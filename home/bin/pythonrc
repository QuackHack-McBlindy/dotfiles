#!/usr/bin/env python3

import os
import sys
import math
import datetime
import logging
from pprint import pprint

import colorlog
import logging

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


def main():
    # Kill process on port 5001 if it is already in use
    try:
        import subprocess
        subprocess.run(f"lsof -t -i:{PORT} | xargs kill -9", shell=True, check=True)
        logger.info(f"Killed any existing processes using port {PORT}")
    except subprocess.CalledProcessError:
        logger.info(f"No processes found using port {PORT}")
    logger.info(f"Starting {PROJECT}")
    print(__doc__)
    app.run(host=HOST, port=PORT, debug=False)


# DEBUG
import pdb
def debugger():
    pdb.set_trace()

import traceback
def custom_traceback(exc_type, exc_value, exc_tb):
    traceback.format_exception(exc_type, exc_value, exc_tb)
    print("Custom traceback formatting...")
    sys.__excepthook__(exc_type, exc_value, exc_tb)
sys.excepthook = custom_traceback


# FILE HANDLING
def read_file(file_path):
    with open(file_path, 'r') as f:
        return f.read()

def write_file(file_path, content):
    with open(file_path, 'w') as f:
        f.write(content)

def search_file(file_path, search_term):
    with open(file_path, 'r') as f:
        for line in f:
            if search_term in line:
                print(line)

# SYSTEM MONITORING
import psutil

def monitor_system_usage():
    cpu_usage = psutil.cpu_percent()
    memory_usage = psutil.virtual_memory().percent
    if cpu_usage > 90:
        logger.warning(f"High CPU usage: {cpu_usage}%")
    if memory_usage > 90:
        logger.warning(f"High Memory usage: {memory_usage}%")

monitor_system_usage()  # Call periodically

# SEND NOTIFICATION
def send_notification(message):
    os.system(f'notify-send "Python Notification" "{message}"')

send_notification("Python interactive session started.")

# Pretty-printing the current Python path
#print("\nPython Path:")
#pprint(sys.path)

# Adding a custom prompt
sys.ps1 = "\033[1;32m>>> \033[0m"  # Green colored prompt
sys.ps2 = "\033[1;34m... \033[0m"  # Blue colored continuation prompt
