# **yo-rs**

**yo-rs** is a multi-client microphone audio streaming service with wake-word detection and transcription with shell command translation and execution.  
All communication is over TCP with a simple binary protocol, using RMS based VAD.  
**yo-rs** can be used as a full-stack voice assistant - as it has all the required components.  

# **This package includes four binaries:**

- `yo-rs` – Server service
- `yo-client` – Microphone client
- `yo-do` – Natural language to shell translator
- `yo-tests` – Nix defined sentence testing

## **yo-rs (Server)**


- **Wake-word detection (ONNX)**
- **Text-to-speech generator (Piper ONNX)**
- **Speech-to-text (Whisper GGML)**
- **Shell command translator (Nix defined sentences)**
  
Everything neatly handled on a aingle port.   


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
--exec-command (oefault: none)
--tts-model (default: amy_enUS-medium.onnx)
--debug	(default: false)
--help, -h
```

## **yo-client**

1. **Streams microphone audio to the server for wake‑word detection** 
2. **On detection, records audio until silence (RMS‑based) or a maximum duration**
3. **Sends the recorded audio to the server for transcription**
4. **Waits for server response (success/failure), plays sounds and executes optional commands**
5. **Streams microphone audio for wake‑word detection again** 
 
 
Options:

```
--uri (default: 127.0.0.1:12345)
--awake-sound (default: embedded ding.wav)
--done-sound (default: embedded done.wav)
--fail-sound (default: embedded fail.wav)
--awake-cmd (optional)
--done-cmd (optional)
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


Go nuts if you want.    
  
<details><summary><strong>
🦆 Ducks are not FBI! Anything is allowed..
</strong></summary>



