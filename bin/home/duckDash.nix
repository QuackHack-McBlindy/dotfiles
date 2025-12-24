# dotfiles/bin/home/duckDash.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ auto generate smart home dashboard
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
  mqttAuth = "-u mqtt -P $(cat ${config.house.zigbee.mosquitto.passwordFile})";

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

  pageFilesAndCss = let
    pages = config.house.dashboard.pages;
  in lib.concatStrings (lib.mapAttrsToList (pageId: page: 
    if page.css != "" then "echo '${page.css}' > $WORKDIR/page-${pageId}.css;" else ""
  ) pages);


  # 🦆 says ⮞ generate html for status cards
  statusCardsHtml = lib.concatStrings (lib.mapAttrsToList (name: card: 
    if card.enable then ''
      <div class="card" data-card="${name}">
        <div class="card-header">
          <div class="card-title">${card.title}</div>
          <i class="${card.icon}" style="color: ${card.color};"></i>
        </div>
        <div class="card-value" id="status-${name}-value">${card.defaultValue}</div>
        <div class="card-details">
          <i class="fas fa-info-circle"></i>
          <span id="status-${name}-details">${card.defaultDetails}</span>
        </div>
      </div>
    '' else ""
  ) config.house.dashboard.statusCards);

  # 🦆 says ⮞ generate js update functions
  statusCardsJs = let
    cardUpdates = lib.mapAttrsToList (name: card: 
      if card.enable then ''
        // 🦆says⮞ update function for ${name}
        function update${lib.toUpper (lib.substring 0 1 name)}${lib.substring 1 (lib.stringLength name) name}Card() {
          console.log('🦆 Fetching ${name} data from /${builtins.baseNameOf card.filePath}');
          fetch('/${builtins.baseNameOf card.filePath}')
            .then(response => {
              console.log('🦆 ${name} response status:', response.status);
              if (!response.ok) throw new Error('HTTP ' + response.status);
              return response.json();
            })
            .then(data => {
              console.log('🦆 ${name} data received:', data);
              const value = data.${card.jsonField};
              console.log('🦆 ${name} field ${card.jsonField} value:', value);
              const formattedValue = "${card.format}".replace(/\{value\}/g, value);
              console.log('🦆 ${name} formatted value:', formattedValue);
              updateCardValue("${name}", formattedValue);
              
              // 🦆 says ⮞ Handle details field
              ${if card.detailsJsonField != null then ''
                const detailsValue = data['${card.detailsJsonField}'];
                if (detailsValue !== undefined && detailsValue !== null) {
                  const formattedDetails = "${card.detailsFormat}".replace(/\{value\}/g, detailsValue);
                  updateCardDetails("${name}", formattedDetails);
                } else {
                  updateCardDetails("${name}", "${card.defaultDetails}");
                }
              '' else if card.details != "" then ''
                updateCardDetails("${name}", "${card.details}");
              '' else ''
                updateCardDetails("${name}", "${card.defaultDetails}");
              ''}
            })
            .catch(error => {
              console.error('🦆 Error fetching ${name} data:', error);
              updateCardValue("${name}", "${card.defaultValue}");
              updateCardDetails("${name}", "${card.defaultDetails}");
            });
        }
      '' else ""
    ) config.house.dashboard.statusCards;
  in lib.concatStrings cardUpdates;
  
  # 🦆 says ⮞ generate the main update function
  updateAllCardsJs = let
    functionCalls = lib.mapAttrsToList (name: card: 
      if card.enable then 
        "update${lib.toUpper (lib.substring 0 1 name)}${lib.substring 1 (lib.stringLength name) name}Card();"
      else ""
    ) config.house.dashboard.statusCards;
  in ''
    function updateAllStatusCards() {
      ${lib.concatStringsSep "\n      " functionCalls}
    }
  '';

  
  # 🦆 says ⮞ generate custom tabs HTML  
  customTabsHtml = let
    pages = config.house.dashboard.pages;
  in if pages == {} then "" else lib.concatStrings (lib.mapAttrsToList (id: page: 
    let
      iconHtml = if lib.hasPrefix "http" page.icon then
        ''<img src="${page.icon}" class="nav-icon">''
      else if lib.hasPrefix "mdi:" page.icon then
        ''<i class="mdi mdi-${lib.removePrefix "mdi:" page.icon}"></i>''
      else
        ''<i class="${page.icon}"></i>'';
    in
      ''<div class="nav-tab" data-page="${id}">${iconHtml}</div>''
  ) pages);

  # 🦆 says ⮞ generate custom pages js
  customPagesJs = "";

  # 🦆 says ⮞ auto-refresh file cards
  fileRefreshJs = ''
    setInterval(() => {
      updateAllStatusCards();
    }, 30000); // 🦆says⮞30 secs
  
    document.addEventListener('DOMContentLoaded', function() {
      setTimeout(() => {
        updateAllStatusCards();
      }, 1000);
    });
  '';

  # 🦆 says ⮞ get house.zigbee.devices
  zigbeeDevices = config.house.zigbee.devices;
  lightDevices = lib.filterAttrs (_: device: device.type == "light") zigbeeDevices;

  # 🦆 says ⮞ get house.zigbee.scenes
  zigbeeScenes = config.house.zigbee.scenes;
  zigbeeDevicesIcon = lib.mapAttrs' (id: device: {
    name = device.friendly_name;
    value = device.icon;
  }) zigbeeDevices;

  # 🦆 says ⮞ generate scene data
  sceneData = builtins.toJSON zigbeeScenes;
  iconData = builtins.toJSON zigbeeDevicesIcon;

  # 🦆 says ⮞ generate  scene gradients css
  sceneGradientCss = lib.concatStrings (lib.mapAttrsToList (name: scene: 
    let
      deviceStates = lib.mapAttrsToList (_: device: device.state) scene;
      onCount = lib.length (lib.filter (state: state == "ON") deviceStates);
      offCount = lib.length (lib.filter (state: state == "OFF") deviceStates);
      
      colors = lib.unique (lib.concatMap (device: 
        if device.state == "ON" && device ? color then [device.color.hex] else []
      ) (lib.attrValues scene));
      
      colorsLength = builtins.length colors;
      
      background = 
        if offCount > onCount then "black"
        else if colorsLength == 0 then "white"
        else if colorsLength == 1 then "linear-gradient(135deg, ${lib.elemAt colors 0} 0%, ${lib.elemAt colors 0}66 100%)"
        else 
          let
            colorStops = lib.imap0 (i: color: 
              "${color} ${toString (i * (100 / (colorsLength - 1)))}%"
            ) colors;
          in
            "linear-gradient(135deg, ${lib.concatStringsSep ", " colorStops})";
    in
      ".scene-item[data-scene=\"${lib.escapeXML name}\"] { 
        background: ${background}; 
        ${if background == "white" then "color: black;" else ""}
      }"
  ) zigbeeScenes);

  # 🦆 says ⮞ generate scene HTML  
  sceneGridHtml = lib.concatStrings (lib.mapAttrsToList (name: scene: 
    let
      colors = lib.concatMap (device: 
        if device.state == "ON" && device ? color then [device.color.hex] else []
      ) (lib.attrValues scene);
      
      deviceStates = lib.mapAttrsToList (_: device: device.state) scene;
      onCount = lib.length (lib.filter (state: state == "ON") deviceStates);
      offCount = lib.length (lib.filter (state: state == "OFF") deviceStates);
      colorsAttr = if colors != [] then "data-colors='${builtins.toJSON colors}'" else "";
      statesAttr = "data-on='${toString onCount}' data-off='${toString offCount}'";
    in
      ''<div class="scene-item" data-scene="${lib.escapeXML name}" ${colorsAttr} ${statesAttr}>
        <i class="fas fa-lightbulb"></i>
        <span>${lib.escapeXML name}</span>
      </div>''
  ) zigbeeScenes);
  
  devicesJson = pkgs.writeTextFile {
    name = "devices.json";
    text = builtins.toJSON config.house.zigbee.devices;
  };

  roomsJson = pkgs.writeTextFile {
    name = "rooms.json";
    text = builtins.toJSON config.house.rooms;
  };

  # 🦆 says ⮞ get house.tv configuration with debug info
  tvConfig = builtins.trace "TV config: ${builtins.toJSON config.house.tv}" config.house.tv;

  # 🦆 says ⮞ generate room mapping with both ID and friendly name
  roomDeviceMappings = lib.concatMapStrings (room: 
    let roomLights = devicesByRoom.${room} or [];
    in if roomLights != [] then
      let
        deviceMappings = map (d: {
          id = d.id;
          friendly_name = d.friendly_name or d.id;
        }) roomLights;
      in
        "window.roomDeviceMappings['${room}'] = " + builtins.toJSON deviceMappings + ";\n"
    else ""
  ) sortedRooms;

  # 🦆 says ⮞ generate TV selector options with debug
  tvOptions = let
    tvNames = lib.attrNames tvConfig;
    options = lib.concatMapStrings (tvName: 
      let tv = tvConfig.${tvName};
      in if tv.enable then ''<option value="${tv.ip}">${tvName}</option>'' else ""
    ) tvNames;
  in builtins.trace "TV options: ${options}" options;

  statusCards = ''
    <div class="status-cards">
      <div class="card unified-status-card" id="unifiedStatusCard">
        <div class="card-header">
          <div class="card-title" id="statusCardTitle">Status</div>
          <i class="fas fa-info-circle" id="statusCardIcon" style="color: #2ecc71;"></i>
        </div>
        <div class="card-value" id="statusCardValue">--</div>
        <div class="card-details" id="statusCardDetails">
          <i class="fas fa-clock"></i>
          <span id="statusCardTime">Waiting for data</span>
        </div>
      </div>
    </div>
  '';
  
  # 🦆 says ⮞ get house.rooms
  roomIcons = lib.mapAttrs' (name: room: {
    name = name;
    value = room.icon;
  }) config.house.rooms;
  
  devicesWithId = lib.mapAttrsToList (id: value: { inherit id; } // value) lightDevices;
  devicesByRoom = lib.groupBy (device: device.room) devicesWithId;
  sortedRooms = lib.sort (a: b: a < b) (lib.attrNames devicesByRoom);
  
  # 🦆 says ⮞ generate devices in collapsible rooms
  roomControlsHtml = let
    devicesWithId = lib.mapAttrsToList (id: value: { inherit id; } // value) lightDevices;
    devicesByRoom = lib.groupBy (device: device.room) devicesWithId;
    sortedRooms = lib.sort (a: b: a < b) (lib.attrNames devicesByRoom);
  in ''
    <div class="room-controls-section">
      <h3>Rooms</h3>
      <div class="rooms" id="roomsContainer">
        ${lib.concatMapStrings (room: 
          let 
            iconName = lib.removePrefix "mdi:" (roomIcons.${room} or "mdi:home");
            roomLights = devicesByRoom.${room} or [];
            hasLights = roomLights != [];
          in
            if hasLights then ''
              <div class="room" id="room-${room}" data-room="${room}">
                <div class="room-header">
                  <div class="room-title">
                    <i class="mdi mdi-${iconName} room-icon"></i>
                    <span class="room-name">${lib.toUpper (lib.substring 0 1 room)}${lib.substring 1 (lib.stringLength room) room}</span>
                  </div>
                  <div class="room-controls">
                    <button class="collapse-btn">▸</button>
                  </div>
                </div>
                <input class="brightness room-brightness" type="range" min="0" max="100" value="100">
                <div class="devices hidden" id="devices-${room}">
                  ${lib.concatMapStrings (device: 
                    let
                      deviceIconName = lib.removePrefix "mdi:" (device.icon or "mdi:lightbulb");
                      supportsColor = device.supports_color or false;
                      deviceColor = "#ffffff";
                    in ''
                      <div class="device" id="device-${device.id}" data-device="${device.id}">
                        <div class="device-top">
                          <div class="device-icon-container">
                            <i class="mdi mdi-${deviceIconName} device-icon"></i>
                            <div class="device-name">${device.friendly_name or device.id}</div>
                          </div>
                          <div class="device-controls">
                            <div class="controls-row">
                              ${if supportsColor then ''<input class="color-picker" type="color" value="${deviceColor}">'' else ""}
                              <label class="switch">
                                <input type="checkbox" class="device-toggle">
                                <span class="toggle-slider"></span>
                              </label>
                            </div>
                          </div>
                        </div>
                        <input class="brightness device-brightness" type="range" min="0" max="100" value="100">
                      </div>
                    ''
                  ) roomLights}
                </div>
              </div>
            '' else ""
        ) sortedRooms}
      </div>
    </div><br><br><br><br>
  '';

  roomControlCSS = ''
    :root {
      --bg: #0e1117;
      --card: #161b22;
      --text: #e6edf3;
      --muted: #8b949e;
      --border: #30363d;
      --accent: #34c759;
    }

    .room-controls-section {
      margin-top: 20px;
      padding: 0 20px;
    }
    
    .room-controls-section h3 {
      color: #ffffff;
      margin-bottom: 20px;
      font-size: 2.2rem;
      text-align: center;
      font-weight: 700;
      text-transform: uppercase;
      letter-spacing: 1px;
    }
    
    .rooms {
      display: grid;
      gap: 18px;
    }
    
    .room {
      background: var(--card);
      border-radius: 14px;
      padding: 12px 16px;
      border: 2px solid var(--border);
      transition: box-shadow 0.2s, border-color 0.2s;
    }
    
    .room.on {
      border-color: var(--room-color);
      box-shadow: 0 0 18px var(--room-color);
    }
    
    .room-header {
      display: grid;
      grid-template-columns: 1fr auto;
      gap: 10px;
      align-items: center;
      margin-bottom: 8px;
      cursor: pointer;
    }
    
    .room-title {
      font-size: 18px;
      font-weight: 600;
      display: flex;
      gap: 12px;
      align-items: center;
    }
    
    .room-icon {
      font-size: 1.8rem;
      display: flex;
      align-items: center;
      justify-content: center;
      min-width: 32px;
    }
    
    .room-name {
      font-size: 1.5rem;
    }
    
    .room-controls {
      display: flex;
      gap: 8px;
      align-items: center;
    }
    
    .devices {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
      gap: 12px;
      margin-top: 12px;
    }
    
    .devices.hidden {
      display: none;
    }
    
    .device {
      background: #0b0f14;
      border-radius: 12px;
      padding: 12px;
      border: 2px solid var(--border);
      display: flex;
      flex-direction: column;
      gap: 10px;
      transition: box-shadow 0.15s, border-color 0.15s, opacity 0.15s;
      min-height: 120px;
    }
    
    .device.on {
      border-color: var(--device-color);
      box-shadow: 0 0 10px var(--device-color);
    }
    
    .device.off {
      opacity: 0.75;
    }
    
    .device-top {
      display: flex;
      justify-content: space-between;
      align-items: center;
      gap: 8px;
      flex-grow: 1;
    }
    
    .device-icon-container {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 8px;
      min-width: 40px;
    }
    
    .device-icon {
      font-size: 1.8rem;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    
    .device-name {
      font-size: 14px;
      font-weight: 600;
      text-align: center;
      color: var(--text);
      overflow: hidden;
      text-overflow: ellipsis;
      display: -webkit-box;
      -webkit-line-clamp: 2;
      -webkit-box-orient: vertical;
      line-height: 1.3;
      min-height: 36px;
    }
    
    .device-controls {
      display: flex;
      flex-direction: column;
      align-items: flex-end;
      gap: 8px;
      flex-grow: 1;
    }
    
    .controls-row {
      display: flex;
      align-items: center;
      gap: 10px;
      width: 100%;
      justify-content: space-between;
    }
    
    .device .switch {
      position: relative;
      display: inline-block;
      width: 52px;
      height: 28px;
      min-width: 52px;
    }
    
    .device .switch input {
      opacity: 0;
      width: 0;
      height: 0;
    }
    
    .device .toggle-slider {
      position: absolute;
      cursor: pointer;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background-color: #3a3f45;
      transition: .4s;
      border-radius: 34px;
    }
    
    .device .toggle-slider:before {
      position: absolute;
      content: "";
      height: 20px;
      width: 20px;
      left: 4px;
      bottom: 4px;
      background-color: white;
      transition: .4s;
      border-radius: 50%;
    }
    
    .device input:checked + .toggle-slider {
      background-color: var(--accent);
    }
    
    .device input:checked + .toggle-slider:before {
      transform: translateX(24px);
    }
    
    .color-picker {
      width: 28px;
      height: 28px;
      border: 2px solid var(--border);
      border-radius: 50%;
      background: none;
      cursor: pointer;
      padding: 0;
      min-width: 28px;
    }
    
    .color-picker::-webkit-color-swatch {
      border-radius: 50%;
      border: none;
    }
    
    .color-picker::-moz-color-swatch {
      border-radius: 50%;
      border: none;
    }
    
    .device-brightness, .room-brightness {
      width: 100%;
      margin-top: 8px;
      display: none;
    }
    
    .device.on .device-brightness {
      display: block;
    }
    
    .room.on .room-brightness {
      display: block;
    }
    
    input[type="range"] {
      -webkit-appearance: none;
      width: 100%;
      height: 6px;
      background: #30363d;
      border-radius: 5px;
      outline: none;
    }
    
    input[type="range"]::-webkit-slider-thumb {
      -webkit-appearance: none;
      width: 20px;
      height: 20px;
      border-radius: 50%;
      background: white;
      cursor: pointer;
      border: 2px solid var(--border);
    }
    
    input[type="range"]::-moz-range-thumb {
      width: 20px;
      height: 20px;
      border-radius: 50%;
      background: white;
      cursor: pointer;
      border: 2px solid var(--border);
    }
    
    .collapse-btn {
      background: none;
      border: none;
      color: var(--muted);
      cursor: pointer;
      font-size: 18px;
      padding: 6px 10px;
      border-radius: 6px;
      transition: background-color 0.2s, transform 0.2s;
      min-width: 36px;
    }
    
    .collapse-btn:hover {
      background-color: rgba(255, 255, 255, 0.1);
      transform: scale(1.1);
    }
    
    @media (max-width: 768px) {
      .devices {
        grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
        gap: 10px;
      }
      
      .device {
        padding: 10px;
        min-height: 110px;
      }
      
      .device-icon {
        font-size: 1.6rem;
      }
      
      .device-name {
        font-size: 13px;
      }
    }
    
    @media (max-width: 480px) {
      .devices {
        grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));
      }
      
      .room-controls-section {
        padding: 0 12px;
      }
      
      .room {
        padding: 10px 12px;
      }
    }
  '';

  roomControlJs = '' 
    function syncRoomStatesAfterLoad() {
        console.log('🦆 Syncing room states after load...');   
        document.querySelectorAll('.room').forEach(roomEl => {
            const roomName = roomEl.getAttribute('data-room');
            const deviceElements = Array.from(roomEl.querySelectorAll('.device'));
            let anyOn = false;
        
            deviceElements.forEach(device => {
                const deviceId = device.getAttribute('data-device');
                const deviceData = window.devices[deviceId];
                const toggle = device.querySelector('.device-toggle');
            
                if (deviceData && deviceData.state === 'ON' && toggle) {
                    toggle.checked = true;
                    device.classList.add('on');
                    device.classList.remove('off');
                    anyOn = true;
                }
            });
        
            if (anyOn) {
                roomEl.classList.add('on');
            
                const roomBrightnessSlider = roomEl.querySelector('.room-brightness');
                if (roomBrightnessSlider) {
                    roomBrightnessSlider.style.display = 'block';
                }
            } else {
                roomEl.classList.remove('on');
            }
        });
    
        updateRoomColors();
    }
 
    // 🦆 says ⮞ room control func
    function updateRoomColors() {
        document.querySelectorAll('.room').forEach(roomEl => {
            const roomName = roomEl.getAttribute('data-room');
            const deviceElements = Array.from(roomEl.querySelectorAll('.device'));
            const anyOn = deviceElements.some(device => {
                const toggle = device.querySelector('.device-toggle');
                return device.classList.contains('on') || (toggle && toggle.checked);
            });
        
            if (anyOn) {
                const onDevices = deviceElements.filter(device => {
                    const toggle = device.querySelector('.device-toggle');
                    return device.classList.contains('on') || (toggle && toggle.checked);
                });
            
                let r = 0, g = 0, b = 0, count = 0;
            
                onDevices.forEach(device => {
                    const colorPicker = device.querySelector('.color-picker');
                    const toggle = device.querySelector('.device-toggle');
                
                    if (colorPicker && toggle && toggle.checked) {
                        const color = colorPicker.value;
                        const c = color.replace('#', "");
                        r += parseInt(c.substr(0, 2), 16);
                        g += parseInt(c.substr(2, 2), 16);
                        b += parseInt(c.substr(4, 2), 16);
                        count++;
                    }
                });
            
                if (count > 0) {
                    r = Math.round(r / count);
                    g = Math.round(g / count);
                    b = Math.round(b / count);
                    const roomColor = `rgb(''${r}, ''${g}, ''${b})`;
                    roomEl.style.setProperty('--room-color', roomColor);
                    roomEl.classList.add('on');
                } else {
                    roomEl.classList.remove('on');
                }
            } else {
                roomEl.classList.remove('on');
            }
        });
    }
    
    function toggleRoom(roomName, state) {
      console.log('🦆 Toggle room:', roomName, state);
      const devices = window.roomDevices ? window.roomDevices[roomName] : [];
      if (!devices || devices.length === 0) {
        console.error('No devices found for room:', roomName);
        showNotification('No devices found in ' + roomName, 'error');
        return;
      }
      
      const command = { state: state ? 'ON' : 'OFF' };
      console.log('🦆 Sending command to devices:', devices, command);
      
      devices.forEach(device => {
        if (window.sendCommand) {
          window.sendCommand(device, command);
        } else {
          console.error('sendCommand not available');
        }
      });
      
      showNotification(`''${state ? 'Turning on' : 'Turning off'} ''${roomName}`, 'success');
    }
    
    function setRoomBrightness(roomName, brightness) {
      console.log('🦆 Set room brightness:', roomName, brightness);
      const devices = window.roomDevices ? window.roomDevices[roomName] : [];
      if (!devices || devices.length === 0) {
        console.error('No devices found for room:', roomName);
        return;
      }
      
      const command = { brightness: Math.round((parseInt(brightness) / 100) * 255) };
      console.log('🦆 Sending brightness to devices:', devices, command);
      
      devices.forEach(device => {
        if (window.sendCommand) {
          window.sendCommand(device, command);
        } else {
          console.error('sendCommand not available');
        }
      });
    }
    
    function setDeviceBrightness(deviceId, brightness) {
      console.log('🦆 Set device brightness:', deviceId, brightness);
      const command = { brightness: Math.round((parseInt(brightness) / 100) * 255) };
      
      if (window.sendCommand) {
        window.sendCommand(deviceId, command);
      } else {
        console.error('sendCommand not available');
      }
    }
    
    function setDeviceColor(deviceId, color) {
      console.log('🦆 Set device color:', deviceId, color);
      const hex = color.replace('#', "");
      const r = parseInt(hex.substr(0,2), 16);
      const g = parseInt(hex.substr(2,2), 16);
      const b = parseInt(hex.substr(4,2), 16);
      
      const command = { color: { r, g, b } };
      
      if (window.sendCommand) {
        window.sendCommand(deviceId, command);
      } else {
        console.error('sendCommand not available');
      }
    }
    
    function initRoomControls() {
      document.querySelectorAll('.room-header').forEach(header => {
        header.addEventListener('click', function(e) {
          if (e.target.classList.contains('collapse-btn')) return;
          
          const roomEl = this.closest('.room');
          const roomName = roomEl.getAttribute('data-room');
          const devices = roomEl.querySelectorAll('.device');
          const anyOn = Array.from(devices).some(device => 
            device.classList.contains('on')
          );
          
          toggleRoom(roomName, !anyOn);
        });
      });
      
      // 🦆 says ⮞ handle collapse button clicks
      document.querySelectorAll('.collapse-btn').forEach(btn => {
        btn.addEventListener('click', function(e) {
          e.stopPropagation();
          const roomEl = this.closest('.room');
          const devicesEl = roomEl.querySelector('.devices');
          devicesEl.classList.toggle('hidden');
          this.textContent = devicesEl.classList.contains('hidden') ? '▸' : '▾';
        });
      });
      
      document.querySelectorAll('.device-toggle').forEach(toggle => {
        toggle.addEventListener('change', function() {
          const deviceEl = this.closest('.device');
          const deviceId = deviceEl.getAttribute('data-device');
          const command = { state: this.checked ? 'ON' : 'OFF' };
          
          if (window.sendCommand) {
            window.sendCommand(deviceId, command);
          }
          
          deviceEl.classList.toggle('on', this.checked);
          deviceEl.classList.toggle('off', !this.checked);
          
          const brightnessSlider = deviceEl.querySelector('.device-brightness');
          if (brightnessSlider) {
            brightnessSlider.style.display = this.checked ? 'block' : 'none';
          }
          
          updateRoomColors();
        });
      });
      
      document.querySelectorAll('.device-brightness').forEach(slider => {
        slider.addEventListener('input', function() {
          const deviceEl = this.closest('.device');
          const deviceId = deviceEl.getAttribute('data-device');
          setDeviceBrightness(deviceId, this.value);
        });
      });
      
      document.querySelectorAll('.room-brightness').forEach(slider => {
        slider.addEventListener('input', function() {
          const roomEl = this.closest('.room');
          const roomName = roomEl.getAttribute('data-room');
          setRoomBrightness(roomName, this.value);
        });
      });
      
      document.querySelectorAll('.color-picker').forEach(picker => {
        picker.addEventListener('input', function() {
          const deviceEl = this.closest('.device');
          const deviceId = deviceEl.getAttribute('data-device');
          setDeviceColor(deviceId, this.value);
          
          deviceEl.style.setProperty('--device-color', this.value);
          deviceEl.classList.add('on');
          
          updateRoomColors();
        });
      });
    }
    
    function updateDeviceUIFromMQTT(deviceId, data) {
      const deviceEl = document.getElementById('device-''${deviceId}');
      if (!deviceEl) return;      
      const toggle = deviceEl.querySelector('.device-toggle');
      const brightnessSlider = deviceEl.querySelector('.device-brightness');
      const colorPicker = deviceEl.querySelector('.color-picker');
      
      if (toggle && data.state !== undefined) {
        toggle.checked = data.state === 'ON';
        deviceEl.classList.toggle('on', data.state === 'ON');
        deviceEl.classList.toggle('off', data.state !== 'ON');
        
        if (brightnessSlider) {
          brightnessSlider.style.display = data.state === 'ON' ? 'block' : 'none';
        }
      }
      
      if (brightnessSlider && data.brightness !== undefined) {
        const percent = Math.round((data.brightness / 254) * 100);
        brightnessSlider.value = percent;
      }
      
      if (colorPicker && data.color && data.color.hex) {
        colorPicker.value = data.color.hex;
        deviceEl.style.setProperty('--device-color', data.color.hex);
      }
      
      const roomEl = deviceEl.closest('.room');
      if (roomEl) {
        const roomName = roomEl.getAttribute('data-room');
        const anyOn = Array.from(roomEl.querySelectorAll('.device')).some(device => 
          device.classList.contains('on')
        );
        
        const roomBrightnessSlider = roomEl.querySelector('.room-brightness');
        if (roomBrightnessSlider) {
          roomBrightnessSlider.style.display = anyOn ? 'block' : 'none';
        }
        
        updateRoomColors();
      }
    }
        
    function updateAllRoomControls() {
        console.log('🦆 updateAllRoomControls called');
        console.log('🦆 window.devices:', window.devices);
        console.log('🦆 window.roomDeviceMappings:', window.roomDeviceMappings);
        if (!window.roomDeviceMappings) {
            console.error('🦆 window.roomDeviceMappings is not defined');
            return;
        }

        if (!window.devices || Object.keys(window.devices).length === 0) {
            console.error('🦆 window.devices is empty or not defined');
            return;
        }

        Object.entries(window.roomDeviceMappings).forEach(([roomName, deviceMappings]) => {
            console.log(`🦆 Processing room "''${roomName}" with devices:`, deviceMappings);
    
            deviceMappings.forEach(deviceInfo => {
                const deviceId = deviceInfo.id;
                const friendlyName = deviceInfo.friendly_name;
        
                let deviceData = window.devices[deviceId];
            
                if (!deviceData) {
                    deviceData = window.devices[friendlyName];
                }
            
                if (!deviceData) {
                    const foundKey = Object.keys(window.devices).find(key => 
                        key.includes(deviceId) || 
                        key.includes(friendlyName) ||
                        (window.devices[key] && window.devices[key].friendly_name === friendlyName)
                    );
                    if (foundKey) {
                        deviceData = window.devices[foundKey];
                    }
                }
        
                console.log(`🦆 Device ''${deviceId}/''${friendlyName} data:`, deviceData);
        
                if (deviceData) {
                    updateDeviceInRoom(deviceId, deviceData);
                } else {
                    console.warn(`🦆 No data found for device ''${deviceId}/''${friendlyName}`);
                }
            });
    
            updateRoomHeaderState(roomName);
        });

        updateRoomColors();
        console.log('🦆 Room controls updated');
    }
    
    function updateDeviceInRoom(deviceId, data) {
        const deviceElementId = 'device-' + deviceId;
        const deviceEl = document.getElementById(deviceElementId);  
        if (!deviceEl) {
            console.warn(`🦆 Device element not found for ID: ''${deviceId}`);
        
            const altEl = document.querySelector(`[data-device="''${deviceId}"]`);
            if (altEl) {
                deviceEl = altEl;
            } else {
                const allDeviceEls = document.querySelectorAll('[data-device]');
                for (const el of allDeviceEls) {
                    if (el.querySelector('.device-name')?.textContent === deviceId) {
                        deviceEl = el;
                        break;
                    }
                }
            }
        
            if (!deviceEl) {
                console.error(`🦆 Could not find device element for: ''${deviceId}`);
                return;
            }
        } 
        
        const toggle = deviceEl.querySelector('.device-toggle');
        const brightnessSlider = deviceEl.querySelector('.device-brightness');
        const colorPicker = deviceEl.querySelector('.color-picker');
        
        let deviceState = data.state;
        if (deviceState === undefined) {
            deviceState = data.State || data.STATE || data.power || data.Power;
        }
        
        console.log(`🦆 Device ''${deviceId} state:`, deviceState, 'from data:', data);
        
        if (toggle && deviceState !== undefined) {
            const isOn = typeof deviceState === 'string' 
                ? deviceState.toUpperCase() === 'ON'
                : Boolean(deviceState);
            
            toggle.checked = isOn;
            deviceEl.classList.toggle('on', isOn);
            deviceEl.classList.toggle('off', !isOn);
            
            if (brightnessSlider) {
                brightnessSlider.style.display = isOn ? 'block' : 'none';
            }
        } else if (toggle) {
            console.warn(`🦆 No state found for device ''${deviceId}`);
        }
        
        if (brightnessSlider && data.brightness !== undefined) {
            const percent = Math.round((data.brightness / 254) * 100);
            brightnessSlider.value = percent;
            console.log(`🦆 Device ''${deviceId} brightness: ''${percent}%`);
        }
        
        if (colorPicker && data.color) {
            const colorHex = normalizeColorFromState(data.color);
            if (colorHex) {
                colorPicker.value = colorHex;
                deviceEl.style.setProperty('--device-color', colorHex);
            }
        }
    }
        
    function normalizeColorFromState(colorData) {
      if (!colorData) return '#ffffff';      
      try {
        if (colorData.hex) {
          return colorData.hex;
        }
        
        if (typeof colorData === 'string') {
          const parsed = JSON.parse(colorData);
          return normalizeColorFromState(parsed);
        }
        
        if (colorData.x !== undefined && colorData.y !== undefined) {
          const { x, y } = colorData;
          const z = 1.0 - x - y;
          const Y = 1.0; // Assuming full brightness
          const X = (Y / y) * x;
          const Z = (Y / y) * z;
          
          let r = X * 1.656492 - Y * 0.354851 - Z * 0.255038;
          let g = -X * 0.707196 + Y * 1.655397 + Z * 0.036152;
          let b = X * 0.051713 - Y * 0.121364 + Z * 1.011530;
          
          r = r <= 0.0031308 ? 12.92 * r : 1.055 * Math.pow(r, 1/2.4) - 0.055;
          g = g <= 0.0031308 ? 12.92 * g : 1.055 * Math.pow(g, 1/2.4) - 0.055;
          b = b <= 0.0031308 ? 12.92 * b : 1.055 * Math.pow(b, 1/2.4) - 0.055;
          
          r = Math.round(Math.max(0, Math.min(1, r)) * 255);
          g = Math.round(Math.max(0, Math.min(1, g)) * 255);
          b = Math.round(Math.max(0, Math.min(1, b)) * 255);
          
          return `#''${((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1)}`;
        }
        
        if (colorData.hue !== undefined || colorData.h !== undefined) {
          const h = (colorData.hue || colorData.h || 0) / 360;
          const s = ((colorData.saturation || colorData.s || 100) / 100);
          const v = 1;
          
          const i = Math.floor(h * 6);
          const f = h * 6 - i;
          const p = v * (1 - s);
          const q = v * (1 - f * s);
          const t = v * (1 - (1 - f) * s);
          
          let r, g, b;
          switch (i % 6) {
            case 0: r = v, g = t, b = p; break;
            case 1: r = q, g = v, b = p; break;
            case 2: r = p, g = v, b = t; break;
            case 3: r = p, g = q, b = v; break;
            case 4: r = t, g = p, b = v; break;
            case 5: r = v, g = p, b = q; break;
          }
          
          r = Math.round(r * 255);
          g = Math.round(g * 255);
          b = Math.round(b * 255);
          
          return `#''${((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1)}`;
        }
        
      } catch (e) {
        console.warn('Failed to parse color:', colorData, e);
      }
      
      return '#ffffff';
    }
    
    // 🦆 says ⮞ update room state
    function updateRoomHeaderState(roomName) {
      const roomEl = document.getElementById('room-' + roomName);
      if (!roomEl) return;
      
      const deviceIds = window.roomDevices[roomName] || [];
      const anyOn = deviceIds.some(deviceId => {
        const deviceData = window.devices[deviceId];
        return deviceData && deviceData.state === 'ON';
      });
      
      const roomBrightnessSlider = roomEl.querySelector('.room-brightness');
      if (roomBrightnessSlider) {
        roomBrightnessSlider.style.display = anyOn ? 'block' : 'none';
      }
      
      if (anyOn) {
        const onDevices = deviceIds.filter(id => 
          window.devices[id] && window.devices[id].state === 'ON' && window.devices[id].brightness
        );
        
        let avgBrightness = 100;
        if (onDevices.length > 0) {
          const totalBrightness = onDevices.reduce((sum, deviceId) => {
            const brightness = window.devices[deviceId].brightness;
            return sum + (brightness || 0);
          }, 0);
          avgBrightness = Math.round((totalBrightness / onDevices.length) / 2.54); // Convert 0-255 to 0-100
        }
        
        if (roomBrightnessSlider) {
          roomBrightnessSlider.value = avgBrightness;
        }
      }
    }
    
    // 🦆 says ⮞ sync room toggles based on device states
    function syncRoomTogglesFromState() {
      if (!window.roomDevices || !window.devices) return;
      
      Object.entries(window.roomDevices).forEach(([roomName, deviceIds]) => {
        const anyDeviceOn = deviceIds.some(deviceId => {
          const device = window.devices[deviceId];
          return device && device.state === 'ON';
        });
        
        const roomEl = document.getElementById(`room-''${roomName}`);
        if (roomEl) {
          roomEl.classList.toggle('on', anyDeviceOn);
          roomEl.classList.toggle('off', !anyDeviceOn);
          
          const roomBrightnessSlider = roomEl.querySelector('.room-brightness');
          if (roomBrightnessSlider) {
            roomBrightnessSlider.style.display = anyDeviceOn ? 'block' : 'none';
          }
        }
      });
    }
    
    function setInitialRoomCollapse() {
      document.querySelectorAll('.room').forEach(roomEl => {
        const roomName = roomEl.getAttribute('data-room');
        const devicesInRoom = window.roomDevices[roomName] || [];
        
        const anyOn = devicesInRoom.some(deviceId => 
          window.devices[deviceId] && window.devices[deviceId].state === 'ON'
        );
        
        if (!anyOn) {
          const devicesEl = roomEl.querySelector('.devices');
          const collapseBtn = roomEl.querySelector('.collapse-btn');
          if (devicesEl && collapseBtn) {
            devicesEl.classList.add('hidden');
            collapseBtn.textContent = '▸';
          }
        }
      });
    }
    
    window.updateDeviceUIFromMQTT = updateDeviceUIFromMQTT;
    window.updateAllRoomControls = updateAllRoomControls;
    window.syncRoomTogglesFromState = syncRoomTogglesFromState;
    window.setInitialRoomCollapse = setInitialRoomCollapse;
  '';

  
  httpServer = pkgs.writeShellScriptBin "serve-dashboard" ''
    HOST=''${1:-0.0.0.0}
    PORT=''${2:-13337}
    CERT=''${3:-}
    KEY=''${4:-}
    WORKDIR=$(mktemp -d)

    ln -sf /etc/login.html $WORKDIR/  
    ln -sf /etc/index.html $WORKDIR/
    ln -sf /etc/devices.json $WORKDIR/
    ln -sf /etc/rooms.json $WORKDIR/
    ln -sf /etc/tv.json $WORKDIR/
    ln -sf /var/lib/zigduck/state.json $WORKDIR/  
    ln -sf /etc/static/epg.json $WORKDIR/   
    ln -sf /etc/static/tv.html $WORKDIR/   
    ln -sf /etc/static/favicon.ico $WORKDIR/   

    # 🦆 says ⮞ symlink all status card JSON files
    ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: card: 
      if card.enable then "ln -sf ${card.filePath} $WORKDIR/${builtins.baseNameOf card.filePath};" else ""
    ) config.house.dashboard.statusCards)}

    # 🦆 says ⮞ process page files from dashboard configuration
    ${lib.concatStringsSep "\n" (lib.flatten (lib.mapAttrsToList (_: page:
      lib.mapAttrsToList (name: source: 
        if lib.isString source then
          "ln -sf ${source} $WORKDIR/${name}"
        else
          "ln -sf ${toString source} $WORKDIR/${name}"
      ) (page.files or {})
    ) config.house.dashboard.pages))}

    # 🦆 says ⮞ CSS files only (no matter what it says below)
    ${pageFilesAndCss}

    # 🦆 says ⮞ TV icons
    mkdir -p $WORKDIR/tv-icons
    ${lib.concatMapStrings (tvName: 
        let tv = tvConfig.${tvName};
        in lib.concatMapStrings (channelId: 
            let channel = tv.channels.${channelId};
            in "ln -sf ${channel.icon} $WORKDIR/tv-icons/${channelId}.png\n"
        ) (lib.attrNames tv.channels)
    ) (lib.attrNames tvConfig)}
  

    cat > $WORKDIR/simple_server.py << 'EOF'
