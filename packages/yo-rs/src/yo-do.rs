// ddotfiles/packages/yo-rs/src/yo-do.rs ⮞ https://github.com/QuackHack-McBlindy/dotfiles
use std::{ // 🦆 says ⮞ yo-do (Shell Translator)
    env,
    fs::{OpenOptions, File},
    io::{self, Write},
    sync::Once,
    time::Instant,
};
use chrono::Local;
use colored::*;

static INIT: Once = Once::new();
static mut LOGGER: Option<DuckTraceLogger> = None;

struct DuckTraceLogger {
    level: LogLevel,
    log_file: Option<File>,
    debug_mode: bool,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd)]
enum LogLevel {
    Debug,
    Info,
    Warning,
    Error,
    Critical,
}

impl DuckTraceLogger {
    fn new(level_str: Option<&str>) -> Self {
        let debug_mode = env::var("DEBUG").is_ok();
        let level = match level_str {
            Some(l) => Self::level_from_str(l),
            None => match env::var("DT_LOG_LEVEL")
                .unwrap_or_else(|_| "INFO".to_string())
                .to_uppercase()
                .as_str()
            {
                "DEBUG" => LogLevel::Debug,
                "WARNING" => LogLevel::Warning,
                "ERROR" => LogLevel::Error,
                "CRITICAL" => LogLevel::Critical,
                _ => LogLevel::Info,
            },
        };
        
        let log_file = Self::setup_log_file();
        
        Self { level, log_file, debug_mode }
    }
    
    fn level_from_str(s: &str) -> LogLevel {
        match s.to_uppercase().as_str() {
            "DEBUG" => LogLevel::Debug,
            "INFO" => LogLevel::Info,
            "WARNING" => LogLevel::Warning,
            "ERROR" => LogLevel::Error,
            "CRITICAL" => LogLevel::Critical,
            _ => LogLevel::Info,
        }
    }
    
    fn setup_log_file() -> Option<File> {
        let log_path = env::var("DT_LOG_PATH")
            .unwrap_or_else(|_| {
                let home = env::var("HOME").unwrap_or_else(|_| ".".to_string());
                format!("{}/.config/duckTrace", home)
            });
        
        std::fs::create_dir_all(&log_path).ok()?;
        
        let log_filename = env::var("DT_LOG_FILE")
            .unwrap_or_else(|_| "unknown.rs-script.log".to_string());
        
        let full_path = format!("{}{}", log_path, log_filename);
        
        OpenOptions::new()
            .create(true)
            .append(true)
            .open(&full_path)
            .ok()
    }
    
    fn should_log(&self, msg_level: LogLevel) -> bool {
        if msg_level == LogLevel::Debug && !self.debug_mode {
            return false;
        }
        msg_level >= self.level
    }
    
    fn get_symbol(&self, level: LogLevel) -> &'static str {
        match level {
            LogLevel::Debug => "⁉️",
            LogLevel::Info => "✅",
            LogLevel::Warning => "⚠️",
            LogLevel::Error => "❌",
            LogLevel::Critical => "🚨",
        }
    }
    
    fn format_message(&self, level: LogLevel, message: &str) -> String {
        let timestamp = Local::now().format("%H:%M:%S");
        let symbol = self.get_symbol(level);
        let level_str = match level {
            LogLevel::Debug => "DEBUG",
            LogLevel::Info => "INFO",
            LogLevel::Warning => "WARNING",
            LogLevel::Error => "ERROR",
            LogLevel::Critical => "CRITICAL",
        };
        
        format!("[🦆📜] [{}] {}{}{} ⮞ {}", 
            timestamp, symbol, level_str, symbol, message)
    }
    
    fn colorize_console(&self, level: LogLevel, formatted_msg: &str) -> String {
        match level {
            LogLevel::Debug => formatted_msg.blue().bold().to_string(),
            LogLevel::Info => formatted_msg.green().bold().to_string(),
            LogLevel::Warning => formatted_msg.yellow().bold().to_string(),
            LogLevel::Error => formatted_msg.red().bold().blink().to_string(),
            LogLevel::Critical => formatted_msg.red().bold().blink().to_string(),
        }
    }
    
    fn add_duck_say(&self, level: LogLevel, message: &str) -> String {
        if matches!(level, LogLevel::Error | LogLevel::Critical) {
            let duck_say = format!(
                "\n\x1b[3m\x1b[38;2;0;150;150m🦆 duck say \x1b[1m\x1b[38;2;255;255;0m⮞\x1b[0m\x1b[3m\x1b[38;2;0;150;150m fuck ❌ {}\x1b[0m",
                message
            );
            duck_say
        } else {
            String::new()
        }
    }
    
    pub fn log(&mut self, level: LogLevel, message: &str) {
        if !self.should_log(level) {
            return;
        }
        
        let formatted = self.format_message(level, message);
        let console_output = self.colorize_console(level, &formatted);
        
        eprintln!("{}", console_output);
        
        if matches!(level, LogLevel::Error | LogLevel::Critical) {
            let duck_say = self.add_duck_say(level, message);
            eprintln!("{}", duck_say);
        }
        
        if let Some(file) = &mut self.log_file {
            let timestamp = Local::now().format("%H:%M:%S");
            let level_str = match level {
                LogLevel::Debug => "DEBUG",
                LogLevel::Info => "INFO",
                LogLevel::Warning => "WARNING",
                LogLevel::Error => "ERROR",
                LogLevel::Critical => "CRITICAL",
            };
            
            let file_msg = format!("[{}] {} - {}\n", timestamp, level_str, message);
            let _ = writeln!(file, "{}", file_msg);
        }
    }
}

pub fn dt_debug(msg: &str) {
    unsafe {
        if LOGGER.is_none() {
            LOGGER = Some(DuckTraceLogger::new(None));
        }
        if let Some(logger) = &mut LOGGER {
            logger.log(LogLevel::Debug, msg);
        }
    }
}

pub fn dt_info(msg: &str) {
    unsafe {
        if LOGGER.is_none() {
            LOGGER = Some(DuckTraceLogger::new(None));
        }
        if let Some(logger) = &mut LOGGER {
            logger.log(LogLevel::Info, msg);
        }
    }
}

pub fn dt_warning(msg: &str) {
    unsafe {
        if LOGGER.is_none() {
            LOGGER = Some(DuckTraceLogger::new(None));
        }
        if let Some(logger) = &mut LOGGER {
            logger.log(LogLevel::Warning, msg);
        }
    }
}

pub fn dt_error(msg: &str) {
    unsafe {
        if LOGGER.is_none() {
            LOGGER = Some(DuckTraceLogger::new(None));
        }
        if let Some(logger) = &mut LOGGER {
            logger.log(LogLevel::Error, msg);
        }
    }
}

