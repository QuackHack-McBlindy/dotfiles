# dotfiles/bin/config/wake.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ Configures a wake word which in return triggers audio recording that will get sent for transcription.
  self, # 🦆 says ⮞ Define `"wake"` at `ccnfig.this.host.modules.services` to enable, install dependencies & start everything up at boot.
  lib,
  config,
  pkgs,
  cmdHelpers,
  ...
} : let
  # 🦆 says ⮞ dis fetch what host has Mosquitto
  sysHosts = lib.attrNames self.nixosConfigurations;
  transcriptionHost = lib.findFirst
    (host:
      let cfg = self.nixosConfigurations.${host}.config;
      in cfg.yo.scripts.transcribe.autoStart or false
    ) null sysHosts;
  transcriptionHostIP = let
    ip = if transcriptionHost != null then
      self.nixosConfigurations.${transcriptionHost}.config.this.host.ip
    else
      "0.0.0.0";
  in
    if ip == config.this.host.ip then "0.0.0.0" else ip;

  # 🦆 says ⮞ fetchez all host withat runz diz service
  wakeAutoStart = config.yo.scripts.wake.autoStart or false;
in {
  yo.scripts.wake = { # 🦆 says ⮞ dis is where my home at
    description = "Run Wake word detection for audio recording and transcription";
    category = "🗣️ Voice"; # 🦆 says ⮞ dat'z sum conditional quack-fu yo!
    #autoStart = builtins.elem config.this.host.hostname [ "desktop" "nasty" "homie" ];
    autoStart = false;
    logLevel = "DEBUG";
    parameters = [ # 🦆 says ⮞ Wake word configuration goez down here yo!
      { name = "threshold"; description = "Wake word probability thresholdn"; default = "0.85"; }
      { name = "cooldown"; description = "Set minimum ooldown period between triggers"; default = "15"; }
      { name = "sound"; description = "Sound file to play on detection"; default = config.this.user.me.dotfilesDir + "/modules/themes/sounds/awake.wav"; }
      { name = "remoteSound"; description = "Host to play the awake sound on"; default = if lib.elem config.this.host.hostname [ "nasty" "homie" ]
          then "true"
          else "false"; }
      { name = "redisHost"; description = "Redis host for distributed locking"; default = transcriptionHostIP; }
      { name = "redis_pwFIle"; description = "File path containing password for redis"; default = config.sops.secrets.redis.path; }
    ]; # 🦆 says ⮞ here we gooooo yo!
    code = ''
      ${cmdHelpers}
      WAKE_THRESHOLD="$threshold"
      WAKE_COOLDOWN="$cooldown"
      AWAKE_SOUND="$sound"
      LAST_TRIGGER_TIME=0
      REMOTE_SOUND="$remoteSound"
      REDIS_HOST="$redisHost"
      TRANSCRIPTION_HOST="$REDIS_HOST"
      TRANSCRIBE_PORT=$(nix eval .#nixosConfigurations.$HOSTNAME.config.yo.scripts.transcribe.parameters --json | jq -r '.[] | select(.name == "port") | .default')
      LOCK_TIMEOUT="$WAKE_COOLDOWN"
      LOCK_KEY="wake:lock"
      LOCK_VALUE="$HOSTNAME:$$"
      REDIS_PASSWORD=$(cat $redis_pwFile)
      dt_debug "Redis host: $REDIS_HOST, Password file: $redis_pwFile"

      # 🦆 says ⮞ measure loudness in dB
      DB_LEVEL="$(${pkgs.sox}/bin/sox "$NORMALIZED_FILE" -n stat 2>&1 | ${pkgs.gawk}/bin/awk '/RMS.*dB/ {print $4}')"
      LOG_FILE="/home/pungkula/mic.log"
      touch $LOG_FILE
      check_db() {
        # 🦆 says ⮞ check if over X dB, then do Y
        THRESHOLD_DB="-10"
        if (( $(echo "$DB_LEVEL > $THRESHOLD_DB" | ${pkgs.bc}/bin/bc -l) )); then
          echo "[LOUDNESS: ''${DB_LEVEL} dB > $THRESHOLD_DB]" >> "$LOG_FILE"
          # ${pkgs.sox}/bin/sox "$NORMALIZED_FILE" "$NORMALIZED_FILE" gain -3
        else
          echo "[LOUDNESS: ''${DB_LEVEL} dB ≤ $THRESHOLD_DB] Proceeding normally" >> "$LOG_FILE"
        fi
      }

      acquire_lock() {
        local result
        result=$(${pkgs.redis}/bin/redis-cli -h "$REDIS_HOST" -a "$REDIS_PASSWORD" SET "$LOCK_KEY" "$LOCK_VALUE" NX EX "$LOCK_TIMEOUT")
        [[ "$result" == "OK" ]]
        dt_debug "Acquired lock successfully"
      }

      release_lock() {
        ${pkgs.redis}/bin/redis-cli -h "$REDIS_HOST" -a "$REDIS_PASSWORD" EVAL \
          "if redis.call('GET', KEYS[1]) == ARGV[1] then
             return redis.call('DEL', KEYS[1])
           end
           return 0" \
          1 "$LOCK_KEY" "$LOCK_VALUE" >/dev/null
          dt_debug "Released lock successfully"
      }

      # 🦆 says ⮞ playz sound on detection
      play_wav() {
        if [ "$REMOTE_SOUND" = "true" ]; then
          curl -k https://$TRANSCRIPTION_HOST:25451/play?sound=$AWAKE_SOUND
        fi
        if [ "$REMOTE_SOUND" = "false" ]; then
          ${pkgs.alsa-utils}/bin/aplay "$AWAKE_SOUND" >/dev/null 2>&1 &
        fi
      }


      # 🦆 says ⮞ startz up a fake satellite as a background process to establish connection to openwakeword
      wakeword_connection() { # 🦆 says ⮞ requred to read da probability threashold
        ${pkgs.wyoming-satellite}/bin/wyoming-satellite \
          --name fakeSat \
          --wake-word-name yo_bitch \
          --uri tcp://0.0.0.0:10700\
          --mic-command "${pkgs.alsa-utils}/bin/arecord -r 16000 -c 1 -f S16_LE -t raw" \
          --snd-command "${pkgs.alsa-utils}/bin/aplay -r 22050 -c 1 -f S16_LE -t raw" \
          --wake-uri tcp://0.0.0.0:10400 &
        SATELLITE_PID=$!
      }

      # 🦆 says ⮞ start the connection letz uz read probability yo
      wakeword_connection

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

                  # 🦆 says ⮞ attempt to acquire distributed lock
                  if acquire_lock; then
                      # 🦆 says ⮞ put sum duck tracin' in da logz
                      dt_info "⚠️ [Wake Word] Detected! Probability: $probability."
                      current_time=$(${pkgs.coreutils}/bin/date +%s)
                      LAST_TRIGGER_TIME="$current_time"
                      # 🦆 says ⮞ play sound
                      play_wav

                      # 🦆 says ⮞ and lastly we trigger yo-mic so u can say dat intent - yo
                      TRANSCRIPTION=$(yo-mic)

                      # 🦆 says ⮞ no duckin' way! duckie don't b stoppiin' here dat'z too borin'!
                      if [[ -z "$TRANSCRIPTION" ]]; then
                        dt_debug "Empty transcription"

                      else # 🦆 says ⮞ ELSE WAT?!
                        # 🦆 says ⮞ ... ?? duck not shure waatz to do here lol
                        dt_debug "Transcribed text: $TRANSCRIPTION"
                        export VOICE_MODE=1
                        check_db
                        dt_info "yo do ⮞ $TRANSCRIPTION"
                        yo-do --input "$TRANSCRIPTION"
                        unset VOICE_MODE
                        current_time=$(${pkgs.coreutils}/bin/date +%s)
                        LAST_TRIGGER_TIME="$current_time"
                      fi

                      # 🦆 says ⮞ release da lock
                      release_lock
                  else
                      dt_info "⚠️ [LOCKED Wake Word] Detected! Probability: $probability."
                  fi
              fi
          fi
      done < <(${pkgs.systemd}/bin/journalctl -u wyoming-openwakeword -f -n 0)
    '';
  };

  # 🦆 says ⮞ duckz hatez rulez - but dat firewall rulez iz all good yo
  networking.firewall = lib.mkIf wakeAutoStart { allowedTCPPorts = [ 10400 10700 ]; };

  # 🦆 says ⮞ dependencies
  environment.systemPackages = lib.mkIf wakeAutoStart [
    pkgs.wyoming-openwakeword
    pkgs.redis
    pkgs.wyoming-satellite
    pkgs.alsa-utils
  ];

  services.wyoming.openwakeword = lib.mkIf wakeAutoStart {
    enable = true;
    uri = "tcp://0.0.0.0:10400";
    #preloadModels = [ "yo_bitch" ]; # 🦆 says ⮞ mature....
    customModelsDirectories = [ "/etc/openwakeword" ];
    threshold = 0.8; # 🦆 says ⮞ dooz not really matter since we run fake sat yo
    triggerLevel = 1;
    extraArgs = [ "--debug" "--debug-probability" ]; # 🦆 says ⮞ ooof.. can't touch diz - we use diz to read dem' values yo
  };} # 🦆 says ⮞ sleep tight & wake up wen 🦆 says ⮞ YO BIAAATCH !!111
# 🦆 says ⮞ QuackHack-McBLindy out!
# ... 🛌🦆💤
