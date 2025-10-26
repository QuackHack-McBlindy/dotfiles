# dotfiles/bin/network/api.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ simple bash api to hold timers, shopping list and stuff like dat
  self,
  config,
  pkgs,
  cmdHelpers,
  ...
} : let
  handlerScript = ''
    #!/usr/bin/env bash
    source {cmdHelpers}
    log(){ dt_debug "[API] $*"; }
    
    urldecode() {
      local encoded="$1"
      printf '%b' "''${encoded//%/\\x}"
    }
    
    send_response() {
      local status="$1"
      local body="$2"
      local content_type="''${3:-application/json}"
      local length
      length=$(printf "%s" "$body" | wc -c)
    
      printf "HTTP/1.1 %s\r\n" "$status"
      printf "Content-Type: %s\r\n" "$content_type"
      printf "Access-Control-Allow-Origin: *\r\n"
      printf "Content-Length: %s\r\n" "$length"
      printf "\r\n"
      printf "%s" "$body"
    }
    
    # 🦆 says ⮞ read request line empty? exit
    if ! IFS= read -r request_line; then
      log "No data on stdin; exiting"
      exit 0
    fi
    log "Request: $request_line"
    
    method=$(printf "%s" "$request_line" | awk "{print \$1}")
    raw_path=$(printf "%s" "$request_line" | awk "{print \$2}")
    
    content_length=0
    while IFS= read -r header; do
      [[ -z "$header" || "$header" = $'\r' ]] && break
      if [[ "$header" =~ ^[Cc]ontent-[Ll]ength:[[:space:]]*([0-9]+) ]]; then
        content_length="''${BASH_REMATCH[1]}"
      fi
    done
    
    body=""
    if [[ -n "$content_length" && "$content_length" -gt 0 ]]; then
      read -r -n "$content_length" body
      log "Body: $body"
    fi
    
    # 🦆 says ⮞ strip query
    path_no_query="''${raw_path%%\?*}"
    query="''${raw_path#*\?}"
    
    get_path_arg() {
      local q="$1"
      local val
      # 🦆 says ⮞ drop everything before 'path=' and stop at '&'
      val="''${q#*path=}"
      val="''${val%%&*}"
      val="''${val//+/ }"
      urldecode "$val"
    }


    
    case "$path_no_query" in
      "/" )
        send_response "200 OK" '{"service":"yo-api","endpoints":["/timers","/alarms","/shopping","/health","/add","/add_folder"]}' ;;
      "/add"|"/api/add" )
        path_arg="$(get_path_arg "$query")"
        if [[ -z "$path_arg" ]]; then
          send_response "400 Bad Request" '{"error":"Missing path parameter"}'
          exit 0
        fi
        log "Adding file: $path_arg"
        if yo vlc --add "$path_arg" >/dev/null 2>&1; then
          send_response "200 OK" "{\"status\":\"ok\",\"action\":\"add\",\"path\":\"$path_arg\"}"
        else
          send_response "500 Internal Server Error" "{\"error\":\"Failed to add file\",\"path\":\"$path_arg\"}"
        fi ;;
      "/add_folder"|"/api/add_folder" )
        path_arg="$(get_path_arg "$query")"
        if [[ -z "$path_arg" ]]; then
          send_response "400 Bad Request" '{"error":"Missing path parameter"}'
          exit 0
        fi
        log "Adding folder: $path_arg"
        if yo vlc --addDir "$path_arg" >/dev/null 2>&1; then
          send_response "200 OK" "{\"status\":\"ok\",\"action\":\"add_folder\",\"path\":\"$path_arg\"}"
        else
          send_response "500 Internal Server Error" "{\"error\":\"Failed to add folder\",\"path\":\"$path_arg\"}"
        fi ;;
      "/timers"|"/api/timers" )
        if output=$(yo timer --list 2>/dev/null); then
          send_response "200 OK" "$output"
        else
          send_response "500 Internal Server Error" '{"error":"Failed to fetch timers"}'
        fi ;;
      "/alarms"|"/api/alarms" )
        if output=$(yo alarm --list 2>/dev/null); then
          send_response "200 OK" "$output"
        else
          send_response "500 Internal Server Error" '{"error":"Failed to fetch alarms"}'
        fi ;;
      "/shopping"|"/shopping-list"|"/api/shopping" )
        if output=$(yo shop-list --list 2>/dev/null); then
          if [[ -n "$output" ]]; then
            json_items=$(printf '%s\n' "$output" | jq -R -s 'split("\n")[:-1]')
            send_response "200 OK" "{\"items\":$json_items}"
          else
            send_response "500 Internal Server Error" '{"error":"Failed to fetch shopping list"}'
          fi
        else
          send_response "500 Internal Server Error" '{"error":"Failed to fetch shopping list"}'
        fi ;;
      "/reminders"|"/remmind"|"/api/reminders" )
        if output=$(yo reminder --list 2>/dev/null); then
          if [[ -n "$output" ]]; then
            json_items=$(printf '%s\n' "$output" | jq -R -s 'split("\n")[:-1]')
            send_response "200 OK" "{\"items\":$json_items}"
          else
            send_response "500 Internal Server Error" '{"error":"Failed to fetch reminders"}'
          fi
        else
          send_response "500 Internal Server Error" '{"error":"Failed to fetch reminders"}'
        fi ;;
      "/playlist"|"/api/playlist" )
        if output=$(yo vlc --list 2>/dev/null); then
          send_response "200 OK" "$output"
        else
          send_response "500 Internal Server Error" '{"error":"Failed to fetch playlist"}'
        fi ;;
      "/health" )
        send_response "200 OK" "{\"status\":\"healthy\",\"service\":\"yo-api\",\"timestamp\":\"$(date -Iseconds)\"}" ;;
      * )
        send_response "404 Not Found" "{\"error\":\"Endpoint not found\",\"path\":\"$raw_path\"}" ;;
    esac
    '
  '';  
  
