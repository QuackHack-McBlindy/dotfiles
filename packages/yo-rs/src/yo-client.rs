// ddotfiles/packages/yo-rs/src/yo-client.rs ⮞ https://github.com/QuackHack-McBlindy/dotfiles
use std::{ // 🦆 says ⮞ yo-client (Microphone Client)
    env,
    io::{Cursor, Read, Write},
    net::TcpStream,
    sync::{
        atomic::{AtomicBool, Ordering},
        mpsc, Arc, Mutex,
    },
    thread,
    time::{Duration, Instant},
};

use anyhow::{bail, Result};
use byteorder::{LittleEndian, WriteBytesExt};
use cpal::{
    traits::{DeviceTrait, HostTrait, StreamTrait},
    SampleFormat,
};
use rodio::OutputStream;

use oww_rs::{
    mic::{
        converters::i16_to_f32,
        mic_config::find_best_config,
        process_audio::resample_into_chunks,
        resampler::make_resampler,
    },
    oww::OWW_MODEL_CHUNK_SIZE,
};

const DEFAULT_SERVER_ADDR: &str = "127.0.0.1:12345";
const DING_WAV: &[u8] = include_bytes!("../ding.wav");

fn print_usage(program_name: &str) {
    eprintln!(
        "Usage: {} [OPTIONS]\n\
         Options:\n\
         --uri <ADDRESS>              Server address (default: {})\n\
         --debug                       Enable debug output (prints RMS)\n\
         --silence-threshold <FLOAT>   RMS threshold for silence detection (default: 0.005)\n\
         --silence-timeout <SECONDS>   Seconds of silence before stopping (default: 1.0)\n\
         --max-duration <SECONDS>      Maximum recording length (default: 5.0)\n\
         --help, -h                     Show this help message",
        program_name, DEFAULT_SERVER_ADDR
    );
}

// 🦆 says ⮞ RMS helper
fn rms_f32(samples: &[f32]) -> f32 {
    if samples.is_empty() {
        return 0.0;
    }
    let sum_squares: f32 = samples.iter().map(|&x| x * x).sum();
    (sum_squares / samples.len() as f32).sqrt()
}

