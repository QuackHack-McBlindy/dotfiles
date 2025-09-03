# dotfiles/bin/home/duckDash.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
# 🦆 says ⮞ auto generate smart home dashboard
{
  self, 
  config, # 🦆 says ⮞ not rly a fan of web interfaces
  lib,# 🦆 says ⮞ but - 
  pkgs,
  cmdHelpers, # 🦆 feels ⮞ diz might have potential.. we'll see
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

  tvJson = pkgs.writeTextFile {
    name = "tv.json";
    text = builtins.toJSON config.house.tv;
  };  


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

  deviceEntry = device: let
    icon = device.icon or "mdi:lightbulb";
    iconName = lib.removePrefix "mdi:" icon;
  in ''
    <div class="device" data-id="${device.id}">
      <div class="device-header" onclick="toggleDeviceControls('${device.id}')">
        <div class="control-label">
          <i class="mdi mdi-${iconName}"></i> ${lib.escapeXML device.friendly_name}
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

  httpServer = pkgs.writeShellScriptBin "serve-dashboard" ''
    HOST=''${1:-0.0.0.0}
    PORT=''${2:-13337}
    ${pkgs.python3}/bin/python3 -m http.server "$PORT" --bind "$HOST" -d /etc/
  '';

  roomList = lib.concatMapStrings (room: let
    icon = lib.removePrefix "mdi:" roomIcons.${room};
  in ''
    <li class="room-item">
      <i class="mdi mdi-${icon}"></i>
      <span class="label">${lib.toUpper (lib.substring 0 1 room)}${lib.substring 1 (lib.stringLength room) room}</span>
    </li>
  '') (lib.attrNames config.house.rooms);
  
  indexHtml = ''    
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>🦆'Dash</title>
        <link rel="preconnect" href="https://cdn.jsdelivr.net">
        <link rel="dns-prefetch" href="https://cdn.jsdelivr.net">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link rel="stylesheet" href="https://raw.githack.com/QuackHack-McBlindy/dotfiles/main/modules/themes/css/duckdash2.css">        
        <link href="https://cdn.jsdelivr.net/npm/@mdi/font/css/materialdesignicons.min.css" rel="stylesheet">
        <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@600&display=swap" rel="stylesheet">
        <script src="https://unpkg.com/mqtt/dist/mqtt.min.js"></script>        
        <style>
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
            <header>
                 <div class="logo" onclick="showPage(0)" style="cursor: pointer;">
                  <i class="fas fa-home"></i>
                  <h1 class="floating-duck">🦆</h1>
                  <span class="dash-text">'Dash!</span>
                </div>
                
                <div class="search-bar">
                  <i class="fas fa-search"></i>
                  <input type="text" placeholder="🦆 quack quack, may I assist?" id="searchInput">
                </div>
    
                <button id="micButton" class="mic-btn">🎙️</button>
            </header>
    
            <select id="deviceSelect" class="device-selector">
            <option value="">🦆 says > pick a device </option>
            </select>
    
            <div class="connection-status status-connecting" id="connectionStatus">
                <i class="fas fa-plug"></i>
               <span>⚠️</span>
            </div>
    
    
            <div class="page-container" id="pageContainer"> 
                <!-- 🦆 says ⮞ PAGE 0 HOME -->
                <div class="page" id="pageHome">
                    <div class="status-cards">
                    <div class="status-cards">
                        <div class="card">
                            <div class="card-header">
                                <div class="card-title">Connected Devices</div>
                                <i class="fas fa-network-wired" style="color: #2ecc71;"></i>
                            </div>
                            <div class="card-value" id="connectedDevicesCount">0</div>
                            <div class="card-details">
                                <i class="fas fa-check-circle"></i>
                                <span id="devicesStatus">Waiting for data</span>
                            </div>
                        </div>
                        
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
                        
                        <div class="card">
                            <div class="card-header">
                                <div class="card-title">Energy</div>
                                <i class="fas fa-bolt" style="color: #f39c12;"></i>
                            </div>
                            <div class="card-value" id="energyPrice">--.- SEK/kWh</div>
                            <div class="card-value" id="energyUsage">--.- kWh (month)</div>
                            <div class="card-details">
                                <i class="fas fa-clock"></i>
                                <span>Current price & monthly usage</span>
                            </div>
                        </div>
                        
                        <div class="card">
                            <div class="card-header">
                                <div class="card-title">Security</div>
                                <i class="fas fa-shield-alt" style="color: #4a6fa5;"></i>
                            </div>
                            <div class="card-value" id="securityStatus">--</div>
                            <div class="card-details">
                                <i class="fas fa-lock"></i>
                                <span id="securityDetail">Waiting for data</span>
                            </div>
                        </div>
                    </div>
                    </div>
                </div>  
                
                <!-- 🦆 says ⮞ PAGE 1 DEVICES -->
                <div class="page" id="pageDevices">                    
                    <div class="device-controls" id="deviceControls">
                        <div class="device-header">
                            <div class="device-icon">
                                <i id="currentDeviceIcon" class="mdi"></i>
                            </div>
                            <div class="device-info">
                                <h2 id="currentDeviceName">Select a device</h2>
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
                
                <!-- 🦆 says ⮞ PAGE 2 - SCENES -->
                <div class="page" id="pageScenes">
                    <h2>Scenes</h2>
                    <div class="scene-grid" id="scenesContainer">
                      ${sceneGridHtml}
                    </div>
                </div>
                
                
                <!-- 🦆 says ⮞ PAGE 3 - TV - -->
                <div class="page" id="pageTV">
                    <div class="tv-controls">
                        <div class="tv-power">
                            <button class="tv-btn power" id="tvPower">
                                <i class="fas fa-power-off"></i>
                            </button>
                        </div>
                    
                        <div class="tv-volume">
                            <button class="tv-btn" id="volDown">
                                <i class="fas fa-volume-down"></i>
                            </button>
                            <button class="tv-btn" id="volMute">
                                <i class="fas fa-volume-mute"></i>
                            </button>
                            <button class="tv-btn" id="volUp">
                                <i class="fas fa-volume-up"></i>
                            </button>
                        </div>
                    
                        <div class="tv-navigation">
                            <button class="tv-btn" id="navUp">
                                <i class="fas fa-arrow-up"></i>
                            </button>
                            <button class="tv-btn" id="navLeft">
                                <i class="fas fa-arrow-left"></i>
                            </button>
                           <button class="tv-btn ok" id="navSelect">
                                <i class="fas fa-dot-circle"></i>
                            </button>
                            <button class="tv-btn" id="navRight">
                                <i class="fas fa-arrow-right"></i>
                            </button>
                            <button class="tv-btn" id="navDown">
                                <i class="fas fa-arrow-down"></i>
                            </button>
                        </div>
                    
                        <div class="tv-playback">
                            <button class="tv-btn" id="playbackBack">
                                <i class="fas fa-backward"></i>
                            </button>
                            <button class="tv-btn" id="playbackPlay">
                                <i class="fas fa-play"></i>
                            </button>
                            <button class="tv-btn" id="playbackForward">
                                <i class="fas fa-forward"></i>
                            </button>
                        </div>
                    
                    </div>
                </div>
            </div>
            
            <!-- 🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆
             🦆 says ⮞ TABS
             🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆 -->
            <div class="nav-tabs">
                <div class="nav-tab active" data-page="1">
                    <i class="mdi mdi-cellphone"></i>
                    <span>Devices</span>
                </div>
                <div class="nav-tab" data-page="2">
                    <i class="mdi mdi-lightbulb"></i>
                    <span>Scenes</span>
                </div>
                <div class="nav-tab" data-page="3">
                    <i class="mdi mdi-television"></i>
                    <span>TV</span>
                </div>
            </div>
        </div>
    
        <div class="notification hidden" id="notification"></div>
    
        <script>      
            document.addEventListener('DOMContentLoaded', function() {
                // 🦆 says ⮞ mqtt
                let client = null;
                const brokerUrl = 'ws://${mqttHostip}:9001';
                const statusElement = document.getElementById('connectionStatus');
                const notification = document.getElementById('notification');
                
                // 🦆 says ⮞ device state
                let devices = {};
                let selectedDevice = null;
                let sceneData = ${sceneData};
                let deviceIcons = ${iconData};  
                console.log('All device icons:', deviceIcons);
                console.log('Device friendly names:', Object.keys(deviceIcons));
  
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
                                devices = state.devices;
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
                        showNotification('State saved to localStorage', 'success');
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
          
                
                /*🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆
                 🦆 says ⮞ ZIGDUCK CONNECT 
                 🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆*/
                function connectToMQTT() {
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
                        username: 'mqtt',
                        password: password,
                        clientId: 'web-dashboard-' + Math.random().toString(16).substring(2, 10)
                    };
                    
                    try {
                        client = mqtt.connect(brokerUrl, options);
                        
                        client.on('connect', function() {
                            statusElement.className = 'connection-status status-connected';
                            statusElement.innerHTML = '<i class="fas fa-plug"></i><span>🟢</span>';
                            
                            client.subscribe('zigbee2mqtt/#', function(err) {
                                if (!err) {
                                    showNotification('Subscribed to all devices', 'success');
                                }
                            });
                            client.subscribe('zigbee2mqtt/tibber/#', function(err) {
                                if (!err) {
                                    showNotification('Subscribed to energy data', 'success');
                                }
                            });
                        });
                        
                        client.on('error', function(err) {
                            statusElement.className = 'connection-status status-error';
                            statusElement.innerHTML = '<i class="fas fa-exclamation-triangle"></i><span>⚠️📛</span>';
                            console.error('Connection error: ', err);
                            showNotification('MQTT connection error', 'error');
                        });
                        
                        client.on('message', function(topic, message) {
                            const topicParts = topic.split('/');
                            const deviceName = topicParts[1];

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
    

                            if (topicParts.length === 2) {
                                try {
                                    const data = JSON.parse(message.toString());
                                    devices[deviceName] = data;
                                    
                                    //🦆 says ⮞ auto-save when data arrives
                                    saveState();
                                    
                                    updateDeviceSelector();
                                    
                                    if (selectedDevice === deviceName) {
                                        updateDeviceUI(data);
                                    }
                                    
                                    updateStatusCards();
                                } catch (e) {
                                    console.error('Error parsing message: ', e);
                                }
                            }
                        });
                        
                        client.on('close', function() {
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
                    
                    // 🦆 says ⮞ clear
                    while (selector.options.length > 1) {
                        selector.remove(1);
                    }
                    
                    Object.keys(devices).forEach(device => {
                        if (device !== 'bridge') {
                            const option = document.createElement('option');
                            option.value = device;
                            option.textContent = device;
                            selector.appendChild(option);
                        }
                    });
                    
                    // 🦆 says ⮞ restore?
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
                    const deviceCount = Object.keys(devices).length - 1; // Subtract bridge
                    document.getElementById('connectedDevicesCount').textContent = deviceCount;
                    document.getElementById('devicesStatus').textContent = deviceCount > 0 ? 'Devices online' : 'No devices';
                    
                    //  🦆 says ⮞ find temp
                    let temperature = '--.-';
                    let tempLocation = 'No sensor';
                    
                    for (const [device, data] of Object.entries(devices)) {
                        if (data.temperature !== undefined) {
                            temperature = data.temperature;
                            tempLocation = device;
                            break;
                        }
                    }
                    
                    document.getElementById('temperatureValue').textContent = `''${temperature}°C`;
                    document.getElementById('temperatureLocation').textContent = tempLocation;
                    
                    document.getElementById('securityStatus').textContent = 'Active';
                    document.getElementById('securityDetail').textContent = 'All secured';
                }
      
                function updateDeviceIcon(deviceName) {
                    console.log('updateDeviceIcon called for:', deviceName);
                    const icon = deviceIcons[deviceName] || "mdi:lightbulb";
                    console.log('Raw icon value:', icon);
    
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
                
                function showPage(pageIndex) {
                    currentPage = pageIndex;
                    pageContainer.style.transform = `translateX(-''${pageIndex * 25}%)`;
    
                    navTabs.forEach((tab) => {
                        const tabPageIndex = parseInt(tab.getAttribute('data-page'));
                        if (tabPageIndex === pageIndex) {
                            tab.classList.add('active');
                        } else {
                            tab.classList.remove('active');
                        }
                    });
    
                    saveState();
                }

                function updateLinkquality(percent) {
                  const bars = document.querySelectorAll(".lq-bar");
                  const activeBars = Math.round((percent / 100) * bars.length);
                  bars.forEach((bar, idx) => {
                    bar.className = "lq-bar"; // reset
                    if (idx < activeBars) {
                      if (percent > 75) bar.classList.add("good");
                      else if (percent > 50) bar.classList.add("ok");
                      else if (percent > 25) bar.classList.add("bad");
                      else bar.classList.add("terrible");
                    } else {
                      bar.classList.add("off");
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
                   
                    <p>RAW</p>
                   
                    // 🦆 says ⮞ OTHER FIELDS
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
                
                function initDashboard() {
                    loadSavedState();
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
                            if (diff > 0 && currentPage < 3) {  // Changed from 2 to 3 for 4 pages
                                // 🦆 says ⮞ swipe left
                                showPage(currentPage + 1);
                            } else if (diff < 0 && currentPage > 0) {
                                // 🦆 says ⮞ swipe right
                                showPage(currentPage - 1);
                            }
                        }
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

                    
                    document.querySelectorAll('.scene-item').forEach(item => {
                        item.addEventListener('click', function() {
                            const scene = this.getAttribute('data-scene');
                            activateScene(scene);
                        });
                    });
                    
                    document.getElementById('tvPower').addEventListener('click', function() {
                        sendTVCommand('power');
                    });
                    
                    document.getElementById('volDown').addEventListener('click', function() {
                        sendTVCommand('volume_down');
                    });
                    
                    document.getElementById('volMute').addEventListener('click', function() {
                        sendTVCommand('mute');
                    });
                    
                    document.getElementById('volUp').addEventListener('click', function() {
                        sendTVCommand('volume_up');
                    });
                    
                    document.getElementById('navUp').addEventListener('click', function() {
                        sendTVCommand('up');
                    });
                    
                    document.getElementById('navLeft').addEventListener('click', function() {
                        sendTVCommand('left');
                    });
                    
                    document.getElementById('navSelect').addEventListener('click', function() {
                        sendTVCommand('select');
                    });
                    
                    document.getElementById('navRight').addEventListener('click', function() {
                        sendTVCommand('right');
                    });
                    
                    document.getElementById('navDown').addEventListener('click', function() {
                        sendTVCommand('down');
                    });
                    
                    document.getElementById('playbackBack').addEventListener('click', function() {
                        sendTVCommand('back');
                    });
                    
                    document.getElementById('playbackPlay').addEventListener('click', function() {
                        sendTVCommand('play_pause');
                    });
                    
                    document.getElementById('playbackForward').addEventListener('click', function() {
                        sendTVCommand('forward');
                    });
                    
                    document.querySelectorAll('.channel-btn').forEach(btn => {
                        btn.addEventListener('click', function() {
                            const channel = this.getAttribute('data-channel');
                            sendTVCommand('channel', channel);
                        });
                    });    
                    window.addEventListener('beforeunload', saveState);         
                    connectToMQTT();
                }
                
                function activateScene(sceneName) {
                    const scene = sceneData[sceneName];
                    if (!scene) {
                        showNotification(`Scene "''${sceneName}" not found`, 'error');
                        return;
                    }
    
                    showNotification(`Activating "''${sceneName}" scene`, 'success');
    
                    Object.entries(scene).forEach(([device, settings]) => {
                        let command = {...settings};
                        if (command.color && command.color.hex) {
                            const hex = command.color.hex.replace('#', "");
                            command.color = {
                                r: parseInt(hex.substr(0, 2), 16),
                                g: parseInt(hex.substr(2, 2), 16),
                                b: parseInt(hex.substr(4, 2), 16)
                            };
                        }
        
                        sendCommand(device, command);
                    });
                }
                
                function sendTVCommand(command, value) {
                    showNotification(`Sending TV command: ''${command}`, 'success');
                    console.log(`TV command: ''${command}`, value ? `Value: ''${value}` : "");
                    const topic = 'tv/control';
                    const message = value ? { command, value } : { command };        
                    if (client && client.connected) {
                        client.publish(topic, JSON.stringify(message));
                    }
                }
                
                initDashboard();
            });
        </script>
    </body>
    </html>       
  '';

in {
  yo.scripts = { 
    duckDash = {
      description = "Mobile-first dashboard, unified frontend for zigbee devices, tv remotes and other smart home tech stuff.";
      aliases = [ "dash" ];
      category = "🛖 Home Automation";  
      autoStart = config.this.host.hostname == "homie";
      parameters = [   
        { name = "host"; description = "IP address of the host (127.0.0.1 / 0.0.0.0"; default = "0.0.0.0"; }      
        { name = "port"; description = "Port to run the frontend service on"; default = "13337"; }
      ];
      code = ''
        ${cmdHelpers}
        HOST=$host
        PORT=$port
        dt_info "Starting 🦆'Dash server on http://${mqttHostip}:$PORT"
        ${httpServer}/bin/serve-dashboard "$HOST" "$PORT" 
      '';
    };  
  };

  networking.firewall.allowedTCPPorts = [ 13337 ];
  
  environment.etc."index.html" = {
    text = indexHtml;
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
  }