in { 
  networking.firewall.allowedTCPPorts = [9815];
  # 🦆 says ⮞ fancy cat'z...
  environment.systemPackages = [ pkgs.socat pkgs.netcat ];
  # 🦆 says ⮞  da script yo
  yo.scripts.api = {
    description = "Simple API for collecting system data";
    category = "🌐 Networking";
    autoStart = builtins.elem config.this.host.hostname [ "homie" ];
    logLevel = "DEBUG";
    parameters = [
      { name = "host"; description = "IP to run server on"; default = "0.0.0.0"; }
      { name = "port"; description = "Port for the service"; default = 9815;  } 
    ]; 
    code = ''
      ${cmdHelpers} 
      HOST="$host"
      PORT="$port"

      if command -v ss >/dev/null 2>&1 && ss -tuln | grep -q ":$PORT "; then
        echo "Error: Port $PORT is already in use" >&2
        dt_error "Port $PORT is already in use"
        exit 1
      fi

      dt_info "Starting yo API server on $HOST:$PORT" >&2
      dt_info "Endpoints:" >&2
      dt_info "  GET /timers     - List timers" >&2
      dt_info "  GET /alarms     - List alarms" >&2
      dt_info "  GET /shopping   - List shopping items" >&2
      dt_info "  GET /health     - Health check" >&2
      dt_info "Press Ctrl+C to stop" >&2

      TMP_HANDLER=$(mktemp)
      cat > "$TMP_HANDLER" << 'EOF'
      ${handlerScript}
EOF
      chmod +x "$TMP_HANDLER"
      socat TCP-LISTEN:"$PORT",bind="$HOST",reuseaddr,fork EXEC:"$TMP_HANDLER"

      trap 'rm -f "$TMP_HANDLER"' EXIT
    '';
    
  };}
