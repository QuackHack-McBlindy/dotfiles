{
  services = {
    wyoming-satellite = {
      enable = true;
      config = {
        uri = "tcp://localhost:12345";
        name = "Satellite";
        awake_wav = "/home/pungkula/wyoming/sounds/awake.wav";
        done_wav = "/home/pungkula/wyoming/sounds/done.wav";
        sound_enabled = true;
        noise_suppression = 2;
        auto_gain = 15;
        mic_volume_multiplier = 2;
        sound_volume_multiplier = 2;
        wake_uri = "tcp://localhost:12346";
        wake_word_name = "yo_bitch";
        wake_command = "path/to/wake_word_detector --model /path/to/yo_bitch.tflite";
        vad = true;
      };
    };

    wyoming-faster-whisper = {
      enable = true;
      config = {
        model = "small-int8";
        uri = "tcp://localhost:12347";
        data_dir = "/path/to/data";
        download_dir = "/path/to/download";
        device = "cpu";
        language = "sv";
        beam_size = 1;
      };
    };

    piper = {
      enable = true;
      config = {
        model = "/path/to/sv_SE-nst-medium.onnx";
        config = "/path/to/sv_SE-nst-medium.json";
        voice = "sv_SE-nst-medium";
        speaker = 2;
        length_scale = 1;
        noise_scale = 0.667;
        noise_w = 0.333;
        max_piper_procs = 3;
      };
    };
  };
}

