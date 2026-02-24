use crate::RMS_BUFFER_SIZE;
use circular_buffer::CircularBuffer;

pub fn calculate_max_rms(buffer: &CircularBuffer<RMS_BUFFER_SIZE, i16>) -> i16 {
    let mut max = 0;
    for rms in buffer.to_vec() {
        let abs_rms = rms.abs();
        if abs_rms > max {
            max = abs_rms;
        }
    }
    max
}

pub fn calculate_rms(chunk: &[i16]) -> i16 {
    // Handle empty slice case
    if chunk.is_empty() {
        return 0;
    }
    // Calculate sum of absolute values using i64 to prevent overflow
    let sum: u64 = chunk.iter().map(|&x| (x as i64).unsigned_abs()).sum();

    // Calculate average (as f64 for precision)
    let average: u64 = sum / chunk.len() as u64;

    // Take square root and convert back to i16
    i16::try_from(average as i16).unwrap_or(1)
}

#[cfg(test)]
mod tests {
    use crate::rms::{calculate_max_rms, calculate_rms};
    use circular_buffer::CircularBuffer;
    #[test]
    fn tst_rms_i16() {
        let rms = calculate_rms(&vec![1_i16, 2_i16, 3_i16]);
        assert_eq!(rms, 2);
    }

    #[test]
    fn tst_rms_i16_max() {
        let rms = calculate_rms(&vec![10_000, 10_000, 10_000]);
        assert_eq!(rms, 10_000)
    }

    #[test]
    fn test_max_rms_i16() {
        let mut buffer = CircularBuffer::new();
        buffer.extend_from_slice(&vec![1, 2, 3, -1, 0, 0, 1, 3]);
        let mut max_rms = calculate_max_rms(&buffer);

        assert_eq!(max_rms, 3);
        buffer.push_back(-10);

        max_rms = calculate_max_rms(&buffer);
        assert_eq!(max_rms, 10);

        buffer.push_back(i16::MAX);
        max_rms = calculate_max_rms(&buffer);
        assert_eq!(max_rms, i16::MAX);
    }
}
