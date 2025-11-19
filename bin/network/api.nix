# dotfiles/bin/network/api.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ simple bash api to hold timers, shopping list and stuff like dat
  self,
  config,
  pkgs,
  cmdHelpers,
  ...
} : let
     
  api-rs = pkgs.writeText "api.rs" ''
    use std::env;
    use std::io::{BufRead, BufReader, Read, Write};
    use std::net::{TcpListener, TcpStream};
    use std::process::Command;

    fn log(message: &str) {
        eprintln!("[API] {}", message);
    }

    fn urldecode(s: &str) -> String {
        s.replace('+', " ")
            .chars()
            .collect::<Vec<char>>()
            .windows(3)
            .fold(String::new(), |mut acc, window| {
                if window[0] == '%' {
                    if let Ok(byte) = u8::from_str_radix(&format!("{}{}", window[1], window[2]), 16) {
                        acc.push(byte as char);
                    }
                } else if window.len() == 1 {
                    acc.push(window[0]);
                }
                acc
            })
    }

    fn send_response(stream: &mut TcpStream, status: &str, body: &str, content_type: Option<&str>) {
        let content_type = content_type.unwrap_or("application/json");
        let response = format!(
            "HTTP/1.1 {}\r\nContent-Type: {}\r\nAccess-Control-Allow-Origin: *\r\nContent-Length: {}\r\n\r\n{}",
            status,
            content_type,
            body.len(),
            body
        );
        if let Err(e) = stream.write_all(response.as_bytes()) {
            log(&format!("Failed to send response: {}", e));
        }
    }

    fn get_path_arg(query: &str) -> String {
        let parts: Vec<&str> = query.split('&').collect();
        for part in parts {
            if part.starts_with("path=") {
                let encoded = &part[5..];
                return urldecode(encoded);
            }
        }
        String::new()
    }

    fn handle_browse(path_arg: &str, use_v2: bool) -> String {
        let media_root = "/Pool";
        let full_path = format!("{}/{}", media_root, path_arg);
        
        // 🦆 says ⮞ safety first!
        if !full_path.starts_with(media_root) {
            return r#"{"error":"Access forbidden"}"#.to_string();
        }

        let path_std = std::path::Path::new(&full_path);
        if !path_std.exists() || !path_std.is_dir() {
            return format!(r#"{{"error":"Directory not found: {}"}}"#, path_arg);
        }

        let mut directories = Vec::new();
        let mut files = Vec::new();

        if use_v2 {
            // 🦆 says ⮞ browsev2 logic with find
            let output = Command::new("find")
                .arg(&full_path)
                .arg("-maxdepth")
                .arg("1")
                .arg("-mindepth")
                .arg("1")
                .output();
            
            match output {
                Ok(output) if output.status.success() => {
                    let output_str = String::from_utf8_lossy(&output.stdout);
                    for line in output_str.lines() {
                        if line.is_empty() { continue; }
                        let item_path = std::path::Path::new(line);
                        if let Some(name) = item_path.file_name().and_then(|n| n.to_str()) {
                            if item_path.is_dir() {
                                directories.push(name.to_string());
                            } else {
                                files.push(name.to_string());
                            }
                        }
                    }
                }
                _ => return r#"{"error":"Failed to list directory"}"#.to_string(),
            }
        } else {
            // 🦆 says ⮞ browse logic with ls
            let output = Command::new("ls")
                .arg("-1")
                .arg(&full_path)
                .output();
            
            match output {
                Ok(output) if output.status.success() => {
                    let output_str = String::from_utf8_lossy(&output.stdout);
                    for item in output_str.lines() {
                        if item.is_empty() { continue; }
                        let item_path = path_std.join(item);
                        if item_path.is_dir() {
                            directories.push(item.to_string());
                        } else {
                            files.push(item.to_string());
                        }
                    }
                }
                _ => return r#"{"error":"Failed to list directory"}"#.to_string(),
            }
        }

        directories.sort();
        files.sort();

        let dirs_json = serde_json::to_string(&directories).unwrap_or_else(|_| "[]".to_string());
        let files_json = serde_json::to_string(&files).unwrap_or_else(|_| "[]".to_string());

        if use_v2 {
            let real_full_path = path_std.canonicalize().unwrap_or_else(|_| path_std.to_path_buf());
            format!(
                r#"{{"path":"{}","full_path":"{}","directories":{},"files":{}}}"#,
                path_arg,
                real_full_path.display(),
                dirs_json,
                files_json
            )
        } else {
            format!(
                r#"{{"path":"{}","directories":{},"files":{}}}"#,
                path_arg,
                dirs_json,
                files_json
            )
        }
    }

    fn run_yo_command(args: &[&str]) -> Result<String, String> {
        let output = Command::new("yo")
            .args(args)
            .output()
            .map_err(|e| format!("Failed to execute yo command: {}", e))?;
        
        if output.status.success() {
            Ok(String::from_utf8_lossy(&output.stdout).to_string())
        } else {
            Err(String::from_utf8_lossy(&output.stderr).to_string())
        }
    }

    fn handle_shopping_list() -> String {
        match run_yo_command(&["shop-list", "--list"]) {
            Ok(output) => {
                let items: Vec<&str> = output.lines().collect();
                match serde_json::to_string(&items) {
                    Ok(json_items) => format!(r#"{{"items":{}}}"#, json_items),
                    Err(_) => r#"{"error":"Failed to format shopping list"}"#.to_string(),
                }
            }
            Err(_) => r#"{"error":"Failed to fetch shopping list"}"#.to_string(),
        }
    }

    fn handle_reminders() -> String {
        match run_yo_command(&["reminder", "--list"]) {
            Ok(output) => {
                let items: Vec<&str> = output.lines().collect();
                match serde_json::to_string(&items) {
                    Ok(json_items) => format!(r#"{{"items":{}}}"#, json_items),
                    Err(_) => r#"{"error":"Failed to format reminders"}"#.to_string(),
                }
            }
            Err(_) => r#"{"error":"Failed to fetch reminders"}"#.to_string(),
        }
    }

    fn handle_request(mut stream: TcpStream) {
        let mut reader = BufReader::new(&stream);
        let mut request_line = String::new();
        
        // 🦆 says ⮞ read request line
        if reader.read_line(&mut request_line).is_err() || request_line.is_empty() {
            log("No data on stdin; exiting");
            return;
        }
        log(&format!("Request: {}", request_line.trim()));

        let parts: Vec<&str> = request_line.split_whitespace().collect();
        if parts.len() < 2 {
            return;
        }

        let method = parts[0];
        let raw_path = parts[1];

        // 🦆 says ⮞ read headers
        let mut content_length = 0;
        let mut header_line = String::new();
        loop {
            header_line.clear();
            if reader.read_line(&mut header_line).is_err() || header_line.is_empty() {
                break;
            }
            if header_line == "\r\n" || header_line == "\n" {
                break;
            }
            if header_line.to_lowercase().starts_with("content-length:") {
                if let Some(len_str) = header_line.split(':').nth(1) {
                    content_length = len_str.trim().parse().unwrap_or(0);
                }
            }
        }

        // 🦆 says ⮞ read body if present
        let mut body = String::new();
        if content_length > 0 {
            let mut body_buf = vec![0; content_length];
            if let Ok(()) = reader.read_exact(&mut body_buf) {
                body = String::from_utf8_lossy(&body_buf).to_string();
                log(&format!("Body: {}", body));
            }
        }

        // 🦆 says ⮞ parse path and query
        let (path_no_query, query) = match raw_path.split_once('?') {
            Some((path, query)) => (path, query),
            None => (raw_path, ""),
        };

        // 🦆 says ⮞ route the request
        match path_no_query {
            "/" => {
                send_response(&mut stream, "200 OK", r#"{"service":"yo-api","endpoints":["/timers","/alarms","/shopping","/health","/add","/add_folder"]}"#, None);
            }
            "/browsev2" | "/api/browsev2" => {
                let path_arg = get_path_arg(query);
                let response = handle_browse(&path_arg, true);
                send_response(&mut stream, "200 OK", &response, None);
            }
            "/browse" | "/api/browse" => {
                let path_arg = get_path_arg(query);
                let response = handle_browse(&path_arg, false);
                send_response(&mut stream, "200 OK", &response, None);
            }
            "/add" | "/api/add" => {
                let path_arg = get_path_arg(query);
                if path_arg.is_empty() {
                    send_response(&mut stream, "400 Bad Request", r#"{"error":"Missing path parameter"}"#, None);
                    return;
                }
                log(&format!("Adding file: {}", path_arg));
                match run_yo_command(&["vlc", "--add", &path_arg]) {
                    Ok(_) => send_response(&mut stream, "200 OK", &format!(r#"{{"status":"ok","action":"add","path":"{}"}}"#, path_arg), None),
                    Err(_) => send_response(&mut stream, "500 Internal Server Error", &format!(r#"{{"error":"Failed to add file","path":"{}"}}"#, path_arg), None),
                }
            }
            "/add_folder" | "/api/add_folder" => {
                let path_arg = get_path_arg(query);
                if path_arg.is_empty() {
                    send_response(&mut stream, "400 Bad Request", r#"{"error":"Missing path parameter"}"#, None);
                    return;
                }
                log(&format!("Adding folder: {}", path_arg));
                match run_yo_command(&["vlc", "--addDir", &path_arg]) {
                    Ok(_) => send_response(&mut stream, "200 OK", &format!(r#"{{"status":"ok","action":"add_folder","path":"{}"}}"#, path_arg), None),
                    Err(_) => send_response(&mut stream, "500 Internal Server Error", &format!(r#"{{"error":"Failed to add folder","path":"{}"}}"#, path_arg), None),
                }
            }
            "/timers" | "/api/timers" => {
                match run_yo_command(&["timer", "--list"]) {
                    Ok(output) => send_response(&mut stream, "200 OK", &output, None),
                    Err(_) => send_response(&mut stream, "500 Internal Server Error", r#"{"error":"Failed to fetch timers"}"#, None),
                }
            }
            "/alarms" | "/api/alarms" => {
                match run_yo_command(&["alarm", "--list"]) {
                    Ok(output) => send_response(&mut stream, "200 OK", &output, None),
                    Err(_) => send_response(&mut stream, "500 Internal Server Error", r#"{"error":"Failed to fetch alarms"}"#, None),
                }
            }
            "/shopping" | "/shopping-list" | "/api/shopping" => {
                let response = handle_shopping_list();
                if response.contains("error") {
                    send_response(&mut stream, "500 Internal Server Error", &response, None);
                } else {
                    send_response(&mut stream, "200 OK", &response, None);
                }
            }
            "/reminders" | "/remmind" | "/api/reminders" => {
                let response = handle_reminders();
                if response.contains("error") {
                    send_response(&mut stream, "500 Internal Server Error", &response, None);
                } else {
                    send_response(&mut stream, "200 OK", &response, None);
                }
            }
            "/playlist" | "/api/playlist" => {
                match run_yo_command(&["vlc", "--list"]) {
                    Ok(output) => send_response(&mut stream, "200 OK", &output, None),
                    Err(_) => send_response(&mut stream, "500 Internal Server Error", r#"{"error":"Failed to fetch playlist"}"#, None),
                }
            }
            "/health" => {
                let timestamp = chrono::Local::now().format("%Y-%m-%dT%H:%M:%S%z").to_string();
                send_response(&mut stream, "200 OK", &format!(r#"{{"status":"healthy","service":"yo-api","timestamp":"{}"}}"#, timestamp), None);
            }
            _ => {
                send_response(&mut stream, "404 Not Found", &format!(r#"{{"error":"Endpoint not found","path":"{}"}}"#, raw_path), None);
            }
        }
    }

    fn main() {
        let args: Vec<String> = env::args().collect();
        if args.len() != 3 {
            eprintln!("Usage: {} <host> <port>", args[0]);
            std::process::exit(1);
        }

        let host = &args[1];
        let port = &args[2];
        let address = format!("{}:{}", host, port);

        // 🦆 says ⮞ port in use?
        if TcpListener::bind(&address).is_err() {
            eprintln!("Error: Port {} is already in use", port);
            std::process::exit(1);
        }

        let listener = TcpListener::bind(&address).expect("Failed to bind to address");
        log(&format!("Starting yo API server on {}:{}", host, port));
        log("Endpoints:");
        log("  GET /timers     - List timers");
        log("  GET /alarms     - List alarms");
        log("  GET /shopping   - List shopping items");
        log("  GET /health     - Health check");
        log("Press Ctrl+C to stop");

        for stream in listener.incoming() {
            match stream {
                Ok(stream) => {
                    std::thread::spawn(move || {
                        handle_request(stream);
                    });
                }
                Err(e) => {
                    log(&format!("Connection failed: {}", e));
                }
            }
        }
    }
  '';
  
  cargo-toml = pkgs.writeText "Cargo.toml" ''
    [package]
    name = "api-rs"
    version = "0.1.0"
    edition = "2021"

    [dependencies]
    serde_json = "1.0"
    chrono = { version = "0.4", features = ["serde"] }
  ''; 


  handlerScript = ''
    #!/usr/bin/env bash

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
        
      "/browsev2"|"/api/browsev2" )
        path_arg="$(get_path_arg "$query")"
        MEDIA_ROOT="/Pool"
        full_path="$MEDIA_ROOT/$path_arg"
        real_full_path=$(realpath "$full_path" 2>/dev/null)
        real_media_root=$(realpath "$MEDIA_ROOT")
        if [[ -z "$real_full_path" || ! "$real_full_path" =~ ^$real_media_root ]]; then
          send_response "403 Forbidden" '{"error":"Access forbidden"}'
          exit 0
        fi
    
        if [[ ! -d "$real_full_path" ]]; then
          send_response "404 Not Found" "{\"error\":\"Directory not found: $path_arg\"}"
          exit 0
        fi
    
        directories=()
        files=()
    
        while IFS= read -r item; do
          if [[ -n "$item" ]]; then
            item_name=$(basename "$item")
            if [[ -d "$item" ]]; then
              directories+=("$item_name")
            else
              files+=("$item_name")
            fi
          fi
        done < <(find "$real_full_path" -maxdepth 1 -mindepth 1 2>/dev/null | sort)
    
        dirs_json=$(printf '%s\n' "''${directories[@]}" | jq -R -s 'split("\n") | map(select(. != ""))')
        files_json=$(printf '%s\n' "''${files[@]}" | jq -R -s 'split("\n") | map(select(. != ""))')
    
        send_response "200 OK" "{\"path\":\"$path_arg\",\"full_path\":\"$real_full_path\",\"directories\":$dirs_json,\"files\":$files_json}"
        ;;
      "/browse"|"/api/browse" )
        path_arg="$(get_path_arg "$query")"
    
        if [[ -z "$path_arg" ]]; then
          path_arg=""
        fi
    
        MEDIA_ROOT="/Pool"
        full_path="$MEDIA_ROOT/$path_arg"
    
        # 🦆 says ⮞ SAFETY FIRST
        if [[ ! "$full_path" =~ ^$MEDIA_ROOT ]]; then
          send_response "403 Forbidden" '{"error":"Access forbidden"}'
          exit 0
        fi
    
        if [[ ! -d "$full_path" ]]; then
          send_response "404 Not Found" "{\"error\":\"Directory not found: $path_arg\"}"
          exit 0
        fi
    
        # 🦆 says ⮞ list directories and files
        directories=()
        files=()
    
        while IFS= read -r item; do
          if [[ -n "$item" ]]; then
            item_path="$full_path/$item"
            if [[ -d "$item_path" ]]; then
              directories+=("$item")
            else
              files+=("$item")
            fi
          fi
        done < <(ls -1 "$full_path" 2>/dev/null)
    
        # 🦆 says ⮞ json ist da bomb yo
        dirs_json=$(printf '%s\n' "''${directories[@]}" | jq -R -s 'split("\n") | map(select(. != ""))')
        files_json=$(printf '%s\n' "''${files[@]}" | jq -R -s 'split("\n") | map(select(. != ""))')
    
        send_response "200 OK" "{\"path\":\"$path_arg\",\"directories\":$dirs_json,\"files\":$files_json}" ;;     
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
      { name = "dir"; description = "Directory path to build inside"; default = "/home/" + config.this.user.me.name + "/api-rs";  }       
    ]; 
    code = ''
      ${cmdHelpers} 
      HOST="$host"
      PORT="$port"
      mkdir -p $dir/src
      
      cp ${api-rs} $dir/src/main.rs
      cp ${cargo-toml} $dir/Cargo.toml
      cd "$dir"
      ${pkgs.cargo}/bin/cargo generate-lockfile     
      ${pkgs.cargo}/bin/cargo build --release
      dt_info "Build complete!"

      dt_info "Starting yo API server (Rust) on $HOST:$PORT" >&2
      echo "Endpoints:" >&2
      echo "  GET /timers     - List timers" >&2
      echo "  GET /alarms     - List alarms" >&2
      echo "  GET /shopping   - List shopping items" >&2
      echo "  GET /health     - Health check" >&2
      echo "Press Ctrl+C to stop" >&2

      # 🦆 says ⮞ check yo.scripts.do if DEBUG mode yo
      if [ "$VERBOSE" -ge 1 ]; then
        while true; do
          # 🦆 says ⮞ keep me alive plx
          DEBUG=1 DT_LOG_FILE_PATH="$DT_LOG_PATH$DT_LOG_FILE" ./target/release/api-rs "$HOST" "$PORT"
          EXIT_CODE=$?
          dt_error "api-rs exited with code $EXIT_CODE, restarting in 3 seconds..."
          sleep 3
       done
      fi  
      # 🦆 says ⮞ keep me alive plx
      while true; do
        # 🦆 says ⮞ else run debugless yo
        DT_LOG_FILE_PATH="$DT_LOG_PATH$DT_LOG_FILE" ./target/release/api-rs "$HOST" "$PORT"
        EXIT_CODE=$?
        dt_error "api-rs exited with code $EXIT_CODE, restarting in 3 seconds..."
        sleep 3
      done         
    '';      
    
  };}
