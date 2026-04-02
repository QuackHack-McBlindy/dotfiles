use std::{
    env,
    io::{Read, Write, Cursor},
    net::{TcpListener, TcpStream},
    process::Command,
    thread,
    time::{Duration, Instant},
    sync::Arc,
};
use ducktrace_logger::*;
use anyhow::Result;
use byteorder::{LittleEndian, ReadBytesExt, WriteBytesExt};
use oww_rs::{
    mic::{
        converters::i16_to_f32,
        mic_config::find_best_config,
        process_audio::resample_into_chunks,
        resampler::make_resampler,
    },
    oww::{OwwModel, OWW_MODEL_CHUNK_SIZE},
};
use rodio::OutputStream;
use whisper_rs::{WhisperContext, FullParams, SamplingStrategy};


// 🦆 says ⮞ RMS helper
fn rms_f32(samples: &[f32]) -> f32 {
    if samples.is_empty() {
        return 0.0;
    }
    let sum_squares: f32 = samples.iter().map(|&x| x * x).sum();
    (sum_squares / samples.len() as f32).sqrt()
}

fn save_audio_to_file(audio: &[f32], client_id: &str) -> std::io::Result<()> {
    use std::fs::{File, create_dir_all};
    use std::io::Write;
    use std::path::Path;

    let dir = Path::new("recordings");
    if !dir.exists() {
        create_dir_all(dir)?;
    }

    let safe_client_id = client_id
        .chars()
        .map(|c| if c.is_alphanumeric() { c } else { '_' })
        .collect::<String>();

    let timestamp = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .unwrap()
        .as_secs();

    let filename = format!("recordings/esp_{}_{}.raw", safe_client_id, timestamp);
    let mut file = File::create(filename)?;
    for &sample in audio {
        file.write_all(&sample.to_le_bytes())?;
    }
    Ok(())
}


const LISTEN_ADDR: &str = "0.0.0.0:12345";
const DING_WAV: &[u8] = include_bytes!("./../ding.wav");
const DONE_WAV: &[u8] = include_bytes!("./../done.wav");

const DEFAULT_WAKE_MODEL: &[u8] = include_bytes!("./../models/wake-words/yo_bitch.onnx");

// ESP32 client specific
const ESP_SILENCE_THRESHOLD: f32 = 0.005;
const ESP_SILENCE_TIMEOUT_SECS: f64 = 1.2;
const ESP_MAX_DURATION_SECS: f64 = 5.0;

fn reset_wake_model(model: &mut OwwModel, chunks_to_flush: usize) {
    let zero_chunk = vec![0.0; OWW_MODEL_CHUNK_SIZE];
    for _ in 0..chunks_to_flush {
        let _ = model.detection(zero_chunk.clone());
    }
}

