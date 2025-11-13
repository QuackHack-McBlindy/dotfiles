# dotfiles/bin/system/esp.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ declarative micro controller coding if you will
  self,
  config,
  lib,
  pkgs,
  cmdHelpers,
  ...
}: let
  # 🦆 says ⮞ dis fetch what host has Mosquitto
  sysHosts = lib.attrNames self.nixosConfigurations; 
  mqttHost = "homie";
#  mqttHost = lib.findSingle (host:
#      let cfg = self.nixosConfigurations.${host}.config;
#      in cfg.services.mosquitto.enable or false
#    ) null null sysHosts;    
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
      <div class="room-content" id="room-content-${room}" style="display: none;">
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
            <input type="range" min="0" max="360" value="0" class="rgb-slider" data-device="${device.id}" oninput="updateRGBColor(this)">
          </div>        
          
          <div class="control-row">
            <input type="color" class="color-picker" data-device="${device.id}" value="#ffffff">
          </div>
        ''}
      </div>
    </div>
  '';


  # 🦆 says ⮞ nix generated code injection
  boxSketchContent = lib.readFile ./../../home/sketchbook/boards/esp32s3box.ino;
  nixBoxSketch = let
    placeholders = [
      "ZIGBEEDEVICESHERE"
    ];  
    replacements = [
      "String zigbeeDevicesHTML = R\"rawliteral(${roomSections})rawliteral\";"
    ];  
  in lib.replaceStrings placeholders replacements boxSketchContent;

  # 🦆 says ⮞ write zigbee devices to watch
  watchSketchContent = lib.readFile ./../../home/sketchbook/boards/esp32s3-twatch.ino;
  nixWatchSketch = let
    watchPlaceholder = "ZIGBEEDEVICESHERE";
    watchReplacement = "String zigbeeDevicesHTML = R\"rawliteral(${roomSections})rawliteral\";";
  in lib.replaceStrings [watchPlaceholder] [watchReplacement] watchSketchContent;
  
