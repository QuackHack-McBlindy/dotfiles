use crate::VOICE_SAMPLE_RATE;
use chrono::Utc;
use log::{debug, warn};

pub fn save_full_wav(data: &Vec<i16>, detection_prc: u8, me: &str, prefix: &str, max_rms: i16, dir_path: &str) -> String {
    let spec = hound::WavSpec {
        channels: 1,
        sample_rate: VOICE_SAMPLE_RATE as _,
        bits_per_sample: 16,
        sample_format: hound::SampleFormat::Int,
    };
    let now = Utc::now();
    let ts = now.format("%y%m%d-%H%M%S").to_string();

    let filename = format!("{dir_path}/{}_{}_{}_{}_{}.wav", prefix, me, detection_prc, ts, max_rms);
    // println!("Saving {}", filename);
    let mut writer = hound::WavWriter::create(&filename, spec).unwrap();

    for d in data {
        // if (short_wav && index > RING_BUFFER_SIZE / 2) || !short_wav {
        if let Err(e) = writer.write_sample(*d) {
            warn!("Error writing to wav file {:?}", e);
            break;
        }
        // }
    }
    debug!("Recording saved to {filename}");
    filename
}

pub fn save_full_wav_with_channels(
    data: &Vec<i16>,
    channels: usize,
    sample_rate: u32,
    detection_prc: u8,
    me: &str,
    prefix: &str,
    max_rms: i16,
    dir_path: &str,
) -> String {
    let spec = hound::WavSpec {
        channels: channels as _,
        sample_rate: sample_rate as _,
        bits_per_sample: 16,
        sample_format: hound::SampleFormat::Int,
    };
    let now = Utc::now();
    let ts = now.format("%y%m%d-%H%M%S").to_string();

    let filename = format!("{dir_path}/{}_{}_{}_{}_{}.wav", prefix, me, detection_prc, ts, max_rms);
    debug!("Saving {}, rate {}", filename, sample_rate);
    let mut writer = hound::WavWriter::create(&filename, spec).unwrap();

    for d in data.iter() {
        // if (short_wav && index > RING_BUFFER_SIZE / 2) || !short_wav {
        if let Err(e) = writer.write_sample(*d) {
            warn!("Error writing to wav file {:?}", e);
            break;
        }
        // }
    }
    debug!("Recording saved to {filename}");
    filename
}
