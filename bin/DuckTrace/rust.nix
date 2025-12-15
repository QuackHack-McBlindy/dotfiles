# dotfiles/bin/DuckTrace/rust.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 duck say ⮞ DT follow cross lang get it?
    self,
    config,
    lib,
    pkgs,
    ...
} : let # 🦆say⮞setup
# ${RustDuckTrace}
#    fn main() {
#        setup_ducktrace_logging(None, None);
#        let log_file = std::env::var("DT_LOG_FILE")
#            .unwrap_or_else(|_| "api.log".to_string());
#        let log_path = std::env::var("DT_LOG_PATH")
#            .unwrap_or_else(|_| "/home/${config.this.user.me.name}/.config/duckTrace/".to_string());
#        let log_level = std::env::var("DT_LOG_LEVEL")
#            .unwrap_or_else(|_| "INFO".to_string());
    
#        dt_info(&format!("🚀 Starting yo API server"));
#        dt_info(&format!("Log file: {}{}", log_path, log_file));
#        dt_info(&format!("Log Level: {}", log_level));

# 🦆says ⮞ make sure Cargo.toml has
#[dependencies]
#chrono = "0.4"
#lazy_static = "1.4"
#dirs = "5.0"
#tempfile = "3.8"
#colored = "2.1"
in
  ''
    use std::env;
    use std::fs::{OpenOptions, File};
    use std::io::{self, Write};
    use std::sync::Once;
    use std::time::Instant;
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
                .unwrap_or_else(|_| "/home/${config.this.user.me.name}/.config/duckTrace".to_string());
            
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
  ''

