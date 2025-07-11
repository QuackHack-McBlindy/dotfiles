# dotfiles/bin/config/wake.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ Configures a wake word which in return triggers audio recording that will get sent for transcription.  
  self, # 🦆 says ⮞ Define `"wake"` at `ccnfig.this.host.modules.services` to enable, install dependencies & start everything up at boot.
  lib,
  config,
  pkgs,
  cmdHelpers,
  ... 
} : let # 🦆 says ⮞ fetchez all host withat runz diz service
  wakeAutoStart = config.yo.scripts.wake.autoStart or false;
  # 🦆 says ⮞ host to playback mappin' yo
  remoteSoundHost = {
    homie   = "desktop";
    nasty   = "desktop";
  }.${config.this.host.hostname} or config.this.host.hostname; # 🦆 says ⮞ fallback to play awake sound locally
in { 
  yo.scripts.wake = { # 🦆 says ⮞ dis is where my home at
    description = "Run Wake word detection for audio recording and transcription";
    category = "⚙️ Configuration"; # 🦆 says ⮞ dat'z sum conditional quack-fu yo!
    autoStart = builtins.elem config.this.host.hostname [ "desktop" "nasty" "homie" ];
    logLevel = "INFO";
    parameters = [ # 🦆 says ⮞ Wake word configuration goez down here yo!
      { name = "threshold"; description = "Wake word probability thresholdn"; default = "0.8"; }
      { name = "cooldown"; description = "Set minimum ooldown period between triggers"; default = "30"; }
      { name = "sound"; description = "Sound file to play on detection"; default = config.this.user.me.dotfilesDir + "/modules/themes/sounds/awake.wav"; }
      { name = "remoteSound"; description = "Host to play the awake sound on"; default = remoteSoundHost; }
    ]; # 🦆 says ⮞ here we gooooo yo!
    code = ''
      ${cmdHelpers}
      WAKE_THRESHOLD="$threshold"
      WAKE_COOLDOWN="$cooldown"
      AWAKE_SOUND="$sound"
      LAST_TRIGGER_TIME=0
      REMOTE_SOUND="$remoteSound"

      # 🦆 says ⮞ playz sound on detection

      play_wav() {
        if [ "$REMOTE_SOUND" = "$HOSTNAME" ]; then
          ${pkgs.alsa-utils}/bin/aplay "$AWAKE_SOUND" >/dev/null 2>&1 &
        else
          ${pkgs.openssh}/bin/ssh -o ConnectTimeout=3 "$REMOTE_SOUND" \
            ${pkgs.alsa-utils}/bin/aplay "$AWAKE_SOUND" >/dev/null 2>&1 &
        fi
      }
      
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

      # 🦆 says ⮞ audio device reset function
      reset_audio() {
        ${pkgs.alsa-utils}/bin/alsactl restore >/dev/null 2>&1
        sleep 0.5
      }

      # 🦆 says ⮞ start the connection letz uz read probability yo
      wakeword_connection
      reset_audio      
      # 🦆 says ⮞ monitor da logz for detection yo
      while read -r line; do
        # 🦆 says ⮞ monitor wake word probability.. 
        if [[ $line =~ probability=([0-9]+\.[0-9]+) ]]; then
              # 🦆 says ⮞ .. check defined threshold
              probability="''${BASH_REMATCH[1]}"    
              # 🦆 says ⮞ ... & current time
              current_time=$(${pkgs.coreutils}/bin/date +%s)
              # 🦆 says ⮞ ... calculate time difference between last trigger & current time
              time_diff=$((current_time - LAST_TRIGGER_TIME))
              # 🦆 says ⮞ ... compare threshold and cooldown
              awk_comparison=$(${pkgs.gawk}/bin/awk -v p="$probability" -v t="$WAKE_THRESHOLD" 'BEGIN { print (p > t) ? 1 : 0 }')
              
              # 🦆 says ⮞ all checkz out ok?
              if [[ "$awk_comparison" -eq 1 && "$time_diff" -gt "$WAKE_COOLDOWN" ]]; then
                  dt_debug "Cooldown check: diff=$time_diff, last=$LAST_TRIGGER_TIME, now=$current_time"
                  # 🦆 says ⮞ TRIGGERED YO!!1
                  # 🦆 says ⮞ set last trigger time to now
                  LAST_TRIGGER_TIME="$current_time"
                  TIME_FORMATTED=$(${pkgs.coreutils}/bin/date +"%H:%M:%S")
                  # 🦆 says ⮞ put sum duck tracin' in da logz 
                  dt_info "⚠️ [Wake Word] Detected! Probability: $probability."
                  # 🦆 says ⮞ play sound
                  play_wav
                  # 🦆 says ⮞ and lastly we trigger yo-mic so u can say dat intent - yo
                  TRANSCRIPTION=$(yo-mic)
                
                  # 🦆 says ⮞ no duckin' way! duckie don't b stoppiin' here dat'z too borin'!                 
                  if [[ -z "$TRANSCRIPTION" ]]; then
                    dt_debug "Empty transcription"
                    LAST_TRIGGER_TIME=$((current_time - WAKE_COOLDOWN + 5))
                  else # 🦆 says ⮞ ELSE WAT?!
                    # 🦆 says ⮞ ... ?? duck not shure waatz to do here lol          
                    # 🦆 says ⮞ clean it up, trim it down, remove stuffz, collapz stuffz and lowercase shit upside-down - it'z all done from yo-mic
                    # 🦆 says ⮞ trace it - log it or dump it - i don't rly care                  
                    dt_debug "Transcribed text: $TRANSCRIPTION"
                    # 🦆 says ⮞ ok had enuff - say bai bai
                    export VOICE_MODE=1
                    # 🦆 says ⮞ yo bitch! take care of diz shit!
                    dt_info "yo bitch ⮞ $TRANSCRIPTION"
                    yo-bitch --input "$TRANSCRIPTION" &
                    # 🦆 says ⮞ nlp.nix take it from here yo
                    unset $VOICE_MODE
                  fi                                
              fi
          fi
      done < <(${pkgs.systemd}/bin/journalctl -u wyoming-openwakeword -f -n 0)  
      dt_error "Wake loop terminated! Restarting in 5 seconds..."
      kill $SATELLITE_PID >/dev/null 2>&1
      sleep 5
    '';
  };

  # 🦆 says ⮞ duckz hatez rulez - but dat firewall rulez iz all good yo
  networking.firewall = lib.mkIf wakeAutoStart { allowedTCPPorts = [ 10400 10700 ]; };
    
  # 🦆 says ⮞ dependencies
  environment.systemPackages = lib.mkIf wakeAutoStart [
    pkgs.wyoming-openwakeword
    pkgs.wyoming-satellite
    pkgs.alsa-utils  
  ];  
  
  # 🦆 says ⮞ How do I change this lib.mkIf statement to use if wakeAutoStart is true instead?
  services.wyoming.openwakeword = lib.mkIf wakeAutoStart {
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
