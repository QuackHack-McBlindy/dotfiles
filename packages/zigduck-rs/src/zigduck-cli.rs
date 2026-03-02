// ddotfiles/packages/zigduck-rs/src/zigduck-cli.rs ⮞ https://github.com/QuackHack-McBlindy/dotfiles
use std::{ // 🦆 says ⮞ zigduck-cli is a command line device controller for zigduck
    fs,
    process::Command,    
    thread::sleep,
    path::PathBuf,
    time::Duration,
    collections::HashMap,
};    
use clap::{
    Parser,
    ArgGroup,
    ValueEnum,
};
use rand:: {
    Rng,
    seq::SliceRandom,
};
use ducktrace_logger::*;
use serde::{Deserialize, Serialize};
use rumqttc::{Client, MqttOptions, QoS};
use anyhow::{Result, Context};
use colored::*;
use reqwest::blocking::Client as HttpClient;
 
#[derive(Parser)]
#[command(
    name = "zigduck-cli",
    version = "0.1.0",
    author = "QuackHack-McBLindy",
    about = "High-performance unified home automation controller",
    long_about = "Control Zigbee and Hue devices, scenes, and automations with Rust speed and reliability"
)]
#[command(group(
    ArgGroup::new("action")
        .required(true)
        .args(["device", "room", "scene", "list", "pair", "all_lights", "cheap_mode", "json_cmd"])
))]
struct Cli {
    // 🦆 says ⮞ global options
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

    // 🦆 says ⮞ action flags (mutually exclusive)
    // 🦆 says ⮞ control a single device
    #[arg(long, help = "Device name (friendly name)")]
    device: Option<String>,

    // 🦆 says ⮞ control all lights in a room
    #[arg(long, help = "Room name")]
    room: Option<String>,

    // 🦆 says ⮞ activate a scene
    #[arg(long, help = "Scene name")]
    scene: Option<String>,

    // 🦆 says ⮞ list available items
    #[arg(long, help = "List devices, rooms, scenes, lights, or sensors")]
    list: Option<Option<ListType>>,

    // 🦆 says ⮞ enter pairing mode for new Zigbee devices
    #[arg(long, num_args(0..=1), default_missing_value = "120", help = "Pairing duration in seconds (default: 120)")]
    pair: Option<Option<u16>>,

    // 🦆 says ⮞ control every light in the house
    #[arg(long, help = "Control all lights")]
    all_lights: bool,

    // 🦆 says ⮞ eEnergy‑saving mode: lights on, then off after a delay
    #[arg(long, help = "Room name for cheap mode")]
    cheap_mode: Option<String>,

    // 🦆 says ⮞ send raw JSON payload to a device
    #[arg(long, help = "Send raw JSON to a device")]
    json_cmd: bool,

    // 🦆 says ⮞ additional arguments for specific actions
    // 🦆 says ⮞ device state (on/off/toggle)
    #[arg(long, value_enum)]
    state: Option<DeviceState>,

    // 🦆 says ⮞ brightness percentage
    #[arg(long)]
    brightness: Option<u8>,

    // 🦆 says ⮞ color name or hex code
    #[arg(long)]
    color: Option<String>,

    // 🦆 says ⮞ color temperature (153-500)
    #[arg(long)]
    temperature: Option<u16>,

    // 🦆 says ⮞ transition time in seconds (device only)
    #[arg(long, requires = "device")]
    transition: Option<f32>,

    // 🦆 says ⮞ raw JSON payload (for --json-cmd)
    #[arg(long, requires = "json_cmd")]
    payload: Option<String>,

    // 🦆 says ⮞ backend type for JSON command (auto/zigbee/hue)
    #[arg(long, value_enum, default_value = "auto", requires = "json_cmd")]
    backend: BackendType,

    // 🦆 says ⮞ output list as JSON
    #[arg(long, requires = "list")]
    json_output: bool,

    // 🦆 says ⮞ for --pair: watch for new devices
    #[arg(long, requires = "pair")]
    watch: bool,

    // 🦆 says ⮞ for --scene: pick a random scene
    #[arg(long, requires = "scene")]
    random: bool,

    // 🦆 says ⮞ for --scene: restrict to a specific room
    #[arg(long, requires = "scene")]
    scene_room: Option<String>,

    // 🦆 says ⮞ for --cheap-mode: delay in seconds before turning off (default: 300)
    #[arg(long, default_value_t = 300, requires = "cheap_mode")]
    delay: u64,
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
    dt_setup(None, None);
    dt_debug("zigduck-cli init!");
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
        cli.broker, cli.user, password,
        cli.hue_bridge_ip, cli.hue_api_key,
        cli.devices_config, cli.scenes_config,
        cli.verbose > 0,
    )?;

    // 🦆 says ⮞ determine which action was requested
    if let Some(device_name) = cli.device {
        // 🦆 says ⮞ device action
        let state = cli.state.expect("--state is required for device");
        controller.control_device_with_params(
            &device_name,
            &state,
            cli.brightness,
            cli.color,
            cli.temperature,
            cli.transition,
        )
    } else if let Some(room_name) = cli.room {
        // 🦆 says ⮞ room action
        let state = cli.state.expect("--state is required for room");
        controller.control_room(
            &room_name,
            &state,
            cli.brightness,
            cli.color,
            cli.temperature,
        )
    } else if let Some(scene_name) = cli.scene {
        // 🦆 says ⮞ Scene action
        controller.activate_scene(&scene_name, cli.random)?;
        Ok(())
    } else if let Some(list_arg) = cli.list {
        let what = list_arg.unwrap_or(ListType::Devices);
        controller.list_items(&what, cli.json_output);
        Ok(())
    } else if let Some(pair_arg) = cli.pair {
        // 🦆 says ⮞ pair action
        let duration = pair_arg.unwrap_or(120);
        controller.enter_pairing_mode(duration, cli.watch)
    } else if cli.all_lights {
        // 🦆 says ⮞ all lights action
        let state = cli.state.expect("--state is required for all-lights");
        controller.control_all_lights(&state, cli.brightness, cli.color)
    } else if let Some(room_name) = cli.cheap_mode {
        // 🦆 says ⮞ cheap mode action
        controller.cheap_mode(&room_name, cli.delay)
    } else if cli.json_cmd {
        // 🦆 says ⮞ JSON command (requires --device and --payload)
        let device_name = cli.device.expect("--device is required for JSON command");
        let payload = cli.payload.expect("--payload is required for JSON command");
        controller.control_device_with_json(&device_name, &payload, &cli.backend)
    } else { unreachable!("No action specified"); }
}
