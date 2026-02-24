use crate::mic::mic_cpal::MODEL_SAMPLE_RATE;
use crate::mic::process_audio::{interlace_stereo2, split_channels2};
use crate::oww::OWW_MODEL_CHUNK_SIZE;
use log::{debug, info, warn};
use rubato::{FftFixedInOut, FftFixedOut, Resampler};
use std::error::Error;
use std::fmt::{Debug, Formatter};

const HIGH_SAMPLING_RATE: usize = 48_000;

pub struct Resamplers {
    pub main: FftFixedInOut<f32>,
    pub upsampler: FftFixedOut<f32>,
    pub use_upsampler: bool,
    pub chunk_for_resampling: usize,
    pub resample_rate: f32,
}

impl Debug for Resamplers {
    fn fmt(&self, f: &mut Formatter<'_>) -> std::fmt::Result {
        f.write_str(&format!(
            "use {}, chunk size {}, resample rate {}",
            self.use_upsampler, self.chunk_for_resampling, self.resample_rate
        ))
    }
}

pub fn make_resampler(original_sample_rate: u32, model_chunk_size: u32, channels_count: usize) -> Result<Resamplers, Box<dyn Error>> {
    let sample_rate = original_sample_rate as f32 / MODEL_SAMPLE_RATE as f32 ;

    if sample_rate.floor() != sample_rate {
        warn!("mic sample rate not supported {}; using double resampling", sample_rate);
        let upsampler_rate = original_sample_rate as f32 / HIGH_SAMPLING_RATE as f32;

        let internal_rate = HIGH_SAMPLING_RATE as f32 / MODEL_SAMPLE_RATE as f32;

        let main_sampler_input_size = (model_chunk_size as f32 * internal_rate) as usize;

        let main = FftFixedInOut::<f32>::new(HIGH_SAMPLING_RATE as _, MODEL_SAMPLE_RATE as _, main_sampler_input_size, channels_count)?;

        let upsampler_output_size = (OWW_MODEL_CHUNK_SIZE as f32 * internal_rate) as usize;
        let upsampler_input_size = (upsampler_output_size as f32 * upsampler_rate) as usize;

        let upsampler = FftFixedOut::<f32>::new(original_sample_rate as _, HIGH_SAMPLING_RATE as _, upsampler_output_size, 1, channels_count)?;

        let resamplers = Resamplers {
            main,
            upsampler,
            use_upsampler: true,
            chunk_for_resampling: upsampler_input_size,
            resample_rate: sample_rate,
        };
        debug!("Resamplers: {:?}", resamplers);
        Ok(resamplers)
    } else {
        info!("mic sample rate {}", sample_rate);

        // Do not use channels here. The rate should be alculated per channel only
        let input_chunk_size: usize = (model_chunk_size * sample_rate as u32) as usize;

        let _prev = FftFixedOut::<f32>::new(original_sample_rate as _, MODEL_SAMPLE_RATE as _, input_chunk_size, 1, channels_count)?;
        let main = FftFixedInOut::<f32>::new(original_sample_rate as _, MODEL_SAMPLE_RATE as _, input_chunk_size, channels_count)?;

        Ok(Resamplers {
            main,
            upsampler: _prev,
            use_upsampler: false,
            chunk_for_resampling: input_chunk_size,
            resample_rate: sample_rate,
        })
    }
}

pub fn resample_audio(data: &[f32], resamplers: &mut Resamplers, channels: usize) -> Result<Vec<f32>, String> {
    // debug!("Resampling audio size {}, channels {}", data.len(), channels);

    let with_channels = split_channels2(data, channels);
    let presampled = if resamplers.use_upsampler {
        match resamplers.upsampler.process(&with_channels, None) {
            Ok(r) => {
                assert_eq!(r.first().unwrap().len(), 3840);
                r
            }
            Err(e) => {
                eprintln!("> {:?}", e);
                panic!("resampling error")
            }
        }
    } else {
        *with_channels
    };

    assert_eq!(presampled.len(), channels);
    // println!("Non resampled: {}", presampled.first().unwrap().len());
    match resamplers.main.process(&presampled, None) {
        Ok(resampled) => {
            // println!("Resampled {}", resampled.first().unwrap().len());
            Ok(interlace_stereo2(&resampled))
        }
        Err(e) => {
            eprintln!("Main resampling error {:?}", e);
            Err(format!("Resampler process returned an error {}", e))
        }
    }
}

#[cfg(test)]
pub mod tests {
    use crate::mic::resampler::make_resampler;

    #[test]
    fn test_mono_16khz() {
        let r = make_resampler(16000, 1280, 1).unwrap();
        assert_eq!(r.resample_rate, 1.0);
        assert_eq!(r.chunk_for_resampling, 1280);
    }

    #[test]
    fn test_stereo_16khz() {
        let r = make_resampler(16000, 1280, 2).unwrap();
        assert_eq!(r.resample_rate, 1.0);
        assert_eq!(r.chunk_for_resampling, 1280);
    }

    #[test]
    fn test_mono_48khz() {
        let r = make_resampler(48000, 1280, 1).unwrap();
        assert_eq!(r.resample_rate, 3.0);
        assert_eq!(r.chunk_for_resampling, 1280 * r.resample_rate as usize);
    }

    #[test]
    fn test_stereo_48khz() {
        let r = make_resampler(48000, 1280, 2).unwrap();
        assert_eq!(r.resample_rate, 3.0);
        assert_eq!(r.chunk_for_resampling, 3840);
    }

    #[test]
    fn test_mono_44_1khz() {
        let r = make_resampler(44100, 1280, 1).unwrap();
        assert_eq!(r.resample_rate, 2.75625);
        assert_eq!(r.chunk_for_resampling, 3528);
    }

    #[test]
    fn test_stereo_44_1khz() {
        let r = make_resampler(44100, 1280, 2).unwrap();
        assert_eq!(r.resample_rate, 2.75625);
        assert_eq!(r.chunk_for_resampling, 3528);
    }
}
