use std::{
    env,
    io::{self, Write},
    process::{Command, Stdio},
    os::unix::net::UnixStream,
};
use ducktrace_logger::*;

struct Args {
    text: String,
    model: String,
    blocking: bool,
    path: Option<String>,
    length_scale: f64,
    announce: bool,
}

fn parse_args() -> Args {
    let mut args = env::args().skip(1).peekable();
    let mut text = None;
    let mut model = None;
    let mut blocking = false;
    let mut path = None;
    let mut length_scale = 1.0;

    while let Some(arg) = args.next() {
        match arg.as_str() {
            "--text" => {
                let value = args.next().expect("Missing value for --text");
                if text.is_some() {
                    eprintln!("🦆 says ⮞ fuck ❌ Duplicate --text provided");
                    std::process::exit(1);
                }
                text = Some(value);
            }
            "--model" => {
                let value = args.next().expect("Missing value for --model");
                if model.is_some() {
                    eprintln!("🦆 says ⮞ fuck ❌ Duplicate --model provided");
                    std::process::exit(1);
                }
                model = Some(value);
            }
            "--blocking" => {
                match args.peek() {
                    Some(next) if !next.starts_with('-') => {
                        let value = args.next().unwrap();
                        blocking = value.parse::<bool>().unwrap_or_else(|_| {
                            eprintln!("🦆 says ⮞ fuck ❌ Invalid value for --blocking: {}", value);
                            std::process::exit(1);
                        });
                    }
                    _ => blocking = true,
                }
            }
            "--path" => {
                let value = args.next().expect("Missing value for --path");
                if path.is_some() {
                    eprintln!("🦆 says ⮞ fuck ❌ Duplicate --path provided");
                    std::process::exit(1);
                }
                path = Some(value);
            }
            "--announce" => {
                announce = true;
            }
            "--length-scale" => {
                let value = args.next().expect("Missing value for --length-scale");
                length_scale = value.parse::<f64>().unwrap_or_else(|_| {
                    eprintln!("🦆 says ⮞ fuck ❌ Invalid floating point value for --length-scale: {}", value);
                    std::process::exit(1);
                });
            }
            _ => {
                eprintln!("🦆 says ⮞ fuck ❌ Unknown argument: {}", arg);
                std::process::exit(1);
            }
        }
    }

    let text = text.unwrap_or_else(|| {
        eprintln!("🦆 says ⮞ fuck ❌ Missing required argument: --text");
        std::process::exit(1);
    });

    let model = model.unwrap_or_else(|| {
        eprintln!("🦆 says ⮞ fuck ❌ Missing required argument: --model");
        std::process::exit(1);
    });

    Args { text, model, blocking, path, length_scale }
}

fn try_broadcast(text: &str) -> bool {
    if let Ok(mut stream) = UnixStream::connect("/tmp/yo-tts.sock") {
        if stream.write_all(text.as_bytes()).is_ok() && stream.flush().is_ok() {
            dt_info!("Broadcasted TTS via Unix socket");
            return true;
        }
    }
    false
}


#[derive(Debug, Deserialize)]
struct Client {
    id: String,
    ip: String,
    connected_at: u64,
}


fn get_esp_ips() -> io::Result<Vec<String>> {
    let home = dirs::home_dir().ok_or_else(|| {
        io::Error::new(io::ErrorKind::NotFound, "Could not determine home directory")
    })?;
    let json_path = home.join(".config/yo/clients.json");
    let data = std::fs::read_to_string(&json_path)?;
    let clients: Vec<Client> = serde_json::from_str(&data)?;

    let ips: Vec<String> = clients
        .into_iter()
        .filter(|c| c.id.contains("esp"))
        .filter_map(|c| c.ip.split(':').next().map(|ip| ip.to_string()))
        .collect();

    Ok(ips)
}


