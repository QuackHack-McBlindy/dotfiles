import subprocess
import psutil
import sys
import time
import socket
import os
import json
from datetime import timedelta
import logging

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def get_disk_temperature_smartctl(disk: str):
    try:
        cmd = ['smartctl', '-a']
        if disk.startswith('/dev/nvme'):
            cmd.extend(['-d', 'nvme'])
        cmd.append(disk)
        result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        if result.returncode != 0:
            return "failed"
        lines = result.stdout.splitlines()
        for line in lines:
            if "Temperature:" in line and "Celsius" in line:
                parts = line.split()
                return f"{parts[-2]}°C"
            elif "Temperature_Celsius" in line:
                parts = line.split()
                return f"{parts[9]}°C" if len(parts) >= 10 else "N/A"
        return "N/A"
    except Exception as e:
        logger.error(f"Temperature error for {disk}: {e}")
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

        try:
            temps = psutil.sensors_temperatures()
            if 'coretemp' in temps:
                stats["cpu_temperature"] = f"{temps['coretemp'][0].current}°C"
        except Exception as e:
            logger.error(f"CPU temp error: {e}")

        disk_temp_cache = {}
        for partition in psutil.disk_partitions():
            try:
                # Get disk usage
                usage = psutil.disk_usage(partition.mountpoint).percent
                stats["disk_usage"][partition.device] = f"{usage}%"

                # Get physical disk
                real_device = os.path.realpath(partition.device)
                result = subprocess.run(['lsblk', '-no', 'pkname', real_device], 
                                      stdout=subprocess.PIPE, text=True)
                parent_disk = result.stdout.strip()
                if not parent_disk:
                    stats["disk_temperature"][partition.device] = "N/A"
                    continue

                # Check cache or get new temperature
                parent_device = f"/dev/{parent_disk}"
                if parent_device not in disk_temp_cache:
                    disk_temp_cache[parent_device] = get_disk_temperature_smartctl(parent_device)
                stats["disk_temperature"][partition.device] = disk_temp_cache[parent_device]

            except Exception as e:
                logger.error(f"Disk error for {partition.device}: {e}")
                stats["disk_temperature"][partition.device] = "N/A"

        return stats

    except Exception as e:
        logger.error(f"Fatal error: {e}")
        return {"error": str(e)}

if __name__ == "__main__":
    # Check if we're root (needed for smartctl)
    if os.geteuid() != 0:
        logger.info("Restarting with sudo privileges...")
        subprocess.run(["sudo", sys.executable] + sys.argv)
        sys.exit()

    # Get and print stats
    stats = get_system_stats()
    print(json.dumps(stats, indent=2))
