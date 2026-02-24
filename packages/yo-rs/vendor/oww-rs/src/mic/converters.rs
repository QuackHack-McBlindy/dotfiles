pub fn f32_to_i16(sample: &f32) -> i16 {
    // Clamp the sample to the [-1.0, 1.0] range
    let clamped_sample = sample.clamp(-1.0, 1.0);

    // Scale and cast to i16
    (clamped_sample * 32767.0) as i16
}

pub fn i16_to_f32(sample: &i16) -> f32 {
    *sample as f32 / 32768.0
}

#[cfg(test)]
mod tests {
    use crate::mic::converters::{f32_to_i16, i16_to_f32};

    #[test]
    fn test_conversion() {
        use approx::assert_relative_eq;
        let i = vec![0i16, 14, 31, 22, 150, -256, -1i16, i16::MIN, i16::MAX];
        let f: Vec<f32> = i.iter().map(i16_to_f32).collect();
        let ii: Vec<i16> = f.iter().map(f32_to_i16).collect();
        for (x, y) in ii.iter().zip(i) {
            assert_relative_eq!(*x as f32, y as f32, epsilon = 1.0);
        }
    }

}
