# dotfiles/bin/home/zigduck.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # From Quack to Stack: A Declarative Zigbee and home automation system
  self, # 🦆 says ⮞ Welcome to QuackHack-McBLindy'z Quacky Hacky Home of Fun! 
  lib, 
  config, # 🦆 says ⮞ duck don't write automations - duck write infra with junkie comments on each line.... quack
  pkgs,
  cmdHelpers, # 🦆 with MQTT dreams and zigbee schemes.
  ... 
} : let # yo follow 🦆 home ⬇⬇ 🦆 says diz way plz? quack quackz
  # 🦆 says ⮞ Directpry  for this configuration 
  zigduckDir = "/var/lib/zigduck";
  # 🦆 says ⮞ don't stick it to the duck - encrypted Zigbee USB coordinator backup filepath
  backupEncryptedFile = "${config.this.user.me.dotfilesDir}/secrets/zigbee_coordinator_backup.json";
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
      mqtt_pub -t "zigbee2mqtt/${device}/set" -m '${json}'
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
  # 🦆 says ⮞ RUSTY SMART HOME qwack qwack     
  zigduck-rs = pkgs.writeText "zigduck-rs" ''    
    
    use rumqttc::{MqttOptions, Client, QoS, Event, Incoming};
    use serde_json::{Value, json};
    use std::collections::HashMap;
    use std::fs;
    use std::path::Path;
    use std::time::{Duration, SystemTime, UNIX_EPOCH};
    use std::process::Command;
    use serde::{Deserialize, Serialize};
    use chrono::{Local, Timelike};
    
    #[derive(Debug, Clone, Serialize, Deserialize)]
    struct Device {
        room: String,
        #[serde(rename = "type")]
        device_type: String,
        id: String,
        endpoint: u32,
    }
    
    #[derive(Debug, Clone)]
    struct ZigduckState {
        mqtt_broker: String,
        mqtt_user: String,
        mqtt_password: String,
        state_dir: String,
        state_file: String,
        larmed_file: String,
        devices: HashMap<String, Device>,
        automations: AutomationConfig,  // 🦆 NEW!
        dark_time_enabled: bool,        // 🦆 NEW!
        processing_times: HashMap<String, u128>,
        message_counts: HashMap<String, u64>,
        total_messages: u64,
        debug: bool,
        
    }

    // 🦆 says ⮞ automation types
    #[derive(Debug, Clone, Serialize, Deserialize)]
    struct AutomationConfig {
        dimmer_actions: HashMap<String, DimmerAction>,
        room_actions: HashMap<String, HashMap<String, Vec<AutomationAction>>>,
        global_actions: HashMap<String, Vec<AutomationAction>>,
    }

    #[derive(Debug, Clone, Serialize, Deserialize)]
    struct DimmerAction {
        enable: bool,
        description: String,
        extra_actions: Vec<AutomationAction>,
    }

    #[derive(Debug, Clone, Serialize, Deserialize)]
    #[serde(untagged)]
    enum AutomationAction {
        Simple(String),
        Structured(StructuredAction),
    }

    #[derive(Debug, Clone, Serialize, Deserialize)]
    struct StructuredAction {
        #[serde(rename = "type")]
        action_type: String,
        command: Option<String>,
        topic: Option<String>,
        message: Option<String>,
        scene: Option<String>,
    }
    
    impl ZigduckState {
        fn new(mqtt_broker: String, mqtt_user: String, mqtt_password: String, state_dir: String, devices_file: String, automations_file: String, dark_time_enabled: bool, debug: bool) -> Self {
            let state_file = format!("{}/state.json", state_dir);
            let larmed_file = format!("{}/security_state.json", state_dir);      
            // 🦆 says ⮞ duck needz dirz create dirz thnx
            std::fs::create_dir_all(&state_dir).unwrap_or_else(|e| {
                eprintln!("[🦆📜] ❌ERROR❌ ⮞ Failed to create state directory {}: {}", state_dir, e);
                std::process::exit(1);
            });   
        
            // 🦆 says ⮞ init state file yes
            if !std::path::Path::new(&state_file).exists() {
                std::fs::write(&state_file, "{}").unwrap_or_else(|e| {
                    eprintln!("[🦆📜] ❌ERROR❌ ⮞ Failed to create state file {}: {}", state_file, e);
                    std::process::exit(1);
                });
            }
        
            // 🦆 says ⮞ init sec state
            if !std::path::Path::new(&larmed_file).exists() {
                std::fs::write(&larmed_file, r#"{"larmed":false}"#).unwrap_or_else(|e| {
                    eprintln!("[🦆📜] ❌ERROR❌ ⮞ Failed to create security state file {}: {}", larmed_file, e);
                    std::process::exit(1);
                });
            }  
        
            // 🦆 says ⮞ read devices file
            let devices_json = std::fs::read_to_string(&devices_file)
                .unwrap_or_else(|e| {
                    eprintln!("[🦆📜] ❌ERROR❌ ⮞ Failed to read devices file {}: {}", devices_file, e);
                    "{}".to_string()
                });  
        
            // 🦆 says ⮞ parse da json map of devicez yo
            let raw_devices: std::collections::HashMap<String, serde_json::Value> = serde_json::from_str(&devices_json)
                .unwrap_or_else(|e| {
                    eprintln!("[🦆📜] ❌ERROR❌ ⮞ Failed to parse devices JSON from {}: {}", devices_file, e);
                    std::collections::HashMap::new()
                });
        
                // 🦆 says ⮞ convert 2 device struct
                let mut devices = std::collections::HashMap::new();
                for (friendly_name, device_value) in raw_devices {
                    match serde_json::from_value::<Device>(device_value.clone()) {
                    Ok(device) => {
                        devices.insert(friendly_name, device);
                    }
                    Err(e) => {
                        eprintln!("[🦆📜] ⁉️DEBUG⁉️ ⮞ Failed to parse device {}: {}", friendly_name, e);
                    }
                }
            }
        
            eprintln!("[🦆📜] ✅INFO✅ ⮞ Loaded {} devices from {}", devices.len(), devices_file);
            eprintln!("[🦆📜] ✅INFO✅ ⮞ State directory: {}", state_dir);
            eprintln!("[🦆📜] ✅INFO✅ ⮞ State file: {}", state_file);
            eprintln!("[🦆📜] ✅INFO✅ ⮞ Security file: {}", larmed_file);
        
            // 🦆 says ⮞ Load automations configuration
            let automations_json = std::fs::read_to_string(&automations_file)
                .unwrap_or_else(|e| {
                    eprintln!("[🦆📜] ❌ERROR❌ ⮞ Failed to read automations file {}: {}", automations_file, e);
                    "{\"dimmer_actions\":{},\"room_actions\":{},\"global_actions\":{}}".to_string()
                });
        
            let automations: AutomationConfig = serde_json::from_str(&automations_json)
                .unwrap_or_else(|e| {
                    eprintln!("[🦆📜] ❌ERROR❌ ⮞ Failed to parse automations JSON: {}", e);
                    AutomationConfig {
                        dimmer_actions: HashMap::new(),
                        room_actions: HashMap::new(),
                        global_actions: HashMap::new(),
                    }
                });
        
                Self {
                    mqtt_broker,
                    mqtt_user,
                    mqtt_password,
                    state_dir,
                    state_file,
                    larmed_file,
                    devices,
                    automations,
                    dark_time_enabled,
                    processing_times: HashMap::new(),
                    message_counts: HashMap::new(),
                    total_messages: 0,
                    debug,
                }
            }
         

        fn activate_scene(&self, scene_name: &str) -> Result<(), Box<dyn std::error::Error>> {
            self.quack_info(&format!("🎭 Activating scene: {}", scene_name));
            // 🦆 says ⮞ This would send MQTT commands to set the scene
            // For now, we'll just log it
            self.quack_debug(&format!("Scene '{}' would be activated here", scene_name));
            Ok(())
        }
    
        // 🦆 says ⮞ duckTrace - quack loggin' be bitchin' (yu log)
        fn quack_debug(&self, msg: &str) {
            if self.debug {
                let log_msg = format!("[🦆📜] ⁉️DEBUG⁉️ ⮞ {}", msg);
                eprintln!("{}", log_msg);
                // 🦆 says ⮞ debug mode? write 2 duckTrace (yo log)      
                if let Ok(log_path) = std::env::var("DT_LOG_FILE_PATH") {
                    let _ = std::fs::OpenOptions::new()
                        .create(true)
                        .append(true)
                        .open(&log_path)
                        .and_then(|mut file| {
                            use std::io::Write;
                            writeln!(file, "{}", log_msg)
                        });
                }
            }
        }
    
        fn quack_info(&self, msg: &str) {
            let log_msg = format!("[🦆📜] ✅INFO✅ ⮞ {}", msg);
            eprintln!("{}", log_msg);
            // 🦆 says ⮞ always write info 2 duckTrace (yo log)
            if let Ok(log_path) = std::env::var("DT_LOG_FILE_PATH") {
                let _ = std::fs::OpenOptions::new()
                    .create(true)
                    .append(true)
                    .open(&log_path)
                    .and_then(|mut file| {
                        use std::io::Write;
                        writeln!(file, "{}", log_msg)
                    });
            }
        }

        
        fn execute_automations(&self, automation_type: &str, trigger: &str, device_name: &str, room: &str) -> Result<(), Box<dyn std::error::Error>> {
            // 🦆 says ⮞ Load automations from config (you'll need to pass this to Rust)
            // This would come from your Nix configuration as JSON
            
            match automation_type {
                "dimmer" => {
                    if let Some(actions) = self.automations.dimmer_actions.get(trigger) {
                        if actions.enable {
                            // Execute extra actions
                            for action in &actions.extra_actions {
                                self.execute_automation_action(action, device_name, room)?;
                            }
                        }
                    }
                }
                "motion" => {
                    if let Some(actions) = self.automations.room_actions.get(room) {
                        if let Some(motion_actions) = actions.get("motion_detected") {
                            for action in motion_actions {
                                self.execute_automation_action(action, device_name, room)?;
                            }
                        }
                    }
                }
                _ => {}
            }
            Ok(())
        }
        
        fn execute_automation_action(&self, action: &AutomationAction, device_name: &str, room: &str) -> Result<(), Box<dyn std::error::Error>> {
            match action {
                AutomationAction::Simple(cmd) => {
                    // Execute shell command
                    let _ = std::process::Command::new("sh")
                        .arg("-c")
                        .arg(cmd)
                        .output();
                }
                AutomationAction::Structured(action_config) => {
                    match action_config.action_type.as_str() {
                        "mqtt" => {
                            if let (Some(topic), Some(message)) = (&action_config.topic, &action_config.message) {
                                self.mqtt_publish(topic, message)?;
                            }
                        }
                        "shell" => {
                            if let Some(cmd) = &action_config.command {
                                let _ = std::process::Command::new("sh")
                                    .arg("-c")
                                    .arg(cmd)
                                    .output();
                            }
                        }
                        "scene" => {
                            if let Some(scene_name) = &action_config.scene {
                                // Activate scene
                                self.activate_scene(scene_name)?;
                            }
                        }
                        _ => {}
                    }
                }
            }
            Ok(())
        }
            
        // 🦆 says ⮞ updatez da state json file yo    
        fn update_device_state(&self, device: &str, key: &str, value: &str) -> Result<(), Box<dyn std::error::Error>> {
            let state_content = fs::read_to_string(&self.state_file)?;
            let mut state: Value = serde_json::from_str(&state_content).unwrap_or_else(|_| json!({}));    
            if !state[device].is_object() {
                state[device] = json!({});
            }
            state[device][key] = Value::String(value.to_string());
            let tmp_file = format!("{}/tmp_state.json", self.state_dir);
            fs::write(&tmp_file, state.to_string())?;
            fs::rename(&tmp_file, &self.state_file)?; 
            self.quack_debug(&format!("Updated state: {}.{} = {}", device, key, value));
            Ok(())
        }
    
        // 🦆 says ⮞ GET DEVICE STATE     
        fn get_state(&self, device: &str, key: &str) -> Option<String> {
            let state_content = fs::read_to_string(&self.state_file).ok()?;
            let state: Value = serde_json::from_str(&state_content).ok()?;
            state[device][key].as_str().map(|s| s.to_string())
        }
    
        // 🦆 says ⮞ CENTRALIZED STATE UPDATES - like Bash version
        fn update_device_state_from_data(&self, device_name: &str, data: &Value) -> Result<(), Box<dyn std::error::Error>> {
            // 🦆 says ⮞ Skip set/availability topics like Bash version
            if device_name.ends_with("/set") || device_name.ends_with("/availability") {
                self.quack_debug(&format!("Skipping state update for {} (set/availability topic)", device_name));
                return Ok(());
            }
    
            self.quack_debug(&format!("Updating ALL state fields for: {}", device_name));
    
            // 🦆 says ⮞ Extract ALL fields like the Bash version
            if let Some(linkquality) = data["linkquality"].as_u64() {
                self.update_device_state(device_name, "linkquality", &linkquality.to_string())?;
            }
            
            if let Some(last_seen) = data["last_seen"].as_str() {
                self.update_device_state(device_name, "last_seen", last_seen)?;
            }
            
            if let Some(occupancy) = data["occupancy"].as_bool() {
                self.update_device_state(device_name, "occupancy", &occupancy.to_string())?;
            }
            
            if let Some(action) = data["action"].as_str() {
                self.update_device_state(device_name, "action", action)?;
            }
            
            if let Some(contact) = data["contact"].as_bool() {
                self.update_device_state(device_name, "contact", &contact.to_string())?;
            }
            
            if let Some(position) = data["position"].as_u64() {
                self.update_device_state(device_name, "position", &position.to_string())?;
            }
            
            if let Some(state) = data["state"].as_str() {
                self.update_device_state(device_name, "state", state)?;
            }
            
            if let Some(brightness) = data["brightness"].as_u64() {
                self.update_device_state(device_name, "brightness", &brightness.to_string())?;
            }
            
            if let Some(color) = data["color"].as_object() {
                if let Ok(color_json) = serde_json::to_string(color) {
                    self.update_device_state(device_name, "color", &color_json)?;
                }
            }
            
            if let Some(water_leak) = data["water_leak"].as_bool() {
                self.update_device_state(device_name, "water_leak", &water_leak.to_string())?;
            }
            
            if let Some(waterleak) = data["waterleak"].as_bool() {
                self.update_device_state(device_name, "waterleak", &waterleak.to_string())?;
            }
            
            if let Some(temperature) = data["temperature"].as_f64() {
                self.update_device_state(device_name, "temperature", &temperature.to_string())?;
            }
            
            if let Some(battery) = data["battery"].as_u64() {
                self.update_device_state(device_name, "battery", &battery.to_string())?;
            }
            
            if let Some(battery_state) = data["battery_state"].as_str() {
                self.update_device_state(device_name, "battery_state", battery_state)?;
            }
            
            if let Some(tamper) = data["tamper"].as_bool() {
                self.update_device_state(device_name, "tamper", &tamper.to_string())?;
            }
            
            if let Some(smoke) = data["smoke"].as_bool() {
                self.update_device_state(device_name, "smoke", &smoke.to_string())?;
            }
            
            // 🦆 says ⮞ Update last_seen timestamp for every message
            let timestamp = SystemTime::now().duration_since(UNIX_EPOCH).unwrap().as_secs();
            self.update_device_state(device_name, "last_updated", &timestamp.to_string())?;
            
            Ok(())
        }
                
        // 🦆 says ⮞ room timer - turns off lights after nix configured seconds of no motion
        fn reset_room_timer(&self, room: &str) -> Result<(), Box<dyn std::error::Error>> {
            let timer_dir = format!("{}/timers", self.state_dir);
            let sanitized_room = room.replace(" ", "_");
            let timer_file = format!("{}/{}", timer_dir, sanitized_room);    
            // 🦆 says ⮞ just2make sure yo
            std::fs::create_dir_all(&timer_dir)?;
            
            self.quack_info(&format!("⏰ Starting room timer for {} ({} seconds)", 
                room, ${config.house.zigbee.darkTime.duration}));
        
            // 🦆 says ⮞ kill timer if there is any
            if let Ok(content) = std::fs::read_to_string(&timer_file) {
                if let Ok(pid) = content.trim().parse::<i32>() {
                    self.quack_info(&format!("⏰ Resetting existing timer for {}", room));
                    let _ = std::process::Command::new("kill")
                        .arg(pid.to_string())
                        .output();
                }
                let _ = std::fs::remove_file(&timer_file);
            }
        
            // 🦆 says ⮞ spawn timer
            let room_clone = room.to_string();
            let timer_file_clone = timer_file.clone();
            let state_clone = std::sync::Arc::new(self.clone());
            
            self.quack_info(&format!("⏰ Room timer initiated for {} - lights will turn off in {} seconds", 
                room, ${config.house.zigbee.darkTime.duration}));
        
            tokio::spawn(async move {
                // 🦆 says ⮞ Sleep for X sec (nix config.house.zigbee.darkTime.duration)
                state_clone.quack_debug(&format!("⏰ Room timer sleeping for {} seconds for {}", 
                    ${config.house.zigbee.darkTime.duration}, room_clone));
                
                tokio::time::sleep(Duration::from_secs(${config.house.zigbee.darkTime.duration})).await;
                
                state_clone.quack_debug(&format!("⏰ Room timer expired for {}, turning off lights", room_clone));
                
                // 🦆 says ⮞ room lights off
                if let Err(e) = state_clone.room_lights_off(&room_clone) {
                    state_clone.quack_info(&format!("❌ERROR❌ ⮞ Failed to turn off lights for {}: {}", room_clone, e));
                } else {
                    state_clone.quack_info(&format!("💡 Successfully turned off lights in {}", room_clone));
                }
                
                // 🦆 says ⮞ clean up
                let _ = std::fs::remove_file(&timer_file_clone);
                state_clone.quack_debug(&format!("⏰ Room timer completed and cleaned up for {}", room_clone));
            });
            
            // 🦆 says ⮞ write thread id 4 trackin' 
            let pseudo_pid = std::process::id();
            std::fs::write(&timer_file, pseudo_pid.to_string())?;
            
            self.quack_debug(&format!("Reset {} second timer for {} (File: {})", 
                ${config.house.zigbee.darkTime.duration}, room, timer_file));
            
            self.quack_debug(&format!("⏰ Room timer successfully set for {}", room));
            Ok(())
        }
      
      
        // 🦆 says ⮞ SET SECURITY STATE    
        fn set_larmed(&self, armed: bool) -> Result<(), Box<dyn std::error::Error>> {
            let state = json!({ "larmed": armed });
            fs::write(&self.larmed_file, state.to_string())?; 
            self.mqtt_publish("zigbee2mqtt/security/state", &state.to_string())?;
            if armed {
                self.quack_info("🛡️ Security system ARMED");
                self.run_yo_command(&["notify", "🛡️ Security armed"])?;
            } else {
                self.quack_info("🛡️ Security system DISARMED");
                self.run_yo_command(&["notify", "🛡️ Security disarmed"])?;
            }       
            Ok(())
        }
    
        // 🦆 says ⮞ GET SECURITY STATE    
        fn get_larmed(&self) -> bool {
            let content = fs::read_to_string(&self.larmed_file).unwrap_or_else(|_| r#"{"larmed":false}"#.to_string());
            let state: Value = serde_json::from_str(&content).unwrap_or_else(|_| json!({"larmed": false}));
            state["larmed"].as_bool().unwrap_or(false)
        }
    
        // 🦆 says ⮞ MQTT PUBLISH    
        fn mqtt_publish(&self, topic: &str, message: &str) -> Result<(), Box<dyn std::error::Error>> {
            let output = Command::new("mosquitto_pub")
                .arg("-h")
                .arg(&self.mqtt_broker)
                .arg("-u")
                .arg(&self.mqtt_user)
                .arg("-P")
                .arg(&self.mqtt_password)
                .arg("-t")
                .arg(topic)
                .arg("-m")
                .arg(message)
                .output()?;
            if !output.status.success() {
                return Err(format!("MQTT publish failed: {}", String::from_utf8_lossy(&output.stderr)).into());
            }   
            Ok(())
        }
    
        // 🦆 says ⮞ EXECUTE yo COMMANDS yo!    
        fn run_yo_command(&self, args: &[&str]) -> Result<(), Box<dyn std::error::Error>> {
            let output = Command::new("yo")
                .args(args)
                .output()?;    
            if !output.status.success() {
                self.quack_debug(&format!("yo command failed: {}", String::from_utf8_lossy(&output.stderr)));
            }      
            Ok(())
        }
    
        // 🦆 says ⮞ TURN ON ROOM LIGHTS qwack    
        fn room_lights_on(&self, room: &str) -> Result<(), Box<dyn std::error::Error>> {
            for (device_id, device) in &self.devices {
                if device.room == room && device.device_type == "light" {
                    let message = json!({ "state": "ON" });
                    let topic = format!("zigbee2mqtt/{}/set", device_id);
                    self.mqtt_publish(&topic, &message.to_string())?;
                }
            }
            Ok(())
        }
    
        // 🦆 says ⮞ TURN OFF ROOM LIGHTS    
        fn room_lights_off(&self, room: &str) -> Result<(), Box<dyn std::error::Error>> {
            for (device_id, device) in &self.devices {
                if device.room == room && device.device_type == "light" {
                    let message = json!({ "state": "OFF" });
                    let topic = format!("zigbee2mqtt/{}/set", device_id);
                    self.mqtt_publish(&topic, &message.to_string())?;
                }
            }
            Ok(())
        }
        
        // 🦆 says ⮞ check if dark (static time configured)    
        fn is_dark_time(&self) -> bool {
            if !self.dark_time_enabled {
                return true; // 🦆 says ⮞If dark time disabled, always consider it "dark" for automations
            }
            let now = Local::now();
            let hour = now.hour();
            // after🦆18:00⮞before⮜06:00🦆 
            hour >= ${config.house.zigbee.darkTime.after} || hour <= ${config.house.zigbee.darkTime.before}   
        }
    
        fn update_performance_stats(&mut self, topic: &str, duration: u128) {
            let current_avg = self.processing_times.get(topic).copied().unwrap_or(0);
            self.processing_times.insert(topic.to_string(), (current_avg + duration) / 2);
            *self.message_counts.entry(topic.to_string()).or_insert(0) += 1;
            self.total_messages += 1;
            if duration > 100 {
                self.quack_info(&format!("[🦆📶] - Slow processing: {} took {}ms", topic, duration));
            }
    
            if self.total_messages % 100 == 0 {
                self.quack_debug(&format!("[🦆📶] - Total messages: {}", self.total_messages));
                for (topic_type, avg_time) in &self.processing_times {
                    let count = self.message_counts.get(topic_type).unwrap_or(&0);
                    self.quack_debug(&format!("{}: avg {}ms, count {}", topic_type, avg_time, count));
                }
            }
        }
    
        // 🦆 says ⮞
        fn control_all_lights(&self, state: &str, brightness: Option<u8>) -> Result<(), Box<dyn std::error::Error>> {
            for (device_id, device) in &self.devices {
                if device.device_type == "light" {
                    let mut message = serde_json::Map::new();
                    message.insert("state".to_string(), Value::String(state.to_string())); 
                    if let Some(brightness) = brightness {
                        message.insert("brightness".to_string(), Value::Number(brightness.into()));
                    }       
                    let topic = format!("zigbee2mqtt/{}/set", device_id);
                    self.mqtt_publish(&topic, &Value::Object(message).to_string())?;
                }
            }
            let action = if state == "ON" { "ON" } else { "OFF" };
            self.quack_info(&format!("💡 All lights turned {}", action));
            Ok(())
        }    
    
        // 🦆 says ⮞ PROCESS MQTT MESSAGES    
        async fn process_message(&mut self, topic: &str, payload: &str) -> Result<(), Box<dyn std::error::Error>> {
            // 🦆 says ⮞ start timer 4 exec time messurementz    
            let start_time = std::time::Instant::now();
            // 🦆 says ⮞ skip large payloads
            if payload.len() > 10000 {
                self.quack_debug(&format!("Skipping large payload on topic: {} (size: {})", topic, payload.len()));
                return Ok(());
            }
            // 🦆 says ⮞ debug log raw payloadz yo    
            self.quack_debug(&format!("TOPIC: {}", topic));
            self.quack_debug(&format!("PAYLOAD: {}", payload));
            let data: Value = match serde_json::from_str(payload) {
                Ok(parsed) => parsed,
                Err(_) => {
                    self.quack_debug(&format!("Invalid JSON payload: {}", payload));
                    return Ok(());
                }
            };
    
            // 🦆 says ⮞ TV CHANNEL    
            if data.get("tvChannel").is_some() {
                if let Some(channel) = data["tvChannel"].as_str() {
                    let ip = data["ip"].as_str().unwrap_or("192.168.1.223");
                    self.quack_info(&format!("TV channel change requested! Channel: {}. IP: {}", channel, ip));
                    self.run_yo_command(&["tv", "--typ", "livetv", "--device", ip, "--search", channel])?;
                }
                return Ok(());
            }
    
            if topic.starts_with("zigbee2mqtt/tv/") && topic.ends_with("/channel") {
                if let Some(device_ip) = topic.split('/').nth(2) {
                    if let (Some(channel_id), Some(channel_name)) = (
                        data["channel_id"].as_str(),
                        data["channel_name"].as_str()
                    ) {
                        let device_key = format!("tv_{}", device_ip);
                        self.update_device_state(&device_key, "current_channel", channel_id)?;
                        self.update_device_state(&device_key, "current_channel_name", channel_name)?; 
                        let timestamp = Local::now().to_rfc3339();
                        self.update_device_state(&device_key, "last_update", &timestamp)?;
                        self.quack_info(&format!("📺 {} live tv channel: {}", device_ip, channel_name));
                    }
                }
                return Ok(());
            }
    
            // 🦆 says ⮞ ENERGY USAGE    
            if topic == "zigbee2mqtt/tibber/price" {
                if let Some(price) = data["current_price"].as_str() {
                    self.update_device_state("tibber", "current_price", price)?;
                    self.quack_info(&format!("Energy price updated: {} SEK/kWh", price));
                }
                return Ok(());
            }
    
            if topic == "zigbee2mqtt/tibber/usage" {
                if let Some(usage) = data["monthly_usage"].as_str() {
                    self.update_device_state("tibber", "monthly_usage", usage)?;
                    self.quack_info(&format!("Energy usage updated: {} kWh", usage));
                }
                return Ok(());
            }

            // 🦆 says ⮞ 🧠 NLP COMMAND - handle commands from dashboard
            if topic == "zigbee2mqtt/command" {
                if let Some(command) = data["command"].as_str() {
                    self.quack_info(&format!("🧠 NLP Command received from dashboard: {}", command));
                    let _ = Command::new("yo")
                        .arg("do")
                        .arg(command)
                        .spawn();
                }
                return Ok(());
            }
    
            // 🦆 says ⮞ SECURITY
            if data.get("security").is_some() && self.get_larmed() {
                self.quack_info("Larmed apartment");
                self.run_yo_command(&["notify", "Larm på"])?;
            }
    
            let device_name = topic.strip_prefix("zigbee2mqtt/").unwrap_or(topic);
    
            // 🦆 says ⮞ CENTRALIZED STATE UPDATES - like Bash version
            if let Err(e) = self.update_device_state_from_data(device_name, &data) {
                self.quack_debug(&format!("Failed to update device state: {}", e));
            }
    
            // 🦆 says ⮞ Now do the specific logic with logging
            if let Some(device) = self.devices.get(device_name) {
                let room = &device.room;
                // 🦆 says ⮞ 🔋 BATTERY
                if let Some(battery) = data["battery"].as_u64() {
                    let prev_battery = self.get_state(device_name, "battery");
                    if prev_battery.as_deref() != Some(&battery.to_string()) && prev_battery.is_some() {
                        self.quack_info(&format!("🔋 Battery update for {}: {}% > {}%", device_name, prev_battery.unwrap(), battery));
                    }
                }
    
                // 🦆 says ⮞ 🌡️ TEMPERATURE SENSORS
                if let Some(temperature) = data["temperature"].as_f64() {
                    let prev_temp = self.get_state(device_name, "temperature");
                    if prev_temp.as_deref() != Some(&temperature.to_string()) && prev_temp.is_some() {
                        self.quack_info(&format!("🌡️ Temperature update for {}: {}°C > {}°C", device_name, prev_temp.unwrap(), temperature));
                    }
                }
    
                // 🦆 says ⮞ left da home?    
                if payload == "\"LEFT\"" {
                    // 🦆 says ⮞ turn on security
                    self.set_larmed(true)?;
                } else if payload == "\"RETURN\"" {
                    // 🦆 says ⮞ home again? turn off security
                    self.set_larmed(false)?;
                }
    
                // 🦆 says ⮞ ❤️‍🔥 FIRE / SMOKE DETECTOR    
                if let Some(smoke) = data["smoke"].as_bool() {
                    if smoke {
                        self.run_yo_command(&["notify", "❤️‍🔥❤️‍🔥❤️‍🔥 FIRE !!! ❤️‍🔥❤️‍🔥❤️‍🔥"])?;
                        self.quack_info(&format!("❤️‍🔥❤️‍🔥 SMOKE! in {} {}", device_name, room));
                    }
                }
    
                // 🦆 says ⮞ 🕵️ MOTION SENSORS
                if let Some(occupancy) = data["occupancy"].as_bool() {
                    if occupancy {
                        let motion_data = json!({
                            "last_active_room": room,
                            "timestamp": Local::now().to_rfc3339()
                        }); // 🦆 says ⮞ save it, useful laterz?
                        fs::write(format!("{}/last_motion.json", self.state_dir), motion_data.to_string())?;
                        self.quack_debug(&format!("🕵️ Motion in {} {}", device_name, room));
                        // 🦆 says ⮞ & update state file yo
                        let timestamp = SystemTime::now().duration_since(UNIX_EPOCH).unwrap().as_secs();
                        self.update_device_state("apartment", "last_motion", &timestamp.to_string())?;
                        
                        if self.is_dark_time() { // 🦆 says ⮞ motion & iz dark? turn room lightsz on cool & timer to power off again 
                            self.room_lights_on(room)?;
                            self.reset_room_timer(room)?;
                        } else { // 🦆 says ⮞ daytime? lightz no thnx
                            self.quack_debug("❌ Daytime - no lights activated by motion.");
                        }
                    } else { // 🦆 says ⮞ no more movementz update state file yo
                        self.quack_debug(&format!("🛑 No more motion in {} {}", device_name, room));
                        // State already updated by centralized function
                    }
                }
    
                // 🦆 says ⮞ 💧 WATER SENSORS
                if data["water_leak"].as_bool() == Some(true) || data["waterleak"].as_bool() == Some(true) {
                    self.quack_info(&format!("💧 WATER LEAK DETECTED in {} on {}", room, device_name));
                    self.run_yo_command(&["notify", &format!("💧 WATER LEAK DETECTED in {} on {}", room, device_name)])?;     
                    tokio::time::sleep(Duration::from_secs(15)).await;
                    self.run_yo_command(&["notify", &format!("WATER LEAK DETECTED in {} on {}", room, device_name)])?;
                }
    
                // 🦆 says ⮞ DOOR / WINDOW SENSOR
                if let Some(contact) = data["contact"].as_bool() {
                    if contact {
                        self.quack_info(&format!("🚪 Door open in {} ({})", room, device_name));
                        // 🦆 says ⮞ check time & where last motion iz
                        let current_time = SystemTime::now().duration_since(UNIX_EPOCH).unwrap().as_secs();
                        let last_motion_str = self.get_state("apartment", "last_motion").unwrap_or_else(|| "0".to_string());
                        let last_motion: u64 = last_motion_str.parse().unwrap_or(0);
                        let time_diff = current_time.saturating_sub(last_motion); 
                        self.quack_debug(&format!("TIME: {} | LAST MOTION: {} | TIME DIFF: {}", current_time, last_motion, time_diff));
                        
                        if time_diff > 7200 { // 🦆 says ⮞ secondz
                            self.quack_info("Welcoming you home! (no motion for 2 hours, door opened)");
                            tokio::time::sleep(Duration::from_secs(5)).await;
                            self.run_yo_command(&["say", "--text", "Välkommen hem idiot!", "--host", "desktop"])?; // 🦆 says ⮞ ='(
                        } else { 
                            self.quack_info(&format!("🛑 NOT WELCOMING:🛑 only {} minutes since last motion", time_diff / 60));
                        }
                    }
                }
    
                // 🦆 says ⮞ BLINDz - diz iz where i got my name from? quack
                if let Some(position) = data["position"].as_u64() {
                    if device.device_type == "blind" {
                        if position == 0 {
                            self.quack_info(&format!("🪟 Rolled DOWN {} in {}", device_name, room));
                        } else if position == 100 {
                            self.quack_info(&format!("🪟 Rolled UP {} in {}", device_name, room));
                        } else {
                            self.quack_debug(&format!("🪟 {} positioned at {}% in {}", device_name, position, room));
                        }
                    }
                }
                
                // 🦆 says ⮞ STATE
                if let Some(state) = data["state"].as_str() {
                    match device.device_type.as_str() { // 🦆 says ⮞ outletz/energy meters etc
                        "outlet" => {
                            if state == "ON" {
                                self.quack_info(&format!("🔌 {} Turned ON in {}", device_name, room));
                            } else if state == "OFF" {
                                self.quack_info(&format!("🔌 {} Turned OFF in {}", device_name, room));
                            }
                        }
                        "light" => {
                            if state == "ON" {
                                self.quack_debug(&format!("💡 {} Turned ON in {}", device_name, room));
                            } else if state == "OFF" {
                                self.quack_debug(&format!("💡 {} Turned OFF in {}", device_name, room));
                            }
                        }
                        _ => { // 🦆 says ⮞ handle other device types that have state
                            if state == "ON" {
                                self.quack_debug(&format!("⚡ {} Turned ON in {}", device_name, room));
                            } else if state == "OFF" {
                                self.quack_debug(&format!("⚡ {} Turned OFF in {}", device_name, room));
                            }
                        }
                    }
                }
    
                // 🦆 says ⮞ 🎚 DIMMER SWITCH
                if let Some(action) = data["action"].as_str() {
                    match action { // 🦆 says ⮞ on button - turns on room lights yo
                        "on_press_release" => {
                            self.quack_info(&format!("💡 Turning on lights in {}", room));
                            self.room_lights_on(room)?;
                            self.execute_automations("dimmer", &action, &device_name, &room)?;
                        }
                        "on_hold_release" => { // 🦆 says ⮞ on hold button - turns on all lights
                            self.control_all_lights("ON", Some(255))?;
                            self.execute_automations("dimmer", &action, &device_name, &room)?;
                            self.quack_info("✅💡 MAX LIGHTS ON");
                        }
                        "up_press_release" => { // 🦆 says ⮞ dim + button - increase brightness in room
                            self.execute_automations("dimmer", &action, &device_name, &room)?;
                            for (light_id, light_device) in &self.devices {
                                if light_device.room == *room && light_device.device_type == "light" {
                                    self.quack_info(&format!("🔺 Increasing brightness on {} in {}", light_id, room));
                                    let message = json!({
                                        "brightness_step": 50,
                                        "transition": 3.5
                                    });
                                    let topic = format!("zigbee2mqtt/{}/set", light_id);
                                    self.mqtt_publish(&topic, &message.to_string())?;
                                }
                            }
                        }
                        "down_press_release" => { // 🦆 says ⮞ dim - button - decrease brightness in room
                            self.execute_automations("dimmer", &action, &device_name, &room)?;
                            for (light_id, light_device) in &self.devices {
                                if light_device.room == *room && light_device.device_type == "light" {
                                    self.quack_info(&format!("🔻 Decreasing {} in {}", light_id, room));
                                    let message = json!({
                                        "brightness_step": -50,
                                        "transition": 3.5
                                    });
                                    let topic = format!("zigbee2mqtt/{}/set", light_id);
                                    self.mqtt_publish(&topic, &message.to_string())?;
                                }
                            }
                        }
                        "off_press_release" => { // 🦆 says ⮞ off button - turns off room lights plx
                            self.quack_info(&format!("💡 Turning off lights in {}", room));
                            self.room_lights_off(room)?;
                            self.execute_automations("dimmer", &action, &device_name, &room)?;
                        }
                        "off_hold_release" => { // 🦆 says ⮞ off hold button - turns off all lights!
                            self.control_all_lights("OFF", None)?;
                            self.execute_automations("dimmer", &action, &device_name, &room)?;
                            self.quack_info("🦆⮞ DARKNESS ON");
                        }
                        _ => { // 🦆 says ⮞ else debug print button action
                            self.quack_debug(&format!("{}", action));
                        }
                    }
                }
    
                // 🦆 says ⮞ 🛒 SHOPPING LIST
                if let Some(shopping_action) = data["shopping_action"].as_str() {
                    let shopping_list_file = format!("{}/shopping_list.txt", self.state_dir);   
                    match shopping_action {
                        "add" => {
                            if let Some(item) = data["item"].as_str() {
                                fs::write(&shopping_list_file, format!("{}\n", item))?;
                                self.quack_info(&format!("🛒 Added '{}' to shopping list", item));
                                let message = json!({
                                    "action": "add",
                                    "item": item
                                });
                                self.mqtt_publish("zigbee2mqtt/shopping_list/updated", &message.to_string())?;
                                self.run_yo_command(&["notify", &format!("🛒 Added: {}", item)])?;
                            }
                        }
                        "remove" => {
                            if let Some(item) = data["item"].as_str() {
                                self.quack_info(&format!("🛒 Removed '{}' from shopping list", item));
                            }
                        }
                        "clear" => {
                            fs::write(&shopping_list_file, "")?;
                            self.quack_info("🛒 Cleared shopping list");
                            self.mqtt_publish("zigbee2mqtt/shopping_list/updated", r#"{"action":"clear"}"#)?;
                            self.run_yo_command(&["notify", "🛒 List cleared"])?;
                        }
                        "view" => {}
                        _ => {}
                    }
                    return Ok(());
                }
    
                // 🦆 says ⮞ NLP COMMAND
                if let Some(command) = data["command"].as_str() {
                    self.quack_info(&format!("yo do execution requested from web interface: yo do {}", command));
                    let _ = Command::new("yo")
                        .arg("do")
                        .arg(command)
                        .spawn();
                    return Ok(());
                }
    
                // 🦆 says ⮞ TV COMMAND
                if let Some(tv_command) = data["tvCommand"].as_str() {
                    if let Some(ip) = data["ip"].as_str() {
                        self.quack_info(&format!("TV command received! Command: {}. IP: {}", tv_command, ip));
                        self.run_yo_command(&["tv", "--typ", tv_command, "--device", ip])?;
                    }
                    return Ok(());
                }
            }
    
            let duration = start_time.elapsed().as_millis();
            self.update_performance_stats(topic, duration); 
            Ok(())
        }
    
        async fn start_listening(&mut self) -> Result<(), Box<dyn std::error::Error>> {
            self.quack_info("🚀 Starting zigduck automation system");
            self.quack_info("📡 Listening to all Zigbee events...");
    
            let mut mqttoptions = MqttOptions::new("zigduck-rs", &self.mqtt_broker, 1883);
            mqttoptions.set_credentials(&self.mqtt_user, &self.mqtt_password);
            mqttoptions.set_keep_alive(Duration::from_secs(5));
            // 🦆 says ⮞ max packet size if larger payloads
            mqttoptions.set_max_packet_size(256 * 1024, 256 * 1024); // 🦆 says ⮞ 256KB
    
            let (mut client, mut connection) = Client::new(mqttoptions, 10);
            client.subscribe("zigbee2mqtt/#", QoS::AtMostOnce)?;
    
            self.quack_info(&format!("Connected to MQTT broker: {}", &self.mqtt_broker));
            self.quack_info("🦆🏡 Welcome Home");
            // 🦆 says ⮞ main event loop with reconnect yo 
            loop {
                match connection.eventloop.poll().await {
                    Ok(event) => {
                        if let Event::Incoming(Incoming::Publish(publish)) = event {
                            let topic = publish.topic;
                            let payload = String::from_utf8_lossy(&publish.payload);
                            
                            if let Err(e) = self.process_message(&topic, &payload).await {
                                self.quack_debug(&format!("Failed to process message: {}", e));
                            }
                        }
                    }
                    Err(e) => {
                        self.quack_debug(&format!("Connection error: {}", e));
                        self.quack_info("Attempting to reconnect in 5 seconds...");
                        tokio::time::sleep(Duration::from_secs(5)).await;
                        
                        // 🦆 says ⮞ recreate connection
                        let mut mqttoptions = MqttOptions::new("zigduck-rs", &self.mqtt_broker, 1883);
                        mqttoptions.set_credentials(&self.mqtt_user, &self.mqtt_password);
                        mqttoptions.set_keep_alive(Duration::from_secs(5));
                        mqttoptions.set_max_packet_size(256 * 1024, 256 * 1024);
                       
                        let (new_client, new_connection) = Client::new(mqttoptions, 10);
                        client = new_client;
                        connection = new_connection;
                        
                        match client.subscribe("zigbee2mqtt/#", QoS::AtMostOnce) {
                            Ok(_) => self.quack_info("Successfully reconnected and subscribed"),
                            Err(e) => self.quack_debug(&format!("Failed to subscribe after reconnect: {}", e)),
                        }
                    }
                }
            }
        }
    }
    
    fn main() -> Result<(), Box<dyn std::error::Error>> {
        // 🦆 says ⮞ get configuration from env var or cmd
        let mqtt_broker = std::env::var("MQTT_BROKER").unwrap_or_else(|_| "192.168.1.211".to_string());
        let mqtt_user = std::env::var("MQTT_USER").unwrap_or_else(|_| "mqtt".to_string());
        let mqtt_password = std::env::var("MQTT_PASSWORD")
            .or_else(|_| std::fs::read_to_string("/run/secrets/mosquitto"))
            .unwrap_or_else(|_| "".to_string());
        let debug = std::env::var("DEBUG").is_ok();
        
        // 🦆 says ⮞ static state directory path
        let state_dir = "/var/lib/zigduck".to_string();
        let timer_dir = format!("{}/timers", state_dir);
        std::fs::create_dir_all(&timer_dir)?;

        // 🦆 says ⮞ Get automations config and dark time setting
        let automations_file = std::env::var("AUTOMATIONS_FILE")
            .unwrap_or_else(|_| "automations.json".to_string());
        let dark_time_enabled = std::env::var("DARK_TIME_ENABLED")
            .map(|s| s == "1")
            .unwrap_or(true); // Default to true for backward compatibility
                
        // 🦆 says ⮞ read devices from env var
        let devices_file = std::env::var("ZIGBEE_DEVICES_FILE")
            .unwrap_or_else(|_| "devices.json".to_string());
    
        eprintln!("[🦆📜] ✅INFO✅ ⮞ MQTT Broker: {}", mqtt_broker);
        eprintln!("[🦆📜] ✅INFO✅ ⮞ State Directory: {}", state_dir);
        eprintln!("[🦆📜] ✅INFO✅ ⮞ Devices file: {}", devices_file);
        if debug {
            eprintln!("[🦆📜] ⁉️DEBUG⁉️ ⮞ Debug mode enabled");
        }
    
        let mut state = ZigduckState::new(
            mqtt_broker,
            mqtt_user,
            mqtt_password,
            state_dir,
            devices_file,
            automations_file,
            dark_time_enabled,
            debug,
        );
        
        // 🦆 says ⮞ simple runtime
        let rt = tokio::runtime::Runtime::new()?;
        rt.block_on(async {
            state.start_listening().await
        })
    }  
  '';

  # 🦆 says ⮞ cargo.toml
  zigduck-toml = pkgs.writeText "zigduck.toml" ''    
    [package]
    name = "zigduck-rs"
    version = "0.1.0"
    edition = "2024"

    [dependencies]
    tokio = { version = "1.0", features = ["full"] }
    rumqttc = "0.21.0"
    serde = { version = "1.0", features = ["derive"] }
    serde_json = "1.0"
    chrono = { version = "0.4", features = ["serde"] }
  '';
  
in { # 🦆 says ⮞ finally here, quack! 
  yo.scripts.zigduck-rs = {
    description = "Home automation system written in Rust";
    category = "🛖 Home Automation"; # 🦆 says ⮞ thnx for following me home
    logLevel = "INFO";
    autoStart = config.this.host.hostname == "homie"; # 🦆 says ⮞ dat'z sum conditional quack-fu yo!
    parameters = [ # 🦆 says ⮞ set your mosquitto user & password
      { name = "dir"; description = "Directory path to compile in"; default = "/home/pungkula/zigduck-rs"; optional = false; } 
      { name = "user"; description = "User which Mosquitto runs on"; default = "mqtt"; optional = false; }
      { name = "pwfile"; description = "Password file for Mosquitto user"; optional = false; default = config.sops.secrets.mosquitto.path; }
    ];
    code = ''
      ${cmdHelpers}
      MQTT_BROKER="${mqttHostip}"
      #MQTT_BROKER="localhost"
      dt_info "MQTT_BROKER: $MQTT_BROKER" 
      MQTT_USER="$user"
      MQTT_PASSWORD=$(cat "$pwfile")

      # 🦆 says ⮞ create the Rust projectz directory and move into it
      mkdir -p "$dir"
      cd "$dir"
      mkdir -p src
      # 🦆 says ⮞ create the source filez yo 
      cat ${zigduck-rs} > src/main.rs
      cat ${zigduck-toml} > Cargo.toml
      
      # 🦆 says ⮞ check build bool
      if [ "$build" = true ]; then
        dt_debug "Deleting any possible old versions of the binary"
        rm -f target/release/zigduck-rs
        ${pkgs.cargo}/bin/cargo generate-lockfile      
        ${pkgs.cargo}/bin/cargo build --release
        dt_info "Build complete!"
      fi # 🦆 says ⮞ if no binary exist - compile it yo
      if [ ! -f "target/release/zigduck-rs" ]; then
        ${pkgs.cargo}/bin/cargo generate-lockfile     
        ${pkgs.cargo}/bin/cargo build --release
        dt_info "Build complete!"
      fi

      # 🦆 says ⮞ check yo.scripts.do if DEBUG mode yo
      if [ "$VERBOSE" -ge 1 ]; then
        DEBUG=1 ZIGBEE_DEVICES='${deviceMeta}' ZIGBEE_DEVICES_FILE="${devices-json}" AUTOMATIONS_FILE="${automationsFile}" DARK_TIME_ENABLED="${darkTimeEnabled}" DT_LOG_FILE_PATH="$DT_LOG_PATH$DT_LOG_FILE" ./target/release/zigduck-rs
      fi  
      # 🦆 says ⮞ else run debugless yo
      ZIGBEE_DEVICES='${deviceMeta}' ZIGBEE_DEVICES_FILE="${devices-json}" AUTOMATIONS_FILE="${automationsFile}" DARK_TIME_ENABLED="${darkTimeEnabled}" DT_LOG_FILE_PATH="$DT_LOG_PATH$DT_LOG_FILE" ./target/release/zigduck-rs
                  
    '';
  };

  # 🦆 says ⮞ zigduck bash the original og yo
  yo.scripts.zigduck = { # 🦆 says ⮞ dis is where my home at
    description = "Home automation system written in Bash";
    category = "🛖 Home Automation"; # 🦆 says ⮞ thnx for following me home
    #autoStart = config.this.host.hostname == "homie"; # 🦆 says ⮞ dat'z sum conditional quack-fu yo!
    #aliases = [ "hem" ]; # 🦆 says ⮞ and not laughing at me
    # 🦆 says ⮞ run `yo zigduck --help` to display your battery states!
    helpFooter = '' 
      # 🦆 says ⮞ TODO - TUI/GUI Group Control within help command  # 🦆 says ⮜ dis coold be cool yeah?!
      STATE_DIR=/var/lib/zigbee
      STATE_FILE="state.json"
      WIDTH=100
      cat <<EOF | ${pkgs.glow}/bin/glow --width $WIDTH -
## ──────⋆⋅☆⋅⋆────── ##
## 🔋 Battery Status
$(${pkgs.jq}/bin/jq -r --slurpfile mapping ${mappingFile} '
  to_entries[] |
  select(.value.battery != null) |
  .key as $ieee |
  .value.battery as $battery |
  ($mapping[0] | .[$ieee] // $ieee) as $display_name |
  "### 🖥️ Device: `\($display_name)`\n**Battery:** \($battery)% " +
  (
    if $battery >= 75 then "🔋"
    elif $battery >= 30 then "🟡"
    else "🪫"
    end
  ) + "\n"
' $STATE_DIR/$STATE_FILE)
## ──────⋆⋅☆⋅⋆────── ##
EOF
    '';
    logLevel = "INFO";
    parameters = [ # 🦆 says ⮞ set your mosquitto user & password
      { name = "user"; description = "User which Mosquitto runs on"; default = "mqtt"; optional = false; }
      { name = "pwfile"; description = "Password file for Mosquitto user"; optional = false; default = config.sops.secrets.mosquitto.path; }
    ]; # 🦆 says ⮞ Script entrypoint yo
    code = ''
      ${cmdHelpers} # 🦆 says ⮞ load default helper functions 
      DEBUG_MODE=DEBUG # 🦆 says ⮞ if true, duck logs flood
      ZIGBEE_DEVICES='${deviceMeta}'
      MQTT_BROKER="${mqttHostip}" && dt_debug "$MQTT_BROKER"
      MQTT_USER="$user" && dt_debug "$MQTT_USER"
      MQTT_PASSWORD=$(cat "$pwfile")
      STATE_DIR="${zigduckDir}"
      STATE_FILE="$STATE_DIR/state.json"
      TIMER_DIR="$STATE_DIR/timers" 
      BACKUP_ID=""
      BACKUP_TMP_FILE=""

      LARMED_FILE="$STATE_DIR/security_state.json"
      umask 077
      mkdir -p "$STATE_DIR" && mkdir -p "$TIMER_DIR"
      if [ ! -f "$STATE_FILE" ]; then
        echo "{}" > "$STATE_FILE"
        chmod 600 "$STATE_FILE"
      fi   


      update_device_state() {
        local device="$1"
        local key="$2"
        local value="$3"  
        local tmpfile
        tmpfile=$(mktemp 2>/dev/null || echo "/tmp/tmp.XXXXXX")
        tmpfile=$(mktemp 2>/dev/null || echo "$STATE_DIR/tmp.XXXXXX")
  
        if [ $? -ne 0 ]; then
          tmpfile="$STATE_DIR/tmp.$$.$RANDOM"
        fi
  
        touch "$tmpfile" 2>/dev/null || {
          dt_error "Cannot create temp file: $tmpfile"
          return 1
        }  
        chmod 600 "$tmpfile" 2>/dev/null  
        dt_debug "Updating state: $device.$key = $value"
  
        if [ -f "$STATE_FILE" ]; then
          ${pkgs.jq}/bin/jq --arg dev "$device" --arg key "$key" --arg val "$value" \
            '.[$dev][$key] = $val' "$STATE_FILE" > "$tmpfile" 2>/dev/null
        else
          echo "{}" | ${pkgs.jq}/bin/jq --arg dev "$device" --arg key "$key" --arg val "$value" \
            '.[$dev][$key] = $val' > "$tmpfile" 2>/dev/null
        fi  
        if [ $? -eq 0 ]; then
          mv "$tmpfile" "$STATE_FILE" 2>/dev/null && \
          chmod 644 "$STATE_FILE" 2>/dev/null
          dt_debug "Successfully updated state for $device"
        else
          dt_error "jq failed to update state for $device.$key"
          rm -f "$tmpfile" 2>/dev/null
          return 1
        fi
      }      
      
      if [ ! -f "$LARMED_FILE" ]; then
        echo '{"larmed":false}' > "$LARMED_FILE"
      fi

      set_larmed() {
        local state="$1"
        jq -n --argjson val "$state" '{larmed: $val}' > "$LARMED_FILE"
        mqtt_pub -t "zigbee2mqtt/security/state" -m "$(cat "$LARMED_FILE")"
        
        if [ "$state" = "true" ]; then
          dt_warning "🛡️ Security system ARMED"
          yo notify "🛡️ Security armed"
        else
          dt_warning "🛡️ Security system DISARMED"
          yo notify "🛡️ Security disarmed"
        fi
      }
      get_state() {
        local device="$1"
        local key="$2"
        ${pkgs.jq}/bin/jq -r ".\"$device\".\"$key\" // empty" "$STATE_FILE"
      }      
      get_larmed() {
        ${pkgs.jq}/bin/jq -r '.larmed' "$LARMED_FILE"
      }
      # 🦆 says ⮞ device parser for zigduck
      device_check() { 
        linkquality=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.linkquality // empty') && dt_debug "linkquality: $linkquality"
        last_seen=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.last_seen // empty') && dt_debug "last_seen: $last_seen"
        occupancy=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.occupancy // empty') && dt_debug "occupancy: $occupancy"
        action=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.action // empty') && dt_debug "action: $action"
        contact=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.contact // empty') && dt_debug "contact: $contact"
        position=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.position // empty') && dt_debug "position: $position"
        state=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.state // empty') && dt_debug "state: $state"
        brightness=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.brightness // empty') && dt_debug "brightness: $brightness"
        color=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.color // empty') && dt_debug "color: $color"
        water_leak=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.water_leak // empty') && dt_debug "water_leak: $water_leak"
        waterleak=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.waterleak // empty') && dt_debug "waterleak: $waterleak"
        temperature=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.temperature // empty') && dt_debug "temperature: $temperature"

        battery=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.battery // empty') && dt_debug "battery: $battery"
        battery_state=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.battery_state // empty') && dt_debug "battery state: $battery_state"
        tamper=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.tamper // empty') && dt_debug "Tamper: $tamper"
        smoke=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.smoke // empty') && dt_debug "Smoke: $smoke"
                
        device_name="''${topic#zigbee2mqtt/}" && dt_debug "device_name: $device_name"
        dev_room=$(${pkgs.jq}/bin/jq ".\"$device_name\".room" $STATE_DIR/zigbee_devices.json) && dt_debug "dev_room: $dev_room"
        dev_type=$(${pkgs.jq}/bin/jq ".\"$device_name\".type" $STATE_DIR/zigbee_devices.json) && dt_debug "dev_type: $dev_type"     
        dev_id=$(${pkgs.jq}/bin/jq ".\"$device_name\".id" $STATE_DIR/zigbee_devices.json) && dt_debug "dev_id: $dev_id"  
        room="''${dev_room//\"/}"
      
        should_update() {
          case "$device_name" in
            */set|*/availability)
              dt_debug "Skipping update for device: $device_name (set/availability topic)"
              return 1
            ;;
            *)
              dt_debug "Will update state for device: $device_name"
              return 0  
            ;;
          esac
        }

        if should_update; then
          [ -n "$battery" ] && update_device_state "$device_name" "battery" "$battery"
          [ -n "$temperature" ] && update_device_state "$device_name" "temperature" "$temperature"
          [ -n "$state" ] && update_device_state "$device_name" "state" "$state"
          [ -n "$brightness" ] && update_device_state "$device_name" "brightness" "$brightness"
          [ -n "$color" ] && update_device_state "$device_name" "color" "$color"        
          [ -n "$position" ] && update_device_state "$device_name" "position" "$position"
          [ -n "$contact" ] && update_device_state "$device_name" "contact" "$contact"
          [ -n "$tamper" ] && update_device_state "$device_name" "tamper" "$tamper"
          [ -n "$smoke" ] && update_device_state "$device_name" "smoke" "$smoke"
          [ -n "$battery_state" ] && update_device_state "$device_name" "Battery state" "$battery_state"
          [ -n "$occupancy" ] && update_device_state "$device_name" "occupancy" "$occupancy"
         
          [ -n "$last_seen" ] && update_device_state "$device_name" "last_seen" "$last_seen"        
          [ -n "$linkquality" ] && update_device_state "$device_name" "linkquality" "$linkquality"       
        else
          dt_debug "Skipped state update for device: $device_name"
        fi
      }
  
      # 🦆 says ⮞ zigbee coordinator backup function
      perform_zigbee_backup() {
        BACKUP_ID="zigbee_backup_$(${pkgs.coreutils}/bin/date +%Y%m%d_%H%M%S)"
        BACKUP_TMP_FILE="$(mktemp)"
        say_duck "Triggering Zigbee coordinator backup: $BACKUP_ID"
        mqtt_pub -t "zigbee2mqtt/bridge/request/backup" -m "{\"id\": \"$BACKUP_ID\"}"
      }
      # 🦆 says ⮞ handle backup response function
      handle_backup_response() {
        local line="$1"
        local backup_id=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.id')        
        if [ "$backup_id" != "$BACKUP_ID" ]; then
          dt_info "ignoring backup response for ID: $backup_id (waiting for $BACKUP_ID)"
          return
        fi      
        local status=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.status')
        if [ "$status" = "ok" ]; then
          echo "$line" | ${pkgs.jq}/bin/jq -r '.data.backup' > "$BACKUP_TMP_FILE"
          dt_debug "Encrypting Zigbee coordinator backup with sops..."   
          if "''${config.pkgs.yo}/bin/yo-sops" "$BACKUP_TMP_FILE" > "${backupEncryptedFile}"; then
            dt_info "Backup saved to: ${backupEncryptedFile}"
          else
            say_duck "fuck ❌ encryption failed for zigbee coordinator backup!"
            dt_critical "Encryption failed for zigbee coordinator backup!"
          fi
          rm -f "$BACKUP_TMP_FILE"
        else
          local error_msg=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.error')
          say_duck "❌ Backup failed: $error_msg"
          dt_critical "Backup failed: $error_msg"
        fi    
        # 🦆 says ⮞ reset states
        BACKUP_ID=""
        BACKUP_TMP_FILE=""
      }  
      # 🦆 says ⮞ main loop - ducks can't listen but mosquitto's can apparently    
      start_listening() {
        echo "$ZIGBEE_DEVICES" | ${pkgs.jq}/bin/jq 'map({(.id): .}) | add' > $STATE_DIR/zigbee_devices.json
        ${pkgs.jq}/bin/jq 'map(select(.friendly_name != null) | {(.friendly_name): .}) | add' $STATE_DIR/zigbee_devices.json \
          > $STATE_DIR/zigbee_devices_by_friendly_name.json
        # 🦆 says ⮞ last echo
        echo "🦆🏡 Welcome Home" 
        
        # 🦆 says ⮞ performance tracking
        declare -A processing_times
        declare -A message_counts
        local total_messages=0
        local slow_threshold=100 # 🦆 says ⮞ ms        
        
        # 🦆 says ⮞ Subscribe and split topic and payload
        mqtt_sub "zigbee2mqtt/#" | while IFS='|' read -r topic line; do
          dt_debug "TOPIC: 
          $topic" && dt_debug "PAYLOAD: 
          $line"         
          # 🦆 says ⮞ backup handling
          if [ "$topic" = "zigbee2mqtt/bridge/response/backup" ]; then handle_backup_response "$line"; fi          
          # 🦆 says ⮞ trigger backup from MQTT
          if [ "$topic" = "zigbee2mqtt/backup/request" ]; then perform_zigbee_backup; fi

          # 🦆 says ⮞ TV  DEVICES CHANNEL STATE 
          if echo "$line" | ${pkgs.jq}/bin/jq -e 'has("tvChannel")' > /dev/null; then
              channel=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.tvChannel')
              ip=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.ip // "192.168.1.223"')
              if [ -n "$channel" ]; then
                  dt_info "TV channel change requested! Channel: $channel . IP: $ip"
                  device_name=$(${pkgs.jq}/bin/jq -r --arg ip "$ip" '
                      to_entries[] | select(.value.ip == $ip) | .key
                  ' "${tvDevicesJson}")
                  if [ -n "$device_name" ] && [ "$device_name" != "null" ]; then
                      dt_info "Changing channel on $device_name ($ip) to: $channel"
                      yo tv --typ livetv --device "$ip" --search "$channel"
                  else
                      dt_warning "Unknown TV device IP: $ip, attempting channel change anyway"
                      yo tv --typ livetv --device "$ip" --search "$channel"
                  fi
              fi
              continue
          fi

          # 🦆 says ⮞ TV CHANNEL STATE UPDATES          
          if [[ "$topic" == zigbee2mqtt/tv/*/channel ]]; then
              device_ip=$(echo "$topic" | cut -d'/' -f3)
              channel_id=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.channel_id')
              channel_name=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.channel_name')
              device_name=$(${pkgs.jq}/bin/jq -r --arg ip "$device_ip" '
                  to_entries[] | select(.value.ip == $ip) | .key
              ' "${tvDevicesJson}")
              if [ -n "$device_name" ] && [ "$device_name" != "null" ]; then
                  dt_info "📺 $device_name live tv channel: $channel_name"
                  update_device_state "tv_$device_name" "current_channel" "$channel_id"
                  update_device_state "tv_$device_name" "current_channel_name" "$channel_name"
                  update_device_state "tv_$device_name" "last_update" "$(${pkgs.coreutils}/bin/date -Iseconds)"
              fi
              continue
          fi
          
          # 🦆 says ⮞ ENERGY CONSUMPTION & PRICE
          if [ "$topic" = "zigbee2mqtt/tibber/price" ]; then
              current_price=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.current_price')
              if [ -n "$current_price" ]; then
                  update_device_state "tibber" "current_price" "$current_price"
                  dt_info "Energy price updated: $current_price SEK/kWh"
              fi
              continue
          fi

          if [ "$topic" = "zigbee2mqtt/tibber/usage" ]; then
              monthly_usage=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.monthly_usage')
              if [ -n "$monthly_usage" ]; then
                  update_device_state "tibber" "monthly_usage" "$monthly_usage"
                  dt_info "Energy usage updated: $monthly_usage kWh"
              fi
              continue
          fi

          # 🦆 says ⮞ 🚨 alarm
          if echo "$line" | ${pkgs.jq}/bin/jq -e 'has("security")' > /dev/null; then 
            if [ "$LARMED" = "true" ]; then
              dt_info "Larmed apartment"
              yo notify "Larm på"
            fi
          fi
          
          # 🦆 says ⮞ 🔋 battery
          if echo "$line" | ${pkgs.jq}/bin/jq -e 'has("battery")' > /dev/null; then
            device_check
            prev_battery=$(${pkgs.jq}/bin/jq -r ".\"$device_name\".battery" "$STATE_FILE")

            if [ "$battery" != "$prev_battery" ] && [ "$prev_battery" != "null" ]; then
              dt_info "🔋 Battery update for $device_name: ''${prev_battery}% > ''${battery}%"
            fi
          fi

          # 🦆 says ⮞ 🌡️ temperature
          if echo "$line" | ${pkgs.jq}/bin/jq -e 'has("temperature")' > /dev/null; then
            device_check
            prev_temp=$(${pkgs.jq}/bin/jq -r ".\"$device_name\".temperature" "$STATE_FILE")
            if [ "$temperature" != "$prev_temp" ] && [ "$prev_temp" != "null" ]; then
              dt_info "🌡️ Temperature update for $device_name: ''${prev_temp}°C > ''${temperature}°C"
            fi
          fi
         
          # 🦆 says ⮞ left home yo
          # call with: mosquitto_pub -h IP -t "zigbee2mqtt/leaving_home" -m "LEFT"
          if [ "$line" = "LEFT" ]; then
            set_larmed true            
          fi
          # 🦆 says ⮞ returned homez
          # calll mosquitto_pub -h "${mqttHostip}" -t "zigbee2mqtt/returning_home" -m "RETURN" 
          if [ "$line" = "RETURN" ]; then
            set_larmed false
          fi

          # 🦆 says ⮞ ❤️‍🔥 SMOKE SMOKE SMOKE
          if echo "$line" | ${pkgs.jq}/bin/jq -e 'has("smoke")' > /dev/null; then
            device_check            
            if [ "$smoke" = "true" ]; then
              yo notify "❤️‍🔥❤️‍🔥❤️‍🔥 FIRE !!! ❤️‍🔥❤️‍🔥❤️‍🔥"
              echo "❤️‍🔥❤️‍🔥❤️‍🔥❤️‍🔥❤️‍🔥❤️‍🔥❤️‍🔥❤️‍🔥"
              dt_critical "❤️‍🔥❤️‍🔥 SMOKE! in in $device_name $dev_room"
            fi
          fi
          
          # 🦆 says ⮞ 🕵️ quick quack motion detect
          if echo "$line" | ${pkgs.jq}/bin/jq -e 'has("occupancy")' > /dev/null; then
            device_check   
            dt_info "🕵️ Occupancy update for $device_name: $occupancy (prev: $(get_state "$device_name" "occupancy"))"  
            if [ "$occupancy" = "true" ]; then
              # 🦆 says ⮞ save for easy user localisation
              echo "{\"last_active_room\": \$dev_room\, \"timestamp\": \"$(${pkgs.coreutils}/bin/date -Iseconds)\"}" > "$STATE_DIR/last_motion.json"
              dt_info "🕵️ Motion in $device_name $dev_room"
              # 🦆 says ⮞ track last motion time 
              update_device_state "apartment" "last_motion" "$(${pkgs.coreutils}/bin/date +%s)"
              # 🦆 says ⮞ If current time is within motion > light timeframe - turn on lights
              if is_dark_time; then
                room_lights_on "$room"
                reset_room_timer "$room"
              else
                dt_debug "❌ Daytime - no lights activated by motion."
              fi
            else
              dt_debug "🛑 No more motion in $device_name $dev_room"    
              update_device_state "$device_name" "occupancy" "false"
            fi
          fi

          # 🦆 says ⮞ 💧 water sensor
          if echo "$line" | ${pkgs.jq}/bin/jq -e 'has("water_leak")' > /dev/null; then
            device_check            
            if [[ "$water_leak" == "true" || "$waterleak" == "true" ]]; then
              dt_critical "💧 WATER LEAK DETECTED in $dev_room on $device_name"
              yo notify "💧 WATER LEAK DETECTED in $dev_room on $device_name"
              sleep 15
              yo notify "WATER LEAK DETECTED in $dev_room on $device_name"
            fi
          fi
          
          # 🦆 says ⮞ 🚪 door and window sensor yo 
          if echo "$line" | ${pkgs.jq}/bin/jq -e 'has("contact")' > /dev/null; then
            device_check
            dt_info "🚪 Door open in $dev_room ($device_name)"
            current_time=$(${pkgs.coreutils}/bin/date +%s)
            last_motion=$(get_state "apartment" "last_motion")
            time_diff=$((current_time - last_motion))
            dt_debug "TIME: $current_time | LAST MOTION: $last_motion | TIME DIFF: $time_diff"
            # 🦆 says ⮞ diz iz a fun one - if i've been gone for >2 hours
            if [ $time_diff -gt 7200 ]; then 
              dt_info "Welcoming you home! (no motion for 2 hours, door opened"
              # 🦆 says ⮞ then greet me welcome home - so i can say "quack? thanx yo!"
              sleep 5 && yo say --text "Välkommen hem!" --host "desktop"
            else
              dt_info "🛑 NOT WELCOMING:🛑 only $((time_diff/60)) minutes since last motion"
            fi
          fi       

          # 🦆 says ⮞ 🪟 BLIND & shaderz
          if echo "$line" | ${pkgs.jq}/bin/jq -e 'has("position")' > /dev/null; then
            device_check
            if [ "$dev_type" = "blind" ]; then 
              if [ "$position" = "0" ]; then
                dt_info "🪟 Rolled DOWN $device_name in $dev_room"
              fi     
              if [ "$position" = "100" ]; then
                dt_info "🪟 Rolled UP $device_name in $dev_room"
              fi
            fi  
          fi  

          # 🦆 says ⮞ 🔌 power plugz & energy meterz
          if echo "$line" | ${pkgs.jq}/bin/jq -e 'has("state")' > /dev/null; then
            device_check     
            if [[ "$dev_type" == "plug" || "$dev_type" == "power" || "$dev_type" == "outlet" ]]; then
              if [ "$state" = "ON" ]; then      
                dt_info "🔌 $device_name Turned ON in $dev_room"
              fi       
              if [ "$state" = "OFF" ]; then
                dt_info "🔌 $device_name Turned OFF in $dev_room"
              fi  
            else  

          # 🦆 says ⮞ 💡 state change (debug)      
              if [ "$state" = "OFF" ]; then
                dt_debug "💡 $device_name Turned OFF in $dev_room"
              fi  
              if [ "$state" = "ON" ]; then
                dt_debug "💡 $device_name Turned ON in $dev_room"
              fi                
            fi  
          fi 

          # 🦆 says ⮞ 🎚 Dimmer Switch actions
          if echo "$line" | ${pkgs.jq}/bin/jq -e 'has("action")' > /dev/null; then
            device_check       
            if [ "$action" == "on_press_release" ]; then
              # 🦆 says ⮞ turn on all lights in the room
              room_lights_on "$room"
            # 🦆 says ⮞ yo homie, turn the fan on when grillin'
            if [ "$clean_room" == "kitchen" ]; then mqtt_pub -t "zigbee2mqtt/Fläkt/set" -m '{"state":"ON"}'; fi
            fi
            if [ "$action" == "on_hold_release" ]; then scene "max" && dt_debug "✅💡 MAX LIGHTS ON"; fi
            if [ "$action" == "up_press_release" ]; then
              clean_room=$(echo "$dev_room" | sed 's/"//g')
                ${pkgs.jq}/bin/jq -r --arg room "$clean_room" 'to_entries | map(select(.value.room == $room and .value.type == "light")) | .[].value.id' $STATE_DIR/zigbee_devices.json |
                  while read -r light_id; do
                    dt_debug "🔺 Increasing brightness on $light_id in $clean_room"
                    mqtt_pub -t "zigbee2mqtt/$light_id/set" -m '{"brightness_step":50,"transition":3.5}'
                  done
            fi
            if [ "$action" == "up_hold_release" ]; then dt_debug "$action"; fi
            if [ "$action" == "down_press_release" ]; then
              clean_room=$(echo "$dev_room" | sed 's/"//g')
              ${pkgs.jq}/bin/jq -r --arg room "$clean_room" 'to_entries | map(select(.value.room == $room and .value.type == "light")) | .[].value.id' $STATE_DIR/zigbee_devices.json |
                while read -r light_id; do
                  dt_debug "🔻 Decreasing $light_id in $clean_room"
                  mqtt_pub -t "zigbee2mqtt/$light_id/set" -m '{"brightness_step":-50,"transition":3.5}'
                done
            fi
            if [ "$action" == "down_hold_release" ]; then dt_debug "$action"; fi
            if [ "$action" == "off_press_release" ]; then room_lights_off "$room"; fi
            if [ "$action" == "off_hold_release" ]; then scene "dark" && dt_debug "DARKNESS ON"; fi
          fi
          
          # 🦆 says ⮞ 🛒 shopping list functionality
          if echo "$line" | ${pkgs.jq}/bin/jq -e 'has("shopping_action")' > /dev/null; then
            shopping_action=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.shopping_action')
            item=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.item // ""')  
            SHOPPING_LIST_FILE="$STATE_DIR/shopping_list.txt"  
            case "$shopping_action" in
              "add")
                if [ -n "$item" ]; then
                  echo "$item" >> "$SHOPPING_LIST_FILE"
                  dt_info "🛒 Added '$item' to shopping list"
                  mqtt_pub -t "zigbee2mqtt/shopping_list/updated" -m "{\"action\": \"add\", \"item\": \"$item\"}"
                  yo notify "🛒 Added: $item"
                fi
                ;;
              "remove")
                if [ -n "$item" ]; then
                  grep -v -i -- "^$item\$" "$SHOPPING_LIST_FILE" > "$SHOPPING_LIST_FILE.tmp" && mv "$SHOPPING_LIST_FILE.tmp" "$SHOPPING_LIST_FILE"
                  dt_info "🛒 Removed '$item' from shopping list"
                  mqtt_pub -t "zigbee2mqtt/shopping_list/updated" -m "{\"action\": \"remove\", \"item\": \"$item\"}"
                  yo notify "🛒 Removed: $item"
                fi
                ;;
              "clear")
                > "$SHOPPING_LIST_FILE"
                dt_info "🛒 Cleared shopping list"
                mqtt_pub -t "zigbee2mqtt/shopping_list/updated" -m "{\"action\": \"clear\"}"
                yo notify "🛒 List cleared"
                ;;
              "view")
                if [ -f "$SHOPPING_LIST_FILE" ] && [ -s "$SHOPPING_LIST_FILE" ]; then
                  list_content=$(cat "$SHOPPING_LIST_FILE" | tr '\n' ',' | sed 's/,$//')
                  mqtt_pub -t "zigbee2mqtt/shopping_list/current" -m "{\"items\": \"$list_content\"}"
                else
                  mqtt_pub -t "zigbee2mqtt/shopping_list/current" -m "{\"items\": \"\"}"
                fi
                ;;
            esac
            continue
          fi
          
          # 🦆 says ⮞ 🤖 yo do commands
          if echo "$line" | ${pkgs.jq}/bin/jq -e 'has("command")' > /dev/null; then
            command=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.command')
            if [ -n "$command" ]; then
              dt_info "yo do execution requested from web interface: yo do $command"
              yo do "$command" &
            fi
            continue
          fi

          # 🦆 says ⮞ 📺 yo TV commands
          if echo "$line" | ${pkgs.jq}/bin/jq -e 'has("tvCommand")' > /dev/null; then
            command=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.tvCommand')
            ip=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.ip')
            if [ -n "$command" ]; then
              dt_info "TV command receieved! Command: $command . IP: $ip"
              yo tv --typ $command --device $ip
            fi
            continue
          fi
          
          local end_time=$(date +%s%N)
          local duration=$(( (end_time - start_time) / 1000000 ))
        
          # 🦆 says ⮞ update MA for this topic type
          local current_avg=''${processing_times["$topic"]:-0}
          processing_times["$topic"]=$(( (current_avg + duration) / 2 ))
          message_counts["$topic"]=$(( ''${message_counts["$topic"]:-0} + 1 ))
        
          # 🦆 says ⮞ slow? log it
          if [ $duration -gt $slow_threshold ]; then
            dt_warning "Slow processing: $topic took ''${duration}ms"
          fi
        
          # 🦆 says ⮞ log performance every 100 messages
          if [ $((total_messages % 100)) -eq 0 ]; then
            dt_info "[🦆📶] - Total messages: $total_messages"
            for topic_type in "''${!processing_times[@]}"; do
              local avg_time=''${processing_times["$topic_type"]}
              local count=''${message_counts["$topic_type"]}
              dt_debug "  $topic_type: avg ''${avg_time}ms, count $count"
            done
          fi
             
        done
      }
            
      # 🦆 says ⮞ ran diz thang
      dt_info "🚀 Starting zigduck automation system"  
      say_duck "🚀 quack to the moon yo!"
      dt_info "📡 Listening to all Zigbee events..."
      start_listening             
    '';
  };
   
  # 🦆 says ⮞ how does ducks say ssschh?
  sops.secrets = {
    mosquitto = { # 🦆 says ⮞ quack, stupid!
      sopsFile = ./../../secrets/mosquitto.yaml; 
      owner = config.this.user.me.name;
      group = config.this.user.me.name;
      mode = "0440"; # 🦆 says ⮞ Read-only for owner and group
    }; # 🦆 says ⮞ Z2MQTT encryption key - if changed needs re-pairing devices
    z2m_network_key = lib.mkIf (lib.elem "zigduck" config.this.host.modules.services) { 
      sopsFile = ./../../secrets/z2m_network_key.yaml; 
      owner = "zigbee2mqtt";
      group = "zigbee2mqtt";
      mode = "0440"; # 🦆 says ⮞ Read-only for owner and group
    };
    z2m_mosquitto = lib.mkIf (lib.elem "zigduck" config.this.host.modules.services) { 
      sopsFile = ./../../secrets/z2m_mosquitto.yaml; 
      owner = "zigbee2mqtt";
      group = "zigbee2mqtt";
      mode = "0440"; # 🦆 says ⮞ Read-only for owner and group
    };
  };
  # 🦆 says ⮞ Mosquitto configuration
  # 🦆 says ⮞ we only need server configuration on one host - so set zigduck at config.this.host.module services in your host config
  services.mosquitto = lib.mkIf (lib.elem "zigduck" config.this.host.modules.services) {
    enable = true;
    listeners = [
      { # 🦆 says ⮞ mqtt:// @ 1883
        acl = [ "pattern readwrite #" ];
        port = 1883;
        omitPasswordAuth = false; # 🦆 says ⮞ safety first!
        users.mqtt.passwordFile = config.sops.secrets.mosquitto.path;
        settings.allow_anonymous = false; # 🦆 says ⮞ never forget, never forgive right?
#        settings.require_certificate = true; # 🦆 says ⮞ T to the L to the S spells wat? DUCK! 
#        settings.use_identity_as_username = true;
      }   
      { # 🦆 says ⮞ ws:// @ 9001
        acl = [ "pattern readwrite #" ];
        port = 9001;
        settings.protocol = "websockets";
        omitPasswordAuth = false; # 🦆 says ⮞ safety first!
        users.mqtt.passwordFile = config.sops.secrets.mosquitto.path;
        settings.allow_anonymous = false; # 🦆 says ⮞ never forget, never forgive right?
        #settings.require_certificate = false; # 🦆 says ⮞ T to the L to the S spells wat? DUCK! 
      } 
    ];

  };
  # 🦆 says ⮞ open firewall 4 Z2MQTT & Mosquitto on the server host
  networking.firewall = lib.mkIf (lib.elem "zigduck" config.this.host.modules.services) { allowedTCPPorts = [ 1883 8099 9001 ]; };

  # 🦆 says ⮞ create device symlink for declarative serial port mapping
  services.udev.extraRules = ''SUBSYSTEM=="tty", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", SYMLINK+="zigbee"'';
  
  # 🦆 says ⮞ Z2MQTT configurations
  services.zigbee2mqtt = lib.mkIf (lib.elem "zigduck" config.this.host.modules.services) { # 🦆 says ⮞ once again - dis is server configuration
    enable = true;
    dataDir = "/var/lib/zigbee";
    settings = {
        experimental.output = "json";
        homeassistant = false; # 🦆 says ⮞ no thnx....
        mqtt = {
          server = "mqtt://localhost:1883";
          user = "mqtt";
          password =  config.sops.secrets.mosquitto.path; # 🦆 says ⮞ no support for passwordFile?! sneaky duckiie use dis as placeholder lol
          base_topic = "zigbee2mqtt";
        };
        # 🦆 says ⮞ physical port mapping
        serial = { # 🦆 says ⮞ either USB port (/dev/ttyUSB0), network Zigbee adapters (tcp://192.168.1.1:6638) or mDNS adapter (mdns://my-adapter).       
         port = "/dev/zigbee"; # 🦆 says ⮞ all hosts, same serial port yo!
         disable_led = true; # 🦆 says ⮞ save quack on electricity bill yo  
        };
        frontend = { 
          enabled = false;
          host = "0.0.0.0";   
          port = 8099; 
        };
        advanced = { # 🦆 says ⮞ dis is advanced? ='( duck tearz of sadness
          export_state = true;
          export_state_path = "${zigduckDir}/zigbee_devices.json";
          homeassistant_legacy_entity_attributes = false; # 🦆 says ⮞ wat the duck?! wat do u thiink?
          legacy_api = false;
          legacy_availability_payload = false;
          log_syslog = { # 🦆 says ⮞ log settings
            app_name = "Zigbee2MQTT";
            eol = "/n";
            host = "localhost";
            localhost = "localhost";
            path = "/dev/log";
            pid = "process.pid"; # 🦆 says ⮞ process id
            port = 123;
            protocol = "tcp4";# 🦆 says ⮞ TCP4pcplife
            type = "5424";
          };
          transmit_power = 9; # 🦆 says ⮞ to avoid brain damage, set low power
          channel = 15; # 🦆 says ⮞ channel 15 optimized for minimal interference from other 2.4Ghz devices, provides good stability  
          last_seen = "ISO_8601_local";
          # 🦆 says ⮞ zigbee encryption key.. quack? - better not expose it yo - letz handle dat down below
            # network_key = [ "..." ]
            pan_id = 60410;
          };
          device_options = { legacy = false; };
          availability = true;
          permit_join = false; # 🦆 says ⮞ allow new devices, not suggested for thin wallets
          devices = deviceConfig; # 🦆 says ⮞ inject defined Zigbee D!
          groups = groupConfig // { # 🦆 says ⮞ inject defined Zigbee G, yo!
            all_lights = { # 🦆 says ⮞ + create a group containing all light devices
              friendly_name = "all";
              devices = lib.concatMap (id: 
                let dev = zigbeeDevices.${id};
                in if dev.type == "light" then ["${id}/${toString dev.endpoint}"] else []
              ) (lib.attrNames zigbeeDevices);
            };
          };
        };
      }; 

  environment.systemPackages = [
    pkgs.clang
    # 🦆 says ⮞ Dependencies 
    pkgs.mosquitto
    pkgs.zigbee2mqtt # 🦆 says ⮞ wat? dat's all?
    # 🦆 says ⮞ scene fireworks  
    (pkgs.writeScriptBin "scene-roll" ''
      ${cmdHelpers}
      ${lib.concatStringsSep "\n" (lib.flatten (lib.mapAttrsToList (_: cmds: lib.mapAttrsToList (_: cmd: cmd) cmds) sceneCommands))}
    '')
    # 🦆 says ⮞ activate a scene yo
    (pkgs.writeScriptBin "scene" ''
      ${cmdHelpers}
      MQTT_BROKER="${mqttHostip}"
      MQTT_USER=$(nix eval "${config.this.user.me.dotfilesDir}#nixosConfigurations.${config.this.host.hostname}.config.yo.scripts.zigduck.parameters" --json | ${pkgs.jq}/bin/jq -r '.[] | select(.name == "user") | .default')
      MQTT_PASSWORD=$(cat "${config.sops.secrets.mosquitto.path}")
      SCENE="$1"      
      # 🦆 says ⮞ no scene == random scene
      if [ -z "$SCENE" ]; then
        SCENE=$(shuf -n 1 -e ${lib.concatStringsSep " " (lib.map (name: "\"${name}\"") (lib.attrNames sceneCommands))})
      fi      
      case "$SCENE" in
      ${
        lib.concatStringsSep "\n" (
          lib.mapAttrsToList (sceneName: cmds:
            let
              commandLines = lib.concatStringsSep "\n    " (
                lib.mapAttrsToList (_: cmd: cmd) cmds
              );
            in
              "\"${sceneName}\")\n    ${commandLines}\n    ;;"
          ) sceneCommands
        )
      }
      *)
        say_duck "fuck ❌"
        exit 1
        ;;
      esac
    '')     
    # 🦆 says ⮞ activate a scene yo
    (pkgs.writeScriptBin "zig" ''
      ${cmdHelpers}
      set -euo pipefail
      # 🦆 says ⮞ create case insensitive map of device friendly_name
      declare -A device_map=(
        ${lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "['${lib.toLower k}']='${v}'") normalizedDeviceMap)}
      )
      available_devices=(
        ${toString deviceList}
      )    
      DEVICE="$1" # 🦆 says ⮞ device to control      
      STATE="''${2:-}" # 🦆 says ⮞ state change        
      BRIGHTNESS="''${3:-100}"
      COLOR="''${4:-}"
      TEMP="''${5:-}"
      ZIGBEE_DEVICES='${deviceMeta}'
      MQTT_BROKER="${mqttHostip}"
      MQTT_USER=$(nix eval "${config.this.user.me.dotfilesDir}#nixosConfigurations.${config.this.host.hostname}.config.yo.scripts.zigduck.parameters" --json | ${pkgs.jq}/bin/jq -r '.[] | select(.name == "user") | .default')
      MQTT_PASSWORD=$(cat "${config.sops.secrets.mosquitto.path}") # ⮜ 🦆 says password file 
      # 🦆 says ⮞ Zigbee coordinator backup
      if [[ "$DEVICE" == "backup" ]]; then
        mqtt_pub -t "zigbee2mqtt/backup/request" -m '{"action":"backup"}'
        say_duck "Zigbee coordinator backup requested! - processing on server..."
        exit 0
      fi         
      # 🦆 says ⮞ validate device
      input_lower=$(echo "$DEVICE" | tr '[:upper:]' '[:lower:]')
      exact_name=''${device_map["$input_lower"]}
      if [[ -z "$exact_name" ]]; then
        say_duck "fuck ❌ device not found: $DEVICE" >&2
        say_duck "Available devices: ${toString (builtins.attrNames zigbeeDevices)}" >&2
        exit 1
      fi
      # 🦆 says ⮞ if COLOR da lamp prob want hex yo
      if [[ -n "$COLOR" ]]; then
        COLOR=$(color2hex "$COLOR") || {
          say_duck "fuck ❌ Invalid color: $COLOR" >&2
          exit 1
        }
      fi
      # 🦆 says ⮞ turn off the device
      if [[ "$STATE" == "off" ]]; then
        mqtt_pub -t "zigbee2mqtt/$exact_name/set" -m '{"state":"OFF"}'
        say_duck " turned off $DEVICE"
        exit 0
      fi    
      # 🦆 says ⮞ turn down the device brightness
      if [[ "$STATE" == "down" ]]; then
        say_duck "🔻 Decreasing $light_id in $clean_room"
        mqtt_pub -t "zigbee2mqtt/$exact_name/set" -m '{"brightness_step":-50,"transition":3.5}'
        exit 0
      fi      
      # 🦆 says ⮞ turn up the device brightness
      if [[ "$STATE" == "up" ]]; then
        say_duck "🔺 Increasing brightness on $light_id in $clean_room"
        mqtt_pub -t "zigbee2mqtt/$exact_name/set" -m '{"brightness_step":50,"transition":3.5}'
        exit 0
      fi      
      # 🦆 says ⮞ construct payload
      PAYLOAD="{\"state\":\"ON\""
      [[ -n "$BRIGHTNESS" ]] && PAYLOAD+=", \"brightness\":$BRIGHTNESS"
      [[ -n "$COLOR" ]] && PAYLOAD+=", \"color\":{\"hex\":\"$COLOR\"}"
      PAYLOAD+="}"
      # 🦆 says ⮞ publish payload
      mqtt_pub -t "zigbee2mqtt/$exact_name/set" -m "$PAYLOAD"
      say_duck "$PAYLOAD"   
    '') 
  ];  

  systemd.services.zigduck = {
    serviceConfig = {
      User = config.this.user.me.name;
      Group = config.this.user.me.name;
      StateDirectory = "zigduck";
      StateDirectoryMode = "0755";
    };
    preStart = ''
      if [ ! -f "${zigduckDir}/state.json" ]; then
        echo "{}" > "${zigduckDir}/state.json"
        chown ${config.this.user.me.name}:${config.this.user.me.name} "${zigduckDir}/state.json"
        chmod 644 "${zigduckDir}/state.json"
      fi
    
      mkdir -p "${zigduckDir}/timers"
      chown ${config.this.user.me.name}:${config.this.user.me.name} "${zigduckDir}/timers"
      chmod 755 "${zigduckDir}/timers"
    '';
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/zigduck 0755 ${config.this.user.me.name} ${config.this.user.me.name} - -"
    "d /var/lib/zigduck/timers 0755 ${config.this.user.me.name} ${config.this.user.me.name} - -"
    "f /var/lib/zigduck/state.json 0644 ${config.this.user.me.name} ${config.this.user.me.name} - -"
  ];




  # 🦆 says ⮞ let's do some ducktastic decryption magic into yaml files before we boot services up duck duck yo
  systemd.services.zigbee2mqtt = lib.mkIf (lib.elem "zigduck" config.this.host.modules.services) {
    wantedBy = [ "multi-user.target" ];
    after = [ "sops-nix.service" "network.target" ];
    environment.ZIGBEE2MQTT_DATA = "/var/lib/zigbee";
    preStart = '' 
      mkdir -p ${config.services.zigbee2mqtt.dataDir}    
      # 🦆 says ⮞ our real mosquitto password quack quack
      mosquitto_password=$(cat ${config.sops.secrets.z2m_mosquitto.path}) 
      # 🦆 says ⮞ Injecting password into config...
      sed -i "s|/run/secrets/mosquitto|$mosquitto_password|" ${config.services.zigbee2mqtt.dataDir}/configuration.yaml  
      # 🦆 says ⮞ da real zigbee network key boom boom quack quack yo yo
      TMPFILE="${config.services.zigbee2mqtt.dataDir}/tmp.yaml"
      CFGFILE="${config.services.zigbee2mqtt.dataDir}/configuration.yaml"
      # 🦆 says ⮞ starting awk decryption magic..."
      ${pkgs.gawk}/bin/awk -v keyfile="${config.sops.secrets.z2m_network_key.path}" '
        /(^|[[:space:]])network_key:/ { found = 1 }

        { lines[NR] = $0 }

        END {
          if (found) {
            for (i = 1; i <= NR; i++) print lines[i]
          } else {
            print lines[1]
            print "  network_key:"
            while ((getline line < keyfile) > 0) {
              print "    " line
            }
            close(keyfile)
            for (i = 2; i <= NR; i++) print lines[i]
          }
        }
      ' "$CFGFILE" > "$TMPFILE"      
      mv "$TMPFILE" "$CFGFILE"
    ''; # 🦆 says ⮞ thnx fo quackin' along!
  };} # 🦆 says ⮞ sleep tight!
# 🦆 says ⮞ QuackHack-McBLindy out!
# ... 🛌🦆💤
