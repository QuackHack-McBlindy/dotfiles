# dotfiles/bin/home/zigduck-rs.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
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
  mqttAuth = "-u mqtt -P $(cat ${config.house.zigbee.mosquitto.passwordFile})";

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

    #[derive(Debug, Clone, Serialize, Deserialize)]
    struct Condition {
        #[serde(rename = "type")]
        condition_type: String,
        room: Option<String>,
        value: Option<bool>,
    }

    #[derive(Debug, Clone, Serialize, Deserialize)]
    #[serde(untagged)]
    enum ScheduleConfig {
        Cron(String),
        TimeRange {
            start: Option<String>,
            end: Option<String>,
            days: Vec<String>,
        },
    }

    #[derive(Debug, Clone, Serialize, Deserialize)]
    struct TimeBasedAutomation {
        enable: bool,
        description: String,
        schedule: TimeRangeSchedule,
        conditions: Vec<Condition>,
        actions: Vec<AutomationAction>,
    }


    #[derive(Debug, Clone, Serialize, Deserialize)]
    struct PresenceBasedAutomation {
        enable: bool,
        description: String,
        motion_sensors: Vec<String>,
        no_motion_duration: u64,
        conditions: Vec<Condition>,
        actions: Vec<AutomationAction>,
        motion_restored_actions: Vec<AutomationAction>,
    }

    // 🦆 says ⮞ MQTT triggered automations
    #[derive(Debug, Clone, Serialize, Deserialize)]
    struct MqttTriggeredAutomation {
        enable: bool,
        description: String,
        topic: String,
        message: Option<String>,
        conditions: Vec<Condition>,
        actions: Vec<AutomationAction>,
    }

    #[derive(Debug, Clone, Serialize, Deserialize)]
    struct TimeRangeSchedule {
        start: Option<String>,
        end: Option<String>,
        days: Vec<String>,
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
        automations: AutomationConfig,
        dark_time_enabled: bool,
        motion_tracker: MotionTracker,
        processing_times: HashMap<String, u128>,
        message_counts: HashMap<String, u64>,
        total_messages: u64,
        debug: bool,
    }


    // 🦆 says ⮞ automation types
    #[derive(Debug, Clone, Serialize, Deserialize)]
        struct AutomationConfig {
        dimmer_actions: HashMap<String, RoomDimmerActions>,
        room_actions: HashMap<String, HashMap<String, Vec<AutomationAction>>>,
        global_actions: HashMap<String, Vec<AutomationAction>>,
        time_based: HashMap<String, TimeBasedAutomation>,
        presence_based: HashMap<String, PresenceBasedAutomation>,
        mqtt_triggered: HashMap<String, MqttTriggeredAutomation>,
    }


    // 🦆 says ⮞ room specific dimmer actions
    #[derive(Debug, Clone, Serialize, Deserialize)]
    struct RoomDimmerActions {
        on_press_release: Option<DimmerAction>,
        on_hold_release: Option<DimmerAction>,
        off_press_release: Option<DimmerAction>,
        off_hold_release: Option<DimmerAction>,
        up_press_release: Option<DimmerAction>,
        up_hold_release: Option<DimmerAction>,
        down_press_release: Option<DimmerAction>,
        down_hold_release: Option<DimmerAction>,
    }

    #[derive(Debug, Clone, Serialize, Deserialize)]
    struct DimmerAction {
        enable: bool,
        description: String,
        extra_actions: Vec<AutomationAction>,
        #[serde(default)]
        override_actions: Vec<AutomationAction>,
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
    
    #[derive(Debug, Clone)]
    struct MotionTracker {
        last_motion: HashMap<String, SystemTime>,
    }
   
    impl ZigduckState {
        // 🦆 says ⮞ handle MQTT triggered automations
        async fn check_mqtt_triggered_automations(&self, topic: &str, payload: &str) -> Result<(), Box<dyn std::error::Error>> {
            for (name, automation) in &self.automations.mqtt_triggered {
                if !automation.enable {
                    continue;
                }
                // 🦆 says ⮞ check if topic matches
                if topic == automation.topic {
                    // 🦆 says ⮞ check if message matches (if specified)
                    if let Some(expected_msg) = &automation.message {
                        if payload != expected_msg {
                            continue;
                        }
                    }
                    // 🦆 says ⮞ check conditions
                    if self.check_conditions(&automation.conditions).await {
                        self.quack_info(&format!("Triggering MQTT automation: {}", automation.description));
                        for action in &automation.actions {
                            if let Err(e) = self.execute_automation_action_mqtt(action, "mqtt_triggered", "global", topic, payload) {
                                self.quack_debug(&format!("Error executing MQTT automation action: {}", e));
                            }
                        }
                    }
                }
            }
            Ok(())
        }
    
        async fn start_periodic_checks(&self) {
            let state = self.clone();
            tokio::spawn(async move {
                let mut interval = tokio::time::interval(Duration::from_secs(60)); // Check every minute
                loop {
                    interval.tick().await;
                    state.check_presence_automations().await;
                    state.check_time_based_automations().await; // Add this too
                }
            });
        }

        async fn check_time_based_automations(&self) {
            for (name, automation) in &self.automations.time_based {
                if !automation.enable { continue; }         
                let schedule_matches = self.check_time_range(
                    &automation.schedule.start, 
                    &automation.schedule.end, 
                    &automation.schedule.days
                ).await;
            
                if schedule_matches && self.check_conditions(&automation.conditions).await {
                    for action in &automation.actions {
                        if let Err(e) = self.execute_automation_action(action, "time_based", "global") {
                            self.quack_debug(&format!("Error executing time-based automation: {}", e));
                        }
                    }
                }
            }
        }

        async fn check_time_range(&self, start: &Option<String>, end: &Option<String>, days: &[String]) -> bool {
            let now = Local::now();    
            let current_day = now.format("%a").to_string().to_lowercase();
            if !days.iter().any(|day| day == &current_day) {
                return false;
            }
        
            if let (Some(start_str), Some(end_str)) = (start, end) {
                if let (Ok(start_time), Ok(end_time)) = (
                    chrono::NaiveTime::parse_from_str(start_str, "%H:%M"),
                    chrono::NaiveTime::parse_from_str(end_str, "%H:%M")
                ) {
                    let current_time = now.time();
                    return current_time >= start_time && current_time <= end_time;
                }
            }
        
            if let Some(start_str) = start {
                if let Ok(start_time) = chrono::NaiveTime::parse_from_str(start_str, "%H:%M") {
                    if now.time() < start_time {
                        return false;
                    }
                }
            }
        
            if let Some(end_str) = end {
                if let Ok(end_time) = chrono::NaiveTime::parse_from_str(end_str, "%H:%M") {
                    if now.time() > end_time {
                        return false;
                    }
                }
            }     
            true
        }
        async fn check_conditions(&self, conditions: &[Condition]) -> bool {
            for condition in conditions {
                if !self.check_condition(condition).await {
                    return false;
                }
            }
            true
        }

        async fn check_condition(&self, condition: &Condition) -> bool {
            match condition.condition_type.as_str() {
                "dark_time" => self.is_dark_time(),
                "someone_home" => {
                    if let Some(expected_value) = condition.value {
                        self.is_someone_home() == expected_value
                    } else {
                        // 🦆 says ⮞ default true when someone home
                        self.is_someone_home()
                    }
                }
                "room_occupied" => {
                    if let Some(room) = &condition.room {
                        self.is_motion_triggered(room) || self.has_recent_motion_in_room(room)
                    } else {
                        false
                    }
                }
                _ => false,
            }
        }

        async fn check_presence_automations(&self) {
            for (name, automation) in &self.automations.presence_based {
                if !automation.enable { continue; }
                let all_no_motion = automation.motion_sensors.iter().all(|sensor| {
                    if let Some(last_motion) = self.motion_tracker.last_motion.get(sensor) {
                        let duration = SystemTime::now().duration_since(*last_motion).unwrap();
                        duration.as_secs() >= automation.no_motion_duration
                    } else {
                        false
                    }
                });
        
                if all_no_motion && self.check_conditions(&automation.conditions).await {
                    for action in &automation.actions {
                        if let Err(e) = self.execute_automation_action(action, "presence_based", "global") {
                            self.quack_debug(&format!("Error executing presence automation: {}", e));
                        }
                    }
                }
            }
        }
    
        fn update_motion_tracker(&mut self, sensor_name: &str) {
            self.motion_tracker.last_motion.insert(sensor_name.to_string(), SystemTime::now());
        }

        // 🦆 says ⮞ handle room specific dimmer actions
        fn handle_room_dimmer_action<F>(
            &self, 
            action: &str, 
            device_name: &str, 
            room: &str,
            default_action: F
        ) -> Result<(), Box<dyn std::error::Error>> 
        where
            F: FnOnce(&str) -> Result<(), Box<dyn std::error::Error>>,
        {
            let mut executed = false;
            let mut default_action = Some(default_action); // 🦆 NEW: Wrap in Option to control ownership
            
            // 🦆 says ⮞ load room specific config
            if let Some(room_actions) = self.automations.dimmer_actions.get(room) {
                let dimmer_action = match action {
                    "on_press_release" => &room_actions.on_press_release,
                    "on_hold_release" => &room_actions.on_hold_release,
                    "off_press_release" => &room_actions.off_press_release,
                    "off_hold_release" => &room_actions.off_hold_release,
                    "up_press_release" => &room_actions.up_press_release,
                    "up_hold_release" => &room_actions.up_hold_release,
                    "down_press_release" => &room_actions.down_press_release,
                    "down_hold_release" => &room_actions.down_hold_release,
                    _ => &None,
                };
                
                if let Some(config) = dimmer_action {
                    if config.enable {
                        if !config.override_actions.is_empty() {
                            // 🦆 says ⮞ run only the override actions
                            self.quack_debug(&format!("Running override actions for {} in {}", action, room));
                            for override_action in &config.override_actions {
                                self.execute_automation_action(override_action, device_name, room)?;
                            }
                            executed = true;
                        } else {
                            // 🦆 says ⮞ if no overrides - default + extra actions
                            self.quack_debug(&format!("Running default + extra actions for {} in {}", action, room));
                            if let Some(action_fn) = default_action.take() {
                                action_fn(room)?;
                            }
                            for extra_action in &config.extra_actions {
                                self.execute_automation_action(extra_action, device_name, room)?;
                            }
                            executed = true;
                        }
                    } else {
                        // 🦆 says ⮞ if none of the above - actions disabled 
                        self.quack_debug(&format!("Actions disabled for {} in {}", action, room));
                        executed = true;
                    }
                }
            }
            
            // 🦆 says ⮞ check default configuration
            if !executed {
                if let Some(default_actions) = self.automations.dimmer_actions.get("_default") {
                    let dimmer_action = match action {
                        "on_press_release" => &default_actions.on_press_release,
                        "on_hold_release" => &default_actions.on_hold_release,
                        "off_press_release" => &default_actions.off_press_release,
                        "off_hold_release" => &default_actions.off_hold_release,
                        "up_press_release" => &default_actions.up_press_release,
                        "up_hold_release" => &default_actions.up_hold_release,
                        "down_press_release" => &default_actions.down_press_release,
                        "down_hold_release" => &default_actions.down_hold_release,
                        _ => &None,
                    };
                    
                    if let Some(config) = dimmer_action {
                        if config.enable {
                            if !config.override_actions.is_empty() {
                                self.quack_debug(&format!("Running default override actions for {}", action));
                                for override_action in &config.override_actions {
                                    self.execute_automation_action(override_action, device_name, room)?;
                                }
                                executed = true;
                            } else {
                                self.quack_debug(&format!("Running default actions for {}", action));
                                if let Some(action_fn) = default_action.take() {
                                    action_fn(room)?;
                                }
                                for extra_action in &config.extra_actions {
                                    self.execute_automation_action(extra_action, device_name, room)?;
                                }
                                executed = true;
                            }
                        }
                    }
                }
            }
            
            // 🦆 says ⮞ no configuration - run default action
            if !executed {
                self.quack_debug(&format!("🏃 Running fallback default for {} in {}", action, room));
                if let Some(action_fn) = default_action.take() {
                    action_fn(room)?;
                }
            }   
            Ok(())
        }
      
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
       
            // 🦆 says ⮞ load automations configuration
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
                        time_based: HashMap::new(),
                        mqtt_triggered: HashMap::new(),
                        presence_based: HashMap::new(),
                    }
                });
        
                let motion_tracker = MotionTracker {
                    last_motion: HashMap::new(),
                }; 

                       
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
                    motion_tracker,
                   // room_occupancy,
                   // presence_state,
                   // last_presence_update,
                    debug,
                }
            }
   
        // 🦆 says ⮞ TODO
        fn activate_scene(&self, scene_name: &str) -> Result<(), Box<dyn std::error::Error>> {
            let output = Command::new("yo")
                .arg("house")
                .arg("--scene")
                .arg(scene_name)
                .output()?;
    
            if !output.status.success() {
                let error_msg = format!(
                    "Failed to activate scene '{}': {}",
                    scene_name,
                    String::from_utf8_lossy(&output.stderr)
                );
                self.quack_info(&error_msg);
                return Err(error_msg.into());
            }
            self.quack_info(&format!("Activated scene: {}", scene_name));
            Ok(())
        }
   
        // 🦆 says ⮞ duckTrace - quack loggin' be bitchin'
        fn quack_debug(&self, msg: &str) {
            if self.debug {
                let log_msg = format!("[🦆📜] ⁉️DEBUG⁉️ ⮞ {}", msg);
                eprintln!("{}", log_msg);
                // 🦆 says ⮞ debug mode? write 2 duckTrace 
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
            // 🦆 says ⮞ always write info 2 duckTrace
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
            // 🦆 says ⮞ load automations from Nix config        
            match automation_type {
                "motion" => {
                    if let Some(actions) = self.automations.room_actions.get(room) {
                        if let Some(motion_actions) = actions.get(trigger) {
                            for action in motion_actions {
                                self.execute_automation_action(action, device_name, room)?;
                            }
                        }
                    }
                }
                "contact" => {
                    if let Some(actions) = self.automations.room_actions.get(room) {
                        if let Some(contact_actions) = actions.get(trigger) {
                            for action in contact_actions {
                                self.execute_automation_action(action, device_name, room)?;
                            }
                        }
                    }
                }
                "water_leak" => {
                    if let Some(actions) = self.automations.global_actions.get(trigger) {
                        for action in actions {
                            self.execute_automation_action(action, device_name, room)?;
                        }
                    }
                }
                "smoke" => {
                    if let Some(actions) = self.automations.global_actions.get(trigger) {
                        for action in actions {
                            self.execute_automation_action(action, device_name, room)?;
                        }
                    }
                }
                _ => {}
            }
            Ok(())
        }


        fn execute_automation_action_mqtt(&self, action: &AutomationAction, device_name: &str, room: &str, topic: &str, payload: &str) -> Result<(), Box<dyn std::error::Error>> {     
            self.quack_debug(&format!("Executing automation action for {} in {}", device_name, room));
    
            // 🦆 says ⮞ set MQTT environment variables for shell actions
            unsafe { std::env::set_var("AUTOMATION_DEVICE", device_name); }
            unsafe { std::env::set_var("AUTOMATION_ROOM", room); }
            unsafe { std::env::set_var("MQTT_TOPIC", topic); }
            unsafe { std::env::set_var("MQTT_PAYLOAD", payload); }
            unsafe { std::env::set_var("MQTT_DEVICE", device_name); }
            unsafe { std::env::set_var("MQTT_ROOM", room); }
    
            if let Ok(data) = serde_json::from_str::<serde_json::Value>(payload) {
                if let Some(action_val) = data.get("action").and_then(|v| v.as_str()) {
                    unsafe { std::env::set_var("MQTT_ACTION", action_val); }
                }
                if let Some(state_val) = data.get("state").and_then(|v| v.as_str()) {
                    unsafe { std::env::set_var("MQTT_STATE", state_val); }
                }
            }
    
            match action {
                AutomationAction::Simple(cmd) => {
                    // 🦆 says ⮞ execute shell command with environment
                    let output = std::process::Command::new("sh")
                        .arg("-c")
                        .arg(cmd)
                        .env("AUTOMATION_DEVICE", device_name)
                        .env("AUTOMATION_ROOM", room)
                        .output()?;
            
                    if !output.status.success() {
                        self.quack_debug(&format!("Shell command failed: {}", String::from_utf8_lossy(&output.stderr)));
                    }
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
                                let output = std::process::Command::new("sh")
                                    .arg("-c")
                                    .arg(cmd)
                                    .env("AUTOMATION_DEVICE", device_name)
                                    .env("AUTOMATION_ROOM", room)
                                    .output()?;
                        
                                if !output.status.success() {
                                    self.quack_debug(&format!("Shell command failed: {}", String::from_utf8_lossy(&output.stderr)));
                                }
                            }
                        }
                        "scene" => {
                            if let Some(scene_name) = &action_config.scene {
                                self.activate_scene(scene_name)?;
                            }
                        }
                        _ => {}
                    }
                }
            }
            Ok(())
        } 
 
        fn execute_automation_action(&self, action: &AutomationAction, device_name: &str, room: &str) -> Result<(), Box<dyn std::error::Error>> {        
            self.quack_debug(&format!("Executing automation action for {} in {}", device_name, room));
    
            // 🦆 says ⮞ set MQTT environment variables for shell actions
            unsafe { std::env::set_var("AUTOMATION_DEVICE", device_name); }
            unsafe { std::env::set_var("AUTOMATION_ROOM", room); }
       
            match action {
                AutomationAction::Simple(cmd) => {
                    // 🦆 says ⮞ execute shell command with environment
                    let output = std::process::Command::new("sh")
                        .arg("-c")
                        .arg(cmd)
                        .env("AUTOMATION_DEVICE", device_name)
                        .env("AUTOMATION_ROOM", room)
                        .output()?;
            
                    if !output.status.success() {
                        self.quack_debug(&format!("Shell command failed: {}", String::from_utf8_lossy(&output.stderr)));
                    }
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
                                let output = std::process::Command::new("sh")
                                    .arg("-c")
                                    .arg(cmd)
                                    .env("AUTOMATION_DEVICE", device_name)
                                    .env("AUTOMATION_ROOM", room)
                                    .output()?;
                        
                                if !output.status.success() {
                                    self.quack_debug(&format!("Shell command failed: {}", String::from_utf8_lossy(&output.stderr)));
                                }
                            }
                        }
                        "scene" => {
                            if let Some(scene_name) = &action_config.scene {
                                self.activate_scene(scene_name)?;
                            }
                        }
                        _ => {}
                    }
                }
            }
            Ok(())
        }
        
        // 🦆 says ⮞ check if someone is home
        fn is_someone_home(&self) -> bool {
            let current_time = SystemTime::now().duration_since(UNIX_EPOCH).unwrap().as_secs();
            let last_motion_str = self.get_state("apartment", "last_motion").unwrap_or_else(|| "0".to_string());
            let last_motion: u64 = last_motion_str.parse().unwrap_or(0);
            let time_diff = current_time.saturating_sub(last_motion);
            time_diff <= ${config.house.zigbee.automations.greeting.awayDuration}
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
    
        // 🦆 says ⮞ STATE UPDATES
        fn update_device_state_from_data(&self, device_name: &str, data: &Value) -> Result<(), Box<dyn std::error::Error>> {
            // 🦆 says ⮞ skip set/availability topics
            if device_name.ends_with("/set") || device_name.ends_with("/availability") {
                self.quack_debug(&format!("Skipping state update for {} (set/availability topic)", device_name));
                return Ok(());
            }
    
            self.quack_debug(&format!("Updating all state fields for: {}", device_name));
    
            // 🦆 says ⮞ extract ALL fields
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
            // 🦆 says ⮞ update last_seen
            let timestamp = SystemTime::now().duration_since(UNIX_EPOCH).unwrap().as_secs();
            self.update_device_state(device_name, "last_updated", &timestamp.to_string())?;
            
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
            // after🦆16:00⮞before⮜09:00🦆 
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

        // 🦆 says ⮞ track motion-triggered lights
        fn set_motion_triggered(&self, room: &str, triggered: bool) -> Result<(), Box<dyn std::error::Error>> {
            let motion_file = format!("{}/motion_triggered.json", self.state_dir);
            let content = fs::read_to_string(&motion_file).unwrap_or_else(|_| "{}".to_string());
            let mut motion_state: Value = serde_json::from_str(&content).unwrap_or_else(|_| json!({}));    
            motion_state[room] = Value::Bool(triggered);
            fs::write(&motion_file, motion_state.to_string())?;
            Ok(())
        }

        fn is_motion_triggered(&self, room: &str) -> bool {
            let motion_file = format!("{}/motion_triggered.json", self.state_dir);
            let content = fs::read_to_string(&motion_file).unwrap_or_else(|_| "{}".to_string());
            let motion_state: Value = serde_json::from_str(&content).unwrap_or_else(|_| json!({}));
            motion_state[room].as_bool().unwrap_or(false)
        }
    
        // 🦆 says ⮞ ALL LIGHTS CONTROLLER
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

        // 🦆 says ⮞ check if has been any motion in a room
        fn has_recent_motion_in_room(&self, room: &str) -> bool {
            let motion_timeout = Duration::from_secs(300); // 5 minutes

            for (sensor_name, last_motion) in &self.motion_tracker.last_motion {
                if let Some(device) = self.devices.get(sensor_name) {
                    if device.room == room {
                        if let Ok(elapsed) = SystemTime::now().duration_since(*last_motion) {
                            if elapsed < motion_timeout {
                                return true;
                            }
                        }
                    }
                }
            }
            false
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
            
            // 🦆 says ⮞ MQTT TRIGGERED AUTOMATIONS
            if let Err(e) = self.check_mqtt_triggered_automations(topic, payload).await {
                self.quack_debug(&format!("Error checking MQTT automations: {}", e));
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
    
            if payload == "\"LEFT\"" {
                // 🦆 says ⮞ turn on security
                self.set_larmed(true)?;
                return Ok(());
            } else if payload == "\"RETURN\"" {
                // 🦆 says ⮞ home again? turn off security
                self.set_larmed(false)?;
                return Ok(());
            }
            
            // 🦆 says ⮞ TV COMMAND
            if topic == "zigbee2mqtt/tvCommand" {
                if let Some(tv_command) = data["tvCommand"].as_str() {
                    if let Some(ip) = data["ip"].as_str() {
                        self.quack_info(&format!("TV command received! Command: {}. IP: {}", tv_command, ip));
                        self.run_yo_command(&["tv", "--typ", tv_command, "--device", ip])?;
                    }
                }
                return Ok(());
            }
    
            let device_name = topic.strip_prefix("zigbee2mqtt/").unwrap_or(topic);
    
            // 🦆 says ⮞ STATE UPDATES
            if let Err(e) = self.update_device_state_from_data(device_name, &data) {
                self.quack_debug(&format!("Failed to update device state: {}", e));
            }
    
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
                        self.execute_automations("smoke", "smoke_detected", device_name, room)?;
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
                        
                        self.execute_automations("motion", "motion_detected", device_name, room)?;
                        // 🦆 says ⮞ & update state file yo
                        let timestamp = SystemTime::now().duration_since(UNIX_EPOCH).unwrap().as_secs();
                        self.update_device_state("apartment", "last_motion", &timestamp.to_string())?;
                        
                        if self.is_dark_time() { // 🦆 says ⮞ motion & iz dark? turn room lightsz on cool & timer to power off again 
                            self.set_motion_triggered(room, true)?; 
                            self.room_lights_on(room)?;
                        } else { // 🦆 says ⮞ daytime? lightz no thnx
                            self.quack_debug("❌ Daytime - no lights activated by motion.");
                        }
                    } else { // 🦆 says ⮞ no more movementz update state file yo
                        self.quack_debug(&format!("🛑 No more motion in {} {}", device_name, room));
                        self.execute_automations("motion", "motion_not_detected", device_name, room)?;
                        // 🦆 says ⮞ motion stopped - check if we should turn off lights
                        if self.is_motion_triggered(room) {
                            self.quack_debug(&format!("⏰ Motion stopped in {}, will turn off lights in 900s", room));
                            let room_clone = room.to_string();
                            let state_clone = std::sync::Arc::new(self.clone());        
                            tokio::spawn(async move {
                                tokio::time::sleep(Duration::from_secs(${config.house.zigbee.darkTime.duration})).await;            
                                // 🦆 says ⮞ still no motion? lightz off 
                                if state_clone.is_motion_triggered(&room_clone) {
                                    state_clone.quack_debug(&format!("💡 Turning off motion-triggered lights in {}", room_clone));
                                    let _ = state_clone.room_lights_off(&room_clone);
                                    let _ = state_clone.set_motion_triggered(&room_clone, false);
                                }
                            });                     
                        }
                    }
                }
    
                // 🦆 says ⮞ 💧 WATER SENSORS
                if data["water_leak"].as_bool() == Some(true) || data["waterleak"].as_bool() == Some(true) {
                    self.quack_info(&format!("💧 WATER LEAK DETECTED in {} on {}", room, device_name));
                    self.execute_automations("water_leak", "leak_detected", device_name, room)?;
                }

                // 🦆 says ⮞ DOOR / WINDOW SENSOR
                if let Some(contact) = data["contact"].as_bool() {
                    if !contact {
                        self.quack_info(&format!("🚪 Door open in {} ({})", room, device_name));
                        self.execute_automations("contact", "door_opened", device_name, room)?;
                        // 🦆 says ⮞ check time & where last motion iz
                        let current_time = SystemTime::now().duration_since(UNIX_EPOCH).unwrap().as_secs();
                        let last_motion_str = self.get_state("apartment", "last_motion").unwrap_or_else(|| "0".to_string());
                        let last_motion: u64 = last_motion_str.parse().unwrap_or(0);
                        let time_diff = current_time.saturating_sub(last_motion); 
                        self.quack_debug(&format!("TIME: {} | LAST MOTION: {} | TIME DIFF: {}", current_time, last_motion, time_diff));
                        
                        if time_diff > ${config.house.zigbee.automations.greeting.awayDuration} { // 🦆 says ⮞ secondz
                            self.quack_info("Welcoming you home! (no motion for 2 hours, door opened)");
                            tokio::time::sleep(Duration::from_secs(${config.house.zigbee.automations.greeting.delay})).await;
                            self.run_yo_command(&["say", "--text", "${config.house.zigbee.automations.greeting.greeting}", "--host", "${config.house.zigbee.automations.greeting.sayOnHost}"])?; // 🦆 says ⮞ ='(
                        } else { 
                            self.quack_debug(&format!("🛑 NOT WELCOMING:🛑 only {} minutes since last motion", time_diff / 60));
                        }
                    } else { // 🦆 says ⮞ door closed  
                        self.execute_automations("contact", "door_closed", device_name, room)?;
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
                    match action {
                        "on_press_release" => {
                            self.handle_room_dimmer_action(action, device_name, room, |room| {
                                self.quack_info(&format!("💡 Turning on lights in {}", room));
                                self.room_lights_on(room)
                            })?;
                        }
                        "on_hold_release" => {
                            self.handle_room_dimmer_action(action, device_name, room, |_| {
                                self.control_all_lights("ON", Some(255))?;
                                self.quack_info("✅💡 MAX LIGHTS ON");
                                Ok(())
                            })?;
                        }
                        "off_press_release" => {
                            self.handle_room_dimmer_action(action, device_name, room, |room| {
                                self.quack_info(&format!("💡 Turning off lights in {}", room));
                                self.room_lights_off(room)
                            })?;
                        }
                        "off_hold_release" => {
                            self.handle_room_dimmer_action(action, device_name, room, |_| {
                                self.control_all_lights("OFF", None)?;
                                self.quack_info("🦆 DARKNESS ON");
                                Ok(())
                            })?;
                        }
                        "up_press_release" => {
                            self.handle_room_dimmer_action(action, device_name, room, |room| {
                                for (light_id, light_device) in &self.devices {
                                    if light_device.room == room && light_device.device_type == "light" {
                                        self.quack_info(&format!("🔺 Increasing brightness on {} in {}", light_id, room));
                                        let message = json!({
                                            "brightness_step": 50,
                                            "transition": 3.5
                                        });
                                        let topic = format!("zigbee2mqtt/{}/set", light_id);
                                        self.mqtt_publish(&topic, &message.to_string())?;
                                    }
                                }
                                Ok(())
                            })?;
                        }
                        "down_press_release" => {
                            self.handle_room_dimmer_action(action, device_name, room, |room| {
                                for (light_id, light_device) in &self.devices {
                                    if light_device.room == room && light_device.device_type == "light" {
                                        self.quack_info(&format!("🔻 Decreasing {} in {}", light_id, room));
                                        let message = json!({
                                            "brightness_step": -50,
                                            "transition": 3.5
                                        });
                                        let topic = format!("zigbee2mqtt/{}/set", light_id);
                                        self.mqtt_publish(&topic, &message.to_string())?;
                                    }
                                }
                                Ok(())
                            })?;
                        }
                        "up_hold_release" | "down_hold_release" => {
                            // 🦆 says ⮞ up/down_hold_release have no default actions
                            self.handle_room_dimmer_action(action, device_name, room, |_| {
                                self.quack_debug(&format!("{} in {}", action, room));
                                Ok(())
                            })?;
                        }
                        _ => {
                            self.quack_debug(&format!("Unhandled dimmer action: {}", action));
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
    
            }
    
            let duration = start_time.elapsed().as_millis();
            self.update_performance_stats(topic, duration); 
            Ok(())
        }
    
        async fn start_listening(&mut self) -> Result<(), Box<dyn std::error::Error>> {
            self.quack_info("🚀 Starting ZigDuck automation system");
            self.quack_info("📡 Listening to all Zigbee events...");
            self.start_periodic_checks().await;
            let mut mqttoptions = MqttOptions::new("zigduck-rs", &self.mqtt_broker, 1883);
            mqttoptions.set_credentials(&self.mqtt_user, &self.mqtt_password);
            mqttoptions.set_keep_alive(Duration::from_secs(5));
            // 🦆 says ⮞ max packet size if larger payloads
            mqttoptions.set_max_packet_size(256 * 1024, 256 * 1024); // 🦆 says ⮞ 256KB
    
            let (mut client, mut connection) = Client::new(mqttoptions, 10);
            client.subscribe("zigbee2mqtt/#", QoS::AtMostOnce)?;
    
            self.quack_info(&format!("Connected to MQTT broker: {}", &self.mqtt_broker));
            self.quack_info("[🦆🏡] ⮞ Welcome Home");
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
        // 🦆 says ⮞ get configuration from env var
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
            .unwrap_or(true);
                
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

  #environment.variables."MQTT_BROKER" = mqttHostip;
  #environment.variables."MQTT_USER" = config.house.zigbee.mosquitto.username;
  #environment.variables."pwfile" = config.house.zigbee.mosquitto.passwordFile;
  environment.variables."ZIGBEE_DEVICES" = deviceMeta;
  environment.variables."ZIGBEE_DEVICES_FILE" = devices-json;
  environment.variables."AUTOMATIONS_FILE" = automationsFile;
  environment.variables."DARK_TIME_ENABLED" = darkTimeEnabled;
  
in { # 🦆 says ⮞ finally here, quack! 
  yo.scripts.zigduck-rs = {
    description = "[🦆🏡] ZigDuck - Home automation system! Devices, scenes, automations -- EVERYTHING is defined using Nix options from the module 'house.nix'. (Written in Rust)";
    category = "🛖 Home Automation"; # 🦆 says ⮞ thnx for following me home
    logLevel = "INFO";
    autoStart = config.this.host.hostname == "homie"; # 🦆 says ⮞ dat'z sum conditional quack-fu yo!
    parameters = [ # 🦆 says ⮞ set your mosquitto user & password
      { name = "dir"; description = "Directory path to compile in"; default = "/home/pungkula/zigduck-rs"; optional = false; } 
      { name = "user"; description = "User which Mosquitto runs on"; default = "mqtt"; optional = false; }
      { name = "pwfile"; description = "Password file for Mosquitto user"; optional = false; default = config.sops.secrets.mosquitto.path; }
    ];
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
    code = ''
      ${cmdHelpers}
      MQTT_BROKER="${mqttHostip}"

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
        while true; do
          # 🦆 says ⮞ keep me alive plx
          DEBUG=1 ZIGBEE_DEVICES='${deviceMeta}' ZIGBEE_DEVICES_FILE="${devices-json}" AUTOMATIONS_FILE="${automationsFile}" DARK_TIME_ENABLED="${darkTimeEnabled}" DT_LOG_FILE_PATH="$DT_LOG_PATH$DT_LOG_FILE" ./target/release/zigduck-rs
          EXIT_CODE=$?
          dt_error "zigduck-rs exited with code $EXIT_CODE, restarting in 3 seconds..."
          sleep 3
       done
      fi  
      # 🦆 says ⮞ keep me alive plx
      while true; do
        # 🦆 says ⮞ else run debugless yo
        ZIGBEE_DEVICES='${deviceMeta}' ZIGBEE_DEVICES_FILE="${devices-json}" AUTOMATIONS_FILE="${automationsFile}" DARK_TIME_ENABLED="${darkTimeEnabled}" DT_LOG_FILE_PATH="$DT_LOG_PATH$DT_LOG_FILE" ./target/release/zigduck-rs
        EXIT_CODE=$?
        dt_error "zigduck-rs exited with code $EXIT_CODE, restarting in 3 seconds..."
        sleep 3
      done         
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
        users.mqtt.passwordFile = config.house.zigbee.mosquitto.passwordFile;
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
          user = config.house.zigbee.mosquitto.username;
          password = config.sops.secrets.mosquitto.path; # 🦆 says ⮞ no support for passwordFile?! sneaky duckiie use dis as placeholder lol
          base_topic = "zigbee2mqtt";
        };
        # 🦆 says ⮞ physical port mapping
        serial = { # 🦆 says ⮞ either USB port (/dev/ttyUSB0), network Zigbee adapters (tcp://192.168.1.1:6638) or mDNS adapter (mdns://my-adapter).       
         port = "/dev/" + config.house.zigbee.coordinator.symlink; # 🦆 says ⮞ all hosts, same serial port yo!
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
          availability = false;
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
  ];  

  systemd.services.zigduck-rs = {
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
    environment.ZIGBEE2MQTT_DATA = config.services.zigbee2mqtt.dataDir;
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