fn handle_client(
    mut stream: TcpStream,
    mut wake_model: OwwModel,
    whisper_ctx: Arc<WhisperContext>,
    client_id: String,
    debug: bool,
    cooldown_secs: u64,
    beam_size: i32,
    temperature: f32,
    language: Option<String>,
    threads: i32,
    sound_data: Vec<u8>,
    done_sound_data: Vec<u8>,
    exec_command: Option<String>,
    translate_to_shell: bool,
    room: String,
) -> Result<()> {  
    let mut last_detection: Option<Instant> = None;

    loop {
        // 🦆 says ⮞ Wake‑word detection
        let len = match stream.read_u32::<LittleEndian>() {
            Ok(l) => l as usize,
            Err(e) => {
                dt_error!("[{}] Failed to read length: {} – client disconnected", client_id, e);
                break;
            }
        };

        let mut sample_bytes = vec![0u8; len * 4];
        if let Err(e) = stream.read_exact(&mut sample_bytes) {
            dt_error!("[{}] Failed to read samples: {}", client_id, e);
            break;
        }

        let samples: Vec<f32> = sample_bytes
            .chunks_exact(4)
            .map(|b| f32::from_le_bytes([b[0], b[1], b[2], b[3]]))
            .collect();

        if samples.len() != OWW_MODEL_CHUNK_SIZE {
            dt_warning!(
                "[{}] Warning: received chunk of size {}, expected {}",
                client_id,
                samples.len(),
                OWW_MODEL_CHUNK_SIZE
            );
        }

        let detection = wake_model.detection(samples);
        if detection.detected {
            // 🦆 says ⮞ Debounce
            if let Some(last) = last_detection {
                if last.elapsed() < Duration::from_secs(1) {
                    thread::sleep(Duration::from_millis(100));
                    continue;
                }
            }
            dt_debug!("💥 DETECTED!");
            let mut timer = dt_timer("voice pipeline");
            dt_info!("💥 DETECTED! {} Probability: {:.4}", client_id, detection.probability);

            // 🦆 says ⮞ Play sound
            let sound_data_for_thread = sound_data.clone();
            let client_id_clone = client_id.clone();
            let debug_clone = debug;
            thread::spawn(move || {
                let (_stream, handle) = OutputStream::try_default().unwrap();
                let cursor = Cursor::new(sound_data_for_thread);
                if let Ok(sink) = handle.play_once(cursor) {
                    sink.sleep_until_end();
                }
                if debug_clone { dt_debug!("[{}] Finished playing awake sound", client_id_clone); }
            });

            // 🦆 says ⮞ Send notification to client
            if let Err(e) = stream.write_u8(0x01) {
                dt_error!("[{}] Failed to send detection notification: {}", client_id, e);
            }
            if let Err(e) = stream.flush() { dt_error!("[{}] Failed to flush: {}", client_id, e); }

            // 🦆 says ⮞ wait for transcription, discarding stray chunks
            let transcription_audio = loop {
                let mut msg_type = [0u8; 1];
                if let Err(e) = stream.read_exact(&mut msg_type) {
                    dt_error!("[{}] Failed to read message type after detection: {}", client_id, e);
                    return Ok(());
                }
                match msg_type[0] {
                    0x02 => {
                        let num_samples = match stream.read_u32::<LittleEndian>() {
                            Ok(n) => n as usize,
                            Err(e) => {
                                dt_error!("[{}] Failed to read transcription length: {}", client_id, e);
                                return Ok(());
                            }
                        };
                        let mut audio_bytes = vec![0u8; num_samples * 4];
                        if let Err(e) = stream.read_exact(&mut audio_bytes) {
                            dt_error!("[{}] Failed to read transcription samples: {}", client_id, e);
                            return Ok(());
                        }
                        let audio_f32: Vec<f32> = audio_bytes
                            .chunks_exact(4)
                            .map(|b| f32::from_le_bytes([b[0], b[1], b[2], b[3]]))
                            .collect();
                        break audio_f32;
                    }
                    _ => {
                        let len = match stream.read_u32::<LittleEndian>() {
                            Ok(l) => l as usize,
                            Err(e) => {
                                dt_error!("[{}] Failed to read discarded chunk length: {}", client_id, e);
                                return Ok(());
                            }
                        };
                        let mut discard = vec![0u8; len * 4];
                        if let Err(e) = stream.read_exact(&mut discard) {
                            dt_error!("[{}] Failed to read discarded chunk samples: {}", client_id, e);
                            return Ok(());
                        }
                        dt_error!("[{}] Discarded a pending wake chunk ({} samples)", client_id, len);
                        continue;
                    }
                }
            };

            
            let perf_start = if debug { Some(Instant::now()) } else { None };

            // 🦆 says ⮞ Transcribe
            let sampling_strategy = if beam_size > 0 {
                SamplingStrategy::BeamSearch { beam_size, patience: 1.0 }
            // 🦆 says ⮞ beam_size == 0 -> greedy decoding with best_of = 1
            } else { SamplingStrategy::Greedy { best_of: 1 } };
            
            let mut whisper_params = FullParams::new(sampling_strategy);
 
            whisper_params.set_n_threads(threads);
            whisper_params.set_translate(false);
            whisper_params.set_language(language.as_deref());
            whisper_params.set_print_special(false);
            whisper_params.set_print_progress(false);
            whisper_params.set_print_realtime(false);
            whisper_params.set_print_timestamps(false);
            whisper_params.set_temperature(temperature);
            whisper_params.set_suppress_blank(true);
            whisper_params.set_suppress_non_speech_tokens(true);
            // whisper_params.set_token_timestamps(true);

            let mut state = whisper_ctx.create_state().expect("failed to create state");
            if let Err(e) = state.full(whisper_params, &transcription_audio) {
                dt_error!("[{}] Whisper transcription failed: {}", client_id, e);
            } else {
                let num_segments = state.full_n_segments()? as usize;
                let mut transcription = String::new();
                for i in 0..num_segments {
                    let segment = state.full_get_segment_text(i as i32)?;
                    transcription.push_str(&segment);
                }
                dt_info!("[{}] Transcription: {}", client_id, transcription);                

                // 🦆 says ⮞ if --debug
                if debug { // 🦆 says ⮞ print transcription timer
                    if let Some(start) = perf_start {
                        let elapsed = start.elapsed();
                        dt_debug!("[{}] Transcription took {:.3}s", client_id, elapsed.as_secs_f64());
                    }
                }

                let normalized = normalize_transcription(&transcription);
                if debug { dt_debug!("[{}] Normalized: {}", client_id, normalized); }

                // 🦆 says ⮞ translate transcribed text to shell command and execute
                let mut command_succeeded = false;
                
                if translate_to_shell {
                    if normalized.is_empty() {
                        if debug { dt_error!("[{}] Normalized text is empty, nothing to translate.", client_id); }
                    } else {
                        let mut cmd = Command::new("yo");
                        cmd.arg("do");
                        if !room.is_empty() { cmd.arg("--room").arg(&room); }
                        cmd.arg(&normalized).env("VOICE_MODE", "1");
                        let status = cmd.status();
                
                        match status {
                            Ok(status) => {
                                if status.success() {
                                    timer.complete();
                                    dt_info!("🎉 {} Shell translation successful!", client_id);
                                    command_succeeded = true;
                                } else {
                                    dt_error!("[{}] Shell translator failed with exit code: {:?}", client_id, status.code());
                                }
                            }
                            Err(e) => dt_error!("[{}] Failed to execute yo do: {}", client_id, e),
                        }
                    }
                }
                
                if let Some(ref cmd_str) = exec_command {
                    if !translate_to_shell {
                        if normalized.is_empty() {
                            if debug { dt_error!("[{}] Normalized text is empty, nothing to execute", client_id); }
                        } else {
                            let mut parts = cmd_str.split_whitespace();
                            if let Some(program) = parts.next() {
                                let mut command = Command::new(program);
                                for arg in parts { command.arg(arg); }
                                command.arg(&normalized);
                                command.env("VOICE_MODE", "1");
                
                                match command.status() {
                                    Ok(status) => {
                                        if status.success() {
                                            dt_info!("🎉 {} Executed successfully!", client_id);
                                            command_succeeded = true;
                                        } else {
                                            dt_error!("🚫 {} Command failed with exit code: {:?}", client_id, status.code());
                                        }
                                    }
                                    Err(e) => dt_error!("🚫 {} Failed to execute command: {}", client_id, e),
                                }
                            }
                        }
                    }
                }
                
                // 🦆 says ⮞ Play done sound locally on success
                if command_succeeded { play_done_sound(done_sound_data.clone(), client_id.clone(), debug); }                
                // send to client
                // 0x03 = WIN 🎉 0x04 = FAIL! 💩
                let notification_byte = if command_succeeded { 0x03 } else { 0x04 };
                if let Err(e) = stream.write_u8(notification_byte) {
                    dt_error!("[{}] Failed to send notification to client: {}", client_id, e);
                }
                if let Err(e) = stream.flush() {
                    dt_error!("[{}] Failed to flush after notification: {}", client_id, e);
                }
                

                // 🦆 says ⮞ if no exec command, do nothing                 
            }
            last_detection = Some(Instant::now());
        } else if debug && detection.probability > 0.0 {
            dt_debug!("[{}] Probability: {:.4}", client_id, detection.probability);
        }
    }

    dt_info!("🚫 ❌ {} Disconnected!", client_id);
    Ok(())
}

