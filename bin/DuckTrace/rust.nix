# dotfiles/bin/DuckTrace/rust.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 duck say ⮞ DT follow cross lang get it?
    self,
    config,
    lib,
    pkgs,
    ...
} : let # 🦆say⮞setup
#     fn main() -> io::Result<()> {
#        setup_ducktrace_logging(None, Some("DEBUG"))?;     

#[dependencies]
#chrono = "0.4"
#lazy_static = "1.4"
#dirs = "5.0"
#tempfile = "3.8"
in
  ''
    const COLOR_DEBUG: &str = "\x1b[34m";
    const COLOR_INFO: &str = "\x1b[0;32m";
    const COLOR_WARNING: &str = "\x1b[33m";
    const COLOR_ERROR: &str = "\x1b[1;31m";
    const COLOR_CRITICAL: &str = "\x1b[1;5;31m";
    const COLOR_RESET: &str = "\x1b[0m";
    const COLOR_BOLD: &str = "\x1b[1m";
    const COLOR_BLINK: &str = "\x1b[5m";
    const COLOR_DSAY: &str = "\x1b[3m\x1b[38;2;0;150;150m";
    const COLOR_GRAY: &str = "\x1b[38;5;244m";
    const COLOR_YELLOW: &str = "\x1b[38;2;255;255;0m";
    
    const SYMBOL_DEBUG: &str = "⁉️";
    const SYMBOL_INFO: &str = "✅";
    const SYMBOL_WARNING: &str = "⚠️";
    const SYMBOL_ERROR: &str = "❌";
    const SYMBOL_CRITICAL: &str = "🚨";
    
    #[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
    pub enum LogLevel {
        Debug = 0,
        Info = 1,
        Warning = 2,
        Error = 3,
        Critical = 4,
    }
    
    impl From<&str> for LogLevel {
        fn from(s: &str) -> Self {
            match s.to_uppercase().as_str() {
                "DEBUG" => LogLevel::Debug,
                "INFO" => LogLevel::Info,
                "WARNING" => LogLevel::Warning,
                "ERROR" => LogLevel::Error,
                "CRITICAL" => LogLevel::Critical,
                _ => LogLevel::Info,
            }
        }
    }
    
    impl fmt::Display for LogLevel {
        fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
            match self {
                LogLevel::Debug => write!(f, "DEBUG"),
                LogLevel::Info => write!(f, "INFO"),
                LogLevel::Warning => write!(f, "WARNING"),
                LogLevel::Error => write!(f, "ERROR"),
                LogLevel::Critical => write!(f, "CRITICAL"),
            }
        }
    }
    
    #[derive(Clone)]
    pub struct LoggerConfig {
        pub name: Option<String>,
        pub level: LogLevel,
        pub log_path: PathBuf,
        pub log_file: String,
    }
    
    impl Default for LoggerConfig {
        fn default() -> Self {
            let log_path = env::var("DT_LOG_PATH")
                .map(PathBuf::from)
                .unwrap_or_else(|_| {
                    let mut path = dirs::home_dir().unwrap_or_else(|| PathBuf::from("."));
                    path.push(".config/duckTrace");
                    path
                });
            
            let log_file = env::var("DT_LOG_FILE")
                .unwrap_or_else(|_| "PyDuckTrace.log".to_string());
            
            let level = env::var("DT_LOG_LEVEL")
                .unwrap_or_else(|_| "INFO".to_string());
            
            Self {
                name: None,
                level: LogLevel::from(level.as_str()),
                log_path,
                log_file,
            }
        }
    }
    
    pub struct DuckTraceLogger {
        config: LoggerConfig,
        file_handle: Arc<Mutex<Option<File>>>,
    }
    
    impl DuckTraceLogger {
        pub fn new(config: LoggerConfig) -> io::Result<Self> {
            fs::create_dir_all(&config.log_path)?;
            
            let log_file_path = config.log_path.join(&config.log_file);
            let file = OpenOptions::new()
                .create(true)
                .append(true)
                .open(log_file_path)?;
            
            Ok(Self {
                config,
                file_handle: Arc::new(Mutex::new(Some(file))),
            })
        }
        
        pub fn setup(name: Option<&str>, level: Option<LogLevel>) -> io::Result<Self> {
            let mut config = LoggerConfig::default();     
            if let Some(n) = name {
                config.name = Some(n.to_string());
            }
            
            if let Some(lvl) = level {
                config.level = lvl;
            }
            
            Self::new(config)
        }
        
        fn format_message(&self, level: LogLevel, message: &str) -> String {
            let timestamp = Local::now().format("%H:%M:%S").to_string();
            
            let (color, symbol) = match level {
                LogLevel::Debug => (COLOR_DEBUG, SYMBOL_DEBUG),
                LogLevel::Info => (COLOR_INFO, SYMBOL_INFO),
                LogLevel::Warning => (COLOR_WARNING, SYMBOL_WARNING),
                LogLevel::Error => (COLOR_ERROR, SYMBOL_ERROR),
                LogLevel::Critical => (COLOR_CRITICAL, SYMBOL_CRITICAL),
            };
            
            let blink = if level >= LogLevel::Error {
                COLOR_BLINK
            } else {
                ""
            };
            
            let mut formatted = format!(
                "{}{}{}[🦆📜] [{}] {}{}{} ⮞ {}{}",
                color, COLOR_BOLD, blink,
                timestamp, symbol, level, symbol,
                message, COLOR_RESET
            );
            
            if level >= LogLevel::Error {
                formatted.push_str(&format!(
                    "\n{}{}🦆 duck say {}{}⮞{} fuck ❌ {}{}",
                    COLOR_DSAY, COLOR_BOLD, COLOR_YELLOW, COLOR_RESET,
                    COLOR_DSAY, message, COLOR_RESET
                ));
            }
            
            formatted
        }
        
        fn write_to_file(&self, level: LogLevel, message: &str) -> io::Result<()> {
            let timestamp = Local::now().format("%H:%M:%S").to_string();
            let file_message = format!("[{}] {} - {}\n", timestamp, level, message);
            
            if let Some(file) = self.file_handle.lock().unwrap().as_mut() {
                file.write_all(file_message.as_bytes())?;
            }
            
            Ok(())
        }
        
        pub fn log(&self, level: LogLevel, message: &str) -> io::Result<()> {
            if level < self.config.level {
                return Ok(());
            }
            
            eprintln!("{}", self.format_message(level, message));
            
            self.write_to_file(level, message)
        }
        
        pub fn debug(&self, message: &str) -> io::Result<()> {
            self.log(LogLevel::Debug, message)
        }
        
        pub fn info(&self, message: &str) -> io::Result<()> {
            self.log(LogLevel::Info, message)
        }
        
        pub fn warning(&self, message: &str) -> io::Result<()> {
            self.log(LogLevel::Warning, message)
        }
        
        pub fn error(&self, message: &str) -> io::Result<()> {
            self.log(LogLevel::Error, message)
        }
        
        pub fn critical(&self, message: &str) -> io::Result<()> {
            self.log(LogLevel::Critical, message)
        }
    }
    
    lazy_static::lazy_static! {
        static ref GLOBAL_LOGGER: Arc<Mutex<Option<DuckTraceLogger>>> = Arc::new(Mutex::new(None));
    }
    
    pub fn dt_debug(message: &str) {
        if let Some(logger) = GLOBAL_LOGGER.lock().unwrap().as_ref() {
            let _ = logger.debug(message);
        }
    }
    
    pub fn dt_info(message: &str) {
        if let Some(logger) = GLOBAL_LOGGER.lock().unwrap().as_ref() {
            let _ = logger.info(message);
        }
    }
    
    pub fn dt_warning(message: &str) {
        if let Some(logger) = GLOBAL_LOGGER.lock().unwrap().as_ref() {
            let _ = logger.warning(message);
        }
    }
    
    pub fn dt_error(message: &str) {
        if let Some(logger) = GLOBAL_LOGGER.lock().unwrap().as_ref() {
            let _ = logger.error(message);
        }
    }
    
    pub fn dt_critical(message: &str) {
        if let Some(logger) = GLOBAL_LOGGER.lock().unwrap().as_ref() {
            let _ = logger.critical(message);
        }
    }
    
    pub fn setup_ducktrace_logging(name: Option<&str>, level: Option<&str>) -> io::Result<()> {
        let log_level = level.map(LogLevel::from);
        let logger = DuckTraceLogger::setup(name, log_level)?;
        
        let mut global_logger = GLOBAL_LOGGER.lock().unwrap();
        *global_logger = Some(logger);
        
        Ok(())
    }
    
    pub struct TimedFunction<'a> {
        name: &'a str,
        start_time: Instant,
    }
    
    impl<'a> TimedFunction<'a> {
        pub fn new(name: &'a str) -> Self {
            dt_debug(&format!("Starting {}...", name));
            Self {
                name,
                start_time: Instant::now(),
            }
        }
        
        pub fn complete(self) {
            let elapsed = self.start_time.elapsed();
            dt_debug(&format!("Completed {} in {:.3}s", self.name, elapsed.as_secs_f64()));
        }
        
        pub fn complete_with_result<T>(self, result: &io::Result<T>) {
            let elapsed = self.start_time.elapsed();
            
            match result {
                Ok(_) => dt_debug(&format!("Completed {} in {:.3}s", self.name, elapsed.as_secs_f64())),
                Err(e) => dt_error(&format!("Failed {} after {:.3}s: {}", self.name, elapsed.as_secs_f64(), e)),
            }
        }
    }
    
    #[macro_export]
    macro_rules! timed_function {
        ($name:expr, $func:expr) => {{
            let timer = TimedFunction::new($name);
            let result = $func;
            timer.complete_with_result(&result);
            result
        }};
    }
    
    pub struct TranscriptionTimer {
        operation_name: String,
        start_time: Instant,
        logger: Arc<Mutex<Option<DuckTraceLogger>>>,
    }
    
    impl TranscriptionTimer {
        pub fn new(operation_name: &str) -> Self {
            if let Some(logger) = GLOBAL_LOGGER.lock().unwrap().as_ref() {
                let _ = logger.debug(&format!("Starting {}...", operation_name));
            }
            
            Self {
                operation_name: operation_name.to_string(),
                start_time: Instant::now(),
                logger: GLOBAL_LOGGER.clone(),
            }
        }
        
        pub fn lap(&self, lap_name: &str) {
            let elapsed = self.start_time.elapsed();
            if let Some(logger) = self.logger.lock().unwrap().as_ref() {
                let _ = logger.debug(&format!("{} - {}: {:.3}s", self.operation_name, lap_name, elapsed.as_secs_f64()));
            }
        }
        
        pub fn complete(self) {
            let elapsed = self.start_time.elapsed();
            if let Some(logger) = self.logger.lock().unwrap().as_ref() {
                let _ = logger.debug(&format!("Completed {} in {:.3}s", self.operation_name, elapsed.as_secs_f64()));
            }
        }
    }
    
    pub mod builder {
        use super::*;
        use std::collections::HashMap;
        
        pub struct DuckTraceBuilder {
            name: Option<String>,
            level: Option<LogLevel>,
            log_path: Option<PathBuf>,
            log_file: Option<String>,
        }
        
        impl DuckTraceBuilder {
            pub fn new() -> Self {
                Self {
                    name: None,
                    level: None,
                    log_path: None,
                    log_file: None,
                }
            }
            
            pub fn name(mut self, name: &str) -> Self {
                self.name = Some(name.to_string());
                self
            }
            
            pub fn level(mut self, level: LogLevel) -> Self {
                self.level = Some(level);
                self
            }
            
            pub fn log_path(mut self, path: &str) -> Self {
                self.log_path = Some(PathBuf::from(path));
                self
            }
            
            pub fn log_file(mut self, file: &str) -> Self {
                self.log_file = Some(file.to_string());
                self
            }
            
            pub fn build(self) -> io::Result<DuckTraceLogger> {
                let mut config = LoggerConfig::default();
                
                if let Some(name) = self.name {
                    config.name = Some(name);
                }
                
                if let Some(level) = self.level {
                    config.level = level;
                }
                
                if let Some(path) = self.log_path {
                    config.log_path = path;
                }
                
                if let Some(file) = self.log_file {
                    config.log_file = file;
                }
                
                DuckTraceLogger::new(config)
            }
        }
    }   
  ''