fn main() -> Result<()> {
    env_logger::init();

    let args: Vec<String> = env::args().collect();

    if args.iter().any(|s| s == "--help" || s == "-h") {
        print_usage(&args[0]);
        return Ok(());
    }

    let mut debug = false;
    let mut server_addr = DEFAULT_SERVER_ADDR.to_string();
    let mut silence_threshold = 0.005;
    let mut silence_timeout_secs = 1.0;
    let mut max_duration_secs = 5.0;

    let mut i = 1;
    while i < args.len() {
        match args[i].as_str() {
            "--uri" => {
                if i + 1 < args.len() {
                    server_addr = args[i + 1].clone();
                    i += 2;
                } else {
                    eprintln!("Error: --uri requires a server address");
                    print_usage(&args[0]);
                    std::process::exit(1);
                }
            }
            "--debug" => {
                debug = true;
                i += 1;
            }
            "--silence-threshold" => {
                if i + 1 < args.len() {
                    silence_threshold = args[i + 1].parse().unwrap_or_else(|_| {
                        eprintln!("Invalid silence threshold – must be a float");
                        std::process::exit(1);
                    });
                    i += 2;
                } else {
                    eprintln!("Error: --silence-threshold requires a value");
                    print_usage(&args[0]);
                    std::process::exit(1);
                }
            }
            "--silence-timeout" => {
                if i + 1 < args.len() {
                    silence_timeout_secs = args[i + 1].parse().unwrap_or_else(|_| {
                        eprintln!("Invalid silence timeout – must be a number (seconds)");
                        std::process::exit(1);
                    });
                    i += 2;
                } else {
                    eprintln!("Error: --silence-timeout requires a value");
                    print_usage(&args[0]);
                    std::process::exit(1);
                }
            }
            "--max-duration" => {
                if i + 1 < args.len() {
                    max_duration_secs = args[i + 1].parse().unwrap_or_else(|_| {
                        eprintln!("Invalid max duration – must be a number (seconds)");
                        std::process::exit(1);
                    });
                    i += 2;
                } else {
                    eprintln!("Error: --max-duration requires a value");
                    print_usage(&args[0]);
                    std::process::exit(1);
                }
            }
            "--help" | "-h" => {
                print_usage(&args[0]);
                return Ok(());
            }
            _ => {
                eprintln!("Unknown argument: {}", args[i]);
                print_usage(&args[0]);
                std::process::exit(1);
            }
        }
    }

    let silence_timeout = Duration::from_secs_f64(silence_timeout_secs);
    let max_duration = Duration::from_secs_f64(max_duration_secs);

    println!("Settings: debug={}, silence_threshold={}, silence_timeout={}s, max_duration={}s",
         debug, silence_threshold, silence_timeout_secs, max_duration_secs);

    // 🦆 says ⮞ Microphone setup
    let host = cpal::default_host();
    let device = host
        .default_input_device()
        .ok_or_else(|| anyhow::anyhow!("No input device"))?;
    let (config, sample_format) = find_best_config(&device)
        .map_err(|e| anyhow::anyhow!("Config error: {}", e))?;
    println!("Selected config: {:?}", config);

    let original_sample_rate = config.sample_rate.0;
    let channels = config.channels as usize;

    // 🦆 says ⮞ shared channel for audio chunks – can be replaced when reconnecting
    let chunk_tx_global: Arc<Mutex<Option<mpsc::SyncSender<Vec<f32>>>>> = Arc::new(Mutex::new(None));

    // 🦆 says ⮞ shared state for transcription
    let is_transcribing = Arc::new(AtomicBool::new(false));
    let recording_active = Arc::new(AtomicBool::new(false));
    let recording_buffer = Arc::new(Mutex::new(Vec::<f32>::new()));

    // 🦆 says ⮞ microphone stream – runs continuously regardless of connection
    let buffer: Arc<Mutex<Vec<f32>>> = Arc::new(Mutex::new(vec![]));
    let buffer_clone = buffer.clone();

    let mut resampler = make_resampler(
        original_sample_rate,
        OWW_MODEL_CHUNK_SIZE as u32,
        channels,
    )
    .map_err(|e| anyhow::anyhow!("Resampler error: {}", e))?;

    let err_fn = |err| eprintln!("Stream error: {}", err);

    // 🦆 says ⮞ build the input stream with a callback that uses the global sender
    let stream = match sample_format {
        SampleFormat::F32 => device.build_input_stream(
            &config,
            {
                let chunk_tx_global = chunk_tx_global.clone();
                let recording_active = recording_active.clone();
                let recording_buffer = recording_buffer.clone();
                move |data: &[f32], _| {
                    let chunks = resample_into_chunks(data, &buffer_clone, channels, &mut resampler);
                    if let Some(tx) = chunk_tx_global.lock().unwrap().as_ref() {
                        for chunk in chunks {
                            let _ = tx.try_send(chunk.data_f32[0].clone()); // 🦆 says ⮞ IGNORE full errors
                        }
                    }
                    if recording_active.load(Ordering::Relaxed) {
                        let mut guard = recording_buffer.lock().unwrap();
                        guard.extend_from_slice(data);
                    }
                }
            },
            err_fn,
            None,
        )?,
        SampleFormat::I16 => device.build_input_stream(
            &config,
            {
                let chunk_tx_global = chunk_tx_global.clone();
                let recording_active = recording_active.clone();
                let recording_buffer = recording_buffer.clone();
                move |data: &[i16], _| {
                    let samples: Vec<f32> = data.iter().map(i16_to_f32).collect();
                    let chunks = resample_into_chunks(&samples, &buffer_clone, channels, &mut resampler);
                    if let Some(tx) = chunk_tx_global.lock().unwrap().as_ref() {
                        for chunk in chunks {
                            let _ = tx.try_send(chunk.data_f32[0].clone());
                        }
                    }
                    if recording_active.load(Ordering::Relaxed) {
                        let mut guard = recording_buffer.lock().unwrap();
                        guard.extend_from_slice(&samples);
                    }
                }
            },
            err_fn,
            None,
        )?,
        _ => bail!("Unsupported sample format: {:?}", sample_format),
    };

    stream.play()?;
    println!("Streaming audio to detector. Press Enter to stop.");

    loop {
        println!("Connecting to {}...", server_addr);
        let stream = loop {
            match TcpStream::connect(&server_addr) {
                Ok(s) => break s,
                Err(e) => {
                    eprintln!("⚠️ 🚫 {}. Retrying in 5 seconds...", e);
                    thread::sleep(Duration::from_secs(5));
                }
            }
        };
        // 🦆 says ⮞ SUCCESSFUL CONNECTION
        println!("📡 ☑️ 🎙️ @ {}", server_addr);

        // 🦆 says ⮞ Clone streams for reading and writing
        let read_stream = stream.try_clone()?;
        let write_stream = Arc::new(Mutex::new(stream.try_clone()?));

        // 🦆 says ⮞ set a read timeout so the receiver thread can check shutdown flag
        if let Err(e) = read_stream.set_read_timeout(Some(Duration::from_secs(1))) {
            eprintln!("Failed to set read timeout: {}", e);
        }

        // 🦆 says ⮞ create a new channel for audio chunks
        let (tx, rx) = mpsc::sync_channel::<Vec<f32>>(100);
        *chunk_tx_global.lock().unwrap() = Some(tx);

        // 🦆 says ⮞ shutdown flag to stop threads gracefully
        let shutdown = Arc::new(AtomicBool::new(false));

        // 🦆 says ⮞ channel to notify main thread when a worker exits
        let (exit_tx, exit_rx) = mpsc::channel::<()>();

        // 🦆 says ⮞ Sender thread
        let sender_shutdown = shutdown.clone();
        let sender_exit_tx = exit_tx.clone();
        let sender_write_stream = write_stream.clone();
        let sender_is_transcribing = is_transcribing.clone();
        let sender_handle = thread::spawn(move || {
            // 🦆 says ⮞ Use catch_unwind to ensure exit notification is sent even on panic
            let _ = std::panic::catch_unwind(|| {
                for chunk in rx {
                    // 🦆 says ⮞ check shutdown flag before each iteration
                    if sender_shutdown.load(Ordering::SeqCst) {
                        break;
                    }
                    while sender_is_transcribing.load(Ordering::SeqCst) {
                        thread::sleep(Duration::from_millis(10));
                        if sender_shutdown.load(Ordering::SeqCst) {
                            return;
                        }
                    }
                    {
                        let mut guard = sender_write_stream.lock().unwrap();
                        if sender_shutdown.load(Ordering::SeqCst) {
                            break;
                        }
                        if let Err(e) = guard.write_u32::<LittleEndian>(chunk.len() as u32) {
                            eprintln!("Failed to send length: {}", e);
                            break;
                        }
                        let mut bytes = Vec::with_capacity(chunk.len() * 4);
                        for &sample in &chunk {
                            bytes.extend_from_slice(&sample.to_le_bytes());
                        }
                        if let Err(e) = guard.write_all(&bytes) {
                            eprintln!("Failed to send samples: {}", e);
                            break;
                        }
                        if let Err(e) = guard.flush() {
                            eprintln!("Failed to flush: {}", e);
                            break;
                        }
                    }
                }
            });
            let _ = sender_exit_tx.send(());
        });

        // 🦆 says ⮞ receiver thread!
        let receiver_shutdown = shutdown.clone();
        let receiver_exit_tx = exit_tx.clone();
        let receiver_write_stream = write_stream.clone();
        let receiver_is_transcribing = is_transcribing.clone();
        let receiver_recording_active = recording_active.clone();
        let receiver_recording_buffer = recording_buffer.clone();
        let receiver_original_sample_rate = original_sample_rate;
        let receiver_channels = channels;
        let receiver_debug = debug;
        let receiver_silence_threshold = silence_threshold;
        let receiver_silence_timeout = silence_timeout;
        let receiver_max_duration = max_duration;

        let receiver_handle = thread::spawn(move || {
            let _ = std::panic::catch_unwind(|| {
                let mut read_stream = read_stream; // 🦆 say ⮞ take ownership
                let mut buf = [0u8; 1];
                loop {
                    if receiver_shutdown.load(Ordering::SeqCst) {
                        break;
                    }
                    match read_stream.read_exact(&mut buf) {
                        Ok(()) => {
                            if buf[0] == 0x01 {
                                if receiver_is_transcribing.load(Ordering::SeqCst) {
                                    continue;
                                }
                                receiver_is_transcribing.store(true, Ordering::SeqCst);

                                // 🦆 says ⮞ play detection sound
                                let sound_data = DING_WAV.to_vec();
                                thread::spawn(move || {
                                    let (_stream, handle) = OutputStream::try_default().unwrap();
                                    let cursor = Cursor::new(sound_data);
                                    if let Ok(sink) = handle.play_once(cursor) {
                                        sink.sleep_until_end();
                                    }
                                });
                                // 🦆 says ⮞ BOOOOM 
                                println!("💥 DETECTED!");

                                thread::sleep(Duration::from_millis(100));

                                {
                                    let mut guard = receiver_recording_buffer.lock().unwrap();
                                    guard.clear();
                                } // 🦆 says ⮞ start recording
                                receiver_recording_active.store(true, Ordering::SeqCst);

                                 // 🦆 says ⮞ dynanic cooldown
                                let start_time = Instant::now();
                                let mut last_speech_time = Instant::now();
                                let receiver_debug = receiver_debug;
                                let receiver_silence_threshold = receiver_silence_threshold;
                                let receiver_silence_timeout = receiver_silence_timeout;
                                let receiver_max_duration = receiver_max_duration;

                                let window_seconds = 0.5;
                                let window_samples = (window_seconds * receiver_original_sample_rate as f64 * receiver_channels as f64) as usize;

                                while start_time.elapsed() < receiver_max_duration {
                                    thread::sleep(Duration::from_millis(50));
                                    if receiver_shutdown.load(Ordering::SeqCst) {
                                        break;
                                    }

                                    // 🦆 says ⮞ calculate RMS over the most recent window of samples
                                    let rms = {
                                        // 🦆 says ⮞ lock the shared recording buffer
                                        let guard = receiver_recording_buffer.lock().unwrap();
                                        // 🦆 says ⮞ total number of samples in current buffer
                                        let len = guard.len();
                                        if len == 0 {
                                            continue;
                                        }
                                        
                                        // 🦆 says ⮞ determine the starting index of the window
                                        let start_idx = if len > window_samples { len - window_samples } else { 0 };
                                        let window = &guard[start_idx..];
                                        if window.is_empty() {
                                            continue;
                                        }
                                        rms_f32(window)
                                    };

                                    // 🦆 says ⮞ --debug? print RMS
                                    if receiver_debug { println!("RMS: {:.6}", rms); }
                                    
                                    // 🦆 says ⮞ RMS exceeds configured silence threshold,
                                    // treat this as speech activity and reset the silence timer
                                    if rms > receiver_silence_threshold { last_speech_time = Instant::now(); }
                                    
                                    // 🦆 says ⮞ reached silence timeout - exit loop
                                    if last_speech_time.elapsed() > receiver_silence_timeout { break; }
                                }

                                receiver_recording_active.store(false, Ordering::SeqCst);

                                let raw_audio = {
                                    let mut guard = receiver_recording_buffer.lock().unwrap();
                                    std::mem::take(&mut *guard)
                                };

                                let resampled_audio = resample_to_16k_mono(
                                    &raw_audio,
                                    receiver_original_sample_rate,
                                    receiver_channels,
                                );

                                {
                                    let mut guard = receiver_write_stream.lock().unwrap();
                                    if let Err(e) = guard.write_u8(0x02) {
                                        eprintln!("Failed to send transcription type: {}", e);
                                    }
                                    if let Err(e) = guard.write_u32::<LittleEndian>(resampled_audio.len() as u32) { 
                                        eprintln!("Failed to send transcription length: {}", e);
                                    }
                                    let mut bytes = Vec::with_capacity(resampled_audio.len() * 4);
                                    for &s in &resampled_audio {
                                        bytes.extend_from_slice(&s.to_le_bytes());
                                    }
                                    if let Err(e) = guard.write_all(&bytes) { eprintln!("Failed to send transcription samples: {}", e); }
                                    if let Err(e) = guard.flush() { eprintln!("Failed to flush: {}", e); }
                                }

                                receiver_is_transcribing.store(false, Ordering::SeqCst);
                            }
                        }
                        Err(e) if e.kind() == std::io::ErrorKind::WouldBlock || e.kind() == std::io::ErrorKind::TimedOut => {
                            if receiver_shutdown.load(Ordering::SeqCst) {
                                break;
                            }
                            continue;
                        }
                        Err(e) => {
                            eprintln!("Read error: {}", e);
                            break;
                        }
                    }
                }
            });
            let _ = receiver_exit_tx.send(());
        });

        let _ = exit_rx.recv();

        shutdown.store(true, Ordering::SeqCst);

        *chunk_tx_global.lock().unwrap() = None;

        let _ = sender_handle.join();
        let _ = receiver_handle.join();

        println!("⚠️ Reconnecting...");
        // 🦆 says ⮞ LOOOP IT YO!
    }
}

fn resample_to_16k_mono(raw: &[f32], input_rate: u32, channels: usize) -> Vec<f32> {
    let mono = if channels > 1 {
        raw.chunks(channels)
            .map(|frame| frame.iter().sum::<f32>() / channels as f32)
            .collect::<Vec<f32>>()
    } else {
        raw.to_vec()
    };

    let mut resampler = match make_resampler(input_rate, 16000, 1) {
        Ok(r) => r,
        Err(e) => {
            eprintln!("Failed to create resampler: {}", e);
            return Vec::new();
        }
    };

    let resample_buffer = Arc::new(Mutex::new(Vec::new()));
    let mut output = Vec::new();

    let chunks = resample_into_chunks(&mono, &resample_buffer, 1, &mut resampler);
    for chunk in chunks {
        output.extend_from_slice(&chunk.data_f32[0]);
    }
    output
}
