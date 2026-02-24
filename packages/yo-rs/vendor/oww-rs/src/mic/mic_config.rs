use crate::VOICE_SAMPLE_RATE;
use cpal::traits::DeviceTrait;
use cpal::{SampleFormat, SampleRate, StreamConfig, SupportedStreamConfigRange};
use log::{debug, error, info};

pub fn find_best_config(device: &cpal::Device) -> Result<(StreamConfig, SampleFormat), Box<dyn std::error::Error>> {
    #[cfg(target_os = "ios")]
    {
        let config = match device.default_input_config() {
            Ok(config) => {
                info!("IOS Mic config: {:?}", config);
                config
            }
            Err(e) => {
                warn!("IOS Mic config not available in Simulator!");
                return Err(e.into());
            }
        };

        return Ok((config.clone().into(), config.sample_format()));
    }

    let supported_configs: Vec<SupportedStreamConfigRange> = match device.supported_input_configs() {
        Ok(supported_configs) => {
            info!("supported_configs found");
            supported_configs.collect()
        }
        Err(e) => {
            error!("error getting supported_input_configs : {:?}", e);
            return Err(Box::new(e));
        }
    };

    for config in &supported_configs {
        info!("Supported input config: {:?}", config);
    }

    // Try to find a configuration with 16kHz, i16, and 1 channel
    let desired_sample_rate = VOICE_SAMPLE_RATE as u32;
    let desired_config = supported_configs.iter().find(|config| {
        config.channels() == 1
            && config.sample_format() == SampleFormat::F32
            && config.min_sample_rate().0 <= desired_sample_rate
            && config.max_sample_rate().0 >= desired_sample_rate
    });

    if let Some(config_range) = desired_config {
        let config = config_range.with_sample_rate(SampleRate(desired_sample_rate));
        debug!("Found desired configuration (16kHz, f32, mono)");
        return Ok((config.clone().into(), config_range.sample_format()));
    }

    // Try to find any mono configuration with f32
    let mono_f32_config = supported_configs
        .iter()
        .find(|config| config.channels() == 1 && config.sample_format() == SampleFormat::F32);

    if let Some(config_range) = mono_f32_config {
        let config = config_range.with_max_sample_rate();
        debug!("Found mono f32 configuration with different sample rate {:?}", &config);
        return Ok((config.into(), config_range.sample_format()));
    }

    // Try to find any stereo configuration with f32
    let stereo_f32_config = supported_configs
        .iter()
        .find(|config| config.channels() == 2 && config.sample_format() == SampleFormat::F32);

    if let Some(config_range) = stereo_f32_config {
        let config = config_range.with_max_sample_rate();
        debug!("Found stereo f32 configuration with different sample rate {:?}", &config);
        return Ok((config.into(), config_range.sample_format()));
    }

    // Try to find any mono configuration with sample rate 16khz
    let mono_16khz_config = supported_configs
        .iter()
        .find(|config| config.channels() == 1 && config.min_sample_rate().0 <= desired_sample_rate && config.max_sample_rate().0 >= desired_sample_rate);

    if let Some(config_range) = mono_16khz_config {
        let config = config_range.with_max_sample_rate();
        debug!("Found mono 16khz configuration with different format but good sample rate {:?}", &config);
        return Ok((config.into(), config_range.sample_format()));
    }

    // Try to find any mono configuration
    let mono_config = supported_configs.iter().find(|config| config.channels() == 1);

    if let Some(config_range) = mono_config {
        let config = config_range.with_max_sample_rate();
        debug!("Found mono configuration with different format, btu mono {:?}", &config);
        return Ok((config.into(), config_range.sample_format()));
    }

    let default_config = device.default_input_config()?;
    debug!("Using default configuration {:?} ", default_config);
    Ok((default_config.clone().into(), default_config.sample_format()))
}
