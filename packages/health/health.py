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
            # Use nvme-cli from Nix store
            cmd = ['${pkgs.nvme-cli}/bin/nvme', 'smart-log', disk]
            result = subprocess.run(cmd,
                                  stdout=subprocess.PIPE,
                                  stderr=subprocess.PIPE,
                                  text=True,
                                  timeout=10)
            
            if result.returncode != 0:
                logger.error(f"NVME command failed: {result.stderr}")
                return "failed"
            
            temp_match = re.search(r'Temperature\s*:\s*(\d+)\s*C', result.stdout)
            return f"{temp_match.group(1)}°C" if temp_match else "N/A"
        else:
            # Existing smartctl logic for other drives
            cmd = ['${pkgs.smartmontools}/bin/smartctl', '-a', disk]
            result = subprocess.run(cmd,
                                  stdout=subprocess.PIPE,
                                  stderr=subprocess.PIPE,
                                  text=True,
                                  timeout=10)
            
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
        "cpu_usage": psutil.cpu_percent(interval=1),
        "memory_usage": psutil.virtual_memory().percent,
        "cpu_temperature": "N/A",
        "uptime": str(timedelta(seconds=time.time() - psutil.boot_time())),
        "disks": {}
    }

    try:
        temps = psutil.sensors_temperatures()
        if 'coretemp' in temps:
            stats["cpu_temperature"] = f"{temps['coretemp'][0].current}°C"
    except Exception as e:
        logger.error(f"CPU temp error: {e}")

    # Get physical disks
    lsblk_output = subprocess.check_output(
        ['lsblk', '-d', '-n', '-o', 'NAME,MODEL,TYPE'],
        text=True
    )
    
    physical_disks = {}
    for line in lsblk_output.split('\n'):
        if line and 'disk' in line:
            parts = line.split(maxsplit=2)
            dev_name = f"/dev/{parts[0]}"
            physical_disks[dev_name] = {
                "model": parts[1] if len(parts) > 1 else "N/A",
                "temperature": get_disk_temperature(dev_name),
                "partitions": []
            }

    # Get partition info
    for partition in psutil.disk_partitions():
        try:
            real_device = os.path.realpath(partition.device)
            parent = subprocess.check_output(
                ['lsblk', '-no', 'pkname', real_device],
                text=True
            ).strip()
            
            if parent:
                parent_disk = f"/dev/{parent}"
                if parent_disk in physical_disks:
                    physical_disks[parent_disk]["partitions"].append({
                        "device": partition.device,
                        "mountpoint": partition.mountpoint,
                        "usage": f"{psutil.disk_usage(partition.mountpoint).percent}%"
                    })
        except Exception as e:
            logger.error(f"Partition error: {e}")

    stats["disks"] = physical_disks
    return stats

if __name__ == "__main__":
    if os.geteuid() != 0:
        os.execvp("sudo", ["sudo", sys.executable] + sys.argv)
    
    # Automatically format output as JSON
    print(json.dumps(get_system_stats(), indent=2))