pub fn dt_critical(msg: &str) {
    unsafe {
        if LOGGER.is_none() {
            LOGGER = Some(DuckTraceLogger::new(None));
        }
        if let Some(logger) = &mut LOGGER {
            logger.log(LogLevel::Critical, msg);
        }
    }
}

pub fn setup_ducktrace_logging(log_name: Option<&str>, level: Option<&str>) {
    INIT.call_once(|| {
        unsafe {
            LOGGER = Some(DuckTraceLogger::new(level));
        }
    });
}

pub struct TranscriptionTimer {
    operation_name: String,
    start_time: Instant,
}

impl TranscriptionTimer {
    pub fn new(operation_name: &str) -> Self {
        dt_debug(&format!("Starting {}...", operation_name));
        Self {
            operation_name: operation_name.to_string(),
            start_time: Instant::now(),
        }
    }
    
    pub fn lap(&self, lap_name: &str) {
        let elapsed = self.start_time.elapsed().as_secs_f64();
        dt_debug(&format!("{} - {}: {:.3}s", self.operation_name, lap_name, elapsed));
    }
    
    pub fn complete(self) {
        let elapsed = self.start_time.elapsed().as_secs_f64();
        dt_debug(&format!("Completed {} in {:.3}s", self.operation_name, elapsed));
    }
}

macro_rules! duck_log {
    (debug: $($arg:tt)*) => {
        dt_debug(&format!($($arg)*));
    };
    (info: $($arg:tt)*) => {
        dt_info(&format!($($arg)*));
    };
    (warning: $($arg:tt)*) => {
        dt_warning(&format!($($arg)*));
    };
    (error: $($arg:tt)*) => {
        dt_error(&format!($($arg)*));
    };
    (critical: $($arg:tt)*) => {
        dt_critical(&format!($($arg)*));
    };
}





use std::collections::HashMap;
use std::fs;
use std::process::{Command, exit};
use regex::Regex;
use serde::{Deserialize, Serialize};

use tokio_tungstenite::{connect_async, tungstenite::protocol::Message};
use futures_util::{SinkExt, StreamExt};
use serde_json::Value;
use std::sync::Arc;
use tokio::sync::Mutex;

struct TranscriptionClient {
    ws: Option<futures_util::stream::SplitSink<tokio_tungstenite::WebSocketStream<tokio_tungstenite::MaybeTlsStream<tokio::net::TcpStream>>, Message>>,
    nlp_processor: Arc<YoDo>,
}

impl TranscriptionClient {
    async fn new(nlp_processor: Arc<YoDo>) -> Result<Self, Box<dyn std::error::Error>> {
        let (ws_stream, _) = connect_async("ws://localhost:8765").await?;
        let (ws, mut read) = ws_stream.split();
        
        let client = TranscriptionClient {
            ws: Some(ws),
            nlp_processor: nlp_processor.clone(),
        };
        
        // 🦆 says ⮞ start message processing
        tokio::spawn(async move {
            while let Some(message) = read.next().await {
                if let Ok(Message::Text(text)) = message {
                    if let Ok(data) = serde_json::from_str::<Value>(&text) {
                        if data["type"] == "transcription" {
                            if let Some(transcription) = data["text"].as_str() {
                                if !transcription.trim().is_empty() {
                                    // 🦆 says ⮞ process with NLP
                                    let _ = nlp_processor.process_transcription(transcription).await;
                                }
                            }
                        }
                    }
                }
            }
        });
        
        Ok(client)
    }
    
    async fn send_audio_chunk(&mut self, chunk: &[u8], is_final: bool) -> Result<(), Box<dyn std::error::Error>> {
        if let Some(ws) = &mut self.ws {
            let message = serde_json::json!({
                "type": "audio_chunk",
                "chunk": chunk,
                "is_final": is_final,
                "timestamp": chrono::Utc::now().timestamp_millis(),
                "reduce_noise": true
            });
            
            ws.send(Message::Text(message.to_string())).await?;
        }
        Ok(())
    }
}


