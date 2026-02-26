# **health-rs**

Simple system health reporting in JSON.  
  
  
**Example output:**  


```bash
{
  "hostname": "desktop",
  "uptime": "01:39:44",
  "cpu_usage": "6.4%",
  "cpu_temperature": "28.0°C",
  "memory_usage": "16.6%",
  "disk_usage": {
    "/dev/nvme0n1p2": "94.0%",
    "/dev/nvme0n1p1": "7.5%"
  },
  "disk_temperature": {
    "/dev/nvme0n1": "N/A"
  }
}
```

