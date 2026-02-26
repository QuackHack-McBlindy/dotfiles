use std::collections::{HashMap, HashSet};
use std::fs;
use std::time::Duration;

use anyhow::Result;
use log::error;
use serde::Serialize;

#[derive(Debug, Serialize)]
struct SystemStats {
    hostname: String,
    uptime: String,
    cpu_usage: String,
    cpu_temperature: String,
    memory_usage: String,
    disk_usage: HashMap<String, String>,
    disk_temperature: HashMap<String, String>,
}

fn get_system_stats() -> SystemStats {
    let hostname = get_hostname().unwrap_or_else(|_| "unknown".to_string());
    let uptime = get_uptime();
    let cpu_usage = format_cpu_usage(get_cpu_usage());
    let cpu_temperature = get_cpu_temperature();
    let memory_usage = format_memory_usage(get_memory_usage());
    let disk_usage = get_disk_usage();

    let physical_disks = get_physical_disks_sysfs().unwrap_or_else(|e| {
        error!("Failed to get physical disks from sysfs: {}", e);
        vec![]
    });

    let mut disk_temp_cache = HashMap::new();
    for disk in &physical_disks {
        let temp = get_disk_temperature_sysfs(disk).unwrap_or_else(|e| {
            error!("Failed to get temperature for {} via sysfs: {}", disk, e);
            "N/A".to_string()
        });
        disk_temp_cache.insert(disk.clone(), temp);
    }

    let mut disk_temperature = HashMap::new();
    let mut shown_disks = HashSet::new();

    for (device, _) in &disk_usage {
        if !device.starts_with("/dev/") || device.contains("/dev/loop") {
            continue;
        }
        let disk_name = strip_partition_suffix(device).unwrap_or_else(|| device.clone());
        if !shown_disks.contains(&disk_name) {
            let temp = disk_temp_cache
                .get(&disk_name)
                .cloned()
                .unwrap_or_else(|| "N/A".to_string());
            disk_temperature.insert(disk_name.clone(), temp);
            shown_disks.insert(disk_name);
        }
    }

    SystemStats {
        hostname,
        uptime,
        cpu_usage,
        cpu_temperature,
        memory_usage,
        disk_usage,
        disk_temperature,
    }
}


fn format_cpu_usage(usage: f32) -> String {
    format!("{:.1}%", usage)
}

fn format_memory_usage(usage: f64) -> String {
    format!("{:.1}%", usage)
}

fn get_hostname() -> Result<String> {
    hostname::get()
        .map(|h| h.to_string_lossy().into_owned())
        .map_err(Into::into)
}

fn get_uptime() -> String {
    match uptime_lib::get() {
        Ok(duration) => {
            let secs = duration.as_secs();
            let days = secs / 86400;
            let hours = (secs % 86400) / 3600;
            let minutes = (secs % 3600) / 60;
            let seconds = secs % 60;
            if days > 0 {
                format!("{} days, {:02}:{:02}:{:02}", days, hours, minutes, seconds)
            } else {
                format!("{:02}:{:02}:{:02}", hours, minutes, seconds)
            }
        }
        Err(e) => {
            error!("Failed to get uptime: {}", e);
            "N/A".to_string()
        }
    }
}

fn get_cpu_usage() -> f32 {
    let mut sys = sysinfo::System::new();
    sys.refresh_cpu_usage();
    std::thread::sleep(Duration::from_secs(1));
    sys.refresh_cpu_usage();
    sys.global_cpu_info().cpu_usage()
}

fn get_cpu_temperature() -> String {
    if let Ok(temp) = read_cpu_temp_thermal() {
        return temp;
    }
    if let Ok(temp) = read_cpu_temp_hwmon() {
        return temp;
    }
    "N/A".to_string()
}

fn read_cpu_temp_thermal() -> Result<String> {
    let thermal_zones = fs::read_dir("/sys/class/thermal")?
        .filter_map(|entry| entry.ok())
        .filter(|e| e.file_name().to_string_lossy().starts_with("thermal_zone"));

    for zone in thermal_zones {
        let type_path = zone.path().join("type");
        let temp_path = zone.path().join("temp");
        if type_path.exists() && temp_path.exists() {
            if let Ok(zone_type) = fs::read_to_string(type_path) {
                let zone_type = zone_type.trim();
                if zone_type.contains("cpu") || zone_type.contains("pkg") || zone_type == "x86_pkg_temp" {
                    if let Ok(temp) = read_temp_file(&temp_path.to_string_lossy()) {
                        return Ok(format!("{:.1}°C", temp));
                    }
                }
            }
        }
    }
    anyhow::bail!("No CPU temperature found in thermal zones")
}

