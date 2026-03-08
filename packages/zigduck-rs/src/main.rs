use std::{
    collections::HashMap,
    fs,
    process::Command,
    sync::{Arc, RwLock},
    time::{Duration, SystemTime, UNIX_EPOCH},
};
use chrono::{Local, Timelike};
use rumqttc::{Client, Event, Incoming, MqttOptions, QoS};
use serde::{Deserialize, Serialize};
use serde_json::{json, Value};
use tokio::time;
use ducktrace_logger::*;

#[derive(Debug, Clone, Serialize, Deserialize)]
struct HouseConfig {
    dimmer: DimmerConfig,
    dark_time: DarkTimeConfig,
    //greeting: GreetingConfig,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct DimmerConfig {
    message_key: String,
    actions: DimmerActions,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct DimmerActions {
    on_press: String,
    on_hold: String,
    off_press: String,
    off_hold: String,
    up_press: String,
    up_hold: String,
    down_press: String,
    down_hold: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct DarkTimeConfig {
    enabled: bool,
    after: u32,    // 🦆 says ⮞ hour (0-23)
    before: u32,   // 🦆 says ⮞ hour (0-23)
    duration: u64, // 🦆 says ⮞ seconds
}


#[derive(Debug, Clone, Serialize, Deserialize)]
struct Device {
    room: String,
    #[serde(rename = "type")]
    device_type: String,
    id: String,
    endpoint: u32,
    ieee: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct SceneConfig {
    scenes: HashMap<String, HashMap<String, serde_json::Value>>,
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

// 🦆 says ⮞ Dashboard card configuration
#[derive(Debug, Clone, Serialize, Deserialize)]
struct DashboardCardConfig {
    enable: bool,
    title: String,
    icon: String,
    color: String,
    on_click_action: Vec<AutomationAction>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct DashboardConfig {
    cards: HashMap<String, DashboardCardConfig>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
struct GreetingAutomation {
    enable: bool,
    away_duration: u64,
    delay: u64,
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

#[derive(Debug)]
struct ZigduckState {
    mqtt_broker: String,
    mqtt_user: String,
    mqtt_password: String,
    dashboard_config: DashboardConfig,
    state_dir: String,
    state_file: String,
    devices: HashMap<String, Device>,
    scene_config: SceneConfig,
    automations: AutomationConfig,
    motion_tracker: MotionTracker,
    motion_timers: HashMap<String, tokio::task::JoinHandle<()>>,
    processing_times: HashMap<String, u128>,
    message_counts: HashMap<String, u64>,
    total_messages: u64,
    debug: bool,
    device_states: Arc<RwLock<HashMap<String, HashMap<String, String>>>>,
    config: HouseConfig,
}

impl Clone for ZigduckState {
    fn clone(&self) -> Self {
        Self {
            mqtt_broker: self.mqtt_broker.clone(),
            mqtt_user: self.mqtt_user.clone(),
            mqtt_password: self.mqtt_password.clone(),
            dashboard_config: self.dashboard_config.clone(),
            state_dir: self.state_dir.clone(),
            state_file: self.state_file.clone(),
            devices: self.devices.clone(),
            scene_config: self.scene_config.clone(),
            automations: self.automations.clone(),
            motion_tracker: self.motion_tracker.clone(),
            motion_timers: HashMap::new(),
            processing_times: self.processing_times.clone(),
            message_counts: self.message_counts.clone(),
            total_messages: self.total_messages,
            debug: self.debug,
            device_states: self.device_states.clone(),
            config: self.config.clone(),
        }
    }
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
    greeting: Option<GreetingAutomation>,
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
                    dt_debug!("Triggering MQTT automation: {}", automation.description);
                    for action in &automation.actions {
                        if let Err(e) = self.execute_automation_action_mqtt(action, "mqtt_triggered", "global", topic, payload) {
                            dt_debug!("Error executing MQTT automation action: {}", e);
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
                        dt_debug!("Error executing time-based automation: {}", e);
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
                        dt_debug!("Error executing presence automation: {}", e);
                    }
                }
            }
        }
    }

    fn update_motion_tracker(&mut self, sensor_name: &str) {
        self.motion_tracker.last_motion.insert(sensor_name.to_string(), SystemTime::now());
    }

    // 🦆 says ⮞ don't run default light actions if user defined automations in nix config
    fn has_motion_automation_for_room(&self, room: &str) -> bool {
        self.automations.room_actions
            .get(room)
            .and_then(|actions| actions.get("motion_detected"))
            .map(|actions| !actions.is_empty())
            .unwrap_or(false)
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
                        dt_debug!("Running override actions for {} in {}", action, room);
                        for override_action in &config.override_actions {
                            self.execute_automation_action(override_action, device_name, room)?;
                        }
                        executed = true;
                    } else {
                        // 🦆 says ⮞ if no overrides - default + extra actions
                        dt_debug!("Running default + extra actions for {} in {}", action, room);
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
                    dt_debug!("Actions disabled for {} in {}", action, room);
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
                            dt_debug!("Running default override actions for {}", action);
                            for override_action in &config.override_actions {
                                self.execute_automation_action(override_action, device_name, room)?;
                            }
                            executed = true;
                        } else {
                            dt_debug!("Running default actions for {}", action);
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
            dt_debug!("Running fallback default for {} in {}", action, room);
            if let Some(action_fn) = default_action.take() {
                action_fn(room)?;
            }
        }
        Ok(())
    }

    // 🦆 says ⮞ NEW NEW NEW ZigduckState::new new new
    fn new(mqtt_broker: String, mqtt_user: String, mqtt_password: String,
           state_dir: String, devices_file: String, automations_file: String,
           debug: bool) -> Self {

        let config_path = std::env::var("HOUSE_CONFIG_FILE")
            .unwrap_or_else(|_| "/etc/zigduck/config.json".to_string());
        let config: HouseConfig = std::fs::read_to_string(&config_path)
            .ok()
            .and_then(|content| serde_json::from_str(&content).ok())
            .unwrap_or_else(|| {
                dt_error!("Failed to load house config from {}", config_path);
                std::process::exit(1);
            });

        let state_file = format!("{}/state.json", state_dir);

        std::fs::create_dir_all(&state_dir).unwrap_or_else(|e| {
            dt_error!("Failed to create state directory {}: {}", state_dir, e);
            std::process::exit(1);
        });

        if !std::path::Path::new(&state_file).exists() {
            std::fs::write(&state_file, "{}").unwrap_or_else(|e| {
                dt_error!("Failed to create state file {}: {}", state_file, e);
                std::process::exit(1);
            });
        }

        let scene_config_path = std::env::var("SCENE_CONFIG_FILE")
            .unwrap_or_else(|_| "/etc/zigduck/scenes.json".to_string());

        let scene_config: SceneConfig = std::fs::read_to_string(&scene_config_path)
            .ok()
            .and_then(|content| serde_json::from_str(&content).ok())
            .unwrap_or_else(|| {
                dt_warning!("Failed to load scene config from {}", scene_config_path);
                SceneConfig { scenes: HashMap::new() }
            });

        let devices_json = std::fs::read_to_string(&devices_file)
            .unwrap_or_else(|e| {
                dt_warning!("Failed to read devices file {}: {}", devices_file, e);
                "{}".to_string()
            });

        let raw_devices: std::collections::HashMap<String, serde_json::Value> = serde_json::from_str(&devices_json)
            .unwrap_or_else(|e| {
                dt_warning!("Failed to parse devices JSON from {}: {}", devices_file, e);
                std::collections::HashMap::new()
            });

        let mut devices = std::collections::HashMap::new();
        for (friendly_name, device_value) in raw_devices {
            match serde_json::from_value::<Device>(device_value.clone()) {
                Ok(device) => {
                    devices.insert(friendly_name, device);
                }
                Err(e) => {
                    dt_debug!("Failed to parse device {}: {}", friendly_name, e);
                }
            }
        }

        dt_info!("Loaded {} devices from {}", devices.len(), devices_file);
        dt_info!("State directory: {}", state_dir);
        dt_info!("State file: {}", state_file);

        let automations_json = std::fs::read_to_string(&automations_file)
            .unwrap_or_else(|e| {
                dt_warning!("Failed to read automations file {}: {}", automations_file, e);
                "{\"dimmer_actions\":{},\"room_actions\":{},\"global_actions\":{}}".to_string()
            });

        let automations: AutomationConfig = serde_json::from_str(&automations_json)
            .unwrap_or_else(|e| {
                dt_warning!("Failed to parse automations JSON: {}", e);
                AutomationConfig {
                    dimmer_actions: HashMap::new(),
                    room_actions: HashMap::new(),
                    global_actions: HashMap::new(),
                    time_based: HashMap::new(),
                    mqtt_triggered: HashMap::new(),
                    presence_based: HashMap::new(),
                    greeting: None,
                }
            });

        let motion_tracker = MotionTracker {
            last_motion: HashMap::new(),
        };

        let dashboard_config_path = std::env::var("DASHBOARD_CONFIG_FILE")
            .unwrap_or_else(|_| "/etc/zigduck/dashboard.json".to_string());

        let dashboard_config: DashboardConfig = std::fs::read_to_string(&dashboard_config_path)
            .ok()
            .and_then(|content| serde_json::from_str(&content).ok())
            .unwrap_or_else(|| {
                dt_warning!("Failed to load dashboard config from {}", dashboard_config_path);
                DashboardConfig { cards: HashMap::new() }
            });

        let device_states = Arc::new(RwLock::new(HashMap::new()));

        if let Ok(content) = std::fs::read_to_string(&state_file) {
            if let Ok(existing) = serde_json::from_str::<HashMap<String, HashMap<String, String>>>(&content) {
                let mut states = device_states.write().unwrap();
                *states = existing;
            }
        }

        Self {
            mqtt_broker,
            mqtt_user,
            mqtt_password,
            state_dir,
            state_file,
            dashboard_config,
            devices,
            scene_config,
            automations,
            processing_times: HashMap::new(),
            message_counts: HashMap::new(),
            total_messages: 0,
            motion_tracker,
            motion_timers: HashMap::new(),
            debug,
            device_states,
            config,
        }
    }

    // 🦆 says ⮞ sset scene
    fn activate_scene(&self, scene_name: &str) -> Result<(), Box<dyn std::error::Error>> {
        if self.scene_config.scenes.contains_key(scene_name) {
            dt_debug!("🎨 Activating scene: {}", scene_name);

            let output = std::process::Command::new("nqtt")
                .arg("--scene")
                .arg(scene_name)
                .output()?;

            if output.status.success() {
                if self.debug {
                    let stdout = String::from_utf8_lossy(&output.stdout);
                    let stderr = String::from_utf8_lossy(&output.stderr);
                    dt_debug!("stdout: {}", stdout);
                    if !stderr.is_empty() {
                        dt_debug!("stderr: {}", stderr);
                    }
                }
            } else {
                let stderr = String::from_utf8_lossy(&output.stderr);
                let error_msg = format!("Failed to activate scene: {}", stderr);
                dt_debug!("{}", error_msg);
                return Err(error_msg.into());
            }

            Ok(())
        } else {
            let error_msg = format!("Scene '{}' not found", scene_name);
            dt_info!("{}", error_msg);
            Err(error_msg.into())
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
        dt_debug!("Executing automation action for {} in {}", device_name, room);

        // 🦆 says ⮞ set MQTT environment variables for shell actions
        std::env::set_var("AUTOMATION_DEVICE", device_name);
        std::env::set_var("AUTOMATION_ROOM", room);
        std::env::set_var("MQTT_TOPIC", topic);
        std::env::set_var("MQTT_PAYLOAD", payload);
        std::env::set_var("MQTT_DEVICE", device_name);
        std::env::set_var("MQTT_ROOM", room);

        if let Ok(data) = serde_json::from_str::<serde_json::Value>(payload) {
            if let Some(action_val) = data.get("action").and_then(|v| v.as_str()) {
                std::env::set_var("MQTT_ACTION", action_val);
            }
            if let Some(state_val) = data.get("state").and_then(|v| v.as_str()) {
                std::env::set_var("MQTT_STATE", state_val);
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
                    dt_debug!("Shell command failed: {}", String::from_utf8_lossy(&output.stderr));
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
                                dt_debug!("Shell command failed: {}", String::from_utf8_lossy(&output.stderr));
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
        dt_debug!("Executing automation action for {} in {}", device_name, room);

        // 🦆 says ⮞ set MQTT environment variables for shell actions
        std::env::set_var("AUTOMATION_DEVICE", device_name);
        std::env::set_var("AUTOMATION_ROOM", room);

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
                    dt_info!("Shell command failed: {}", String::from_utf8_lossy(&output.stderr));
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
                                dt_debug!("Shell command failed: {}", String::from_utf8_lossy(&output.stderr));
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
        let away_duration = self.automations.greeting
            .as_ref()
            .map(|g| g.away_duration)
            .unwrap_or(7200);
        time_diff <= away_duration
    }

    fn update_device_state(&self, device: &str, key: &str, value: &str) -> Result<(), Box<dyn std::error::Error>> {
        let mut states = self.device_states.write().unwrap();
        let device_map = states.entry(device.to_string()).or_insert_with(HashMap::new);
        device_map.insert(key.to_string(), value.to_string());
        Ok(())
    }

    fn get_state(&self, device: &str, key: &str) -> Option<String> {
        let states = self.device_states.read().unwrap();
        states.get(device)?.get(key).cloned()
    }

    // 🦆 says ⮞ STATE UPDATES
    fn update_device_state_from_data(&self, device_name: &str, data: &Value) -> Result<(), Box<dyn std::error::Error>> {
        // 🦆 says ⮞ skip set/availability topics
        if device_name.ends_with("/set") || device_name.ends_with("/availability") {
            dt_debug!("Skipping state update for {} (set/availability topic)", device_name);
            return Ok(());
        }

        dt_debug!("Updating all state fields for: {}", device_name);

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

        // 🌡️ Temperature
        if let Some(temperature) = data["temperature"].as_f64() {
            let temp_str = format!("{:.1}", temperature); // optional: round to 1 decimal
            let prev = self.get_state(device_name, "temperature");
            if prev.as_deref() != Some(&temp_str) && prev.is_some() {
                dt_debug!("🌡️ Temperature: {}: {}°C → {}°C",
                    device_name, prev.unwrap(), temperature);
            }
            self.update_device_state(device_name, "temperature", &temp_str)?;
        }

        // 🔋 Battery
        if let Some(battery) = data["battery"].as_u64() {
            let battery_str = battery.to_string();
            let prev = self.get_state(device_name, "battery");
            if prev.as_deref() != Some(&battery_str) && prev.is_some() {
                dt_info!("🔋 Battery: {}: {}% → {}%",
                    device_name, prev.unwrap(), battery);
            }
            self.update_device_state(device_name, "battery", &battery_str)?;
        }

        // ⚡ Power
        if let Some(power) = data["power"].as_f64() {
            let power_str = power.to_string();
            let prev = self.get_state(device_name, "power");
            if prev.as_deref() != Some(&power_str) && prev.is_some() {
                dt_debug!("⚡ Power: {}: {}W → {}W", device_name, prev.unwrap(), power);
            }
            self.update_device_state(device_name, "power", &power_str)?;
        }

        // ⚡ Energy
        if let Some(energy) = data["energy"].as_f64() {
            let energy_str = energy.to_string();
            let prev = self.get_state(device_name, "energy");
            if prev.as_deref() != Some(&energy_str) && prev.is_some() {
                dt_debug!("🔋 Energy: {}: {} kWh → {} kWh", device_name, prev.unwrap(), energy);
            }
            self.update_device_state(device_name, "energy", &energy_str)?;
        }

        // ⚡ Voltage
        if let Some(voltage) = data["voltage"].as_f64() {
            let voltage_str = voltage.to_string();
            let prev = self.get_state(device_name, "voltage");
            if prev.as_deref() != Some(&voltage_str) && prev.is_some() {
                dt_debug!("⚡ Voltage: {}: {}V → {}V", device_name, prev.unwrap(), voltage);
            }
            self.update_device_state(device_name, "voltage", &voltage_str)?;
        }

        // 🔋 Charging
        if let Some(charging) = data["charging"].as_u64() {
            let charging_str = charging.to_string();
            let prev = self.get_state(device_name, "charging");
            if prev.as_deref() != Some(&charging_str) && prev.is_some() {
                dt_debug!("🔋 Charging: {}: {} → {}", device_name, prev.unwrap(), charging);
            }
            self.update_device_state(device_name, "charging", &charging_str)?;
        }

        if let Some(smoke) = data["smoke"].as_bool() {
            self.update_device_state(device_name, "smoke", &smoke.to_string())?;
        }
        // 🦆 says ⮞ update last_seen
        let timestamp = SystemTime::now().duration_since(UNIX_EPOCH).unwrap().as_secs();
        self.update_device_state(device_name, "last_updated", &timestamp.to_string())?;

        Ok(())
    }

    // 🦆 says ⮞ MQTT PUBLISH
    fn mqtt_publish(&self, topic: &str, message: &str) -> Result<(), Box<dyn std::error::Error>> {
        dt_debug!("Publishing to {}: {}", topic, message);
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
            let stderr = String::from_utf8_lossy(&output.stderr);
            dt_info!("MQTT publish failed to {}: {}", topic, stderr);
            return Err(format!("MQTT publish failed: {}", String::from_utf8_lossy(&output.stderr)).into());
        }
        Ok(())
    }


    // 🦆 says ⮞ TURN ON ROOM LIGHTS qwack
    fn room_lights_on(&self, room: &str) -> Result<(), Box<dyn std::error::Error>> {
        for (device_id, device) in &self.devices {
            if device.room == room && device.device_type == "light" {
                let message = json!({ "state": "ON" });
                let topic = format!("zigbee2mqtt/{}/set", device_id);
                if let Err(e) = self.mqtt_publish(&topic, &message.to_string()) {
                    dt_info!("Failed to turn on {}: {}", device_id, e);
                    // 🦆 says ⮞ continue
                }
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
                if let Err(e) = self.mqtt_publish(&topic, &message.to_string()) {
                    dt_info!("Failed to turn on {}: {}", device_id, e);
                    // continue
                }
            }
        }
        Ok(())
    }

    // 🦆 says ⮞ check if dark (static time configured)
    fn is_dark_time(&self) -> bool {
        // 🦆 says ⮞ if dark time is disabled, it's always dark
        if !self.config.dark_time.enabled {
            return true;
        }
        let now = Local::now();
        let hour = now.hour();
        // after🦆16:00⮞before⮜09:00🦆
        hour >= self.config.dark_time.after || hour <= self.config.dark_time.before
    }

    fn update_performance_stats(&mut self, topic: &str, duration: u128) {
        let current_avg = self.processing_times.get(topic).copied().unwrap_or(0);
        self.processing_times.insert(topic.to_string(), (current_avg + duration) / 2);
        *self.message_counts.entry(topic.to_string()).or_insert(0) += 1;
        self.total_messages += 1;
        if duration > 100 {
            dt_info!("[🦆📶] - SLOW PROCESSING: {} took {}ms", topic, duration);
        }

        if self.total_messages % 100 == 0 {
            dt_debug!("[🦆📶] - Total messages: {}", self.total_messages);
            for (topic_type, avg_time) in &self.processing_times {
                let count = self.message_counts.get(topic_type).unwrap_or(&0);
                dt_debug!("{}: avg {}ms, count {}", topic_type, avg_time, count);
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
                if let Err(e) = self.mqtt_publish(&topic, &Value::Object(message).to_string()) {
                    dt_info!("Failed to control {}: {}", device_id, e);
                    // continue
                }
            }
        }
        let action = if state == "ON" { "ON" } else { "OFF" };
        dt_info!("💡 All lights turned {}", action);
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

    // 🦆 says ⮞ unified devices controller (hue api/zigbee2mqtt)
    fn handle_device_command<'a>(
        &'a self,
        device_id: &'a str,
        payload: &'a str,
    ) -> std::pin::Pin<Box<dyn std::future::Future<Output = Result<(), Box<dyn std::error::Error>>> + 'a>> {
        Box::pin(async move {
            let data: Value = match serde_json::from_str(payload) {
                Ok(d) => d,
                Err(e) => {
                    dt_debug!("Failed to parse payload: {}", e);
                    return Ok(());
                }
            };

            let normalize = |s: &str| s.to_lowercase().trim_start_matches("0x").to_string();
            let incoming_norm = normalize(device_id);

            let mut resolved_device = None;

            for (_key, info) in &self.devices {
                // 🦆 says ⮞ match by ieee
                if normalize(&info.id) == incoming_norm {
                    resolved_device = Some(info);
                    break;
                }

                // 🦆 says ⮞ match by stored IEEE
                if let Some(ieee) = &info.ieee {
                    if normalize(ieee) == incoming_norm {
                        resolved_device = Some(info);
                        break;
                    }
                }

                // 🦆 says ⮞ match by friendly name
                if info.id.eq_ignore_ascii_case(device_id) {
                    resolved_device = Some(info);
                    break;
                }
            }

            let device_info = match resolved_device {
                Some(d) => d,
                None => {
                    dt_info!("❌ Device not found: {}", device_id);
                    dt_info!("Available devices: {:?}", self.devices.keys().collect::<Vec<_>>());
                    return Ok(());
                }
            };

            // 🦆 says ⮞ routing
            match device_info.device_type.as_str() {
                "hue_light" => {
                    let mut hue_payload = serde_json::Map::new();

                    if let Some(state) = data.get("state").and_then(|v| v.as_str()) {
                        hue_payload.insert("on".into(), Value::Bool(state.eq_ignore_ascii_case("on")));
                    }

                    if let Some(brightness) = data.get("brightness").and_then(|v| v.as_u64()) {
                        let bri = if brightness > 100 {
                            brightness.clamp(0, 254)
                        } else {
                            ((brightness as f64 / 100.0) * 254.0).round() as u64
                        };
                        hue_payload.insert("bri".into(), Value::Number(bri.into()));
                    }

                    if let Some(transition) = data.get("transition").and_then(|v| v.as_f64()) {
                        hue_payload.insert(
                            "transitiontime".into(),
                            Value::Number(((transition * 100.0).round() as u64).into()),
                        );
                    }

                    if hue_payload.contains_key("on") && !hue_payload.contains_key("bri") {
                        hue_payload.insert("bri".into(), Value::Number(254.into()));
                    }

                    let hue_json = serde_json::to_string(&Value::Object(hue_payload))?;
                    dt_debug!("Hue payload: {}", hue_json);

                    let output = std::process::Command::new("nqtt")
                        .arg("--device")
                        .arg(&device_info.id)
                        .arg("--json")
                        .arg(&hue_json)
                        .output()?;

                    if !output.status.success() {
                        dt_debug!("Hue failed: {}", String::from_utf8_lossy(&output.stderr));
                    }
                }

                // 🦆 says ⮞ not hue? publish to mqtt
                _ => {
                    let topic = format!("zigbee2mqtt/{}/set", device_info.id);
                    dt_debug!("MQTT → {}", topic);
                    self.mqtt_publish(&topic, payload)?;
                }
            }

            Ok(())
        })
    }

    // 🦆 says ⮞ PROCESS MQTT MESSAGES
    async fn process_message(&mut self, topic: &str, payload: &str) -> Result<(), Box<dyn std::error::Error>> {
        // 🦆 says ⮞ start timer 4 exec time messurementz
        let start_time = std::time::Instant::now();
        // 🦆 says ⮞ skip large payloads
        if payload.len() > 10000 {
            dt_debug!("Skipping large payload on topic: {} (size: {})", topic, payload.len());
            return Ok(());
        }

        // 🦆 says ⮞ MQTT TRIGGERED AUTOMATIONS
        if let Err(e) = self.check_mqtt_triggered_automations(topic, payload).await {
            dt_info!("Error checking MQTT automations: {}", e);
        }

        // 🦆 says ⮞ debug log raw payloadz yo
        dt_debug!("TOPIC: {}", topic);
        dt_debug!("PAYLOAD: {}", payload);
        let data: Value = match serde_json::from_str(payload) {
            Ok(parsed) => parsed,
            Err(_) => {
                dt_debug!("Invalid JSON payload: {}", payload);
                return Ok(());
            }
        };

        // 🦆 says ⮞ unified hue & z2m topic
        if topic.starts_with("zigbee2mqtt/device_command/") {
            let device_id = topic.strip_prefix("zigbee2mqtt/device_command/").unwrap_or("");
            if !device_id.is_empty() {
                return self.handle_device_command(device_id, payload).await;
            }
        }

        // 🦆 says ⮞ dashboard status card clicks automations
        if topic.starts_with("zigbee2mqtt/dashboard/card/") && topic.ends_with("/click") {
            let card_name = topic
                .strip_prefix("zigbee2mqtt/dashboard/card/")
                .and_then(|s| s.strip_suffix("/click"))
                .unwrap_or("");

            if !card_name.is_empty() {
                dt_info!("Dashboard card clicked: {}", card_name);

                // 🦆 says ⮞ parse payload 2 get click data
                if let Ok(data) = serde_json::from_str::<Value>(payload) {
                    if let Some(card_config) = self.dashboard_config.cards.get(card_name) {
                        if card_config.enable {
                            for action in &card_config.on_click_action {
                                if let Err(e) = self.execute_automation_action_mqtt(action, card_name, "dashboard", topic, payload) {
                                    dt_debug!("Error executing dashboard card action: {}", e);
                                }
                            }
                        } else {
                            dt_debug!("Card {} is disabled", card_name);
                        }
                    } else {
                        dt_debug!("No configuration found for card: {}", card_name);
                    }
                }
            }
            return Ok(());
        }

        // 🦆 says ⮞ dashboard triggered scene activation
        if topic.starts_with("zigbee2mqtt/scene/") {
            let scene_name = topic.strip_prefix("zigbee2mqtt/scene/").unwrap_or("");

            if !scene_name.is_empty() {
                dt_debug!("Activating scene: {}", scene_name);

                if let Err(e) = self.activate_scene(scene_name) {
                    dt_warning!("Error activating scene: {}", e);
                }
            }
            return Ok(());
        }

        // 🦆 says ⮞ tv
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
                    dt_info!("📺 {} live tv channel: {}", device_ip, channel_name);
                }
            }
            return Ok(());
        }

        let device_name = topic.strip_prefix("zigbee2mqtt/").unwrap_or(topic);

        // 🦆 says ⮞ STATE UPDATES
        if let Err(e) = self.update_device_state_from_data(device_name, &data) {
            dt_debug!("Failed to update device state: {}", e);
        }

        if let Some(device) = self.devices.get(device_name) {
            let room = device.room.clone();
            let device_type = device.device_type.clone();

            // 🦆 says ⮞ ❤️‍🔥 FIRE / SMOKE DETECTOR
            if let Some(smoke) = data["smoke"].as_bool() {
                if smoke {
                    self.execute_automations("smoke", "smoke_detected", device_name, &room)?;
                    dt_info!("❤️‍🔥❤️‍🔥 SMOKE! in {} {}", device_name, room);
                }
            }

            // 🦆 says ⮞ 🕵️ MOTION SENSORS
            if let Some(occupancy) = data["occupancy"].as_bool() {
                if occupancy {
                    let motion_data = json!({
                        "last_active_room": room,
                        "timestamp": Local::now().to_rfc3339()
                    });

                    if let Err(e) = fs::write(format!("{}/last_motion.json", self.state_dir), motion_data.to_string()) {
                        dt_info!("Failed to write last_motion.json: {}", e);
                    }

                    dt_debug!("🕵️ Motion in {} {}", device_name, room);

                    self.execute_automations("motion", "motion_detected", device_name, &room)?;
                    let timestamp = SystemTime::now().duration_since(UNIX_EPOCH).unwrap().as_secs();
                    self.update_device_state("apartment", "last_motion", &timestamp.to_string())?;

                    if self.is_dark_time() {
                        if let Some(existing_timer) = self.motion_timers.remove(&room) {
                            existing_timer.abort();
                            dt_debug!("⏰ Cancelled existing timer for {}", room);
                        }
                        self.set_motion_triggered(&room, true)?;
                        if !self.has_motion_automation_for_room(&room) {
                            self.room_lights_on(&room)?;
                        }
                    } else {
                        dt_debug!("❌ Daytime - no lights activated by motion.");
                    }
                } else {
                    dt_debug!("🛑 No more motion in {} {}", device_name, room);
                    self.execute_automations("motion", "motion_not_detected", device_name, &room)?;

                    if self.is_motion_triggered(&room) {
                        dt_debug!("⏰ Motion stopped in {}, will turn off lights in {}s", room, self.config.dark_time.duration);
                        let room_clone = room.clone();
                        let state_clone = std::sync::Arc::new(self.clone());
                        let duration = self.config.dark_time.duration;
                        let timer_handle = tokio::spawn(async move {
                            tokio::time::sleep(Duration::from_secs(duration)).await;
                            if state_clone.is_motion_triggered(&room_clone) {
                                dt_debug!("💡 Turning off motion-triggered lights in {}", room_clone);
                                let _ = state_clone.room_lights_off(&room_clone);
                                let _ = state_clone.set_motion_triggered(&room_clone, false);
                            }
                        });
                        self.motion_timers.insert(room.clone(), timer_handle);
                    }
                }
            }

            // 🦆 says ⮞ 💧 WATER SENSORS
            if data["water_leak"].as_bool() == Some(true) || data["waterleak"].as_bool() == Some(true) {
                dt_info!("💧 WATER LEAK DETECTED in {} on {}", room, device_name);
                self.execute_automations("water_leak", "leak_detected", device_name, &room)?;
            }

            // 🦆 says ⮞ DOOR / WINDOW SENSOR
            if let Some(contact) = data["contact"].as_bool() {
                if !contact {
                    dt_info!("🚪 Door open in {} ({})", room, device_name);
                    self.execute_automations("contact", "door_opened", device_name, &room)?;
                    let current_time = SystemTime::now().duration_since(UNIX_EPOCH).unwrap().as_secs();
                    let last_motion_str = self.get_state("apartment", "last_motion").unwrap_or_else(|| "0".to_string());
                    let last_motion: u64 = last_motion_str.parse().unwrap_or(0);
                    let time_diff = current_time.saturating_sub(last_motion);
                    dt_debug!("TIME: {} | LAST MOTION: {} | TIME DIFF: {}", current_time, last_motion, time_diff);

                    if let Some(greeting) = &self.automations.greeting {
                        if greeting.enable && time_diff > greeting.away_duration {
                            dt_info!("Welcoming you home! (no motion for {} seconds)", greeting.away_duration);
                            tokio::time::sleep(Duration::from_secs(greeting.delay)).await;
                            for action in &greeting.actions {
                                if let Err(e) = self.execute_automation_action(action, "greeting", "global") {
                                    dt_debug!("Error executing greeting action: {}", e);
                                }
                            }
                        }
                    } else {
                        dt_debug!("🛑 NOT WELCOMING: only {} minutes since last motion", time_diff / 60);
                    }
                } else {
                    self.execute_automations("contact", "door_closed", device_name, &room)?;
                }
            }

            // 🦆 says ⮞ BLINDz
            if let Some(position) = data["position"].as_u64() {
                if device_type == "blind" {
                    if position == 0 {
                        dt_info!("🪟 Rolled DOWN {} in {}", device_name, room);
                    } else if position == 100 {
                        dt_info!("🪟 Rolled UP {} in {}", device_name, room);
                    } else {
                        dt_info!("🪟 {} positioned at {}% in {}", device_name, position, room);
                    }
                }
            }

            // 🦆 says ⮞ STATE
            if let Some(state) = data["state"].as_str() {
                match device_type.as_str() {
                    "outlet" => {
                        if state == "ON" {
                            dt_debug!("🔌 {} Turned ON in {}", device_name, room);
                        } else if state == "OFF" {
                            dt_debug!("🔌 {} Turned OFF in {}", device_name, room);
                        }
                    }
                    "light" => {
                        if state == "ON" {
                            dt_debug!("💡 {} Turned ON in {}", device_name, room);
                        } else if state == "OFF" {
                            dt_debug!("💡 {} Turned OFF in {}", device_name, room);
                        }
                    }
                    _ => {
                        if state == "ON" {
                            dt_debug!("⚡ {} Turned ON in {}", device_name, room);
                        } else if state == "OFF" {
                            dt_debug!("⚡ {} Turned OFF in {}", device_name, room);
                        }
                    }
                }
            }

            // 🦆 says ⮞ 🎚 DIMMER SWITCH
            if let Some(action) = data[&self.config.dimmer.message_key].as_str() {
                if action == self.config.dimmer.actions.on_press {
                    self.handle_room_dimmer_action(action, device_name, &room, |room| {
                        dt_info!("💡 Turning on lights in {}", room);
                        self.room_lights_on(room)
                    })?;
                } else if action == self.config.dimmer.actions.on_hold {
                    self.handle_room_dimmer_action(action, device_name, &room, |_| {
                        self.control_all_lights("ON", Some(254))?;
                        dt_info!("✅💡 MAX LIGHTS ON");
                        Ok(())
                    })?;
                } else if action == self.config.dimmer.actions.off_press {
                    self.handle_room_dimmer_action(action, device_name, &room, |room| {
                        dt_info!("💡 Turning off lights in {}", room);
                        self.room_lights_off(room)
                    })?;
                } else if action == self.config.dimmer.actions.off_hold {
                    self.handle_room_dimmer_action(action, device_name, &room, |_| {
                        self.control_all_lights("OFF", None)?;
                        dt_info!("🦆 DARKNESS ON");
                        Ok(())
                    })?;
                } else if action == self.config.dimmer.actions.up_press {
                    self.handle_room_dimmer_action(action, device_name, &room, |room| {
                        for (light_id, light_device) in &self.devices {
                            if light_device.room == room && light_device.device_type == "light" {
                                dt_info!("🔺 Increasing brightness on {} in {}", light_id, room);
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
                } else if action == self.config.dimmer.actions.down_press {
                    self.handle_room_dimmer_action(action, device_name, &room, |room| {
                        for (light_id, light_device) in &self.devices {
                            if light_device.room == room && light_device.device_type == "light" {
                                dt_info!("🔻 Decreasing {} in {}", light_id, room);
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
                } else if action == self.config.dimmer.actions.up_hold || action == self.config.dimmer.actions.down_hold {
                    self.handle_room_dimmer_action(action, device_name, &room, |_| {
                        dt_debug!("{} in {}", action, room);
                        Ok(())
                    })?;
                } else {
                    dt_debug!("Unhandled dimmer action: {}", action);
                }
            }
        }

        let duration = start_time.elapsed().as_millis();
        self.update_performance_stats(topic, duration);
        Ok(())
    }

    async fn start_listening(&mut self) -> Result<(), Box<dyn std::error::Error>> {
        let device_states = self.device_states.clone();
        let state_file = self.state_file.clone();

        tokio::spawn(async move {
            let mut interval = time::interval(Duration::from_secs(5));
            loop {
                interval.tick().await;
                let snapshot = device_states.read().unwrap().clone();
                let state_file = state_file.clone();
                tokio::task::spawn_blocking(move || {
                    let json = serde_json::to_string(&snapshot).unwrap();
                    let tmp = format!("{}.tmp", state_file);
                    let _ = std::fs::write(&tmp, json);
                    let _ = std::fs::rename(&tmp, &state_file);
                }).await.ok();
            }
        });


        dt_info!("🚀 Starting ZigDuck automation system");
        dt_info!("📡 Listening to all Zigbee events...");
        self.start_periodic_checks().await;
        let mut mqttoptions = MqttOptions::new("zigduck-rs", &self.mqtt_broker, 1883);
        mqttoptions.set_credentials(&self.mqtt_user, &self.mqtt_password);
        mqttoptions.set_keep_alive(Duration::from_secs(5));
        // 🦆 says ⮞ max packet size if larger payloads
        mqttoptions.set_max_packet_size(256 * 1024, 256 * 1024); // 🦆 says ⮞ 256KB

        let (mut client, mut connection) = Client::new(mqttoptions, 10);
        client.subscribe("zigbee2mqtt/#", QoS::AtMostOnce)?;

        dt_info!("Connected to MQTT broker: {}", &self.mqtt_broker);
        dt_info!("[🦆🏡] ⮞ Welcome Home");
        // 🦆 says ⮞ main event loop with reconnect yo
        loop {
            match connection.eventloop.poll().await {
                Ok(event) => {
                    if let Event::Incoming(Incoming::Publish(publish)) = event {
                        let topic = publish.topic;
                        let payload = String::from_utf8_lossy(&publish.payload);

                        if let Err(e) = self.process_message(&topic, &payload).await {
                            dt_debug!("Failed to process message: {}", e);
                        }
                    }
                }
                Err(e) => {
                    dt_debug!("Connection error: {}", e);
                    dt_info!("Attempting to reconnect in 5 seconds...");
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
                        Ok(_) => dt_info!("Successfully reconnected and subscribed"),
                        Err(e) => dt_debug!("Failed to subscribe after reconnect: {}", e),
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
    // 🦆 says ⮞ Password: from env var, or from file (configurable path), or empty
    let mqtt_password = std::env::var("MQTT_PASSWORD")
        .or_else(|_| {
            let password_file = std::env::var("MQTT_PASSWORD_FILE")
                .unwrap_or_else(|_| "/run/secrets/mosquitto".to_string());
            std::fs::read_to_string(&password_file)
                .map(|s| s.trim().to_string())
                .map_err(|e| {
                    eprintln!("[🦆📜] ❌ERROR❌ ⮞ Failed to read MQTT password from {}: {}", password_file, e);
                    e
                })
        })
        .unwrap_or_else(|_| {
            eprintln!("[🦆📜] ⚠️ WARNING ⚠️ ⮞ No MQTT password set, proceeding with empty password");
            "".to_string()
        });

    let debug = std::env::var("DEBUG").is_ok();

    // 🦆 says ⮞ static state directory path
    let state_dir = std::env::var("STATE_DIR")
        .unwrap_or_else(|_| "/var/lib/zigduck".to_string());

    let timer_dir = format!("{}/timers", state_dir);
    std::fs::create_dir_all(&timer_dir)?;

    let log_path = format!("{}/zigduck.log", state_dir);
    dt_setup(Some(log_path.as_str()), None);


    // 🦆 says ⮞ Get automations config and dark time setting
    let automations_file = std::env::var("AUTOMATIONS_FILE")
        .unwrap_or_else(|_| "/etc/zigduck/automations.json".to_string());

    // 🦆 says ⮞ read devices from env var
    let devices_file = std::env::var("ZIGBEE_DEVICES_FILE")
        .unwrap_or_else(|_| "/etc/zigduck/devices.json".to_string());

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
        debug,
    );

    // 🦆 says ⮞ simple runtime
    let rt = tokio::runtime::Runtime::new()?;
    rt.block_on(async {
        state.start_listening().await
    })
}
