# dotfiles/bin/config/wake.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ Configures a wake word which in return triggers audio recording that will get sent for transcription.  
  self, # 🦆 says ⮞ Define `"wake"` at `ccnfig.this.host.modules.services` to enable, install dependencies & start everything up at boot.
  lib,
  config,
  pkgs,
  cmdHelpers,
  ... 
} : let # 🦆 says ⮞ let ...
in { # 🦆 says ⮞ .. nuthin' in?
# 🦆 says ⮞ dat'z strange... but ok yo
  yo.scripts.wake = { # 🦆 says ⮞ dis is where my home at
    description = "Run Wake word detection for audio recording and transcription";
    category = "⚙️ Configuration"; # 🦆 says ⮞ dat'z sum conditional quack-fu yo!
    autoStart = config.this.host.hostname == "desktop";
#    helpFooter = '' # 🦆 says ⮞ TODO some fun & useful helpFooter - think, think, tink.. 
#      WIDTH=100
#      cat <<EOF | ${pkgs.glow}/bin/glow --width $WIDTH -
## ──────⋆⋅☆⋅⋆────── ##
#EOF
##    '';
    logLevel = "DEBUG";
    parameters = [ # 🦆 says ⮞ Wake word configuration goez down here yo!
      { name = "threshold"; description = "Wake word probability thresholdn"; default = "0.8"; }
      { name = "cooldown"; description = "Set minimum ooldown period between triggers"; default = "20"; }
      { name = "sound"; description = "Sound file to play on detection"; default = config.this.user.me.dotfilesDir + "/modules/themes/sounds/awake.wav";  } 
    ]; # 🦆 says ⮞ here we gooooo yo!
    code = ''
      ${cmdHelpers}
      WAKE_THRESHOLD="$threshold"
      WAKE_COOLDOWN="$cooldown"
      AWAKE_SOUND="$sound"
      LAST_TRIGGER_TIME=0

      # 🦆 says ⮞ startz up a fake satellite as a background process to establish connection to openwakeword 
      wakeword_connection() { # 🦆 says ⮞ requred to read da probability threashold
        ${pkgs.wyoming-satellite}/bin/wyoming-satellite \
          --name fakeSat \
          --uri tcp://0.0.0.0:10700\
          --mic-command "${pkgs.alsa-utils}/bin/arecord -r 16000 -c 1 -f S16_LE -t raw" \
          --snd-command "${pkgs.alsa-utils}/bin/aplay -r 22050 -c 1 -f S16_LE -t raw" \
          --wake-uri tcp://0.0.0.0:10400 &
        SATELLITE_PID=$!            
      }      
      # 🦆 says ⮞ playz sound on detection
      play_wav() {
        ${pkgs.alsa-utils}/bin/aplay "$AWAKE_SOUND" >/dev/null 2>&1
      }
      # 🦆 says ⮞ start the connection letz uz read probability yo
      wakeword_connection
      
      # 🦆 says ⮞ monitor da logz for detection yo
#      ${pkgs.systemd}/bin/journalctl -u wyoming-openwakeword -f -n 0 | while read -r line; do
      prev_line=""
      while read -r line; do
        # Skip duplicate lines
        if [[ "$line" == "$prev_line" ]]; then
            continue
        fi
        prev_line="$line"
    
        if [[ $line =~ probability=([0-9]+\.[0-9]+) ]]; then
            probability="''${BASH_REMATCH[1]}"    
            current_time=$(${pkgs.coreutils}/bin/date +%s)
            time_diff=$((current_time - LAST_TRIGGER_TIME))
        
            # Handle potential clock changes
            if (( time_diff < 0 )); then
                time_diff=WAKE_COOLDOWN+1
            fi
        
            awk_comparison=$(${pkgs.gawk}/bin/awk -v p="$probability" -v t="$WAKE_THRESHOLD" 'BEGIN { print (p > t) ? 1 : 0 }')
        
            if [[ "$awk_comparison" -eq 1 && "$time_diff" -gt "$WAKE_COOLDOWN" ]]; then
                LAST_TRIGGER_TIME="$current_time"
                dt_info "⚠️ [Wake Word] Detected! Probability: $probability"
                play_wav "$AWAKE_SOUND"
                TRANSCRIPTION=$(yo-mic)
            
                if [[ -z "$TRANSCRIPTION" ]]; then
                    dt_debug "Empty transcription"
                else
                    dt_debug "Transcribed text: $TRANSCRIPTION"
                    export VOICE_MODE=1
                    dt_info "yo bitch ⮞ $TRANSCRIPTION"
                    yo-bitch --input "$TRANSCRIPTION"
                    unset VOICE_MODE
                fi
            else
                dt_debug "Ignored detection (cooldown: $time_diff/$WAKE_COOLDOWN s, prob: $probability)"
            fi
        fi
      done < <(${pkgs.systemd}/bin/journalctl -u wyoming-openwakeword -f -n 0)
    '';
  };

  # 🦆 says ⮞ duckz hatez rulez - but dat firewall rulez iz all good yo
  networking.firewall = lib.mkIf (lib.elem "wake" config.this.host.modules.services) { allowedTCPPorts = [ 10400 10700 ]; };
    
  # 🦆 says ⮞ dependencies
  environment.systemPackages = lib.mkIf (lib.elem "wake" config.this.host.modules.services) [
    pkgs.wyoming-openwakeword
    pkgs.wyoming-satellite
    pkgs.alsa-utils  
  ];  
  
  # 🦆 says ⮞ hero of da day
  services.wyoming.openwakeword = lib.mkIf (lib.elem "wake" config.this.host.modules.services) { # 🦆 says ⮞ again -- server config on single host
    enable = true;
    uri = "tcp://0.0.0.0:10400";
    preloadModels = [ "yo_bitch" ]; # 🦆 says ⮞ mature....
    customModelsDirectories = [ "/etc/openwakeword" ];
    threshold = 0.8; # 🦆 says ⮞ dooz not really matter since we run fake sat yo
    triggerLevel = 1;
    extraArgs = [ "--debug" "--debug-probability" ]; # 🦆 says ⮞ ooof.. can't touch diz - we use diz to read dem' values yo 
  };} # 🦆 says ⮞ sleep tight & wake up wen 🦆 says ⮞ YO BIAAATCH !!111 
# 🦆 says ⮞ QuackHack-McBLindy out!
# ... 🛌🦆💤
