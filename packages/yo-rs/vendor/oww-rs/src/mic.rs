use crate::{BUFFER_SECS, VOICE_SAMPLE_RATE};

pub mod converters;
pub mod mic_config;
pub mod mic_cpal;
pub mod process_audio;
pub mod resampler;

pub const RMS_BUFFER_SIZE: usize = 16; // 1 secs+ buffer size

pub const EXPECTED_CHUNK_SIZE: usize = 512;

pub const RING_BUFFER_SIZE: usize = (VOICE_SAMPLE_RATE * BUFFER_SECS) / EXPECTED_CHUNK_SIZE;

pub const MAX_DETECTION_DURATION_SECS: u128 = 80; // ~80ms is threshold for next detection run; based on chunk size
