# **yo-rs**

**yo-rs** is a minimal multi-client microphone audio streaming service with wake-word detection and transcription with shell command translation and execution.  
All communication is over TCP with a simple binary protocol, using RMS based VAD.  
It can be used as a full-stack voice assistant - as it has all components required.  

# **This package includes four binaries:**

- `yo-rs` – Server service
- `yo-client` – Microphone client
- `yo-do` – Natural language to shell translator
- `yo-tests` – Nix defined sentence testing

## **yo-rs (Server)**


- **Wake-word detection (ONNX)**
- **Speech-to-text (Whisper GGML)**
- **Shell command translator (yo-do)**

Options:

```
--host (default: 0.0.0.0:12345)
--shellTranslate (default: false)
--done-sound (default: done.wav)
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

## **yo-client**

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



## **yo-do**

The natural language shell translator can also be used as a standalone executable:  
 
**Example usage:**  

```bash
yo do "i want to watch show seinfeld in bedroom" 50
```

This will run the translator with a fuzzy matching threshold of 50 and would translate and execute:    

```bash
yo tv --type "tv" --search "seinfeld" --device "192.168.1.153" 
```


## **NixOS Modules**

  
[Full yo module](https://github.com/QuackHack-McBlindy/dotfiles/tree/main/modules/yo.nix)
  
  
  
<details><summary><strong>
Defining shell scripts that can be executed:
</strong></summary>

**How to define sentences**

- **Parameters:** `{param}`
- **Optional words:** `[optional|words|can|be|omitted]`
- **Required words:** `(one|of|these|words|must|be|used)`
- **Wildcard:** will match anything


Running `yo tests` will do extensive tests on all user defined sentences for conflicts and misconfigurations that would make the shell translator have issues translating.  
Running `yo --help` will display markdown rendered help for all yo scripts.  


**Example yo script with sentences:**

```nix
  yo.scripts = {   
    tv = {
      description = "Example script controlling a TV.";
      parameters = [
        { name = "type"; description = "Specify the type of command or the media type to search for"; default = "tv"; optional = true; }
        { name = "search"; type = "string"; description = "Media to search"; optional = true; }
        { name = "device"; description = "Device IP to play on"; default = "192.168.1.223"; }
        { name = "shuffle"; type = "bool"; description = "Shuffle Toggle, true or false"; default = true; }
      ];
      code = ''
        # script code goes here
      '';
      voice = {
        fuzzy.enable = true;
        fuzzy.threshold = 0.85;
        sentences = [     
          # non‑default device control
          "[I] (play|start|run|launch) [up|started] {type} {search} on {device}"
          "I want to watch {type} {search} (on|in) {device}"    
          "I want to listen to {type} on {device}"
          "I want to hear {type} {search} on {device}"
          "{type} (volume|episode|track|thing) on {device}"          
          "tv {type} on {device}"
          # default player
          "[I] (play|start|run|launch) [up|started] {type} {search}"
          "I want to watch {type} {search}"    
          "I want to listen to [my] {type}"
          "I want to hear [my] {type}"
          "{type} (volume|episode|track|thing)"       
          "tv {type}"
          # append to favorites playlist
          "save to {type}"
          "add this [song] to {type}"
          # find remote
          "call {type}"
          "find {type}"            
        ]; # lists are in‑word → out‑word
        lists = {
          type.values = [          
            { "in" = "[show|series|the series|tv series|the tv series]"; out = "tv"; }
            { "in" = "[pod|podcast|the podcast]"; out = "podcast"; }
            { "in" = "[random|shuffle|music|mix]"; out = "jukebox"; }
            { "in" = "[artist|the artist|band|the band|group|the group]"; out = "music"; }
            { "in" = "[song|the song|track|the track]"; out = "song"; }
            { "in" = "[movie|the movie|film|the film]"; out = "movie"; }
            { "in" = "[audiobook|the audiobook]"; out = "audiobook"; }
            { "in" = "[video|the video]"; out = "othervideo"; }
            { "in" = "[music video|musicvideo]"; out = "musicvideo"; }
            { "in" = "[channel|the channel]"; out = "livetv"; }
            { "in" = "[youtube|yt|y.t]"; out = "youtube"; }     
            { "in" = "[news|latest news]"; out = "news"; }                          
            { "in" = "[playlist|the playlist|favorites]"; out = "favorites"; } 
            { "in" = "[pause|stop|mute]"; out = "pause"; }
            { "in" = "[play|continue|ok]"; out = "play"; }
            { "in" = "[volume up|raise|increase]"; out = "up"; }
            { "in" = "[volume down|lower|decrease]"; out = "down"; }
            { "in" = "[next|skip|forward]"; out = "next"; }
            { "in" = "[previous|back|prev]"; out = "previous"; }                   
            { "in" = "[save|add|append]"; out = "add"; }
            { "in" = "[favorite|favorites]"; out = "add"; }     
            { "in" = "[off|turn off]"; out = "off"; }            
            { "in" = "on"; out = "on"; }                         
            { "in" = "[remote|the remote]"; out = "call"; }               
          ]; # wildcard can be anything            
          search.wildcard = true;
          device.values = [
            { "in" = "[bedroom|the bedroom]"; out = "192.168.1.153"; }
            { "in" = "[living room|the living room|livingroom]"; out = "192.168.1.223"; }    
          ];
        };
      };
```


</details>
     
  
    

[Standalone service module](https://github.com/QuackHack-McBlindy/dotfiles/tree/main/modules/yo-rs.nix)

The standalone module can be used if user does not want the yo script framework.  
This way the server/client can still be utilized and an optional --exec-command can be used for a external intent handler.  

**Minimal service configuration:**

```nix
      services.yo-rs = {
        server = {
          enable = true;
        };        
        client = {
          enable = true;
        };        
      };   
```
  
  
<details><summary><strong>
Full configuration:
</strong></summary>


```nix
      services.yo-rs = {
        server = {
          enable = true;
          host = "0.0.0.0:12345";
          shellTranslate = true;
          wakeWordPath = "/home/pungkula/dotfiles/home/.config/models/yo_bitch.onnx";
          threshold = 0.8; 
          awakeSound = "/home/pungkula/dotfiles/modules/themes/sounds/awake.wav";
          doneSound = "/home/pungkula/dotfiles/modules/themes/sounds/done.wav";          
          whisperModelPath = "/home/pungkula/models/stt/ggml-small.bin";
          language = "sv";
          beamSize = 5;
          temperature = 0.2;
          threads = 4;
          execCommand = "echo"; # Will echo "transcribed text"
        };
        
        client = {
          enable = true;
          uri = "192.168.1.111:12345";
          silenceThreshold = 0.03;
          silenceTimeout = 0.9; 
        };        
      };   
```

</details>

  
## **Protocol**

1. Wake‑word chunks – Client sends `[length (u32)] + [f32 samples]` repeatedly.

2. Detection – Server sends `0x01` when wake word is detected.

3. Transcription audio – Client sends `0x02 + [length (u32)] + [f32 samples]`.

4. Discard – Any other message type causes the server to discard the following chunk (used to skip pending wake chunks).

