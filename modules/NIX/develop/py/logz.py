import logger

#──→ > LOGGING  ←──
class LevelBasedStreamHandler(logging.StreamHandler):
    def __init__(self, formatters):
        super().__init__()
        self.formatters = formatters  # Dictionary of formatters per log level

    def emit(self, record):
        # Select formatter based on the log level
        formatter = self.formatters.get(record.levelno, self.formatters[logging.INFO])  # Default to INFO formatter
        self.setFormatter(formatter)
        super().emit(record)

# Define formatters for each log level
formatters = {
    logging.DEBUG: colorlog.ColoredFormatter(
        "%(log_color)s [🦆DuckTrace📜] - 🐛🦆 DEBUG 🦆🐛 - %(message)s",
        log_colors={'DEBUG': 'white'}
    ),
    logging.INFO: colorlog.ColoredFormatter(
        "%(log_color)s [🦆DuckTrace📜] - ✅🦆 INFO 🦆✅ - %(message)s",
        log_colors={'INFO': 'bold_green'}
    ),
    logging.WARNING: colorlog.ColoredFormatter(
        "%(log_color)s [🦆DuckTrace📜] - ⚠️🦆 WARNING 🦆⚠️ - ⚠️ %(message)s ⚠️",
        log_colors={'WARNING': 'bold_yellow'}
    ),
    logging.ERROR: colorlog.ColoredFormatter(
        "%(log_color)s - ❌🦆 ❌ ERROR ❌ 🦆❌ - ❌❌❌ %(message)s ❌❌❌",
        log_colors={'ERROR': 'bold_red'}
    ),
    logging.CRITICAL: colorlog.ColoredFormatter(
        "%(log_color)s [🦆DuckTrace📜] - 🚨🦆 CRITICAL 🦆🚨 - %(name)s - 🚨🚨🚨 %(message)s 🚨🚨🚨",
        log_colors={'CRITICAL': 'bold_red'}
    )
}

# Create a custom handler that switches formatters based on log level
console_handler = LevelBasedStreamHandler(formatters)

# File Logs (plain format for file output)
file_handler = logging.FileHandler('agent_log.log')
file_formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
file_handler.setFormatter(file_formatter)

# Logger
logger = logging.getLogger("DuckTraceLogger")

# Convert string level to logging constant
LOGGING_LEVEL = "INFO"
log_level = getattr(logging, LOGGING_LEVEL.upper(), logging.INFO)  # Default to INFO if invalid
logger.setLevel(log_level)

# Add both handlers to the logger
logger.addHandler(console_handler)  # For colored logs in the console
logger.addHandler(file_handler)      # For plain logs in a file

# Confirm that logging is set up
logger.info("Logging setup complete. Ready to log messages!")

# Provide the logger as a global variable for convenience
print("Logger 'DuckTrace' is ready for use.")
# Custom greeting message
print("Welcome to Python Interactive Mode!")
print("Common modules (os, sys, math, datetime) are already imported.")
print("Use 'pprint' for pretty-printing.")

# Helper functions
def ls(path="."):
    """List files and directories in the given path."""
    return os.listdir(path)

def rainbow_text(text):
    # ANSI color codes for rainbow colors
    colors = [
        "\033[38;5;196m",  # Red
        "\033[38;5;202m",  # Orange
        "\033[38;5;226m",  # Yellow
        "\033[38;5;46m",   # Green
        "\033[38;5;51m",   # Cyan
        "\033[38;5;189m",  # Blue
        "\033[38;5;99m",   # Purple
        "\033[0m"          # Reset color
    ]
    
    # Iterate over the text and assign each character a color
    colored_text = ""
    color_index = 0
    for char in text:
        colored_text += f"{colors[color_index % len(colors)]}{char}\033[0m"
        color_index += 1

    return colored_text


def now():
    """Return the current date and time."""
    return datetime.datetime.now()

def whoami():
    """Return the current user."""
    return os.getenv("USER") or os.getenv("USERNAME")

from dotenv import load_dotenv

def load_secrets(env_path=".env"):
    """Load environment variables from a specified .env file."""
    if os.path.exists(env_path):
        load_dotenv(env_path)
        print(f"Environment variables loaded from {env_path}")
    else:
        print(f"No .env file found at {env_path}")

# Call the function to load environment variables automatically
load_secrets()

handler = colorlog.StreamHandler()
handler.setFormatter(colorlog.ColoredFormatter(
	'%(log_color)s%(levelname)s:%(name)s:%(message)s'))

logger = colorlog.getLogger('example')
logger.addHandler(handler)
