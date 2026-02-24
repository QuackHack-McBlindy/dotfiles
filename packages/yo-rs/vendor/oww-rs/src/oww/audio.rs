use circular_buffer::CircularBuffer;
use log::trace;
use rust_embed::Embed;
use std::error::Error;
use std::io::Cursor;
use tract_core::prelude::multithread::{self, Executor};
use tract_onnx::prelude::Tensor;

use crate::ModelType;
use tract_onnx::prelude::*;

#[derive(Embed)]
#[folder = "models/"]
struct Models;

pub const FEATURE_BUFFER_SIZE: usize = 16;
pub const MELS_BUFFER_SIZE: usize = 40;
const MEL_CIRC_SIZE: usize = 80 / 5;

#[derive(Debug)]
pub struct AudioFeaturesTract {
    mel: ModelType,
    emb: ModelType,
    pub feature_buffer: Box<CircularBuffer<FEATURE_BUFFER_SIZE, Tensor>>,
    pub mel_spectrogram_buffer: Box<CircularBuffer<MEL_CIRC_SIZE, Tensor>>,
}

impl AudioFeaturesTract {
    pub fn create_default() -> Self {
        let mel_model_data = &Models::get("melspectrogram.onnx").unwrap().data;
        let mut mel_model_rdr = Cursor::new(mel_model_data);
        let mel_model = tract_onnx::onnx().model_for_read(&mut mel_model_rdr);

        let emb_model_data = &Models::get("embedding_model.onnx").unwrap().data;
        let mut emb_model_rdr = Cursor::new(emb_model_data);
        let embeddings_model = tract_onnx::onnx().model_for_read(&mut emb_model_rdr);

        multithread::set_default_executor(Executor::SingleThread);

        let mel = mel_model
            .unwrap()
            .with_input_fact(0, f32::fact([1, 1280]).into())
            .unwrap()
            .into_optimized()
            .unwrap()
            .into_runnable()
            .unwrap();

        let emb = embeddings_model
            .unwrap()
            .with_input_fact(0, f32::fact([1, 76, 32, 1]).into())
            .unwrap()
            .into_optimized()
            .unwrap()
            .into_runnable()
            .unwrap();

        let mut feature_buffer = CircularBuffer::<FEATURE_BUFFER_SIZE, Tensor>::boxed();
        for _ in 0..FEATURE_BUFFER_SIZE {
            feature_buffer.push_back(Tensor::from_shape(&[1, 1, 1, 96], &[0f32; 96]).unwrap());
        }
        let mut mel_spectrogram_buffer: Box<CircularBuffer<MEL_CIRC_SIZE, Tensor>> = CircularBuffer::<MEL_CIRC_SIZE, Tensor>::boxed();
        for _ in 0..MEL_CIRC_SIZE {
            mel_spectrogram_buffer.push_back(Tensor::from_shape(&[5, 32], &[0f32; 5 * 32]).unwrap());
        }

        AudioFeaturesTract {
            mel,
            emb,
            feature_buffer,
            mel_spectrogram_buffer,
        }
    }

    pub fn get_melspectrogram(&mut self, data: &[f32]) -> Result<Tensor, Box<dyn Error>> {
        let tensor = Tensor::from_shape(&[1, 1280], data).expect("wrong shape size"); // or .into() variants depending on tract version

        trace!("2:get_melspectrogram with data size {:?}", tensor.shape());
        let outputs: TVec<TValue> = self.mel.run(tvec!(tensor.into()))?;

        let out_tensor = outputs[0].clone().into_tensor();
        trace!("2: get_melspectrogram with output tensor {:?}", out_tensor.shape());
        let resized = out_tensor.clone().into_shape(&[5, 32])?;
        let a = resized.into_array::<f32>()?.into_owned();
        let updated = a.mapv(|v| (v / 10.0) + 2.0).into_tensor();
        Ok(updated)
    }

    pub fn get_audio_features(&mut self, data: &[f32]) -> Result<Tensor, Box<dyn Error>> {
        trace!("2: data chunk: {:?}", data.len());
        let mel_chunk = self.get_melspectrogram(data)?;
        // info!("2: mel_chunk: {:?}", mel_chunk.shape());  // [5,32]

        self.mel_spectrogram_buffer.push_back(mel_chunk);
        let stacked_mels = Tensor::stack_tensors(0, &self.mel_spectrogram_buffer.to_vec())?;

        // info!("2:stacked_mels: {:?}", stacked_mels.shape());  // [80,32]

        let smaller = stacked_mels.slice(0, 4, 80)?;
        // info!("2:smaller: {:?}", smaller.shape());  // [76, 32]
        let reshaped = smaller.into_shape(&[1, 76, 32, 1])?;

        // info!("2: all mels: {:?}", reshaped.shape());

        let embedings = self.emb.run(tvec!(reshaped.into()))?;

        // info!("2: embd shapes: {:?}", embedings[0].shape()); // [1,1,1,96]

        self.feature_buffer.push_back(embedings[0].clone().into_tensor());

        let stacked = Tensor::stack_tensors(0, &self.feature_buffer.to_vec())?;

        // Now reshape [41,1,1,96] -> [41,96]
        let reshaped = stacked.into_shape(&[self.feature_buffer.len(), 96])?;
        Ok(reshaped)
    }
}