import http.server
import socketserver
import os
import urllib.parse
import json
import hashlib
import sys
import time
import ssl
from pathlib import Path

password_file = "${config.house.dashboard.passwordFile}"
with open(password_file, "r") as f:
    PASSWORD = f.read().strip()

sessions = {}

class SimpleAuthHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        self.directory = os.getcwd()
        super().__init__(*args, directory=self.directory, **kwargs)
    
    def do_GET(self):
        auth_cookie = self.headers.get('Cookie', "")
        is_authenticated = False        
        for cookie in auth_cookie.split(';'):
            cookie = cookie.strip()
            if cookie.startswith('auth_token='):
                token = cookie.split('auth_token=')[1]
                if token in sessions:
                    is_authenticated = True
        
        if self.path in ['/login', '/login.html', '/submit']:
            return super().do_GET()
        
        if not is_authenticated:
            self.send_response(302)
            self.send_header('Location', '/login.html')
            self.end_headers()
            return
        
        return super().do_GET()
    
    def do_POST(self):
        if self.path == '/submit':
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length).decode('utf-8')
            parsed_data = urllib.parse.parse_qs(post_data)
            password = parsed_data.get('password', [""])[0]
            
            if password == PASSWORD:
                import uuid
                token = str(uuid.uuid4())
                sessions[token] = time.time()
                
                self.send_response(302)
                self.send_header('Location', '/')
                self.send_header('Set-Cookie', f'auth_token={token}; Path=/; HttpOnly; SameSite=Lax')
                self.send_header('Set-Cookie', f'api_password={PASSWORD}; Path=/; SameSite=Lax')   
                self.end_headers()
                print("Login successful!")
            else:
                self.send_response(401)
                self.send_header('Content-type', 'text/html')
                self.end_headers()
                self.wfile.write(b'<html><body>Access denied. <a href="/login.html">Try again</a></body></html>')
                print("Login failed!")
        else:
            self.send_response(404)
            self.end_headers()

    def log_message(self, format, *args):
        pass

