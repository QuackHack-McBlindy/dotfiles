#!/usr/bin/env python3
# [ DuckTrace! Easy Happy Logs! ]
# ------------------------
import sys
import time

class DuckTrace:
    # ANSI escape codes for colors and formatting
    RESET = "\033[0m"
    BOLD = "\033[1m"
    BLINK = "\033[5m"

    RED = "\033[31m"
    YELLOW = "\033[33m"
    GREEN = "\033[32m"
    BLUE = "\033[34m"

    LOG_FILE = "ducktrace.log"

    def _timestamp(self):
        return time.strftime("%Y-%m-%d %H:%M:%S")

    def _log(self, level, symbol, color, message, blink=False):
        timestamp = self._timestamp()
        blink_text = self.BLINK if blink else ""
        formatted_message = (
            f"{color}{self.BOLD}{blink_text}[{timestamp}] [🦆DuckTrace📜] {symbol} {level} {symbol} - {message}{self.RESET}"
        )
        print(formatted_message)
        with open(self.LOG_FILE, "a") as log_file:
            log_file.write(f"[{timestamp}] {level} - {message}\n")

    def info(self, message):
        self._log("INFO", "✅", self.GREEN, message)

    def warning(self, message):
        self._log("WARNING", "⚠️", self.YELLOW, message)

    def error(self, message):
        self._log("ERROR", "❌", self.RED, message, blink=True)

    def critical(self, message):
        self._log("CRITICAL", "🚨", self.RED, message, blink=True)

    def debug(self, message):
        self._log("DEBUG", "🐛", self.BLUE, message)


# Create a global DuckTrace instance for easy use
dt = DuckTrace()

