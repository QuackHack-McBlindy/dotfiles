# dotfiles/bin/home/state.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ fetchez the state of specified device 
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ...
} : let 
  zigduckDir = "/home/" + config.this.user.me.name + "/.config/zigduck";
  # 🦆 says ⮞ findz da mosquitto host
  sysHosts = lib.attrNames self.nixosConfigurations;
  mqttHost = let
    sysHosts = lib.attrNames self.nixosConfigurations;
    mqttHosts = lib.filter (host:
      let cfg = self.nixosConfigurations.${host}.config;
      in cfg.services.mosquitto.enable or false
    ) sysHosts;
  in
    if mqttHosts != [] then lib.head mqttHosts else null;

  # 🦆 says ⮞ get MQTT broker IP (fallback to localhost)
  mqttHostIp = if mqttHost != null
    then self.nixosConfigurations.${mqttHost}.config.this.host.ip or "127.0.0.1"
    else "127.0.0.1";

  # 🦆 says ⮞ define Zigbee devices here yo 
  zigbeeDevices = config.house.zigbee.devices;

  # 🦆 says ⮞ Filter to only include light devices
  lightDevices = lib.filterAttrs (_: device: device.type == "light") zigbeeDevices;
 
  # 🦆 says ⮞ case-insensitive device matching
  normalizedDeviceMap = lib.mapAttrs' (id: device:
    lib.nameValuePair (lib.toLower device.friendly_name) device.friendly_name
  ) zigbeeDevices;

  # 🦆 says ⮞ Group devices by room
  roomDevicesMap = let
    grouped = lib.groupBy (device: device.room) (lib.attrValues zigbeeDevices);
  in lib.mapAttrs (room: devices: 
      map (d: d.friendly_name) devices
    ) grouped;

  # 🦆 says ⮞ All devices list for 'all' area
  allDevicesList = lib.attrValues normalizedDeviceMap;

  # 🦆 says ⮞ device validation list
  deviceList = builtins.attrNames normalizedDeviceMap;

  # 🦆 says ⮞ Get Zigbee configuration
  zigbeeCfg = if mqttHost != null
    then self.nixosConfigurations.${mqttHost}.config.services.zigbee2mqtt.settings or {}
    else {};

  # 🦆 says ⮞ Precompute device and group mappings
  devicesSet = zigbeeCfg.devices or {};
  groupsSet = zigbeeCfg.groups or {};

  # 🦆 says ⮞ Room bash map with only lights, using | as separator
  roomBashMap = lib.mapAttrs' (room: devices:
    lib.nameValuePair room (lib.concatStringsSep "|" devices)
  ) roomDevicesMap;

  # 🦆 says ⮞ All devices as a pipe-separated string
  allDevicesStr = lib.concatStringsSep "|" allDevicesList;

