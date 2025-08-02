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
        <span class="room-toggle">▶</span>
        ${roomIcons.${room} or "💡"} ${lib.toUpper (lib.substring 0 1 room)}${lib.substring 1 (lib.stringLength room) room}
      </h4>
      <div class="room-content" id="room-content-${room}" style="display:none">
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
            <div class="color-control">
              <input type="range" min="0" max="360" value="0" class="hue-slider" data-device="${device.id}">
              <div class="color-preview" id="preview-${device.id}"></div>
            </div>
          </div>
        ''}
      </div>
    </div>
  '';


  # 🦆 says ⮞ js injection - quack! nice name for rockband yo
  JSinject = ''
    <script>
      // 🦆 says ⮞ hsl to rgb
      function hslToRgb(h, s, l) {
        h /= 360;
        s /= 100;
        l /= 100;
        let r, g, b;
        
        if (s === 0) {
          r = g = b = l;
        } else {
          const hue2rgb = (p, q, t) => {
            if (t < 0) t += 1;
            if (t > 1) t -= 1;
            if (t < 1/6) return p + (q - p) * 6 * t;
            if (t < 1/2) return q;
            if (t < 2/3) return p + (q - p) * (2/3 - t) * 6;
            return p;
          };
          
          const q = l < 0.5 ? l * (1 + s) : l + s - l * s;
          const p = 2 * l - q;
          r = hue2rgb(p, q, h + 1/3);
          g = hue2rgb(p, q, h);
          b = hue2rgb(p, q, h - 1/3);
        }
        
        return [Math.round(r * 255), Math.round(g * 255), Math.round(b * 255)];
      }

      function updateColor(deviceId, hue) {
        const [r, g, b] = hslToRgb(hue, 100, 50);
        const hexColor = "#" + 
          r.toString(16).padStart(2, '0') + 
          g.toString(16).padStart(2, '0') + 
          b.toString(16).padStart(2, '0');
        document.getElementById(`preview-''${deviceId}`).style.backgroundColor = hexColor;        
        fetch(`/zigbee/color?id=''${encodeURIComponent(deviceId)}&color=''${hexColor.substring(1)}`)
          .then(res => {
            if (!res.ok) console.error(`Set color failed for ''${deviceId}`);
          });
      }
      document.addEventListener('DOMContentLoaded', function() {
        document.querySelectorAll('.hue-slider').forEach(slider => {
          const deviceId = slider.dataset.device;
          updateColor(deviceId, slider.value);          
          slider.addEventListener('input', function() {
            updateColor(deviceId, this.value);
          });
        });
      });


      function toggleRoom(roomId) {
        const roomContent = document.getElementById(`room-content-''${roomId}`);
        const roomToggle = document.querySelector(`[onclick="toggleRoom(''${roomId}')] .room-toggle`);
      
        if (roomContent.style.display === 'none' || !roomContent.style.display) {
          roomContent.style.display = 'block';
          roomToggle.textContent = '▼';
          localStorage.setItem(`room-''${roomId}-expanded`, 'true');
        } else {
          roomContent.style.display = 'none';
          roomToggle.textContent = '▶';
          localStorage.removeItem(`room-''${roomId}-expanded`);
        }
      }

      document.addEventListener('DOMContentLoaded', function() {
        ${lib.concatMapStrings (room: ''
          if (localStorage.getItem('room-${room}-expanded') === 'true') {
            document.getElementById('room-content-${room}').style.display = 'block';
            document.querySelector('[onclick="toggleRoom(\'${room}\')] .room-toggle').textContent = '▼';
          }
        '') sortedRooms}
      });
    </script>
  '';

  # 🦆 says ⮞ css injection
  pewpewCSS = ''
    <style>
      .color-control {
        display: flex;
        align-items: center;
        gap: 10px;
        width: 100%;
      }      
      .hue-slider {
        flex-grow: 1;
        height: 20px;
        background: linear-gradient(to right,
          #ff0000, #ffff00, #00ff00, #00ffff, #0000ff, #ff00ff, #ff0000
        );
        border-radius: 10px;
        outline: none;
      }      
      .color-preview {
        width: 30px;
        height: 30px;
        border-radius: 50%;
        border: 2px solid #ddd;
        box-shadow: 0 2px 5px rgba(0,0,0,0.1);
      }
      .room-content {
        overflow: hidden;
        transition: max-height 0.3s ease-in-out;
      }    
      .room-toggle {
        display: inline-block;
        width: 20px;
        text-align: center;
        margin-right: 8px;
      }
    </style>
  '';

  espDevicesHeader = let
    deviceEntries = lib.mapAttrsToList (name: cfg: 
      "{ \"${name}\", \"${cfg.ip}\", \"${cfg.description}\", false, 0 }"
    ) espDevices;
  in lib.concatStringsSep ",\n" deviceEntries;
 
  # 🦆 says ⮞ nix generated code injection
  boxSketchContent = lib.readFile ./../../home/sketchbook/boards/esp32s3box.ino;
  nixBoxSketch = let
    placeholders = [
      "ZIGBEEDEVICESHERE"
      "DEVICESTATUSINITHERE"
      "/* 🦆CSSANDJSINJECTFEST🦆 */"
    ];  
    replacements = [
      "String zigbeeDevicesHTML = R\"rawliteral(${roomSections})rawliteral\";"
      "${espDevicesHeader}" 
      "${pewpewCSS}${JSinject}"
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
      description = "Nix ESP32 flasher tool";
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

        # 🦆 says ⮞ datz it yo - compile and upload quaack
        # arduino-cli compile --fqbn "$board" "$tmpDir/sketch"
        # arduino-cli upload -p "$actualSerialPort" --fqbn "$board" "$tmpDir/sketch"
        arduino-cli compile --fqbn "$board" "$tmpDir/sketch"
        # 🦆 TODO ⮞ version taggin' all dat wit git pushin' all night disco duck yo       
        arduino-cli upload -p "$actualPort" $extraFlags --fqbn "$board" "$tmpDir/sketch"
      '';
    };  
  };  

  file = { # 🦆 says ⮞ let'z make dem' .nixino files cool huh
    "sketchbook/devices/esp32s3box.ino" = nixBoxSketch;
    "sketchbook/devices/esp32s3-twatch.ino" = nixWatchSketch;
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
# 🦆 says ⮞ peace out yo