// ESP32 clients are simplified – VAD handled on server
fn handle_client_esp(
    mut stream: TcpStream,
    mut wake_model: OwwModel,
    whisper_ctx: Arc<WhisperContext>,
    client_id: String,
    debug: bool,
    _cooldown_secs: u64,
    beam_size: i32,
    temperature: f32,
    language: Option<String>,
    threads: i32,
    sound_data: Vec<u8>,
    done_sound_data: Vec<u8>,
    exec_command: Option<String>,
    translate_to_shell: bool,
    room: String,
) -> Result<()> {
    enum State {
        Normal,
        Recording {
            buffer: Vec<f32>,
            start: Instant,
            last_speech: Instant,
            duration: Duration,
            timeout: Duration,
            threshold: f32,
        },
        Cooldown {
            until: Instant,
        },
    }

    const SAMPLE_RATE: u32 = 16000;
    const WINDOW_SECONDS: f64 = 0.5;

    let mut state = State::Normal;
    let mut last_detection: Option<Instant> = None;

    loop {
        let len = match stream.read_u32::<LittleEndian>() {
            Ok(l) => l as usize,
            Err(e) => {
                dt_error!("[{}] Failed to read length: {} – client disconnected", client_id, e);
                break;
            }
        };

        let mut sample_bytes = vec![0u8; len * 4];
        if let Err(e) = stream.read_exact(&mut sample_bytes) {
            dt_error!("[{}] Failed to read samples: {}", client_id, e);
            break;
        }

        let samples: Vec<f32> = sample_bytes
            .chunks_exact(4)
            .map(|b| f32::from_le_bytes([b[0], b[1], b[2], b[3]]))
            .collect();

        match state {
            State::Normal => {
                if samples.len() != OWW_MODEL_CHUNK_SIZE {
                    dt_warning!(
                        "[{}] Warning: received chunk of size {}, expected {}",
                        client_id,
                        samples.len(),
                        OWW_MODEL_CHUNK_SIZE
                    );
                }

                let detection = wake_model.detection(samples.clone());
                if detection.detected {
                    // debounce
                    if let Some(last) = last_detection {
                        if last.elapsed() < Duration::from_secs_f64(COOLDOWN_SECS) {
                            continue;
                        }
                    }
                    dt_info!("💥 DETECTED! {} Probability: {:.4}", client_id, detection.probability);
                    last_detection = Some(Instant::now());

                    // play awake sound
                    let sound_data = sound_data.clone();
                    let client_id_clone = client_id.clone();
                    let debug_clone = debug;
                    thread::spawn(move || {
                        let (_stream, handle) = OutputStream::try_default().unwrap();
                        let cursor = Cursor::new(sound_data);
                        if let Ok(sink) = handle.play_once(cursor) {
                            sink.sleep_until_end();
                        }
                        if debug_clone {
                            dt_debug!("[{}] Finished playing awake sound", client_id_clone);
                        }
                    });

                    // send 0x01 to client
                    if let Err(e) = stream.write_u8(0x01) {
                        dt_error!("[{}] Failed to send detection notification: {}", client_id, e);
                    }
                    if let Err(e) = stream.flush() {
                        dt_error!("[{}] Failed to flush: {}", client_id, e);
                    }

                    // start recording
                    let mut buffer = Vec::with_capacity((ESP_MAX_DURATION_SECS * SAMPLE_RATE as f64) as usize);
                    buffer.extend(samples);
                    let start = Instant::now();
                    let last_speech = Instant::now();
                    let duration = Duration::from_secs_f64(ESP_MAX_DURATION_SECS);
                    let timeout = Duration::from_secs_f64(ESP_SILENCE_TIMEOUT_SECS);
                    let threshold = ESP_SILENCE_THRESHOLD;
                    state = State::Recording { buffer, start, last_speech, duration, timeout, threshold };
                }
            }
            State::Recording {
                mut buffer,
                start,
                mut last_speech,
                duration,
                timeout,
                threshold,
            } => {
                buffer.extend(samples);

                // stop recording?
                let stop = if start.elapsed() >= duration {
                    true
                } else {
                    // calculate RMS over the most recent window
                    let window_samples = (WINDOW_SECONDS * SAMPLE_RATE as f64) as usize;
                    if buffer.len() >= window_samples {
                        let window_start = buffer.len() - window_samples;
                        let window = &buffer[window_start..];
                        let rms = rms_f32(window);
                        if debug {
                            dt_debug!("[{}] RMS: {:.6}", client_id, rms);
                        }
                        if rms > threshold {
                            last_speech = Instant::now();
                        }
                        last_speech.elapsed() > timeout
                    } else {
                        false   // not enough data yet to make a decision
                    }
                };

                if stop {
                    let duration_secs = buffer.len() as f64 / SAMPLE_RATE as f64;
                    dt_info!("[{}] Recording finished ({} samples, {:.2}s)", client_id, buffer.len(), duration_secs);

                    if let Err(e) = save_audio_to_file(&buffer, &client_id) {
                        dt_error!("[{}] Failed to save audio: {}", client_id, e);
                    }

                    // TRANSCRIBE
                    let transcription_audio = buffer;
                    let perf_start = if debug { Some(Instant::now()) } else { None };

                    let sampling_strategy = if beam_size > 0 {
                        SamplingStrategy::BeamSearch { beam_size, patience: 1.0 }
                    } else {
                        SamplingStrategy::Greedy { best_of: 1 }
                    };
                    let mut whisper_params = FullParams::new(sampling_strategy);
                    whisper_params.set_n_threads(threads);
                    whisper_params.set_translate(false);
                    whisper_params.set_language(language.as_deref());
                    whisper_params.set_print_special(false);
                    whisper_params.set_print_progress(false);
                    whisper_params.set_print_realtime(false);
                    whisper_params.set_print_timestamps(false);
                    whisper_params.set_temperature(temperature);
                    whisper_params.set_suppress_blank(true);
                    whisper_params.set_suppress_non_speech_tokens(true);

                    let mut whisper_state = whisper_ctx.create_state().expect("failed to create state");
                    let mut command_succeeded = false;
                    if let Err(e) = whisper_state.full(whisper_params, &transcription_audio) {
                        dt_error!("[{}] Whisper transcription failed: {}", client_id, e);
                    } else {
                        let num_segments = whisper_state.full_n_segments()? as usize;
                        let mut transcription = String::new();
                        for i in 0..num_segments {
                            let segment = whisper_state.full_get_segment_text(i as i32)?;
                            transcription.push_str(&segment);
                        }
                        dt_info!("[{}] Transcription: {}", client_id, transcription);

                        if debug {
                            if let Some(start) = perf_start {
                                let elapsed = start.elapsed();
                                dt_debug!("[{}] Transcription took {:.3}s", client_id, elapsed.as_secs_f64());
                            }
                        }

                        let normalized = normalize_transcription(&transcription);
                        if debug {
                            dt_debug!("[{}] Normalized: {}", client_id, normalized);
                        }

                        if translate_to_shell {
                            if normalized.is_empty() {
                                if debug {
                                    dt_error!("[{}] Normalized text is empty, nothing to translate.", client_id);
                                }
                            } else {
                                let mut cmd = Command::new("yo");
                                cmd.arg("do");
                                if !room.is_empty() {
                                    cmd.arg("--room").arg(&room);
                                }
                                cmd.arg("--input").cmd.arg(&normalized).env("VOICE_MODE", "1");
                                let status = cmd.status();
                                match status {
                                    Ok(status) => {
                                        if status.success() {
                                            dt_info!("🎉 {} Shell translation successful!", client_id);
                                            command_succeeded = true;
                                        } else {
                                            dt_error!(
                                                "[{}] Shell translator failed with exit code: {:?}",
                                                client_id,
                                                status.code()
                                            );
                                        }
                                    }
                                    Err(e) => dt_error!("[{}] Failed to execute yo do: {}", client_id, e),
                                }
                            }
                        }

                        if let Some(ref cmd_str) = exec_command {
                            if !translate_to_shell {
                                if normalized.is_empty() {
                                    if debug {
                                        dt_error!("[{}] Normalized text is empty, nothing to execute", client_id);
                                    }
                                } else {
                                    let mut parts = cmd_str.split_whitespace();
                                    if let Some(program) = parts.next() {
                                        let mut command = Command::new(program);
                                        for arg in parts {
                                            command.arg(arg);
                                        }
                                        command.arg(&normalized);
                                        command.env("VOICE_MODE", "1");
                                        match command.status() {
                                            Ok(status) => {
                                                if status.success() {
                                                    dt_info!("🎉 {} Executed successfully!", client_id);
                                                    command_succeeded = true;
                                                } else {
                                                    dt_error!(
                                                        "🚫 {} Command failed with exit code: {:?}",
                                                        client_id,
                                                        status.code()
                                                    );
                                                }
                                            }
                                            Err(e) => dt_error!("🚫 {} Failed to execute command: {}", client_id, e),
                                        }
                                    }
                                }
                            }
                        }

                        // play done sound
                        if command_succeeded {
                            play_done_sound(done_sound_data.clone(), client_id.clone(), debug);
                        }
                    }

                    // notify client (0x03 = success, 0x04 = failure)
                    let notification_byte = if command_succeeded { 0x03 } else { 0x04 };
                    if let Err(e) = stream.write_u8(notification_byte) {
                        dt_error!("[{}] Failed to send notification to client: {}", client_id, e);
                    }
                    if let Err(e) = stream.flush() {
                        dt_error!("[{}] Failed to flush after notification: {}", client_id, e);
                    }

                    reset_wake_model(&mut wake_model, 10);
                    // after processing, go to cooldown
                    let cooldown_until = Instant::now() + Duration::from_secs_f64(COOLDOWN_SECS);
                    state = State::Cooldown { until: cooldown_until };
                } else {
                    // continue recording
                    state = State::Recording {
                        buffer,
                        start,
                        last_speech,
                        duration,
                        timeout,
                        threshold,
                    };
                }
            }
            State::Cooldown { until } => {
                // ignore chunks til cooldown expires
                if Instant::now() >= until {
                    state = State::Normal;
                }
                // else discard chunk
            }
        }
    }

    dt_info!("🚫 ❌ {} Disconnected!", client_id);
    Ok(())
}


