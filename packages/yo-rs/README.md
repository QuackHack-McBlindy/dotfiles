# **yo-rs**

**yo-rs** is a minimal multi-client microphone audio streaming service with wake-word detection and transcription with optional shell command execution with the transcribed text as argument.  
All communication is over TCP with a simple binary protocol, using RMS based VAD.  


# **This package includes two binaries:**

## **yo-rs (Server)**


- **Wake-word detection (ONNX)**
- **Speech-to-text (Whisper GGML)**
- **Optional: execute external command with transcribed text**

Options:

```
--host (default: 0.0.0.0:12345)
--awake-sound (default: ding.wav)
--wake-word (default: yo_bitch.onnx)
--threshold (default: 0.5)
--model (default: ggml-tiny.bin)
--beam-size (default: 5, 0 = greedy)
--temperature (default: 0.2)
--language (default: en)
--threads (default: 4)
--exec-command (optional)
--debug	(default: false)
--help, -h
```

# **yo-client**

1. **Streams microphone audio to the server for wake‑word detection** 
2. **On detection, records audio until silence (RMS‑based) or a maximum duration**
3. **Sends the recorded audio to the server for transcription**
4. **Streams microphone audio for wake‑word detection again** 
 
Options:

```
--uri (default: 127.0.0.1:12345)
--silence-threshold (default: 0.005)
--silence-timeout (default: 1.0)
--max-duration (default: 5.0)
--debug (default: false)
--help, -h
```


## **NixOS Module**

[Use this module](https://github.com/QuackHack-McBlindy/dotfiles/tree/main/modules/yo-rs.nix)

**Example configuration:**

```nix
      services.yo-rs = {
        server = {
          enable = true;
          host = "0.0.0.0:12345";
          execCommand = "myScript.sh"; # Will exec: myScript.sh "transcribed text"
          wakeWordPath = "/home/pungkula/dotfiles/home/.config/models/yo_bitch.onnx";
          threshold = 0.8; 
          awakeSound = "/home/pungkula/dotfiles/modules/themes/sounds/awake.wav";
          whisperModelPath = "/home/pungkula/models/stt/ggml-small.bin";
          language = "sv";
          beamSize = 5;
          temperature = 0.2;
          threads = 4;
        };
        
        client = {
          enable = true;
          uri = "192.168.1.111:12345";
          silenceThreshold = 0.03;
          silenceTimeout = 0.9; 
        };        
      };   
```


## **Protocol**

1. Wake‑word chunks – Client sends `[length (u32)] + [f32 samples]` repeatedly.

2. Detection – Server sends `0x01` when wake word is detected.

3. Transcription audio – Client sends `0x02 + [length (u32)] + [f32 samples]`.

4. Discard – Any other message type causes the server to discard the following chunk (used to skip pending wake chunks).