```nix
voice = {
  priority = 1;
  sentences = [
    # 🦆 says ⮞ multi taskerz
    "{device} {state} i {room} och [ändra] färg[en] [till] {color} [och] ljusstyrka[n] [till] {brightness} procent"
    "{device} {state} och ljusstyrka {brightness} procent"
    "(gör|ändra) {device} [till] {color} [färg] [och] {brightness} procent [ljusstyrka]"
    "{scene} alla lampor"
    "{scene} (belysning|belysningen)"
    "{slate} alla lampor i {device}"
    "{state} {device} (lampor|igen)"
    "{state} lamporna i {device}"
    "stäng {state} {device}"
    "starta {state} {device}"
    # 🦆 says ⮞ english multi taskerz
    "turn {device} {state} in the {room} and (change|set) color to {color} and brightness to {brightness} percent"
    "set {device} {state} and brightness to {brightness} percent"
    "(make|set) {device} {color} and {brightness} percent"
    "{scene} all lights"
    "{scene} the (lighting|lights)"
    "{slate} all lights in {device}"
    "turn {state} {device}"
    "turn {state} the lights in {device}"
    "set {device} {state}"
    "activate {device} {state}"
    # 🦆 says ⮞ color control
    "(ändra|gör) färgen [på|i] {device} till {color}"
    "(ändra|gör) {device} {color}"
    # 🦆 says ⮞ english color control
    "(change|set) the color of {device} to {color}"
    "(change|set) {device} to {color}"
    # 🦆 says ⮞ pairing mode
    "{pair} [ny|nya] [zigbee] (enhet|enheter)"
    # 🦆 says ⮞ english pairing mode
    "{pair} [new] [zigbee] (device|devices)"
    # 🦆 says ⮞ brightness control
    "justera {device} till {brightness} procent"
    # 🦆 says ⮞ english brightness control
    "adjust {device} to {brightness} percent"
    "set {device} brightness to {brightness} percent"
  ];

  lists = {
    state.values = [
      # 🦆 says ⮞ swedish ON
      { "in" = "[tänd|tända|tänk|start|starta|på|tönd|tömd]"; out = "ON"; }
      # 🦆 says ⮞ swedish OFF
      { "in" = "[släck|släcka|slick|av|stäng|stäng av]"; out = "OFF"; }
      # 🦆 says ⮞ english ON
      { "in" = "[on|turn on|switch on|activate]"; out = "ON"; }
      # 🦆 says ⮞ english OFF
      { "in" = "[off|turn off|switch off|deactivate]"; out = "OFF"; }
    ];

    brightness.values = builtins.genList (i: {
      "in" = toString (i + 1);
      out = toString (i + 1);
    }) 100;

    device.values = let
      reservedNames = [ "hall" "kitchen" "bedroom" "bathroom" "wc" "livingroom" "kitchen" "switch" "all" "every" ];
      sanitize = str:
        lib.replaceStrings [ "/" " " ] [ "" "_" ] str;

      # 🦆 says ⮞ natural Swedish patterns
      swedishPatterns = base: baseRaw: [
        base
        "${baseRaw}n"
        "${baseRaw}t"
        "${baseRaw}en"
        "${baseRaw}et"
        "${baseRaw}ar"
        "${baseRaw}or"
        "${baseRaw}er"
        "${baseRaw}na"
        "${baseRaw}orna"
        "${baseRaw}erna"
        "${baseRaw}lampan"
        "${baseRaw}lampor"
        "${baseRaw}lamporna"
        "${baseRaw}ljus"
        "${baseRaw}lamp"
      ];

      # 🦆 says ⮞ natural English patterns
      englishPatterns = base: baseRaw: [
        base
        "the ${baseRaw}"
        "${baseRaw} light"
        "the ${baseRaw} light"
        "${baseRaw} lamp"
        "the ${baseRaw} lamp"
        "${baseRaw} lights"
        "the ${baseRaw} lights"
      ];
    in [
      { "in" = "[vardagsrum|vardagsrummet|stora rummet|förrum|living room|livingroom]"; out = "livingroom"; }
      { "in" = "[kök|köket|kitchen]"; out = "kitchen"; }
      { "in" = "[sovrum|sovrummet|sängkammaren|sovrummet|bedroom]"; out = "bedroom"; }
      { "in" = "[badrum|badrummet|toaletten|wc|bathroom|toilet]"; out = "bathroom"; }
      { "in" = "[hall|hallen|korridor|korridoren|hallway]"; out = "hallway"; }
      { "in" = "[alla|allting|allt|alla lampor|varje lampa|all|every|all lights|every light]"; out = "ALL_LIGHTS"; }
    ] ++
    (lib.filter (x: x != null) (
      lib.mapAttrsToList (_: device:
        let
          baseRaw = lib.toLower device.friendly_name;
          base = sanitize baseRaw;
          baseWords = lib.splitString " " base;
          isAmbiguous = lib.any (word: lib.elem word reservedNames) baseWords;

          swedishVariations = lib.unique (swedishPatterns base baseRaw);
          englishVariations = lib.unique (englishPatterns base baseRaw);

          variations = lib.unique (
            [
              base
              (sanitize (lib.replaceStrings [ " " ] [ "" ] base))
              (lib.replaceStrings [ "_" ] [ " " ] base)
            ] ++ swedishVariations ++ englishVariations
          );
        in if isAmbiguous then null else {
          "in" = "[" + lib.concatStringsSep "|" variations + "]";
          out = device.friendly_name;
        }
      ) zigbeeDevices
    ));

    color.values = [
      # 🦆 says ⮞ swedish colors
      { "in" = "[röd|rött|röda]"; out = "red"; }
      { "in" = "[grön|grönt|gröna]"; out = "green"; }
      { "in" = "[blå|blått|blåa]"; out = "blue"; }
      { "in" = "[gul|gult|gula]"; out = "yellow"; }
      { "in" = "[orange|orangefärgad|orangea]"; out = "orange"; }
      { "in" = "[lila|lilla|violett|violetta]"; out = "purple"; }
      { "in" = "[rosa|rosafärgad|rosaaktig]"; out = "pink"; }
      { "in" = "[vit|vitt|vita]"; out = "white"; }
      { "in" = "[svart|svarta]"; out = "black"; }
      { "in" = "[grå|grått|gråa]"; out = "gray"; }
      { "in" = "[brun|brunt|bruna]"; out = "brown"; }
      { "in" = "[cyan|cyanblå|turkosblå]"; out = "cyan"; }
      { "in" = "[magenta|cerise|fuchsia]"; out = "magenta"; }
      { "in" = "[turkos|turkosgrön]"; out = "turquoise"; }
      { "in" = "[teal|blågrön]"; out = "teal"; }
      { "in" = "[lime|limegrön]"; out = "lime"; }
      { "in" = "[maroon|mörkröd]"; out = "maroon"; }
      { "in" = "[oliv|olivgrön]"; out = "olive"; }
      { "in" = "[navy|marinblå]"; out = "navy"; }
      { "in" = "[lavendel|ljuslila]"; out = "lavender"; }
      { "in" = "[korall|korallröd]"; out = "coral"; }
      { "in" = "[guld|guldfärgad]"; out = "gold"; }
      { "in" = "[silver|silverfärgad]"; out = "silver"; }
      { "in" = "[slumpmässig|random|valfri färg]"; out = "random"; }
      # 🦆 says ⮞ english colors
      { "in" = "[red]"; out = "red"; }
      { "in" = "[green]"; out = "green"; }
      { "in" = "[blue]"; out = "blue"; }
      { "in" = "[yellow]"; out = "yellow"; }
      { "in" = "[orange]"; out = "orange"; }
      { "in" = "[purple|violet]"; out = "purple"; }
      { "in" = "[pink]"; out = "pink"; }
      { "in" = "[white]"; out = "white"; }
      { "in" = "[black]"; out = "black"; }
      { "in" = "[gray|grey]"; out = "gray"; }
      { "in" = "[brown]"; out = "brown"; }
      { "in" = "[cyan]"; out = "cyan"; }
      { "in" = "[magenta]"; out = "magenta"; }
      { "in" = "[turquoise]"; out = "turquoise"; }
      { "in" = "[teal]"; out = "teal"; }
      { "in" = "[lime]"; out = "lime"; }
      { "in" = "[maroon]"; out = "maroon"; }
      { "in" = "[olive]"; out = "olive"; }
      { "in" = "[navy]"; out = "navy"; }
      { "in" = "[lavender]"; out = "lavender"; }
      { "in" = "[coral]"; out = "coral"; }
      { "in" = "[gold]"; out = "gold"; }
      { "in" = "[silver]"; out = "silver"; }
      { "in" = "[random|any]"; out = "random"; }
    ];

    temperature.values = builtins.genList (i: {
      "in" = toString (i + 153);
      out = toString (i + 153);
    }) 347; # 153-500

    scene.values = let
      reservedSceneNames = [ "max" "dark" "off" "on" "all" "every" ];
      sanitizeScene = str:
        lib.toLower (lib.replaceStrings [ " " "-" "_" ] [ "" "" "" ] str);

      # 🦆 says ⮞ natural Swedish scene patterns
      swedishScenePatterns = base: baseRaw: [
        base
        "${baseRaw}n"
        "${baseRaw}t"
        "${baseRaw}en"
        "${baseRaw}et"
        "${baseRaw} scen"
        "${baseRaw} scenen"
        "${baseRaw} läge"
        "${baseRaw} läget"
      ];

      # 🦆 says ⮞ natural English scene patterns
      englishScenePatterns = base: baseRaw: [
        base
        "the ${baseRaw}"
        "${baseRaw} scene"
        "the ${baseRaw} scene"
        "${baseRaw} mode"
        "the ${baseRaw} mode"
      ];
    in [
      # 🦆 says ⮞ scenes swedish/english
      { "in" = "[tänd||tänk|max|maxa|maxxa|maxad|maximum|on]"; out = "max"; }
      { "in" = "[på|tänd|aktiv|on|active]"; out = "max"; }

      { "in" = "[mörk|mörker|mörkt|släckt|avstängd|dark|off]"; out = "dark"; }
      { "in" = "[av|släck|släckt|stängd|stäng|off|turn off]"; out = "dark"; }

      { "in" = "[mys|myspys|mysig|chill|chilla|cozy|relax]"; out = "Chill Scene"; }
    ] ++
    (lib.mapAttrsToList (sceneId: sceneConfig:
      let
        baseRaw = lib.toLower sceneConfig.friendly_name or sceneId;
        base = sanitizeScene baseRaw;
        baseWords = lib.splitString " " base;
        isAmbiguous = lib.any (word: lib.elem word reservedSceneNames) baseWords;

        swedishVariations = if isAmbiguous then [] else lib.unique (swedishScenePatterns base baseRaw);
        englishVariations = if isAmbiguous then [] else lib.unique (englishScenePatterns base baseRaw);

        variations = lib.unique (
          [
            base
            (sanitizeScene (lib.replaceStrings [ " " ] [ "" ] base))
            (lib.replaceStrings [ "_" "-" ] [ " " " " ] base)
            sceneId
          ] ++ swedishVariations ++ englishVariations
        );
      in {
        "in" = "[" + lib.concatStringsSep "|" variations + "]";
        out = sceneId;
      }
    ) scenes);

    # 🦆 says ⮞ pairin' new devices! (pair = sex?)
    pair.values = [
      { "in" = "[para|paras|pair|pair new]"; out = "true"; }
    ];

    # 🦆 says ⮞ hardcoded room names
    room.values = [
      { "in" = "[kök|köket|kitchen]"; out = "kitchen"; }
      { "in" = "[vardagsrum|vardagsrummet|living room|livingroom]"; out = "livingroom"; }
      { "in" = "[sovrum|sovrummet|bedroom]"; out = "bedroom"; }
      { "in" = "[badrum|badrummet|wc|toilet|bathroom]"; out = "wc"; }
      { "in" = "[hall|hallen|hallway]"; out = "hallway"; }
    ];
  };
};
```

  
</details>




