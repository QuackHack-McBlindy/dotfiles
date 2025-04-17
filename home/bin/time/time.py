#!/usr/bin/env python3
from datetime import datetime

def get_time():
    return datetime.now().strftime("%H:%M")

if __name__ == "__main__":
    print(get_time())
