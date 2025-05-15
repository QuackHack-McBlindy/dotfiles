{ 
    config, 
    lib, 
    pkgs, 
    ... 
} : {
  config = lib.mkIf (lib.elem "bitchr" config.this.host.modules.services) {
    # Satellite
    services.wyoming.satellite = {
        enable = true;
        package = pkgs.wyoming-satellite;
        user = "voice";
        group = "voice";
        uri = "tcp://0.0.0.0:10700";
        name = "desktop";
        area = "vardagsrum";
        microphone = {
            command = "arecord -r 16000 -c 1 -f S16_LE -t raw";
            autoGain = 10;
            noiseSuppression = 1;
        };
        sound.command = "aplay -r 22050 -c 1 -f S16_LE -t raw";
        sounds = {
            awake = "/pungkula/.config/wyoming/sounds/awake.wav";
            done = "/pungkula/.config/wyoming/sounds/done.wav";
        };
        vad.enable = true;
        #  extraArgs = [ "--some-extra-arg" ];
    };

    # Wake Word
    services.wyoming.openwakeword = {
        #enable = true;
        package = pkgs.wyoming-openwakeword;
        uri = "tcp://0.0.0.0:10400";
        preloadModels = [ "yo_bitch" ];
        customModelsDirectories = [ "/etc/openwakeword" ];
        #customModelsDirectories = [ "/home/pungkula/models/yo_bitch.tflite" ];
        # preloadModels = [ "yo_bitch" ];
        threshold = 0.5;
        triggerLevel = 1;
        extraArgs = [ ];
    };
    
    # Speech to Text
    services.wyoming.faster-whisper = {
        package = pkgs.wyoming-faster-whisper;
        servers = {
            "whisper" = {
                enable = true;
                model = "small-int8";
                language = "sv";
                beamSize = 1;
                uri = "tcp://0.0.0.0:10300";
                device = "cpu";
                extraArgs = [ ];
            };
        };
    };
  
    # Text to Speech
    services.wyoming.piper = {
        package = pkgs.wyoming-piper;
        servers = {
            "piper" = {
                enable = true;
                piper = pkgs.piper-tts;
                voice = "sv_SE-nst-medium";
                uri = "tcp://0.0.0.0:10200";
                speaker = 0;
                noiseScale = 0.667;
                noiseWidth = 0.333;
                lengthScale = 1.0;
                extraArgs = [
                    "--piper" "/etc/profiles/per-user/pungkula/bin/piper"
                    "--data-dir" "/home/pungkula/.local/share/piper"
                    "--download-dir" "/home/pungkula/.local/share/piper"
                ];
            };
        };
    };
  };}  
