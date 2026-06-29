# dotfiles/bin/system/watch.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 duck say ⮞ smart watch controller
  self,
  config,
  pkgs,
  cmdHelpers,
  ...
} : let
  sysHosts = builtins.attrNames self.nixosConfigurations;
  vmHosts = builtins.filter (host:
    self.nixosConfigurations.${host}.self.config.system.build ? vm
  ) sysHosts;  
in {
  yo.scripts = { 
   watch = {
     description = "API controller for ESP32-S3-WATCH-rs.";
     category = "🖥️ System Management";
     parameters = [
       { name = "device"; type = "string"; description = "Host IP"; optional = false; default = "192.168.1.182"; }
       { name = "setting"; type = "string"; description = "endpoint to control"; optional = false; }
       { name = "value"; type = "string"; description = "SSH username"; optional = true; }
     ];
     code = ''   
       ${cmdHelpers}


  
       
       #!/usr/bin/env bash
       
       DEVICE=""
       SETTING=""
       VALUE=""
       
       while [[ $# -gt 0 ]]; do
           case "$1" in
               --device) DEVICE="$2"; shift 2 ;;
               --setting) SETTING="$2"; shift 2 ;;
               --value) VALUE="$2"; shift 2 ;;
               *) shift ;;
           esac
       done
       
       if [[ -n "$VALUE" ]]; then
           URL="http://''${DEVICE}/api/settings/''${SETTING}/''${VALUE}"
       else
           URL="http://''${DEVICE}/api/settings/''${SETTING}"
       fi
       
       curl --silent "$URL"
     '';
     voice = {
       enabled = true;
       priority = 5;
       fuzzy.enable = false;
       sentences = [ 
         "ändra {setting} på {device}"
         "ändra {setting} på {device} till {value}"
       ];
       lists = {
         device.values = [
           { "in" = "[klocka|klockan]"; out = "192.168.1.182"; }       
         ];
         

         setting.values = [
           # === DISPLAY ===
           { "in" = "[ljusstyrka|ljusstyrkan|ljus]"; out = "display/brightness"; }
           { "in" = "[skärm av|stäng skärm|skärmen av|display av]"; out = "display/state/off"; }
           { "in" = "[skärm på|tänd skärm|skärmen på|display på]"; out = "display/state/on"; }
           { "in" = "[uppdatera skärm|rit om|redraw]"; out = "display/redraw"; }
           { "in" = "[skärm timeout|timeout]"; out = "display/timeout"; }
           { "in" = "[visa sida|gå till sida]"; out = "display/page"; }
           { "in" = "[visa text|skärm text]"; out = "display/text"; }
         
           # === AUDIO: SPEAKER ===
           { "in" = "[volym|ljudstyrka]"; out = "speaker/volume"; }
           { "in" = "[ljud av|tysta|muta högtalare]"; out = "speaker/mute/on"; }
           { "in" = "[ljud på|ljudet på|avmuta högtalare]"; out = "speaker/mute/off"; }
           { "in" = "[växla ljud|toggle mute]"; out = "speaker/mute/toggle"; }
           { "in" = "[högtalaruppgift av|stoppa högtalare]"; out = "speaker/off"; }
           { "in" = "[högtalaruppgift på|starta högtalare]"; out = "speaker/on"; }
           { "in" = "[strömma ljud av|stoppa ljudström]"; out = "speaker/stream/off"; }
           { "in" = "[strömma ljud på|starta ljudström]"; out = "speaker/stream/on"; }
           { "in" = "[test pip|spela ding]"; out = "speaker/play/ding"; }
         
           # === AUDIO: MICROPHONE ===
           { "in" = "[mikrofonvolym|mic volym]"; out = "mic/volume"; }
           { "in" = "[mikrofon av|stäng av mikrofonen]"; out = "mic/mute/on"; }
           { "in" = "[mikrofon på|sätt på mikrofonen]"; out = "mic/mute/off"; }
           { "in" = "[växla mikrofon|toggle mic mute]"; out = "mic/mute/toggle"; }
         
           # === VOICE ASSISTANT ===
           { "in" = "[röst av|stäng av röst]"; out = "voice/off"; }
           { "in" = "[röst på|sätt på röst]"; out = "voice/on"; }
           { "in" = "[växla röst|toggle voice]"; out = "voice/toggle"; }
           { "in" = "[vaknord av|stäng av vaknord]"; out = "voice/wakeword/off"; }
           { "in" = "[vaknord på|sätt på vaknord]"; out = "voice/wakeword/on"; }
         
           # === POWER & CPU ===
           { "in" = "[sparläge|strömspar|låg effekt]"; out = "power/low/on"; }
           { "in" = "[normal läge|stäng av sparläge]"; out = "power/low/off"; }
           { "in" = "[växla sparläge|toggle low power]"; out = "power/low/toggle"; }
           { "in" = "[processor hastighet|cpu frekvens]"; out = "cpu"; }
         
           # === BLUETOOTH ===
           { "in" = "[bluetooth av|stäng av bluetooth]"; out = "bluetooth/off"; }
           { "in" = "[bluetooth på|sätt på bluetooth]"; out = "bluetooth/on"; }
         
           # === API & NETWORK ===
           { "in" = "[stäng av api|stoppa api]"; out = "api/off"; }
           { "in" = "[stäng av wifi|wifi av]"; out = "wifi/off"; }
         
           # === INCOMING CALL ===
           { "in" = "[samtal från|ringer]"; out = "display/call"; }

         ];
         

         value.wildcard = true;
         #[
         #  { "in" = "[pungkula]"; out = "pungkula"; }
        #   { "in" = "[annan]"; out = "random"; }        
        # ];
       };
     };
    };
    
  };}
