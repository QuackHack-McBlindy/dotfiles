# dotfiles/bin/network/api.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ 
  self,
  config,
  pkgs,
  cmdHelpers,
  ...
} : let
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
          send_response "200 OK" '{"service":"yo-api","endpoints":["/timers","/alarms","/shopping","/health"]}' ;;
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
            send_response "200 OK" "$output"
          else
            send_response "500 Internal Server Error" '{"error":"Failed to fetch shopping list"}'
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
  environment.systemPackages = [ pkgs.socat pkgs.netcat ];
  yo.scripts.api = {
    description = "Simple API for collecting system data";
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
      echo "  GET /timers     - List timers" >&2
      echo "  GET /alarms     - List alarms" >&2
      echo "  GET /shopping   - List shopping items" >&2
      echo "  GET /health     - Health check" >&2
      echo "Press Ctrl+C to stop" >&2

      TMP_HANDLER=$(mktemp)
      cat > "$TMP_HANDLER" << 'EOF'
      ${handlerScript}
EOF
      chmod +x "$TMP_HANDLER"
      socat TCP-LISTEN:"$PORT",bind="$HOST",reuseaddr,fork EXEC:"$TMP_HANDLER"

      trap 'rm -f "$TMP_HANDLER"' EXIT
    '';
    
  };}
