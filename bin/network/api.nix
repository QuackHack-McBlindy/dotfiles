# dotfiles/bin/network/api.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ simple bash api to hold timers, shopping list and stuff like dat
  self,
  config,
  pkgs,
  cmdHelpers,
  ...
}: let
  handlerScript = ''
    #!/usr/bin/env bash
    DEBUG="${DEBUG:-false}"
    log() {
      if [[ "$DEBUG" != "false" ]]; then
        echo "[API] $*" >&2
      fi
    }

    send_response() {
      local status_code="$1"
      local body="$2"
      local content_type="''${3:-application/json}"
      local length=$(echo -n "$body" | wc -c)

      cat << RESPONSE
HTTP/1.1 $status_code
Content-Type: $content_type
Access-Control-Allow-Origin: *
Content-Length: $length

$body
RESPONSE
    }

    handle_request() {
      local method=""
      local path=""
      local body=""
      local content_length=""
      read -r request_line
      log "Request: $request_line"
      method=$(echo "$request_line" | awk '{print $1}')
      path=$(echo "$request_line" | awk '{print $2}')
      
      while IFS= read -r header; do
        [[ -z "$header" || "$header" = $'\r' ]] && break
        if [[ "$header" =~ ^[Cc]ontent-[Ll]ength:[[:space:]]*([0-9]+) ]]; then
          content_length="''${BASH_REMATCH[1]}"
        fi
      done

      if [[ -n "$content_length" ]] && [[ "$content_length" -gt 0 ]]; then
        read -r -n "$content_length" body
        log "Body: $body"
      fi

      case "$path" in
        "/" )
          if [[ "$method" == "POST" ]]; then
            # Handle file actions for VLC
            if [[ -n "$body" ]]; then
              action=$(echo "$body" | ${pkgs.jq}/bin/jq -r '.action // empty')
              file_path=$(echo "$body" | ${pkgs.jq}/bin/jq -r '.path // empty')
              
              if [[ -z "$action" || -z "$file_path" ]]; then
                send_response "400 Bad Request" '{"error":"Missing action or path"}'
                return
              fi

              case "$action" in
                "add"|"add_folder")
                  log "Adding to VLC: $file_path"
                  # Convert URL path to filesystem path if needed
                  # Remove any URL encoding and extract the relative path
                  decoded_path=$(printf '%b' "''${file_path//%/\\x}")
                  # If it's a full URL, extract the path component
                  if [[ "$decoded_path" == http* ]]; then
                    decoded_path=$(echo "$decoded_path" | ${pkgs.python3}/bin/python3 -c "from urllib.parse import urlparse; import sys; print(urlparse(sys.stdin.read()).path)")
                  fi
                  
                  # Execute VLC command
                  if yo vlc --add "$decoded_path" 2>/dev/null; then
                    send_response "200 OK" "{\"status\":\"success\",\"message\":\"Added to VLC: $decoded_path\",\"action\":\"$action\"}"
                  else
                    send_response "500 Internal Server Error" "{\"error\":\"Failed to add to VLC: $decoded_path\"}"
                  fi
                  ;;
                "remove")
                  log "Remove action received for: $file_path"
                  # You can implement remove logic here if needed
                  send_response "200 OK" '{"status":"success","message":"Remove action acknowledged"}'
                  ;;
                *)
                  send_response "400 Bad Request" "{\"error\":\"Unknown action: $action\"}"
                  ;;
              esac
            else
              send_response "400 Bad Request" '{"error":"Empty request body"}'
            fi
          else
            send_response "200 OK" '{"service":"yo-api","endpoints":["/timers","/alarms","/shopping","/health"],"file_actions":["add","add_folder","remove"]}'
          fi
          ;;
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
          fi ;;
        "/reminders"|"/remmind"|"/api/reminders" )
          if output=$(yo reminder --list 2>/dev/null); then
            if [[ -n "$output" ]]; then
              json_items=$(printf '%s\n' "$output" | jq -R -s 'split("\n")[:-1]')
              send_response "200 OK" "{\"items\":$json_items}"
            else
              send_response "500 Internal Server Error" '{"error":"Failed to fetch reminders"}'
            fi  
          fi ;;
        "/health" )
          send_response "200 OK" '{"status":"healthy","service":"yo-api","timestamp":"'"$(date -Iseconds)"'"}' ;;
        * )
          send_response "404 Not Found" '{"error":"Endpoint not found","path":"'"$path"'"}' ;;
      esac
    }
    handle_request
  '';  
  
in { 
  networking.firewall.allowedTCPPorts = [9815];
  
  # Add required packages for JSON parsing and URL decoding
  environment.systemPackages = [ 
    pkgs.socat 
    pkgs.netcat
    pkgs.jq
    pkgs.python3  # for URL parsing
  ];
  
  yo.scripts.api = {
    description = "Simple API for collecting system data and VLC file actions";
    category = "🌐 Networking";
    autoStart = builtins.elem config.this.host.hostname [ "homie" ];
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
        exit 1
      fi

      echo "Starting yo API server on $HOST:$PORT" >&2
      echo "Endpoints:" >&2
      echo "  POST /           - Add files/folders to VLC" >&2
      echo "  GET  /timers     - List timers" >&2
      echo "  GET  /alarms     - List alarms" >&2
      echo "  GET  /shopping   - List shopping items" >&2
      echo "  GET  /health     - Health check" >&2
      echo "File Actions:" >&2
      echo "  add        - Add file to VLC playlist" >&2
      echo "  add_folder - Add folder to VLC playlist" >&2
      echo "  remove     - Remove from playlist" >&2
      echo "Press Ctrl+C to stop" >&2

      TMP_HANDLER=$(mktemp)
      cat > "$TMP_HANDLER" << 'EOF'
      ${handlerScript}
EOF
      chmod +x "$TMP_HANDLER"
      socat TCP-LISTEN:"$PORT",bind="$HOST",reuseaddr,fork EXEC:"$TMP_HANDLER"

      trap 'rm -f "$TMP_HANDLER"' EXIT
    '';
  };
}
