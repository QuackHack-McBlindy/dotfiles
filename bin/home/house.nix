# dotfiles/bin/home/house.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
#  » ★ QuackHack-McBLindy.com ★ «
# 🦆 ⮞ my house - qwack! u wanna copy pasta?
{ #  » ★ github.com/QuackHack-McBlindy/zigduck ★ «
  self,
  lib,
  config,
  pkgs,
  swe,
  ...
} : let

in {
  yo.scripts.house = {
    description = "High-performance unified CLI for controlling all smart home devices.";
    category = "🛖 Home Automation";
    autoStart = false;
    logLevel = "WARNING";
    binary = self.inputs.zigduck.packages.x86_64-linux.zigduck-cli + "/bin/zigduck-cli";
    parameters = [
      { name = "device"; description = "Device to control"; optional = true;
          values = swe.allowFrom "device"; }
      { name = "state"; type = "string"; description = "State of the device or group";
          values = [ "ON" "OFF" ]; }
      { name = "brightness"; description = "Brightness value (1-100)"; optional = true; type = "string";
          values = swe.allowFrom "brightness"; }
      { name = "color"; description = "Color name or hex code"; optional = true;
          values = swe.allowFrom "color"; }
      { name = "temperature"; description = "Light color temperature (153-500)"; optional = true;
          values = swe.allowFrom "temperature"; }
      { name = "scene"; description = "Activate a predefined scene"; optional = true;
          values = swe.allowFrom "scene"; }
      { name = "room"; description = "Room to target"; optional = true;
          values = swe.allowFrom "room"; }
      { name = "blinds"; description = "Control all blinds (up/down/open/close)"; optional = true;
          values = swe.allowFrom "blinds"; }
      { name = "all-lights"; description = "Control all lights"; type = "bool"; optional = false; default = false; }
      { name = "get-state"; type = "bool"; description = "Fetch current on/off state of a device"; optional = true; }
      #{ name = "pair"; type = "bool"; description = "Activate zigbee2mqtt pairing and start searching for new devices"; optional = true; }
    ];

    voice  = {
      priority        = 2;
      fuzzy.enable    = true;
      fuzzy.threshold = 0.5;
      sentences       = [
          # 🦆 says ⮞ multi taskerz
          "{device} [sätt|slå|stäng] {state} i {room} [{when}] och [ändra] färg[en] [till] {color} [och] ljusstyrka[n] [till] {brightness} procent"
          "{device} [sätt|slå|stäng] {state} i {room} och [ändra] färg[en] [till] {color} [och] ljusstyrka[n] [till] {brightness} procent"
          "[sätt|slå|stäng] {state} {device} [till] {color} [färg] [och] {brightness} procent [ljusstyrka]"
          "[sätt|slå|stäng] {state} {room} [till] {color} [färg] [och] {brightness} procent [ljusstyrka]"
          "[sätt|slå|stäng] {state} {room} och [ljusstyrka|ljusstyrkan] {brightness} procent"
          "(sätt|ställ|ändra|justera) {device} till {brightness} procent"
          "(sätt|ställ|ändra|justera) ljusstyrkan [på] {device} till {brightness} procent"
          "(gör|ställ) {device} (ljusare|mörkare)"
          "{device} till {brightness} procent"
          "{brightness} procent [ljusstyrka] på {device}"
          "{brightness} procent [ljusstyrka] i {room}"
          #"{scene} alla lampor"
          "{scene} (belysning|belysningen)"
          "{scene} (lamp|lampor|lamporna|allt|ljus|ljuset)"
          "släck (lamp|lampor|lamporna|allt|ljus|ljuset) [igen] {scene} [som] [fan] [utav] [helvete]"
          #"{state} [av] {all-lights} (lampor|lamporna)"
          "[sätt|slå|stäng] {state} {device} (lampor|igen)"
          "[sätt|slå|stäng] {state} [alla|allt] (lampor|lamporna|ljus) i {room}"
          "[sätt|slå|stäng] {state} (lamporna|ljusen) [i] {room}"
          "[sätt|slå|stäng] {state} {room}"
          "[sätt|slå|stäng] {state} belysningen i {room}"
          "[sätt|slå|stäng] {state} [på|av] i {room}"
          "[sätt|slå|stäng] {state} [alla|allt] (lampor|lamporna|ljus) i {room}"
          "[sätt|slå|stäng] {state} {device}"

          # 🦆 says ⮞ color control
          "(ändra|gör) färgen [på|i] {device} till {color}"
          "(ändra|gör) {device} {color}"
          "(ändra|gör) {room} {color}"

          # 🦆 says ⮞ pairing mode
          #"{pair} [ny|nya] [zigbee] (enhet|enheter)"

          # 🦆 says ⮞ brightness control
          "justera {device} till {brightness} procent"

          # 🦆 says ⮞ fetch temp
          "vad är {get-temp} i {room} [just] [nu]"
          "vad är det för {get-temp} i {room} [nu]"
          "hur många {get-temp} är det i {room} [just] [nu]"
          "hur {get-temp} är det i {room} [just] [nu]"

          # 🦆 says ⮞ fetch battery
          #"hur mycket {get-bat} återstår (på|i) {device}"
          #"hur mycket {get-bat} är det kvar (på|i) {device}"
          #"har {device} lite {get-bat} [kvar]"
          #"är det mycket {get-bat} kvar på {device}"
          #"vad har {device} för {get-bat} [nivå|procent]"

          # 🦆 says ⮞ contorl all blinds
          "(hissa|dra|veva|ta) {blinds} (persienner|persiennerna)"
          "{scene} [alla] (lampor|lamporna|ljuset|ljusen)"
          "(långsam|långsamt|sakta|slowly) släck [i] {scene}"
          "(släck|stäng) {scene} (långsam|långsamt|sakta)"
      ];
      lists = {
        device.values      = swe.devices;
        color.values       = swe.colors;
        room.values        = swe.rooms;
        temperature.values = swe.temperature;
        brightness.values  = swe.brightness;
        state.values       = [
            { "in" = "tänd|på|starta|aktivera";    out = "ON"; }
            { "in" = "släck|av|avaktivera|stäng|av"; out = "OFF"; }
        ];
        scene.values = swe.scenes ++ [
            { "in" = "tänd||tänk|max|maxa|maxxa|maxad|maximum"; out = "max"; }
            { "in" = "på|tänd|aktiv";                           out = "max"; }
            { "in" = "mörk|mörker|mörkt|släckt|avstängd";       out = "dark"; }
            { "in" = "av|släck|släckt|stängd|stäng";            out = "dark"; }
            { "in" = "fort";                                    out = "dark-fast"; }
            { "in" = "kök|köket";                               out = "kitchenFadeOff"; }
            { "in" = "mys|myspys|mysig|chill|chilla";           out = "Chill Scene"; }
        ];
        all-lights.values = [
            { "in" = "all|alla|allt"; out = "true"; }
        ];
        blinds.values     = [
            { "in" = "up|upp";   out = "up"; }
            { "in" = "ner|ned";  out = "down"; }
            { "in" = "öppna";    out = "open"; }
            { "in" = "stäng";    out = "close"; }
        ];
        #pair.values      = [
        #   { "in" = "[para|paras]"; out = "true"; }
        #];
      };
    };

  };}
