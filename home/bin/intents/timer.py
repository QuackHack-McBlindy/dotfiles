import argparse
import logging
from datetime import datetime, timedelta
import os
from typing import Optional, Callable
import time
import subprocess

_LOGGER = logging.getLogger(__name__)

SOUNDFILE = "/home/pungkula/dotfiles/home/sounds/finished.wav"
STATUS_IDLE = "idle"
STATUS_ACTIVE = "active"
STATUS_PAUSED = "paused"

class Timer:
    """A simple Timer class with start, pause, cancel, and finish functionalities."""

    def __init__(self, duration: timedelta) -> None:
        """Initialize the timer."""
        self._state: str = STATUS_IDLE
        self._configured_duration: timedelta = duration
        self._remaining: Optional[timedelta] = None
        self._end: Optional[datetime] = None
        self._listener: Optional[Callable[[], None]] = None

    def start(self, duration: Optional[timedelta] = None) -> None:
        """Start the timer."""
        if self._state in (STATUS_ACTIVE, STATUS_PAUSED):
            self._state = STATUS_ACTIVE
        else:
            self._state = STATUS_ACTIVE

        # Set remaining and running duration
        if duration:
            self._remaining = duration
        elif not self._remaining:
            self._remaining = self._configured_duration

        self._end = datetime.utcnow() + self._remaining
        _LOGGER.info(f"Timer started with {self._remaining} remaining.")

    def pause(self) -> None:
        """Pause the timer."""
        if self._state != STATUS_ACTIVE:
            return
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
        if self._state != STATUS_ACTIVE:
            return
        self._state = STATUS_IDLE
        self._remaining = None
        self._end = None
        _LOGGER.info("Timer finished.")

    def check_status(self) -> str:
        """Return the current state of the timer."""
        return self._state

    def get_remaining(self) -> Optional[timedelta]:
        """Return the remaining time on the timer."""
        if self._state == STATUS_ACTIVE:
            return self._end - datetime.utcnow()
        return self._remaining

    def get_end_time(self) -> Optional[datetime]:
        """Return the end time of the timer."""
        return self._end


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

# Main program to parse arguments and run the timer
if __name__ == "__main__":
    # Command line argument parser
    parser = argparse.ArgumentParser(description="Run a timer.")
    parser.add_argument("seconds", type=int, help="Duration of the timer in seconds.")
    args = parser.parse_args()

    timer = Timer(timedelta(seconds=args.seconds))

    timer.start()

    # Simulate waiting for the timer to finish
    while timer.get_remaining() > timedelta(seconds=0):
        time.sleep(1)  # Sleep for a second and check the status
        print(f"Timer Status: {timer.check_status()}")
        print(f"Time remaining: {timer.get_remaining()}")

    timer.finish()
    print(f"Timer Status: {timer.check_status()}")

    timer.play_sound(SOUNDFILE)

