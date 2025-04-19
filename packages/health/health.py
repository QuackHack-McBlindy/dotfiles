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
            # Use nvme-cli for NVMe drives
            cmd = ['nvme', 'smart-log', disk]
            result = subprocess.run(cmd, 
                                  stdout=subprocess.PIPE,
                                  stderr=subprocess.PIPE,
                                  text=True,
                                  timeout=10)
            
            if result.returncode != 0:
                logger.error(f"nvme command failed for {disk}: {result.stderr}")
                return "failed"
            
            # Try to find temperature using regex
            match = re.search(r'Temperature\s*:\s*(\d+)\s*Celsius', result.stdout)
            if not match:
                match = re.search(r'Temperature Sensor 1\s*:\s*(\d+)\s*°C', result.stdout)
            
            if match:
                return f"{match.group(1)}°C"
            return "N/A"
        else:
            # Existing smartctl logic for other drives
            cmd = ['smartctl', '-a', disk]
            result = subprocess.run(cmd,
                                  stdout=subprocess.PIPE,
                                  stderr=subprocess.PIPE,
                                  text=True,
                                  timeout=10)
            
            if result.returncode != 0:
                logger.error(f"smartctl failed for {disk}: {result.stderr}")
                return "failed"
            
            # Temperature parsing for regular drives
            for line in result.stdout.split('\n'):
                if 'Temperature_Celsius' in line:
                    parts = line.split()
                    if len(parts) >= 10:
                        return f"{parts[9]}°C"
                elif 'Temperature' in line and 'Celsius' in line:
                    parts = line.split()
                    return f"{parts[-2]}°C"
            
            return "N/A"
            
    except Exception as e:
        logger.error(f"Temperature error for {disk}: {str(e)}")
        return "failed"

def get_system_stats():
    try:
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

        # Get physical disks
        lsblk_output = subprocess.check_output(
            ['lsblk', '-d', '-n', '-o', 'NAME,TYPE'],
            text=True
        )
        physical_disks = [
            f"/dev/{line.split()[0]}" 
            for line in lsblk_output.split('\n') 
            if line and 'disk' in line
        ]

        # Get temperatures for all physical disks
        disk_temp_cache = {}
        for disk in physical_disks:
            disk_temp_cache[disk] = get_disk_temperature(disk)
            time.sleep(0.1)  # Brief pause between disk checks

        # Map partitions to physical disks
        for partition in psutil.disk_partitions():
            try:
                usage = psutil.disk_usage(partition.mountpoint).percent
                stats["disk_usage"][partition.device] = f"{usage}%"

                real_device = os.path.realpath(partition.device)
                parent = subprocess.check_output(
                    ['lsblk', '-no', 'pkname', real_device],
                    text=True
                ).strip()
                
                if parent:
                    parent_disk = f"/dev/{parent}"
                    stats["disk_temperature"][partition.device] = disk_temp_cache.get(parent_disk, "N/A")
                else:
                    stats["disk_temperature"][partition.device] = "N/A"

            except Exception as e:
                logger.error(f"Disk error for {partition.device}: {e}")
                stats["disk_temperature"][partition.device] = "N/A"

        return stats

    except Exception as e:
        logger.error(f"Fatal error: {e}")
        return {"error": str(e)}

if __name__ == "__main__":
    if os.geteuid() != 0:
        logger.info("Restarting with sudo privileges...")
        subprocess.run(["sudo", sys.executable] + sys.argv)
        sys.exit()

    print(json.dumps(get_system_stats(), indent=2))
