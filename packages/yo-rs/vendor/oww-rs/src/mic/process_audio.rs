use crate::mic::converters::f32_to_i16;
use crate::mic::resampler::{Resamplers, resample_audio};
use crate::rms::calculate_rms;
use std::fmt::Debug;
use std::sync::{Arc, Mutex};
use crate::chunk::{ChannelsData, ChannelsVec, Chunk};

pub fn resample_into_chunks(input: &[f32], buffer: &Arc<Mutex<Vec<f32>>>, channels: usize, resamplers: &mut Resamplers) -> Vec<Chunk> {
    let mut data_buffer = buffer.lock().unwrap();

    data_buffer.extend(input);

    let mut chunks = vec![];

    while data_buffer.len() >= resamplers.chunk_for_resampling * channels {
        let input: Vec<f32> = data_buffer.drain(0..resamplers.chunk_for_resampling * channels).collect();

        let resampled_data = if resamplers.resample_rate != 1.0 {
            resample_audio(&input, resamplers, channels).expect("resampling error")
        } else {
            input.to_vec()
        };

        // assert_eq!(resampled_data.len(), resampler.chunk_for_resampling / resampler.resample_rate as usize);
        let data_f32 = *split_channels(&resampled_data, channels);
        assert_eq!(data_f32.iter().len(), channels);
        let data_i16: Vec<_> = data_f32.iter().map(|c| c.iter().map(f32_to_i16).collect::<Vec<i16>>()).collect();
        assert_eq!(data_i16.len(), channels);
        let rms = data_i16.iter().map(|c| calculate_rms(c.as_slice())).max().unwrap_or(0_i16);

        assert_eq!(data_i16.iter().len(), data_f32.iter().len());
        let chunk = Chunk {
            data_i16: ChannelsVec::new(data_i16),
            data_f32,
            rms,
        };
        chunks.push(chunk);
    }
    chunks
}

/// returns vec of 1 or 2 channels data as vec
pub fn split_channels<T: Copy + Clone + Debug>(samples: &[T], channels: usize) -> Box<ChannelsVec<Vec<T>>> {
    match channels {
        1 => {
            // Mono: duplicate the channel to simulate stereo
            Box::new(ChannelsVec::new(vec![samples.to_vec()]))
        }
        2 => {
            // Stereo: deinterleave into left and right
            let mut left = Vec::with_capacity(samples.len() / 2);
            let mut right = Vec::with_capacity(samples.len() / 2);

            for chunk in samples.chunks(2) {
                if let [l, r] = chunk {
                    left.push(*l);
                    right.push(*r);
                }
            }

            Box::new(ChannelsVec::new(vec![left, right]))
        }
        _ => panic!("Unsupported number of channels: {}", channels),
    }
}

/// returns vec of 1 or 2 channels data as vec
pub fn split_channels2<T: Copy + Clone + Debug>(samples: &[T], channels: usize) -> Box<Vec<Vec<T>>> {
    match channels {
        1 => {
            // Mono: duplicate the channel to simulate stereo
            Box::new(vec![samples.to_vec()])
        }
        2 => {
            // Stereo: deinterleave into left and right
            let mut left = Vec::with_capacity(samples.len() / 2);
            let mut right = Vec::with_capacity(samples.len() / 2);

            for chunk in samples.chunks(2) {
                if let [l, r] = chunk {
                    left.push(*l);
                    right.push(*r);
                }
            }

            Box::new(vec![left, right])
        }
        _ => panic!("Unsupported number of channels: {}", channels),
    }
}

pub fn interlace_stereo(channels: ChannelsData) -> Vec<f32> {
    if channels.iter().len() == 1 {
        channels[0].clone()
    } else if channels.iter().len() == 2 {
        let left = &channels[0];
        let right = &channels[1];
        assert_eq!(left.len(), right.len(), "Left and right channels must be of equal length.");

        let mut interlaced = Vec::with_capacity(left.len() * 2);

        for i in 0..left.len() {
            interlaced.push(left[i]);
            interlaced.push(right[i]);
        }

        interlaced
    } else {
        panic!("Unsupported number of channels: {}", channels.iter().len());
    }
}

pub fn interlace_stereo2(channels: &Vec<Vec<f32>>) -> Vec<f32> {
    if channels.iter().len() == 1 {
        channels[0].clone()
    } else if channels.iter().len() == 2 {
        let left = &channels[0];
        let right = &channels[1];
        assert_eq!(left.len(), right.len(), "Left and right channels must be of equal length.");

        let mut interlaced = Vec::with_capacity(left.len() * 2);

        for i in 0..left.len() {
            interlaced.push(left[i]);
            interlaced.push(right[i]);
        }

        interlaced
    } else {
        panic!("Unsupported number of channels: {}", channels.iter().len());
    }
}