<details><summary><strong>
🦆 FBI quack? (assertions)
</strong></summary>


```nix
      runAtErrors = lib.mapAttrsToList (name: script:
        if script.runAt != null then
          let
            missingParams = lib.filter (p: !p.optional && p.default == null) script.parameters;
          in
            if missingParams != [] then
              "🦆 duck say ⮞ fuck ❌ Cannot schedule '${name}' at ${script.runAt} - missing defaults for: " +
              lib.concatMapStringsSep ", " (p: p.name) missingParams
            else null
        else null
      ) scripts;
      actualRunAtErrors = lib.filter (e: e != null) runAtErrors;
            
      # 🦆 duck say ⮞ quackin' flappin' mappin' aliasez ⮞ script dat belong to it 
      aliasMap = lib.foldl' (acc: script:
        lib.foldl' (acc': alias:
          acc' // { 
            ${alias} = (acc'.${alias} or []) ++ [script.name]; # 🦆 duck say ⮞ mmerge or start a list yo
          }
        ) acc script.aliases
      ) {} (attrValues scripts);
      # 🦆 duck say ⮞ find conflicts between script names & script aliases
      scriptNameConflicts = lib.filterAttrs (alias: _: lib.elem alias scriptNames) aliasMap;  
      # 🦆 duck say ⮞ find dem' double aliasez 
      duplicateAliases = lib.filterAttrs (_: scripts: lib.length scripts > 1) aliasMap;
      # 🦆 duck say ⮞ build da alias conflict error msg
      formatConflict = alias: scripts: 
        "Alias '${alias}' conflicts with script name (used by: ${lib.concatStringsSep ", " scripts})";       
      # 🦆 duck say ⮞ build da double rainbowz error msg yo
      formatDuplicate = alias: scripts: 
        "Alias '${alias}' used by multiple scripts: ${lib.concatStringsSep ", " scripts}";
      # 🦆 duck say ⮞ find auto-start scriptz - if i find i make sure it haz default values for all required paramz
      autoStartErrors = lib.mapAttrsToList (name: script:
        if script.autoStart then
          let # 🦆 duck say ⮞ filter dem not optional no defaultz
            missingParams = lib.filter (p: !p.optional && p.default == null) script.parameters;
          in
            if missingParams != [] then
              "🦆 duck say ⮞ fuck ❌ Cannot auto-start '${name}' - missing defaults for: " +
              lib.concatMapStringsSep ", " (p: p.name) missingParams
            else null
        else null
      ) scripts;    
      
      nonInteractiveErrors = lib.mapAttrsToList (name: script:
        if script.autoStart || script.runEvery != null then
          let
            missingParams = lib.filter (p: !p.optional && p.default == null) script.parameters;
          in
            if missingParams != [] then
              "🦆 duck say ⮞ fuck ❌ Cannot schedule '${name}' - missing defaults for: " +
              lib.concatMapStringsSep ", " (p: p.name) missingParams
            else null
        else null
      ) scripts;      
      # 🦆 duck say ⮞ clean out dem' nullz! no nullz in ma ASSertionthz! ... quack
      actualAutoStartErrors = lib.filter (e: e != null) autoStartErrors;   
      # 🦆 duck say ⮞ Validate da shit out of 'value' option quack! only allowed wit string type yo!
      valueTypeErrors = lib.concatMap (script:
        lib.concatMap (param:
          if param.values != null && param.type != "string" then
            [ "🦆 duck say ⮞ fuck ❌ Parameter '${param.name}' in script '${script.name}' has 'value' defined but type is '${param.type}' (only 'string' type allowed)" ]
          else []
        ) script.parameters
      ) (lib.attrValues scripts);
    in [
      { # 🦆 duck say ⮞ assert no alias name cpmflict with script name 
        assertion = scriptNameConflicts == {};
        message = "🦆 duck say ⮞ fuck ❌ Alias/script name conflicts:\n" +
          lib.concatStringsSep "\n" (lib.mapAttrsToList formatConflict scriptNameConflicts);
      }
      { # 🦆 duck say ⮞ make sure dat aliases unique are yo
        assertion = duplicateAliases == {};
        message = "🦆 duck say ⮞ fuck ❌ Duplicate aliases:\n" +
          lib.concatStringsSep "\n" (lib.mapAttrsToList formatDuplicate duplicateAliases);
      }
      { # 🦆 duck say ⮞ autoStart scriptz must be fully configured of course!
        assertion = actualAutoStartErrors == [];
        message = "Auto-start errors:\n" + lib.concatStringsSep "\n" actualAutoStartErrors;
      }  
      { # 🦆 duck say ⮞ runAt script fully configured?
        assertion = actualRunAtErrors == [];
        message = "runAt scheduling errors:\n" + lib.concatStringsSep "\n" actualRunAtErrors;
      }      
      { # 🦆 duck say ⮞ runEvery OR runAt NOT BOTH
        assertion = lib.all (script: 
          !(script.runEvery != null && script.runAt != null)
        ) (lib.attrValues scripts);
        message = "🦆 duck say ⮞ fuck ❌ Script cannot have both runEvery and runAt set";
      }
      { # 🦆 duck say ⮞ value option only 4 strings i said!
        assertion = valueTypeErrors == [];
        message = "Value type errors:\n" + lib.concatStringsSep "\n" valueTypeErrors;
      }
    ];
```

