import argparse
import logging
from datetime import datetime, timedelta
import os
import re
import time
import subprocess

_LOGGER = logging.getLogger(__name__)

SOUNDFILE = "/home/pungkula/dotfiles/home/sounds/finished.wav"
STATUS_IDLE = "idle"
STATUS_ACTIVE = "active"
STATUS_PAUSED = "paused"

TIME_UNITS = {
    "h": 3600, "hour": 3600, "hours": 3600, "timmar": 3600, "timme": 3600,
    "min": 60, "minute": 60, "minutes": 60, "minuter": 60, "minut": 60,
    "sec": 1, "second": 1, "seconds": 1, "sekunder": 1, "sekund": 1
}

def parse_time_input(time_str: str) -> int:
    """Parses a human-readable time format and returns total seconds."""
    total_seconds = 0
    matches = re.findall(r"(\d+)\s*(\w+)", time_str)
    for amount, unit in matches:
        if unit in TIME_UNITS:
            total_seconds += int(amount) * TIME_UNITS[unit]
        else:
            raise ValueError(f"Unknown time unit: {unit}")
    return total_seconds

class Timer:
    """A simple Timer class with start, pause, cancel, and finish functionalities."""

    def __init__(self, duration: timedelta) -> None:
        """Initialize the timer."""
        self._state: str = STATUS_IDLE
        self._configured_duration: timedelta = duration
        self._remaining: timedelta = duration
        self._end: Optional[datetime] = None

    def start(self) -> None:
        """Start the timer."""
        self._state = STATUS_ACTIVE
        self._end = datetime.utcnow() + self._remaining
        _LOGGER.info(f"Timer started with {self._remaining} remaining.")

    def pause(self) -> None:
        """Pause the timer."""
        if self._state == STATUS_ACTIVE:
            self._remaining = self._end - datetime.utcnow()
            self._state = STATUS_PAUSED
            self._end = None
            _LOGGER.info("Timer paused.")

    def cancel(self) -> None:
        """Cancel the timer."""
        self._state = STATUS_IDLE
        self._end = None
        self._remaining = None
        _LOGGER.info("Timer canceled.")

    def finish(self) -> None:
        """Finish the timer."""
        if self._state == STATUS_ACTIVE:
            self._state = STATUS_IDLE
            self._remaining = None
            self._end = None
            _LOGGER.info("Timer finished.")

    def get_remaining(self) -> Optional[timedelta]:
        """Return the remaining time on the timer."""
        if self._state == STATUS_ACTIVE:
            return self._end - datetime.utcnow()
        return self._remaining

    def play_sound(self, sound_file: str = "finish.wav") -> None:
        """Play a sound when the timer finishes."""
        if os.path.exists(sound_file):
            for _ in range(10):
                subprocess.run(["aplay", sound_file])
            time.sleep(15)
            for _ in range(8):
                subprocess.run(["aplay", sound_file])
        else:
            _LOGGER.warning("Sound file not found, skipping sound.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Run a timer.")
    parser.add_argument("time_input", type=str, help="Duration of the timer in human-readable format.")
    args = parser.parse_args()

    try:
        total_seconds = parse_time_input(args.time_input)
        timer = Timer(timedelta(seconds=total_seconds))
        timer.start()

        while timer.get_remaining() > timedelta(seconds=0):
            time.sleep(1)
            print(f"Time remaining: {timer.get_remaining()}")

        timer.finish()
        timer.play_sound(SOUNDFILE)
    except ValueError as e:
        print(f"Error: {e}")