in { # 🦆 says ⮞ my microcontrollerz yo
  house.esp = {
    box = { # 🦆 says ⮞ dope dev toolboxin'z crazy
      enable = true;
      type = "esp32s3box";
      ip = "192.168.1.13";
      mac = "30:30:f9:5a:ba:d0";
    };    
    watch = { # 🦆 says ⮞ yo cool watch - cat!
      enable = false;
      type = "esp32s3-twatch";
      mac = "30:30:f9:5a:bb:d0";      
      ip = "192.168.1.101";
    };
  };
  
  yo.scripts = { 
    esp = { # 🦆 says ⮞ quackin' flashin' helpin' scriptin' - yo 
      description = "Declarative firmware deployment tool for ESP32 boards with built-in version control.";
      category = "🖥️ System Management";
      logLevel = "DEBUG";
      parameters = [
        { name = "device"; description = "Target device name to flash"; default = "box"; }           
        { name = "serialPort"; description = "Serial port used to flash"; default = "/dev/ttyACM0"; }
        { name = "ota"; description = "Use OTA update"; default = "false"; }
        { name = "otaPort"; description = "OTA port"; default = "3232"; }
        { name = "OTAPwFile"; description = "File path containing the password for Over The Air updates"; default = config.sops.secrets.ota.path; }             
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
            deviceIP="${cfg.ip}"
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

        # 🦆 says ⮞ safe dump - no leaks
        dump_sketch_safe() {
          redacted_sketch="$(sed \
            -e "s#$MQTTPASSWORD#***REDACTED***#g" \
            -e "s#$WIFIPASSWORD#***REDACTED***#g" \
            -e "s#$OTAPASSWORD#***REDACTED***#g" \
            "$tmpDir/sketch/sketch.ino")"
          echo "$redacted_sketch"
        } # 🦆 says ⮞ basic
        version_control() {
          local device="$1"
          local dir="${config.this.user.me.dotfilesDir}/home/sketchbook/devices/$device"
          local base_name="$device"
          local ext="ino"
          local max_files=5
          mkdir -p "$dir"
          # 🦆 says ⮞ count & remove
          local files=($(ls -1 "$dir"/"$base_name"_v*."$ext" 2>/dev/null | sort))
          local count=''${#files[@]}
          if (( count >= max_files )); then
              dt_debug "Deleting oldest file: ''${files[0]}"
              rm -f "''${files[0]}"
          fi
          # 🦆 says ⮞ find latest
          local latest_version=0.0
          for f in "''${files[@]}"; do
              ver=$(basename "$f" | sed -E "s/''${base_name}_v([0-9]+\.[0-9]+)\.''${ext}/\1/")
              if awk "BEGIN {exit !($ver > $latest_version)}"; then
                  latest_version=$ver
              fi
          done
          # 🦆 says ⮞ set version
          new_version=$(awk "BEGIN {printf \"%.2f\", $latest_version + 0.01}")
          new_file="''${dir}/''${base_name}_v''${new_version}.''${ext}"
          # 🦆 says ⮞ save new version
          dump_sketch_safe > "$new_file"
          dt_info "New version saved: $new_file"
        }

        actualSerialPort="''${serialPort:-$serialPortDefault}"
        useOTA=''${ota:-false}
        otaPort=''${otaPort:-3232}

        # 🦆 says ⮞ inject passwords into tmp filez
        WIFIPASSWORD="$(tr -d '\n' < "$wifiPwFile")"
        MQTTPASSWORD="$(tr -d '\n' < "$mqttPwFile")"
        OTAPASSWORD="$(tr -d '\n' < "$OTAPwFile")"
        
        tmpDir=$(mktemp -d)
        trap 'rm -rf "$tmpDir"' EXIT
        mkdir -p "$tmpDir/sketch"
          
        cp "${config.this.user.me.dotfilesDir}/home/sketchbook/devices/$sketch" "$tmpDir/sketch/sketch.ino"

        # 🦆 says ⮞ cya here's sed
        sed -i \
          -e "s#MQTTHOSTIPHERE#$mqttHost#g" \
          -e "s#MQTTUSERNAMEHERE#$mqttUser#g" \
          -e "s#MQTTPASSWORDHERE#$MQTTPASSWORD#g" \
          -e "s#WIFISSIDHERE#$wifiSSID#g" \
          -e "s#WIFIPASSWORDHERE#$WIFIPASSWORD#g" \
          -e "s#TRANSCRIPTIONHOSTIPHERE#$transcriptionHostIP#g" \
          -e "s#OTAPORTHERE#$otaPort#g" \
          -e "s#OTAPASSWORDHERE#$OTAPASSWORD#g" \
          "$tmpDir/sketch/sketch.ino"

        if $useOTA; then
          actualPort="$deviceIP:$otaPort"
          protocol="espota"
          otaPassword="$OTAPASSWORD)"
          extraFlags="--protocol $protocol --upload-field password=$otaPassword"
        else
          actualPort="''${serialPort:-$serialPortDefault}"
          extraFlags=""
        fi

        # 🦆 says ⮞ datz it - compile yo
        if ! arduino-cli compile --fqbn "$board" "$tmpDir/sketch"; then
          dt_error "Compilation failed!"
          say_duck "fuck ❌ Compiling failed!"
          play_fail
          echo -n "🦆 Show safe sketch? [y/N] "
          read -t 30 -n 1 answer
          echo ""
          if [[ "$answer" =~ ^[Yy]$ ]]; then
            dump_sketch_safe
          fi
          exit 1          
        fi 

        # 🦆 says ⮞ and upload quack
        if ! arduino-cli upload -p "$actualPort" $extraFlags --fqbn "$board" "$tmpDir/sketch"; then
          dt_error "Upload failed!"
          say_duck "fuck ❌ Upload failed!"
          play_fail
          exit 1
        else
          # 🦆 says ⮞ sucess? cool save dat code 
          play_win
          version_control "$device"
        fi        
      '';
    };  
  };  

  file = { # 🦆 says ⮞ let'z make dem' .nixino files cool huh
    "sketchbook/devices/esp32s3box.ino" = nixBoxSketch;
    "sketchbook/devices/esp32s3-twatch.ino" = nixWatchSketch;
  };

  # 🦆 says ⮞ auto updates comin' flyin'
  yo.scripts = { 
    espOTA = { # 🦆 says ⮞ quackin' flashin' helpin' scriptin' - yo 
      description = "Updates ESP32 devices over the air.";
      category = "🖥️ System Management";
      logLevel = "INFO";
      code = ''
        dt_info "Updating over the air"
        yo-esp --ota
      '';
    };
  };  

  sops.secrets = {
    wifi = { # 🦆 says ⮞ don't tell anyone ok?
      sopsFile = ./../../secrets/wifi.yaml;
      owner = config.this.user.me.name;
      group = config.this.user.me.name;
      mode = "0440";
    };
    ota = { # 🦆 says ⮞ holy duck wireguard OTA updates to watch - hot enuff?
      sopsFile = ./../../secrets/ota.yaml;
      owner = config.this.user.me.name;
      group = config.this.user.me.name;
      mode = "0440";
    };  # 🦆 says ⮞ quack hack   
  };} # 🦆 says ⮞ blind duck
# 🦆 says ⮞ bye bye sup
