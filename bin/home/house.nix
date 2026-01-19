





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

	  # 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 
	# 🦆 ⮞ DEVICES
	  # 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 

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
	      hue_id = device.hue_id or null;
	      supports_color = device.supports_color or false;
	      supports_temperature = device.supports_temperature or false;
	    }) zigbeeDevices
	  );

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

	  # 🦆 says ⮞ Create reverse mapping from friendly_name to device ID
	  friendlyNameToId = builtins.listToAttrs (
	    lib.flatten (
	      lib.mapAttrsToList (id: device: [
		{ 
		  name = device.friendly_name; 
		  value = id; 
		}
	      ]) zigbeeDevices
	    )
	  );


	  # 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 
	# 🦆 ⮞ SCENES
	  # 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 
	  # 🎨 Scenes 🦆 YELLS ⮞ SCENES!!!!!!!!!!!!!!!11
	  scenes = config.house.zigbee.scenes;


	  # 🦆 says ⮞ Generate scene commands - FIXED to handle friendly names in scenes
	  makeCommand = deviceName: settings:
	    let
	      # 🦆 says ⮞ Try to find device ID by friendly name
	      deviceId = friendlyNameToId.${deviceName} or null;
	      dev = if deviceId != null then zigbeeDevices.${deviceId} else null;
	      json = builtins.toJSON settings;
	      hue_id = if dev != null && dev.hue_id != null then toString dev.hue_id else "unknown";
	      # 🦆 says ⮞ Use device's friendly name for MQTT topic
	      mqttName = if dev != null then dev.friendly_name else deviceName;
	    in
	      if dev == null then
		# 🦆 says ⮞ Device not found - output error but continue
		''echo "🦆 Warning: Device '${deviceName}' not found in zigbeeDevices"''
	      else if dev.type == "hue_light" then
		''echo "light_id: ${hue_id} - ${json}"''
	      else
		''mqtt_pub --topic "zigbee2mqtt/${mqttName}/set" -m '${json}''
	      ;
	      
	  sceneCommands = lib.mapAttrs
	    (sceneName: sceneDevices:
	      lib.mapAttrs (device: settings: makeCommand device settings) sceneDevices
	    ) scenes;  


	  # 🦆 says ⮞ generate scenes json
	  scenesJson = builtins.toJSON (
	    lib.mapAttrs (sceneName: sceneDevices: {
	      friendly_name = sceneName;
	      devices = sceneDevices;
	    }) scenes
	  );

	  # 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 
	# 🦆 ⮞ RUST CODE - UPDATED FOR PROPER HUE INTEGRATION
	  # 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 🦆 
	  
	  # 🦆🚀🚀 rocket ⮞ 🌙 
	  zigduck-cli = pkgs.writeText "main.rs" ''    
	    use std::process::Command;    
	    use std::thread::sleep;
	    use clap::{Parser, Subcommand, ValueEnum, Args};
	    use serde::{Deserialize, Serialize};
	    use rumqttc::{Client, MqttOptions, QoS};
	    use std::time::Duration;
	    use anyhow::{Result, Context};
	    use colored::*;
	    use std::collections::HashMap;
	    use std::fs;
	    use std::path::PathBuf;
	    use reqwest::blocking::Client as HttpClient;
	    use rand::Rng;
	    use rand::seq::SliceRandom; 
	    
	    #[derive(Parser)]
	    #[command(
		name = "zigduck-cli",
		version = "1.0.0",
		author = "🦆 QuackHack-McBLindy",
		about = "High-performance unified home automation controller",
		long_about = "Control Zigbee and Hue devices, scenes, and automations with Rust speed and reliability"
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
		/// 🦆 says ⮞ control individual device with named parameters
		Device(DeviceCommand),
		
		/// 🦆 says ⮞ control device with raw JSON
		Json(JsonCommand),
		
		/// 🦆 says ⮞ control all devices in a room
		Room {
		    /// 🦆 says ⮞ room name
		    #[arg(short, long)]
		    name: String,
		    
		    /// 🦆 says ⮞ room state
		    #[arg(value_enum)]
		    state: DeviceState,
		    
		    /// 🦆 says ⮞ brightness percentage
		    #[arg(short, long)]
		    brightness: Option<u8>,
		    
		    /// 🦆 says ⮞ color name or hex code
		    #[arg(short, long)]
		    color: Option<String>,
		    
		    /// 🦆 says ⮞ color temperature (153-500)
		    #[arg(short = 't', long)]
		    temperature: Option<u16>,
		},
		
		/// 🦆 says ⮞ activate scene
		Scene {
		    /// 🦆 says ⮞ scene name
		    name: String,
		    
		    /// 🦆 says ⮞ random scene if no provided
		    #[arg(short, long, default_value_t = false)]
		    random: bool,
		},
		
		/// 🦆 says ⮞ enter pairing mode for new devices
		Pair {
		    /// 🦆 says ⮞ pairing duration in seconds
		    #[arg(short, long, default_value_t = 120)]
		    duration: u16,
		    
		    /// 🦆 says ⮞ watch for new devices
		    #[arg(short, long, default_value_t = false)]
		    watch: bool,
		},
		
		/// 🦆 says ⮞ control all lights
		AllLights {
		    /// 🦆 says ⮞ all lights state
		    #[arg(value_enum)]
		    state: DeviceState,            
		    /// 🦆 says ⮞ brightness percentage
		    #[arg(short, long)]
		    brightness: Option<u8>,            
		    /// 🦆 says ⮞ color name or hex code
		    #[arg(short, long)]
		    color: Option<String>,
		},
		
		/// 🦆 says ⮞ List available devices, rooms, or scenes
		List {
		    /// 🦆 says ⮞ what to list
		    #[arg(value_enum)]
		    what: ListType,            
		    /// 🦆 says ⮞ output as JSON
		    #[arg(short, long, default_value_t = false)]
		    json: bool,
		},
		
		/// 🦆 says ⮞ energy saving mode - turn off lights after delay
		CheapMode {
		    /// 🦆 says ⮞ room name
		    room: String,            
		    /// 🦆 says ⮞ delay in seconds before turning off
		    #[arg(short, long, default_value_t = 300)]
		    delay: u64,
		},
	    }
	    
	    #[derive(Args)]
	    struct DeviceCommand {
		/// 🦆 says ⮞ device name
		#[arg(short, long)]
		device: String,
		
		/// 🦆 says ⮞ device state
		#[arg(short, long, value_enum)]
		state: DeviceState,
		
		/// 🦆 says ⮞ brightness percentage (1-100)
		#[arg(short, long)]
		brightness: Option<u8>,
		
		/// 🦆 says ⮞ color name or hex code
		#[arg(short, long)]
		color: Option<String>,
		
		/// 🦆 says ⮞ color temperature (153-500)
		#[arg(short = 't', long)]
		temperature: Option<u16>,
		
		/// 🦆 says ⮞ transition time in seconds
		#[arg(short = 'T', long)]
		transition: Option<f32>,
	    }
	    
	    #[derive(Args)]
	    struct JsonCommand {
		/// 🦆 says ⮞ device name
		#[arg(short, long)]
		device: String,
		
		/// 🦆 says ⮞ raw JSON to send
		#[arg(short, long)]
		json: String,
		
		/// 🦆 says ⮞ backend type (auto, zigbee, hue)
		#[arg(short, long, value_enum, default_value = "auto")]
		backend: BackendType,
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
	    
	    #[derive(Clone, ValueEnum)]
	    enum BackendType {
		Auto,
		Zigbee,
		Hue,
	    }
	    
          #[derive(Debug, Clone, Serialize, Deserialize)]  // Add Clone here
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
              supports_color: Option<bool>,
              supports_temperature: Option<bool>,
          }

	    
	    struct HueClient {
		base_url: String,
		client: HttpClient,
	    }
	    
	    impl HueClient {
		fn new(bridge_ip: &str, api_key: &str) -> Result<Self> {
		    let base_url = format!("http://{}/api/{}", bridge_ip, api_key);
		    let client = HttpClient::new();
		
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
		
		fn get_light_state(&self, light_id: u16) -> Result<serde_json::Value> {
		    let url = format!("{}/lights/{}", self.base_url, light_id);
		    
		    let response = self.client
		        .get(&url)
		        .send()
		        .context("Failed to get Hue light state")?;
		        
		    if !response.status().is_success() {
		        anyhow::bail!("Failed to get light state: {}", response.status());
		    }
		    
		    let json: serde_json::Value = response.json()?;
		    Ok(json)
		}
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
	    
	    struct ZigduckController {
		mqtt_client: Client,
		hue_client: Option<HueClient>,
		devices: HashMap<String, DeviceConfig>,
		scenes: HashMap<String, SceneConfig>,
		verbose: bool,
	    }
	    
	    impl ZigduckController {
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
		    
		    let hue_client = if let (Some(ip), Some(key)) = (hue_bridge_ip, hue_api_key) {
		        Some(HueClient::new(&ip, &key)?)
		    } else {
		        None
		    };
		    
		    let (mqtt_client, mut connection) = Client::new(mqttoptions, 10);
		    
		    let mqtt_client_clone = mqtt_client.clone();
		    std::thread::spawn(move || {
		        for notification in connection.iter() {
		            match notification {
		                Ok(_) => {},
		                Err(e) => {
		                    eprintln!("MQTT connection error: {}", e);
		                    break;
		                }
		            }
		        }
		    });
		    
		    std::thread::sleep(Duration::from_millis(100));
		    
		    let devices = Self::load_devices(devices_config)?;
		    let scenes = Self::load_scenes(scenes_config)?;
		    
		    if verbose {
		        println!("{} Connected to MQTT broker: {}", "✅".green(), broker);
		        println!("{} Loaded {} devices", "📱".blue(), devices.len());
		        println!("{} Loaded {} scenes", "🎨".purple(), scenes.len());
		        if hue_client.is_some() {
		            println!("{} Hue Bridge connected", "💡".yellow());
		        }
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
		        println!("{} No devices config found, using empty list", "⚠️".yellow());
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
		        println!("{} No scenes config found, using empty list", "⚠️".yellow());
		        return Ok(HashMap::new());
		    }
		    
		    let scenes_json = fs::read_to_string(config_path)
		        .context("Failed to read scenes config file")?;
		    
		    let scenes: HashMap<String, SceneConfig> = serde_json::from_str(&scenes_json)
		        .map_err(|e| anyhow::anyhow!("Failed to parse scenes JSON: {}", e))?;
		    
		    Ok(scenes)
		}
		
		fn color_name_to_hue_sat(&self, color_name: &str) -> Result<(u16, u8)> {
		    let mut rng = rand::thread_rng();
		    
		    match color_name.to_lowercase().as_str() {
		        "red" => Ok((rng.gen_range(0..6000), 254)),
		        "orange" => Ok((rng.gen_range(6000..10000), 254)),
		        "yellow" => Ok((rng.gen_range(10000..15000), 254)),
		        "green" => Ok((rng.gen_range(20000..30000), 254)),
		        "cyan" => Ok((rng.gen_range(30000..36000), 254)),
		        "blue" => Ok((rng.gen_range(45000..50000), 254)),
		        "purple" => Ok((rng.gen_range(50000..56000), 254)),
		        "pink" => Ok((rng.gen_range(56000..62000), 150)),
		        "magenta" => Ok((rng.gen_range(58000..65535), 254)),
		        "white" => Ok((rng.gen_range(0..65535), 30)),
		        "gray" | "grey" => Ok((rng.gen_range(0..65535), 60)),
		        "black" => Ok((rng.gen_range(0..65535), 0)),
		        "random" => Ok((rng.gen_range(0..65535), rng.gen_range(0..254))),
		        _ => anyhow::bail!("Unknown color: {}", color_name),
		    }
		}
		
		fn hex_to_xy(&self, hex: &str) -> Result<(f32, f32)> {
		    let hex = hex.trim_start_matches('#');
		    if hex.len() != 6 {
		        anyhow::bail!("Invalid hex color: {}", hex);
		    }
		    
		    let r = u8::from_str_radix(&hex[0..2], 16)? as f32 / 255.0;
		    let g = u8::from_str_radix(&hex[2..4], 16)? as f32 / 255.0;
		    let b = u8::from_str_radix(&hex[4..6], 16)? as f32 / 255.0;
		    
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
		        Ok((0.5, 0.4))
		    } else {
		        Ok((x / sum, y / sum))
		    }
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
		
		fn publish_mqtt(&mut self, topic: &str, payload: serde_json::Value) -> Result<()> {
		    let payload_str = serde_json::to_string(&payload)?;
		    
		    if self.verbose {
		        println!("{} {} → {}", "🦆 MQTT".cyan(), topic.blue(), payload_str.yellow());
		    }
		    
		    self.mqtt_client
		        .publish(topic, QoS::AtMostOnce, false, payload_str)
		        .map_err(|e| anyhow::anyhow!("Failed to publish MQTT message: {}", e))?;
		    
		    std::thread::sleep(Duration::from_millis(50));
		    Ok(())
		}
		
              fn find_device(&self, query: &str) -> Result<DeviceConfig> {
                  let query_lower = query.to_lowercase();
  
                  for device in self.devices.values() {
                      if device.friendly_name.to_lowercase() == query_lower {
                          return Ok(device.clone());
                      }
                  }
  
                  for device in self.devices.values() {
                      if device.friendly_name.to_lowercase().contains(&query_lower) {
                          return Ok(device.clone());
                      }
                  }
  
                  anyhow::bail!("Device not found: {}", query)
              }

		
		fn is_hue_device(&self, device: &DeviceConfig) -> bool {
		    device.hue_id.is_some() && (device.device_type == "light" || device.device_type == "hue_light")
		}
		
              fn control_device_with_params(
                  &mut self,
                  device_name: &str,
                  state: &DeviceState,
                  brightness: Option<u8>,
                  color: Option<String>,
                  temperature: Option<u16>,
                  transition: Option<f32>,
              ) -> Result<()> {
                  let device = self.find_device(device_name)?.clone();  // Clone the device
  
                  if self.is_hue_device(&device) {
                      self.control_hue_device(&device, state, brightness, color, temperature, transition)
                  } else {
                      self.control_zigbee_device(&device.friendly_name, state, brightness, color, temperature, transition)
                  }
              }
		
		fn control_hue_device(
		    &mut self,
		    device: &DeviceConfig,
		    state: &DeviceState,
		    brightness: Option<u8>,
		    color: Option<String>,
		    temperature: Option<u16>,
		    transition: Option<f32>,
		) -> Result<()> {
		    let hue_id = device.hue_id.unwrap();
		    let hue_client = self.hue_client.as_ref()
		        .context("Hue client not initialized")?;
		    
		    let mut payload = serde_json::Map::new();
		    
		    match state {
		        DeviceState::On => {
		            payload.insert("on".to_string(), serde_json::Value::Bool(true));
		            
		            if let Some(bri) = brightness {
		                if !(1..=100).contains(&bri) {
		                    anyhow::bail!("Brightness must be between 1-100");
		                }
		                let hue_bri = (bri as f32 * 2.54).round() as u8;
		                if hue_bri > 0 {
		                    payload.insert("bri".to_string(), serde_json::Value::Number(hue_bri.into()));
		                }
		            }
		            
		            if let Some(color_val) = &color {
		                if let Some(temp_val) = temperature {
		                    payload.insert("ct".to_string(), serde_json::Value::Number(temp_val.into()));
		                } else {
		                    let hex = self.color_name_to_hex(color_val)?;
		                    let (hue, sat) = if color_val == "white" {
		                        (0, 0)
		                    } else if color_val == "random" {
		                        let mut rng = rand::thread_rng();
		                        (rng.gen_range(0..65535), rng.gen_range(0..254))
		                    } else if let Ok((h, s)) = self.color_name_to_hue_sat(color_val) {
		                        (h, s)
		                    } else {
		                        let xy = self.hex_to_xy(&hex)?;
		                        payload.insert("xy".to_string(), serde_json::json!([xy.0, xy.1]));
		                        (0, 0)
		                    };
		                    
		                    if hue > 0 || sat > 0 {
		                        payload.insert("hue".to_string(), serde_json::Value::Number(hue.into()));
		                        payload.insert("sat".to_string(), serde_json::Value::Number(sat.into()));
		                    }
		                }
		            } else if let Some(temp_val) = temperature {
		                payload.insert("ct".to_string(), serde_json::Value::Number(temp_val.into()));
		            }
		            
		            if let Some(trans) = transition {
		                let trans_time = (trans * 10.0).round() as u16;
		                payload.insert("transitiontime".to_string(), serde_json::Value::Number(trans_time.into()));
		            }
		        }
		        DeviceState::Off => {
		            payload.insert("on".to_string(), serde_json::Value::Bool(false));
		        }
		        DeviceState::Toggle => {
		            let current = hue_client.get_light_state(hue_id)?;
		            let is_on = current.get("state")
		                .and_then(|s| s.get("on"))
		                .and_then(|o| o.as_bool())
		                .unwrap_or(false);
		            
		            payload.insert("on".to_string(), serde_json::Value::Bool(!is_on));
		        }
		    }
		    
		    let payload_json = serde_json::Value::Object(payload);
		    
		    if self.verbose {
		        println!("{} Hue Light {} (ID: {}) → {}", "💡".yellow(), 
		            device.friendly_name, hue_id, payload_json.to_string());
		    }
		    
		    hue_client.set_light_state(hue_id, payload_json)
		}
		
		fn control_zigbee_device(
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
		            
		            if let Some(bri) = brightness {
		                if !(1..=100).contains(&bri) {
		                    anyhow::bail!("Brightness must be between 1-100");
		                }
		                let mqtt_bri = (bri as f32 * 2.54).round() as u8;
		                payload.insert("brightness".to_string(), mqtt_bri.into());
		            }
		            
		            if let Some(color_val) = &color {
		                let hex = self.color_name_to_hex(color_val)?;
		                payload.insert("color".to_string(), 
		                    serde_json::json!({"hex": hex}));
		            }
		            
		            if let Some(temp_val) = temperature {
		                payload.insert("color_temp".to_string(), temp_val.into());
		            }
		            
		            if let Some(trans) = transition {
		                payload.insert("transition".to_string(), trans.into());
		            }
		        }
		        DeviceState::Off => {
		            payload.insert("state".to_string(), "OFF".into());
		        }
		        DeviceState::Toggle => {
		            payload.insert("state".to_string(), "TOGGLE".into());
		        }
		    }
		    
		    let topic = format!("zigbee2mqtt/{}/set", device_name);
		    self.publish_mqtt(&topic, serde_json::Value::Object(payload))
		}
		

              fn control_device_with_json(
                  &mut self,
                  device_name: &str,
                  json_str: &str,
                  backend_type: &BackendType,
              ) -> Result<()> {
                  let device = self.find_device(device_name)?.clone();  // Clone the device
                  let payload: serde_json::Value = serde_json::from_str(json_str)
                      .context("Failed to parse JSON")?;
  
                  match backend_type {
                      BackendType::Auto => {
                          if self.is_hue_device(&device) {
                              self.control_hue_with_json(&device, payload)
                          } else {
                              self.control_zigbee_with_json(&device.friendly_name, payload)
                          }
                      }
                      BackendType::Zigbee => {
                          self.control_zigbee_with_json(&device.friendly_name, payload)
                      }
                      BackendType::Hue => {
                          self.control_hue_with_json(&device, payload)
                      }
                  }
              }
		
		fn control_hue_with_json(&mut self, device: &DeviceConfig, payload: serde_json::Value) -> Result<()> {
		    let hue_id = device.hue_id.unwrap();
		    let hue_client = self.hue_client.as_ref()
		        .context("Hue client not initialized")?;
		    
		    if self.verbose {
		        println!("{} Hue Light {} (ID: {}) → {}", "💡".yellow(), 
		            device.friendly_name, hue_id, payload.to_string());
		    }
		    
		    hue_client.set_light_state(hue_id, payload)
		}
		
		fn control_zigbee_with_json(&mut self, device_name: &str, payload: serde_json::Value) -> Result<()> {
		    let topic = format!("zigbee2mqtt/{}/set", device_name);
		    self.publish_mqtt(&topic, payload)
		}
		
		fn control_room(
		    &mut self,
		    room_name: &str,
		    state: &DeviceState,
		    brightness: Option<u8>,
		    color: Option<String>,
		    temperature: Option<u16>,
		) -> Result<()> {
		    let device_names: Vec<String> = self.devices
		        .values()
		        .filter(|d| d.room.to_lowercase() == room_name.to_lowercase() && 
		                  (d.device_type == "light" || d.device_type == "hue_light"))
		        .map(|d| d.friendly_name.clone())
		        .collect();
	    
		    if device_names.is_empty() {
		        anyhow::bail!("No lights found in room: {}", room_name);
		    }
	    
		    println!("{} Controlling {} lights in {}", 
		        "💡".green(), device_names.len(), room_name.bold());
	    
		    for device_name in device_names {
		        self.control_device_with_params(
		            &device_name,
		            state,
		            brightness,
		            color.clone(),
		            temperature,
		            None,
		        )?;
		        std::thread::sleep(Duration::from_millis(50));
		    }
	    
		    Ok(())
		}
		
              fn activate_scene(&mut self, scene_name: &str, random: bool) -> Result<()> {
                  let scene_to_activate = if random {
                      let scene_names: Vec<String> = self.scenes.keys().cloned().collect();
                      if scene_names.is_empty() {
                          anyhow::bail!("No scenes configured");
                      }
                      let mut rng = rand::thread_rng();
                      scene_names.choose(&mut rng).unwrap().clone()
                  } else {
                      scene_name.to_string()
                  };

                  println!("{} Activating scene: {}", "🎨".purple(), scene_to_activate.bold());

                  // Get the scene and immediately clone its devices
                  let scene = self.scenes
                      .get(&scene_to_activate)
                      .context(format!("Scene not found: {}", scene_to_activate))?;

                  if self.verbose {
                      println!("{} Scene '{}' has {} devices", "🔍".cyan(), scene_to_activate, scene.devices.len());
                  }

                  if scene.devices.is_empty() {
                      anyhow::bail!("No devices found in scene: {}", scene_to_activate);
                  }

                  // Clone the devices map so we don't hold a borrow to self.scenes
                  let devices: Vec<(String, serde_json::Value)> = scene.devices
                      .iter()
                      .map(|(k, v)| (k.clone(), v.clone()))
                      .collect();

                  let mut hue_count = 0;
                  let mut zigbee_count = 0;

                  for (device_name, settings) in devices {
                      if let Ok(device) = self.find_device(&device_name) {
                          if self.is_hue_device(&device) {
                              if let Some(hue_client) = &self.hue_client {
                                  let hue_id = device.hue_id.unwrap();
                                  let hue_payload = self.convert_to_hue_payload(&settings)?;
                  
                                  if self.verbose {
                                      println!("{} Hue {} (ID: {}) → {}", "💡".yellow(), 
                                          device_name, hue_id, hue_payload.to_string());
                                  }
                  
                                  hue_client.set_light_state(hue_id, hue_payload)?;
                                  hue_count += 1;
                              } else {
                                  println!("{} Skipping Hue device {}: Hue client not initialized", "⚠️".yellow(), device_name);
                              }
                          } else {
                              let topic = format!("zigbee2mqtt/{}/set", device_name);
                              if self.verbose {
                                  println!("{} MQTT {} → {}", "🦆".cyan(), topic, settings.to_string());
                              }
                              self.publish_mqtt(&topic, settings)?;
                              zigbee_count += 1;
                          }
                      } else {
                          println!("{} Device {} not found", "⚠️".yellow(), device_name);
                      }
      
                      std::thread::sleep(Duration::from_millis(10));
                  }

                  println!("{} Scene '{}' activated ({} Hue, {} Zigbee)", 
                      "✅".green(), scene_to_activate, hue_count, zigbee_count);
                  Ok(())
              }
		
        fn convert_to_hue_payload(&self, settings: &serde_json::Value) -> Result<serde_json::Value> {
            let mut payload = serde_json::Map::new();
    
            // Handle on/off state
            if let Some(state) = settings.get("state").and_then(|s| s.as_str()) {
                payload.insert("on".to_string(), serde_json::Value::Bool(state == "ON"));
            } else {
                payload.insert("on".to_string(), serde_json::Value::Bool(true));
            }
    
            // Handle brightness
            if let Some(brightness) = settings.get("brightness") {
                if let Some(bri) = brightness.as_u64() {
                    let hue_bri = (bri as f32).min(254.0) as u8;
                    if hue_bri > 0 {
                        payload.insert("bri".to_string(), serde_json::Value::Number(hue_bri.into()));
                    }
                } else if let Some(bri) = brightness.as_f64() {
                    let hue_bri = (bri as f32).min(254.0) as u8;
                    if hue_bri > 0 {
                        payload.insert("bri".to_string(), serde_json::Value::Number(hue_bri.into()));
                    }
                }
            }
    
            // Handle color with XY coordinates (this is the fix!)
            if let Some(color_obj) = settings.get("color") {
                if let Some(xy_array) = color_obj.get("xy") {
                    if let Some(xy) = xy_array.as_array() {
                        if xy.len() == 2 {
                            payload.insert("xy".to_string(), serde_json::json!(xy));
                        }
                    }
                }
            }
    
            // Handle color temperature (if present)
            if let Some(temp) = settings.get("color_temp") {
                if let Some(ct) = temp.as_u64() {
                    // Convert to Hue's CT range (153-500)
                    let hue_ct = if ct > 500 { 500 } else if ct < 153 { 153 } else { ct as u16 };
                    payload.insert("ct".to_string(), serde_json::Value::Number(hue_ct.into()));
                }
            }
    
            // Handle transition time
            if let Some(transition) = settings.get("transition") {
                if let Some(t) = transition.as_f64() {
                    let trans_time = (t * 10.0).round() as u16;
                    payload.insert("transitiontime".to_string(), serde_json::Value::Number(trans_time.into()));
                } else if let Some(t) = transition.as_u64() {
                    let trans_time = (t as f64 * 10.0).round() as u16;
                    payload.insert("transitiontime".to_string(), serde_json::Value::Number(trans_time.into()));
                }
            }
    
            Ok(serde_json::Value::Object(payload))
        }
		
		fn enter_pairing_mode(&mut self, duration: u16, watch: bool) -> Result<()> {
		    println!("{} Entering pairing mode for {} seconds...", "📡".blue(), duration);
		    
		    let enable_payload = serde_json::json!({
		        "value": true,
		        "time": duration
		    });
		    
		    self.publish_mqtt("zigbee2mqtt/bridge/request/permit_join", enable_payload)?;
		    
		    if watch {
		        println!("{} Watching for new devices...", "👀".cyan());
		        println!("{} Put your device in pairing mode now!", "👉".yellow());
		        std::thread::sleep(Duration::from_secs(duration as u64));
		    } else {
		        println!("{} Pairing mode active for {} seconds", "⏰".yellow(), duration);
		        std::thread::sleep(Duration::from_secs(duration as u64));
		    }
		    
		    let disable_payload = serde_json::json!({
		        "value": false
		    });
		    
		    self.publish_mqtt("zigbee2mqtt/bridge/request/permit_join", disable_payload)?;
		    
		    println!("{} Pairing mode finished", "✅".green());
		    Ok(())
		}
		
		fn control_all_lights(&mut self, state: &DeviceState, brightness: Option<u8>, color: Option<String>) -> Result<()> {
		    let device_names: Vec<String> = self.devices
		        .values()
		        .filter(|d| d.device_type == "light" || d.device_type == "hue_light")
		        .map(|d| d.friendly_name.clone())
		        .collect();
	    
		    println!("{} Controlling {} lights", "💡".green(), device_names.len());
	    
		    for device_name in device_names {
		        self.control_device_with_params(
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
		
		fn cheap_mode(&mut self, room: &str, delay: u64) -> Result<()> {
		    println!("{} Energy saving mode for {} ({} seconds delay)", 
		        "💰".green(), room, delay);
		    
		    self.control_room(room, &DeviceState::On, Some(50), None, None)?;
		    
		    println!("{} Lights on, will turn off in {} seconds...", "⏰".yellow(), delay);
		    
		    std::thread::sleep(Duration::from_secs(delay));
		    
		    self.control_room(room, &DeviceState::Off, None, None, None)?;            
		    println!("{} Lights turned off for energy saving", "✅".green());
		    
		    Ok(())
		}
		
		fn list_items(&self, what: &ListType, json: bool) -> Result<()> {
		    match what {
		        ListType::Devices => {
		            let devices_list: Vec<_> = self.devices.values().collect();
		            if json {
		                println!("{}", serde_json::to_string_pretty(&devices_list)?);
		            } else {
		                println!("\n{} All Devices ({} total):", "📱".blue(), devices_list.len());
		                for device in devices_list {
		                    let hue_info = if device.hue_id.is_some() {
		                        format!(" [Hue ID: {}]", device.hue_id.unwrap())
		                    } else {
		                        "".to_string()
		                    };
		                    println!("  • {} [{}]{}{}", 
		                        device.friendly_name.bold(), 
		                        device.room, 
		                        hue_info,
		                        if device.supports_color.unwrap_or(false) { " 🎨" } else { "" });
		                }
		            }
		        }
		        ListType::Rooms => {
		            let mut rooms = std::collections::HashMap::new();
		            for device in self.devices.values() {
		                *rooms.entry(&device.room).or_insert(0) += 1;
		            }
		            
		            if json {
		                println!("{}", serde_json::to_string_pretty(&rooms)?);
		            } else {
		                println!("\n{} Rooms ({} total):", "🏠".blue(), rooms.len());
		                for (room, count) in rooms {
		                    println!("  • {} ({} devices)", room.bold(), count);
		                }
		            }
		        }
		        ListType::Scenes => {
		            if json {
		                println!("{}", serde_json::to_string_pretty(&self.scenes)?);
		            } else {
		                println!("\n{} Scenes ({} total):", "🎨".purple(), self.scenes.len());
		                for (scene_name, scene) in &self.scenes {
		                    let friendly_name = scene.friendly_name
		                        .as_deref()
		                        .unwrap_or(scene_name);
		                    println!("  • {} ({} devices)", friendly_name.bold(), scene.devices.len());
		                }
		            }
		        }
		        ListType::Lights => {
		            let lights: Vec<_> = self.devices.values()
		                .filter(|d| d.device_type == "light" || d.device_type == "hue_light")
		                .collect();
		            
		            if json {
		                println!("{}", serde_json::to_string_pretty(&lights)?);
		            } else {
		                println!("\n{} Lights ({} total):", "💡".yellow(), lights.len());
		                for light in lights {
		                    let hue_info = if light.hue_id.is_some() {
		                        format!(" [Hue ID: {}]", light.hue_id.unwrap())
		                    } else {
		                        "".to_string()
		                    };
		                    println!("  • {} [{}]{}", light.friendly_name.bold(), light.room, hue_info);
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
		                println!("{}", serde_json::to_string_pretty(&sensors)?);
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
	    }
	    
	    fn main() -> Result<()> {
		let cli = Cli::parse();
		
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
		    Commands::Device(cmd) => {
		        controller.control_device_with_params(
		            &cmd.device,
		            &cmd.state,
		            cmd.brightness,
		            cmd.color,
		            cmd.temperature,
		            cmd.transition,
		        )
		    }
		    Commands::Json(cmd) => {
		        controller.control_device_with_json(
		            &cmd.device,
		            &cmd.json,
		            &cmd.backend,
		        )
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
	    description = "High-performance unified home automation CLI"
	    license = "MIT"

	    [[bin]]
	    name = "zigduck-cli"
	    path = "src/main.rs"

	    [dependencies]
	    clap = { version = "4.4", features = ["derive", "env"] }
	    rumqttc = "0.22"
	    serde = { version = "1.0", features = ["derive"] }
	    serde_json = "1.0"
	    anyhow = "1.0"
	    colored = "2.1"
	    rand = "0.8"
	    reqwest = { version = "0.11", features = ["blocking", "json"] }
	    tokio = { version = "1.0", features = ["full"] }
	  '';

	in {
	  yo.scripts.house = {
	    description = "High-performance unified CLI for controlling all smart home devices.";
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
	      { name = "brightness"; description = "Brightness value (1-100)"; optional = true; type = "int"; }    
	      { name = "color"; description = "Color name or hex code"; optional = true; }    
	      { name = "temperature"; description = "Light color temperature (153-500)"; optional = true; }          
	      { name = "scene"; description = "Activate a predefined scene"; optional = true; }     
	      { name = "room"; description = "Room to target"; optional = true; }        
	      { name = "user"; description = "Mosquitto username to use"; default = config.house.zigbee.mosquitto.username; }    
	      { name = "passwordfile"; description = "File path containing password for Mosquitto user"; default = config.house.zigbee.mosquitto.passwordFile; }
	      { name = "flake"; description = "Path containing flake.nix"; default = config.this.user.me.dotfilesDir; }
	      { name = "pair"; type = "bool"; description = "Activate zigbee2mqtt pairing and start searching for new devices"; default = false; }
	      { name = "cheapMode"; type = "bool"; description = "Energy saving mode. Turns off the lights again after X seconds."; default = false; }
	      { name = "json"; description = "Raw JSON to send to device"; optional = true; }
	      { name = "backend"; description = "Backend type (auto, zigbee, hue)"; optional = true; default = "auto"; }
	    ];
	    code = ''
	      ${cmdHelpers}
	      export OPENSSL_DIR="${pkgs.openssl.dev}"
	      export OPENSSL_LIB_DIR="${pkgs.openssl.out}/lib"
	      export PKG_CONFIG_PATH="${pkgs.openssl.dev}/lib/pkgconfig"
	      export PATH="${pkgs.pkg-config}/bin:$PATH"      
	      # 🦆 says ⮞ create case insensitive map of device friendly_name
            declare -A device_map
            while IFS= read -r line; do
              key=$(echo "$line" | cut -d'=' -f1 | tr -d "[:space:]'[]")
              value=$(echo "$line" | cut -d'=' -f2 | tr -d "[:space:]'")
              device_map["$key"]="$value"
            done < <(
              ${lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "['${lib.toLower k}']='${v}'") normalizedDeviceMap)}
            )
            available_devices=( ${toString deviceList} )
	      DOTFILES="$flake"
	      DIR="/home/${config.this.user.me.name}/zigduck-cli"
	      DEVICE="$device"
	      STATE="$state"
	      SCENE="$scene"
	      BRIGHTNESS="$brightness"
	      COLOR="$color"
	      TEMP="$temperature"
	      JSON="$json"
	      BACKEND="$backend"
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
	      
	      # 🦆 says ⮞ copy config files
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
	      # 🦆 says ⮞ compile if needed
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
	      
	      # 🦆 says ⮞ JSON control
	      if [ -n "$JSON" ]; then
		if [ -z "$DEVICE" ]; then
		  dt_error "JSON control requires a device parameter"
		  exit 1
		fi
		
		RUST_ARGS+=(json --device "$DEVICE" --json "$JSON")
		if [ -n "$BACKEND" ]; then
		  RUST_ARGS+=(--backend "$BACKEND")
		fi
		
	      # 🦆 says ⮞ ROOM CONTROL
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
                RUST_ARGS+=(device --device "$DEVICE" --state "$STATE_FOR_RUST")
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
		  RUST_ARGS+=(device --device "$DEVICE" --state "$STATE_FOR_RUST")
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
		   "in" = toString (i + 153);
		    out = toString (i + 153);
		}) 347; # 153-500
		
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
	    
	  };
	}





