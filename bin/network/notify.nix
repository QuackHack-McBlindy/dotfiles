# dotfiles/bin/network/notify.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ Notification System with true power. Routing automations ++ NLP and TTS support.
  self, 
  lib, 
  config,     
  pkgs,        
  cmdHelpers,
  ... 
} : let 
in { # 🦆 says ⮞ call diz wen u wantz to sendz notifications
  yo.scripts.notify = { 
    description = "Send Notifications eazy as-quick quack done";
    category = "🌐 Networking";
    autoStart = false;
    logLevel = "DEBUG";
    parameters = [
      { name = "message"; description = "Notification content"; optional = false; }    
      { name = "topic"; description = "Topic to publish to"; default = "quack"; }
      { name = "device"; description = "Topic to subscribe to"; optional = true; }
      { name = "base_urlFile"; description = ""; default = config.sops.secrets.ntfy-url.path; }
    ]; # 🦆 says ⮞ call diz like dat: `yo notify this is my message`
    code = ''
      ${cmdHelpers}
      BASE_URL=$(cat $base_urlFile)
      if [ -z "$BASE_URL" ]; then
        dt_error "Cannot run without base URL!" >&2
        exit 1
      fi
      if [ -n "$device" ]; then
        topic="$topic/$device"
      fi
      ${pkgs.ntfy-sh}/bin/ntfy publish "$BASE_URL"/"$topic" "$message"
    '';
  };  
 
  # 🦆 says ⮞ diz runz on da boot, no worriez - duckie be listenin'
  yo.scripts.notify-me = {
    description = "Listener for notifications and run actions";
    category = "🌐 Networking";
    logLevel = "DEBUG";
#    autoStart = false;  
    autoStart = builtins.elem config.this.host.hostname [ "desktop" "homie" ];
    parameters = [
      { name = "topic"; description = "Topic to subscribe to"; default = "quack"; }
      { name = "base_urlFile"; description = ""; default = config.sops.secrets.ntfy-url.path; }
      { name = "sound"; description = "Sound file to play on detection"; default = config.this.user.me.dotfilesDir + "/modules/themes/sounds/awake.wav";  } 
    ]; 
    code = ''
      ${cmdHelpers}

      BASE_URL=$(cat $base_urlFile)
      play_wav() { ${pkgs.alsa-utils}/bin/aplay "$sound" >/dev/null 2>&1; }

      if [ -z "$BASE_URL" ]; then
        dt_error "No base URL provided!"
        exit 1
      fi
      
      if [ -n "$device" ]; then
        TOPICS="$topic,$topic/$device"
      else
        TOPICS="$topic"
      fi
      dt_info "Listening to $BASE_URL/{$TOPICS}"

      ${pkgs.ntfy-sh}/bin/ntfy subscribe "$BASE_URL/$TOPICS" | while IFS= read -r json; do
        msg=$(echo "$json" | ${pkgs.jq}/bin/jq -r '.message')
        ts=$(echo "$json" | ${pkgs.jq}/bin/jq -r '.time')
        time_fmt=$(date -d "@$ts" +"%H:%M")
        dt_info "[$time_fmt] $msg"
        play_wav && sleep 2
        
        if [[ "$msg" == *"VARNING!"* ]]; then
          dt_debug "Skipping self-generated message"
          continue
        fi
        
        lower_msg=$(echo "$msg" | tr '[:upper:]' '[:lower:]')
        if [[ "$lower_msg" == @(yo|jo)\ bitch* ]]; then
          clean_msg="''${msg#yo bitch }"
          yo say "VARNING! Skickar $clean_msg till bitchen" || true
          sleep 4
          dt_warning "Processing command: $clean_msg"
          COMMAND=$(yo bitch "$clean_msg" 2>&1)
          yo notify --device iphone --message "$COMMAND" &
        fi
        
        if [[ "$lower_msg" == @(left|leave)\ home* ]]; then
          yo say "VARNING! Lämnar hemmet - larm om 30s" || true
          sleep 30
          mqtt_pub -t "zigbee2mqtt/leave_home/set" -m 'LEFT'
          dt_warning "Left home sequence activated"
        fi
        
        if [[ "$lower_msg" == @(return|arrive)\ home* ]]; then
          mqtt_pub -t "zigbee2mqtt/return_home/set" -m 'RETURN'
          yo say "Välkommen hem!" || true
          dt_info "Welcome home sequence"
        fi
        
        # Skip TTS for system messages
        if [[ ! "$msg" =~ (VARNING!|Larm|bitchen) ]]; then
          yo say "Meddelande: $msg" &
        fi
      done
    '';
  }; # 🦆 says ⮞ TODO i should probably put a key on diz?
  
  sops.secrets = {
    ntfy-url = {
      sopsFile = ./../../secrets/ntfy-url.yaml;
      owner = config.this.user.me.name;
      group = config.this.user.me.name;
      mode = "0440";
	    };    
  };} # 🦆 says ⮞ sleep tight!
# 🦆 says ⮞ QuackHack-McBLindy out!
# ... 🛌🦆💤

