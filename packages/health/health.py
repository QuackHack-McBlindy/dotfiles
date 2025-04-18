#!/usr/bin/env python3

import subprocess
import psutil
import sys
import time
import socket
import os
import json
import re
from datetime import timedelta
import logging

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def get_disk_temperature(disk: str):
    try:
        if disk.startswith('/dev/nvme'):
            # Use your exact nvme command
            cmd = ['sudo', 'nvme', 'smart-log', disk]
            result = subprocess.run(cmd,
                                  stdout=subprocess.PIPE,
                                  stderr=subprocess.PIPE,
                                  text=True,
                                  timeout=5)
            
            if result.returncode != 0:
                return "failed"
            
            # Use your exact sed command logic in Python
            match = re.search(r'Temperature Sensor 1\s*:\s*(\d+)\s*°C', result.stdout)
            return f"{match.group(1)}°C" if match else "N/A"
        
        else:
            # Existing smartctl logic for regular disks
            cmd = ['sudo', 'smartctl', '-a', disk]
            result = subprocess.run(cmd,
                                  stdout=subprocess.PIPE,
                                  stderr=subprocess.PIPE,
                                  text=True,
                                  timeout=5)
            
            if result.returncode != 0:
                return "failed"
            
            # Original temperature parsing for regular disks
            for line in result.stdout.split('\n'):
                if 'Temperature_Celsius' in line:
                    parts = line.split()
                    return f"{parts[9]}°C" if len(parts) >= 10 else "N/A"
            return "N/A"
            
    except Exception as e:
        logger.error(f"Temperature error: {str(e)}")
        return "failed"

def get_system_stats():
    stats = {
        "hostname": socket.gethostname(),
        "cpu_usage": psutil.cpu_percent(interval=1),
        "memory_usage": psutil.virtual_memory().percent,
        "cpu_temperature": "N/A",
        "uptime": str(timedelta(seconds=time.time() - psutil.boot_time())),
        "disk_usage": {},
        "disk_temperature": {}
    }

    # Get CPU temp
    try:
        temps = psutil.sensors_temperatures()
        if 'coretemp' in temps:
            stats["cpu_temperature"] = f"{temps['coretemp'][0].current}°C"
    except Exception as e:
        logger.error(f"CPU temp error: {e}")

    # Process disks
    disk_temp_cache = {}
    partitions = psutil.disk_partitions()
    
    # Get all physical disks first
    lsblk_output = subprocess.check_output(
        ['lsblk', '-d', '-n', '-o', 'NAME'],
        text=True
    )
    physical_disks = [f"/dev/{line.strip()}" for line in lsblk_output.split('\n') if line]

    # Get temperatures for physical disks
    for disk in physical_disks:
        disk_temp_cache[disk] = get_disk_temperature(disk)

    # Map partitions to physical disks
    for partition in partitions:
        try:
            # Disk usage
            stats["disk_usage"][partition.device] = f"{psutil.disk_usage(partition.mountpoint).percent}%"
            
            # Find parent disk
            real_device = os.path.realpath(partition.device)
            parent = subprocess.check_output(
                ['lsblk', '-no', 'pkname', real_device],
                text=True
            ).strip()
            
            # Get temperature from parent
            if parent:
                parent_disk = f"/dev/{parent}"
                stats["disk_temperature"][partition.device] = disk_temp_cache.get(parent_disk, "N/A")
            else:
                stats["disk_temperature"][partition.device] = "N/A"

        except Exception as e:
            logger.error(f"Disk error: {e}")
            stats["disk_temperature"][partition.device] = "N/A"

    return stats

if __name__ == "__main__":
    if os.geteuid() != 0:
        logger.info("Restarting with sudo privileges...")
        subprocess.run(["sudo", sys.executable] + sys.argv)
        sys.exit()

    print(json.dumps(get_system_stats(), indent=2))
