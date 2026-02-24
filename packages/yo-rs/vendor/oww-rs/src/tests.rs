
#[cfg(test)]
mod tests {
    use crate::oww::audio::AudioFeaturesTract;

    #[test]
    fn test_mels2() {
        let mut audio = AudioFeaturesTract::create_default();

        let sample_data = [0f32; 1280];
        let mels = audio.get_melspectrogram(&sample_data).unwrap();
        assert_eq!(mels.shape(), [5, 32]);
    }
}

