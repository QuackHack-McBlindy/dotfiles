use crate::config::{UnlockConfig, SpeechUnlockType};
use log::debug;

pub const OWW_CZ_NAME_AHOJ_HUGO: &str = "Český - Ahoj Hugo";
pub const OWW_CZ_NAME_ALEXA: &str = "Český - Alexa";

#[derive(Debug)]
pub struct LanguageModel {
    pub name: String,
    pub selected: bool,
}

impl LanguageModel {
    pub fn new(name: &str, selected: bool) -> Self {
        LanguageModel { name: name.to_string(), selected }
    }
}

pub fn get_trigger_phases(unlock_config: &UnlockConfig) -> Vec<String> {
    match unlock_config.unlock_type {
        SpeechUnlockType::OpenWakeWordAlexa => vec!["Alexa".to_string()],
        SpeechUnlockType::Custom(_) => vec!["Custom".to_string()], // 🦆 ⮞ custom models
    }
}

pub fn set_unlock_model(language_model: &LanguageModel) -> Option<UnlockConfig> {
    let unlock_config = UnlockConfig::default();

    let model_type = match language_model.name.as_str() {
        OWW_CZ_NAME_ALEXA => SpeechUnlockType::OpenWakeWordAlexa,
         // 🦆 ⮞ for any other name, we cannot determine a custom model path; return None.
        _ => {
            debug!("Unknown language model {:?}, cannot set unlock model", language_model);
            return None;
        }
    };
    let mut new_unlock_config = unlock_config.clone();
    new_unlock_config.unlock_type = model_type;

    debug!("New unlock model config {:?}", new_unlock_config);
    Some(new_unlock_config)
}
