# dotfiles/bin/network/notify.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ Notification System with true power. Routing automations ++ NLP and TTS support.
  self, 
  lib, 
  config,     
  pkgs,        
  cmdHelpers,
  ... 
} : let 
in {
  networking.firewall.allowedTCPPorts = [9913];
  # 🦆 says ⮞ call diz wen u wantz to sendz notifications
#  yo.scripts.notify = { 
#    description = "Send Notifications eazy as-quick quack done";
#    category = "🌐 Networking";
#    autoStart = false;
#    logLevel = "DEBUG";
#    parameters = [
#      { name = "message"; description = "Notification content"; optional = false; }    
#      { name = "topic"; description = "Topic to publish to"; default = "quack"; }
#      { name = "base_urlFile"; description = ""; default = config.sops.secrets.ntfy-url.path; }
#    ]; # 🦆 says ⮞ call diz like dat: `yo notify this is my message`
#    code = ''
#      ${cmdHelpers}
#      BASE_URL=$(cat $base_urlFile)
#      if [ -z "$BASE_URL" ]; then
#        dt_error "Cannot run without base URL!" >&2
#        exit 1
#      fi
#      ${pkgs.ntfy-sh}/bin/ntfy publish "$BASE_URL"/"$topic" "$message"
#    '';
#  };  
 
  # 🦆 says ⮞ diz runz on da boot, no worriez - duckie be listenin'
#  yo.scripts.notify-me = {
#    description = "Listener for notifications and run actions";
#    category = "🌐 Networking";
#    logLevel = "INFO";
#    autoStart = false;  
#    autoStart = builtins.elem config.this.host.hostname [ "homie" ];
#    parameters = [
#      { name = "topic"; description = "Topic to subscribe to"; default = "quack"; }
#      { name = "base_urlFile"; description = ""; default = config.sops.secrets.ntfy-url.path; }
#      { name = "sound"; description = "Sound file to play on detection"; default = config.this.user.me.dotfilesDir + "/modules/themes/sounds/awake.wav";  } 
#    ]; 
#    code = ''
#      ${cmdHelpers}
#      BASE_URL=$(cat $base_urlFile)
#      play_wav() { ${pkgs.alsa-utils}/bin/aplay "$sound" >/dev/null 2>&1; }

#      if [ -z "$BASE_URL" ]; then
#        dt_error "No base URL provided!"
#        exit 1
#      fi
#      dt_info "Listening to $BASE_URL/$topic"

#      ${pkgs.ntfy-sh}/bin/ntfy subscribe "$BASE_URL/$topic" | while IFS= read -r json; do
#        msg=$(echo "$json" | ${pkgs.jq}/bin/jq -r '.message')
#        ts=$(echo "$json" | ${pkgs.jq}/bin/jq -r '.time')
#        time_fmt=$(${pkgs.coreutils}/bin/date -d "@$ts" +"%H:%M")
#        dt_info "$time_fmt > $msg"
#        play_wav && sleep 2
        
        # 🦆 says ⮞ if yo call da bitch..
#        lower_msg=$(echo "$msg" | tr '[:upper:]' '[:lower:]')
#        if [[ "$lower_msg" == @(yo|jo)\ bitch* ]]; then
#          clean_msg="''${msg#yo bitch }"
#          yo say "Varning! Skickar $clean_msg till bitchen"
#          sleep 4 # 🦆 says ⮞ .. da bitch ya get
#          dt_warning "Skickar $clean_msg till bitchen"
          # 🦆 says ⮞ route to NLP - gives notifications access to run all yo scripts  
#          COMMAND=$(yo bitch "$clean_msg" 2>&1)
#          yo notify --message "$COMMAND" --topic "iphone" 
#        fi
        
#        if [[ "$lower_msg" == @(left|Left)\ home* ]]; then
#          yo say "Varning! Du har lämnat hemmet. Jag larmar om 30 sekunder!"
#          sleep 30 # 🦆 says ⮞ .. da bitch ya get
#          yo say "Larmat!"
#          sleep 2
#          mqtt_pub -t "zigbee2mqtt/leave_home/set" -m 'LEFT'
#          dt_warning "Left home! Turning off lights and arming security..."
#        fi
#        if [[ "$lower_msg" == @(return|returned)\ home* ]]; then
#          mqtt_pub -t "zigbee2mqtt/return_home/set" -m 'RETURN'
#          yo say "Välkommen home brusschaan!!"
#          sleep 0.1
#          dt_info "Welcome home!"
#        fi
#        yo say "Viktigt meddelande från bitchen!" && sleep 4
#        yo say "$msg"
#      done
#    '';
#  }; # 🦆 says ⮞ TODO i should probably put a key on diz?

  # 🦆 says ⮞ diz runz on da boot, no worriez - duckie be listenin'
  yo.scripts.notify-me = {
    description = "Notification server for iOS devices";
    category = "🌐 Networking";
    logLevel = "DEBUG";
#    autoStart = false;  
    autoStart = builtins.elem config.this.host.hostname [ "homie" ];
    parameters = [
#      { name = "deviceKey"; description = "Device token"; default = "X"; }  
      { name = "address"; description = "IP to run server on"; default = "0.0.0.0"; }
      { name = "port"; description = "Port for the service"; default = "9913";  } 
      { name = "dataDir"; description = "Directory path to store server data"; default = "/home/pungkula/barks";  }       
#      { name = "user"; description = "Username authentication for the service"; default = "9913";  } 
#      { name = "pwFile"; description = "FIle path of file containing password the service"; default = config.sops.secrets.bark.path;  } 
    ]; 
    code = ''
      ${cmdHelpers}
#      BASE_URL=$(cat $base_urlFile)
#      USER=$user
#      PASSWORDFILE=$pwFile
#      PASSWORD=$(cat PASSWORDFILE)
#      DEVICE_KEY=$deviceKey
      mkdir $dataDir
      ${pkgs.bark-server}/bin/bark-server --addr $address:$port --data $dataDir
    '';  
  };
  
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