// 🦆 says ⮞ memory
#[derive(Debug, Clone, Serialize, Deserialize)]
struct MemoryContext {
    last_action: String,
    active_servers: Vec<String>,
    environment: String,
    user_preferences: HashMap<String, String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct CommandHistory {
    recent_commands: Vec<RecentCommand>,
    confirmed_matches: HashMap<String, u32>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct RecentCommand {
    script: String,
    args: String,
    matched_sentence: String,
    match_type: String,
    timestamp: String,
    confirmed: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct MemoryData {
    context: MemoryContext,
    history: CommandHistory,
}

// 🦆 says ⮞ config structs wit da duck wisdom
#[derive(Debug, Clone, Serialize, Deserialize)]
struct ScriptConfig {
    description: String,
    aliases: Vec<String>,
    category: String,
    log_level: String,
    auto_start: bool,
    parameters: Vec<Parameter>,
    help_footer: String,
    code: String,
    voice: Option<VoiceConfig>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct Parameter {
    name: String,
    description: String,
    optional: bool,
    param_type: Option<String>,
    default: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct VoiceConfig {
    enabled: bool,
    priority: i32,
    sentences: Vec<String>,
    lists: HashMap<String, ListConfig>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct ListConfig {
    wildcard: bool,
    values: Vec<ListValue>,
}

// 🦆 says ⮞ entity resolution
#[derive(Debug, Clone, Serialize, Deserialize)]
struct EntityValue {
    r#in: String,  // 🦆 says ⮞ "in" is a keyword so we use raw identifier
    out: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)] 
struct EntityList {
    wildcard: Option<bool>,
    values: Vec<EntityValue>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct VoiceData {
    sentences: Vec<String>,
    lists: HashMap<String, EntityList>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct ScriptIntentData {
    substitutions: Vec<Substitution>,
    sentences: Vec<String>,
    // 🦆 says ⮞ voice data for entity resolution
    voice_data: Option<HashMap<String, VoiceData>>,
}  

#[derive(Debug, Clone, Serialize, Deserialize)]
struct ListValue {
    r#in: String,
    out: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct IntentData {
    substitutions: Vec<Substitution>,
    sentences: Vec<String>,
    lists: HashMap<String, ListConfig>,  
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct Substitution {
    pattern: String,
    value: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct FuzzyIndexEntry {
    script: String,
    sentence: String,
    signature: String,
}

// 🦆 says ⮞ script priority for da optimized processing yo
#[derive(Debug, Clone)]
struct ScriptPriority {
    name: String,
    priority: i32,
    has_complex_patterns: bool,
}

// 🦆 says ⮞ MATCH RESULT wit da duck power!
#[derive(Debug)]
struct MatchResult {
    script_name: String,
    args: Vec<String>,
    matched_sentence: String,
    processing_time: std::time::Duration,
}

#[derive(Clone)]     
struct YoDo {
    scripts: HashMap<String, ScriptConfig>,
    intent_data: HashMap<String, IntentData>,
    fuzzy_index: Vec<FuzzyIndexEntry>,
    processing_order: Vec<ScriptPriority>,
    fuzzy_threshold: i32,
    debug: bool,
    memory_data: MemoryData,  
    split_words: Vec<String>,
    sorry_phrases: Vec<String>,
}


impl YoDo {
    fn new() -> Self {
        let split_words = load_split_words();
        let sorry_phrases = load_sorry_phrases();
        // 🦆 says ⮞ Load memory data
        let memory_data = Self::load_memory_data().unwrap_or_else(|_| {
            // 🦆 says ⮞ Default memory if loading fails
            MemoryData {
                context: MemoryContext {
                    last_action: "".to_string(),
                    active_servers: Vec::new(),
                    environment: "default".to_string(),
                    user_preferences: HashMap::new(),
                },
                history: CommandHistory {
                    recent_commands: Vec::new(),
                    confirmed_matches: HashMap::new(),
                },
            }
        });
    
        Self {
            scripts: HashMap::new(),
            intent_data: HashMap::new(),
            fuzzy_index: Vec::new(),
            processing_order: Vec::new(),
            fuzzy_threshold: 15,
            debug: env::var("DEBUG").is_ok() || env::var("DT_DEBUG").is_ok(),
            memory_data,
            split_words,
            sorry_phrases,
        }
    }

    fn is_wildcard_param(&self, script_name: &str, param_name: &str) -> bool {
        self.intent_data
            .get(script_name)
            .and_then(|intent| intent.lists.get(param_name))
            .map(|list| list.wildcard)
            .unwrap_or(false)
    }

    // 🦆 says ⮞ memory loader (from files)
    fn load_memory_data() -> Result<MemoryData, Box<dyn std::error::Error>> {
        let stats_dir = std::env::var("HOME").unwrap_or_else(|_| ".".to_string()) + "/.local/share/yo/stats";
    
        // 🦆 says ⮞ load da context
        let context_path = format!("{}/current_context.json", stats_dir);
        let context: MemoryContext = if let Ok(file) = std::fs::File::open(&context_path) {
            serde_json::from_reader(file).unwrap_or_else(|_| MemoryContext {
                last_action: "".to_string(),
                active_servers: Vec::new(),
                environment: "default".to_string(),
                user_preferences: HashMap::new(),
            })
        } else {
            MemoryContext {
                last_action: "".to_string(),
                active_servers: Vec::new(),
                environment: "default".to_string(),
                user_preferences: HashMap::new(),
            }
        };
    
        // 🦆 says ⮞ load da command history
        let history_path = format!("{}/command_history.json", stats_dir);
        let history: CommandHistory = if let Ok(file) = std::fs::File::open(&history_path) {
            serde_json::from_reader(file).unwrap_or_else(|_| CommandHistory {
                recent_commands: Vec::new(),
                confirmed_matches: HashMap::new(),
            })
        } else {
            CommandHistory {
                recent_commands: Vec::new(),
                confirmed_matches: HashMap::new(),
            }
        }; 
        Ok(MemoryData { context, history })
    }

    async fn process_transcription(&self, text: &str) -> Result<(), Box<dyn std::error::Error>> {
        dt_info(&format!("Real-time transcription: {}", text));
        
        if let Some(match_result) = self.exact_match(text) {
            self.execute_script(&match_result)?;
        } else if let Some(match_result) = self.fuzzy_match(text) {
            self.execute_script(&match_result)?;
        } else {
            dt_debug(&format!("No command found for: {}", text));
        }
        
        Ok(())
    }
    
    // 🦆 says ⮞ Real-time mode
    pub async fn run_realtime(&mut self) -> Result<(), Box<dyn std::error::Error>> {
        let client = TranscriptionClient::new(Arc::new(self.clone())).await?;
        dt_info("🦆 Real-time NLP mode activated - listening for transcriptions...");
        
        // 🦆 says ⮞ Keep alive
        tokio::time::sleep(tokio::time::Duration::from_secs(3600)).await;
        Ok(())
    }

    // 🦆 says ⮞ never fail but log failz anywayz
    fn log_failed_command(&self, input: &str, fuzzy_candidates: &[(String, String, i32)]) -> Result<(), Box<dyn std::error::Error>> {
        let stats_dir = std::env::var("HOME").unwrap_or_else(|_| ".".to_string()) + "/.local/share/yo/stats";
        let _ = std::fs::create_dir_all(&stats_dir);
        
        let log_file = format!("{}/failed_commands.log", stats_dir);
        let stats_file = format!("{}/command_stats.json", stats_dir);
        
        // 🦆 says ⮞ log to text file
        let timestamp = chrono::Local::now().format("%Y-%m-%d %H:%M:%S");
        let log_entry = format!("[{}] FAILED: '{}'\n", timestamp, input);
        
        if let Ok(mut file) = std::fs::OpenOptions::new().create(true).append(true).open(&log_file) {
            use std::io::Write;
            let _ = file.write_all(log_entry.as_bytes());
        }
        
        // 🦆 says ⮞ update stats
        let mut stats: serde_json::Value = if let Ok(content) = std::fs::read_to_string(&stats_file) {
            serde_json::from_str(&content).unwrap_or_else(|_| {
                serde_json::json!({
                    "failed_commands": {},
                    "successful_commands": {},
                    "fuzzy_matches": {}
                })
            })
        } else {
            serde_json::json!({
                "failed_commands": {},
                "successful_commands": {}, 
                "fuzzy_matches": {}
            })
        };
        
        // 🦆 says ⮞ increment failed command count
        if let Some(failed_commands) = stats.get_mut("failed_commands").and_then(|v| v.as_object_mut()) {
            let count = failed_commands.get(input).and_then(|v| v.as_u64()).unwrap_or(0);
            failed_commands.insert(input.to_string(), serde_json::Value::from(count + 1));
        }
        
        // 🦆 says ⮞ write back updated stats
        if let Ok(content) = serde_json::to_string_pretty(&stats) {
            let _ = std::fs::write(&stats_file, content);
        }
        
        // 🦆 says ⮞ log fuzzy matchin' candidates for analysis
        if !fuzzy_candidates.is_empty() {
            dt_debug(&format!("Fuzzy candidates for '{}':", input));
            for (script, sentence, score) in fuzzy_candidates {
                dt_debug(&format!("  {}%: {} -> {}", score, sentence, script));
            }
        }        
        Ok(())
    }


    // 🦆 says ⮞ log successful command execution
    fn log_successful_command(&self, script_name: &str, args: &[String], processing_time: std::time::Duration) -> Result<(), Box<dyn std::error::Error>> {
        let stats_dir = std::env::var("HOME").unwrap_or_else(|_| ".".to_string()) + "/.local/share/yo/stats";
        let stats_file = format!("{}/command_stats.json", stats_dir);  
        let mut stats: serde_json::Value = if let Ok(content) = std::fs::read_to_string(&stats_file) {
            serde_json::from_str(&content).unwrap_or_else(|_| {
                serde_json::json!({
                    "failed_commands": {},
                    "successful_commands": {},
                    "fuzzy_matches": {}
                })
            })
        } else {
            serde_json::json!({
                "failed_commands": {},
                "successful_commands": {},
                "fuzzy_matches": {}
            })
        }; 
        if let Some(successful_commands) = stats.get_mut("successful_commands").and_then(|v| v.as_object_mut()) {
            let count = successful_commands.get(script_name).and_then(|v| v.as_u64()).unwrap_or(0);
            successful_commands.insert(script_name.to_string(), serde_json::Value::from(count + 1));
        }
        
        if let Ok(content) = serde_json::to_string_pretty(&stats) {
            let _ = std::fs::write(&stats_file, content);
        }     
        Ok(())
    }

    // 🦆 says ⮞ QUACK LOADER - load all the duck data!
    fn load_intent_data(&mut self, intent_data_path: &str) -> Result<(), Box<dyn std::error::Error>> {
        let data = fs::read_to_string(intent_data_path)?;
        self.intent_data = serde_json::from_str(&data)?;
        dt_debug(&format!("🦆 Loaded intent data for {} scripts", self.intent_data.len()));
        Ok(())
    }

    fn load_fuzzy_index(&mut self, fuzzy_index_path: &str) -> Result<(), Box<dyn std::error::Error>> {
        let data = fs::read_to_string(fuzzy_index_path)?;
        self.fuzzy_index = serde_json::from_str(&data)?;
        dt_debug(&format!("🦆 Loaded {} fuzzy index entries", self.fuzzy_index.len()));
        Ok(())
    }
    
    // 🦆 says ⮞ OPTIONAL WORD EXPANDER - make all the combinations!
    fn expand_optional_words(&self, sentence: &str) -> Vec<String> {
        let tokens: Vec<&str> = sentence.split_whitespace().collect();
        let mut variants = Vec::new();
        
        // 🦆 says ⮞ recursive combination generator
        fn generate_combinations(tokens: &[&str], current: Vec<String>, index: usize, result: &mut Vec<String>) {
            if index >= tokens.len() {
                let sentence = current.join(" ").trim().to_string();
                if !sentence.is_empty() {
                    result.push(sentence);
                }
                return;
            }

            let token = tokens[index];
            let mut alternatives = Vec::new();

            // 🦆 says ⮞ handle (required|alternatives)
            if token.starts_with('(') && token.ends_with(')') {
                let clean = &token[1..token.len()-1];
                alternatives.extend(clean.split('|').map(|s| s.to_string()));
            } 
            // 🦆 says ⮞ handle [optional|words]
            else if token.starts_with('[') && token.ends_with(']') {
                let clean = &token[1..token.len()-1];
                alternatives.extend(clean.split('|').map(|s| s.to_string()));
                alternatives.push("".to_string()); // 🦆 says ⮞ empty for optional
            } 
            // 🦆 says ⮞ regular token
            else {
                alternatives.push(token.to_string());
            }

            for alt in alternatives {
                let mut new_current = current.clone();
                if !alt.is_empty() {
                    new_current.push(alt);
                }
                generate_combinations(tokens, new_current, index + 1, result);
            }
        }

        generate_combinations(&tokens, Vec::new(), 0, &mut variants);
        
        // 🦆 says ⮞ YO! clean up da mezz and filter
        variants.iter()
            .map(|v| v.replace("  ", " ").trim().to_string())
            .filter(|v| !v.is_empty())
            .collect()
    }

    // 🦆 says ⮞ ENTITY RESOLVER - duck translation matrix!
    fn resolve_entity(&self, script_name: &str, param_name: &str, param_value: &str) -> String {
        if self.is_wildcard_param(script_name, param_name) {
            return param_value.to_string();
        }
        if let Some(intent) = self.intent_data.get(script_name) {
            let normalized_input = param_value.to_lowercase();
            
            for sub in &intent.substitutions {
                let pattern = sub.pattern.to_lowercase();
                
                // 🦆 says ⮞ exact match
                if pattern == normalized_input {
                    dt_debug(&format!("      Exact entity match: {} → {}", param_value, sub.value));
                    return sub.value.clone();
                }
                
                // 🦆 says ⮞ parenthesized content match
                if pattern.starts_with('(') && pattern.ends_with(')') {
                    let content = &pattern[1..pattern.len()-1]; // 🦆 says ⮞ remove parentheses
                    if content == normalized_input {
                        dt_debug(&format!("      Parenthesized entity match: {} → {}", param_value, sub.value));
                        return sub.value.clone();
                    }
                }
                
                // 🦆 says ⮞ handle alternatives in parentheses
                if pattern.starts_with('(') && pattern.ends_with(')') && pattern.contains('|') {
                    let content = &pattern[1..pattern.len()-1];
                    let alternatives: Vec<&str> = content.split('|').collect();
                    for alternative in alternatives {
                        if alternative.trim() == normalized_input {
                            dt_debug(&format!("      Parenthesized alternative match: {} → {}", param_value, sub.value));
                            return sub.value.clone();
                        }
                    }
                }
            }
            
            // 🦆 says ⮞ Debug: show what we tried to match against
            dt_debug(&format!("      No entity match found for '{}' in {} substitutions", 
                param_value, intent.substitutions.len()));
        }
        
        param_value.to_string()
    }
  
    // 🦆 says ⮞ DYNAMIC REGEX BUILDER - quacky pattern magic!
    fn build_pattern_matcher(&self, script_name: &str, sentence: &str) -> Option<(Regex, Vec<String>)> {
        let start_time = Instant::now();
        dt_debug(&format!("    Building pattern matcher for: '{}'", sentence));

        let mut regex_parts = Vec::new();
        let mut param_names = Vec::new();
        let mut current = sentence.to_string();

        // 🦆 says ⮞ extract parameters and build regex
        while let Some(start) = current.find('{') {
            if let Some(end) = current.find('}') {
                let before_param = &current[..start];
                let param = &current[start+1..end];
                let after_param = &current[end+1..];

                // 🦆 says ⮞ handle text before parameter
                if !before_param.is_empty() {
                    let escaped = regex::escape(before_param);
                    regex_parts.push(escaped);
                }

                param_names.push(param.to_string());
                let is_wildcard = self.is_wildcard_param(script_name, param);

                let regex_group = if is_wildcard {
                    // 🦆 says ⮞ wildcard - match anything!
                    dt_debug(&format!("      Wildcard parameter: {}", param));
                    "(.*)".to_string()
                } else {
                    // 🦆 says ⮞ specific parameter
                    dt_debug(&format!("      Specific parameter: {}", param));
                    let mut lookahead = after_param.to_string();
                    let next_is_wildcard = loop {
                        if let Some(next_start) = lookahead.find('{') {
                            if let Some(next_end) = lookahead.find('}') {
                                let next_param = &lookahead[next_start+1..next_end];
                                if self.is_wildcard_param(script_name, next_param) {
                                    break true;
                                }

                                lookahead = lookahead[next_end+1..].to_string();
                            } else { break false; }
                        } else { break false; }
                    };

                    if next_is_wildcard {
                        r"([^ ]+)".to_string()  // No trailing \b before wildcard
                    } else {
                        r"\b([^ ]+)\b".to_string()  // Normal word boundaries
                    }
                };

                regex_parts.push(regex_group);
                current = after_param.to_string();
            } else {
                break;
            }
        }

        // 🦆 says ⮞ handle remaining text
        if !current.is_empty() {
            regex_parts.push(regex::escape(&current));
        }

        let regex_pattern = format!("^{}$", regex_parts.join(""));
        
        let build_time = start_time.elapsed();
        dt_debug(&format!("      Final regex: {}", regex_pattern));
        dt_debug(&format!("      Parameter names: {:?}", param_names));
        dt_debug(&format!("      Regex build time: {:?}", build_time));  
        match Regex::new(&regex_pattern) {
            Ok(re) => {
                dt_debug("      Regex compiled successfully");
                Some((re, param_names))
            },
            Err(e) => {
                dt_debug(&format!("🦆 says ⮞ fuck ❌ Regex compilation failed: {}", e));
                None
            },
        }
    }

    // 🦆 says ⮞ MEMORIZATION PRIORITY PROCESSIN' SYSTEM 
    fn calculate_processing_order(&mut self) {
        let mut script_priorities = Vec::new();    
        for (script_name, intent) in &self.intent_data {
            // 🦆 says ⮞ start wit base priority from voice config
            let base_priority = 3; // 🦆 says ⮞ TODO: from voice config
            // 🦆be⮞debuggin'
            dt_debug(&format!("Memory context: last_action={}, recent_commands={}", 
                self.memory_data.context.last_action, 
                self.memory_data.history.recent_commands.len()));
    
            // 🦆 says ⮞ memorization booztz adjust da priority based on usage
            let mut adjusted_priority = base_priority;      
            // 🦆 says ⮞ booztz for recent usage scriptz
            let recent_usage = self.memory_data.history.recent_commands
                .iter()
                .filter(|cmd| cmd.script == *script_name)
                .count();
            adjusted_priority -= recent_usage as i32; // 🦆 says ⮞ more usage = higher priority qwack (lower number)
            // 🦆 says ⮞ booztz 4 context match (if dis script was last action)
            if self.memory_data.context.last_action == *script_name {
                adjusted_priority -= 2; // Big boost for context continuity
dt_debug(&format!("  Context boost applied for {} (last action)", script_name));
            }        
            // 🦆says⮞ b(.)(.)bs for confirmed patterns
            let confirmation_key = format!("{}:", script_name);
            let confirmation_count = self.memory_data.history.confirmed_matches
                .keys()
                .filter(|k| k.starts_with(&confirmation_key))
                .count();
            adjusted_priority -= confirmation_count as i32;
            if confirmation_count > 0 {
                dt_debug(&format!("  Confirmation boost: {} patterns confirmed", confirmation_count));
            }
            // 🦆says⮞priority? don't u dare go below da zero
            adjusted_priority = adjusted_priority.max(0);  
            // 🦆says⮞bootz complex patterns
            let has_complex_patterns = intent.sentences.iter().any(|s| {
                s.contains('{') || s.contains('[') || s.contains('(')
            });

            script_priorities.push(ScriptPriority {
                name: script_name.clone(),
                priority: adjusted_priority,
                has_complex_patterns,
            });
    
            dt_info(&format!("MEMORY ADJUSTMENT: {}: base={} → adjusted={} (uses={}, confirms={}, context={})", 
                script_name, base_priority, adjusted_priority, recent_usage, confirmation_count,
                if self.memory_data.context.last_action == *script_name { "YES" } else { "NO" }));
        }

        // 🦆 says ⮞ Nix stylez priority with memory boosts
        script_priorities.sort_by(|a, b| {
            a.priority.cmp(&b.priority)
                .then(a.has_complex_patterns.cmp(&b.has_complex_patterns))
                .then(a.name.cmp(&b.name))
        });

        self.processing_order = script_priorities;
        dt_debug(&format!("Final processing order with memory: {:?}", 
            self.processing_order.iter().map(|s| format!("{}[{}]", s.name, s.priority)).collect::<Vec<_>>()));
    }

    // 🦆 says ⮞ SUBSTITUTION ENGINE
    fn apply_real_time_substitutions(&self, script_name: &str, text: &str) -> (String, HashMap<String, String>) {
        let mut resolved_text = text.to_lowercase();
        let mut substitutions = HashMap::new();

        if let Some(intent) = self.intent_data.get(script_name) {
            for sub in &intent.substitutions {
                // 🦆 says ⮞ word boundary substitution
                let pattern = format!(r"\b{}\b", regex::escape(&sub.pattern));
                if let Ok(re) = Regex::new(&pattern) {
                    if let Some(original_match) = re.find(&resolved_text) {
                        let original = original_match.as_str().to_string();
                        resolved_text = re.replace_all(&resolved_text, &sub.value).to_string();
                        substitutions.insert(original.clone(), sub.value.clone());
                        dt_debug(&format!("      Real-time sub: {} → {}", original, sub.value));
                    }
                }
            }
        }
        (resolved_text, substitutions)
    }

    // 🦆 says ⮞ EXACT MATCHIN'        
    fn exact_match(&self, text: &str) -> Option<MatchResult> {
        let global_start = Instant::now();
        let text = text.to_lowercase();     
        dt_debug(&format!("Starting EXACT match for: '{}'", text));
    
        for (script_index, script_priority) in self.processing_order.iter().enumerate() {
            let script_name = &script_priority.name; 
            dt_debug(&format!("Trying script [{}/{}]: {}", 
                script_index + 1, self.processing_order.len(), script_name));
            // 🦆 says ⮞ go real-time substitutions i choose u!
            let (resolved_text, substitutions) = self.apply_real_time_substitutions(script_name, &text);
            dt_debug(&format!("After substitutions: '{}'", resolved_text));
            if let Some(intent) = self.intent_data.get(script_name) {
                for sentence in &intent.sentences {
                    let expanded_variants = self.expand_optional_words(sentence);
                    
                    for variant in expanded_variants {
                        if let Some((regex, param_names)) = self.build_pattern_matcher(script_name, &variant) {
                            if let Some(captures) = regex.captures(&resolved_text) {
                                let mut args = Vec::new();      
                                // 🦆 says ⮞ process da param
                                for i in 1..captures.len() {
                                    if let Some(matched) = captures.get(i) {
                                        let param_index = i - 1;
                                        let param_name = if param_index < param_names.len() {
                                            &param_names[param_index]
                                        } else {
                                            "param"
                                        };
                    
                                        let mut param_value = matched.as_str().to_string();     
                                        // 🦆 says ⮞ go entity resolution i choose u!
                                        dt_debug(&format!("Before entity resolution: --{} {}", param_name, param_value));
                                        
                                        let entity_resolved = self.resolve_entity(script_name, param_name, &param_value);
                                        if entity_resolved != param_value {
                                            dt_debug(&format!("      Entity resolution: --{} {} → {}", 
                                                param_name, param_value, entity_resolved));
                                            param_value = entity_resolved;
                                        }
                                        
                                        if let Some(sub) = substitutions.get(&param_value) {
                                            dt_debug(&format!("      Substitution: {} → {}", param_value, sub));
                                            param_value = sub.clone();
                                        }
                                        
                                        dt_debug(&format!("      Final argument: --{} {}", param_name, param_value));
                                        args.push(format!("--{}", param_name));
                                        args.push(param_value);
                                    }
                                }
                                
                                return Some(MatchResult {
                                    script_name: script_name.clone(),
                                    args,
                                    matched_sentence: text.clone(),
                                    processing_time: global_start.elapsed(),
                                });
                            }
                        }
                    }
                }
            }
        }          
        None
    }

             
    // 🦆 says ⮞ fallback yo! FUZZY MATCHIN' 2 teh moon!
    fn levenshtein_distance(&self, a: &str, b: &str) -> usize {
        let a_chars: Vec<char> = a.chars().collect();
        let b_chars: Vec<char> = b.chars().collect();
        let a_len = a_chars.len();
        let b_len = b_chars.len();

        if a_len == 0 { return b_len; }
        if b_len == 0 { return a_len; }

        let mut matrix = vec![vec![0; b_len + 1]; a_len + 1];

        for i in 0..=a_len { matrix[i][0] = i; }
        for j in 0..=b_len { matrix[0][j] = j; }

        for i in 1..=a_len {
            for j in 1..=b_len {
                let cost = if a_chars[i-1] == b_chars[j-1] { 0 } else { 1 };
                matrix[i][j] = (matrix[i-1][j] + 1)
                    .min(matrix[i][j-1] + 1)
                    .min(matrix[i-1][j-1] + cost);
            }
        }
        matrix[a_len][b_len]
    }

    fn find_best_fuzzy_match(&self, text: &str) -> Option<(String, String, i32)> {
        let normalized_input = text.to_lowercase();
        let mut best_score = 0;
        let mut best_match = None;
        dt_debug(&format!("Fuzzy matching against {} entries", self.fuzzy_index.len()));

        for entry in &self.fuzzy_index {
            let normalized_sentence = entry.sentence.to_lowercase();            
            let distance = self.levenshtein_distance(&normalized_input, &normalized_sentence);
            let max_len = normalized_input.len().max(normalized_sentence.len());
    
            if max_len == 0 { continue; }      
            let score = 100 - (distance * 100 / max_len) as i32;
    
            dt_debug(&format!("  '{}' vs '{}' -> {}%", normalized_input, normalized_sentence, score));
    
            if score >= self.fuzzy_threshold {
                if score > best_score {
                    best_score = score;
                    best_match = Some((entry.script.clone(), entry.sentence.clone(), score));
                    dt_debug(&format!("  🦆 NEW BEST: {}%", score));
                }
            }
        }
        best_match
    }

    // 🦆 says ⮞ fuzzy permission check
    fn is_fuzzy_allowed(&self, script_name: &str) -> bool {
        self.fuzzy_index.iter().any(|entry| entry.script == script_name)
    }    

    fn fuzzy_match(&self, text: &str) -> Option<MatchResult> {
        dt_debug(&format!("Starting FUZZY match for: '{}'", text));

        if let Some((script_name, sentence, score)) = self.find_best_fuzzy_match(text) {
            // 🦆 say 🛑 STOP 🛑 fuzzy iz allowed?
            if !self.is_fuzzy_allowed(&script_name) {
                dt_debug(&format!("Fuzzy matching disabled for script: {}", script_name));
                return None;
            }
            dt_info(&format!("Fuzzy match: {} (score: {}%)", script_name, score)); 
            // 🦆 says ⮞ TODO parameter extraction for fuzzy matches
            let input_words: Vec<&str> = text.split_whitespace().collect();
            let sentence_words: Vec<&str> = sentence.split_whitespace().collect();     
            let mut args = Vec::new();
            let mut param_index = 0;  
            // 🦆 says ⮞ extract parameter names from sentence
            let mut param_names = Vec::new();
            let mut current = sentence.clone();
            while let Some(start) = current.find('{') {
                if let Some(end) = current.find('}') {
                    let param = &current[start+1..end];
                    param_names.push(param.to_string());
                    current = current[end+1..].to_string();
                } else { break; }
            }
            
            for (i, word) in sentence_words.iter().enumerate() {
                if word.starts_with('{') && word.ends_with('}') {
                    if i < input_words.len() && param_index < param_names.len() {
                        let param_name = &param_names[param_index];
                        let param_value = input_words[i];
                        
                        // 🦆 says ⮞ go entity resolution i choose u!
                        let resolved_value = self.resolve_entity(&script_name, param_name, param_value);
                        
                        args.push(format!("--{}", param_name));
                        args.push(resolved_value);
                        param_index += 1;
                        
                        dt_debug(&format!("      Fuzzy argument: --{} {}", param_name, param_value));
                    }
                }
            }
            
            Some(MatchResult {
                script_name,
                args,
                matched_sentence: text.to_string(),
                processing_time: std::time::Duration::default(),
            })
        } else {
            dt_debug("No fuzzy match found");
            None
        }
    }

    // 🦆 says ⮞ UPDATE CONTEXT AFTER COMMAND EXECUTION
    fn update_memory_context(&self, script_name: &str, args: &[String]) -> Result<(), Box<dyn std::error::Error>> {
        let stats_dir = std::env::var("HOME").unwrap_or_else(|_| ".".to_string()) + "/.local/share/yo/stats";
        let context_path = format!("{}/current_context.json", stats_dir);
        let mut context = self.memory_data.context.clone();
        // 🦆says ⮞update da last action
        context.last_action = script_name.to_string();

        // 🦆 says⮞detect and update active servers from args
        let mut active_servers = Vec::new();
        for arg in args { // 🦆TODO⮞real argz
            if arg.contains("dads") || arg == "--server" && args.iter().any(|a| a == "dads") {
                active_servers.push("dads_media_server".to_string());
            }
            if arg.contains("moms") || arg == "--server" && args.iter().any(|a| a == "moms") {
                active_servers.push("moms_media_server".to_string());
            }
        }
        if !active_servers.is_empty() {
            context.active_servers = active_servers;
        }
        // 🦆says⮞update da environment (not var) based on script
        if script_name == "deploy" { // 🦆TODO⮞moar enviormentz yo
            context.environment = "deployment".to_string();
        } else {
            context.environment = "default".to_string();
        }

        // 🦆says⮞save da updated context
        let context_json = serde_json::to_string_pretty(&context)?;
        std::fs::write(&context_path, context_json)?;    
        dt_debug(&format!("Updated memory context: last_action={}, environment={}", 
            context.last_action, context.environment));    
        Ok(())
    }    

    // 🦆 says ⮞ YO waz qwackin' yo?!
    // 🦆 says ⮞ here comez da executta 
    fn execute_script(&self, result: &MatchResult) -> Result<(), Box<dyn std::error::Error>> {
        dt_debug(&format!("Executing: yo {} {}", result.script_name, result.args.join(" ")));  
        
        // 🦆 says ⮞ update yo memory
        eprintln!("🦆MEMORY:SCRIPT:{}", result.script_name);
        eprintln!("🦆MEMORY:ARGS:{}", result.args.join(" "));
        eprintln!("🦆MEMORY:SENTENCE:{}", result.matched_sentence);
        eprintln!("🦆MEMORY:TYPE:exact");

        // 🦆 says ⮞ UPDATE MEMORY CONTEXT
        if let Err(e) = self.update_memory_context(&result.script_name, &result.args) {
            dt_debug(&format!("Failed to update memory context: {}", e));
        }
               
        // 🦆 says ⮞ execution duck tree climber
        println!("   ┌─(yo-{})", result.script_name);
        println!("   │🦆 qwack!? {}", result.matched_sentence);       
        if result.args.is_empty() {
            println!("   └─🦆 says ⮞ no parameters yo");
        } else {
            for chunk in result.args.chunks(2) {
                if chunk.len() == 2 {
                    println!("   └─⮞ {} {}", chunk[0], chunk[1]);
                }
            }
        }      
        println!("   └─⏰ do took {:?}", result.processing_time);

        // 🦆 says ⮞ EXECUTION
        let status = Command::new(format!("yo-{}", result.script_name))
            .args(&result.args)
            .status()?;          
        if !status.success() {
            eprintln!("🦆 says ⮞ fuck ❌ Script execution failed with status: {}", status);
        }     
        Ok(())
    }
    // 🦆 says ⮞ TTS
    fn say(&self, text: &str) {
        let _ = std::process::Command::new("yo-say")
            .arg(text)
            .status();
    }

    // 🦆 duck say ⮞ very mature sentences incomin' yo!
    fn say_no_match(&self) {
        use rand::seq::SliceRandom;
        if let Some(response) = self.sorry_phrases.choose(&mut rand::thread_rng()) {
            self.say(response);
        }
    }
    
    // 🦆 says ⮞ go MAIN RUNNER i choose u! - quack 2 da attack!
    pub fn run(&mut self, input: &str, fuzzy_threshold: i32) -> Result<(), Box<dyn std::error::Error>> {
        let total_start = Instant::now(); 
        self.fuzzy_threshold = fuzzy_threshold;

        // 🦆say⮞reload-memory! (duck wish dis easy irl....)
        if let Ok(memory_data) = Self::load_memory_data() {
            self.memory_data = memory_data;
            dt_debug("🦆 Memory data reloaded for context-aware processing");
        } else {
            dt_debug("🦆 Using default memory data");
        }

        self.calculate_processing_order();
        
        // 🦆 says ⮞ MULTIPLE COMMANDS - input has any `config.yo.SplitWords` 
        let parts: Vec<&str> = {
            let mut found = false;
            for word in &self.split_words {
                if input.to_lowercase().contains(word) {
                    found = true;
                    break;
                }
            }
            if found {
                let pattern = regex::Regex::new(&self.split_words.join("|")).unwrap();
                pattern.split(input)
                    .map(|part| part.trim())
                    .filter(|part| !part.is_empty())
                    .collect()
            } else {
                vec![input]
            }
        };
        
        // 🦆 says ⮞ 2>partz? process dem all 
        if parts.len() > 1 {
            dt_debug(&format!("Found {} parts to process: {:?}", parts.len(), parts));
            let mut all_successful = true;
            let mut processed_count = 0;
            
            for (index, part) in parts.iter().enumerate() {
                dt_info(&format!("Processing part {}/{}: '{}'", index + 1, parts.len(), part));
                
                // 🦆 says ⮞ process each part individually 🦆 say ⮞ dat iz eazier 2 say in swe qwack
                match self.process_single_input(part, total_start) {
                    Ok(_) => {
                        processed_count += 1;
                        dt_debug(&format!("Successfully processed part {}/{}", index + 1, parts.len()));
                    }
                    Err(e) => {
                        all_successful = false;
                        dt_debug(&format!("🦆 says ⮞ fuck ❌ Failed to process part {}: {}", index + 1, e));
                        // 🦆 says ⮞ keep going anyway plz
                    }
                }
                // 🦆 says ⮞ yo do small delay
                if index < parts.len() - 1 {
                    std::thread::sleep(std::time::Duration::from_millis(100));
                }
            }
            if processed_count > 0 {
                dt_debug(&format!("Successfully processed {}/{} parts", processed_count, parts.len()));
                return Ok(());
            } else {
                dt_info("🦆 says ⮞ fuck ❌ All parts failed to process");
                std::process::exit(1);
            }
        } else {
            // 🦆 says ⮞ input processing
            self.process_single_input(parts[0], total_start)
        }
    }
    
    // 🦆 says ⮞ process command
    fn process_single_input(&self, input: &str, total_start: Instant) -> Result<(), Box<dyn std::error::Error>> {
        let part_start = Instant::now();
        
        // 🦆 says ⮞ collect fuzzy candidates for logging
        let fuzzy_candidates: Vec<(String, String, i32)> = self.fuzzy_index.iter()
            .filter_map(|entry| {
                let normalized_input = input.to_lowercase();
                let normalized_sentence = entry.sentence.to_lowercase();
                let distance = self.levenshtein_distance(&normalized_input, &normalized_sentence);
                let max_len = normalized_input.len().max(normalized_sentence.len());
                if max_len == 0 { return None; }
                let score = 100 - (distance * 100 / max_len) as i32;
                if score >= 10 {
                    Some((entry.script.clone(), entry.sentence.clone(), score))
                } else {
                    None
                }
            })
            .collect();
               
        // 🦆 says ⮞ exact matchin'
        if let Some(match_result) = self.exact_match(input) {
            let part_elapsed = part_start.elapsed();
            dt_debug(&format!("Exact match found: {}", match_result.script_name));
            let _ = self.log_successful_command(&match_result.script_name, &match_result.args, part_elapsed);    
            let final_result = MatchResult {
                script_name: match_result.script_name,
                args: match_result.args,
                matched_sentence: match_result.matched_sentence,
                processing_time: part_elapsed,
            };    
            self.execute_script(&final_result)?;
            return Ok(());
        }
    
        // 🦆 says ⮞ fallback yo go fuzzy matchin' i choose u!
        if let Some(match_result) = self.fuzzy_match(input) {
            let part_elapsed = part_start.elapsed();
            dt_info(&format!("Fuzzy match found: {}", match_result.script_name));
            let final_result = MatchResult {
                script_name: match_result.script_name,
                args: match_result.args,
                matched_sentence: match_result.matched_sentence,
                processing_time: part_elapsed,
            };    
            let _ = self.log_successful_command(&final_result.script_name, &final_result.args, final_result.processing_time); 
            self.execute_script(&final_result)?;
            return Ok(());
        }
        
        // 🦆 says ⮞ NO MATCH
        let part_elapsed = part_start.elapsed();
        println!("   ┌─(yo-do)");
        println!("   │🦆 qwack! {}", input);
        println!("   │🦆 says ⮞ fuck ❌ no match!");
    
        if !fuzzy_candidates.is_empty() {
            let top_candidates: Vec<_> = fuzzy_candidates.iter()
                .filter(|(_, _, score)| *score >= 50)
                .take(3)
                .collect();
    
            for (script, sentence, score) in top_candidates {
                println!("   │   {}%: '{}' -> yo {}", score, sentence, script);
            }
        }
        println!("   └─⏰ do took {:?}", part_elapsed);
        
        // 🦆 says ⮞ speak no match
        self.say_no_match();
        
        // 🦆 says ⮞ log failed command with analysis data
        dt_debug("No match found for part, logging statistics...");
        let _ = self.log_failed_command(input, &fuzzy_candidates);
        Err("No match found for this part".into())
    }
    
}

fn load_split_words() -> Vec<String> {
    let path = env::var("YO_SPLIT_WORDS").expect("YO_SPLIT_WORDS not set");
    let content = fs::read_to_string(path).expect("Failed to read split words file");
    serde_json::from_str(&content).expect("Invalid JSON in split words file")
}

fn load_sorry_phrases() -> Vec<String> {
    let path = env::var("YO_SORRY_PHRASES").expect("YO_SORRY_PHRASES not set");
    let content = fs::read_to_string(path).expect("Failed to read sorry phrases file");
    serde_json::from_str(&content).expect("Invalid JSON in sorry phrases file")
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let args: Vec<String> = env::args().collect(); 
    setup_ducktrace_logging(None, None);
    let log_file = std::env::var("DT_LOG_FILE")
        .unwrap_or_else(|_| "do.log".to_string());
    let log_path = env::var("DT_LOG_PATH")
        .unwrap_or_else(|_| {
            let home = env::var("HOME").unwrap_or_else(|_| ".".to_string());
            format!("{}/.config/duckTrace/", home)
        });
    let log_level = std::env::var("DT_LOG_LEVEL")
        .unwrap_or_else(|_| "INFO".to_string());

    dt_debug(&format!("Log file: {}{}", log_path, log_file));
    dt_debug(&format!("Log Level: {}", log_level));

    // 🦆 says ⮞ Handle real-time mode
    if args.len() > 1 && args[1] == "--realtime" {
        let mut yo_do = YoDo::new();
    
        // 🦆 says ⮞ load da environment data
        if let Ok(intent_data_path) = env::var("YO_INTENT_DATA") {
            yo_do.load_intent_data(&intent_data_path)?;
        } else {
            eprintln!("🦆 says ⮞ fuck ❌ YO_INTENT_DATA environment variable not set");
            return Ok(());
        }    
        if let Ok(fuzzy_index_path) = env::var("YO_FUZZY_INDEX") {
            yo_do.load_fuzzy_index(&fuzzy_index_path)?;
        }
    
        // 🦆 says ⮞ Run real-time mode
        tokio::runtime::Runtime::new()?.block_on(yo_do.run_realtime())?;
        Ok(())
    } else {
        // 🦆 says ⮞ Original command mode
        if args.len() < 2 {
            exit(1);
        }       
        let input = &args[1];
        let fuzzy_threshold = if args.len() > 2 {
            args[2].parse().unwrap_or(15)
        } else {
            15
        };
        let mut yo_do = YoDo::new();
    
        if let Ok(intent_data_path) = env::var("YO_INTENT_DATA") {
            yo_do.load_intent_data(&intent_data_path)?;
        } else {
            eprintln!("🦆 says ⮞ fuck ❌ YO_INTENT_DATA environment variable not set");
            eprintln!("Available YO_* vars:");
            for (key, _) in env::vars().filter(|(k, _)| k.starts_with("YO_")) {
                eprintln!("   {}", key);
            }
            return Ok(());
        }    
        if let Ok(fuzzy_index_path) = env::var("YO_FUZZY_INDEX") {
            yo_do.load_fuzzy_index(&fuzzy_index_path)?;
        }
        yo_do.run(input, fuzzy_threshold)
    }
}
