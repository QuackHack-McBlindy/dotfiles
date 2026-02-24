use crate::config::UnlockConfig;
use crate::mic::RING_BUFFER_SIZE;
use crate::mic::converters::i16_to_f32;
use crate::mic::mic_config::find_best_config;
use crate::mic::process_audio::resample_into_chunks;
use crate::mic::resampler::make_resampler;
use crate::model::{Detection};
use crate::rms::calculate_rms;
use crate::Models;
use circular_buffer::CircularBuffer;
use cpal::SampleFormat;
use cpal::traits::{DeviceTrait, HostTrait, StreamTrait};
use log::{debug, error, info, warn};
use std::error::Error;
use std::sync::{Arc, Mutex};
use std::thread::sleep;
use std::time::Duration;
use tokio::sync::broadcast;
use tokio_util::sync::CancellationToken;
use crate::chunk::{Chunk, ChunkType};

pub(crate) const MODEL_SAMPLE_RATE: u32 = 16000;

pub struct MicHandlerCpal {
    model: Arc<Mutex<Models>>,
    unlock_config: UnlockConfig,
    chunks_sender: broadcast::Sender<ChunkType>,
}

impl MicHandlerCpal {
    pub fn default_mic_name() -> Result<String, String> {
        let host = cpal::default_host();
        let device = host.default_input_device().ok_or("No mic available")?;
        device.name().map_err(|e| e.to_string())
    }

    pub(crate) fn new(
        model: Arc<Mutex<Models>>,
        unlock_config: &UnlockConfig,
        chunks_sender: broadcast::Sender<ChunkType>,
    ) -> Result<Self, Box<dyn Error>> {
        Ok(MicHandlerCpal {
            model,
            unlock_config: unlock_config.clone(),
            chunks_sender,
        })
    }

    pub fn loop_now_sync(&mut self,  cancellation_token: CancellationToken) -> Result<bool, Box<dyn Error>> {
        // Initialize CPAL
        let host = cpal::default_host();
        let device = match host.default_input_device() {
            None => return Err("No input device available".into()),
            Some(mic) => mic,
        };
        let mut last_mic_name = "".to_string();
        match device.name() {
            Ok(name) => {
                debug!("Input device: {}", name);
            }
            Err(e) => {
                error!("Couldn't get microphone device: {:?}", e);
                return Err(e.to_string().into());
            }
        }
        info!("Starting to find the best config");
        let (config, sample_format) = match find_best_config(&device) {
            Ok(c) => c,
            Err(e) => {
                warn!("Microphone not compatible {}", e);
                return Err(e.to_string().into());
            }
        };
        info!("Selected input config: {:?}", config);

        // Create a buffer to store audio data
        let buffer: Arc<Mutex<Vec<f32>>> = Arc::new(Mutex::new(vec![]));
        let buffer_clone = buffer.clone();

        // Store the original sample rate and channels
        let original_sample_rate = config.sample_rate.0;
        let channels = config.channels as usize;

        // Create the input stream
        let err_fn = |err| warn!("An error occurred on the input stream: {}", err);

        let model_chunk_size = self.model.lock().unwrap().frame_length();

        let mut resamplers = make_resampler(original_sample_rate, model_chunk_size as _, channels)?;

        let model3 = self.model.clone();
        let chunks_sender = self.chunks_sender.clone();
        let timeout = Some(Duration::from_millis(80));
        let quiet_threshold = self.unlock_config.quite_threshold;
        let ring_buffer = Arc::new(Mutex::new(CircularBuffer::<{ RING_BUFFER_SIZE }, Chunk>::boxed()));

        let stream = match sample_format {
            SampleFormat::F32 => device.build_input_stream(
                &config,
                move |data: &[f32], _info: &cpal::InputCallbackInfo| {
                    resample_into_chunks(data, &buffer_clone, channels, &mut resamplers).iter().for_each(|chunk| {
                        ring_buffer.lock().unwrap().push_back(chunk.clone());
                        handle_detect(
                            chunk,
                            chunks_sender.clone(),
                            model3.clone(),
                            ring_buffer.lock().unwrap().to_vec(),
                            quiet_threshold,
                        );
                    })
                },
                err_fn,
                timeout,
            )?,
            SampleFormat::I16 => device.build_input_stream(
                &config,
                move |data: &[i16], _: &_| {
                    // Convert i16 to f32
                    let data_f32: Vec<f32> = data.iter().map(i16_to_f32).collect();

                    resample_into_chunks(&data_f32, &buffer_clone, channels, &mut resamplers).iter().for_each(|chunk| {
                        handle_detect(
                            chunk,
                            chunks_sender.clone(),
                            model3.clone(),
                            ring_buffer.lock().unwrap().to_vec(),
                            quiet_threshold,
                        );
                    })
                },
                err_fn,
                timeout,
            )?,
            _ => return Err("Unsupported sample format".to_string().into()),
        };

        stream.play()?;

        let mut check_mic_count: u64 = 0;
        while !cancellation_token.is_cancelled() {
            check_mic_count += 1;
            if check_mic_count.is_multiple_of(20) {
                let mic_name = self.check_mic();
                match mic_name {
                    Some(mic_name) if last_mic_name != mic_name => {
                        last_mic_name = mic_name.clone();
                    }
                    None => {
                        // mic changed, reload recorder
                        break;
                    }
                    _ => {}
                }
            }

            sleep(Duration::from_millis(100));
        }
        Ok(false)
    }

    fn check_mic(&self) -> Option<String> {
        match MicHandlerCpal::default_mic_name() {
            Ok(default_mic) => Some(default_mic),
            Err(e) => {
                warn!("Mic error {}", e);
                None
            }
        }
    }
}

pub(crate) fn handle_detect(
    chunk: &Chunk,
    chunks_sender: broadcast::Sender<ChunkType>,
    model: Arc<Mutex<Models>>,
    buffered_chunks: Vec<Chunk>,
    quite_threshold: i16,
) -> Detection {
    let _ = chunks_sender.send(chunk.clone());

    let mut model = model.lock().unwrap();
    let mut detections_f32 = vec![];

    for (channel, data) in chunk.data_f32.iter().enumerate() {
        let d = if channel == 0 { model.detect1(data.clone()) } else { model.detect2(data.clone()) };
        #[cfg(debug_assertions)]
        d.clone().map(|d| {
            if d.probability > 0.0 {
                debug!("Detection channel {}, prob {}", channel, d.probability)
            }
        });
        detections_f32.push(d);
    }
    let detections_i16: Vec<Option<Detection>> = chunk
        .data_i16
        .iter()
        .enumerate()
        .map(|(i, data)| if i == 0 { model.detect1_i16(data.clone()) } else { model.detect2_i16(data.clone()) })
        .collect();
    // find the best detection
    let detection = detections_f32
        .into_iter()
        .chain(detections_i16) // flatten both vectors into one iterator
        .flatten() // remove the None values
        .max_by(|d1, d2| d1.probability.partial_cmp(&d2.probability).unwrap())
        .unwrap();

    if detection.detected {
        let rmss: Vec<i16> = buffered_chunks.iter().map(|c| c.rms).collect();
        let max_rms = calculate_rms(rmss.as_ref());
        println!("Detection {:?}, max_rms {} limit {}", detection, max_rms, quite_threshold);
    }
    detection
}
