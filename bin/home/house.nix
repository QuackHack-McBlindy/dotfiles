# dotfiles/bin/home/house.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ Rust CLI tool for controlling all smart home devices
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ...
}: let
  # 🦆 says ⮞ configuration directory for diz module
  zigduckDir = "/home/" + config.this.user.me.name + "/.config/zigduck";
  
  # 🦆 says ⮞ findz da mosquitto host
  mqttHost = let
    sysHosts = lib.attrNames self.nixosConfigurations;
    mqttHosts = lib.filter (host:
      let cfg = self.nixosConfigurations.${host}.config;
      in cfg.services.mosquitto.enable or false
    ) sysHosts;
  in
    if mqttHosts != [] then lib.head mqttHosts else null;

  # 🦆 says ⮞ get MQTT broker IP (fallback to localhost)
  mqttHostIp = if mqttHost != null
    then self.nixosConfigurations.${mqttHost}.config.this.host.ip or "127.0.0.1"
    else "127.0.0.1";

  # 🦆 says ⮞ define Zigbee devices here yo 
  zigbeeDevices = config.house.zigbee.devices;

  # 🦆 says ⮞ create devices json file
  devicesJson = builtins.toJSON (
    lib.mapAttrs (id: device: {
      friendly_name = device.friendly_name or id;
      room = device.room or "unknown";
      type = device.type or "unknown";
      endpoint = device.endpoint or 11;
      icon = device.icon or null;
      battery_type = device.batteryType or null;
      hue_id = device.hue_id or null;  # Include hue_id
    }) zigbeeDevices
  );


  # 🦆 SCREAMS ⮞ SCENES!!!111
  scenes = config.house.zigbee.scenes;

  # 🦆 says ⮞ generate scenes json
  scenesJson = builtins.toJSON (
    lib.mapAttrs (sceneName: sceneDevices: {
      friendly_name = sceneName;
      devices = sceneDevices;
    }) scenes
  );

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

  # 🦆 says ⮞ Filter to only include light devices
  lightDevices = lib.filterAttrs (_: device: device.type == "light") zigbeeDevices;

  # 🦆 says ⮞ case-insensitive device matching
  normalizedDeviceMap = lib.mapAttrs' (id: device:
    lib.nameValuePair (lib.toLower device.friendly_name) device.friendly_name
  ) zigbeeDevices;

  # 🦆 says ⮞ group devices by room
  roomDevicesMap = let
    grouped = lib.groupBy (device: device.room) (lib.attrValues zigbeeDevices);
  in lib.mapAttrs (room: devices: 
      map (d: d.friendly_name) devices
    ) grouped;

  # 🦆 says ⮞ device validation list
  deviceList = builtins.attrNames normalizedDeviceMap;

  # 🦆🚀🚀  rocket  ⮞ 🌙 
  zigduck-cli = pkgs.writeText "main.rs" ''    
    use std::process::Command;    
    use std::thread::sleep;
    use clap::{Parser, Subcommand, ValueEnum};
    use serde::{Deserialize, Serialize};
    use rumqttc::{Client, MqttOptions, QoS};
    use std::time::Duration;
    use anyhow::{Result, Context};
    use colored::*;
    use std::collections::HashMap;
    use std::fs;
    use std::path::PathBuf;
    
    #[derive(Parser)]
    #[command(
        name = "zigduck-cli",
        version = "1.0.0",
        author = "🦆 QuackHack-McBLindy",
        about = "High-performance Zigbee home automation controller",
        long_about = "Control Zigbee devices, scenes, and automations with Rust speed and reliability"
    )]
    struct Cli {
        #[command(subcommand)]
        command: Commands,
        
        #[arg(long, short, help = "MQTT broker host", env = "MQTT_BROKER", default_value = "127.0.0.1")]
        broker: String,
        
        #[arg(long, short = 'u', help = "MQTT username", env = "MQTT_USER", default_value = "mqtt")]
        user: String,
        
        #[arg(long, help = "MQTT password file", env = "MQTT_PASSWORD_FILE")]
        password_file: Option<PathBuf>,
        
        #[arg(long, help = "MQTT password", env = "MQTT_PASSWORD")]
        password: Option<String>,
        
        #[arg(long, short = 'v', action = clap::ArgAction::Count, help = "Verbosity level")]
        verbose: u8,
        
        #[arg(long, help = "Path to devices configuration", env = "DEVICES_CONFIG")]
        devices_config: Option<PathBuf>,
        
        #[arg(long, help = "Path to scenes configuration", env = "SCENES_CONFIG")]
        scenes_config: Option<PathBuf>,
        
        #[arg(long, help = "Hue Bridge IP", env = "HUE_BRIDGE_IP")]
        hue_bridge_ip: Option<String>,
    
        #[arg(long, help = "Hue Bridge API key", env = "HUE_API_KEY")]
        hue_api_key: Option<String>,        
    }
    
    #[derive(Subcommand)]
    enum Commands {
        // 🦆 says ⮞ control individual device
        Device {
            // 🦆 says ⮞ device name
            #[arg(short, long)]
            name: String,
        
            // 🦆 says ⮞ device state
            #[arg(short, long, value_enum)]
            state: DeviceState,
        
            // 🦆 says ⮞ brightness percentage
            #[arg(short, long)]
            brightness: Option<u8>,
        
            // 🦆 says ⮞ color name or hex code
            #[arg(short, long)]
            color: Option<String>,
        
            // 🦆 says ⮞ color temperature
            #[arg(short = 't', long)]
            temperature: Option<u16>,
        
            // 🦆 says ⮞ transition time in seconds
            #[arg(short = 'T', long)]
            transition: Option<f32>,
        },
        
        // 🦆 says ⮞ control all devices in a room
        Room {
            // 🦆 says ⮞ room name
            #[arg(short, long)]
            name: String,
            
            // 🦆 says ⮞ room state
            #[arg(value_enum)]
            state: DeviceState,
            
            // 🦆 says ⮞ brightness percentage
            #[arg(short, long)]
            brightness: Option<u8>,
            
            // 🦆 says ⮞ color name or hex code
            #[arg(short, long)]
            color: Option<String>,
            
            // 🦆 says ⮞ color temperature
            #[arg(short = 't', long)]
            temperature: Option<u16>,
        },
        
        // 🦆 says ⮞ activate scene
        Scene {
            // 🦆 says ⮞ scene name
            name: String,
            
            // 🦆 says ⮞ random scene if no provided
            #[arg(short, long, default_value_t = false)]
            random: bool,
        },
        
        // 🦆 says ⮞ enter pairing mode for new devices
        Pair {
            // 🦆 says ⮞ pairing duration in seconds
            #[arg(short, long, default_value_t = 120)]
            duration: u16,
            
            // 🦆 says ⮞ watch for new devices
            #[arg(short, long, default_value_t = false)]
            watch: bool,
        },
        
        // 🦆 says ⮞ control all lights
        AllLights {
            // 🦆 says ⮞ all lights state
            #[arg(value_enum)]
            state: DeviceState,            
            // 🦆 says ⮞ brightness percentage
            #[arg(short, long)]
            brightness: Option<u8>,            
            // 🦆 says ⮞ color name or hex code
            #[arg(short, long)]
            color: Option<String>,
        },
        
        // 🦆 says ⮞ List available devices, rooms, or scenes
        List {
            // 🦆 says ⮞ what to list
            #[arg(value_enum)]
            what: ListType,            
            // 🦆 says ⮞ output as JSON
            #[arg(short, long, default_value_t = false)]
            json: bool,
        },
        
        // 🦆 says ⮞ energy saving mode - turn off lights after delay
        CheapMode {
            // 🦆 says ⮞ room name
            room: String,            
            // 🦆 says ⮞ delay in seconds before turning off
            #[arg(short, long, default_value_t = 300)]
            delay: u64,
        },
    }
    
    #[derive(Clone, ValueEnum)]
    enum DeviceState {
        On,
        Off,
        Toggle,
    }
    
    #[derive(Clone, ValueEnum)]
    enum ListType {
        Devices,
        Rooms,
        Scenes,
        Lights,
        Sensors,
    }
    
    #[derive(Debug, Clone, Serialize, Deserialize)]
    struct DeviceConfig {
        friendly_name: String,
        room: String,
        #[serde(rename = "type")]
        device_type: String,
        #[serde(default = "default_endpoint")]
        endpoint: u8,
        #[serde(default)]
        icon: Option<String>,
        #[serde(default)]
        battery_type: Option<String>,
        hue_id: Option<u16>,
    }
    
    struct HueClient {
        base_url: String,
        client: reqwest::blocking::Client,
    }
    
    impl HueClient {
        fn new(bridge_ip: &str, api_key: &str) -> Result<Self> {
            let base_url = format!("http://{}/api/{}", bridge_ip, api_key);
            let client = reqwest::blocking::Client::new();
        
            Ok(Self {
                base_url,
                client,
            })
        }
    
        fn set_light_state(&self, light_id: u16, state: serde_json::Value) -> Result<()> {
            let url = format!("{}/lights/{}/state", self.base_url, light_id);
        
            let response = self.client
                .put(&url)
                .json(&state)
                .send()
                .context("Failed to send Hue API request")?;
        
            if !response.status().is_success() {
                let status = response.status();
                let body = response.text().unwrap_or_default();
                anyhow::bail!("Hue API error {}: {}", status, body);
            }      
            Ok(())
        }
    }
    
    // 🦆 says ⮞ determine backend from device type & hue_id
    fn get_device_backend(device: &DeviceConfig) -> Backend {
        if device.device_type == "hue_light" && device.hue_id.is_some() {
            Backend::Hue
        } else {
            Backend::Zigbee2Mqtt
        }
    }
    
    enum Backend {
        Zigbee2Mqtt,
        Hue,
    }
    
    
    fn default_endpoint() -> u8 {
        11
    }
    
    #[derive(Debug, Clone, Serialize, Deserialize)]
    struct SceneConfig {
        #[serde(default)]
        friendly_name: Option<String>,
        devices: HashMap<String, serde_json::Value>,
    }
      
    
    // 🦆 says ⮞ remove Debug derive since Client doesn't implement Debug
    struct ZigduckController {
        mqtt_client: Client,
        hue_client: Option<HueClient>,
        devices: HashMap<String, DeviceConfig>,
        scenes: HashMap<String, SceneConfig>,
        verbose: bool,
    }
    
    impl ZigduckController {
        fn run_shell_command(&self, command: &str) -> Result<()> {
            println!("{} Running shell command: {}", "🦆".cyan(), command);
        
            let output = Command::new("sh")
                .arg("-c")
                .arg(command)
                .output()
                .context("Failed to execute shell command")?;
            
            if output.status.success() {
                let stdout = String::from_utf8_lossy(&output.stdout);
                if !stdout.trim().is_empty() {
                    println!("{} Command output: {}", "✅".green(), stdout);
                }
            } else {
                let stderr = String::from_utf8_lossy(&output.stderr);
                anyhow::bail!("Command failed: {}", stderr);
            }        
            Ok(())
        }

        fn get_device_backend(&self, device: &DeviceConfig) -> Backend {
            if (device.device_type == "light" || device.device_type == "hue_light") && device.hue_id.is_some() {
                Backend::Hue
            } else {
                Backend::Zigbee2Mqtt
            }
        }

        fn is_hue_device(&self, device: &DeviceConfig) -> bool {
            let is_light = device.device_type == "light" || device.device_type == "hue_light";
            is_light && device.hue_id.is_some()
        }

        
        fn new(
            broker: String,
            user: String,
            password: String,
            hue_bridge_ip: Option<String>,
            hue_api_key: Option<String>,    
            devices_config: Option<PathBuf>,
            scenes_config: Option<PathBuf>,
            verbose: bool,
        ) -> Result<Self> {
            let mut mqttoptions = MqttOptions::new("zigduck-cli", &broker, 1883);
            mqttoptions.set_credentials(&user, &password);
            mqttoptions.set_keep_alive(Duration::from_secs(5));
            
            // 🦆 says ⮞ init Hue client if credentials
            let hue_client = if let (Some(ip), Some(key)) = (hue_bridge_ip, hue_api_key) {
                Some(HueClient::new(&ip, &key)?)
            } else {
                None
            };
            
            let (mqtt_client, mut connection) = Client::new(mqttoptions, 10);
            
            // 🦆 says ⮞ separate threaded event loop
            let mqtt_client_clone = mqtt_client.clone();
            std::thread::spawn(move || {
                for notification in connection.iter() {
                    match notification {
                        Ok(_) => {
                            // 🦆 says ⮞ We don't need to handle notifications in CLI
                        }
                        Err(e) => {
                            eprintln!("MQTT connection error: {}", e);
                            break;
                        }
                    }
                }
            });
            
            // 🦆 says ⮞ establish connection
            std::thread::sleep(Duration::from_millis(100));
            
            // 🦆 says ⮞ load devices from config file
            let devices = Self::load_devices(devices_config)?;
            let scenes = Self::load_scenes(scenes_config)?;
            
            if verbose {
                println!("{} Connected to MQTT broker: {}", "✅".green(), broker);
                println!("{} Loaded {} devices", "📱".blue(), devices.len());
                println!("{} Loaded {} scenes", "🎨".purple(), scenes.len());
            }
            
            Ok(Self {
                mqtt_client: mqtt_client_clone,
                hue_client,
                devices,
                scenes,
                verbose,
            })
        }
        
        fn load_devices(config_path: Option<PathBuf>) -> Result<HashMap<String, DeviceConfig>> {
            let config_path = config_path.ok_or_else(|| anyhow::anyhow!("No devices config provided"))?;
            
            if !config_path.exists() {
                println!("{} No devices config found at {:?}, using empty list", "⚠️".yellow(), config_path);
                return Ok(HashMap::new());
            }
            
            let devices_json = fs::read_to_string(config_path)
                .context("Failed to read devices config file")?;
            
            let devices: HashMap<String, DeviceConfig> = serde_json::from_str(&devices_json)
                .map_err(|e| anyhow::anyhow!("Failed to parse devices JSON: {}", e))?;
            
            Ok(devices)
        }
        
        fn load_scenes(config_path: Option<PathBuf>) -> Result<HashMap<String, SceneConfig>> {
            let config_path = config_path.ok_or_else(|| anyhow::anyhow!("No scenes config provided"))?;
            
            if !config_path.exists() {
                println!("{} No scenes config found at {:?}, using empty list", "⚠️".yellow(), config_path);
                return Ok(HashMap::new());
            }
            
            let scenes_json = fs::read_to_string(config_path)
                .context("Failed to read scenes config file")?;
            
            let scenes: HashMap<String, SceneConfig> = serde_json::from_str(&scenes_json)
                .map_err(|e| anyhow::anyhow!("Failed to parse scenes JSON: {}", e))?;
            
            Ok(scenes)
        }
                
        fn hex_to_xy(&self, hex: &str) -> Result<(f64, f64)> {
            // 🦆 says ⮞ simple conversion
            let hex = hex.trim_start_matches('#');
            if hex.len() != 6 {
                anyhow::bail!("Invalid hex color: {}", hex);
            }
            
            let r = u8::from_str_radix(&hex[0..2], 16)? as f64 / 255.0;
            let g = u8::from_str_radix(&hex[2..4], 16)? as f64 / 255.0;
            let b = u8::from_str_radix(&hex[4..6], 16)? as f64 / 255.0;
            
            // 🦆 says ⮞ convert to XYZ
            let r = if r > 0.04045 {
                ((r + 0.055) / 1.055).powf(2.4)
            } else {
                r / 12.92
            };
            
            let g = if g > 0.04045 {
                ((g + 0.055) / 1.055).powf(2.4)
            } else {
                g / 12.92
            };
            
            let b = if b > 0.04045 {
                ((b + 0.055) / 1.055).powf(2.4)
            } else {
                b / 12.92
            };
            
            let x = r * 0.649926 + g * 0.103455 + b * 0.197109;
            let y = r * 0.234327 + g * 0.743075 + b * 0.022598;
            let z = r * 0.000000 + g * 0.053077 + b * 1.035763;
            
            let sum = x + y + z;
            if sum == 0.0 {
                Ok((0.5, 0.4)) // 🦆 says ⮞ default neutral
            } else {
                Ok((x / sum, y / sum))
            }
        }
             
        fn publish_command(&mut self, topic: &str, payload: serde_json::Value) -> Result<()> {
            let payload_str = serde_json::to_string(&payload)?;
            
            if self.verbose {
                println!("{} {} → {}", "🦆 PUBLISH".cyan(), topic.blue(), payload_str.yellow());
            }
            
            self.mqtt_client
                .publish(topic, QoS::AtMostOnce, false, payload_str)
                .map_err(|e| anyhow::anyhow!("Failed to publish MQTT message: {}", e))?;
            
            // 🦆 says ⮞ tiny delay to make sure message is sent
            std::thread::sleep(Duration::from_millis(50));
            
            Ok(())
        }
        
        // 🦆 says ⮞ hue device controller
        fn control_hue_device(
            &mut self,
            hue_id: u16,
            state: &DeviceState,
            brightness: Option<u8>,
            color: Option<String>,
            temperature: Option<u16>,
            transition: Option<f32>,
        ) -> Result<()> {
            let hue_client = self.hue_client.as_ref()
                .context("Hue client not initialized")?;
            
            let mut payload = serde_json::Map::new();
            
            match state {
                DeviceState::On => {
                    payload.insert("on".to_string(), serde_json::Value::Bool(true));
                    
                    if let Some(brightness_val) = brightness {
                        if !(1..=100).contains(&brightness_val) {
                            anyhow::bail!("Brightness must be between 1-100");
                        }
                        let hue_brightness = (brightness_val as f32 * 2.54).round() as u8;
                        payload.insert("bri".to_string(), hue_brightness.into());
                    }
                    
                    if let Some(color_val) = color {
                        let xy = self.hex_to_xy(&color_val)?;
                        // 🦆 says ⮞ FIX: Convert tuple to JSON array
                        payload.insert("xy".to_string(), 
                            serde_json::json!([xy.0, xy.1]));
                    }
                    
                    if let Some(temp_val) = temperature {
                        payload.insert("ct".to_string(), temp_val.into());
                    }
                    
                    if let Some(transition_val) = transition {
                        let hue_transition = (transition_val * 10.0).round() as u16; // seconds to deciseconds
                        payload.insert("transitiontime".to_string(), hue_transition.into());
                    }
                }
                DeviceState::Off => {
                    payload.insert("on".to_string(), serde_json::Value::Bool(false));
                }
                DeviceState::Toggle => {
                    // 🦆 says ⮞ TODO
                    println!("{} Toggle not implemented for Hue yet, defaulting to ON", "⚠️".yellow());
                    payload.insert("on".to_string(), serde_json::Value::Bool(true));
                }
            }
            
            let payload_json = serde_json::Value::Object(payload);
            hue_client.set_light_state(hue_id, payload_json)
        }
        
        // 🦆 says ⮞ zigbee device controller 
        fn control_mqtt_device(
            &mut self,
            device_name: &str,
            state: &DeviceState,
            brightness: Option<u8>,
            color: Option<String>,
            temperature: Option<u16>,
            transition: Option<f32>,
        ) -> Result<()> {
            let mut payload = serde_json::Map::new();
            
            match state {
                DeviceState::On => {
                    payload.insert("state".to_string(), "ON".into());
                    
                    if let Some(brightness_val) = brightness {
                        if !(1..=100).contains(&brightness_val) {
                            anyhow::bail!("Brightness must be between 1-100");
                        }
                        let mqtt_brightness = (brightness_val as f32 * 2.54).round() as u8;
                        payload.insert("brightness".to_string(), mqtt_brightness.into());
                    }
                    
                    if let Some(color_val) = color {
                        if color_val.starts_with('#') && color_val.len() == 7 {
                            payload.insert("color".to_string(), 
                                serde_json::json!({"hex": color_val}));
                        } else {
                            let hex_code = self.color_name_to_hex(&color_val)?;
                            payload.insert("color".to_string(), 
                                serde_json::json!({"hex": hex_code}));
                        }
                    }
                    
                    if let Some(temp_val) = temperature {
                        payload.insert("color_temp".to_string(), temp_val.into());
                    }
                    
                    if let Some(transition_val) = transition {
                        payload.insert("transition".to_string(), transition_val.into());
                    }
                }
                DeviceState::Off => {
                    payload.insert("state".to_string(), "OFF".into());
                }
                DeviceState::Toggle => {
                    // 🦆 says ⮞ TODO
                    println!("{} Toggle not fully implemented, defaulting to ON", "⚠️".yellow());
                    payload.insert("state".to_string(), "ON".into());
                }
            }
            
            let topic = format!("zigbee2mqtt/{}/set", device_name);
            self.publish_command(&topic, serde_json::Value::Object(payload))
        }
        
        fn control_device(
            &mut self,
            device_name: &str,
            state: &DeviceState,
            brightness: Option<u8>,
            color: Option<String>,
            temperature: Option<u16>,
            transition: Option<f32>,
        ) -> Result<()> {
            let device = self.find_device(device_name)?;
            
            if device.device_type == "sensor" || device.friendly_name.contains("Smoke") {
                println!("{} {} is a sensor, skipping", "⚠️".yellow(), device.friendly_name);
                return Ok(());
            }
            
            // 🦆 says ⮞ Hue light?
            if device.device_type == "hue_light" && device.hue_id.is_some() {
                // 🦆 says ⮞ use Hue backend
                let hue_client = self.hue_client.as_ref()
                    .context("Hue client not initialized for Hue light")?;
                
                let hue_id = device.hue_id.unwrap();
                let mut hue_payload = serde_json::Map::new();
                
                match state {
                    DeviceState::On => {
                        hue_payload.insert("on".to_string(), serde_json::Value::Bool(true));
                        
                        if let Some(brightness_val) = brightness {
                            if !(1..=100).contains(&brightness_val) {
                                anyhow::bail!("Brightness must be between 1-100");
                            }
                            let hue_brightness = (brightness_val as f32 * 2.54).round() as u8;
                            hue_payload.insert("bri".to_string(), hue_brightness.into());
                        }
                        
                        if let Some(color_val) = color {
                            let hex = if color_val.starts_with('#') {
                                color_val.clone()
                            } else {
                                self.color_name_to_hex(&color_val)?
                            };
                            let xy = self.hex_to_xy(&hex)?;
                            // 🦆 says ⮞ FIX: Convert tuple to JSON array
                            hue_payload.insert("xy".to_string(), 
                                serde_json::json!([xy.0, xy.1]));
                        }
                        
                        if let Some(temp_val) = temperature {
                            hue_payload.insert("ct".to_string(), temp_val.into());
                        }
                        
                        if let Some(transition_val) = transition {
                            let hue_transition = (transition_val * 10.0).round() as u16;
                            hue_payload.insert("transitiontime".to_string(), hue_transition.into());
                        }
                    }
                    DeviceState::Off => {
                        hue_payload.insert("on".to_string(), serde_json::Value::Bool(false));
                    }
                    DeviceState::Toggle => {
                        println!("{} Toggle not implemented for Hue, defaulting to ON", "⚠️".yellow());
                        hue_payload.insert("on".to_string(), serde_json::Value::Bool(true));
                    }
                }
                
                let payload_json = serde_json::Value::Object(hue_payload);
                hue_client.set_light_state(hue_id, payload_json)
            } else {
                // 🦆 says ⮞ use Z2M backend
                self.control_mqtt_device(device_name, state, brightness, color, temperature, transition)
            }
        }
        
        // 🦆 says ⮞ room specific controller
        fn control_room(
            &mut self,
            room_name: &str,
            state: &DeviceState,
            brightness: Option<u8>,
            color: Option<String>,
            temperature: Option<u16>,
        ) -> Result<()> {
            // 🦆 says ⮞ collect device names first to avoid holding reference while mutating
            let device_names: Vec<String> = self.devices
                .values()
                .filter(|d| d.room.to_lowercase() == room_name.to_lowercase() && d.device_type == "light")
                .map(|d| d.friendly_name.clone())
                .collect();
    
            if device_names.is_empty() {
                anyhow::bail!("No lights found in room: {}", room_name);
            }
    
            println!("{} Controlling {} lights in {}", 
                "💡".green(), device_names.len(), room_name.bold());
    
            for device_name in device_names {
                self.control_device(
                    &device_name,
                    state,
                    brightness,
                    color.clone(),
                    temperature,
                    None,
                )?;        
                // 🦆 says ⮞ chill
                std::thread::sleep(Duration::from_millis(50));
            }
    
            Ok(())
        }
    
    
        fn convert_to_hue_payload(&self, settings: &serde_json::Value) -> Result<serde_json::Value> {
            let mut payload = serde_json::Map::new();         
            // 🦆 says ⮞  state
            if let Some(state) = settings.get("state").and_then(|s| s.as_str()) {
                payload.insert("on".to_string(), serde_json::Value::Bool(state == "ON"));
            }
            
            // 🦆 says ⮞  brightness (0-254)
            if let Some(brightness) = settings.get("brightness").and_then(|b| b.as_u64()) {
                payload.insert("bri".to_string(), brightness.into());
            }
            
            // 🦆 says ⮞ color
            if let Some(color) = settings.get("color") {
                if let Some(xy) = color.get("xy") {
                    payload.insert("xy".to_string(), xy.clone());
                } else if let Some(hex) = color.get("hex").and_then(|h| h.as_str()) {
                    let xy = self.hex_to_xy(hex)?;
                    // 🦆 says ⮞ FIX: Convert tuple to JSON array
                    payload.insert("xy".to_string(), serde_json::json!([xy.0, xy.1]));
                }
            }
            
            if let Some(transition) = settings.get("transition").and_then(|t| t.as_u64()) {
                payload.insert("transitiontime".to_string(), transition.into());
            }        
            Ok(serde_json::Value::Object(payload))
        }

   
        fn activate_scene(
            &mut self,
            scene_name: &str,
            random: bool,
        ) -> Result<()> {
            let scene_to_activate = if random {
                use rand::seq::SliceRandom;
                let scene_names: Vec<String> = self.scenes.keys().cloned().collect();
                let chosen = scene_names.choose(&mut rand::thread_rng())
                    .context("No scenes configured")?
                    .clone();
                chosen
            } else {
                scene_name.to_string()
            };
        
            println!("{} Activating scene: {}", "🎨".purple(), scene_to_activate.bold());
        
            let scene = self.scenes
                .get(&scene_to_activate)
                .context(format!("Scene not found: {}", scene_to_activate))?;
        
            if self.verbose {
                println!("{} Scene '{}' has {} devices", "🔍".cyan(), scene_to_activate, scene.devices.len());
            }
        
            if scene.devices.is_empty() {
                anyhow::bail!("No devices found in scene: {}", scene_to_activate);
            }
        
            let mut device_count = 0;
            let mut hue_device_count = 0;
            let mut mqtt_device_count = 0;
        
            for (device_name, settings) in &scene.devices {
                if !settings.is_object() {
                    println!("{} Skipping {}: invalid settings format", "⚠️".yellow(), device_name);
                    continue;
                }
                
                // 🦆 says ⮞ FIX: More flexible Hue device detection
                if let Some(device) = self.devices.get(device_name) {
                    // Check if device is a light AND has hue_id (not just device_type == "hue_light")
                    let is_light = device.device_type == "light" || device.device_type == "hue_light";
                    if is_light && device.hue_id.is_some() {
                        // 🦆 says ⮞ use Hue Bridge API
                        if let Some(hue_client) = &self.hue_client {
                            let hue_id = device.hue_id.unwrap();
                            let hue_payload = self.convert_to_hue_payload(settings)?;
                            
                            if self.verbose {
                                println!("{} Hue API {} (id: {}) → {}", "🦆 PUBLISH".cyan(), 
                                    device_name.blue(), hue_id, hue_payload.to_string().yellow());
                            }
                            
                            hue_client.set_light_state(hue_id, hue_payload)?;
                            hue_device_count += 1;
                            device_count += 1;
                            continue;
                        } else {
                            println!("{} Skipping Hue device {}: Hue client not initialized", "⚠️".yellow(), device_name);
                        }
                    }
                }
                
                // 🦆 says ⮞ fallback 2 z2m
                let topic = format!("zigbee2mqtt/{}/set", device_name);
        
                if self.verbose {
                    println!("{} {} → {}", "🦆 PUBLISH".cyan(), topic.blue(), settings.to_string().yellow());
                }
        
                self.mqtt_client
                    .publish(&topic, QoS::AtMostOnce, false, settings.to_string())
                    .map_err(|e| anyhow::anyhow!("Failed to publish MQTT message for {}: {}", device_name, e))?;
        
                mqtt_device_count += 1;
                device_count += 1;
                std::thread::sleep(Duration::from_millis(10));
            }
        
            if device_count == 0 {
                anyhow::bail!("No valid devices found in scene: {}", scene_to_activate);
            }

            if self.verbose {
                println!("{} Running Hue bridge command for remaining devices", "🎨".purple());
            }
        
            let hue_command = format!("hue bridge apply-scene \"{}\"", scene_name);
            if let Err(e) = self.run_shell_command(&hue_command) {
                println!("{} Hue bridge command failed: {}", "⚠️".yellow(), e);
            }
          
            println!("{} Scene '{}' activated ({} total devices: {} via Hue, {} via MQTT)", 
                "✅".green(), scene_to_activate, device_count, hue_device_count, mqtt_device_count);
            Ok(())
        }
                
        fn enter_pairing_mode(
            &mut self,
            duration: u16,
            watch: bool,
        ) -> Result<()> {
            println!("{} Entering pairing mode for {} seconds...", 
                "📡".blue(), duration);
            
            let enable_payload = serde_json::json!({
                "value": true,
                "time": duration
            });
            
            self.publish_command("zigbee2mqtt/bridge/request/permit_join", enable_payload)?;
            
            if watch {
                println!("{} Watching for new devices...", "👀".cyan());
                println!("{} Put your device in pairing mode now!", "👉".yellow());
                
                std::thread::sleep(Duration::from_secs(duration as u64));
            } else {
                println!("{} Pairing mode active for {} seconds", "⏰".yellow(), duration);
                std::thread::sleep(Duration::from_secs(duration as u64));
            }
            
            // 🦆 says ⮞ disable pairing
            let disable_payload = serde_json::json!({
                "value": false
            });
            
            self.publish_command("zigbee2mqtt/bridge/request/permit_join", disable_payload)?;
            
            println!("{} Pairing mode finished", "✅".green());
            Ok(())
        }
        
        fn control_all_lights(
            &mut self,
            state: &DeviceState,
            brightness: Option<u8>,
            color: Option<String>,
        ) -> Result<()> {
            // 🦆 says ⮞ collect device names first to avoid holding reference while mutating
            let device_names: Vec<String> = self.devices
                .values()
                .filter(|d| d.device_type == "light")
                .map(|d| d.friendly_name.clone())
                .collect();
    
            println!("{} Controlling {} lights", "💡".green(), device_names.len());
    
            for device_name in device_names {
                self.control_device(
                    &device_name,
                    state,
                    brightness,
                    color.clone(),
                    None,
                    None,
                )?;
        
                std::thread::sleep(Duration::from_millis(50));
            }    
            Ok(())
        }
        
        fn cheap_mode(
            &mut self,
            room: &str,
            delay: u64,
        ) -> Result<()> {
            println!("{} Energy saving mode for {} ({} seconds delay)", 
                "💰".green(), room, delay);
            
            // 🦆 says ⮞ first turn on the room lights
            self.control_room(room, &DeviceState::On, Some(50), None, None)?;
            
            println!("{} Lights on, will turn off in {} seconds...", 
                "⏰".yellow(), delay);
            
            // 🦆 says ⮞ wait
            std::thread::sleep(Duration::from_secs(delay));
            
            // 🦆 says ⮞ turn off the lights
            self.control_room(room, &DeviceState::Off, None, None, None)?;            
            println!("{} Lights turned off for energy saving", "✅".green());
            
            Ok(())
        }
        
        fn list_items(&self, what: &ListType, json: bool) -> Result<()> {
            match what {
                ListType::Devices => {
                    let devices_list: Vec<_> = self.devices.values().collect();
                    if json {
                        let json = serde_json::to_string_pretty(&devices_list)?;
                        println!("{}", json);
                    } else {
                        println!("\n{} All Devices ({} total):", "📱".blue(), devices_list.len());
                        for device in devices_list {
                            println!("  • {} [{}] - {}", 
                                device.friendly_name.bold(), 
                                device.room, 
                                device.device_type);
                        }
                    }
                }
                ListType::Rooms => {
                    let mut rooms = std::collections::HashMap::new();
                    for device in self.devices.values() {
                        *rooms.entry(&device.room).or_insert(0) += 1;
                    }
                    
                    if json {
                        let json = serde_json::to_string_pretty(&rooms)?;
                        println!("{}", json);
                    } else {
                        println!("\n{} Rooms ({} total):", "🏠".blue(), rooms.len());
                        for (room, count) in rooms {
                            println!("  • {} ({} devices)", room.bold(), count);
                        }
                    }
                }
    
                ListType::Scenes => {
                    if json {
                        let json = serde_json::to_string_pretty(&self.scenes)?;
                        println!("{}", json);
                    } else {
                        println!("\n{} Scenes ({} total):", "🎨".purple(), self.scenes.len());
                        for (scene_name, scene) in &self.scenes {
                            let friendly_name = scene.friendly_name
                                .as_deref()
                                .unwrap_or(scene_name);
                            let device_count = scene.devices.len();  // Direct access
            
                            println!("  • {} ({} devices)", friendly_name.bold(), device_count);
                        }
                    }
                }
                ListType::Lights => {
                    let lights: Vec<_> = self.devices.values()
                        .filter(|d| d.device_type == "light")
                        .collect();
                    
                    if json {
                        let json = serde_json::to_string_pretty(&lights)?;
                        println!("{}", json);
                    } else {
                        println!("\n{} Lights ({} total):", "💡".yellow(), lights.len());
                        for light in lights {
                            println!("  • {} [{}]", light.friendly_name.bold(), light.room);
                        }
                    }
                }
                ListType::Sensors => {
                    let sensors: Vec<_> = self.devices.values()
                        .filter(|d| d.device_type.contains("sensor") || 
                                   d.device_type.contains("motion") || 
                                   d.device_type.contains("contact"))
                        .collect();
                    
                    if json {
                        let json = serde_json::to_string_pretty(&sensors)?;
                        println!("{}", json);
                    } else {
                        println!("\n{} Sensors ({} total):", "📡".cyan(), sensors.len());
                        for sensor in sensors {
                            println!("  • {} [{}]", sensor.friendly_name.bold(), sensor.room);
                        }
                    }
                }
            }
            
            Ok(())
        }
        
        fn find_device(&self, query: &str) -> Result<&DeviceConfig> {
            let query_lower = query.to_lowercase();            
            if let Some(device) = self.devices.values().find(|d| 
                d.friendly_name.to_lowercase() == query_lower
            ) {
                return Ok(device);
            }
            
            if let Some(device) = self.devices.values().find(|d| 
                d.friendly_name.to_lowercase().contains(&query_lower)
            ) {
                return Ok(device);
            }
            
            if let Some(device) = self.devices.get(query) {
                return Ok(device);
            }
            
            anyhow::bail!("Device not found: {}", query)
        }
        
        fn color_name_to_hex(&self, color_name: &str) -> Result<String> {
            let hex = match color_name.to_lowercase().as_str() {
                "red" => "#FF0000".to_string(),
                "green" => "#00FF00".to_string(),
                "blue" => "#0000FF".to_string(),
                "yellow" => "#FFFF00".to_string(),
                "orange" => "#FFA500".to_string(),
                "purple" => "#800080".to_string(),
                "pink" => "#FFC0CB".to_string(),
                "white" => "#FFFFFF".to_string(),
                "black" => "#000000".to_string(),
                "gray" | "grey" => "#808080".to_string(),
                "brown" => "#A52A2A".to_string(),
                "cyan" => "#00FFFF".to_string(),
                "magenta" => "#FF00FF".to_string(),
                "turquoise" => "#40E0D0".to_string(),
                "teal" => "#008080".to_string(),
                "lime" => "#00FF00".to_string(),
                "maroon" => "#800000".to_string(),
                "olive" => "#808000".to_string(),
                "navy" => "#000080".to_string(),
                "lavender" => "#E6E6FA".to_string(),
                "coral" => "#FF7F50".to_string(),
                "gold" => "#FFD700".to_string(),
                "silver" => "#C0C0C0".to_string(),
                "random" => {
                    use rand::Rng;
                    let mut rng = rand::thread_rng();
                    format!("#{:06X}", rng.gen_range(0..0xFFFFFF))
                }
                _ if color_name.starts_with('#') && color_name.len() == 7 => {
                    return Ok(color_name.to_string());
                }
                _ => anyhow::bail!("Unknown color: {}", color_name),
            };
            
            Ok(hex)
        }
    }
    
    fn main() -> Result<()> {
        let cli = Cli::parse();
        
        // 🦆 says ⮞ load password from file, otherwise use env var or empty
        let password = if let Some(password_file) = cli.password_file {
            fs::read_to_string(password_file)?.trim().to_string()
        } else if let Some(password) = cli.password {
            password
        } else if let Ok(password) = std::env::var("MQTT_PASSWORD") {
            password
        } else {
            "".to_string()
        };
        
        let mut controller = ZigduckController::new(
            cli.broker,
            cli.user,
            password,
            cli.hue_bridge_ip,
            cli.hue_api_key,
            cli.devices_config,
            cli.scenes_config,
            cli.verbose > 0,
        )?;
        
        match cli.command {
            Commands::Device { name, state, brightness, color, temperature, transition } => {
                controller.control_device(&name, &state, brightness, color, temperature, transition)
            }
            Commands::Room { name, state, brightness, color, temperature } => {
                controller.control_room(&name, &state, brightness, color, temperature)
            }
            Commands::Scene { name, random } => {
                controller.activate_scene(&name, random)
            }
            Commands::Pair { duration, watch } => {
                controller.enter_pairing_mode(duration, watch)
            }
            Commands::AllLights { state, brightness, color } => {
                controller.control_all_lights(&state, brightness, color)
            }
            Commands::CheapMode { room, delay } => {
                controller.cheap_mode(&room, delay)
            }
            Commands::List { what, json } => {
                controller.list_items(&what, json)
            }
        }
    }
    

  '';
  
  # 🦆 says ⮞ Write the devices and scenes to JSON files
  devicesConfigFile = pkgs.writeText "devices.json" devicesJson;
  scenesConfigFile = pkgs.writeText "scenes.json" scenesJson;

  zigduck-toml = pkgs.writeText "zigduck.toml" ''    
    [package]
    name = "zigduck-cli"
    version = "1.0.0"
    edition = "2021"
    authors = ["QuackHack-McBLindy"]
    description = "High-performance Rust CLI Mosquitto publisher for home automation"
    license = "MIT"

    [[bin]]
    name = "zigduck-cli"
    path = "src/main.rs"

    [dependencies]
    clap = { version = "4.4", features = ["derive", "env"] }
    rumqttc = "0.22"
    serde = { version = "1.0", features = ["derive"] }
    serde_json = "1.0"
    serde_yaml = "0.9"
    anyhow = "1.0"
    colored = "2.1"
    rand = "0.8"
    reqwest = { version = "0.11", features = ["blocking", "json"] }
    tokio = { version = "1.0", features = ["full"] }
  '';


  environment.variables = {
    OPENSSL_DIR = "${pkgs.openssl.dev}";
    PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
  };
  
