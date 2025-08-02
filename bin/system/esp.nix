# dotfiles/bin/system/esp.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ 
  self,
  config,
  lib,
  pkgs,
  cmdHelpers,
  ...
}: let
  # 🦆 says ⮞ dis fetch what host has Mosquitto
  sysHosts = lib.attrNames self.nixosConfigurations; 
  mqttHost = lib.findSingle (host:
      let cfg = self.nixosConfigurations.${host}.config;
      in cfg.services.mosquitto.enable or false
    ) null null sysHosts;    
  mqttHostip = if mqttHost != null
    then self.nixosConfigurations.${mqttHost}.config.this.host.ip or (
      let
        resolved = builtins.readFile (pkgs.runCommand "resolve-host" {} ''
          ${pkgs.dnsutils}/bin/host -t A ${mqttHost} > $out
        '');
      in
        lib.lists.head (lib.strings.splitString " " (lib.lists.elemAt (lib.strings.splitString "\n" resolved) 0))
    )
    else (throw "No Mosquitto host found in configuration");
  mqttAuth = "-u mqtt -P $(cat ${config.sops.secrets.mosquitto.path})";
  # 🦆 says ⮞ get whisperd host
  transcriptionHost = lib.findFirst
    (host:
      let cfg = self.nixosConfigurations.${host}.config;
      in cfg.yo.scripts.transcribe.autoStart or false
    ) null sysHosts;
  transcriptionHostIP = if transcriptionHost != null then
    self.nixosConfigurations.${transcriptionHost}.config.this.host.ip
  else
    "0.0.0.0"; 

  # 🦆 says ⮞ get house.esp
  espDevices = lib.filterAttrs (_: cfg: cfg.enable) config.house.esp;
  # 🦆 says ⮞ get house.zigbee.devices
  zigbeeDevices = config.house.zigbee.devices;
  lightDevices = lib.filterAttrs (_: device: device.type == "light") zigbeeDevices;
  # 🦆 says ⮞ get house.rooms
  roomIcons = lib.mapAttrs' (name: room: {
    name = name;
    value = room.icon;
  }) config.house.rooms;
  
  devicesWithId = lib.mapAttrsToList (id: value: { inherit id; } // value) lightDevices;
  devicesByRoom = lib.groupBy (device: device.room) devicesWithId;
  sortedRooms = lib.sort (a: b: a < b) (lib.attrNames devicesByRoom);
  # 🦆 says ⮞ generate html for frontend zigbee control features 
  roomSections = lib.concatMapStrings (room: ''
    <div class="room-section">
      <h4 style="margin-top: 20px; margin-bottom: 10px; padding-bottom: 5px; border-bottom: 1px solid #e2e8f0; color: #2b6cb0; cursor: pointer;" onclick="toggleRoom('${room}')">
        <span class="room-toggle">▼</span>
        ${roomIcons.${room} or "💡"} ${lib.toUpper (lib.substring 0 1 room)}${lib.substring 1 (lib.stringLength room) room}
      </h4>
      <div class="room-content" id="room-content-${room}">
        ${lib.concatMapStrings (device: deviceEntry device) devicesByRoom.${room}}
      </div>
    </div>
  '') sortedRooms;
  

  deviceEntry = device: ''
    <div class="device" data-id="${device.id}">
      <div class="device-header" onclick="toggleDeviceControls('${device.id}')">
        <div class="control-label">
          <span>💡</span> ${lib.escapeXML device.friendly_name}
        </div>
        <label class="toggle">
          <input type="checkbox" onchange="toggleDevice('${device.id}', this.checked)">
          <span class="slider"></span>
        </label>
      </div>
      
      <div class="device-controls" id="controls-${device.id}" style="display:none">
        <div class="control-row">
          <label>Brightness:</label>
          <input type="range" min="1" max="254" value="254" class="brightness-slider" data-device="${device.id}">
        </div>
        
        ${lib.optionalString (device.supports_color or false) ''
          <div class="control-row">
            <label>Color:</label>
            <input type="color" class="color-picker" data-device="${device.id}" value="#ffffff">
          </div>
        ''}
      </div>
    </div>
  '';
  
  # 🦆 says ⮞ nix generated code injection
  boxSketchContent = lib.readFile ./../../home/sketchbook/boards/esp32s3box.ino;
  nixBoxSketch = let
    placeholder = "ZIGBEEDEVICESHERE";
    replacement = "String zigbeeDevicesHTML = R\"rawliteral(${roomSections})rawliteral\";";
  in lib.replaceStrings [placeholder] [replacement] boxSketchContent;

  # 🦆 says ⮞ write zigbee devices to watch
  watchSketchContent = lib.readFile ./../../home/sketchbook/boards/esp32s3-twatch.ino;
  nixWatchSketch = let
    watchPlaceholder = "ZIGBEEDEVICESHERE";
    watchReplacement = "String zigbeeDevicesHTML = R\"rawliteral(${roomSections})rawliteral\";";
  in lib.replaceStrings [watchPlaceholder] [watchReplacement] watchSketchContent;
 
  escapeSed = str: lib.escape ["\\" "&"] str;  
  
in { # 🦆 says ⮞ my microcontrollerz yo
  house.esp = {
    box = { # 🦆 says ⮞ dope dev toolboxin'z crazy
      enable = true;
      type = "esp32s3box";
      ip = "192.168.1.13";
      mac = "AA:BB:CC:DD:EE:FF";
    };    
    watch = { # 🦆 says ⮞ yo cool watch - cat!
      enable = false;
      type = "esp32s3-twatch";
      ip = "192.168.1.101";
      mac = "AA:BB:CC:DD:EE:00";
      description = "ESP Smart Watch, ESP32S3 T-Watch LoRa";
    };
  };

  yo.scripts = { 
    esp = { # 🦆 says ⮞ quackin' flashin' helpin' scriptin' - yo 
      description = "Nixiflyin' ESP flasher script";
      category = "🖥️ System Management";
      logLevel = "DEBUG";
      parameters = [
        { name = "device"; description = "Target device name to flash"; }           
        { name = "serialPort"; description = "Serial port used to flash"; default = "/dev/ttyACM0"; }
        { name = "wifiSSID"; description = "WiFi SSID to connect device to"; default = "pungkula2"; }     
        { name = "wifiPwFile"; description = "File path containing the password to WiFi"; default = config.sops.secrets.wifi.path; }     
        { name = "mqttHost"; description = "Mosquitto host IP"; default = mqttHostip; }             
        { name = "mqttUser"; description = "User that runs Mosquitto"; default = "mqtt"; }     
        { name = "mqttPwFile"; description = "File path containing the password to WiFi"; default = config.sops.secrets.mosquitto.path; }          
        { name = "transcriptionHostIP"; description = "IP of machine that has whisperd"; default = transcriptionHostIP; }        
      ];
      code = let 
        deviceConfig = lib.mapAttrs (name: cfg: ''
          "${name}")
            board="${cfg.board}"
            sketch="${cfg.sketch}"
            serialPortDefault="${cfg.serialPort}"
            ;;
        '') espDevices;
      in ''   
        ${cmdHelpers}
        if [ -z "$device" ]; then
          dt_error "Device name must be specified. Available devices:"
          ${lib.concatMapStrings (name: "echo '  - ${name}'\n") (lib.attrNames espDevices)}
          exit 1
        fi

        case "$device" in
          ${lib.concatStrings (lib.attrValues deviceConfig)}
          *)
            dt_error "Unknown device: $device. Available devices:"
            ${lib.concatMapStrings (name: "echo '  - ${name}'\n") (lib.attrNames espDevices)}
            exit 1
            ;;
        esac
        
        actualSerialPort="''${serialPort:-$serialPortDefault}"

        # 🦆 says ⮞ inject passwords into tmp filez
        WIFIPASSWORD="$(tr -d '\n' < "$wifiPwFile")"
        MQTTPASSWORD="$(tr -d '\n' < "$mqttPwFile")"
        # 🦆 says ⮞ nix escapin' iz quackstatic!  
        WIFIPASSWORD_ESC="''${escapeSed WIFIPASSWORD}"
        MQTTPASSWORD_ESC="''${escapeSed MQTTPASSWORD}"
        WIFISSID_ESC="''${escapeSed wifiSSID}"
        MQTTUSER_ESC="''${escapeSed mqttUser}"
        MQTTHOSTIP_ESC="''${escapeSed mqttHostip}"
        TRANSCRIPTIONIP_ESC="''${escapeSed transcriptionHostIP}"
        tmpDir=$(mktemp -d)
        trap 'rm -rf "$tmpDir"' EXIT
        mkdir -p "$tmpDir/sketch"
          
        cp ''${config.this.user.me.dotfilesDir}/home/sketchbook/boards/"$sketch" "$tmpDir/sketch/sketch.ino"
         
        sed -i \
          -e "s#MQTTHOSTIPHERE#$MQTTHOSTIP_ESC#g" \
          -e "s#MQTTUSERNAMEHERE#$MQTTUSER_ESC#g" \
          -e "s#MQTTPASSWORDHERE#$MQTTPASSWORD_ESC#g" \
          -e "s#WIFISSIDHERE#$WIFISSID_ESC#g" \
          -e "s#WIFIPASSWORDHERE#$WIFIPASSWORD_ESC#g" \
          -e "s#TRANSCRIPTIONHOSTIPHERE#$TRANSCRIPTIONIP_ESC#g" \
          "$tmpDir/sketch/sketch.ino"

        # 🦆 says ⮞ datz it yo - compile and upload quaack
        arduino-cli compile --fqbn "$board" "$tmpDir/sketch"
        arduino-cli upload -p "$actualSerialPort" --fqbn "$board" "$tmpDir/sketch"
      '';
    };  
  };  

  file = { # 🦆 says ⮞ let'z make dem' .nixino files cool huh
    "sketchbook/devices/esp32s3box.ino" = nixBoxSketch;
    "sketchbook/devices/esp32s3-twatch.ino" = nixWatchSketch;
  };

  sops.secrets.wifi = { # 🦆 says ⮞ don't tell anyone ok?
    sopsFile = ./../../secrets/wifi.yaml;
    owner = config.this.user.me.name;
    group = config.this.user.me.name;
    mode = "0440";
  };} # 🦆 says ⮞ quack hack
# 🦆 says ⮞ bye bye!
