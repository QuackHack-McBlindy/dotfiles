[![Build & test](https://github.com/skoky/oww_rs/actions/workflows/rust.yml/badge.svg)](https://github.com/skoky/oww_rs/actions/workflows/rust.yml)

# Minimalistic version of the OpenWakeWord inference in Rust and ONNX runtime

This is extracted source code from the [OpenWakeWord](https://github.com/dscripka/openWakeWord) 
providing simplified code for inference of onnx models only. The Python code for inference is converted to
Rust for better wake word detection performance. The inference uses [ORT](https://github.com/pykeio/ort)
supporting all major platforms. For detection the `alexa.onnx` model is used as a sample from
the OpenWakeWord project. Simly saying "Alexa" is detected from microphone as implemented in the `examples/cpal_test.rs`

The implementation uses `cpal` opensourced audio recorder crate. This is pure Rust crate for accessing microphones on all major platforms. 

See the original [OpenWakeWord](https://github.com/dscripka/openWakeWord) lib for more details for pre-trained models or training new custom model. The
training stage is not included in this repo and the OpenWakeWord's original steps should be used to generate
new model triggering on a custom wake word.

# Running like this

    cargo run --example cpal_test

Running tests:

    cargo test

# Contribution

Make an issue / PR etc.

# Licence

MIT license, see [LICENSE](./LICENSE)