**He usually makes me feel safe**

  
</details>
  
  
  
See `examples/` for more example usage.  

  
</details>
     

<br><br><br>
    

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
Full service configuration:
</strong></summary>


```nix
      services.yo-rs = {
        server = {
          enable = true;
          host = "0.0.0.0:12345";
          shellTranslate = true;
          wakeWordPath = "/home/pungkula/dotfiles/home/.config/models/yo_bitch.onnx";
          threshold = 0.8; 
          awakeSound = "/path/to/custom/awake.wav";
          doneSound = "/path/to/custom/done.wav";
          failSound = "/path/to/custom/fail.wav";        
          whisperModelPath = "/home/pungkula/models/stt/ggml-small.bin";
          textToSpeechModelPath = "/home/pungkula/models/tts/lisa_svSE-medium.onnx";
          language = "sv";
          beamSize = 5;
          temperature = 0.2;
          threads = 4;
          execCommand = "echo"; # Will echo "transcribed text"
          debug = true;
          logFile = "/home/pungkula/.config/duckTrace/yo-rs-server.log";
        };
        
        client = {
          enable = true;
          uri = "192.168.1.111:12345";
          awakeSound = "/path/to/custom/awake.wav";
          doneSound = "/path/to/custom/done.wav";
          failSound = "/path/to/custom/fail.wav";
          awakeCmd = "notify-send 'Wake word detected'";
          doneCmd = "mpg123 /path/to/success.mp3"; 
          silenceThreshold = 0.03;
          silenceTimeout = 0.9; 
          debug = true;
          logFile = "/home/pungkula/.config/duckTrace/yo-rs-client.log";          
        };        
      };   
```

</details>

  
## **Protocol**

1. Wake‑word chunks – Client sends `[length (u32)] + [f32 samples]` repeatedly.

2. Detection – Server sends `0x01` when wake word is detected.

3. Transcription audio – Client sends `0x02 + [length (u32)] + [f32 samples]`.

4. Success notification – server sends `0x03` after successful command execution.

5. Failure notification – server sends `0x04` if the command fails.

6. Discard – Any other message type causes the server to discard the following chunk (used to skip pending wake chunks).