in {
  yo.scripts.testing = {
    description = "DuckBee Control lights and other home automatioon devices";
    #aliases = [ "DB" ];
    category = "🛖 Home Automation";
    autoStart = false;
    logLevel = "DEBUG";
    parameters = [   
      { name = "device"; description = "Device to control"; optional = true; }
      { name = "state"; type = "string"; description = "State of the device or group"; } 
      { name = "brightness"; description = "Brightness value of the device or group"; optional = true; type = "int"; }    
      { name = "color"; description = "Color to set on the device"; optional = true; }    
      { name = "temperature"; description = "Light color temperature to set on the device"; optional = true; }          
      { name = "scene"; description = "Activate a predefined scene"; optional = true; }     
      { name = "room"; description = "Room to target"; optional = true; }        
      { name = "user"; description = "Mosquitto username to use"; default = "mqtt"; }    
      { name = "passwordfile"; description = "File path containing password for Mosquitto user"; default = config.sops.secrets.mosquitto.path; }
      { name = "flake"; description = "Path containing flake.nix"; default = config.this.user.me.dotfilesDir; }
      { name = "pair"; type = "bool"; description = "Activate zigbee2mqtt pairring and start searching for new devices"; default = false; }
      { name = "cheapMode"; type = "bool"; description = "Energy saving mode. Turns off the lights again after X seconds."; default = false; }
    ];
    code = ''
      echo "to display"
      
    '';
    voice = {
      priority = 1;
      sentences = [      
        # 🦆 says ⮞ device control (simple, common)
        "(turn on|switch on|activate|start|power on) {device}"
        "(turn off|switch off|deactivate|stop|power off) {device}"
        "(turn|switch) {device} {state}"
        "(turn|switch) {state} {device}"
        "{device} {state} and brightness {brightness} percent"
        "{device} {state} with {color} color and {brightness} percent brightness"
        "{device} {state} in {room} and [change] color [to] {color} [and] brightness [to] {brightness} percent"

        # 🦆 says ⮞ simple room-light control
        "{state} (all|every) light[s] in {room}"
        "{state} {room} light[s]"
        "{state} (all|every) light[s]"
        "{state} (all|every) {device} light[s]"
        "control (all|every) light[s] in {room}"
        "manage {room} lighting"

        # 🦆 says ⮞ color control
        "(change|set|adjust) {device} color to {color}"
        "(change|set|adjust) color of {device} to {color}"
        "make {device} {color}"
        "set {device} to {color} color"
        "apply {color} color to {device}"

        # 🦆 says ⮞ brightness control
        "(adjust|set|change) {device} brightness to {brightness} percent"
        "(adjust|set|change) brightness of {device} to {brightness} percent"
        "make {device} {brightness} percent brightness"
        "set {device} to {brightness} percent brightness"
        "dim {device} to {brightness} percent"
        "brighten {device} to {brightness} percent"

        # 🦆 says ⮞ scene/ambiance control
        "create {scene} (scene|mode|atmosphere) in {room}"
        "set {room} to {scene} (scene|mode|atmosphere)"
        "activate {scene} mode"

        # 🦆 says ⮞ multi taskerz (complex, strict patterns LAST)
        "set {room} lights to {state} with {color} at {brightness} percent and activate {scene}"
        "{device} {state} in {room} with {color} color at {brightness} percent and temperature {temperature} using scene {scene}"
        "configure {device} in {room} with {color} color, {brightness} percent brightness, and {temperature} temperature"
        "create {scene} atmosphere in {room} using {color} lighting at {brightness} percent [in cheap mode]"
        "adjust all lights in {room} to {color} with {brightness} percent brightness and set {temperature} temperature"

        # 🦆 says ⮞ pairing mode
        "{pair} [new] [zigbee] (device|devices|sensor|sensors)"
        "start {pair} [new] device[s]"
        "enable {pair} mode for new devices"
        "begin device {pair}"
      ];      
      lists = {
        state.values = [
          { "in" = "[on]"; out = "ON"; }             
          { "in" = "[off|turn off]"; out = "OFF"; } 
        ];
        brightness.values = builtins.genList (i: {
          "in" = toString (i + 1);
          out = toString (i + 1);
        }) 100 ++ [
          { "in" = "[full|maximum|max|hundred]"; out = "100"; }
          { "in" = "[half|fifty|medium]"; out = "50"; }
          { "in" = "[quarter|twenty five|low]"; out = "25"; }
          { "in" = "[ten percent|minimal|dim]"; out = "10"; }
          { "in" = "[five percent|minimum|min]"; out = "5"; }
          { "in" = "[zero|off|dark]"; out = "0"; }
        ];
# 🦆 says ⮞ automatically add all zigbee devices  
        device.values = let
          reservedNames = [ "hall" "kitchen" "bedroom" "bathroom" "wc" "livingroom" "kitchen" "switch" "all" "every" ];
          sanitize = str:
            lib.replaceStrings [ "/" " " ] [ "" "_" ] str;
        in [
          { "in" = "[living room|livingroom|livingroom|main room|front room]"; out = "livingroom"; }
          { "in" = "[kitchen|cooking area|kitchen area]"; out = "kitchen"; }
          { "in" = "[bedroom|sleeping room|master bedroom]"; out = "bedroom"; }
          { "in" = "[bathroom|restroom|washroom]"; out = "bathroom"; }
          { "in" = "[hallway|hall|corridor|passage]"; out = "hallway"; }
          { "in" = "[all|every|everything|all lights]"; out = "ALL_LIGHTS"; }    
        ] ++
        (lib.filter (x: x != null) (
          lib.mapAttrsToList (_: device:
           let
              baseRaw = lib.toLower device.friendly_name;
              base = sanitize baseRaw;
              baseWords = lib.splitString " " base;
              isAmbiguous = lib.any (word: lib.elem word reservedNames) baseWords;
              hasLampSuffix = lib.hasSuffix "lamp" base;
              lampanVariant = if hasLampSuffix then [ "${base}s" "${base} light" ] else [];  
              enVariant = [ "${base}s" "${base} light" ]; # English variants
              variations = lib.unique (
                [
                  base
                  (sanitize (lib.replaceStrings [ " " ] [ "" ] base))
                  (lib.replaceStrings [ "_" ] [ " " ] base)
                ] ++ lampanVariant ++ enVariant
              );
            in if isAmbiguous then null else {
              "in" = "[" + lib.concatStringsSep "|" variations + "]";
              out = device.friendly_name;
           }
          ) zigbeeDevices
        ));      
        # 🦆 says ⮞ color yo        
        color.values = [
          { "in" = "[red|red color|crimson]"; out = "red"; }
          { "in" = "[green|green color|emerald]"; out = "green"; }
          { "in" = "[blue|blue color|azure]"; out = "blue"; }
          { "in" = "[yellow|yellow color|golden]"; out = "yellow"; }
          { "in" = "[orange|orange color|amber]"; out = "orange"; }
          { "in" = "[purple|purple color|violet]"; out = "purple"; }
          { "in" = "[pink|pink color|rose]"; out = "pink"; }
          { "in" = "[white|white color|pure white]"; out = "white"; }
        ];  
        temperature.values = builtins.genList (i: {
           "in" = toString i;
            out = toString i;
        }) 500;

        scene.values = [
          { "in" = "[chill]"; out = "chill"; }
          { "in" = "[romantic]"; out = "romantic"; }
          { "in" = "[focus]"; out = "focus"; }
        ];

        pair.values = [
          { "in" = "[pair|pairing|discover|scan]"; out = "true"; }
        ];
      };
    };
    
  };}  
        