fn read_cpu_temp_hwmon() -> Result<String> {
    let hwmon_dirs = fs::read_dir("/sys/class/hwmon")?;
    for entry in hwmon_dirs.filter_map(|e| e.ok()) {
        let name_path = entry.path().join("name");
        if !name_path.exists() {
            continue;
        }
        let name = fs::read_to_string(name_path)?;
        let name = name.trim();
        if name == "coretemp" || name == "k10temp" || name == "zenpower" {
            let temp1 = entry.path().join("temp1_input");
            if temp1.exists() {
                if let Ok(temp) = read_temp_file(&temp1.to_string_lossy()) {
                    return Ok(format!("{:.1}°C", temp));
                }
            }
            if let Ok(files) = fs::read_dir(entry.path()) {
                for file in files.flatten() {
                    let fname = file.file_name().to_string_lossy().into_owned();
                    if fname.starts_with("temp") && fname.ends_with("_input") {
                        if let Ok(temp) = read_temp_file(&file.path().to_string_lossy()) {
                            return Ok(format!("{:.1}°C", temp));
                        }
                    }
                }
            }
        }
    }
    anyhow::bail!("No CPU temperature found in hwmon")
}

fn get_memory_usage() -> f64 {
    let mut sys = sysinfo::System::new();
    sys.refresh_memory();
    let total = sys.total_memory() as f64;
    let used = sys.used_memory() as f64;
    if total > 0.0 {
        (used / total) * 100.0
    } else {
        0.0
    }
}

fn get_disk_usage() -> HashMap<String, String> {
    let mut disks = sysinfo::Disks::new();
    disks.refresh_list();
    let mut map = HashMap::new();
    for disk in disks.list() {
        let device = disk.name().to_string_lossy().into_owned();
        if !device.starts_with("/dev/") || device.contains("/dev/loop") {
            continue;
        }
        let total = disk.total_space();
        let available = disk.available_space();
        if total > 0 {
            let used = total - available;
            let percent = (used as f64 / total as f64) * 100.0;
            map.insert(device, format!("{:.1}%", percent));
        }
    }
    map
}

fn get_physical_disks_sysfs() -> Result<Vec<String>> {
    let block_dir = fs::read_dir("/sys/block")?;
    let mut disks = Vec::new();
    for entry in block_dir.filter_map(|e| e.ok()) {
        let name = entry.file_name().to_string_lossy().into_owned();
        if name.starts_with("loop") || name.starts_with("ram") || name.starts_with("dm-") {
            continue;
        }
        disks.push(format!("/dev/{}", name));
    }
    Ok(disks)
}

fn get_disk_temperature_sysfs(disk: &str) -> Result<String> {
    let dev_name = disk.trim_start_matches("/dev/");
    let sysfs_block = format!("/sys/block/{}", dev_name);

    let nvme_temp_path = format!("{}/device/temperature", sysfs_block);
    if let Ok(temp) = read_temp_file(&nvme_temp_path) {
        return Ok(format!("{}°C", temp));
    }

    if dev_name.starts_with("nvme") {
        if let Some(ctrl) = dev_name.split('n').next() {
            let nvme_class_path = format!("/sys/class/nvme/{}/device/temperature", ctrl);
            if let Ok(temp) = read_temp_file(&nvme_class_path) {
                return Ok(format!("{}°C", temp));
            }
        }
    }

    let hwmon_dir = format!("{}/device/hwmon", sysfs_block);
    if let Ok(entries) = fs::read_dir(&hwmon_dir) {
        for entry in entries.flatten() {
            let hwmon_path = entry.path();
            if let Ok(temp_files) = fs::read_dir(&hwmon_path) {
                for file in temp_files.flatten() {
                    let file_name = file.file_name().to_string_lossy().into_owned();
                    if file_name.starts_with("temp") && file_name.ends_with("_input") {
                        if let Ok(temp) = read_temp_file(&file.path().to_string_lossy()) {
                            return Ok(format!("{}°C", temp));
                        }
                    }
                }
            }
        }
    }

    anyhow::bail!("No temperature found in sysfs for {}", disk)
}

fn read_temp_file(path: &str) -> Result<f32> {
    let content = fs::read_to_string(path)?;
    let millideg = content.trim().parse::<f32>()?;
    Ok(millideg / 1000.0)
}


fn strip_partition_suffix(device: &str) -> Option<String> {
    let name = device.trim_start_matches("/dev/");
    let mut digits_start = name.len();
    for (i, c) in name.char_indices().rev() {
        if !c.is_ascii_digit() {
            digits_start = i + c.len_utf8();
            break;
        }
    }
    if digits_start == name.len() {
        return None;
    }
    let mut base_end = digits_start;
    if digits_start > 0 && name.chars().nth(digits_start - 1) == Some('p') {
        base_end = digits_start - 1;
    }
    let base = &name[..base_end];
    if base.is_empty() {
        None
    } else {
        Some(format!("/dev/{}", base))
    }
}

fn main() {
    env_logger::init();

    let stats = get_system_stats();
    let json = serde_json::to_string_pretty(&stats).expect("Failed to serialize stats");
    println!("{}", json);
}