fn normalize_transcription(text: &str) -> String {
    text.trim()
        .to_lowercase()
        .chars()
        .filter(|c| c.is_alphanumeric() || c.is_whitespace() || *c == '.' || *c == '-' || *c == '_')
        .collect::<String>()
        .split_whitespace()
        .collect::<Vec<&str>>()
        .join(" ")
}

fn play_done_sound(done_sound_data: Vec<u8>, client_id: String, debug: bool) {
    thread::spawn(move || {
        let (_stream, handle) = OutputStream::try_default().unwrap();
        let cursor = Cursor::new(done_sound_data);
        if let Ok(sink) = handle.play_once(cursor) {
            sink.sleep_until_end();
        }
        if debug {
            dt_debug!("[{}] Finished playing done sound", client_id);
        }
    });
}

fn print_usage(program_name: &str) {
    dt_error!(
        "Usage: {} [OPTIONS]\n\
         Options:\n\
         --host <ADDRESS>         Listening address (default: 0.0.0.0:12345)\n\
         --awake-sound <PATH>     Path to WAV file to play on wake (default: ding)\n\
         --wake-word <PATH>       Path to wake word model (default: yo_bitch.onnx)\n\
         --done-sound <PATH>      Path to WAV file to play after successful command execution (default: done)\n\
         --threshold <FLOAT>      Detection threshold (default: 0.5)\n\
         --model <PATH>           Path to Whisper model (default: ./ggml-tiny.bin)\n\
         --cooldown <SECONDS>     Cooldown between detections (default: auto)\n\
         --beam-size <INT>        Beam size for Whisper (0 = greedy, >0 = beam search, default: 5)\n\
         --temperature <FLOAT>    Whisper temperature (default: 0.2)\n\
         --language <LANG>        Language code (e.g., sv, en) or 'auto' (default: en)\n\
         --threads <INT>          Number of threads for Whisper (default: 4)\n\
         --exec-command <CMD>     Command to execute with transcribed text as argument (default: none)\n\
         --tts-model <PATH>       Path to TTS ONNX model (default: ./models/tts/en_US-amy-medium.onnx)\n\
         --debug                  Enable debug logging\n\
         --help, -h               Show this help message",
        program_name
    );
}

