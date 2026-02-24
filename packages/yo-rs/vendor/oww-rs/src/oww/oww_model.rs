use crate::config::SpeechUnlockType;
use crate::model::Detection;
use crate::oww;
use crate::oww::OwwModel;
use crate::oww::audio::AudioFeaturesTract;
use circular_buffer::CircularBuffer;
use log::{debug, trace, warn};
use oww::DETECTION_BUFFER_SIZE;
use rust_embed::Embed;
use std::io::Cursor;
use std::time::Instant;
use tract_core::internal::TVec;
use tract_core::prelude::multithread::{self, Executor};
use tract_core::prelude::{Framework, TValue};
use tract_onnx::prelude::{InferenceModelExt, IntoTensor, Tensor as TractTensor, tvec};

// NEW: imports for file I/O
use std::fs::File;
use std::io::Read;

const MIN_POSITIVE_DETECTIONS: f32 = 3.0;
const NO_DETECTION_MS: u32 = 2_000;

#[derive(Embed)]
#[folder = "speech_models/"]
struct SpeechModels;

impl OwwModel {
    pub fn detection(&mut self, chunk_f32: Vec<f32>) -> Detection {
        let start = Instant::now();

        let audio_features = match self.audio.get_audio_features(chunk_f32.as_slice()) {
            Ok(features) => features,
            Err(e) => {
                warn!("Embeddings error {:?}", e);
                return crate::model::Detection {
                    detected: false,
                    probability: 0.0,
                    duration_ms: 0,
                };
            }
        };

        let (detected, prc) = self.detect(audio_features);

        let onnx_duration = start.elapsed();
        Detection {
            detected,
            probability: prc,
            duration_ms: onnx_duration.as_millis(),
        }
    }

    pub fn detect(&mut self, features: TractTensor) -> (bool, f32) {
        trace!("2: features size {:?}", features.shape()); // [16, 96]
        let last = features.into_shape(&[1, 16, 96]).unwrap();
        trace!("2: inputs size {:?}", last.shape()); // [1, 16, 96]

        multithread::set_default_executor(Executor::SingleThread);

        let out: TVec<TValue> = self.tract_model.run(tvec!(last.into())).unwrap();
        trace!("2: output {:?}", out[0].shape()); // [1,1]

        let t = out.clone()[0].clone().into_tensor().cast_to::<f32>().unwrap().into_owned();
        let probability = t.as_slice::<f32>().unwrap()[0];
        trace!("2:Tract probability: {:?}", probability);

        self.detections_buffer.push_back(probability);

        let average_detection_probability = self.calculate_average();
        let since_last_detection = self.last_detection_time.elapsed().as_millis();

        // when detection is done and avg detection is still high. Anf not too often
        if probability < 0.1 && average_detection_probability > self.threshold && since_last_detection > NO_DETECTION_MS as _ {
            self.last_detection_time = Instant::now();
            return (true, average_detection_probability);
        }
        if average_detection_probability > 0.1 {
            debug!("Prob {}, avg {} since {:?}", probability, average_detection_probability, since_last_detection);
        }
        (false, average_detection_probability)
    }

    fn calculate_average(&self) -> f32 {
        let all_detections = self.detections_buffer.to_vec();
        let mut detection_cumulative = 0.0;
        let mut positive_count = 0.0;
        for d in all_detections {
            if d > self.threshold {
                positive_count += 1.0;
                detection_cumulative += d;
            }
        }
        let avg = detection_cumulative / positive_count;
        if positive_count > MIN_POSITIVE_DETECTIONS && avg > self.threshold { avg } else { 0.0 }
    }

    // Existing constructor for embedded models
    pub fn new(model_type: SpeechUnlockType, threshold: f32) -> Result<OwwModel, String> {
        let model_data = match model_type {
            SpeechUnlockType::OpenWakeWordAlexa => &crate::oww::oww_model::SpeechModels::get("alexa.onnx").unwrap().data,
            // NEW: handle custom variant – will be called from model.rs with the path,
            // but we use a separate constructor for that.
            SpeechUnlockType::Custom(_) => unreachable!("Use OwwModel::from_path for custom models"),
        };

        let model_unlock_word = match model_type {
            SpeechUnlockType::OpenWakeWordAlexa => "Alexa".to_string(),
            SpeechUnlockType::Custom(_) => "Custom".to_string(),
        };
        let detections_buffer = CircularBuffer::<DETECTION_BUFFER_SIZE, f32>::new();

        let mut rdr = Cursor::new(model_data);

        let tract_model = tract_onnx::onnx().model_for_read(&mut rdr).unwrap().into_optimized().unwrap().into_runnable().unwrap();
        Ok(OwwModel {
            audio: AudioFeaturesTract::create_default(),
            tract_model,
            threshold,
            last_detection_time: Instant::now(),
            detections_buffer,
            model_unlock_word,
        })
    }

    // NEW: constructor to load a custom speech model from a file path
    pub fn from_path(model_path: &str, threshold: f32) -> Result<OwwModel, String> {
        let mut file = File::open(model_path).map_err(|e| e.to_string())?;
        let mut model_data = Vec::new();
        file.read_to_end(&mut model_data).map_err(|e| e.to_string())?;

        let detections_buffer = CircularBuffer::<DETECTION_BUFFER_SIZE, f32>::new();
        let mut rdr = Cursor::new(model_data);
        let tract_model = tract_onnx::onnx()
            .model_for_read(&mut rdr)
            .map_err(|e| e.to_string())?
            .into_optimized()
            .map_err(|e| e.to_string())?
            .into_runnable()
            .map_err(|e| e.to_string())?;

        Ok(OwwModel {
            audio: AudioFeaturesTract::create_default(),
            tract_model,
            threshold,
            last_detection_time: Instant::now(),
            detections_buffer,
            model_unlock_word: "Custom".to_string(),
        })
    }
}
