# dotfiles/bin/network/api.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ home automation API endpoints, written in Rust
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  RustDuckTrace,
  ...
} : let     
  # 🦆 says ⮞ dis fetch what host has Mosquitto
  sysHosts = lib.attrNames self.nixosConfigurations; 
  mqttHost = lib.findSingle (host:
      let cfg = self.nixosConfigurations.${host}.config;
      in cfg.services.mosquitto.enable or false
    ) null null sysHosts;    
  mqttHostip = if mqttHost != null
    then self.nixosConfigurations.${mqttHost}.config.this.host.ip or (
      let
        resolved = builtins.readFile (pkgs.runCommand "resolve-host" {} ''
          ${pkgs.dnsutils}/bin/host -t A ${mqttHost} > $out
        '');
      in
        lib.lists.head (lib.strings.splitString " " (lib.lists.elemAt (lib.strings.splitString "\n" resolved) 0))
    )
    else (throw "No Mosquitto host found in configuration");
  mqttAuth = "-u mqtt -P $(cat ${config.sops.secrets.mosquitto.path})";
    
  # 🦆 says ⮞ define Zigbee devices here yo 
  zigbeeDevices = config.house.zigbee.devices;
  
  # 🦆 says ⮞ case-insensitive device matching
  normalizedDeviceMap = lib.mapAttrs' (id: device:
    lib.nameValuePair (lib.toLower device.friendly_name) device.friendly_name
  ) zigbeeDevices;

  # 🦆 says ⮞ device validation list
  deviceList = builtins.attrNames normalizedDeviceMap;

  # 🦆 says ⮞ scene simplifier? or not
  sceneLight = {state, brightness ? 200, hex ? null, temp ? null}:
    let
      colorValue = if hex != null then { inherit hex; } else null;
    in
    {
      inherit state brightness;
    } // (if colorValue != null then { color = colorValue; } else {})
      // (if temp != null then { color_temp = temp; } else {});

  # 🎨 Scenes  🦆 YELLS ⮞ SCENES!!!!!!!!!!!!!!!11
  scenes = config.house.zigbee.scenes; # 🦆 says ⮞ Declare light states, quack dat's a scene yo!   

  # 🦆 says ⮞ Generate scene commands    
  makeCommand = device: settings:
    let
      json = builtins.toJSON settings;
    in
      ''
      yo mqtt_pub --topic "zigbee2mqtt/${device}/set" --message '${json}'
      '';
      
  sceneCommands = lib.mapAttrs
    (sceneName: sceneDevices:
      lib.mapAttrs (device: settings: makeCommand device settings) sceneDevices
    ) scenes;  

  # 🦆 says ⮞ Filter devices by rooms
  byRoom = lib.foldlAttrs (acc: id: dev:
    lib.recursiveUpdate acc {
      ${dev.room} = (acc.${dev.room} or []) ++ [ id ];
    }) {} zigbeeDevices;

  # 🦆 says ⮞ Filter by device type
  byType = lib.foldlAttrs (acc: id: dev:
    lib.recursiveUpdate acc {
      ${dev.type} = (acc.${dev.type} or []) ++ [ id ];
    }) {} zigbeeDevices;

  # 🦆 says ⮞ dis creates group configuration for Z2M yo
  groupConfig = lib.mapAttrs' (room: ids: {
    name = room;
    value = {
      friendly_name = room;
      devices = map (id: 
        let dev = zigbeeDevices.${id};
        in "${id}/${toString dev.endpoint}"
      ) ids;
    };
  }) byRoom;

  # 🦆 says ⮞ gen json from `config.house.tv`  
  tvDevicesJson = pkgs.writeText "tv-devices.json" (builtins.toJSON config.house.tv);

  # 🦆 says ⮞ dis creates device configuration for Z2M yo
  deviceConfig = lib.mapAttrs (id: dev: {
    friendly_name = dev.friendly_name;
  }) zigbeeDevices;

  # 🦆 says ⮞ IEEE not very human readable - lets fix dat yo
  ieeeToFriendly = lib.mapAttrs (ieee: dev: dev.friendly_name) zigbeeDevices;
  mappingJSON = builtins.toJSON ieeeToFriendly;
  mappingFile = pkgs.writeText "ieee-to-friendly.json" mappingJSON;

  # 🦆 says ⮞ not to be confused with facebook - this is not even duckbook
  deviceMeta = builtins.toJSON (
    lib.listToAttrs (
      lib.filter (attr: attr.name != null) (
        lib.mapAttrsToList (_: dev: {
          name = dev.friendly_name;
          value = {
            room = dev.room;
            type = dev.type;
            id = dev.friendly_name;
            endpoint = dev.endpoint;
          };
        }) zigbeeDevices
      )
    )
  );# 🦆 says ⮞ yaaaaaaaaaaaaaaay

  # 🦆 says ⮞ Generate automations configuration
  automationsJSON = builtins.toJSON config.house.zigbee.automations;
  automationsFile = pkgs.writeText "automations.json" automationsJSON;

  # 🦆 says ⮞ Dark time enabled flag
  darkTimeEnabled = if config.house.zigbee.darkTime.enable then "1" else "0";

  # 🦆 needz 4 rust  
  devices-json = pkgs.writeText "devices.json" deviceMeta;

  scenes-json = pkgs.writeText "scenes.json" (builtins.toJSON sceneCommands);
  rooms-json = pkgs.writeText "rooms.json" (builtins.toJSON (
    lib.mapAttrs (room: devices: {
      inherit room;
      devices = map (id: zigbeeDevices.${id}.friendly_name) devices;
    }) byRoom
  ));
  types-json = pkgs.writeText "types.json" (builtins.toJSON (
    lib.mapAttrs (type: devices: {
      inherit type;
      devices = map (id: zigbeeDevices.${id}.friendly_name) devices;
    }) byType
  ));

  #  🦆 says ⮞ API   
  cargo-toml = pkgs.writeText "Cargo.toml" ''
    [package]
    name = "api-rs"
    version = "0.1.0"
    edition = "2021"

    [dependencies]
    serde_json = "1.0"
    chrono = { version = "0.4", features = ["serde"] }
    multipart = "0.18"
    colored = "2.1" 
  ''; 

  api-rs = pkgs.writeText "api.rs" ''
    ${RustDuckTrace}
    
    use std::io::{BufRead, BufReader, Read};
    use std::net::{TcpListener, TcpStream};
    use std::process::Command;
    use std::collections::HashMap;
    use std::fs::{self, create_dir_all};
    use serde_json::json;
    

    fn log(message: &str) {
        eprintln!("[API] {}", message);
    }

    // 🦆 says ⮞ Password authentication function
    fn check_password_auth(headers: &HashMap<String, String>, query: &str) -> bool {
        let password_file_path = std::env::var("YO_API_PASSWORD_FILE")
            .unwrap_or_else(|_| "${config.house.dashboard.passwordFile}".to_string());
        
        let expected_password = match std::fs::read_to_string(&password_file_path) {
            Ok(content) => content.trim().to_string(),
            Err(_) => {
                log(&format!("Warning: Could not read password file: {}", password_file_path));
                return false;
            }
        };
        
        if let Some(auth_header) = headers.get("authorization") {
            if auth_header.starts_with("Bearer ") {
                let provided_password = auth_header[7..].trim();
                return provided_password == expected_password;
            } else if auth_header.starts_with("Password ") {
                let provided_password = auth_header[9..].trim();
                return provided_password == expected_password;
            }
        }
        
        let query_password = get_query_arg(query, "password");
        if !query_password.is_empty() && query_password == expected_password {
            return true;
        }
        
        if let Some(api_key) = headers.get("x-api-key") {
            return api_key.trim() == expected_password;
        }       
        false
    }
        
    fn urldecode(s: &str) -> String {
        let mut result = Vec::new();
        let bytes = s.bytes().collect::<Vec<_>>();
        let mut i = 0;
    
        while i < bytes.len() {
            match bytes[i] {
                b'%' if i + 2 < bytes.len() => {
                    if let (Some(high), Some(low)) = (from_hex(bytes[i + 1]), from_hex(bytes[i + 2])) {
                        let byte = (high << 4) | low;
                        result.push(byte);
                        i += 3;
                        continue;
                    }
                }
                b'+' => {
                    result.push(b' ');
                }
                _ => {
                    result.push(bytes[i]);
                }
            }
            i += 1;
        }
    
        String::from_utf8(result).unwrap_or_else(|_| s.to_string())
    }
    
    fn from_hex(byte: u8) -> Option<u8> {
        match byte {
            b'0'..=b'9' => Some(byte - b'0'),
            b'a'..=b'f' => Some(byte - b'a' + 10),
            b'A'..=b'F' => Some(byte - b'A' + 10),
            _ => None,
        }
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
    
    fn get_query_arg(query: &str, arg_name: &str) -> String {
        let parts: Vec<&str> = query.split('&').collect();
        for part in parts {
            if part.starts_with(&format!("{}=", arg_name)) {
                let encoded = &part[arg_name.len() + 1..];
                return urldecode(encoded);
            }
        }
        String::new()
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
            dt_warning(&format!("Access forbidden for path: {}", path_arg));
            return r#"{"error":"Access forbidden"}"#.to_string();
        }
    
        let path_std = std::path::Path::new(&full_path);
        if !path_std.exists() || !path_std.is_dir() {
            return format!(r#"{{"error":"Directory not found: {}"}}"#, path_arg);
        }
    
        let mut directories = Vec::new();
        let mut files = Vec::new();
    
        if use_v2 {
            // 🦆 says ⮞ browsev2 with find
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

    fn handle_file_upload(headers: &HashMap<String, String>, body: &[u8]) -> String {
        let uploads_dir = "/var/lib/zigduck/uploads";
        if let Err(e) = create_dir_all(uploads_dir) {
            return format!(r#"{{"error":"Failed to create uploads directory: {}"}}"#, e);
        }
    
        let content_type = headers.get("content-type").unwrap_or(&String::new()).clone();
        
        if !content_type.contains("multipart/form-data") {
            return r#"{"error":"Only multipart/form-data uploads are supported"}"#.to_string();
        }
        
        let boundary = if let Some(idx) = content_type.find("boundary=") {
            content_type[idx + "boundary=".len()..].trim().to_string()
        } else {
            return r#"{"error":"No boundary in Content-Type"}"#.to_string();
        };
        
        dt_debug(&format!("Boundary: {}", boundary));
        
        let body_str = match String::from_utf8(body.to_vec()) {
            Ok(s) => s,
            Err(_) => return r#"{"error":"Body is not valid UTF-8"}"#.to_string(),
        };
        
        let boundary_marker = format!("--{}", boundary);
        let parts: Vec<&str> = body_str.split(&boundary_marker).collect();
        
        dt_debug(&format!("Found {} parts", parts.len()));
        
        for (i, part) in parts.iter().enumerate().skip(1) {
            if i == parts.len() - 1 && part.trim().ends_with("--") {
                continue;
            }
            
            let part = part.trim();
            if part.is_empty() {
                continue;
            }
            
            log(&format!("Part {}: {} chars", i, part.len()));
            
            if let Some(idx) = part.find("\r\n\r\n") {
                let headers_part = &part[..idx];
                let content_start = idx + 4;
                let content = &part[content_start..];
                
                let mut filename = None;
                for line in headers_part.split("\r\n") {
                    if line.to_lowercase().contains("filename=") {
                        if let Some(start_idx) = line.find("filename=\"") {
                            let start = start_idx + "filename=\"".len();
                            if let Some(end_idx) = line[start..].find('\"') {
                                filename = Some(line[start..start + end_idx].to_string());
                                break;
                            }
                        }
                    }
                }
                
                if let Some(original_filename) = filename {
                    // 🦆 says ⮞ helper 2 get unique filename
                    fn get_unique_filename(dir: &str, base: &str) -> Result<String, String> {
                        use std::path::Path;               
                        const MAX_ATTEMPTS: usize = 1000;
                        
                        let path = Path::new(base);
                        let stem = path.file_stem().and_then(|s| s.to_str()).unwrap_or("file");
                        let ext = path.extension().and_then(|s| s.to_str()).unwrap_or("");
                        
                        let mut candidate = base.to_string();
                        let mut full_path = Path::new(dir).join(&candidate);
                        
                        if !full_path.exists() {
                            log(&format!("Base filename available: {}", candidate));
                            return Ok(candidate);
                        }
                        
                        log(&format!("Base filename exists: {}, generating unique name", candidate));
                        
                        for counter in 1..=MAX_ATTEMPTS {
                            candidate = if ext.is_empty() {
                                format!("{}({})", stem, counter)
                            } else {
                                format!("{}({}).{}", stem, counter, ext)
                            };
                            
                            full_path = Path::new(dir).join(&candidate);
                            if !full_path.exists() {
                                log(&format!("Found unique filename: {}", candidate));
                                return Ok(candidate);
                            }
                        }               
                        Err(format!("Could not find unique filename after {} attempts", MAX_ATTEMPTS))
                    }
                    
                    let sanitized = sanitize_filename(&original_filename);
                    log(&format!("Sanitized filename: {}", sanitized));
                    
                    match get_unique_filename(uploads_dir, &sanitized) {
                        Ok(unique_name) => {
                            let destination = format!("{}/{}", uploads_dir, unique_name);
                            let clean_content = content.trim_end_matches("\r\n");
                            
                            log(&format!("Writing {} bytes to {}", clean_content.len(), destination));
                            
                            match std::fs::write(&destination, clean_content) {
                                Ok(_) => {
                                    let file_size = clean_content.len();
                                    
                                    let response = json!({
                                        "status": "success",
                                        "message": "File uploaded successfully",
                                        "files": [{
                                            "filename": unique_name,
                                            "original_filename": original_filename,
                                            "size": file_size,
                                            "path": destination
                                        }]
                                    }).to_string();
                                    
                                    log(&format!("Upload successful: {}", response));
                                    return response;
                                }
                                Err(e) => {
                                    let error_msg = format!(r#"{{"error":"Failed to write file: {}"}}"#, e);
                                    log(&format!("Write error: {}", error_msg));
                                    return error_msg;
                                }
                            }
                        }
                        Err(e) => {
                            let error_msg = format!(r#"{{"error":"{}"}}"#, e);
                            log(&format!("Unique filename error: {}", error_msg));
                            return error_msg;
                        }
                    }
                }
            }
        }   
        r#"{"error":"No file found in upload"}"#.to_string()
    }

    fn sanitize_filename(filename: &str) -> String {
        let mut sanitized = String::new();
        for c in filename.chars() {
            if c.is_alphanumeric() || c == '.' || c == '-' || c == '_' {
                sanitized.push(c);
            } else if c == ' ' {
                sanitized.push('_');
            }
        }    
        // 🦆 says ⮞ make sure we have at least something
        if sanitized.is_empty() {
            format!("file_{}.bin", chrono::Local::now().format("%Y%m%d_%H%M%S"))
        } else {
            sanitized
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
    
    // 🦆 says ⮞ device control endpoints
    fn handle_device_list() -> String {
        match fs::read_to_string("devices.json") {
            Ok(content) => content,
            Err(_) => r#"{"error":"Devices file not found"}"#.to_string(),
        }
    }
    
    fn handle_device_control(device_name: &str, action: &str, value: &str) -> String {
        let devices_json = fs::read_to_string("devices.json").unwrap_or_else(|_| "{}".to_string());
        let devices: HashMap<String, serde_json::Value> = serde_json::from_str(&devices_json).unwrap_or_default();
    
        let mut found_device = None;
        for (dev_name, _) in &devices {
            if dev_name.to_lowercase() == device_name.to_lowercase() {
                found_device = Some(dev_name);
                break;
            }
        }
    
        match found_device {
            Some(actual_name) => {
                let topic = format!("zigbee2mqtt/{}/set", actual_name);
                let message = match action {
                    "on" => r#"{"state": "ON"}"#.to_string(),
                    "off" => r#"{"state": "OFF"}"#.to_string(),
                    "brightness" => {
                        if let Ok(brightness) = value.parse::<u16>() {
                            format!(r#"{{"state": "ON", "brightness": {}}}"#, brightness)
                        } else {
                            r#"{"error":"Invalid brightness value"}"#.to_string()
                        }
                    }
                    "color" => {
                        if value.starts_with('#') && value.len() == 7 {
                            format!(r#"{{"state": "ON", "color": {{"hex": "{}"}}}}"#, value)
                        } else {
                            r#"{"error":"Invalid color format, use #RRGGBB"}"#.to_string()
                        }
                    }
                    "temp" => {
                        if let Ok(temp) = value.parse::<u16>() {
                            format!(r#"{{"state": "ON", "color_temp": {}}}"#, temp)
                        } else {
                            r#"{"error":"Invalid temperature value"}"#.to_string()
                        }
                    }
                    _ => r#"{"error":"Unknown action"}"#.to_string()
                };
                if message.contains("error") {
                    message
                } else {
                    match run_yo_command(&["mqtt_pub", "--topic", &topic, "--message", &message]) {
                        Ok(_) => format!(r#"{{"status":"ok","device":"{}","action":"{}"}}"#, actual_name, action),
                        Err(e) => format!(r#"{{"error":"Failed to control device: {}"}}"#, e),
                    }
                }
            }
            None => format!(r#"{{"error":"Device not found: {}"}}"#, device_name),
        }
    }
    
    fn handle_scene_activate(scene_name: &str) -> String {
        if scene_name.is_empty() {
            return r#"{"error":"Missing scene name"}"#.to_string();
        }
        let scenes_json = fs::read_to_string("scenes.json").unwrap_or_else(|_| "{}".to_string());
        let scenes: HashMap<String, serde_json::Value> = serde_json::from_str(&scenes_json).unwrap_or_default();
    
        let mut found_scene = None;
        for (scene_key, _) in &scenes {
            if scene_key.to_lowercase() == scene_name.to_lowercase() {
                found_scene = Some(scene_key);
                break;
            }
        }
    
        match found_scene {
            Some(actual_scene) => {
                let scene_commands = &scenes[actual_scene];
                let mut success_count = 0;
                let mut total_count = 0;
    
                if let Some(command_map) = scene_commands.as_object() {
                    for (_device, command_value) in command_map {
                        if let Some(command) = command_value.as_str() {
                            total_count += 1;
                            if run_yo_command(&["sh", "-c", command]).is_ok() {
                                success_count += 1;
                            }
                        }
                    }
                }
    
                if success_count == total_count {
                    format!(r#"{{"status":"ok","scene":"{}","devices_updated":{}}}"#, actual_scene, success_count)
                } else {
                    format!(r#"{{"status":"partial","scene":"{}","successful":{}, "failed":{}}}"#, 
                        actual_scene, success_count, total_count - success_count)
                }
            }
            None => format!(r#"{{"error":"Scene not found: {}"}}"#, scene_name),
        }
    }
    
    fn handle_rooms_list() -> String {
        match fs::read_to_string("rooms.json") {
            Ok(content) => content,
            Err(_) => r#"{"error":"Rooms data not available"}"#.to_string(),
        }
    }
    
    fn handle_types_list() -> String {
        match fs::read_to_string("types.json") {
            Ok(content) => content,
            Err(_) => r#"{"error":"Types data not available"}"#.to_string(),
        }
    }
    
    fn handle_health_check() -> String {
        match Command::new("health").output() {
            Ok(output) if output.status.success() => {
                let health_output = String::from_utf8_lossy(&output.stdout);
                // 🦆 says ⮞ health script already returns JSON, so we can use it directly
                health_output.to_string()
            }
            Ok(output) => {
                let error_msg = String::from_utf8_lossy(&output.stderr);
                // 🦆 says ⮞ fallback if health command fails
                let timestamp = chrono::Local::now().format("%Y-%m-%dT%H:%M:%S%z").to_string();
                format!(
                    r#"{{"status":"degraded","service":"yo-api","timestamp":"{}","error":"Health check failed: {}"}}"#,
                    timestamp, error_msg
                )
            }
            Err(e) => {
                // 🦆 says ⮞ fallback if health command not found
                let timestamp = chrono::Local::now().format("%Y-%m-%dT%H:%M:%S%z").to_string();
                format!(
                    r#"{{"status":"degraded","service":"yo-api","timestamp":"{}","error":"Health command failed: {}"}}"#,
                    timestamp, e
                )
            }
        }
    }

    fn handle_health_all() -> String {
        let health_dir = "/var/lib/zigduck/health";
        let mut health_data = std::collections::HashMap::new();

        if let Ok(entries) = std::fs::read_dir(health_dir) {
            for entry in entries.flatten() {
                let path = entry.path();
                if path.extension().and_then(|s| s.to_str()) == Some("json") {
                    if let Some(file_stem) = path.file_stem().and_then(|s| s.to_str()) {
                        if let Ok(content) = std::fs::read_to_string(&path) {
                            if let Ok(json) = serde_json::from_str::<serde_json::Value>(&content) {
                                health_data.insert(file_stem.to_string(), json);
                            }
                        }
                    }
                }
            }
        }

        match serde_json::to_string(&health_data) {
            Ok(json) => json,
            Err(_) => r#"{"error":"Failed to serialize health data"}"#.to_string(),
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
        let mut headers = HashMap::new();
        let mut header_line = String::new();
        loop {
            header_line.clear();
            if reader.read_line(&mut header_line).is_err() || header_line.is_empty() {
                break;
            }
            if header_line == "\r\n" || header_line == "\n" {
                break;
            }
            
            if let Some((key, value)) = header_line.split_once(':') {
                let key_lower = key.trim().to_lowercase();
                let value_trimmed = value.trim().to_string();
                
                if key_lower == "content-length" {
                    content_length = value_trimmed.parse().unwrap_or(0);
                }
                
                headers.insert(key_lower, value_trimmed);
            }
        }
    
        // 🦆 says ⮞ read body if present
        let mut body = Vec::new();
        if content_length > 0 {
            let mut body_buf = vec![0; content_length];
            if let Ok(()) = reader.read_exact(&mut body_buf) {
                body = body_buf;
                log(&format!("Body size: {} bytes", body.len()));
            }
        }
    
        // 🦆 says ⮞ parse path and query
        let (path_no_query, query) = match raw_path.split_once('?') {
            Some((path, query)) => (path, query),
            None => (raw_path, ""),
        };
    
        // 🦆 says ⮞ exclude authentication for health
        if path_no_query != "/health" && path_no_query != "/health/all" && !check_password_auth(&headers, query) {
            send_response(&mut stream, "401 Unauthorized", 
                r#"{"error":"Authentication required","message":"Valid password required in Authorization: Bearer <password> header, X-API-Key header, or ?password= query parameter"}"#, 
                None);
            return;
        }
    
        // 🦆 says ⮞ route the request
        match (method, path_no_query) {
            ("GET", "/") => {
                send_response(&mut stream, "200 OK", 
                    r#"{"service":"yo-api","endpoints":["/timers","/alarms","/shopping","/reminders","/health","/browse","/browsev2","/add","/add_folder","/playlist","/playlist/remove","/playlist/clear","/playlist/shuffle","/do","/device/list","/device/control","/scene/activate","/device/rooms","/device/types","/upload","/tts"]}"#, 
                    None);
            }
            ("GET", "/browsev2") | ("GET", "/api/browsev2") => {
                let path_arg = get_path_arg(query);
                let response = handle_browse(&path_arg, true);
                send_response(&mut stream, "200 OK", &response, None);
            }
            ("GET", "/browse") | ("GET", "/api/browse") => {
                let path_arg = get_path_arg(query);
                let response = handle_browse(&path_arg, false);
                send_response(&mut stream, "200 OK", &response, None);
            }
            ("GET", "/add") | ("GET", "/api/add") => {
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
            ("GET", "/add_folder") | ("GET", "/api/add_folder") => {
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
            ("GET", "/timers") | ("GET", "/api/timers") => {
                match run_yo_command(&["timer", "--list"]) {
                    Ok(output) => send_response(&mut stream, "200 OK", &output, None),
                    Err(_) => send_response(&mut stream, "500 Internal Server Error", r#"{"error":"Failed to fetch timers"}"#, None),
                }
            }
            ("GET", "/alarms") | ("GET", "/api/alarms") => {
                match run_yo_command(&["alarm", "--list"]) {
                    Ok(output) => send_response(&mut stream, "200 OK", &output, None),
                    Err(_) => send_response(&mut stream, "500 Internal Server Error", r#"{"error":"Failed to fetch alarms"}"#, None),
                }
            }
            ("GET", "/shopping") | ("GET", "/shopping-list") | ("GET", "/api/shopping") => {
                let response = handle_shopping_list();
                if response.contains("error") {
                    send_response(&mut stream, "500 Internal Server Error", &response, None);
                } else {
                    send_response(&mut stream, "200 OK", &response, None);
                }
            }
            ("GET", "/reminders") | ("GET", "/remmind") | ("GET", "/api/reminders") => {
                let response = handle_reminders();
                if response.contains("error") {
                    send_response(&mut stream, "500 Internal Server Error", &response, None);
                } else {
                    send_response(&mut stream, "200 OK", &response, None);
                }
            }
            ("GET", "/playlist") | ("GET", "/api/playlist") => {
                match run_yo_command(&["vlc", "--list"]) {
                    Ok(output) => send_response(&mut stream, "200 OK", &output, None),
                    Err(_) => send_response(&mut stream, "500 Internal Server Error", r#"{"error":"Failed to fetch playlist"}"#, None),
                }
            }           
            ("GET", "/playlist/remove") | ("GET", "/api/playlist/remove") => {
                let index_str = get_query_arg(query, "index");
                if index_str.is_empty() {
                    send_response(&mut stream, "400 Bad Request", r#"{"error":"Missing index parameter"}"#, None);
                    return;
                }
    
                match run_yo_command(&["vlc", "--list"]) {
                    Ok(playlist_json) => {
                        match serde_json::from_str::<serde_json::Value>(&playlist_json) {
                            Ok(parsed) => {
                                if let Some(playlist_array) = parsed.get("playlist").and_then(|p| p.as_array()) {
                                    let index = index_str.parse::<usize>().unwrap_or(usize::MAX);
                                    if index >= playlist_array.len() {
                                        send_response(&mut stream, "400 Bad Request", 
                                            &format!(r#"{{"error":"Index {} out of bounds (playlist has {} items)"}}"#, 
                                            index, playlist_array.len()), None);
                                        return;
                                    }
                        
                                    if let Some(path_value) = playlist_array.get(index) {
                                        if let Some(path) = path_value.as_str() {
                                            match run_yo_command(&["vlc", "--remove", "true", "--add", path]) {
                                                Ok(_) => send_response(&mut stream, "200 OK", 
                                                    &format!(r#"{{"status":"ok","action":"remove","index":{},"path":"{}"}}"#, index, path), None),
                                                Err(e) => send_response(&mut stream, "500 Internal Server Error", 
                                                    &format!(r#"{{"error":"Failed to remove item: {}"}}"#, e), None),
                                            }
                                        } else {
                                            send_response(&mut stream, "500 Internal Server Error", 
                                                r#"{"error":"Invalid path format in playlist"}"#, None);
                                        }
                                    } else {
                                        send_response(&mut stream, "400 Bad Request", 
                                            &format!(r#"{{"error":"Invalid index: {}"}}"#, index), None);
                                    }
                                } else {
                                    send_response(&mut stream, "500 Internal Server Error", 
                                        r#"{"error":"Invalid playlist format"}"#, None);
                                }
                            }
                            Err(e) => send_response(&mut stream, "500 Internal Server Error", 
                                &format!(r#"{{"error":"Failed to parse playlist: {}"}}"#, e), None),
                        }
                    }
                    Err(e) => send_response(&mut stream, "500 Internal Server Error", 
                        &format!(r#"{{"error":"Failed to fetch playlist: {}"}}"#, e), None),
                }
            }

            ("GET", "/playlist/clear") | ("GET", "/api/playlist/clear") => {
                match run_yo_command(&["vlc", "--clear", "true"]) {
                    Ok(_) => send_response(&mut stream, "200 OK", 
                        r#"{"status":"ok","action":"clear","message":"Playlist cleared"}"#, None),
                    Err(e) => send_response(&mut stream, "500 Internal Server Error", 
                        &format!(r#"{{"error":"Failed to clear playlist: {}"}}"#, e), None),
                }
            }

            ("GET", "/playlist/shuffle") | ("GET", "/api/playlist/shuffle") => {
                match run_yo_command(&["vlc", "--shuffle", "true"]) {
                    Ok(_) => send_response(&mut stream, "200 OK", 
                        r#"{"status":"ok","action":"shuffle","message":"Playlist shuffled"}"#, None),
                    Err(e) => send_response(&mut stream, "500 Internal Server Error", 
                        &format!(r#"{{"error":"Failed to shuffle playlist: {}"}}"#, e), None),
                }
            }
                     
            ("GET", "/health") | ("GET", "/api/health") => {
                let response = handle_health_check();
                send_response(&mut stream, "200 OK", &response, None);
            }            
            ("GET", "/health/all") | ("GET", "/api/health/all") => {
                let response = handle_health_all();
                send_response(&mut stream, "200 OK", &response, None);
            }
            
            ("GET", "/device/list") | ("GET", "/api/device/list") => {
                let response = handle_device_list();
                send_response(&mut stream, "200 OK", &response, None);
            }
            
            ("GET", "/device/control") | ("GET", "/api/device/control") => {
                let device_name = get_query_arg(query, "device");
                let action = get_query_arg(query, "action");
                let value = get_query_arg(query, "value");
    
                if device_name.is_empty() || action.is_empty() {
                    send_response(&mut stream, "400 Bad Request", r#"{"error":"Missing device or action parameters"}"#, None);
                    return;
                }
    
                let response = handle_device_control(&device_name, &action, &value);
                if response.contains("error") {
                    send_response(&mut stream, "400 Bad Request", &response, None);
                } else {
                    send_response(&mut stream, "200 OK", &response, None);
                }
            }
            
            ("GET", "/scene/activate") | ("GET", "/api/scene/activate") => {
                let scene_name = get_query_arg(query, "name");
                let response = handle_scene_activate(&scene_name);
                if response.contains("error") {
                    send_response(&mut stream, "404 Not Found", &response, None);
                } else {
                    send_response(&mut stream, "200 OK", &response, None);
                }
            }
            
            ("GET", "/device/rooms") | ("GET", "/api/device/rooms") => {
                let response = handle_rooms_list();
                send_response(&mut stream, "200 OK", &response, None);
            }
            
            ("GET", "/device/types") | ("GET", "/api/device/types") => {
                let response = handle_types_list();
                send_response(&mut stream, "200 OK", &response, None);
            }

            ("GET", "/tts") => {
                let text = get_query_arg(query, "text");
    
                if text.is_empty() {
                    send_response(&mut stream, "400 Bad Request", 
                        r#"{"error":"Missing text parameter"}"#, None);
                    return;
                }
    

                let output = std::process::Command::new("yo")
                    .args(&["say", "--text", &text, "--web"])
                    .output();
    
                match output {
                    Ok(output) if output.status.success() => {
                        let wav_path = String::from_utf8_lossy(&output.stdout).trim().to_string();
            
                        match std::fs::read(&wav_path) {
                            Ok(content) => {
                                let response = format!(
                                    "HTTP/1.1 200 OK\r\n\
                                     Content-Type: audio/wav\r\n\
                                     Content-Length: {}\r\n\
                                     Access-Control-Allow-Origin: *\r\n\
                                     Cache-Control: no-cache\r\n\r\n",
                                    content.len()
                                );
                    
                                if let Err(e) = stream.write_all(response.as_bytes()) {
                                    log(&format!("Failed to send headers: {}", e));
                                    return;
                                }
                    
                                if let Err(e) = stream.write_all(&content) {
                                    log(&format!("Failed to send audio: {}", e));
                                }
                    

                                let _ = std::fs::remove_file(&wav_path);
                            }
                            Err(e) => {
                                log(&format!("Failed to read WAV file: {}", e));
                                send_response(&mut stream, "500 Internal Server Error", 
                                    r#"{"error":"Failed to read audio"}"#, None);
                            }
                        }
                    }
                    Ok(output) => {
                        let stderr = String::from_utf8_lossy(&output.stderr);
                        log(&format!("TTS command failed: {}", stderr));
                        send_response(&mut stream, "500 Internal Server Error", 
                            &format!(r#"{{"error":"TTS failed: {}"}}"#, stderr), None);
                    }
                    Err(e) => {
                        log(&format!("Failed to run TTS command: {}", e));
                        send_response(&mut stream, "500 Internal Server Error", 
                            &format!(r#"{{"error":"TTS command failed: {}"}}"#, e), None);
                    }
                }
            }
            
            ("GET", "/do") | ("GET", "/api/do") => {
                let command = get_query_arg(query, "cmd");
                if command.is_empty() {
                    send_response(&mut stream, "400 Bad Request", r#"{"error":"Missing cmd parameter"}"#, None);
                    return;
                }
    
                log(&format!("Executing command: {}", command));
                let natural_language = if command.to_lowercase().starts_with("do ") {
                    command[3..].trim().to_string()
                } else {
                    command.trim().to_string()
                };
    
                if natural_language.is_empty() {
                    send_response(&mut stream, "400 Bad Request", r#"{"error":"Empty command after 'do'"}"#, None);
                    return;
                }
    
                match run_yo_command(&["do", "--input", &natural_language]) {
                    Ok(output) => {
                        // 🦆 says ⮞ filter out memory & duckTrace logs
                        let filtered_output: String = output
                            .lines()
                            .filter(|line| !line.contains("MEMORY ADJUSTMENT:"))
                            .filter(|line| !line.contains("[🦆📜]"))
                            .collect::<Vec<&str>>()
                            .join("\n");        
                        let cleaned_output = filtered_output.replace('"', "\\\"").replace('\n', "\\n");
                        let response = format!(r#"{{"status":"success","command":"{}","output":"{}"}}"#, 
                            natural_language, cleaned_output.trim());
                        send_response(&mut stream, "200 OK", &response, None);
                    }
                    Err(error) => {
                        let cleaned_error = error.replace('"', "\\\"").replace('\n', "\\n");
                        let response = format!(r#"{{"status":"error","command":"{}","error":"{}"}}"#, 
                            natural_language, cleaned_error.trim());
                        send_response(&mut stream, "500 Internal Server Error", &response, None);
                    }
                }
            }
            
            ("POST", "/upload") | ("POST", "/api/upload") => {
                let response = handle_file_upload(&headers, &body);
                send_response(&mut stream, "200 OK", &response, None);
            }
            
            _ => {
                send_response(&mut stream, "404 Not Found", &format!(r#"{{"error":"Endpoint not found","path":"{}"}}"#, raw_path), None);
            }
        }
    }
   
    fn main() {
        setup_ducktrace_logging(None, None);
        let log_file = std::env::var("DT_LOG_FILE")
            .unwrap_or_else(|_| "api.log".to_string());
        let log_path = std::env::var("DT_LOG_PATH")
            .unwrap_or_else(|_| "/home/${config.this.user.me.name}/.config/duckTrace/".to_string());
        let log_level = std::env::var("DT_LOG_LEVEL")
            .unwrap_or_else(|_| "INFO".to_string());
    
        dt_info(&format!("🚀 Starting yo API server"));
        dt_info(&format!("Log file: {}{}", log_path, log_file));
        dt_info(&format!("Log Level: {}", log_level));
            
        let args: Vec<String> = env::args().collect();
        if args.len() != 3 {
            dt_error("Usage: yo api");
            std::process::exit(1);
        }
    
        let host = &args[1];
        let port = &args[2];
        let address = format!("{}:{}", host, port);
    
        // 🦆 says ⮞ port in use?
        if TcpListener::bind(&address).is_err() {
            dt_error(&format!("❌ Port {} is already in use", port));
            std::process::exit(1);
        }
    
        let listener = TcpListener::bind(&address).expect("Failed to bind to address");
        log(&format!("Starting yo API server on {}:{}", host, port));
        log("Endpoints:");
        log("  GET /timers     - List timers");
        log("  GET /alarms     - List alarms");
        log("  GET /shopping   - List shopping items");
        log("  GET /health     - Health check (no auth required)");
        log("  GET /do?cmd=... - Execute natural language commands");
        log("  GET /device/list - List all devices");
        log("  GET /device/control - Control devices");
        log("  GET /scene/activate - Activate scenes");
        log("  GET /device/rooms - List devices by room");
        log("  GET /device/types - List devices by type");
        log("  POST /upload     - Upload files");
        log("Authentication:");
        log("  All endpoints except /health require password authentication");
        log("  Use: Authorization: Bearer <password> header");
        log("  Or:  X-API-Key: <password> header");
        log("  Or:  ?password=<password> query parameter");
        log("  Password is read from YO_API_PASSWORD_FILE environment variable");
        log("Press Ctrl+C to stop");
    
        for stream in listener.incoming() {
            match stream {
                Ok(stream) => {
                    std::thread::spawn(move || {
                        handle_request(stream);
                    });
                }
                Err(e) => {
                    dt_warning(&format!("🔌 Connection failed: {}", e));
                }
            }
        }
    }
  '';
  
in { 
  networking.firewall.allowedTCPPorts = [9815];
  # 🦆 says ⮞  da script yo
  yo.scripts.api = {
    description = "API endpoints for smart home control, virtual media playlist management, system wide health checks and more.";
    category = "🌐 Networking";
    autoStart = builtins.elem config.this.host.hostname [ "homie" ];
    logLevel = "DEBUG";
    parameters = [
      { name = "host"; description = "IP to run server on"; default = "0.0.0.0"; }
      { name = "port"; description = "Port for the service"; default = 9815;  } 
      { name = "dir"; description = "Directory path to build inside"; default = "/home/" + config.this.user.me.name + "/api-rs";  }       
    ];
    helpFooter = '' 
      echo "# 🔐 Authentication:"
      echo "PASS=\$(cat ${config.house.dashboard.passwordFile} | tr -d '[:space:]')"
      
      echo "# Using Authorization header:"
      echo "curl -H 'Authorization: Bearer \$PASS' http://${mqttHostip}:9815/device/list"
      
      echo "# Using X-API-Key header:"
      echo "curl -H 'X-API-Key: PASS' http://${mqttHostip}:9815/device/list"
      
      echo "# Using query parameter:"
      echo "curl 'http://${mqttHostip}:9815/device/list?password=\$PASS'"
      
      echo "# Media Handling"
      echo "Browse"
      echo "curl -H 'Authorization: Bearer \$PASS' 'http://${mqttHostip}:9815/browsev2?path=Movies'"      
      echo "Add file to playlist"
      echo "curl -H 'Authorization: Bearer \$PASS' 'http://${mqttHostip}:9815/add?path=/Pool/Movies/movie.mp4'"
      echo "Add entire folder to playlist"
      echo "curl -H 'Authorization: Bearer \$PASS' 'http://${mqttHostip}:9815/add_folder?path=/Pool/Movies/Godzilla%20(1998)'"
      echo "Check playlist"
      echo "curl -H 'Authorization: Bearer \$PASS' 'http://${mqttHostip}:9815/playlist'"
      echo "Remove item from playlist (0-based index):"
      echo "curl -H 'Authorization: Bearer \$PASS' 'http://${mqttHostip}:9815/playlist/remove?index=0'"
      echo "Clear entire playlist:"
      echo "curl -H 'Authorization: Bearer \$PASS' 'http://${mqttHostip}:9815/playlist/clear'"
      echo "Shuffle playlist:"
      echo "curl -H 'Authorization: Bearer \$PASS' 'http://${mqttHostip}:9815/playlist/shuffle'"
     
      echo "# Health check (no auth required):"
      echo "curl http://${mqttHostip}:9815/health"
      
      echo "# Text-To-Speech"
      echo "curl -H 'Authorization: Bearer \$PASS' 'http://${mqttHostip}:9815/tts?text=Hello%20world"
      
      echo "# Yo Do commands:"
      echo "curl 'http://${mqttHostip}:9815/do?cmd=your%20cmmand%20here&password=\$PASS'"
      
      echo "# Control devices:"
      echo "curl -H 'Authorization: Bearer \$PASS' 'http://${mqttHostip}:9815/device/control?device=living_room_lamp&action=on'"
      
      echo "# Turn on a light"
      echo "curl -H 'Authorization: Bearer \$PASS' 'http://${mqttHostip}:9815/device/control?device=PC&action=on'"
      
      echo "# Set brightness:"
      echo "curl -H 'Authorization: Bearer \$PASS' 'http://${mqttHostip}:9815/device/control?device=bedroom_light&action=brightness&value=150'"
      
      echo "# Set color:"
      echo "curl -H 'Authorization: Bearer \$PASS' 'http://${mqttHostip}:9815/device/control?device=kitchen_light&action=color&value=%23FF5733'"
      
      echo "# Set color temperature:"
      echo "curl -H 'Authorization: Bearer \$PASS' 'http://${mqttHostip}:9815/device/control?device=office_light&action=temp&value=300'"
      
      echo "# Activate a scene:"
      echo "curl -H 'Authorization: Bearer \$PASS' 'http://${mqttHostip}:9815/scene/activate?name=evening_relax'"

      echo "# List devices:"
      echo "curl -H 'Authorization: Bearer \$PASS' 'http://${mqttHostip}:9815/device/list'"
      echo "# List devices by room:"
      echo "curl -H 'Authorization: Bearer \$PASS' 'http://${mqttHostip}:9815/device/rooms'"
      echo "# List devices by type:"
      echo "curl -H 'Authorization: Bearer \$PASS' 'http://${mqttHostip}:9815/device/types'"
      
      echo "# File upload:"
      echo "curl -X POST -H 'X-API-Key: \$PASS' -F 'file=@/path/to/file' 'http://${mqttHostip}:9815/upload'"
    '';
    code = ''
      ${cmdHelpers} 
      HOST="$host"
      PORT="$port"
      tmp=$(mktemp -d)
      trap "rm -rf '$tmp'" EXIT
      mkdir -p "$tmp/src"

      cp ${api-rs} "$tmp/src/main.rs"
      cp ${cargo-toml} "$tmp/Cargo.toml"
      cp ${devices-json} "$tmp/devices.json"
      cp ${scenes-json} "$tmp/scenes.json" 
      cp ${rooms-json} "$tmp/rooms.json"
      cp ${types-json} "$tmp/types.json"
        
      cd "$tmp"

      dt_info "Build complete!"
      
      ${pkgs.cargo}/bin/cargo generate-lockfile
      ${pkgs.cargo}/bin/cargo build --release    
      dt_info "Build complete!"

      dt_info "Starting yo API server (Rust) on $HOST:$PORT" >&2
      echo "Endpoints:" >&2
      echo "  GET /timers     - List timers" >&2
      echo "  GET /alarms     - List alarms" >&2
      echo "  GET /shopping   - List shopping items" >&2
      echo "  GET /health     - Health check" >&2
      echo "  GET /do?cmd=... - Execute natural language commands" >&2
      echo "Press Ctrl+C to stop" >&2

      # 🦆 says ⮞ check yo.scripts.do if DEBUG mode yo
      if [ "$VERBOSE" -ge 1 ]; then
        while true; do
          # 🦆 says ⮞ keep me alive plx
          DEBUG=1 DT_LOG_FILE_PATH="$DT_LOG_PATH$DT_LOG_FILE" YO_API_PASSWORD_FILE="${config.house.dashboard.passwordFile}" ./target/release/api-rs "$HOST" "$PORT"
          EXIT_CODE=$?
          dt_error "api-rs exited with code $EXIT_CODE, restarting in 3 seconds..."
          sleep 3
       done
      fi  
      # 🦆 says ⮞ keep me alive plx
      while true; do
        # 🦆 says ⮞ else run debugless yo
        DT_LOG_FILE_PATH="$DT_LOG_PATH$DT_LOG_FILE" YO_API_PASSWORD_FILE="${config.house.dashboard.passwordFile}" ./target/release/api-rs "$HOST" "$PORT"
        EXIT_CODE=$?
        dt_error "api-rs exited with code $EXIT_CODE, restarting in 3 seconds..."
        sleep 3
      done         
    '';      
    
  };

  # 🦆 says ⮞ fancy cat'z...
  environment.systemPackages = [ pkgs.socat pkgs.netcat ];
     
  # 🦆 says ⮞ Simple authentication using environment variables
  environment.sessionVariables = {
    YO_API_USER = config.this.user.me.name;
    YO_API_PASSWORD_FILE = config.house.dashboard.passwordFile;

  };}
