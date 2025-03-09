import subprocess
import psutil
import sys
import time
import socket
from datetime import timedelta
from fastapi import FastAPI
from pydantic import BaseModel
import uvicorn
import logging

# Set up logging
logging.basicConfig(level=logging.DEBUG)  # Set the logging level to DEBUG
logger = logging.getLogger(__name__)

# Define a Pydantic model for the response data
class HealthResponse(BaseModel):
    hostname: str
    cpu_usage: float
    memory_usage: float
    cpu_temperature: str
    disk_usage: dict
    disk_temperature: dict
    uptime: str

# Initialize the FastAPI app
app = FastAPI()

# Function to get the disk names using lsblk
def get_disk_names():
    try:
        logger.debug("Running lsblk to fetch disk names...")
        result = subprocess.run(['lsblk', '-d', '-n', '-o', 'NAME'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        if result.returncode != 0:
            raise Exception("Error running lsblk command")
        logger.debug("lsblk output: %s", result.stdout)
        return result.stdout.splitlines()
    except Exception as e:
        logger.error("Error fetching disk names: %s", e)
        return []

# Function to resolve UUID to actual device path
def get_device_from_uuid(uuid: str):
    try:
        result = subprocess.run(['lsblk', '-o', 'NAME,UUID'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        if result.returncode != 0:
            raise Exception("Error running lsblk to resolve UUID")
        for line in result.stdout.splitlines():
            if uuid in line:
                return f"/dev/{line.split()[0]}"
    except Exception as e:
        logger.error(f"Error resolving UUID {uuid}: {e}")
        return None

def get_disk_temperature_smartctl(disk: str):
    try:
        logger.debug(f"Running smartctl for disk {disk}...")
        result = subprocess.run(['smartctl', '-a', f'/dev/{disk}'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        if result.returncode != 0:
            raise Exception(f"Error running smartctl for {disk}")

        logger.debug(f"smartctl output for {disk}:\n{result.stdout}")

        # Find the temperature line in the output
        lines = result.stdout.splitlines()
        temperature_info = None
        for line in lines:
            logger.debug(f"Checking line: {line}")
            if "Temperature" in line:
                if "Celsius" in line:  # For standard drives (HDD/SSD)
                    temp_parts = line.split()
                    if len(temp_parts) >= 2:
                        temperature_info = f"{temp_parts[1]}°C"
                elif "194" in line:  # For older HDDs with specific attributes (e.g., 194 Temperature_Celsius)
                    parts = line.split()
                    if len(parts) > 9:
                        temperature_info = f"{parts[9]}°C (Min: {parts[7]}°C, Max: {parts[8]}°C)"
                elif "Temperature:" in line:  # For NVMe drives
                    temp_parts = line.split()
                    if len(temp_parts) > 1:
                        temperature_info = f"{temp_parts[-2]}°C"

        if temperature_info:
            logger.debug(f"Disk temperature for {disk}: {temperature_info}")
        else:
            logger.warning(f"No temperature info found for {disk}")
        return temperature_info if temperature_info else "N/A"
    except Exception as e:
        logger.error(f"Error fetching temperature for disk {disk}: {e}")
        return "failed"




# Pydantic model for disk temperature data
class DiskTemperature(BaseModel):
    disk: str
    min_temperature: str
    max_temperature: str
    current_temperature: str

# Function to get temperature data for all disks
def get_disk_temperatures():
    # Get the list of all disk devices (excluding partitions)
    disks = subprocess.check_output("lsblk -d -o NAME", shell=True).decode().splitlines()[1:]

    temperature_data = []
    
    # Loop through each disk and check the temperature using smartctl
    for disk in disks:
        disk_name = f"/dev/{disk}"

        # Get the temperature data from smartctl
        temp_data = subprocess.check_output(f"smartctl -A {disk_name}", shell=True).decode()

        if "Temperature_Celsius" in temp_data:
            # Extract Min, Max, and Current temperature values
            min_temp = None
            max_temp = None
            current_temp = None

            for line in temp_data.splitlines():
                if "Temperature_Celsius" in line:
                    parts = line.split()
                    min_temp = parts[9]  # Min Temperature
                    max_temp = parts[10]  # Max Temperature
                    current_temp = parts[12]  # Current Temperature
                    break
            
            # Append to the result if all data is available
            if min_temp and max_temp and current_temp:
                temperature_data.append(DiskTemperature(
                    disk=disk_name,
                    min_temperature=min_temp,
                    max_temperature=max_temp,
                    current_temperature=current_temp
                ))
        else:
            temperature_data.append(DiskTemperature(
                disk=disk_name,
                min_temperature="Not available",
                max_temperature="Not available",
                current_temperature="Not available"
            ))

    return temperature_data





# Endpoint to get disk temperatures
@app.get("/api/disks/temp", response_model=list[DiskTemperature])
def get_temperatures():
    return get_disk_temperatures()



# Route root ("/") to "/health"
@app.get("/")
async def root():
    return await get_system_stats()

@app.get("/health", response_model=HealthResponse)
async def get_system_stats():
    try:
        logger.debug("Fetching system stats...")

        # Get system hostname
        hostname = socket.gethostname()
        logger.debug(f"Hostname: {hostname}")

        # Get CPU usage percentage
        cpu_usage = psutil.cpu_percent(interval=1)
        logger.debug(f"CPU usage: {cpu_usage}%")

        # Get memory usage percentage
        memory_usage = psutil.virtual_memory().percent
        logger.debug(f"Memory usage: {memory_usage}%")

        # Get CPU temperature (Linux only)
        local_temp = None
        try:
            temp_info = psutil.sensors_temperatures()
            if temp_info and 'coretemp' in temp_info:
                local_temp = temp_info['coretemp'][0].current
            if local_temp is None:
                local_temp = "N/A"
            logger.debug(f"CPU temperature: {local_temp}")
        except Exception as e:
            logger.warning(f"Error fetching CPU temperature: {e}")
            local_temp = "N/A"

        # Get disk usage and temperature for all mounted partitions
        disk_usage = {}
        disk_temp = {}

        partitions = psutil.disk_partitions()
        logger.debug(f"Disk partitions: {partitions}")

        for partition in partitions:
            # Get disk usage for each partition
            usage = psutil.disk_usage(partition.mountpoint).percent
            disk_usage[partition.device] = f"{usage}%"
            logger.debug(f"Disk usage for {partition.device}: {disk_usage[partition.device]}")

            # Get the parent device (e.g., from /dev/nvme0n1p1 to /dev/nvme0n1)
            parent_device = partition.device.split('p')[0]

            # Get disk temperature using smartctl for the root device (parent device)
            disk_temp[parent_device] = get_disk_temperature_smartctl(parent_device)

        # Get system uptime
        boot_time = psutil.boot_time()
        current_time = time.time()
        uptime_seconds = current_time - boot_time
        uptime = str(timedelta(seconds=uptime_seconds))  # Format uptime as HH:MM:SS
        logger.debug(f"System uptime: {uptime}")

        # Prepare the response data
        response_data = {
            "hostname": hostname,
            "cpu_usage": cpu_usage,
            "memory_usage": memory_usage,
            "cpu_temperature": str(local_temp),
            "uptime": uptime
        }

        # Add disk usage and temperature with device names in the response
        for partition in disk_usage:
            response_data[f"disk_usage {partition}"] = disk_usage[partition]
            response_data[f"disk_temperature {partition}"] = str(disk_temp.get(partition, "N/A"))

        logger.debug(f"Response data: {response_data}")

        # Return the final response
        return response_data
    except Exception as e:
        logger.error(f"Error fetching system stats: {e}")
        return {"error": f"An error occurred: {e}"}

# To run the app programmatically with sudo
if __name__ == "__main__":
    # Check if the current user is root
    if subprocess.run("id -u", shell=True, capture_output=True).stdout.strip() != b"0":
        # If not root, run the script with sudo to start Uvicorn
        subprocess.run(["sudo", sys.executable, sys.argv[0]])
    else:
        # Otherwise, run the app normally with Uvicorn
        uvicorn.run(app, host="0.0.0.0", port=35010)