in {
  yo.scripts.house = {
    description = "High-performance Rust CLI MQTT publisher for controlling Zigbee devices.";
    category = "🛖 Home Automation";
    autoStart = false;
    logLevel = "DEBUG";
    helpFooter = ''  
      MQTT_HOST="${config.house.zigbee.mosquitto.host}"
      ZIGDUCKDIR="${zigduckDir}"
      STATE_FILE="$ZIGDUCKDIR/state.json"
      if [[ "$MQTT_HOST" == "$HOSTNAME" ]]; then
        BATTERY_DATA=$(cat $STATE_FILE)
      else
        BATTERY_DATA=$(ssh ${mqttHost} cat /home/pungkula/.config/zigduck/state.json)
      fi
      mk_table() {
        echo "| State  | Device | Battery | Temperature |"
        echo "| :- | :-- | :-- | :-- |"
        while IFS= read -r line; do
          [ -z "$line" ] && continue        
          device=$(echo "$line" | cut -d'|' -f2)
          state=$(echo "$line" | cut -d'|' -f1)
          battery=$(echo "$line" | cut -d'|' -f3)
          temp=$(echo "$line" | cut -d'|' -f4)
          device_single_line=$(echo "$device" | tr '\n' ' ' | sed 's/ \{2,\}/ /g')   
          echo "| $device_single_line | $state | $battery | $temp |"
        done <<< "$1"
      }
      TABLE_DATA=$(
        echo "$BATTERY_DATA" | \
        jq -r '
          to_entries[] 
          | .key as $key 
          | .value as $v
          | {
              key: $key,
              state: (
                if $v.state? == "ON" or $v.state? == "OFF" then $v.state
                elif $v.position? == "100" then "OPEN"
                elif $v.contact? == "true" then "CLOSED"
                elif $v.contact? == "false" then "OPEN"
                else null
                end
              ),
              battery: (if $v.battery? and $v.battery != "null" then $v.battery | tonumber else null end),
              temperature: (if $v.temperature? and $v.temperature != "null" then $v.temperature else null end)
            }
          | select(.state != null or .battery != null or .temperature != null)
          | [
              .key,
              (if .state then .state else "" end),
              (if .battery != null then (if .battery > 40 then "🔋" else "🪫" end) + " \(.battery)%" else "" end),
              (if .temperature != null then "\(.temperature)°C" else "" end)
            ]
          | join("|")' 
      )
      echo -e "\n## ──────⋆⋅☆⋅⋆────── ##"
      echo "## Device Status"
      mk_table "$TABLE_DATA"
    '';
    parameters = [   
      { name = "device"; description = "Device to control"; optional = true; }
      { name = "state"; type = "string"; description = "State of the device or group"; } 
      { name = "brightness"; description = "Brightness value of the device or group"; optional = true; type = "int"; }    
      { name = "color"; description = "Color to set on the device"; optional = true; }    
      { name = "temperature"; description = "Light color temperature to set on the device"; optional = true; }          
      { name = "scene"; description = "Activate a predefined scene"; optional = true; }     
      { name = "room"; description = "Room to target"; optional = true; }        
      { name = "user"; description = "Mosquitto username to use"; default = config.house.zigbee.mosquitto.username; }    
      { name = "passwordfile"; description = "File path containing password for Mosquitto user"; default = config.house.zigbee.mosquitto.passwordFile; }
      { name = "flake"; description = "Path containing flake.nix"; default = config.this.user.me.dotfilesDir; }
      { name = "pair"; type = "bool"; description = "Activate zigbee2mqtt pairing and start searching for new devices"; default = false; }
      { name = "cheapMode"; type = "bool"; description = "Energy saving mode. Turns off the lights again after X seconds."; default = false; }
    ];
    code = ''
      ${cmdHelpers}
      export OPENSSL_DIR="${pkgs.openssl.dev}"
      export OPENSSL_LIB_DIR="${pkgs.openssl.out}/lib"
      export PKG_CONFIG_PATH="${pkgs.openssl.dev}/lib/pkgconfig"
      export PATH="${pkgs.pkg-config}/bin:$PATH"      
      # 🦆 says ⮞ create case insensitive map of device friendly_name
      declare -A device_map=( ${lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "['${lib.toLower k}']='${v}'") normalizedDeviceMap)} )
      available_devices=( ${toString deviceList} )      
      DOTFILES="$flake"
      DIR="/home/${config.this.user.me.name}/zigduck-cli"
      DEVICE="$device"
      STATE="$state"
      SCENE="$scene"
      BRIGHTNESS="$brightness"
      COLOR="$color"
      TEMP="$temperature"
      MQTT_BROKER="${config.house.zigbee.mosquitto.host}"
      PWFILE="$passwordfile"
      MQTT_USER="$user"
      MQTT_PASSWORD=$(cat "$PWFILE")
      HUE_BRIDGE_IP="${config.house.zigbee.hueSyncBox.bridge.ip or ""}"
      HUE_API_KEY="$(cat "${config.house.zigbee.hueSyncBox.bridge.passwordFile}" 2>/dev/null || echo "")"      
      ROOM="$room"
      
      dt_info "MQTT_BROKER: $MQTT_BROKER" 
      dt_info "State directory: $DIR"
      
      mkdir -p "$DIR"
      
      # 🦆 says ⮞ copy config files to 
      if [ ! -f "$DIR/devices.json" ]; then
        cat ${devicesConfigFile} > "$DIR/devices.json"
      fi
      
      if [ ! -f "$DIR/scenes.json" ]; then
        cat ${scenesConfigFile} > "$DIR/scenes.json"
      fi
      
      mkdir -p "$DIR/src"
      cat ${zigduck-cli} > "$DIR/src/main.rs"
      cat ${zigduck-toml} > "$DIR/Cargo.toml"
      
      cd "$DIR"
      # 🦆 says ⮞ if no binary exist - compile it yo
      if [ ! -f "target/release/zigduck-cli" ]; then
        ${pkgs.cargo}/bin/cargo generate-lockfile
        ${pkgs.cargo}/bin/cargo build --release      
      fi
    
      # 🦆 says ⮞ build cmd args
      RUST_ARGS=()
      
      RUST_ARGS+=(--broker "$MQTT_BROKER")
      RUST_ARGS+=(--user "$MQTT_USER")
      RUST_ARGS+=(--password "$MQTT_PASSWORD")
      
      
      if [ -n "$HUE_BRIDGE_IP" ] && [ -n "$HUE_API_KEY" ]; then
        RUST_ARGS+=(--hue-bridge-ip "$HUE_BRIDGE_IP")
        RUST_ARGS+=(--hue-api-key "$HUE_API_KEY")
      fi      
      
      RUST_ARGS+=(--devices-config "$DIR/devices.json")
      RUST_ARGS+=(--scenes-config "$DIR/scenes.json")
      
      if [ "$VERBOSE" -ge 1 ]; then
        RUST_ARGS+=(--verbose)
      fi
      
      # 🦆 says ⮞ determine state
      determine_state() {
        local state="$1"
        local color="$2"
        local brightness="$3"
        local temp="$4"
        
        if [ -n "$state" ]; then
          echo "$(echo "$state" | tr '[:upper:]' '[:lower:]')"
        elif [ -n "$color" ] || [ -n "$brightness" ] || [ -n "$temp" ]; then
          echo "on"
        else
          echo "toggle"
        fi
      }
      
      # 🦆 says ⮞ ROOM CONTROL
      if [ -n "$ROOM" ]; then
        STATE_FOR_RUST=$(determine_state "$STATE" "$COLOR" "$BRIGHTNESS" "$TEMP")
        
        RUST_ARGS+=(room --name "$ROOM" "$STATE_FOR_RUST")
        
        if [ -n "$BRIGHTNESS" ]; then
          RUST_ARGS+=(--brightness "$BRIGHTNESS")
        fi
        
        if [ -n "$COLOR" ]; then
          RUST_ARGS+=(--color "$COLOR")
        fi
        
        if [ -n "$TEMP" ]; then
          RUST_ARGS+=(--temperature "$TEMP")
        fi
        
      # 🦆 says ⮞ device control
      elif [ -n "$DEVICE" ]; then
        DEVICE_LOWER=$(echo "$DEVICE" | tr '[:upper:]' '[:lower:]')
        EXACT_NAME="''${device_map["$DEVICE_LOWER"]:-}"
    
        if [ -n "$EXACT_NAME" ]; then
          DEVICE="$EXACT_NAME"
        fi
    
        ROOM_DEVICES=$(echo "''${roomDevicesMap["$DEVICE"]:-}" | head -1)
        STATE_FOR_RUST=$(determine_state "$STATE" "$COLOR" "$BRIGHTNESS" "$TEMP")
    
        if [ -n "$ROOM_DEVICES" ]; then
          RUST_ARGS+=(room --name "$DEVICE" "$STATE_FOR_RUST")
        else
          RUST_ARGS+=(device --name "$DEVICE" --state "$STATE_FOR_RUST")
        fi
    
        if [ -n "$BRIGHTNESS" ]; then
          RUST_ARGS+=(--brightness "$BRIGHTNESS")
        fi
    
        if [ -n "$COLOR" ]; then
          RUST_ARGS+=(--color "$COLOR")
        fi
    
        if [ -n "$TEMP" ]; then
          RUST_ARGS+=(--temperature "$TEMP")
        fi
    
      elif [ -n "$SCENE" ]; then
        RUST_ARGS+=(scene "$SCENE")      
      elif [ "$pair" = "true" ]; then
        RUST_ARGS+=(pair --watch)      
      elif [ "$cheapMode" = "true" ]; then
        if [ -n "$room" ]; then
          RUST_ARGS+=(cheap-mode "$room" --delay 300)
        else
          dt_error "Cheap mode requires a room parameter"
          exit 1
        fi     
      else
        RUST_ARGS+=(list devices)
      fi
      
      # 🦆 says ⮞ run in debug mode
      if [ "$VERBOSE" -ge 1 ]; then
        dt_info "Running: ./target/release/zigduck-cli ''${RUST_ARGS[@]}"
        HUE_BRIDGE_IP="${config.house.zigbee.hueSyncBox.bridge.ip or ""}" HUE_API_KEY="$(cat "${config.house.zigbee.hueSyncBox.bridge.passwordFile}" 2>/dev/null || echo "")" DEBUG=1 ./target/release/zigduck-cli ''${RUST_ARGS[@]}
        exit 0
      fi
      
      # 🦆 says ⮞ normal execution
      HUE_BRIDGE_IP="${config.house.zigbee.hueSyncBox.bridge.ip or ""}" HUE_API_KEY="$(cat "${config.house.zigbee.hueSyncBox.bridge.passwordFile}" 2>/dev/null || echo "")" ./target/release/zigduck-cli "''${RUST_ARGS[@]}"
    '';
    
    voice = {
      priority = 1;
      sentences = [
        # 🦆 says ⮞ multi taskerz
        "{device} {state} i {room} och [ändra] färg[en] [till] {color} [och] ljusstyrka[n] [till] {brightness} procent"
        "{device} {state} och ljusstyrka {brightness} procent"
        "(gör|ändra) {device} [till] {color} [färg] [och] {brightness} procent [ljusstyrka]"  
        "{scene} alla lampor"
        "{scene} (belysning|belysningen)"
        "{slate} alla lampor i {device}"
        "{state} {device} (lampor|igen)"   
        "{state} lamporna i {device}"
        "stäng {state} {device}"
        "starta {state} {device}"
        # 🦆 says ⮞ color control
        "(ändra|gör) färgen [på|i] {device} till {color}"
        "(ändra|gör) {device} {color}"
        # 🦆 says ⮞ pairing mode
        "{pair} [ny|nya] [zigbee] (enhet|enheter)"
        # 🦆 says ⮞ brightness control
        "justera {device} till {brightness} procent"
      ];        
      lists = {
        state.values = [
          { "in" = "[tänd|tända|tänk|start|starta|på|tönd|tömd]"; out = "ON"; }             
          { "in" = "[släck|släcka|slick|av|stäng|stäng av]"; out = "OFF"; } 
        ];
        brightness.values = builtins.genList (i: {
          "in" = toString (i + 1);
          out = toString (i + 1);
        }) 100;
        device.values = let
          reservedNames = [ "hall" "kitchen" "bedroom" "bathroom" "wc" "livingroom" "kitchen" "switch" "all" "every" ];
          sanitize = str:
            lib.replaceStrings [ "/" " " ] [ "" "_" ] str;
    
          # 🦆 says ⮞ natural Swedish patterns
          swedishPatterns = base: baseRaw: [
            # 🦆 says ⮞ base name
            base      
            # 🦆 says ⮞ definite form (the X)
            "${baseRaw}n"           # 🦆says⮞ en-words
            "${baseRaw}t"           # 🦆says⮞ ett-words  
            "${baseRaw}en"
            "${baseRaw}et"   
            # 🦆says⮞ plural forms
            "${baseRaw}ar"
            "${baseRaw}or"
            "${baseRaw}er"
            "${baseRaw}na"          # 🦆says⮞ plural definite
            "${baseRaw}orna"
            "${baseRaw}erna" 
            # 🦆says⮞ common Swedish light/lamp patterns
            "${baseRaw}lampan"
            "${baseRaw}lampor"
            "${baseRaw}lamporna"
            "${baseRaw}ljus"
            "${baseRaw}lamp"
          ];   
        in [
          { "in" = "[vardagsrum|vardagsrummet|stora rummet|förrum]"; out = "livingroom"; }
          { "in" = "[kök|köket]"; out = "kitchen"; }
          { "in" = "[sovrum|sovrummet|sängkammaren|sovrummet]"; out = "bedroom"; }
          { "in" = "[badrum|badrummet|toaletten|wc]"; out = "bathroom"; }
          { "in" = "[hall|hallen|korridor|korridoren]"; out = "hallway"; }
          { "in" = "[alla|allting|allt|alla lampor|varje lampa]"; out = "ALL_LIGHTS"; }    
        ] ++
        (lib.filter (x: x != null) (
          lib.mapAttrsToList (_: device:
           let
              baseRaw = lib.toLower device.friendly_name;
              base = sanitize baseRaw;
              baseWords = lib.splitString " " base;
              isAmbiguous = lib.any (word: lib.elem word reservedNames) baseWords;
        
              # 🦆says⮞ gen Swedish variations
              swedishVariations = lib.unique (swedishPatterns base baseRaw);
        
              # 🦆says⮞ English as fallback
              englishVariants = [ "${base}s" "${base} light" ];
        
              variations = lib.unique (
                [
                  base
                  (sanitize (lib.replaceStrings [ " " ] [ "" ] base))
                  (lib.replaceStrings [ "_" ] [ " " ] base)
                ] ++ swedishVariations ++ englishVariants
              );
            in if isAmbiguous then null else {
              "in" = "[" + lib.concatStringsSep "|" variations + "]";
              out = device.friendly_name;
            }
          ) zigbeeDevices
        ));
  
        color.values = [
          { "in" = "[röd|rött|röda]"; out = "red"; }
          { "in" = "[grön|grönt|gröna]"; out = "green"; }
          { "in" = "[blå|blått|blåa]"; out = "blue"; }
          { "in" = "[gul|gult|gula]"; out = "yellow"; }
          { "in" = "[orange|orangefärgad|orangea]"; out = "orange"; }
          { "in" = "[lila|lilla|violett|violetta]"; out = "purple"; }
          { "in" = "[rosa|rosafärgad|rosaaktig]"; out = "pink"; }
          { "in" = "[vit|vitt|vita]"; out = "white"; }
          { "in" = "[svart|svarta]"; out = "black"; }
          { "in" = "[grå|grått|gråa]"; out = "gray"; }
          { "in" = "[brun|brunt|bruna]"; out = "brown"; }
          { "in" = "[cyan|cyanblå|turkosblå]"; out = "cyan"; }
          { "in" = "[magenta|cerise|fuchsia]"; out = "magenta"; }
          { "in" = "[turkos|turkosgrön]"; out = "turquoise"; }
          { "in" = "[teal|blågrön]"; out = "teal"; }
          { "in" = "[lime|limegrön]"; out = "lime"; }
          { "in" = "[maroon|mörkröd]"; out = "maroon"; }
          { "in" = "[oliv|olivgrön]"; out = "olive"; }
          { "in" = "[navy|marinblå]"; out = "navy"; }
          { "in" = "[lavendel|ljuslila]"; out = "lavender"; }
          { "in" = "[korall|korallröd]"; out = "coral"; }
          { "in" = "[guld|guldfärgad]"; out = "gold"; }
          { "in" = "[silver|silverfärgad]"; out = "silver"; }
          { "in" = "[slumpmässig|random|valfri färg]"; out = "random"; }
        ];
        
        temperature.values = builtins.genList (i: {
           "in" = toString i;
            out = toString i;
        }) 500;
        
        scene.values = let
          reservedSceneNames = [ "max" "dark" "off" "on" "all" "every" ];
          sanitizeScene = str:
            lib.toLower (lib.replaceStrings [ " " "-" "_" ] [ "" "" "" ] str);
            
          # 🦆 says ⮞ natural Swedish scene patterns
          swedishScenePatterns = base: baseRaw: [
            # 🦆 says ⮞ base scene name
            base
            # 🦆 says ⮞ definite form
            "${baseRaw}n"
            "${baseRaw}t" 
            "${baseRaw}en"
            "${baseRaw}et"
            # 🦆 says ⮞ common scene patterns
            "${baseRaw} scen"
            "${baseRaw} scenen"
            "${baseRaw} läge"
            "${baseRaw} läget"
          ];      
        in [
          # 🦆 says ⮞ scenes
          { "in" = "[tänd||tänk|max|maxa|maxxa|maxad|maximum]"; out = "max"; }
          { "in" = "[på|tänd|aktiv]"; out = "max"; }
          
          { "in" = "[mörk|mörker|mörkt|släckt|avstängd]"; out = "dark"; }
          { "in" = "[av|släck|släckt|stängd|stäng]"; out = "dark"; }

          { "in" = "[mys|myspys|mysig|chill|chilla]"; out = "Chill Scene"; }
        ] ++
        (lib.mapAttrsToList (sceneId: sceneConfig:
          let
            baseRaw = lib.toLower sceneConfig.friendly_name or sceneId;
            base = sanitizeScene baseRaw;
            baseWords = lib.splitString " " base;
            isAmbiguous = lib.any (word: lib.elem word reservedSceneNames) baseWords;
        
            # 🦆 says ⮞ generate Swedish variations
            swedishVariations = if isAmbiguous then [] else lib.unique (swedishScenePatterns base baseRaw);
        
            variations = lib.unique (
              [
                base
                (sanitizeScene (lib.replaceStrings [ " " ] [ "" ] base))
                (lib.replaceStrings [ "_" "-" ] [ " " " " ] base)
                sceneId  # Include the actual scene ID
              ] ++ swedishVariations
            );
          in {
            "in" = "[" + lib.concatStringsSep "|" variations + "]";
            out = sceneId;
          }
        ) scenes);
        
        pair.values = [
          { "in" = "[para|paras]"; out = "true"; }
        ];
        
        room.values = [
          { "in" = "[kök|köket|kitchen]"; out = "kitchen"; }
          { "in" = "[vardagsrum|vardagsrummet]"; out = "livingroom"; }
          { "in" = "[sovrum|sovrummet|bedroom]"; out = "bedroom"; }
          { "in" = "[badrum|badrummet|wc|toilet]"; out = "wc"; }
          { "in" = "[hall|hallen|hallway]"; out = "hallway"; }
                                        
        ];        
      };
    };
    
  };}
