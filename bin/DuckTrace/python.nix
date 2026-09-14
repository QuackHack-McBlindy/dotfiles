# dotfiles/bin/DuckTrace/python.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 duck say ⮞ Python version of da DT
    self,
    config,
    lib,
    pkgs,
    ...
} : let
  pyEnv = pkgs.python3.withPackages (ps: [
    ps.fastapi
    ps.pyaudio
    ps.uvicorn
    ps.websockets
    ps.faster-whisper
    ps.numpy
    ps.flask
    ps.soundfile
    ps.python-multipart
    ps.noisereduce
  ]);
in
  ''
    import os
    import sys
    import time
    import logging
    from datetime import datetime
    import json

    class DuckTraceFormatter(logging.Formatter):
        COLORS = {
            'DEBUG': '\033[34m',        # 🦆 says ⮞ BLUE
            'INFO': '\033[0;32m',       # 🦆 says ⮞ GREEN
            'WARNING': '\033[33m',      # 🦆 says ⮞ YELLOW
            'ERROR': '\033[1;31m',      # 🦆 says ⮞ RED
            'CRITICAL': '\033[1;5;31m', # 🦆 says ⮞ BLINKY RED
            'RESET': '\033[0m',
            'BOLD': '\033[1m',
            'BLINK': '\033[5m',
            'DSAY': '\033[3m\033[38;2;0;150;150m',  # Duck say style
            'GRAY': '\033[38;5;244m'
        }

        SYMBOLS = {
            'DEBUG': '⁉️',
            'INFO': '✅',
            'WARNING': '⚠️',
            'ERROR': '❌',
            'CRITICAL': '🚨'
        }

        def format(self, record):
            timestamp = datetime.now().strftime("%H:%M:%S")
            color = self.COLORS.get(record.levelname, self.COLORS['INFO'])
            symbol = self.SYMBOLS.get(record.levelname, "")
            blink = self.COLORS['BLINK'] if record.levelname in ['ERROR', 'CRITICAL'] else ""

            message = super().format(record)
            formatted = f"{color}{self.COLORS['BOLD']}{blink}[🦆📜] [{timestamp}] {symbol}{record.levelname}{symbol} ⮞ {message}{self.COLORS['RESET']}"

            if record.levelname in ['ERROR', 'CRITICAL']:
                formatted += f"\n{self.COLORS['DSAY']}🦆 duck say {self.COLORS['BOLD']}\033[38;2;255;255;0m⮞{self.COLORS['RESET']}{self.COLORS['DSAY']} fuck ❌ {message}{self.COLORS['RESET']}"

            return formatted

    def setup_ducktrace_logging(name=None, level=None):
        # 🦆 says ⮞ get log level from env var or parameter
        if level is None:
            level_map = {'DEBUG': 0, 'INFO': 1, 'WARNING': 2, 'ERROR': 3, 'CRITICAL': 4}
            env_level = os.environ.get('DT_LOG_LEVEL', 'INFO').upper()
            level_num = level_map.get(env_level, 1)

            # 🦆 says ⮞ convert log level
            if level_num <= 0:
                log_level = logging.DEBUG
            elif level_num == 1:
                log_level = logging.INFO
            elif level_num == 2:
                log_level = logging.WARNING
            elif level_num == 3:
                log_level = logging.ERROR
            else:
                log_level = logging.CRITICAL
        else:
            log_level = getattr(logging, level.upper(), logging.INFO)

        # 🦆 says ⮞ Set up log file path
        log_path = os.environ.get('DT_LOG_PATH', os.path.expanduser('~/.config/duckTrace/'))
        os.makedirs(log_path, exist_ok=True)

        if name is None:
            # 🦆 says ⮞ get logfile from env
            name = os.environ.get('DT_LOG_FILE', 'PyDuckTrace.log')

        log_file = os.path.join(log_path, name)
        # 🦆 says ⮞ root logger
        logger = logging.getLogger()
        logger.setLevel(log_level)

        # 🦆 says ⮞ remove existing handlers
        for handler in logger.handlers[:]:
            logger.removeHandler(handler)

        # 🦆 says ⮞ file handler
        file_handler = logging.FileHandler(log_file)
        file_formatter = logging.Formatter('[%(asctime)s] %(levelname)s - %(message)s', datefmt='%H:%M:%S')
        file_handler.setFormatter(file_formatter)
        logger.addHandler(file_handler)
        # 🦆 says ⮞ console handler
        console_handler = logging.StreamHandler(sys.stderr)
        console_formatter = DuckTraceFormatter('%(message)s')
        console_handler.setFormatter(console_formatter)
        logger.addHandler(console_handler)

        return logger

    # 🦆 says ⮞ performance timing decorator (DEBUG)
    def timed_function(func_name=None):
        def decorator(func):
            def wrapper(*args, **kwargs):
                logger = logging.getLogger()
                start_time = time.time()
                actual_name = func_name or func.__name__
                logger.debug(f"Starting {actual_name}...")
                try:
                    result = func(*args, **kwargs)
                    elapsed = time.time() - start_time
                    logger.debug(f"Completed {actual_name} in {elapsed:.3f}s")
                    return result
                except Exception as e:
                    elapsed = time.time() - start_time
                    logger.error(f"Failed {actual_name} after {elapsed:.3f}s: {str(e)}")
                    raise
            return wrapper
        return decorator

    def dt_debug(msg):
        logging.debug(msg)
    def dt_info(msg):
        logging.info(msg)
    def dt_warning(msg):
        logging.warning(msg)
    def dt_error(msg):
        logging.error(msg)
    def dt_critical(msg):
        logging.critical(msg)

    # 🦆 says ⮞ transcription timing helper
    class TranscriptionTimer:
        def __init__(self, operation_name):
            self.operation_name = operation_name
            self.start_time = None
            self.logger = logging.getLogger()

        def __enter__(self):
            self.start_time = time.time()
            self.logger.debug(f"Starting {self.operation_name}...")
            return self

        def __exit__(self, exc_type, exc_val, exc_tb):
            elapsed = time.time() - self.start_time
            if exc_type is None:
                self.logger.debug(f"Completed {self.operation_name} in {elapsed:.3f}s")
            else:
                self.logger.error(f"Failed {self.operation_name} after {elapsed:.3f}s")

        def lap(self, lap_name):
            if self.start_time:
                elapsed = time.time() - self.start_time
                self.logger.debug(f"{self.operation_name} - {lap_name}: {elapsed:.3f}s")
  ''