fn stream_audio_to_esp(ip: &str, wav_path: &str) -> io::Result<()> {
    const PORT: u16 = 12346;
    const CHUNK_SIZE: usize = 1024; // samples per packet

    dt_info!("Connecting to ESP at {}:{}", ip, PORT);
    let mut stream = match TcpStream::connect((ip, PORT)) {
        Ok(s) => s,
        Err(e) => {
            dt_error!("Failed to connect to {}:{} - {}", ip, PORT, e);
            return Err(e);
        }
    };

    let reader = match hound::WavReader::open(wav_path) {
        Ok(r) => r,
        Err(e) => {
            dt_error!("Failed to open WAV file {}: {}", wav_path, e);
            return Err(io::Error::new(io::ErrorKind::Other, e));
        }
    };

    let spec = reader.spec();
    let sample_rate = spec.sample_rate;
    let channels = spec.channels;
    let bits_per_sample = spec.bits_per_sample;
    dt_info!("WAV: {} ch, {} bit, {} Hz", channels, bits_per_sample, sample_rate);

    let samples_f32: Vec<f32> = match bits_per_sample {
        16 => {
            let samples_i16: Vec<i16> = reader.into_samples::<i16>()
                .map(|s| s.unwrap())
                .collect();
            if channels == 1 {
                samples_i16.into_iter().map(|s| s as f32 / 32768.0).collect()
            } else {
                samples_i16.chunks(channels as usize)
                    .map(|chunk| chunk.iter().sum::<i16>() as f32 / (channels as f32 * 32768.0))
                    .collect()
            }
        }
        8 => {
            let samples_u8: Vec<u8> = reader.into_samples::<u8>()
                .map(|s| s.unwrap())
                .collect();
            if channels == 1 {
                samples_u8.into_iter().map(|s| (s as f32 - 128.0) / 128.0).collect()
            } else {
                samples_u8.chunks(channels as usize)
                    .map(|chunk| (chunk.iter().sum::<u8>() as f32 / channels as f32 - 128.0) / 128.0)
                    .collect()
            }
        }
        _ => {
            dt_error!("Unsupported bits per sample: {}", bits_per_sample);
            return Err(io::Error::new(io::ErrorKind::InvalidData, "Unsupported WAV format"));
        }
    };

    let total_samples = samples_f32.len();
    dt_info!("Converted to {} mono f32 samples", total_samples);

    let mut offset = 0;
    while offset < total_samples {
        let end = (offset + CHUNK_SIZE).min(total_samples);
        let chunk = &samples_f32[offset..end];

        let len_bytes = (chunk.len() as u32).to_le_bytes();
        stream.write_all(&len_bytes)?;

        let chunk_bytes: Vec<u8> = chunk.iter()
            .flat_map(|&f| f.to_le_bytes())
            .collect();
        stream.write_all(&chunk_bytes)?;

        offset = end;
        let sleep_secs = chunk.len() as f64 / sample_rate as f64;
        sleep(Duration::from_secs_f64(sleep_secs));

        dt_debug!("Progress: {}/{} samples", offset, total_samples);
    }

    dt_info!("Finished streaming to {}", ip);
    Ok(())
}


fn main() -> io::Result<()> {
    let args = parse_args();

    if args.announce {
        let out_path = match args.path {
            Some(p) => PathBuf::from(p),
            None => {
                let home = dirs::home_dir().expect("Could not find home directory");
                home.join(".config/yo/tts.wav")
            }
        };
        let out_path_str = out_path.to_string_lossy().to_string();

        run_piper_to_file(&args.model, &args.text, &out_path_str, args.length_scale)?;
        dt_info!("TTS saved to {}", out_path_str);

        let esp_ips = match get_esp_ips() {
            Ok(ips) => ips,
            Err(e) => {
                dt_error!("Failed to read clients.json: {}", e);
                std::process::exit(1);
            }
        };

        if esp_ips.is_empty() {
            dt_warn!("No ESP devices found in clients.json");
            return Ok(());
        }

        for ip in esp_ips {
            if let Err(e) = stream_audio_to_esp(&ip, &out_path_str) {
                dt_error!("Failed to stream to {}: {}", ip, e);
            }
        }
        return Ok(());
    }

    if try_broadcast(&args.text) {
        return Ok(());
    }

    let (path, is_temp) = match args.path {
        Some(p) => (p, false),
        None => {
            let temp_file = tempfile::Builder::new()
                .suffix(".wav")
                .tempfile()?;
            let temp_path = temp_file.into_temp_path();
            let path_buf = temp_path.keep()?;
            let path_str = path_buf.to_string_lossy().into_owned();
            (path_str, true)
        }
    };

    run_piper_to_file(&args.model, &args.text, &path, args.length_scale)?;

    if args.blocking {
        play_file(&path, true)?;
        if is_temp {
            std::fs::remove_file(&path)?;
            dt_info!("Removed temporary file: {}", path);
        }
    } else {
        if is_temp {
            let mut child = Command::new("sh")
                .arg("-c")
                .arg(format!("aplay '{}' && rm '{}'", path, path))
                .stdout(Stdio::null())
                .stderr(Stdio::null())
                .spawn()?;
            dt_debug!("Playing in background (file: {}, will be auto‑deleted)", path);
        } else {
            play_file(&path, false)?;
        }
    }

    Ok(())
}

fn run_piper_to_file(model: &str, text: &str, path: &str, length_scale: f64) -> io::Result<()> {
    dt_debug!("Running piper with:");
    dt_debug!("  model: {}", model);
    dt_debug!("  text: {}", text);
    dt_debug!("  output file: {}", path);
    dt_debug!("  length scale: {}", length_scale);
    dt_debug!("  command: piper --length-scale {} -m {} -f {} \"{}\"", length_scale, model, path, text);

    let status = Command::new("piper")
        .arg("--length-scale")
        .arg(length_scale.to_string())
        .arg("-m")
        .arg(model)
        .arg("-f")
        .arg(path)
        .arg(text)
        .status()?;

    if !status.success() {
        dt_info!("Piper failed with exit code: {:?}", status.code());
        std::process::exit(status.code().unwrap_or(1));
    }
    Ok(())
}

fn play_file(path: &str, blocking: bool) -> io::Result<()> {
    let mut player = Command::new("aplay")
        .arg(path)
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .spawn()?;

    if blocking {
        let status = player.wait()?;
        if !status.success() {
            dt_info!("aplay failed with exit code: {:?}", status.code());
            std::process::exit(status.code().unwrap_or(1));
        }
    } else { dt_debug!("Playing in background (file: {})", path); }

    Ok(())
}