fn main() -> Result<()> {
    env_logger::init();

    let args: Vec<String> = env::args().collect();

    // 🦆 says ⮞ --help ? 
    if args.len() > 1 && (args[1] == "--help" || args[1] == "-h") {
        print_usage(&args[0]);
        return Ok(());
    }


    // 🦆 says ⮞ Defaults
    let mut host = LISTEN_ADDR.to_string();
    let mut sound_path: Option<String> = None;
    let mut done_sound_path: Option<String> = None;
    let mut wake_word_path = String::new();
    let mut custom_wake_word_provided = false;  
    let mut threshold = 0.5;
    let mut whisper_model_path = "./models/stt/ggml-tiny.bin".to_string();
    let mut cooldown_secs = 10;
    let mut debug = false;
    let mut beam_size = 5;
    let mut temperature = 0.2;
    let mut language = Some("sv".to_string());
    let mut threads = 4;
    let mut exec_command: Option<String> = None;
    let mut translate_to_shell = false;
    let mut tts_model_path = "./../models/tts/en_US-amy-medium.onnx".to_string();

    // 🦆 says ⮞ parse arguments
    let mut i = 1;
    while i < args.len() {
        match args[i].as_str() {
            "--host" => {
                if i + 1 < args.len() {
                    host = args[i + 1].clone();
                    i += 2;
                } else {
                    dt_error!("Missing value for --host");
                    std::process::exit(1);
                }
            }
            "--translate-to-shell" => {
                translate_to_shell = true;
                i += 1;
            }
            "--awake-sound" => {
                if i + 1 < args.len() {
                    sound_path = Some(args[i + 1].clone());
                    i += 2;
                } else {
                    dt_error!("Missing value for --awake-sound");
                    std::process::exit(1);
                }
            }
            "--done-sound" => {
                if i + 1 < args.len() {
                    done_sound_path = Some(args[i + 1].clone());
                    i += 2;
                } else {
                    dt_error!("Missing value for --done-sound");
                    std::process::exit(1);
                }
            }
            "--beam-size" => {
                if i + 1 < args.len() {
                    let val = args[i + 1].parse().unwrap_or_else(|_| {
                        dt_error!("Invalid beam size value – must be an integer >= 0");
                        std::process::exit(1);
                    });
                    if val < 0 {
                        dt_error!("Beam size must be >= 0");
                        std::process::exit(1);
                    }
                    beam_size = val;
                    i += 2;
                } else {
                    dt_error!("Missing value for --beam-size");
                    std::process::exit(1);
                }
            }
            "--wake-word" => {
                if i + 1 < args.len() {
                    wake_word_path = args[i + 1].clone();
                    custom_wake_word_provided = true;
                    i += 2;
                } else {
                    dt_error!("Missing value for --wake-word");
                    std::process::exit(1);
                }
            }
            "--threshold" => {
                if i + 1 < args.len() {
                    threshold = args[i + 1].parse().unwrap_or_else(|_| {
                        dt_error!("Invalid threshold value");
                        std::process::exit(1);
                    });
                    i += 2;
                } else {
                    dt_error!("Missing value for --threshold");
                    std::process::exit(1);
                }
            }
            "--model" => {
                if i + 1 < args.len() {
                    whisper_model_path = args[i + 1].clone();
                    i += 2;
                } else {
                    dt_error!("Missing value for --model");
                    std::process::exit(1);
                }
            }
            "--cooldown" => {
                if i + 1 < args.len() {
                    cooldown_secs = args[i + 1].parse().unwrap_or_else(|_| {
                        dt_error!("Invalid cooldown value");
                        std::process::exit(1);
                    });
                    i += 2;
                } else {
                    dt_error!("Missing value for --cooldown");
                    std::process::exit(1);
                }
            }       
            "--temperature" => {
                if i + 1 < args.len() {
                    temperature = args[i + 1].parse().unwrap_or_else(|_| {
                        dt_error!("Invalid temperature value – must be a float");
                        std::process::exit(1);
                    });
                    i += 2;
                } else {
                    dt_error!("Missing value for --temperature");
                    std::process::exit(1);
                }
            }
            "--language" => {
                if i + 1 < args.len() {
                    let lang = args[i + 1].clone();
                    language = if lang == "auto" { None } else { Some(lang) };
                    i += 2;
                } else {
                    dt_error!("Missing value for --language");
                    std::process::exit(1);
                }
            }
            "--threads" => {
                if i + 1 < args.len() {
                    threads = args[i + 1].parse().unwrap_or_else(|_| {
                        dt_error!("Invalid threads value – must be an integer");
                        std::process::exit(1);
                    });
                    i += 2;
                } else {
                    dt_error!("Missing value for --threads");
                    std::process::exit(1);
                }
            }
            "--exec-command" => {
                if i + 1 < args.len() {
                    exec_command = Some(args[i + 1].clone());
                    i += 2;
                } else {
                    dt_error!("Missing value for --exec-command");
                    std::process::exit(1);
                }
            }
            "--tts-model" => {
                if i + 1 < args.len() {
                    tts_model_path = args[i + 1].clone();
                    i += 2;
                } else {
                    dt_error!("Missing value for --tts-model");
                    std::process::exit(1);
                }
            }
            "--debug" => {
                debug = true;
                i += 1;
            }
            _ => {
                dt_error!("Unknown argument: {}", args[i]);
                std::process::exit(1);
            }
        }
    }

    if debug { std::env::set_var("DT_LOG_LEVEL", "DEBUG"); }
    dt_setup(None, None);

    // sound loading
    let done_sound_data = if let Some(ref path) = done_sound_path {
        match std::fs::read(path) {
            Ok(data) => {
                dt_info!("Loaded custom done sound from {}", path);
                data
            }
            Err(e) => {
                dt_error!("Failed to read done sound file '{}': {}. Using embedded sound.", path, e);
                DONE_WAV.to_vec()
            }
        }
    } else {
        DONE_WAV.to_vec()
    };    
    // awake sound
    let sound_data = if let Some(ref path) = sound_path {
        match std::fs::read(&path) {
            Ok(data) => {
                dt_info!("Loaded custom awake sound from {}", path);
                data
            }
            Err(e) => {
                dt_error!("Failed to read awake sound file '{}': {}. Using embedded sound.", path, e);
                DING_WAV.to_vec()
            }
        }
    } else { DING_WAV.to_vec() };

    let listener = TcpListener::bind(&host)?;
    
    // 🦆 says ⮞ Print current settings
    let done_sound_display = done_sound_path.as_deref().unwrap_or("done.wav (embedded)");
    let awake_sound_display = sound_path.as_deref().unwrap_or("ding.wav (embedded)");
    let exec_display = exec_command.as_deref().unwrap_or("none");
    let wake_word_display = if custom_wake_word_provided {
        wake_word_path.as_str()
    } else { "yo_bitch" };

    dt_info!(
        r#"Settings:
      Host:           {}
      Debug:          {}
      Wake word:      {}
      Threshold:      {}
      Whisper model:  {}
      TTS model:      {} 
      Temperature:    {}
      Language:       {}
      Threads:        {}
      Awake sound:    {}
      Done sound:     {}   
      Exec command:   {}
      Translate to shell: {}"#,
        host,
        debug,
        wake_word_display,
        threshold,
        whisper_model_path,
        tts_model_path,
        temperature,
        language.as_deref().unwrap_or("auto"),
        threads,
        awake_sound_display,
        done_sound_display,
        exec_display,
        translate_to_shell,
    );

    let whisper_ctx = Arc::new(WhisperContext::new(&whisper_model_path)?);
    
    for stream in listener.incoming() {
        match stream {
            Ok(mut stream) => {
                let peer_addr = match stream.peer_addr() {
                    Ok(addr) => addr.to_string(),
                    Err(_) => "unknown".to_string(),
                };
    
                // 🦆 says ⮞ get room by client
                let room_len = match stream.read_u32::<LittleEndian>() {
                    Ok(len) => len as usize,
                    Err(e) => {
                        dt_error!("[{}] Failed to read room length: {} – assuming empty", peer_addr, e);
                        0
                    }
                };
                let room = if room_len > 0 {
                    let mut room_buf = vec![0u8; room_len];
                    if let Err(e) = stream.read_exact(&mut room_buf) {
                        dt_error!("[{}] Failed to read room: {} – using empty", peer_addr, e);
                        String::new()
                    } else {
                        String::from_utf8_lossy(&room_buf).to_string()
                    }
                } else {
                    String::new()
                };
    
                // 🦆 says ⮞ create client id
                let client_id = if room.is_empty() {
                    format!("client @ {}", peer_addr)
                } else { format!("room '{}'", room) };
                dt_info!("📡 ☑️ 🎙️ {} Connected (IP: {})", client_id, peer_addr);
    
                // 🦆 says ⮞ clone data for the thread
                let sound_data = sound_data.clone();
                let done_sound_data = done_sound_data.clone();
                let exec_command = exec_command.clone();
    
                let wake_model = if custom_wake_word_provided {
                    match OwwModel::from_path(&wake_word_path, threshold) {
                        Ok(m) => m,
                        Err(e) => {
                            dt_error!("[{}] Failed to load wake model from {}: {}", client_id, wake_word_path, e);
                            continue;
                        }
                    }
                } else {
                    match OwwModel::from_bytes(DEFAULT_WAKE_MODEL, threshold) {
                        Ok(m) => m,
                        Err(e) => {
                            dt_error!("[{}] Failed to load embedded wake model: {}", client_id, e);
                            continue;
                        }
                    }
                };
    
                let whisper_ctx = Arc::clone(&whisper_ctx);
                let language = language.clone();
                thread::spawn(move || {
                    let result = if room == "esp" {
                        handle_client_esp(
                            stream,
                            wake_model,
                            whisper_ctx,
                            client_id,
                            debug,
                            cooldown_secs,
                            beam_size,
                            temperature,
                            language,
                            threads,
                            sound_data,
                            done_sound_data,
                            exec_command,
                            translate_to_shell,
                            room,
                        )
                    } else {
                        handle_client(
                            stream,
                            wake_model,
                            whisper_ctx,
                            client_id,
                            debug,
                            cooldown_secs,
                            beam_size,
                            temperature,
                            language,
                            threads,
                            sound_data,
                            done_sound_data,
                            exec_command,
                            translate_to_shell,
                            room,
                        )
                    };
                    if let Err(e) = result {
                        dt_error!("Error in client handler: {}", e);
                    }
                });
            }
            Err(e) => dt_error!("❌ 🚫 Connection failed: {}", e),
        }
    }    
    Ok(())
}