if __name__ == '__main__':
    os.chdir(os.path.dirname(__file__))    
    port = int(os.environ.get('PORT', 13337))
    
    cert_file = os.environ.get('CERT_FILE', "")
    key_file = os.environ.get('KEY_FILE', "")
    
    httpd = socketserver.TCPServer(("", port), SimpleAuthHandler)
    
    ssl_context = None
    if cert_file and key_file and os.path.exists(cert_file) and os.path.exists(key_file):
        try:
            ssl_context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
            ssl_context.load_cert_chain(cert_file, key_file)
            
            httpd.socket = ssl_context.wrap_socket(httpd.socket, server_side=True)
            print(f"🦆 HTTPS server started on https://0.0.0.0:{port}")
            
        except Exception as e:
            print(f"🦆 SSL setup failed: {e}, falling back to HTTP")
            print(f"🦆 HTTP server started on http://0.0.0.0:{port}")
    else:
        print(f"🦆 No SSL certificates found, starting HTTP server on http://0.0.0.0:{port}")
        print(f"🦆 Cert file: {cert_file}, Key file: {key_file}")
    
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        httpd.shutdown()
EOF

    export PORT=$PORT
    export CERT_FILE="$CERT"
    export KEY_FILE="$KEY"
    cd $WORKDIR
    
    if [ -n "$CERT" ] && [ -n "$KEY" ]; then
        echo "🦆 Starting SECURE dashboard server on https://$HOST:$PORT"
    else
        echo "🦆 Starting INSECURE dashboard server on http://$HOST:$PORT"
        echo "🦆 Warning: No SSL certificates provided, audio streaming may not work on mobile!"
    fi
    
    echo "🦆 Starting dashboard server on http://$HOST:$PORT"
    ${pkgs.python3}/bin/python3 simple_server.py
  '';

  customPagesHtml = let
    pages = config.house.dashboard.pages;
  in if pages == {} then "" else lib.concatStrings (lib.mapAttrsToList (id: page: 
    let
      cssLink = if page.css != "" then ''<link rel="stylesheet" href="/page-${id}.css">'' else "";
    in
      ''<div class="page" id="pageCustom${id}" data-page="${id}">
          ${cssLink}
          ${page.code}
        </div>''
  ) pages);


  # 🦆 says ⮞ LOGIN/AUTHENTICATION PAGE  
  login = ''
    <!DOCTYPE html>
    <html lang="en">
    <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login</title>
    <style>
    body {
      margin: 0;
      height: 100vh;
      overflow: hidden;
      display: flex;
      justify-content: center;
      align-items: center;
      font-family: monospace;
      background: black;
      position: relative;
    }
    
    .emoji {
      position: absolute;
      top: -50px;
      font-size: 2rem;
      animation: fall linear infinite;
    }
    
    .duck { font-size: 3rem; }
    
    .heart {
      font-size: 2rem;
      transition: transform 0.3s ease;
    }
    
    .heart:hover {
      transform: scale(2);
      opacity: 0;
    }
    
    @keyframes fall {
      to { transform: translateY(100vh); }
    }
    
    #beginButton {
      font-size: 2rem;
      padding: 12px 40px;
      background: linear-gradient(45deg, #00ff00, #00ccff, #ff00ff);
      background-size: 300% 300%;
      color: black;
      border: 2px solid #00FF00;
      border-radius: 12px;
      cursor: pointer;
      z-index: 300;
      animation: gradientAnimation 3s ease infinite, fadeIn 2s forwards;
      box-shadow: 0 0 20px #00ff00, 0 0 40px #00ff00, 0 0 60px #00ff00;
      transition: transform 0.3s ease, box-shadow 0.3s ease;
    }
    
    #beginButton:hover {
      transform: scale(1.2) rotate(-5deg);
      box-shadow: 0 0 40px #00ff00, 0 0 80px #00ff00, 0 0 120px #00ff00;
    }
    
    @keyframes gradientAnimation {
      0% { background-position: 0% 50%; }
      50% { background-position: 100% 50%; }
      100% { background-position: 0% 50%; }
    }
    
    
    @keyframes fadeIn {
      to { opacity: 1; }
    }
    
    @keyframes flyAway {
      to {
        transform: translate(var(--x), var(--y)) scale(1.5) rotate(720deg);
        opacity: 0;
      }
    }
    
    #matrixScreen {
      display: none;
      position: fixed;
      inset: 0;
      background: black;
      color: #00ff00;
      font-size: 2rem;
      padding: 2rem;
      overflow: hidden;
      opacity: 0;
      transition: opacity 2s ease;
    }
    
    #matrixScreen.show {
      display: block;
      opacity: 1;
    }
    
    .cursor {
      animation: blink 1s infinite;
    }
    
    @keyframes blink {
      50% { opacity: 0; }
    }
    
    #loginPage {
      display: none;
      position: fixed;
      inset: 0;
      background: black;
      color: #00FF00;
      font-family: "Courier New", monospace;
      justify-content: center;
      align-items: center;
      opacity: 0;
      transition: opacity 2s ease;
    }
    
    #loginPage.show {
      display: flex;
      opacity: 1;
    }
    
    .login-container {
      border: 2px solid #00FF00;
      padding: 20px;
      width: 300px;
      text-align: center;
    }
    
    .login-container h1 {
      font-size: 24px;
      margin-bottom: 20px;
    }
    
    .login-container input {
      background-color: black;
      border: 2px solid #00FF00;
      color: #00FF00;
      padding: 10px;
      width: 80%;
      margin: 10px;
      font-size: 16px;
      text-align: center;
    }
    
    .login-container input[type="submit"] {
      cursor: pointer;
      background-color: #00FF00;
      color: black;
      border: none;
      transition: all 0.3s ease;
    }
    
    .login-container input[type="submit"]:hover {
      background-color: #00CC00;
    }
    
    .message {
      font-size: 14px;
      margin-top: 20px;
      color: #FF4500;
    }
    
    .message a {
      color: #00FF00;
      text-decoration: none;
    }
    </style>
    </head>
    
    <body>
    
    <button id="beginButton">Login!</button>
    
    <div id="matrixScreen">
      <div id="matrixText"></div>
    </div>
    
    <div id="loginPage">
      <div class="login-container">
        <h1>Enter the System</h1>
        <form action="/submit" method="POST">
          <input type="password" name="password" placeholder="Password" required>
          <input type="submit" value="Log In">
        </form>
        <div class="message">
          <p>Warning: Unauthorized access will be logged and <strong>punished</strong> accordingly!</p>
        </div>
      </div>
    </div>
    
    <script>
    const emojis = ['🦆','🦆','🦆','🦆','❤️'];
        
    for (let i = 0; i < 200; i++) {
      const e = document.createElement('div');
      e.classList.add('emoji');    
      const type = emojis[Math.floor(Math.random() * emojis.length)];
      e.innerText = type;
    
      if (type === '🦆') e.classList.add('duck');
      else e.classList.add('heart');
    
      e.style.left = Math.random() * 100 + 'vw';
      e.style.animationDuration = Math.random() * 3 + 5 + 's';
      e.style.animationDelay = Math.random() * 5 + 's';    
      document.body.appendChild(e);
    }
    
    document.getElementById('beginButton').addEventListener('click', function () {
      const emojis = document.querySelectorAll('.emoji');    
      emojis.forEach(e => {
        const x = (Math.random() - 0.5) * 2000;
        const y = (Math.random() - 0.5) * 2000;
        e.style.setProperty('--x', `''${x}px`);
        e.style.setProperty('--y', `''${y}px`);
        e.style.animation = 'flyAway 1.5s forwards';
      });
    
      this.style.display = 'none';
    
      setTimeout(() => {
        const matrix = document.getElementById('matrixScreen');
        matrix.classList.add('show');
        startMatrix();
      }, 1500);
    });
    
    function startMatrix() {
      const matrixText = document.getElementById('matrixText');    
      const lines = [
        '> enter authentication...',
      ];
    
      let i = 0;
      let j = 0;
    
      function type() {
        if (i >= lines.length) {
          setTimeout(fadeToLogin, 1500);
          return;
        }
    
        matrixText.innerHTML += lines[i][j] + '<span class="cursor">█</span>';
        j++;
        if (j === lines[i].length) {
          matrixText.innerHTML += '<br>';
          i++;
          j = 0;
        }
        setTimeout(type, 30);
      }    
      type();
    }
    
    function fadeToLogin() {
      const matrix = document.getElementById('matrixScreen');
      const login = document.getElementById('loginPage');
      matrix.style.opacity = 0;
      setTimeout(() => {
        matrix.style.display = 'none';
        login.style.display = 'flex';
    
        setTimeout(() => {
          login.classList.add('show');
        }, 50);
    
      }, 2000);
    }
    </script>    
    </body>
    </html>      
  '';


  # 🦆 says ⮞ letz convert the website into an iOS application (Open Safari & Save bookmark to homescreen) 
  iOSmanifest = pkgs.writeText "manifest.json" ''
    {
      "name": "🦆'Dash",
      "short_name": "🦆'Dash",
      "start_url": "/",
      "display": "standalone",
      "background_color": "#ffffff",
      "theme_color": "#ffffff",
      "icons": [
        {
          "src": "/icon-192.png",
          "sizes": "192x192",
          "type": "image/png"
        },
        {
          "src": "/icon-512.png",
          "sizes": "512x512",
          "type": "image/png"
        }
      ]
    }
  '';

  # 🦆 says ⮞ MAIN DASHBOARD INDEX.HTML    
  indexHtml = ''    
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta name="apple-mobile-web-app-capable" content="yes">
        <meta name="apple-mobile-web-app-status-bar-style" content="default">
        <meta name="apple-mobile-web-app-title" content="🦆'Dash">
        <link rel="apple-touch-icon" href="/icon-192.png">
        <link rel="manifest" href="${iOSmanifest}">
               
        <title>🦆'Dash</title>
        <link rel="preconnect" href="https://cdn.jsdelivr.net">
        <link rel="dns-prefetch" href="https://cdn.jsdelivr.net">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link rel="stylesheet" href="https://raw.githack.com/QuackHack-McBlindy/dotfiles/main/modules/themes/css/duckdash2.css">        
        <link href="https://cdn.jsdelivr.net/npm/@mdi/font/css/materialdesignicons.min.css" rel="stylesheet">
        <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@600&display=swap" rel="stylesheet">
        <script src="https://unpkg.com/mqtt/dist/mqtt.min.js"></script>        


        <style> 
            .container {
                width: 100% !important;          
                margin: 0 !important;
                padding: 0 !important;
            }
  
            .page {
                background: #000000 !important;
                width: 100% !important;
                max-width: none !important;
                margin: 0 !important;
                padding: 20px !important;
                box-sizing: border-box !important;

            }
  
            .page-container {
                width: 100% !important;
                max-width: none !important;
            }
  
            ${roomControlCSS}
            
            .nav-tabs {
                background: #000000 !important;
                border-top: 1px solid #333333 !important;
                position: fixed !important;
                bottom: 0 !important;
                left: 0 !important;
                right: 0 !important;
                height: 60px !important;
                z-index: 1000 !important;
            }
                    
            .nav-tab {
                color: #ffffff !important;
            }
            
            .nav-tab.active {
                background: #2b6cb0 !important;
                color: #ffffff !important;
            }
                        
            .device-selector-container {
                background: #000000 !important;
            }
            
            .device-selector {
                background: #1a1a1a !important;
                color: #ffffff !important;
                border: 1px solid #333333 !important;
            }
            
            .mic-btn {
                background: #1a1a1a !important;
                color: #ffffff !important;
                border: 1px solid #333333 !important;
            }
            
            .connection-status {
                background: #1a1a1a !important;
                color: #ffffff !important;
                border: 1px solid #333333 !important;
            }
            
            .device-controls {
                background: #000000 !important;
                color: #ffffff !important;
            }
            
            .device-header {
                background: #1a1a1a !important;
                color: #ffffff !important;
            }
            
            .device-panel {
                background: #000000 !important;
                color: #ffffff !important;
            }
            
            #pageScenes h2 {
                color: #ffffff !important;
            }
            
            .tv-selector {
                background: #1a1a1a !important;
                color: #ffffff !important;
                border: 1px solid #333333 !important;
            }
            
            .tv-selector option {
                background: #1a1a1a !important;
                color: #ffffff !important;
            }
            
            body, .container, .page, header, .nav-tabs {
                color: #ffffff !important;
            }
            
            .card-title, .card-value, .card-details,
            .device-info h2, .device-info p,
            #currentDeviceName, #currentDeviceStatus {
                color: #ffffff !important;
            }
             
            body {
                background: #000000 !important;
            }

            .container {
                background: #000000 !important;
            }

            .card {
                background: #1a1a1a !important;
                color: #ffffff !important;
            }
            .card-header {
                background: #000000 !important;
                border-bottom: 1px solid #333333 !important;
                padding: 12px 16px !important;
                border-radius: 12px 12px 0 0 !important;
                display: flex !important;
                justify-content: space-between !important;
                align-items: center !important;
            }

            .card-title {
                font-size: 1.5rem !important;
                font-weight: 600 !important;
                color: #ffffff !important;
                margin: 0 !important;
            }

            .card-header i {
                font-size: 1.5rem !important;
            }
            #pageCloud, #pageQwackify {
                padding: 0;
                height: 100%;
            }
            
            .qwackify-grid, .cloud-grid {
                width: 100%;
                height: 100%;
                display: flex;
                align-items: center;
                justify-content: center;
                background: var(--light);
            }
            
            .qwackify-grid iframe, .cloud-grid iframe {
                width: 100%;
                height: 100%;
                border: none;
                border-radius: 0;
                display: block;
            }
            
            .fullpage-iframe {
                width: 100%;
                height: 100%;
                transform-origin: top left;
            }
            
            #pagesContainer {
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: center;
            }


            .nav-icon {
                width: 36px;
                height: 36px;
                object-fit: contain;
                margin-right: 8px;
                vertical-align: middle;
            }
            .status-card-action-menu {
                background: white;
                border-radius: 12px;
                padding: 20px;
                box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
                z-index: 1000;
                position: fixed;
                animation: slideUp 0.2s ease;
            }
            
            @keyframes slideUp {
                from { opacity: 0; transform: translateY(20px); }
                to { opacity: 1; transform: translateY(0); }
            }
            
            .action-menu-header {
                text-align: center;
                margin-bottom: 15px;
                padding-bottom: 15px;
                border-bottom: 1px solid #e2e8f0;
            }
            
            .action-menu-header h3 {
                margin: 0 0 5px 0;
                color: #2d3748;
            }
            
            .action-menu-header p {
                margin: 0;
                color: #718096;
                font-size: 0.9rem;
            }
            
            .action-buttons {
                display: flex;
                flex-direction: column;
                gap: 10px;
            }
            
            .action-btn {
                padding: 12px 15px;
                border: none;
                border-radius: 8px;
                font-size: 1rem;
                cursor: pointer;
                transition: all 0.2s ease;
                display: flex;
                align-items: center;
                gap: 10px;
                justify-content: center;
            }
            
            .read-btn {
                background: linear-gradient(135deg, #48bb78, #38a169);
                color: white;
            }
            
            .hide-btn {
                background: linear-gradient(135deg, #f56565, #e53e3e);
                color: white;
            }
            
            .cancel-btn {
                background: #e2e8f0;
                color: #4a5568;
            }
            
            .action-btn:hover {
                transform: translateY(-2px);
                box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
            }
            
            .action-menu-backdrop {
                position: fixed;
                top: 0;
                left: 0;
                right: 0;
                bottom: 0;
                background: rgba(0, 0, 0, 0.5);
                z-index: 999;
            }
            
            .unified-status-card {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                margin-bottom: 0 !important;
                color: white;
                position: relative;
                overflow: hidden;
            }
    
            .device-selector-container {
                transition: all 0.3s ease;
                margin: 10px 20px;
            }

            .device-selector-container.hidden {
              display: none;
            }
    
            .unified-status-card::before {
              content: "";
              position: absolute;
              top: 0;
              left: 0;
              right: 0;
              height: 4px;
              background: linear-gradient(90deg, #ff6b6b, #4ecdc4, #45b7d1, #96ceb4, #ffeaa7);
            }
    
            .status-priority-critical { background: linear-gradient(135deg, #ff6b6b 0%, #ee5a24 100%) !important; }
            .status-priority-high { background: linear-gradient(135deg, #ff9ff3 0%, #f368e0 100%) !important; }
            .status-priority-medium { background: linear-gradient(135deg, #feca57 0%, #ff9f43 100%) !important; }
            .status-priority-low { background: linear-gradient(135deg, #48dbfb 0%, #0abde3 100%) !important; }
            .status-priority-info { background: linear-gradient(135deg, #1dd1a1 0%, #10ac84 100%) !important; }

            .page-container {
                overflow: hidden;
                height: calc(100vh - 140px);
            }

            .connection-status {
                transition: all 0.5s ease;
                opacity: 1;
                transform: translateY(0);
            }
            
            .connection-status.hidden {
                opacity: 0;
                transform: translateY(-20px);
                pointer-events: none;
            }

            .status-cards {
                gap: 5px;
                padding-bottom: 10px;
            }

            .scene-grid {
                padding-bottom: 80px;
            }    
            
            /* 🦆 says ⮞ TV */
            .tv-channel-display {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                border-radius: 12px;
                padding: 15px;
                margin: 15px auto;
                max-width: 300px;
                color: white;
                text-align: center;
                box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
                min-height: 70px;
            }

            .channel-info {
                display: flex;
                align-items: center;
                justify-content: center;
                gap: 15px;
                height: 100%;
            }

            .channel-icon {
                width: 50px !important;
                height: 50px !important;
                border-radius: 10px;
                background-size: cover !important;
                background-position: center !important;
                background-repeat: no-repeat !important;
                flex-shrink: 0;
                border: 2px solid rgba(255, 255, 255, 0.4);
                display: flex !important;
                align-items: center;
                justify-content: center;
                position: relative;
                min-width: 50px;
                min-height: 50px;
            }

            .channel-number-fallback {
                font-size: 1.1rem;
                font-weight: bold;
                color: white;
                background: rgba(0, 0, 0, 0.3);
                border-radius: 6px;
                padding: 4px 8px;
            }
 
            .program-info {
                flex: 1;
                text-align: left;
                min-width: 0;
            }
            
            .program-title {
                font-size: 1rem;
                font-weight: bold;
                margin: 0 0 8px 0;
                line-height: 1.2;
                white-space: nowrap;
                overflow: hidden;
                text-overflow: ellipsis;
                cursor: pointer;
            }
            
            .program-progress {
                background: rgba(255, 255, 255, 0.2);
                border-radius: 10px;
                height: 6px;
                overflow: hidden;
            }
            
            .program-progress-bar {
                height: 100%;
                width: 0%;
                background: linear-gradient(90deg, #4cd964, #2ecc71);
                transition: width 0.3s ease;
            }
            
            .program-time {
                display: none !important;
            }
            
            .tv-control-btn.channel { background: linear-gradient(135deg, #6366f1 0%, #4338ca 100%); }
            .tv-control-btn.volume { background: linear-gradient(135deg, #8b5cf6 0%, #6d28d9 100%); }
            .tv-control-btn.nav { background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%); }
            .tv-control-btn.playback { background: linear-gradient(135deg, #22c55e 0%, #15803d 100%); }
            .tv-control-btn.system { background: linear-gradient(135deg, #6b7280 0%, #374151 100%); }
            .tv-control-btn.power { background: linear-gradient(135deg, #ef4444 0%, #b91c1c 100%); }
            
            .tv-control-btn[data-nav] {
                font-size: 1.8rem;
                width: 90px;
                height: 90px;
            }
            
            .tv-controls-grid .tv-control-row:nth-child(2) {
                margin-bottom: 20px;
            }
            
            .tv-controls-grid .tv-control-row:nth-child(5) {
                margin-bottom: 20px;
            }
            
            .tv-controls-grid {
                display: grid;
                grid-template-columns: 1fr;
                gap: 15px;
                margin-top: 20px;
            }
            
            .tv-control-row {
                display: flex;
                justify-content: center;
                align-items: center;
                gap: 15px;
            }
            
            .tv-control-btn {
                padding: 15px 20px;
                border: none;
                border-radius: 12px;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                font-weight: 600;
                cursor: pointer;
                transition: all 0.3s ease;
                box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
                display: flex;
                align-items: center;
                gap: 8px;
                min-width: 80px;
                justify-content: center;
            }
            
            .tv-control-btn:hover {
                transform: translateY(-2px);
                box-shadow: 0 6px 12px rgba(0, 0, 0, 0.15);
            }
            
            .tv-control-btn.ok {
                background: linear-gradient(135deg, #4cd964 0%, #2ecc71 100%);
            }
            
            .tv-control-btn.icon-only {
                min-width: 60px;
                padding: 15px;
            }
            
            .tv-selector-container {
                margin-bottom: 20px;
                display: flex;
                justify-content: center;
            }
            
            .tv-selector {
                padding: 12px;
                border-radius: 8px;
                border: 2px solid #38bdf8;
                background: #f0f9ff;
                font-size: 1rem;
                width: 100%;
                max-width: 280px;
            }
            
            .tv-guide-placeholder {
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: center;
                padding: 40px;
                background: var(--light);
                border-radius: 12px;
                margin-bottom: 20px;
                gap: 10px;
                color: var(--gray);
            }
            
            .tv-controls {
                display: grid;
                grid-template-columns: 1fr;
                gap: 20px;
                margin-top: 20px;
            }
            
            .tv-power {
                display: flex;
                justify-content: center;
            }
            
            .tv-volume, .tv-navigation, .tv-playback {
                display: grid;
                grid-template-columns: repeat(3, 1fr);
                gap: 10px;
            }
            
            .tv-btn {
                padding: 15px;
                border-radius: 12px;
                background: white;
                border: none;
                box-shadow: var(--card-shadow);
                font-size: 1.2rem;
                cursor: pointer;
                transition: var(--transition);
            }
            
            .tv-btn:hover {
                background: var(--primary);
                color: white;
            }
            
            .tv-btn.ok {
                grid-column: 2;
            }
           
            .channel-icon {
                background-color: rgba(255, 0, 0, 0.3) !important; /* Red background to see the element */
                border: 3px solid #00ff00 !important; /* Green border to see the bounds */
            }

            #currentChannelIcon {
                display: flex !important;
                visibility: visible !important;
                opacity: 1 !important;
            }             
            
            .scene-item {
                padding: 15px;
                border-radius: 12px;
                cursor: pointer;
                transition: var(--transition);
                text-align: center;
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: center;
                gap: 8px;
                box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
                background: black;
                color: white;
            }
            ${sceneGradientCss}
        </style>
    </head>
    <body>
        <div class="container">
            
            <div id="deviceSelectorContainer" class="device-selector-container hidden">
                <select id="deviceSelect" class="device-selector">
                    <option value="">🦆 says > pick a device </option>
                </select>
            </div>
    
            <div class="connection-status status-connecting" id="connectionStatus">
                <i class="fas fa-plug"></i>
               <span>⚠️</span>
            </div>
    
    
            <div class="page-container" id="pageContainer"> 
                <!-- 🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆
                 🦆 says ⮞ PAGE 0 HOME (STATUS CARDS)
                 🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆 -->
                <div class="page" id="pageHome" data-page="0">
                    ${if config.house.dashboard.betaCard.enable then statusCards else ""}
                    
                    <div class="status-cards">
                    <div class="status-cards">
                        ${statusCardsHtml}
                       
                        <div class="card">
                            <div class="card-header">
                                <div class="card-title">Temperature</div>
                                <i class="fas fa-thermometer-half" style="color: #e74c3c;"></i>
                            </div>
                            <div class="card-value" id="temperatureValue">--.-°C</div>
                            <div class="card-details">
                                <i class="fas fa-map-marker-alt"></i>
                                <span id="temperatureLocation">Waiting for data</span>
                            </div>
                        </div>
                                             
                    </div>
                    </div>
                    ${roomControlsHtml}
                </div><br><br><br>
                
                
                <!-- 🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆
                 🦆 says ⮞ PAGE 1 DEVICES
                 🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆 -->                
                <div class="page" id="pageDevices" data-page="1">                    
                    <div class="device-controls" id="deviceControls">
                        <div class="device-header">
                            <div class="device-icon">
                                <i id="currentDeviceIcon" class="mdi"></i>
                            </div>
                            <div class="device-info">
                                <h1 id="currentDeviceName">Select a device</h1>
                                <p id="currentDeviceStatus">Or swipe around!</p>
                            </div>
                            <div class="linkquality-mini">
                                <div class="lq-bars"></div>
                                <span class="lq-value">--</span>
                            </div>
                        </div>
                        
                        <div id="devicePanel" class="device-panel">

                        </div>
                    </div>
                </div>
                
                
                <!-- 🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆
                 🦆 says ⮞ PAGE 2 - SCENES
                 🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆 -->
                <div class="page" id="pageScenes" data-page="2">
                    <h2>Scenes</h2>
                    <div class="scene-grid" id="scenesContainer">
                      ${sceneGridHtml}
                    </div>
                </div>
                
                
                <!-- 🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆
                 🦆 says ⮞ PAGE 3 - TV
                 🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆 -->
                <div class="page" id="pageTV" data-page="3">
                    <div class="tv-selector-container">
                        <select id="targetTV" class="tv-selector">
                            <option value="">🦆 says > pick a TV</option>
                            ${tvOptions}
                        </select>
                    </div>
                    
                    <!-- 🦆 says ⮞ TV channel display -->
                    <div class="tv-channel-display" id="tvChannelDisplay" style="display: none;">
                        <div class="channel-info">
                            <div class="channel-icon" id="currentChannelIcon">
                                <div class="channel-number-fallback" id="currentChannelNumberFallback">--</div>
                            </div>
                            <div class="program-info">
                                <div class="program-title" id="currentProgramTitle">No program...</div>
                                <div class="program-progress">
                                    <div class="program-progress-bar" id="programProgressBar"></div>
                                </div>
                            </div>
                        </div>
                    </div

                
                    <div class="tv-controls-grid">
                        <!-- 🦆 says ⮞ ROW 1 -->
                        <div class="tv-control-row">
                            <button class="tv-control-btn channel" onclick="sendTVCommand('channel_up')">
                                <i class="fas fa-arrow-up"></i>
                            </button>
                            <button class="tv-control-btn volume" onclick="sendTVCommand('up')">
                                <i class="fas fa-volume-up"></i>
                            </button>
                        </div>
                        
                        <!-- 🦆 says ⮞ ROW 2 -->
                        <div class="tv-control-row">
                            <button class="tv-control-btn channel" onclick="sendTVCommand('channel_down')">
                                <i class="fas fa-arrow-down"></i>
                            </button>
                            <button class="tv-control-btn volume" onclick="sendTVCommand('down')">
                                <i class="fas fa-volume-down"></i>
                            </button>
                        </div>
                        
                        <!-- 🦆 says ⮞ ROW 3 -->
                        <div class="tv-control-row">
                            <button class="tv-control-btn icon-only system" onclick="sendTVCommand('menu')">
                                <i class="mdi mdi-menu"></i>
                            </button>
                            <button class="tv-control-btn nav" data-nav onclick="sendTVCommand('nav_up')">
                                <i class="fas fa-arrow-up"></i>
                            </button>
                            <button class="tv-control-btn icon-only system" onclick="sendTVCommand('home')">
                                <i class="mdi mdi-home"></i>
                            </button>
                        </div>
                        
                        <!-- 🦆 says ⮞ ROW 4 -->
                        <div class="tv-control-row">
                            <button class="tv-control-btn nav" data-nav onclick="sendTVCommand('nav_left')">
                                <i class="fas fa-arrow-left"></i>
                            </button>
                            <button class="tv-control-btn ok nav" onclick="sendTVCommand('nav_select')">
                                <i class="fas fa-dot-circle"></i>
                            </button>
                            <button class="tv-control-btn nav" data-nav onclick="sendTVCommand('nav_right')">
                                <i class="fas fa-arrow-right"></i>
                            </button>
                        </div>
                        
                        <!-- 🦆 says ⮞ ROW 5 -->
                        <div class="tv-control-row">
                            <button class="tv-control-btn icon-only system" onclick="sendTVCommand('back')">
                                <i class="mdi mdi-arrow-left-circle"></i>
                            </button>
                            <button class="tv-control-btn nav" data-nav onclick="sendTVCommand('nav_down')">
                                <i class="fas fa-arrow-down"></i>
                            </button>
                            <button class="tv-control-btn icon-only system" onclick="sendTVCommand('app_switcher')">
                                <i class="mdi mdi-apps"></i>
                            </button>
                        </div>
                        
                        <!-- 🦆 says ⮞ ROW 6 -->
                        <div class="tv-control-row">
                            <button class="tv-control-btn playback" onclick="sendTVCommand('previous')">
                                <i class="fas fa-backward"></i>
                            </button>
                            <button class="tv-control-btn playback" onclick="sendTVCommand('play_pause')">
                                <i class="fas fa-play"></i>
                            </button>
                            <button class="tv-control-btn playback" onclick="sendTVCommand('next')">
                                <i class="fas fa-forward"></i>
                            </button>
                        </div>
                    </div>
                </div>
                             
    
               <!-- 🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆
               🦆 says ⮞ CUSTOM PAGES
               🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆 -->
               ${customPagesHtml}


            </div>
    
    
            <!-- 🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆
             🦆 says ⮞ TABS
             🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆 -->
            <div class="nav-tabs">
                <div class="nav-tab active" data-page="0">
                    <i class="mdi mdi-home"></i>
                </div>
                <div class="nav-tab" data-page="1">
                    <i class="mdi mdi-lightbulb"></i>
                </div>
                <div class="nav-tab" data-page="2">
                    <i class="mdi mdi-palette"></i>
                </div>
                <div class="nav-tab" data-page="3">
                    <i class="mdi mdi-remote"></i>
                </div>
                ${customTabsHtml}
            </div>
        </div>
    
        <div class="notification hidden" id="notification"></div>
    
        <script>
            ${statusCardsJs}
            ${updateAllCardsJs}
            ${fileRefreshJs}
            ${roomControlJs}

            window.syncRoomToggles = function() {
              if (!window.roomDevices || !window.devices) return;
  
              Object.entries(window.roomDevices).forEach(([roomName, deviceIds]) => {
                const anyDeviceOn = deviceIds.some(deviceId => {
                  const device = window.devices[deviceId];
                  return device && device.state === 'ON';
                });
    
                // 🦆 says ⮞ find the toggle for this room
                const toggle = document.querySelector(`.room-control-card[data-room="''${roomName}"] .room-toggle`);
                if (toggle) {
                  toggle.checked = anyDeviceOn;
                }
              });
            };

            window.toggleRoom = function(roomName, state) {
              console.log('🦆 Toggle room:', roomName, state);
              const devices = window.roomDevices ? window.roomDevices[roomName] : [];
              if (!devices || devices.length === 0) {
                console.error('No devices found for room:', roomName);
                showNotification('No devices found in ' + roomName, 'error');
                return;
              }

              const command = { state: state ? 'ON' : 'OFF' };
              console.log('Sending command to devices:', devices, command);
  
              devices.forEach(device => {
                if (window.sendCommand) {
                  window.sendCommand(device, command);
                } else {
                  console.error('sendCommand not available');
                }
              });
  
              showNotification(`''${state ? 'Turning on' : 'Turning off'} ''${roomName}`, 'success');
            };

            // 🦆 says ⮞ debounced brightness control to reduce spam
            window.setRoomBrightness = (function() {
              let timeoutId = null;
              const DEBOUNCE_DELAY = 500; // 🦆 says ⮞ wait 500ms after slider stops
  
              return function(roomName, brightness) {
                console.log('🦆 Set room brightness:', roomName, brightness);
                const devices = window.roomDevices ? window.roomDevices[roomName] : [];
                if (!devices || devices.length === 0) {
                  console.error('No devices found for room:', roomName);
                  return;
                }

                // 🦆 says ⮞ clear previous timeout
                if (timeoutId) {
                  clearTimeout(timeoutId);
                }

                // 🦆 says ⮞ set new timeout
                timeoutId = setTimeout(() => {
                  const command = { brightness: parseInt(brightness) };
                  console.log('🦆 Sending brightness to devices:', devices, command);
      
                  devices.forEach(device => {
                    if (window.sendCommand) {
                      window.sendCommand(device, command);
                    } else {
                      console.error('sendCommand not available');
                    }
                  });
      
                }, DEBOUNCE_DELAY);
              };
            })();


            function updateCardValue(cardId, value) {
                console.log('🦆 updateCardValue called with:', cardId, value);
                const element = document.getElementById("status-"+cardId+"-value");
                console.log('🦆 updateCardValue element found:', element);
                if (element) {
                    console.log('🦆 updateCardValue updating element from:', element.textContent, 'to:', value);
                    element.textContent = value;
                } else {
                    console.error('🦆 updateCardValue element not found for id:', "status-"+cardId+"-value");
                }
            }

            function updateCardDetails(cardId, details) {
                console.log('🦆 updateCardDetails called with:', cardId, details);
                const element = document.getElementById("status-"+cardId+"-details");
                console.log('🦆 updateCardDetails element found:', element);
                if (element) {
                    element.textContent = details;
                }
            }
        
            function onMQTTDataUpdate() {
                updateAllStatusCards();
            }
            
            document.addEventListener('DOMContentLoaded', function() {
                // 🦆 says ⮞ mqtt
                let client = null;
                
                const brokerUrl = 'ws://${mqttHostip}:9001';              
                const statusElement = document.getElementById('connectionStatus');
                const notification = document.getElementById('notification');
        
                // 🦆 says ⮞ auto-hide connection status
                let connectionHideTimeout = null;
                
                function hideConnectionStatus() {
                    if (statusElement.classList.contains('status-connected')) {
                        connectionHideTimeout = setTimeout(() => {
                            statusElement.classList.add('hidden');
                        }, 10000); // 🦆 says ⮞ 10 seconds
                    }
                }
                
                function showConnectionStatus() {
                    if (connectionHideTimeout) {
                        clearTimeout(connectionHideTimeout);
                        connectionHideTimeout = null;
                    }
                    statusElement.classList.remove('hidden');
                }        
        
                // 🦆 says ⮞ device state
                let devices = {};
                let selectedDevice = null;
                let sceneData = ${sceneData};
                let deviceIcons = ${iconData};  
                console.log('All device icons:', deviceIcons);
                console.log('Device friendly names:', Object.keys(deviceIcons));
  
                // 🦆 says ⮞ recording variables
                let mediaRecorder;
                let audioChunks = [];
                let recording = false;
                const transcriptionServerURL = "https://localhost:25451/transcribe";
                const recordingStatus = document.getElementById('recordingStatus');
  
                // 🦆 says ⮞ page
                const pageContainer = document.getElementById('pageContainer');
                const navTabs = document.querySelectorAll('.nav-tab');
                let currentPage = 0;
                              
                // 🦆 says ⮞ helperz 4 renderMessage
                function clamp(value, min, max) {
                    return Math.min(Math.max(value, min), max);
                }
                
                function normalizeColor(color) {
                    if (typeof color === 'string' && color.startsWith('#')) {
                        // 🦆 says ⮞ hex
                        const hex = color.substring(1);
                        return {
                            r: parseInt(hex.substr(0, 2), 16),
                            g: parseInt(hex.substr(2, 2), 16),
                            b: parseInt(hex.substr(4, 2), 16),
                            w: 0,
                            hex: color
                        };
                    } else if (color && typeof color === 'object') {
                        const r = color.r || 0;
                        const g = color.g || 0;
                        const b = color.b || 0;
                        const w = color.w || 0;
                        return {
                            r, g, b, w,
                            hex: `#''${((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1)}`
                        };
                    }
                    
                    // 🦆 says ⮞ white default
                    return { r: 255, g: 255, b: 255, w: 0, hex: '#ffffff' };
                }


                // 🦆 says ⮞ create room to devices mapping
                // 🦆 says ⮞ Initialize room device mappings
                window.roomDeviceMappings = {};
                ${roomDeviceMappings}

                // 🦆 says ⮞ Also create roomDevices for backward compatibility
                window.roomDevices = {};
                Object.keys(window.roomDeviceMappings || {}).forEach(roomName => {
                    if (window.roomDeviceMappings[roomName]) {
                        window.roomDevices[roomName] = window.roomDeviceMappings[roomName].map(d => d.id);
                    }
                });

                console.log('🦆 Room devices mapping:', window.roomDevices);

                function updateBattery(percent) {
                  const fill = document.querySelector(".battery-fill");
                  const text = document.querySelector(".battery-text");

                  fill.style.width = percent + "%";
                  text.textContent = percent + "%";

                  fill.className = "battery-fill"; // reset
                  if (percent > 60) fill.classList.add("high");
                  else if (percent > 30) fill.classList.add("medium");
                  else if (percent > 15) fill.classList.add("low");
                  else fill.classList.add("critical");
                }         
         
                function setRangeGradient(slider, startColor, endColor) {
                    const existingStyle = document.getElementById('sliderGradientStyle');
                    if (existingStyle) {
                        existingStyle.remove();
                    }
    
                    const style = document.createElement('style');
                    style.id = 'sliderGradientStyle';
    
                    const sliderId = `slider-''${Math.random().toString(36).substr(2, 9)}`;
                    slider.id = sliderId;
    
                    style.textContent = `
                        #''${sliderId} {
                            background: linear-gradient(to right, ''${startColor}, ''${endColor});
                        }
        
                        #''${sliderId}::-webkit-slider-thumb {
                            background: var(--primary);
                        }
        
                        #''${sliderId}::-moz-range-thumb {
                            background: var(--primary);
                        }
                    `;
    
                    document.head.appendChild(style);
                }
                
                function valueColor(key, value) {
                    if (key === 'temperature') {
                        if (value > 30) return '#e74c3c';
                        if (value < 15) return '#3498db';
                        return '#2ecc71';
                    }
                    if (key === 'humidity') {
                        if (value > 70) return '#3498db';
                        if (value < 30) return '#e67e22';
                        return '#2ecc71';
                    }
                    if (key === 'linkquality') {
                        if (value > 100) return '#2ecc71';
                        if (value > 50) return '#f39c12';
                        return '#e74c3c';
                    }
                    return null;
                }
                
                function formatValue(key, value) {
                    if (key === 'last_seen') {
                        return new Date(value).toLocaleString();
                    }
                    if (typeof value === 'number') {
                        return Number(value.toFixed(2)).toString();
                    }
                    return String(value);
                }
                
                function linkQualityText(value) {
                    if (value > 200) return 'Excellent';
                    if (value > 100) return 'Good';
                    if (value > 50) return 'Fair';
                    return 'Poor';
                }
                
                function timeAgo(timestamp) {
                    const now = new Date();
                    const time = new Date(timestamp);
                    const diff = now - time;
                    const minutes = Math.floor(diff / 60000);
                    const hours = Math.floor(diff / 3600000);
                    const days = Math.floor(diff / 86400000);
                    
                    if (days > 0) return `''${days} day''${days > 1 ? "s" : ""} ago`;
                    if (hours > 0) return `''${hours} hour''${hours > 1 ? "s" : ""} ago`;
                    if (minutes > 0) return `''${minutes} minute''${minutes > 1 ? "s" : ""} ago`;
                    return 'Just now';
                }
                
                function loadSavedState() {
                    try {
                        const savedState = localStorage.getItem('duckDashState');
                        if (savedState) {
                            const state = JSON.parse(savedState);
            
                            if (state.devices) {
                                devices = {...state.devices, ...devices};
                                updateDeviceSelector();
                                updateStatusCards();
                            }
            
                            if (state.selectedDevice) {
                                selectedDevice = state.selectedDevice;
                                window.selectedDevice = selectedDevice; 
                                document.getElementById('deviceSelect').value = selectedDevice;
                                if (devices[selectedDevice]) {
                                    updateDeviceUI(devices[selectedDevice]);
                                }
                            }
            
                            if (state.currentPage !== undefined) {
                                showPage(state.currentPage);
                            }
            
                            showNotification('Saved state loaded', 'success');
                        }
                    } catch (e) {
                        console.error('Error loading saved state:', e);
                        showNotification('Error loading saved data', 'error');
                    }
                }
                
                function saveState() {
                    try {
                        const state = {
                            devices: devices,
                            selectedDevice: selectedDevice,
                            currentPage: currentPage,
                            timestamp: new Date().toISOString()
                        };
        
                        localStorage.setItem('duckDashState', JSON.stringify(state));
                    } catch (e) {
                        console.error('Error saving state:', e);
                        showNotification('Error saving data', 'error');
                    }
                }
                
                function clearSavedState() {
                    try {
                        localStorage.removeItem('duckDashState');
                        devices = {};
                        selectedDevice = null;
                        window.selectedDevice = null;
                        updateDeviceSelector();
                        updateStatusCards();
                        document.getElementById('currentDeviceName').textContent = 'quack or tap a device';
                        document.getElementById('currentDeviceStatus').textContent = 'up there yo';
                        showNotification('Saved data cleared', 'success');
                    } catch (e) {
                        console.error('Error clearing saved state:', e);
                        showNotification('Error clearing data', 'error');
                    }
                }

                window.publishPatch = publishPatch;
                window.selectedDevice = selectedDevice;
                
                // 🦆 says ⮞ COLOR func
                window.setColor = function(hex) {
                    const r = parseInt(hex.slice(1, 3), 16);
                    const g = parseInt(hex.slice(3, 5), 16);
                    const b = parseInt(hex.slice(5, 7), 16);

                    publishPatch({ color: { r, g, b } });
                };

                window.openColorPicker = function() {
                    document.getElementById('hiddenColorPicker').click();
                };

                window.normalizeColor = function(color) {
                    if (typeof color === 'string' && color.startsWith('#')) {
                        const hex = color.substring(1);
                        return {
                            r: parseInt(hex.substr(0, 2), 16),
                            g: parseInt(hex.substr(2, 2), 16),
                            b: parseInt(hex.substr(4, 2), 16),
                            hex: color
                        };
                    } else if (color && typeof color === 'object') {
                        const r = color.r || 0;
                        const g = color.g || 0;
                        const b = color.b || 0;
                        return {
                            r, g, b,
                            hex: `#''${((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1)}`
                        };
                    }

                    return { r: 255, g: 255, b: 255, hex: '#ffffff' };
                };


                // 🦆 says ⮞ TV control function
                window.sendTVCommand = function(command) {
                    console.log('🦆 TV command triggered:', command);       
                    const targetTV = document.getElementById('targetTV');
                    console.log('🦆 TV selector element:', targetTV);
                    
                    const ip = targetTV.value;   
                    console.log('🦆 Selected TV IP:', ip);
                    
                    if (!ip) {
                        console.warn('🦆 No TV selected, showing error notification');
                        showNotification('Please select a TV first', 'error');
                        return;
                    }   
                    const payload = {
                        tvCommand: command,
                        ip: ip
                    };      
                    console.log('MQTT payload:', payload);
                    console.log('MQTT client status:', client ? (client.connected ? 'connected' : 'disconnected') : 'null');     
                    if (client && client.connected) {
                        console.log('Publishing to topic: zigbee2mqtt/tvCommand');
                        client.publish('zigbee2mqtt/tvCommand', JSON.stringify(payload), function(err) {
                            if (err) {
                                console.error('MQTT publish error:', err);
                                showNotification('Failed to send TV command', 'error');
                            } else {
                                console.log('TV command published successfully');
                                showNotification('TV command sent: ' + command, 'success');
                            }
                        });
                    } else {
                        console.warn('MQTT client not connected');
                        showNotification('Not connected to MQTT', 'error');
                    }
                };

                // 🦆 says ⮞ create device ID to icon mapping
                let deviceIdToIcon = {};
                fetch('/devices.json')
                    .then(response => response.json())
                    .then(allDevices => {
                        Object.entries(allDevices).forEach(([deviceId, device]) => {
                            if (device.icon) {
                                deviceIdToIcon[deviceId] = device.icon;
                            }
                        });
                        console.log('Device ID to icon mapping:', deviceIdToIcon);
                    })
                    .catch(error => {
                        console.log('Could not load devices.json for icon mapping');
                    });


                // 🦆 says ⮞ load and display EPG data
                function loadEPGData() {
                    const tvPage = document.getElementById('pageTV');
                    const channelDisplay = document.getElementById('tvChannelDisplay');
                    if (!tvPage && !channelDisplay) {
                        console.log('TV page elements not available, skipping EPG load');
                        return;
                    }
                    fetch('/epg.json')
                        .then(response => {
                            if (!response.ok) {
                                throw new Error('EPG data not available');
                            }
                            return response.json();
                        })
                        .then(epgData => {
                            window.epgData = epgData;
                            console.log('EPG data loaded successfully');
                            console.log('EPG data structure:', epgData);
                            const currentTV = document.getElementById('targetTV');
                            if (currentTV && currentTV.value) {
                                updateTVWithEPG(currentTV.value);
                            }
                        })
                        .catch(error => {
                            console.log('EPG data not available:', error);
                        });
                }
                
                function updateChannelIcon(channelId) {
                    console.log('🦆 updateChannelIcon called with channelId:', channelId);
                    const iconElement = document.getElementById('currentChannelIcon');
                    const fallbackElement = document.getElementById('currentChannelNumberFallback');
    
                    if (!iconElement) {
                        console.error('Channel icon element not found!');
                        return;
                    }
    
                    if (iconElement && channelId) {
                        const iconPath = `/tv-icons/''${channelId}.png`;
                        console.log('🦆 Looking for channel icon at:', iconPath);
                        iconElement.style.display = 'flex';
                        iconElement.style.visibility = 'visible';
                        iconElement.style.opacity = '1';
                        iconElement.className = 'channel-icon';
                        iconElement.style.backgroundSize = 'cover';
                        iconElement.style.backgroundPosition = 'center';
                        iconElement.style.backgroundRepeat = 'no-repeat';
        
                        iconElement.style.backgroundColor = "";
                        iconElement.style.border = '2px solid rgba(255, 255, 255, 0.4)';
        
                        if (fallbackElement) {
                            fallbackElement.textContent = channelId;
                            fallbackElement.style.display = 'none'; // Hide fallback initially
                        }
        
                        const img = new Image();
                        img.onload = function() {
                            console.log('🦆 Channel icon loaded successfully:', iconPath);
                            console.log('Setting background image to:', iconPath);
                            iconElement.style.backgroundImage = `url(''${iconPath}')`;
                            iconElement.style.display = 'none';
                            iconElement.offsetHeight;
                            iconElement.style.display = 'flex';
            
                            if (fallbackElement) {
                                fallbackElement.style.display = 'none';
                            }
            
                            console.log('Final backgroundImage:', iconElement.style.backgroundImage);
                        };
                        img.onerror = function() {
                            console.warn('🦆 Channel icon not found:', iconPath);
                            iconElement.style.backgroundImage = 'none';
                            iconElement.style.backgroundColor = 'rgba(0, 0, 0, 0.3)';
                            if (fallbackElement) {
                                fallbackElement.style.display = 'flex';
                            }
                        };
                        img.src = iconPath;
                    } else if (iconElement) {
                        console.log('🦆 No channelId provided, showing fallback');
                        iconElement.style.backgroundImage = 'none';
                        iconElement.style.backgroundColor = 'rgba(0, 0, 0, 0.3)';
                        if (fallbackElement) {
                            fallbackElement.style.display = 'flex';
                            fallbackElement.textContent = '--';
                        }
                    }
                }
           
                // 🦆 says ⮞ update TV display with EPG information
                function updateTVWithEPG(deviceIp) {
                    if (!window.epgData || !window.epgData.channels) return;
                    const tvConfig = ${builtins.toJSON config.house.tv};
                    const tvDevice = Object.entries(tvConfig).find(([name, config]) => 
                        config.ip === deviceIp
                    );   
                    if (!tvDevice) {
                        console.log('No TV config found for IP:', deviceIp);
                        return;
                    }    
                    const tvName = tvDevice[0];
                    const tvKey = `tv_''${tvName}`;
                    const tvState = devices[tvKey];
                    if (!tvState || !tvState.current_channel) {
                        console.log('No TV state found for:', tvKey, tvState);
                        return;
                    }  
                    const channelId = tvState.current_channel.toString();
                    console.log('🦆 Found TV channel:', channelId, 'for device:', deviceIp, 'name:', tvName);   
                    updateChannelIcon(channelId);
                    const channel = window.epgData.channels.find(ch => ch.id === channelId);  
                    if (!channel || !channel.programs) {
                        console.log('No EPG data for channel:', channelId);
                        return;
                    }   
                    const now = new Date();
                    const currentProgram = findCurrentProgram(channel.programs, now);
                    if (currentProgram) {
                        updateChannelDisplayWithProgram(channel, currentProgram, now);
                    } else {
                        console.log('No current program found for channel:', channelId);
                        const programTitle = document.getElementById('currentProgramTitle');
                        if (programTitle) {
                            programTitle.textContent = tvState.current_channel_name || 'No program data';
                        }
                    }
                }


                // 🦆 says ⮞ find the currently playing program
                function findCurrentProgram(programs, currentTime) {
                    return programs.find(program => {
                        const startTime = parseEPGTime(program.start);
                        const endTime = parseEPGTime(program.stop);
                        return currentTime >= startTime && currentTime < endTime;
                    });
                }

                // 🦆 says ⮞ parse EPG time
                function parseEPGTime(epgTime) {
                    // 🦆 says ⮞ format: YYYYMMDDHHMMSS +0000
                    const year = epgTime.substring(0, 4);
                    const month = epgTime.substring(4, 6) - 1;
                    const day = epgTime.substring(6, 8);
                    const hour = epgTime.substring(8, 10);
                    const minute = epgTime.substring(10, 12);
                    const second = epgTime.substring(12, 14);
                    return new Date(year, month, day, hour, minute, second);
                }

                // 🦆 says ⮞ clean program title from html
                function cleanProgramTitle(rawTitle) {
                    if (!rawTitle) return 'No program...';
                    let clean = rawTitle.replace(/<[^>]*>/g, "");
                    const channelPatterns = [
                        /^Kanal\s+\d+\s*[-–]?\s*/i,
                        /^TV\d+\s*[-–]?\s*/i,
                        /^SVT\d*\s*[-–]?\s*/i,
                        /^\d+\s*[-–]?\s*/
                    ];
                    channelPatterns.forEach(pattern => {
                        clean = clean.replace(pattern, "");
                    });
                    clean = clean.replace(/^\s*[-–]\s*/, "").trim();
                    if (!clean) {
                        return rawTitle.replace(/<[^>]*>/g, "").trim() || 'No program...';
                    }
                    return clean;
                }

                // 🦆 says ⮞ toggle program description visibility
                function toggleProgramDescription() {
                    const descElement = document.getElementById('currentProgramDescription');
                    const channelDisplay = document.getElementById('tvChannelDisplay');
                    if (descElement && channelDisplay) {
                        const isExpanded = descElement.classList.contains('expanded');
                        if (isExpanded) {
                            descElement.classList.remove('expanded');
                            channelDisplay.classList.remove('expanded');
                        } else {
                            descElement.classList.add('expanded');
                            channelDisplay.classList.add('expanded');
                        }
                    }
                }

                // 🦆 says ⮞ update the display with program info
                function updateChannelDisplayWithProgram(channel, program, currentTime) {
                    const elements = {
                        programTitle: document.getElementById('currentProgramTitle'),
                        progressBar: document.getElementById('programProgressBar')
                    };
    
                    if (!elements.programTitle || !elements.progressBar) {
                        console.log('Required TV display elements not found, skipping update');
                        return;
                    }
    
                    const startTime = parseEPGTime(program.start);
                    const endTime = parseEPGTime(program.stop);
                    const currentUTC = new Date(currentTime.toISOString());
    
                    const totalDuration = endTime - startTime;
                    const elapsed = currentUTC - startTime;
                    const progress = Math.min(Math.max((elapsed / totalDuration) * 100, 0), 100);
    
                    console.log('Program progress:', {
                        start: startTime,
                        end: endTime,
                        current: currentUTC,
                        progress: progress + '%'
                    });
    
                    const cleanTitle = cleanProgramTitle(program.title);
                    elements.programTitle.textContent = cleanTitle;
                    elements.progressBar.style.width = `''${progress}%`;
    
                    if (progress < 25) {
                        elements.progressBar.style.background = 'linear-gradient(90deg, #4cd964, #2ecc71)';
                    } else if (progress < 75) {
                        elements.progressBar.style.background = 'linear-gradient(90deg, #ffcc00, #ff9500)';
                    } else {
                        elements.progressBar.style.background = 'linear-gradient(90deg, #ff3b30, #e74c3c)';
                    }
                }

                // 🦆 says ⮞ update TV channel display
                function updateTVChannelDisplay(deviceIp, channelData) {
                    const channelDisplay = document.getElementById('tvChannelDisplay');
                    if (!channelDisplay) return;

                    const currentTV = document.getElementById('targetTV').value;
                    if (currentTV === deviceIp) {
                        channelDisplay.style.display = 'block';
                        if (channelData.channel_id) {
                            updateChannelIcon(channelData.channel_id.toString());
                        }
                        const programTitle = document.getElementById('currentProgramTitle');
                        if (programTitle) {
                            if (channelData.program_title) {
                                programTitle.textContent = cleanProgramTitle(channelData.program_title);
                                programTitle.style.cursor = 'pointer';
                            } else {
                                programTitle.textContent = 'No program...';
                                programTitle.style.cursor = 'default';
                            }
                        }
                    }
                }

                // 🦆 says ⮞ format timestamp
                function formatChannelTime(timestamp) {
                    if (!timestamp) return '--';
                    try {
                        const date = new Date(timestamp);
                        return date.toLocaleTimeString('sv-SE', { 
                            hour: '2-digit', 
                            minute: '2-digit',
                            hour12: false 
                        });
                    } catch (e) {
                        return '--';
                    }
                }

                // 🦆 says ⮞ load initial TV channel state
                function loadInitialTVState() {
                    fetch('/state.json')
                        .then(response => response.json())
                        .then(state => {
                            Object.entries(state).forEach(([key, data]) => {
                                if (key.startsWith('tv_') && data.current_channel) {
                                    const tvName = key.replace('tv_', "");
                                    const tvConfig = ${builtins.toJSON config.house.tv};
                                    const tvDevice = Object.values(tvConfig).find(tv => 
                                        tv.room.toLowerCase().includes(tvName.toLowerCase())
                                    );																			
                                    if (tvDevice) {
                                        updateTVChannelDisplay(tvDevice.ip, {
                                           channel_id: data.current_channel,
                                            channel_name: data.current_channel_name || `Channel ''${data.current_channel}`,
                                            timestamp: data.last_update
                                        });
                                    }
                                }
                            });
                        })
                        .catch(error => {
                            console.log('No initial TV state available');
                        });
                }          
                
                /*🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆
                 🦆 says ⮞ ZIGDUCK CONNECT 
                 🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆*/
                function connectToMQTT() {
                    showConnectionStatus();
                    statusElement.className = 'connection-status status-connecting';
                    statusElement.innerHTML = '<i class="fas fa-plug"></i><span>📛</span>';
                   
                    let password = localStorage.getItem('mqttPassword');
                    if (!password) {
                        password = prompt('quack yo MQTT pass:');
                        if (password) {
                            localStorage.setItem('mqttPassword', password);
                        }
                    }
                    
                    const options = {
                        username: '${config.house.zigbee.mosquitto.username}',
                        password: password,
                        clientId: 'web-dashboard-' + Math.random().toString(16).substring(2, 10)
                    };
                    
                    try {
                        client = mqtt.connect(brokerUrl, options);
                        
                        client.on('connect', function() {
                            showConnectionStatus();
                            statusElement.className = 'connection-status status-connected';
                            statusElement.innerHTML = '<i class="fas fa-plug"></i><span>🟢</span>';
                            
                            setupStatusSubscriptions();
                            statusCard.updateCard();
                            // 🦆 says ⮞ auto-hide after 10 seconds
                            hideConnectionStatus();
                            
                            client.subscribe('zigbee2mqtt/#', function(err) {
                                if (!err) {
                                    showNotification('Subscribed to all devices', 'success');
                                }
                            });
                            client.subscribe('zigbee2mqtt/reminders', function(err) {
                                if (!err) {
                                    showNotification('Subscribed to reminders', 'success');
                                }
                            });                            
                            client.subscribe('zigbee2mqtt/tibber/#', function(err) {
                                if (!err) {
                                    showNotification('Subscribed to energy data', 'success');
                                }
                            });
                        });
                        
                        client.on('error', function(err) {
                            showConnectionStatus(); // 🦆 says ⮞ show on error
                            statusElement.className = 'connection-status status-error';
                            statusElement.innerHTML = '<i class="fas fa-exclamation-triangle"></i><span>⚠️📛</span>';
                            console.error('Connection error: ', err);
                            showNotification('MQTT connection error', 'error');
                        });
                        
                        client.on('message', function(topic, message) {
                            const topicParts = topic.split('/');
                            const deviceName = topicParts[1];

                            // 🦆 says ⮞ handle reminders
                            if (topic === 'zigbee2mqtt/reminders') {
                                try {
                                    const data = JSON.parse(message.toString());
                                    statusCard.handleRemindersMQTT(message);
                                } catch (e) {
                                    console.error('Error parsing reminder message:', e);
                                }
                                return;
                            }

                            if (topic === 'zigbee2mqtt/tts') {
                                try {
                                    const ttsData = JSON.parse(message.toString());
                                    console.log('🦆 TTS message received:', ttsData);
        
                                    window.speechSynthesis.cancel();
        
                                    const speech = new SpeechSynthesisUtterance();
                                    speech.text = ttsData.text;
                                    speech.rate = ttsData.rate || 1.0;
                                    speech.pitch = ttsData.pitch || 1.0;
                                    speech.volume = ttsData.volume || 0.8;
        
                                    if (ttsData.voice) {
                                        const voices = window.speechSynthesis.getVoices();
                                        const selectedVoice = voices.find(voice => 
                                            voice.name.toLowerCase().includes(ttsData.voice.toLowerCase())
                                        );
                                        if (selectedVoice) {
                                            speech.voice = selectedVoice;
                                        }
                                    }
        
                                    speech.onstart = () => {
                                        showNotification('🔊 ' + ttsData.text, 'info');
                                    };
        
                                    speech.onend = () => {
                                        console.log('🦆 TTS finished');
                                    };
        
                                    speech.onerror = (event) => {
                                        console.error('🦆 TTS error:', event);
                                        showNotification('TTS error: ' + event.error, 'error');
                                    };
        
                                    window.speechSynthesis.speak(speech);
        
                                } catch (e) {
                                    console.error('Error parsing TTS message:', e);
                                }
                                return;
                            }

                            // 🦆 says ⮞ handle TV channel updates
                            if (topic.startsWith('zigbee2mqtt/tv/') && topic.endsWith('/channel')) {
                                try {
                                    const data = JSON.parse(message.toString());
                                    const deviceIp = topicParts[2];
                                    console.log('TV channel update:', deviceIp, data);
                                    const tvConfig = ${builtins.toJSON config.house.tv};
                                    const tvDevice = Object.entries(tvConfig).find(([name, config]) => 
                                        config.ip === deviceIp
                                    );
        
                                    if (tvDevice) {
                                        const tvName = tvDevice[0];
                                        const tvKey = `tv_''${tvName}`;
                                        devices[tvKey] = { ...devices[tvKey], ...data };
                                        console.log('Updated TV state for:', tvKey, devices[tvKey]);
                                        updateTVChannelDisplay(deviceIp, data);
                                        saveState();
                                    }
                                } catch (e) {
                                    console.error('Error parsing TV channel message:', e);
                                }
                                return;
                            }

                            if (deviceName === 'tibber') {
                                try {
                                    const data = JSON.parse(message.toString());
            
                                    if (topicParts[2] === 'price') {
                                       document.getElementById('energyPrice').textContent = 
                                           data.current_price.toFixed(2) + ' SEK/kWh';
                                    } 
                                    else if (topicParts[2] === 'usage') {
                                        document.getElementById('energyUsage').textContent = 
                                        data.monthly_usage.toFixed(1) + ' kWh (month)';
                                    }
                                } catch (e) {
                                    console.error('Error parsing Tibber message:', e);
                                }
                                return;
                            }
    
                            if (topic.startsWith('zigbee2mqtt/tibber/')) {
                                try {
                                    const data = JSON.parse(message.toString());
                                    devices.tibber = {...devices.tibber, ...data};
            
                                    if (data.current_price !== undefined) {
                                        document.getElementById('energyPrice').textContent = 
                                            data.current_price.toFixed(2) + ' SEK/kWh';
                                    }
                                    if (data.monthly_usage !== undefined) {
                                        document.getElementById('energyUsage').textContent = 
                                            data.monthly_usage.toFixed(1) + ' kWh (month)';
                                    }
            
                                    saveState();
                                } catch (e) {
                                    console.error('Error parsing Tibber message:', e);
                                }
                                return;
                            }

                            if (topicParts.length === 2) {
                                try {
                                    const data = JSON.parse(message.toString());
                                    devices[deviceName] = data;    
                                    saveState();     
                                    updateDeviceSelector(); 
                                    if (selectedDevice === deviceName) {
                                        updateDeviceUI(data);
                                    }      
                                    updateStatusCards();
                                    onMQTTDataUpdate();   
                                    
                                    // 🦆 says ⮞ update room control UI
                                    if (window.updateDeviceUIFromMQTT) {
                                      updateDeviceUIFromMQTT(deviceName, data);
                                    }
                                    
                                    if (window.syncRoomToggles) {
                                        window.syncRoomToggles();
                                    }
                                } catch (e) {
                                    console.error('Error parsing message: ', e);
                                }
                            }

                        });
                        
                        client.on('close', function() {
                            showConnectionStatus(); // 🦆 says ⮞ show on disconnect
                            statusElement.className = 'connection-status status-error';
                            statusElement.innerHTML = '<i class="fas fa-exclamation-triangle"></i><span>⚠️📛</span>';
                        });
                        
                    } catch (err) {
                        statusElement.className = 'connection-status status-error';
                        statusElement.innerHTML = '<i class="fas fa-exclamation-triangle"></i><span>Connection failed</span>';
                        console.error('Connection error: ', err);
                    }
                }
                
                function showNotification(message, type) {
                    notification.textContent = message;
                    notification.className = `notification ''${type} show`;
                    
                    setTimeout(() => {
                        notification.className = 'notification hidden';
                    }, 3000);
                }
                
                function updateDeviceSelector() {
                    const selector = document.getElementById('deviceSelect');
                    const currentValue = selector.value;    
                    while (selector.options.length > 1) {
                        selector.remove(1);
                    }
    
                    Object.keys(devices).forEach(device => {
                        // 🦆 says ⮞ filter out system/bridge/availability entries
                        const excludedPatterns = [
                            'bridge',
                            'bridge/',
                            '../availability',
                            'tibber',
                            /^0x/,
                        ];
        
                        const shouldExclude = excludedPatterns.some(pattern => {
                            if (typeof pattern === 'string') {
                                return device.includes(pattern);
                            } else if (pattern instanceof RegExp) {
                                return pattern.test(device);
                            }
                            return false;
                        });
        
                        if (!shouldExclude) {
                            const option = document.createElement('option');
                            option.value = device;
                            option.textContent = device;
                            selector.appendChild(option);
                        }
                    });
    
                    if (devices[currentValue]) {
                        selector.value = currentValue;
                    }
                }
              
                function updateDeviceUI(data) {
                    console.log('Updating device UI for:', selectedDevice);
                    console.log('Device data:', data);
                    document.getElementById('currentDeviceName').textContent = selectedDevice;
                    
                    const statusText = data.state === 'ON' ? 'On • Connected' : 'Off • Connected';
                    document.getElementById('currentDeviceStatus').textContent = statusText;
                    
                    const topic = `zigbee2mqtt/''${selectedDevice}`;
                    renderMessage(data, topic);
                    
                    console.log('Device icon:', deviceIcons[selectedDevice]);
                    updateDeviceIcon(selectedDevice);
                }
                
                function updateStatusCards() {
                    let temperature = '--.-';
                    let tempLocation = 'No sensor';

                    for (const [device, data] of Object.entries(devices)) {
                        if (data.temperature !== undefined) {
                            temperature = data.temperature;
                            tempLocation = device;
                            break;
                        }
                    }    
                    // 🦆 says ⮞ update temperature elements
                    const temperatureValueElement = document.getElementById('temperatureValue');
                    if (temperatureValueElement) {
                        temperatureValueElement.textContent = `''${temperature}°C`;
                    }
                    const temperatureLocationElement = document.getElementById('temperatureLocation');
                    if (temperatureLocationElement) {
                        temperatureLocationElement.textContent = tempLocation;
                    }
                }
      
                function updateDeviceIcon(deviceName) {
                    console.log('updateDeviceIcon called for:', deviceName);
                    const icon = deviceIdToIcon[deviceName] || deviceIcons[deviceName] || "mdi:lightbulb";
                    console.log('Resolved icon for', deviceName, ':', icon);
                    const iconName = icon.replace("mdi:", "");
                    console.log('Processed icon name:', iconName);
                    const iconElement = document.getElementById('currentDeviceIcon');
                    console.log('Icon element found:', !!iconElement);
                    if (iconElement) {
                        iconElement.className = 'mdi mdi-' + iconName;
                        console.log('Final icon classes:', iconElement.className);
                    }
                }
      
                function sendCommand(device, command) {
                    if (!client || !client.connected) {
                        showNotification('Not connected to MQTT', 'error');
                        return;
                    }
                    
                    const topic = `zigbee2mqtt/''${device}/set`;
                    client.publish(topic, JSON.stringify(command), function(err) {
                        if (err) {
                            showNotification('Failed to send command', 'error');
                            console.error('Publish error: ', err);
                        } else {
                            devices[device] = {...devices[device], ...command};
                            saveState();
                        }
                    });
                }
                window.sendCommand = sendCommand;
                
                function showPage(pageId) {
                    console.log('🦆 Switching to page:', pageId, typeof pageId);
                    currentPage = pageId;
                
                    const pages = document.querySelectorAll('.page');
                    pages.forEach((page) => {
                        page.style.display = 'none';
                    });
                
                    const deviceSelectorContainer = document.getElementById('deviceSelectorContainer');
                    if (String(pageId) === "1") {
                        deviceSelectorContainer.classList.remove('hidden');
                    } else {
                        deviceSelectorContainer.classList.add('hidden');
                    }
                
                    navTabs.forEach((tab) => {
                        const tabPageIndex = tab.getAttribute('data-page');
                        if (tabPageIndex === String(pageId)) {
                            tab.classList.add('active');
                        } else {
                            tab.classList.remove('active');
                        }
                    });
                
                    const pageElement = document.querySelector(`.page[data-page="''${pageId}"]`);
                    console.log('🦆 Looking for page with data-page="' + pageId + '"', pageElement);
                    
                    if (pageElement) {
                        pageElement.style.display = 'block';
                        console.log('🦆 Page found and displayed');
                        
                        const pageNum = parseInt(pageId);
                        if (pageNum >= 4) {
                            const initFunction = window['initPage' + pageId];
                            console.log('🦆 Custom page init function:', initFunction);
                            if (initFunction && typeof initFunction === 'function') {
                                console.log('🦆 Calling custom page init function');
                                initFunction();
                            }
                        }
                    } else {
                        console.error('🦆 Page element not found for data-page="' + pageId + '"');
                        // 🦆 fallback
                        const fallbackPage = document.querySelector('.page[data-page="0"]');
                        if (fallbackPage) {
                            fallbackPage.style.display = 'block';
                            console.log('🦆 Fallback to page 0');
                        }
                    }
                
                    saveState();
                }
          
                ${customPagesJs}
         
                function updateLinkquality(percent) {
                  const bars = document.querySelectorAll(".lq-bar");
                  const activeBars = Math.round((percent / 100) * bars.length);
                  bars.forEach((bar, idx) => {
                    bar.className = "lq-bar"; // 🦆 says ⮞ reset
                    if (idx < activeBars) {
                      if (percent > 75) bar.classList.add("good");
                      else if (percent > 50) bar.classList.add("ok");
                      else if (percent > 25) bar.classList.add("bad");
                      else bar.classList.add("terrible");
                    } else {
                    }
                  });
                }
    
                function setRangeGradient(slider, startColor, endColor) {
                    const existingStyle = document.getElementById('sliderGradientStyle');
                    if (existingStyle) {
                        existingStyle.remove();
                    }
    
                    const style = document.createElement('style');
                    style.id = 'sliderGradientStyle';
    
                    const sliderId = `slider-''${Math.random().toString(36).substr(2, 9)}`;
                    slider.id = sliderId;
    
                    style.textContent = `
                        #''${sliderId} {
                            background: linear-gradient(to right, ''${startColor}, ''${endColor});
                        }
        
                        #''${sliderId}::-webkit-slider-thumb {
                            background: var(--primary);
                        }
        
                        #''${sliderId}::-moz-range-thumb {
                            background: var(--primary);
                        }
                    `;
                    document.head.appendChild(style);
                }

                function updatePosition(value) {
                    const position = clamp(parseInt(value), 0, 100);
                    document.querySelector('.position-value').textContent = `''${position}%`;
                
                }
    
                function clamp(value, min, max) {
                    return Math.min(Math.max(value, min), max);
                }    

                function publishPatch(payload) {
                    if (!selectedDevice) {
                        showNotification('Please select a device first', 'error');
                        return;
                    }
                    
                    sendCommand(selectedDevice, payload);
                }


                /*🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆
                 🦆 says ⮞ RENDER MESSAGE
                 🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆*/
                function renderMessage(parsed, topic) {
                    const devicePanel = document.getElementById('devicePanel');
                    devicePanel.innerHTML = "";
                    
                    const deviceName = topic.split('/')[1] || 'Unknown';
                    const title = document.createElement('div');
                    title.className = 'panel-title';
    
                    devicePanel.appendChild(title);
                        
                    const jsonDiv = document.createElement('div');
                    jsonDiv.className = 'json';
                    devicePanel.appendChild(jsonDiv);
                    
                    const entries = Object.entries(parsed);
                    let controlsHtml = "";
                    let rowsHtml = "";
                    
                    // 🦆 says ⮞ STATE (toggle)
                    if ('state' in parsed) {
                        const checked = String(parsed.state).toUpperCase() === 'ON' ? 'checked' : "";
                        const stateText = parsed.state === 'ON' ? 'ON' : 'OFF';
                        const stateClass = parsed.state === 'ON' ? 'state-on' : 'state-off';
    
                        controlsHtml += `
                            <div class="section">Power</div>
                            <div class="row special">
                                <div class="state-display ''${stateClass}">
                                    <label class="switch">
                                        <input type="checkbox" id="stateToggle" ''${checked}>
                                        <span class="slider-round"></span>
                                    </label>
                                    <span class="state-text">''${stateText}</span>
                                </div>
                            </div>`;
                    }

               
                    // 🦆 says ⮞ BATTERY METER
                    if ('battery' in parsed) {
                        const level = clamp(Number(parsed.battery) || 0, 0, 100);
                        controlsHtml += `
                            <div class="section">Battery</div>
                            <div class="battery-container">
                                <div class="battery-fill" style="width:''${level}%"></div>
                                <div class="battery-text">''${level}%</div>
                            </div>`;
                    }
                    
                    // 🦆 says ⮞ TEMPERATURE 
                    if ('temperature' in parsed) {
                        const temp = Number(parsed.temperature) || 0;
                        let classes = 'temperature-value';

                        if (temp < 20.0) classes += ' cold';
                        else if (temp < 23.0) classes += ' good';
                        else if (temp < 23.5) classes += ' warm';
                        else if (temp < 24.0) classes += ' warmer';
                        else classes += ' hot';

                        controlsHtml += `
                            <div class="section">Temperature</div>
                            <div class="temperature-container">
                                <div class="''${classes}">''${temp.toFixed(2)}°C</div>
                            </div>`;
                    }


                    // 🦆 says ⮞ LINK QUALITY
                    if ('linkquality' in parsed) {
                        const lq = clamp(Number(parsed.linkquality) || 0, 0, 100);
                        const totalBars = 4;
                        const activeBars = Math.round((lq / 100) * totalBars);

                        let barsHtml = "";
                        for (let i = 0; i < totalBars; i++) {
                            let classes = 'lq-bar-mini';
                            if (i < activeBars) {
                                if (lq > 75) classes += ' good';
                                else if (lq > 50) classes += ' ok';
                                else if (lq > 25) classes += ' bad';
                                else classes += ' terrible';
                            } else {
                                classes += ' off';
                            }
                            barsHtml += `<div class="''${classes}"></div>`;
                        }

                        const lqMini = document.querySelector('.linkquality-mini');
                        if (lqMini) {
                            lqMini.querySelector('.lq-bars').innerHTML = barsHtml;
                            lqMini.querySelector('.lq-value').textContent = lq;
                        }
                    }

                    // 🦆 says ⮞ CONTACT
                    if ('contact' in parsed) {
                        const contact = parsed.contact;
                        const contactText = contact ? 'Closed' : 'Open';
                        const contactClass = contact ? 'contact-closed' : 'contact-open';

                        controlsHtml += `
                            <div class="section">Contactr</div>
                            <div class="row special">
                                <div class="contact-status ''${contactClass}">
                                    ''${contactText}
                                </div>
                            </div>`;
                    }

                    // 🦆 says ⮞ BLINDs YAAAAY
                    if ('position' in parsed) {
                        const position = clamp(Number(parsed.position) || 0, 0, 100);
    
                        controlsHtml += `
                            <div class="section">Position</div>
                            <div class="row special">
                                <div class="position-controls">
                                    <button class="cover-btn open" onclick="publishPatch({position: 100})">
                                        <i class="fas fa-arrow-up"></i> Open
                                    </button>
                                    <button class="cover-btn stop" onclick="publishPatch({stop: true})">
                                        <i class="fas fa-stop"></i> Stop
                                    </button>
                                    <button class="cover-btn close" onclick="publishPatch({position: 0})">
                                        <i class="fas fa-arrow-down"></i> Close
                                    </button>
                               </div>
                               <div class="position-display">
                                    <div class="position-value">''${position}%</div>
                               </div>
                            </div>`;
                    }

                    // 🦆 says ⮞ MOTION
                    if ('occupancy' in parsed) {
                        const occupancy = parsed.occupancy;
                        let occupancyText, occupancyClass;
    
                        if (occupancy) {
                            occupancyText = 'Motion detected';
                            occupancyClass = 'occupancy-detected';
                            if (devices[selectedDevice]) {
                                devices[selectedDevice].lastMotion = new Date().toISOString();
                                saveState();
                            }
                        } else {
                            occupancyClass = 'occupancy-clear';
                            if (devices[selectedDevice] && devices[selectedDevice].lastMotion) {
                                occupancyText = 'Last motion ' + timeAgo(devices[selectedDevice].lastMotion);
                            } else {
                               occupancyText = 'No motion detected';
                            }
                        }

                        controlsHtml += `
                            <div class="section">Motion</div>
                            <div class="row special">
                                <div class="occupancy-status ''${occupancyClass}">''${occupancyText}</div>
                            </div>`;
                    }
                    
                    // 🦆 says ⮞ BRIGHTNESS
                    if ('brightness' in parsed) {
                        const v = clamp(Number(parsed.brightness) || 0, 0, 255);
                        const percent = Math.round((v / 255) * 100);
    
                        controlsHtml += `
                            <div class="section">Brightness</div>
                            <div class="row special">
                                <div class="brightness-display">
                                    <div class="brightness-value">''${percent}%</div>
                                    <div class="slider-row">
                                        <input type="range" min="0" max="255" value="''${v}" id="brightnessSlider" class="brightness-slider">
                                    </div>
                                </div>
                            </div>`;
                    }
                    
                    // 🦆 says ⮞ COLOR
                    if ('color' in parsed) {
                        const col = normalizeColor(parsed.color);
    
                        controlsHtml += `
                            <div class="section">Color</div>
                            <div class="row special">
                                <div class="color-section">
                                    <div class="color-presets">
                                        <div class="color-preset" style="background: #ff3b30;" onclick="setColor('#ff3b30')"></div>
                                        <div class="color-preset" style="background: #ff9500;" onclick="setColor('#ff9500')"></div>
                                        <div class="color-preset" style="background: #ffcc00;" onclick="setColor('#ffcc00')"></div>
                                        <div class="color-preset" style="background: #4cd964;" onclick="setColor('#4cd964')"></div>
                                        <div class="color-preset" style="background: #5ac8fa;" onclick="setColor('#5ac8fa')"></div>
                                        <div class="color-preset" style="background: #007aff;" onclick="setColor('#007aff')"></div>
                                    </div>
                                    <div class="color-picker-container">
                                        <button class="color-picker-btn" onclick="openColorPicker()">
                                            <i class="fas fa-palette"></i> 🦆 says ⮞ custom color
                                        </button>
                                        <input type="color" id="hiddenColorPicker" style="display: none;" onchange="setColor(this.value)">
                                   </div>
                                </div>
                            </div>`;
                    }
                    
               //🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆
                    // 🦆 likez it ⮞  RAW!  ⮜ ti zekl 🦆 \\
               //🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆                    
                                    
                    // 🦆 says ⮞ OTHER FIELDS
                    rowsHtml += `<div class="section">Raw</div>`;
                    for (const [key, value] of entries) {
                        const lower = key.toLowerCase();
                        if (lower === 'state' || lower === 'brightness' || lower === 'color') continue;
                        
                        let disp = value;
                        let typeClass = 'val-string';
                        let style = "";
                        
                        if (lower === 'last_seen') {
                            disp = timeAgo(value);
                            typeClass = "";
                            style = 'color: var(--gray)';
                        } else if (typeof value === 'number') {
                            typeClass = 'val-number';
                            style = valueColor(key, value) ? `color: ''${valueColor(key, value)}` : "";
                            disp = formatValue(key, value);
                        } else if (typeof value === 'boolean') {
                            typeClass = 'val-boolean';
                        } else if (lower === 'linkquality') {
                            const num = Number(value);
                            const text = isFinite(num) ? linkQualityText(num) : String(value);
                            const css = isFinite(num) ? valueColor('linkquality', num) : "";
                            disp = text;
                            style = css ? `color: ''${css}` : "";
                            typeClass = "";
                        } else {
                            disp = formatValue(key, value);
                        }
                        
                        rowsHtml += `
                            <div class="row">
                                <div class="key">''${key}</div>
                                <div><span class="''${typeClass}" style="''${style}">''${disp}</span></div>
                            </div>`;
                    }
                    
                    jsonDiv.innerHTML = controlsHtml + rowsHtml;
                    
                    // 🦆 says ⮞ hook controls up yo
                    const toggle = document.getElementById('stateToggle');
                    if (toggle) {
                        toggle.onchange = () => {
                            const stateText = document.querySelector('.state-text');
                            const stateDisplay = document.querySelector('.state-display');
        
                            if (toggle.checked) {
                                stateText.textContent = 'ON';
                                stateDisplay.classList.remove('state-off');
                                stateDisplay.classList.add('state-on');
                                publishPatch({ state: 'ON' });
                            } else {
                                stateText.textContent = 'OFF';
                                stateDisplay.classList.remove('state-on');
                                stateDisplay.classList.add('state-off');
                                publishPatch({ state: 'OFF' });
                            }
                        };
                    }

                    const bright = document.getElementById('brightnessSlider');
                    const brightValue = document.querySelector('.brightness-value');
                    if (bright && brightValue) {
                        setRangeGradient(bright, '#000', '#ffd166');
    
                        bright.oninput = () => {
                            const v = clamp(parseInt(bright.value), 0, 255);
                            const percent = Math.round((v / 255) * 100);
                            brightValue.textContent = `''${percent}%`;
                            publishPatch({ brightness: v });
                        };
                    }
                    
                    const picker = document.getElementById('colorPicker');
                    const preview = document.getElementById('colorPreview');
                    const rS = document.getElementById('rSlider');
                    const gS = document.getElementById('gSlider');
                    const bS = document.getElementById('bSlider');
                    const wS = document.getElementById('wSlider');
                    const rB = document.getElementById('rBadge');
                    const gB = document.getElementById('gBadge');
                    const bB = document.getElementById('bBadge');
                    const wB = document.getElementById('wBadge');
                    
                    function rgbwToHex(r, g, b, w) {
                        const rA = clamp(r + w, 0, 255);
                        const gA = clamp(g + w, 0, 255);
                        const bA = clamp(b + w, 0, 255);
                        return '#' + [rA, gA, bA].map(v => v.toString(16).padStart(2, '0')).join("");
                    }
                    
                    function syncFromPicker(hex) {
                        if (!rS || !gS || !bS || !wS) return;
                        const m = /^#?([0-9a-f]{6})$/i.exec(hex);
                        if (!m) return;
                        const n = parseInt(m[1], 16);
                        rS.value = (n >> 16) & 255;
                        gS.value = (n >> 8) & 255;
                        bS.value = n & 255;
                        rB.textContent = rS.value;
                        gB.textContent = gS.value;
                        bB.textContent = bS.value;
                        preview.style.background = rgbwToHex(+rS.value, +gS.value, +bS.value, +wS.value);
                        publishPatch({ color: { r: +rS.value, g: +gS.value, b: +bS.value, w: +wS.value } });
                    }
                    
                    function syncFromSliders() {
                        if (!rS || !gS || !bS || !wS) return;
                        rB.textContent = rS.value;
                        gB.textContent = gS.value;
                        bB.textContent = bS.value;
                        wB.textContent = wS.value;
                        const hex = rgbwToHex(+rS.value, +gS.value, +bS.value, +wS.value);
                        if (picker) picker.value = hex;
                        if (preview) preview.style.background = hex;
                        publishPatch({ color: { r: +rS.value, g: +gS.value, b: +bS.value, w: +wS.value } });
                    }
                    
                    if (picker && preview) {
                        picker.oninput = () => syncFromPicker(picker.value);
                    }
                    
                    [rS, gS, bS, wS].forEach(el => {
                        if (el) el.oninput = syncFromSliders;
                    });
                }
                                
                async function loadInitialState() {
                    try {
                        const response = await fetch('/state.json');
                        if (!response.ok) {
                            throw new Error(`HTTP ''${response.status}: ''${response.statusText}`);
                        }
                
                        const serverState = await response.json();
                        const { ['bridge/state']: bridgeState, ...devicesState } = serverState;
                
                        // 🦆 says ⮞ normalize all device data
                        window.devices = {};
                        for (const [deviceKey, data] of Object.entries(devicesState)) {
                            const normalizedData = normalizeDeviceData(data);
                            window.devices[deviceKey] = normalizedData;
                            
                            // 🦆 says ⮞ also store by ID if we have a mapping
                            if (normalizedData.id) {
                                window.devices[normalizedData.id] = normalizedData;
                            }
                        }
                
                        console.log('🦆 Loaded devices:', Object.keys(window.devices));
                        console.log('🦆 Room mappings:', window.roomDeviceMappings);
                
                        if (window.updateAllRoomControls) {
                            window.updateAllRoomControls();
                        }
                
                        if (window.syncRoomTogglesFromState) {
                            window.syncRoomTogglesFromState();
                        }
                
                        // 🦆 says ⮞ update status cards
                        updateAllStatusCards();
                
                        showNotification('Initial state loaded from server', 'success');
                        
                        return window.devices;
                    } catch (error) {
                        console.error('Error loading initial state:', error);
                        showNotification('Using cached device data', 'info');
                        return {};
                    }
                }
                
                function normalizeDeviceData(data) {
                    const normalized = { ...data };
                    
                    // 🦆 says ⮞ ensure state is uppercase
                    if (normalized.state) {
                        normalized.state = String(normalized.state).toUpperCase();
                    }
                    
                    // 🦆 says ⮞ convert string numbers to actual numbers
                    if (normalized.brightness && typeof normalized.brightness === 'string') {
                        normalized.brightness = parseInt(normalized.brightness, 10);
                    }
                    
                    // 🦆 says ⮞ parse color if it's a string
                    if (normalized.color && typeof normalized.color === 'string') {
                        try {
                            normalized.color = JSON.parse(normalized.color);
                        } catch (e) {
                            console.warn('Failed to parse color:', normalized.color);
                        }
                    }
                    
                    return normalized;
                }


                function initDashboard() {
                    loadInitialState().then(() => {
                        console.log('🦆 Initial state loaded, devices:', Object.keys(window.devices));
        
                        if (window.initRoomControls) {
                            initRoomControls();
                        }
        
                        // 🦆 says ⮞ update room controls with current state
                        setTimeout(() => {
                            console.log('🦆 Updating room controls from state...');
                            if (window.updateAllRoomControls) {
                                updateAllRoomControls();
                            }
                            if (typeof syncRoomStatesAfterLoad === 'function') {
                                syncRoomStatesAfterLoad();
                            }
            
                            if (window.setInitialRoomCollapse) {
                                setInitialRoomCollapse();
                            }
                        }, 500);
        
                        loadSavedState();
                        statusCard.refreshAllFromAPI();
                        startAPIAutoRefresh();
    
                        document.getElementById('targetTV').addEventListener('change', function() {
                            const selectedTV = this.value;
                            const channelDisplay = document.getElementById('tvChannelDisplay');
                            if (selectedTV && channelDisplay) {
                                channelDisplay.style.display = 'block';
                                const tvConfig = ${builtins.toJSON config.house.tv};
                                const tvDevice = Object.entries(tvConfig).find(([name, config]) => 
                                    config.ip === selectedTV
                                );       
                                if (tvDevice) {
                                    const tvName = tvDevice[0];
                                    const tvKey = `tv_''${tvName}`;
                                    const tvState = devices[tvKey];   
                                    if (tvState) {
                                        updateTVChannelDisplay(selectedTV, tvState);
                                    } else {
                                        console.log('No TV state found for:', tvKey);
                                        const programTitle = document.getElementById('currentProgramTitle');
                                        if (programTitle) programTitle.textContent = 'No channel info';
                                        updateChannelIcon(null);
                                    }
                                }
                                if (window.epgData) {
                                    updateTVWithEPG(selectedTV);
                                }
                            } else if (channelDisplay) {
                                channelDisplay.style.display = 'none';
                            }
                        });

                        // 🦆 says ⮞ set default TV if none selected and we have options
                        const tvSelector = document.getElementById('targetTV');
                        if (tvSelector && tvSelector.options.length > 1 && !tvSelector.value) {
                            tvSelector.value = tvSelector.options[1].value;
                            tvSelector.dispatchEvent(new Event('change'));
                        }

                       // 🦆 says ⮞ load EPG data after TV is set up
                        setTimeout(loadEPGData, 500);

                        // 🦆 says ⮞ load initial TV channel state
                        loadInitialTVState();

                        navTabs.forEach((tab) => {
                            tab.addEventListener('click', () => {
                                const pageIndex = parseInt(tab.getAttribute('data-page'));
                                showPage(pageIndex);
                            });
                        });
        
                        // 🦆 says ⮞ swipe
                        let startX = 0;
                        let currentX = 0;  
                        pageContainer.addEventListener('touchstart', (e) => {
                            startX = e.touches[0].clientX;
                        });
        
                        pageContainer.addEventListener('touchmove', (e) => {
                            currentX = e.touches[0].clientX;
                        });
        
                        pageContainer.addEventListener('touchend', () => {
                            const diff = startX - currentX;
                            const swipeThreshold = 50;

                            if (Math.abs(diff) > swipeThreshold) {
                                if (diff > 0 && currentPage < 5) {
                                    // 🦆 says ⮞ swipe left
                                    showPage(currentPage + 1);
                                } else if (diff < 0 && currentPage > 0) {
                                    // 🦆 says ⮞ swipe right
                                    showPage(currentPage - 1);
                                }
                            }
                        });
                        
                        // 🦆 says ⮞ vertical swipe 4 da device page
                        function handleDevicePageVerticalSwipe(diffY) {
                            if (Math.abs(diffY) > verticalSwipeThreshold) {
                                const selector = document.getElementById('deviceSelect');
                                const options = Array.from(selector.options).filter(opt => opt.value);
                                
                                if (options.length > 0) {
                                    const currentIndex = options.findIndex(opt => opt.value === selectedDevice);
                                    let newIndex;
                                    
                                    if (diffY > 0) {
                                        // 🦆 says ⮞ swipe down - next device
                                        newIndex = (currentIndex + 1) % options.length;
                                    } else {
                                        // 🦆 says ⮞ swipe up - previous device
                                        newIndex = (currentIndex - 1 + options.length) % options.length;
                                    }
                                    
                                    if (newIndex >= 0 && newIndex < options.length) {
                                        selector.value = options[newIndex].value;
                                        selector.dispatchEvent(new Event('change'));
                                        showNotification(`Switched to ''${options[newIndex].textContent}`, 'success');
                                    }
                                }
                            }
                        }
                        
 
                        pageContainer.addEventListener('touchend', (e) => {
                            const diffY = startY - e.changedTouches[0].clientY;           
                            if (currentPage === 1 && Math.abs(diffY) > Math.abs(startX - currentX)) {
                                handleDevicePageVerticalSwipe(diffY);
                                return;
                            }
                            
                            if (!isSwiping) return;
                            
                            const diff = startX - currentX;
                            
                            if (Math.abs(diff) > swipeThreshold) {
                                if (diff > 0 && currentPage < 5) {
                                    showPage(currentPage + 1);
                                } else if (diff < 0 && currentPage > 0) {
                                    showPage(currentPage - 1);
                                }
                            }
                            isSwiping = false;
                        });
                   

                        document.querySelector('.logo').addEventListener('click', () => {
                            showPage(0);
                        });
        
                        document.getElementById('deviceSelect').addEventListener('change', function() {
                            selectedDevice = this.value;
                            window.selectedDevice = selectedDevice;
                            if (selectedDevice && devices[selectedDevice]) {
                                updateDeviceUI(devices[selectedDevice]);
                                showPage(1);
                            } else {
                                document.getElementById('currentDeviceName').textContent = 'Select a device';
                                document.getElementById('currentDeviceStatus').textContent = 'Choose a device from the dropdown';
                                document.getElementById('devicePanel').innerHTML = "";
                                showPage(0)
                            }

                            saveState();
                        });

                        // 🦆 says ⮞ duck assist
                        const searchInput = document.getElementById('searchInput');
                        searchInput.addEventListener('keypress', function(e) {
                            if (e.key === 'Enter') {
                                const command = this.value.trim();

                                if (command) {
                                    const payload = {
                                        command: command,
                                    };            
                                    if (client && client.connected) {
                                        console.log('MQTT client is connected, publishing command to topic: command');
                                        client.publish('zigbee2mqtt/command', JSON.stringify(payload));
                                        console.log('Command published successfully:', command);
                                        showNotification('Command sent: ' + command, 'success');
                                        this.value = "";
                                        console.log('Search input cleared');
                                    } else {
                                        console.error('MQTT client is not connected or client is null');
                                        showNotification('Not connected to MQTT', 'error');
                                    }
                                } else {
                                    console.log('Command is empty, ignoring');
                                }
                            }
                        });
        
                        document.querySelectorAll('.scene-item').forEach(item => {
                            item.addEventListener('click', function() {
                                const scene = this.getAttribute('data-scene');
                                activateScene(scene);
                            });
                        });
        
                        window.addEventListener('beforeunload', saveState);         
                        connectToMQTT();
                    }).catch(error => {
                        console.error('Failed to load initial state:', error);
                        // 🦆 says ⮞ fallback
                        loadSavedState();
                        connectToMQTT();
                    });
                }
                

                const API_BASE = `http://''${window.location.hostname}:9815`;
                             
                const apiService = {
                  async fetchTimers() {
                    try {
                      const response = await fetch(`''${API_BASE}/timers`);
                      return await response.json();
                    } catch (error) {
                      console.error('Failed to fetch timers:', error);
                      return { error: 'Failed to fetch timers' };
                    }
                  },
                
                  async fetchAlarms() {
                    try {
                      const response = await fetch(`''${API_BASE}/alarms`);
                      return await response.json();
                    } catch (error) {
                      console.error('Failed to fetch alarms:', error);
                      return { error: 'Failed to fetch alarms' };
                    }
                  },
                
                  async fetchShoppingList() {
                    try {
                      const response = await fetch(`''${API_BASE}/shopping`);
                      return await response.json();
                    } catch (error) {
                      console.error('Failed to fetch shopping list:', error);
                      return { error: 'Failed to fetch shopping list' };
                    }
                  },
                
                  async checkHealth() {
                    try {
                      const response = await fetch(`''${API_BASE}/health`);
                      return await response.json();
                    } catch (error) {
                      console.error('API health check failed:', error);
                      return { error: 'API unavailable' };
                    }
                  }
                };
                   
                                                      
                // 🦆 says ⮞ auto-refresh API data
                let apiRefreshIntervals = [];
                
                function startAPIAutoRefresh() {
                    stopAPIAutoRefresh();
                    
                    apiRefreshIntervals.push(setInterval(() => {
                        statusCard.refreshTimersFromAPI();
                    }, 5000));
                    
                    apiRefreshIntervals.push(setInterval(() => {
                        statusCard.refreshShoppingFromAPI();
                    }, 30000));
                    
                    apiRefreshIntervals.push(setInterval(() => {
                        apiService.checkHealth().then(health => {
                            if (!health.error) {
                                console.log('API health:', health);
                            }
                        });
                    }, 60000));
                }
                
                function stopAPIAutoRefresh() {
                    apiRefreshIntervals.forEach(interval => clearInterval(interval));
                    apiRefreshIntervals = [];
                }
              

                // 🦆 says ⮞ unified status card manager
                const statusCard = {
                  data: {
                    shopping: { updated: null, items: [], priority: 'medium' },
                    timers: { active: [], priority: 'high' },
                    calendar: { events: [], priority: 'medium' },
                    reminders: { items: [], priority: 'critical' }
                  },
                  
                  // 🦆 says ⮞ live update intervals
                  intervals: {},
                  
                  priorities: ['critical', 'high', 'medium', 'low', 'info'],
                  
                  // 🦆 says ⮞ save status card data to localStorage
                  saveData() {
                    try {
                      const statusData = JSON.stringify(this.data);
                      localStorage.setItem('duckDashStatusCard', statusData);
                      console.log('Status card data saved');
                    } catch (e) {
                      console.error('Error saving status card data:', e);
                    }
                  },
              
                  // 🦆 says ⮞ load status card data from localStorage
                  loadData() {
                    try {
                      const savedData = localStorage.getItem('duckDashStatusCard');
                      if (savedData) {
                        this.data = JSON.parse(savedData);
                        console.log('Status card data loaded:', this.data);
                        
                        // 🦆 says ⮞ restart timer countdowns if any are active
                        this.data.timers.active.forEach(timer => {
                          if (timer.remaining > 0) {
                            this.startTimerCountdown(timer.id);
                          }
                        });
                        
                        this.updateCard();
                      }
                    } catch (e) {
                      console.error('Error loading status card data:', e);
                    }
                  },
                
                  async refreshTimersFromAPI() {
                    try {
                      const timerData = await apiService.fetchTimers();
                      if (!timerData.error) {
                        this.handleTimersData(timerData);
                      }
                    } catch (error) {
                      console.error('API timer refresh failed:', error);
                    }
                  },

                  async refreshShoppingFromAPI() {
                    try {
                      const shoppingData = await apiService.fetchShoppingList();
                      if (!shoppingData.error) {
                        this.handleShoppingData(shoppingData);
                      }
                    } catch (error) {
                      console.error('API shopping refresh failed:', error);
                    }
                  },

                  async refreshAlarmsFromAPI() {
                    try {
                      const alarmData = await apiService.fetchAlarms();
                      if (!alarmData.error) {
                        this.handleAlarmsData(alarmData);
                      }
                    } catch (error) {
                      console.error('API alarm refresh failed:', error);
                    }
                  },

                  handleTimersData(data) {
                    console.log('🦆 Timers data received:', data);
                    const timers = data.active_timers || data.timers || data.data || [];
                    console.log('🦆 Processed timers:', timers);

                    const processedTimers = timers.map(timer => ({
                      id: timer.id,
                      name: `Timer ''${timer.id}`,
                      remaining: (timer.hours_left * 3600) + (timer.minutes_left * 60) + timer.seconds_left,
                      target: timer.target
                    }));
  
                    console.log('🦆 Processed timers for countdown:', processedTimers);

                    processedTimers.forEach(timer => {
                      if (timer.remaining > 0) {
                        this.startTimerCountdown(timer.id);
                      }
                    });

                    this.data.timers = {
                      active: processedTimers,
                      priority: 'high'
                    };
                    this.updateCard();
                  },

                  handleShoppingData(data) {
                    console.log('🦆 Shopping data received:', data);
                    const items = data.items || data.data || [];
                    this.data.shopping = {
                      updated: new Date().toISOString(),
                      items: items,
                      priority: 'medium'
                    };
                    this.updateCard();
                  },

                  handleAlarmsData(data) {
                    const alarms = data.alarms || data.data || [];
                    this.data.alarms = {
                      active: alarms,
                      priority: 'high'
                    };
                    this.updateCard();
                  },    
                
                  updateCard() {
                    console.log('🦆 Updating status card with data:', this.data);
                    const card = document.getElementById('unifiedStatusCard');
                    const title = document.getElementById('statusCardTitle');
                    const value = document.getElementById('statusCardValue');
                    const details = document.getElementById('statusCardDetails');
                    const icon = document.getElementById('statusCardIcon');
                    
                    // 🦆 says ⮞ find highest priority content
                    const content = this.getHighestPriorityContent();
                    
                    if (!content) {
                      title.textContent = 'All Clear';
                      value.textContent = 'No notifications';
                      details.innerHTML = '<i class="fas fa-check-circle"></i><span>Everything is quiet</span>';
                      icon.className = 'fas fa-check-circle';
                      card.className = 'card unified-status-card status-priority-info';
                      return;
                    }
                    
                    // 🦆 says ⮞ update card
                    title.textContent = content.title;
                    value.textContent = content.value;
                    details.innerHTML = content.details;
                    icon.className = content.icon;
                    card.className = 'card unified-status-card status-priority-' + content.priority;
                    
                    // 🦆 says ⮞ auto-save when card updates
                    this.saveData();
                  },
                  
                  getHighestPriorityContent() {
                    console.log('🦆 Finding highest priority content from:', this.data);
                    // 🦆 says ⮞ check reminders first
                    if (this.data.reminders.items.length > 0) {
                      const reminder = this.data.reminders.items[0];
                      return {
                        title: 'Reminder',
                        value: reminder.text,
                        details: '<i class="fas fa-bell"></i><span>Tap to dismiss</span>',
                        icon: 'fas fa-bell',
                        priority: 'critical'
                      };
                    }
                    
                    // 🦆 says ⮞ active timers (high)
                    const activeTimer = this.data.timers.active.find(t => t.remaining > 0);
                    if (activeTimer) {
                      return {
                        title: 'Timer',
                        value: activeTimer.name || 'Active Timer',
                        details: '<i class="fas fa-clock"></i><span>' + this.formatTimeRemaining(activeTimer.remaining) + '</span>',
                        icon: 'fas fa-clock',
                        priority: 'high'
                      };
                    }
                    
                    // 🦆 says ⮞ check calendar events happening soon (medium)
                    const upcomingEvent = this.getNextCalendarEvent();
                    if (upcomingEvent) {
                      return {
                        title: 'Calendar',
                        value: upcomingEvent.title,
                        details: '<i class="fas fa-calendar"></i><span>' + this.formatEventTime(upcomingEvent) + '</span>',
                        icon: 'fas fa-calendar',
                        priority: 'medium'
                      };
                    }
                    
                    // 🦆 says ⮞ check recent shopping list updates (low)
                    if (this.isShoppingListRecent()) {
                      const itemCount = this.data.shopping.items.length;
                      return {
                        title: 'Shopping',
                        value: itemCount + ' item' + (itemCount !== 1 ? 's' : ""),
                        details: '<i class="fas fa-cart-plus"></i><span>Updated recently</span>',
                        icon: 'fas fa-shopping-cart',
                        priority: 'low'
                      };
                    }
                    
                    return null;
                  },
                                   
                  async refreshAllData() {
                    await this.refreshTimersFromAPI();
                    await this.refreshShoppingFromAPI();
                    await this.refreshAlarmsFromAPI();
                  },
                  
                  
                  // 🦆 says ⮞ timer functions
                  formatTimeRemaining(seconds) {
                    if (seconds <= 0) return 'Finished!';              
                    const hours = Math.floor(seconds / 3600);
                    const minutes = Math.floor((seconds % 3600) / 60);
                    const secs = seconds % 60;
                    
                    if (hours > 0) {
                      return `''${hours}h ''${minutes}m ''${secs}s`;
                    } else if (minutes > 0) {
                      return `''${minutes}m ''${secs}s`;
                    } else {
                      return `''${secs}s`;
                    }
                  },
                  
                  startTimerCountdown(timerId) {
                    // 🦆 says ⮞ clear existing interval for this timer
                    if (this.intervals[timerId]) {
                      clearInterval(this.intervals[timerId]);
                    }
                    
                    this.intervals[timerId] = setInterval(() => {
                      const timer = this.data.timers.active.find(t => t.id === timerId);
                      if (!timer) {
                        clearInterval(this.intervals[timerId]);
                        return;
                      }
                      
                      timer.remaining--;
                      
                      if (timer.remaining <= 0) {
                        // 🦆 says ⮞ timer finished!
                        clearInterval(this.intervals[timerId]);
                        timer.remaining = 0;
                        showNotification(`Timer "''${timer.name}" finished!`, 'success');
                        
                        // 🦆 says ⮞ play sound or flash notification
                        this.playTimerFinishedSound();
                      }
                      
                      // 🦆 says ⮞ update the card display
                      this.updateCard();
                      this.saveData();
                      
                    }, 1000);
                  },
                  
                  playTimerFinishedSound() {
                    // 🦆 says ⮞ beep sound for timer completion
                    try {
                      const audioContext = new (window.AudioContext || window.webkitAudioContext)();
                      const oscillator = audioContext.createOscillator();
                      const gainNode = audioContext.createGain();
                      
                      oscillator.connect(gainNode);
                      gainNode.connect(audioContext.destination);
                      
                      oscillator.frequency.value = 800;
                      oscillator.type = 'sine';
                      
                      gainNode.gain.setValueAtTime(0.3, audioContext.currentTime);
                      gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + 1);
                      
                      oscillator.start(audioContext.currentTime);
                      oscillator.stop(audioContext.currentTime + 1);
                    } catch (e) {
                      console.log('Audio context not supported, using fallback notification');
                    }
                  },
                  
                  formatEventTime(event) {
                    const now = new Date();
                    const eventTime = new Date(event.start);
                    const diffHours = Math.floor((eventTime - now) / (1000 * 60 * 60));
                    
                    if (diffHours < 1) return 'Starting soon';
                    if (diffHours < 24) return 'Today at ' + eventTime.toLocaleTimeString('sv-SE', {hour: '2-digit', minute: '2-digit'});
                    return 'In ' + diffHours + ' hours';
                  },
                  
                  getNextCalendarEvent() {
                    const now = new Date();
                    const next24Hours = new Date(now.getTime() + 24 * 60 * 60 * 1000);
                    
                    return this.data.calendar.events.find(event => {
                      const eventTime = new Date(event.start);
                      return eventTime > now && eventTime < next24Hours;
                    });
                  },
                  
                  isShoppingListRecent() {
                    if (!this.data.shopping.updated) return false;
                    const updated = new Date(this.data.shopping.updated);
                    const now = new Date();
                    const diffHours = (now - updated) / (1000 * 60 * 60);
                    return diffHours < 24; // 🦆 says ⮞ show if updated in last 24 hours
                  },
                  
                  // 🦆 says ⮞ click handler to dismiss reminders
                  dismissReminder() {
                    if (this.data.reminders.items.length > 0) {
                      this.data.reminders.items.shift(); // Remove the first reminder
                      this.updateCard();
                      showNotification('Reminder dismissed', 'success');
                    }
                  },
                  
                  // 🦆 says ⮞ MQTT message handlers
                  handleShoppingListMQTT(message) {
                    try {
                      const data = JSON.parse(message.toString());
                      this.data.shopping = {
                        updated: new Date().toISOString(),
                        items: data.items || [],
                        priority: 'medium'
                      };
                      this.updateCard();
                    } catch (e) {
                      console.error('Error parsing shopping list:', e);
                    }
                  },
                  
                  handleTimersMQTT(message) {
                    try {
                      const data = JSON.parse(message.toString());
                      const newTimers = data.active_timers || data.timers || [];
                      
                      // 🦆 says ⮞ generate unique IDs for new timers
                      newTimers.forEach(timer => {
                        if (!timer.id) {
                          timer.id = 'timer_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
                        }
                        
                        // 🦆 says ⮞ start countdown for new timers
                        if (timer.remaining > 0) {
                          this.startTimerCountdown(timer.id);
                        }
                      });
                      
                      this.data.timers = {
                        active: newTimers,
                        priority: 'high'
                      };
                      this.updateCard();
                    } catch (e) {
                      console.error('Error parsing timers:', e);
                    }
                  },
                  
                  handleCalendarMQTT(message) {
                    try {
                      const data = JSON.parse(message.toString());
                      this.data.calendar = {
                        events: data.events || [],
                        priority: 'medium'
                      };
                      this.updateCard();
                    } catch (e) {
                      console.error('Error parsing calendar:', e);
                    }
                  },
                  
                  handleRemindersMQTT(message) {
                    try {
                      const data = JSON.parse(message.toString());
                      this.data.reminders = {
                        items: data.reminders || data.items || [],
                        priority: 'critical'
                      };
                      this.updateCard();
                    } catch (e) {
                      console.error('Error parsing reminders:', e);
                    }
                  }
                };
                
                               
                function setupStatusSubscriptions() {
                    statusCard.refreshAllData();
                }
  
                statusCard.refreshAllFromAPI = function() {
                  this.refreshTimersFromAPI();
                  this.refreshAlarmsFromAPI();
                  this.refreshShoppingFromAPI();
                };
    
                initDashboard();
                
                // 🦆 says ⮞ long-press status card
                let longPressTimer;
                let isLongPressing = false;
                
                const unifiedStatusCard = document.getElementById('unifiedStatusCard');
                
                // 🦆 says ⮞ touch events for mobile
                unifiedStatusCard.addEventListener('touchstart', startLongPress);
                unifiedStatusCard.addEventListener('touchend', endLongPress);
                unifiedStatusCard.addEventListener('touchmove', endLongPress);
                
                // 🦆 says ⮞ mouse events for desktop
                unifiedStatusCard.addEventListener('mousedown', startLongPress);
                unifiedStatusCard.addEventListener('mouseup', endLongPress);
                unifiedStatusCard.addEventListener('mouseleave', endLongPress);
                
                function startLongPress(e) {
                    isLongPressing = true;
                    longPressTimer = setTimeout(() => {
                        if (isLongPressing) {
                            showStatusCardActions(e);
                        }
                    }, 1000); // 🦆 says ⮞ 1 sec press
                }
                
                function endLongPress() {
                    isLongPressing = false;
                    clearTimeout(longPressTimer);
                }

                window.readStatusAloud = function() {
                    console.log('🦆 Reading status aloud');
                    const title = document.getElementById('statusCardTitle').textContent;
                    const value = document.getElementById('statusCardValue').textContent;
                    const details = document.getElementById('statusCardDetails').textContent;
                    // 🦆 says ⮞ shut up if speakiong
                    window.speechSynthesis.cancel();
                    const speech = new SpeechSynthesisUtterance();
                    speech.text = `''${title}. ''${value}. ''${details}`;
                    speech.rate = 0.9;
                    speech.pitch = 1;
                    speech.volume = 0.8;
                    // 🦆 says ⮞ get voices
                    const voices = window.speechSynthesis.getVoices();
                    if (voices.length > 0) {
                        // 🦆 says ⮞ i like ladies
                        const femaleVoice = voices.find(voice => 
                            voice.name.includes('Female') || voice.name.includes('woman') || voice.name.includes('Samantha')
                        );
                        if (femaleVoice) {
                            speech.voice = femaleVoice;
                        }
                    }
                    window.speechSynthesis.speak(speech);
                    showNotification('Reading status aloud', 'success');
                    closeActionMenu();
                };

                window.hideStatusNotification = function() {
                    console.log('🦆 Hiding status notification');
                    let cardManager = window.statusCard || statusCard;    
                    if (cardManager && typeof cardManager.dismissCurrentNotification === 'function') {
                        console.log('🦆 Calling dismissCurrentNotification');
                        cardManager.dismissCurrentNotification();
                        showNotification('Notification dismissed', 'success');
                    } else {
                        console.error('🦆 statusCard.dismissCurrentNotification not found', {
                            windowStatusCard: !!window.statusCard,
                            localStatusCard: !!statusCard,
                            hasDismissMethod: cardManager ? typeof cardManager.dismissCurrentNotification : 'no cardManager'
                        });
                        showNotification('Cannot dismiss notification - function not found', 'error');
                    }
                    closeActionMenu();
                };

                window.closeActionMenu = function() {
                    console.log('🦆 Closing action menu');
                    const menu = document.getElementById('statusCardActionMenu');
                    const backdrop = document.querySelector('.action-menu-backdrop');
    
                    if (menu) {
                        // 🦆 says ⮞ remove escape handler
                        if (menu._escapeHandler) {
                            document.removeEventListener('keydown', menu._escapeHandler);
                        }
                        menu.remove();
                        console.log('🦆 Menu removed');
                    }
                    if (backdrop) {
                        backdrop.remove();
                        console.log('🦆 Backdrop removed');
                    }
    
                    // 🦆 says ⮞ reset da long press state
                    isLongPressing = false;
                    if (longPressTimer) {
                        clearTimeout(longPressTimer);
                        longPressTimer = null;
                    }
                };

                function showStatusCardActions(e) {
                    // 🦆 says ⮞ remove existing action menu
                    const existingMenu = document.getElementById('statusCardActionMenu');
                    if (existingMenu) {
                        existingMenu.remove();
                    }
                
                    // 🦆 says ⮞ create action menu
                    const actionMenu = document.createElement('div');
                    actionMenu.id = 'statusCardActionMenu';
                    actionMenu.className = 'status-card-action-menu';
                    
                    // 🦆 says ⮞ get current status card content
                    const title = document.getElementById('statusCardTitle').textContent;
                    const value = document.getElementById('statusCardValue').textContent;
                    
                    actionMenu.innerHTML = `
                        <div class="action-menu-header">
                            <h3>''${title}</h3>
                            <p>''${value}</p>
                        </div>
                        <div class="action-buttons">
                            <button class="action-btn read-btn" onclick="readStatusAloud()">
                                <i class="fas fa-volume-up"></i>
                                Read
                            </button>
                            <button class="action-btn hide-btn" onclick="hideStatusNotification()">
                                <i class="fas fa-eye-slash"></i>
                                Hide
                            </button>
                            <button class="action-btn cancel-btn" onclick="closeActionMenu()">
                                <i class="fas fa-times"></i>
                                Cancel
                            </button>
                        </div>
                    `;
                
                    // 🦆 says ⮞ position near the status card
                    const cardRect = unifiedStatusCard.getBoundingClientRect();
                    actionMenu.style.position = 'fixed';
                    actionMenu.style.top = `''${cardRect.top + window.scrollY}px`;
                    actionMenu.style.left = `''${cardRect.left + window.scrollX}px`;
                    actionMenu.style.width = `''${cardRect.width}px`;
                
                    document.body.appendChild(actionMenu);
                    
                    // 🦆 says ⮞ backdrop
                    const backdrop = document.createElement('div');
                    backdrop.className = 'action-menu-backdrop';
                    backdrop.onclick = closeActionMenu;
                    document.body.appendChild(backdrop);
                }
                               
                statusCard.dismissCurrentNotification = function() {
                    console.log('🦆 Dismissing current notification');
                    const content = this.getHighestPriorityContent();
                    if (!content) {
                        console.log('🦆 No content to dismiss');
                        return;
                    }  
                    console.log('🦆 Dismissing content with priority:', content.priority);    
                    // 🦆 says ⮞ dismiss based on priority type
                    if (content.priority === 'critical') {
                        // 🦆 says ⮞ remove first reminder
                        if (this.data.reminders.items.length > 0) {
                            this.data.reminders.items.shift();
                            console.log('🦆 Dismissed reminder');
                        }
                    } else if (content.priority === 'high') {
                        // 🦆 says ⮞ clear active timers
                        this.data.timers.active = [];
                        // 🦆 says ⮞ clear any timer intervals
                        Object.values(this.intervals).forEach(interval => clearInterval(interval));
                        this.intervals = {};
                        console.log('🦆 Dismissed timers');
                    } else if (content.priority === 'medium') {
                        // 🦆 says ⮞ mark shopping list as not recent
                        this.data.shopping.updated = new Date(0).toISOString();
                        console.log('🦆 Dismissed shopping list');
                    } else if (content.priority === 'low') {
                        // 🦆 says ⮞ handle low priority items
                        console.log('🦆 Dismissed low priority item');
                    } 
                    this.updateCard();
                    this.saveData();
                    console.log('🦆 Notification dismissed successfully');
                };
                // 🦆 says ⮞ make it global
                window.statusCard = statusCard;           
                
            });
        </script>
    </body>
    </html>       
  '';

in {

  yo.scripts = { 
    duckDash = {
      description = "Mobile-first dashboard, unified frontend for Zigbee devices, tv remotes, and other smart home gadgets. Includes DuckCloud page for easy access to your files. (Use WireGuard)";
      aliases = [ "dash" ];
      category = "🛖 Home Automation";  
      autoStart = config.this.host.hostname == "homie";
      parameters = [   
        { name = "host"; description = "IP address of the host (127.0.0.1 / 0.0.0.0"; default = "0.0.0.0"; }      
        { name = "port"; description = "Port to run the frontend service on"; default = "13337"; }
        { name = "cert"; description = "Path to SSL certificate to run the sever on"; default = "/home/pungkula/.ssl/cert.pem"; } 
        { name = "key"; description = "Path to key file to run the sever on"; default = "/home/pungkula/.ssl/key.pem"; } 
      ];
      code = ''
        ${cmdHelpers}
        HOST=$host
        PORT=$port
        CERT_FILE="$cert"
        KEY_FILE="$key"
        dt_info "Starting 🦆'Dash server on port $PORT"
        ${httpServer}/bin/serve-dashboard "$HOST" "$PORT"
      '';
    };  
  };

  networking.firewall.allowedTCPPorts = [ 13337 ];
  
  environment.etc."index.html" = {
    text = indexHtml;
    mode = "0644";
  };

  environment.etc."login.html" = {
    text = login;
    mode = "0644";
  };

  environment.etc."devices.json".source =
    pkgs.writeTextFile {
      name = "devices.json";
      text = builtins.toJSON config.house.zigbee.devices;
    };

  environment.etc."rooms.json".source =
    pkgs.writeTextFile {
      name = "rooms.json";
      text = builtins.toJSON config.house.rooms;
    };
  
  environment.etc."tv.json".source =
    pkgs.writeTextFile {
      name = "tv.json";
      text = builtins.toJSON config.house.tv;
    };

  environment.etc."favicon.ico".source = ./../../modules/themes/icons/favicons/duck.ico;
    
  }
