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

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def get_disk_temperature(disk: str):
    try:
        if disk.startswith('/dev/nvme'):
            cmd = ['sudo', 'nvme', 'smart-log', disk]
            result = subprocess.run(cmd,
                                  stdout=subprocess.PIPE,
                                  stderr=subprocess.PIPE,
                                  text=True,
                                  timeout=5)
            
            if result.returncode != 0:
                return "failed"
            
            match = re.search(r'Temperature Sensor 1\s*:\s*(\d+)\s*°C', result.stdout)
            return f"{match.group(1)}°C" if match else "N/A"
        
        else:
            cmd = ['sudo', 'smartctl', '-a', disk]
            result = subprocess.run(cmd,
                                  stdout=subprocess.PIPE,
                                  stderr=subprocess.PIPE,
                                  text=True,
                                  timeout=5)
            
            if result.returncode != 0:
                return "failed"
            
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
        "uptime": str(timedelta(seconds=time.time() - psutil.boot_time())),
        "cpu_usage": psutil.cpu_percent(interval=1),
        "cpu_temperature": "N/A",
        "memory_usage": psutil.virtual_memory().percent,
        "disk_usage": {},
        "disk_temperature": {}
    }

    try:
        temps = psutil.sensors_temperatures()
        if 'coretemp' in temps:
            stats["cpu_temperature"] = f"{temps['coretemp'][0].current}°C"
    except Exception as e:
        logger.error(f"CPU temp error: {e}")

    disk_temp_cache = {}
    partitions = psutil.disk_partitions()
    
    lsblk_output = subprocess.check_output(
        ['lsblk', '-d', '-n', '-o', 'NAME'],
        text=True
    )
    physical_disks = [f"/dev/{line.strip()}" for line in lsblk_output.split('\n') if line]

    for disk in physical_disks:
        disk_temp_cache[disk] = get_disk_temperature(disk)

    shown_disks = set()
    for partition in partitions:
        try:
            stats["disk_usage"][partition.device] = f"{psutil.disk_usage(partition.mountpoint).percent}%"
            
            real_device = os.path.realpath(partition.device)
            parent = subprocess.check_output(
                ['lsblk', '-no', 'pkname', real_device],
                text=True
            ).strip()
            
            if parent:
                parent_disk = f"/dev/{parent}"
                if parent_disk not in shown_disks:
                    stats["disk_temperature"][parent_disk] = disk_temp_cache.get(parent_disk, "N/A")
                    shown_disks.add(parent_disk)

        except Exception as e:
            logger.error(f"Disk error: {e}")
            continue

    return stats

if __name__ == "__main__":
    print(json.dumps(get_system_stats(), indent=4))
