use crate::config::UnlockConfig;
use crate::config::SpeechUnlockType;
use crate::oww::OwwModel;

pub(crate) trait Model: Send + Sync {
    fn frame_length(&self) -> u32;
    fn detect(&mut self, data: Vec<f32>) -> Option<Detection>;
    fn detect_i16(&mut self, data: Vec<i16>) -> Option<Detection>;
}

pub fn new_model(config: UnlockConfig) -> Result<Box<dyn Model>, String> {
    new_oww_model(config)
}

#[derive(Debug, Clone)]
pub struct Detection {
    pub detected: bool,
    pub probability: f32,
    pub duration_ms: u128,
}

impl Detection {
    pub fn none() -> Detection {
        Detection {
            detected: false,
            probability: 0.0,
            duration_ms: 0,
        }
    }
}

fn new_oww_model(config: UnlockConfig) -> Result<Box<dyn Model>, String> {
    let model_opt = match config.unlock_type {
        SpeechUnlockType::OpenWakeWordAlexa => {
            OwwModel::new(config.unlock_type, config.detection_threshold)
        }
        SpeechUnlockType::Custom(ref path) => {
            OwwModel::from_path(path, config.detection_threshold)
        }
    };

    match model_opt {
        Ok(model) => Ok(Box::new(model)),
        Err(e) => Err(format!("OWW: {}", e)),
    }
}
