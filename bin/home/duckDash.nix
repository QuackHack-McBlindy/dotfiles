# dotfiles/bin/home/duckDash.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ auto generate smart home dashboard wip 
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

  # 🦆 says ⮞ get house.zigbee.scenes
  zigbeeScenes = config.house.zigbee.scenes;

  # 🦆 says ⮞ generate scene data
  sceneData = builtins.toJSON (lib.mapAttrsToList (name: scene: {
    inherit name;
    devices = lib.mapAttrsToList (deviceName: state: {
      id = deviceName;
      state = state;
    }) scene;
  }) zigbeeScenes);



  # 🦆 says ⮞ get house.zigbee.scenes
 

  cssData = lib.readFile ./../../modules/themes/css/duckdash.css;

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
          <span></span> ${lib.escapeXML device.friendly_name}
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
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link href="https://cdn.jsdelivr.net/npm/@mdi/font/css/materialdesignicons.min.css" rel="stylesheet">
        <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@600&display=swap" rel="stylesheet">
        <script src="https://unpkg.com/mqtt/dist/mqtt.min.js"></script>
        <style>
            :root {
                --primary: #4a6fa5;
                --secondary: #6b8cbb;
                --accent: #ff7846;
                --light: #f5f7fa;
                --dark: #2c3e50;
                --success: #2ecc71;
                --warning: #f39c12;
                --danger: #e74c3c;
                --gray: #95a5a6;
                --card-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
                --transition: all 0.3s ease;
            }
    
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            }
    
            body {
                background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
                color: var(--dark);
                min-height: 100vh;
                padding: 15px;
                overflow-x: hidden;
            }
    
            .container {
                max-width: 100%;
                margin: 0 auto;
                background: white;
                border-radius: 15px;
                box-shadow: var(--card-shadow);
                overflow: hidden;
                position: relative;
                min-height: 80vh;
            }
    
            header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 15px;
                background: white;
                border-bottom: 1px solid rgba(0, 0, 0, 0.1);
            }
    
            .logo {
                display: flex;
                align-items: center;
                gap: 10px;
            }
    
            .logo i {
                font-size: 2rem;
                color: var(--primary);
            }
    
            .logo h1 {
                font-weight: 600;
                font-size: 1.5rem;
            }
    
            .search-bar {
                display: flex;
                align-items: center;
                background: var(--light);
                border-radius: 30px;
                padding: 8px 15px;
                width: 100%;
                max-width: 300px;
            }
    
            .search-bar input {
                border: none;
                outline: none;
                width: 100%;
                font-size: 1rem;
                background: transparent;
            }
    
            .page-container {
                display: flex;
                width: 300%;
                transition: transform 0.3s ease;
            }
    
            .page {
                width: 33.333%;
                padding: 20px;
                min-height: 65vh;
            }
    
            .status-cards {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
                gap: 15px;
                margin-bottom: 20px;
            }
    
            .card {
                background: white;
                border-radius: 12px;
                padding: 15px;
                box-shadow: var(--card-shadow);
                display: flex;
                flex-direction: column;
                gap: 8px;
            }
    
            .card-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
            }
    
            .card-title {
                font-size: 0.9rem;
                font-weight: 500;
                color: var(--secondary);
            }
    
            .card-value {
                font-size: 1.5rem;
                font-weight: 600;
                color: var(--primary);
            }
    
            .card-details {
                display: flex;
                align-items: center;
                gap: 8px;
                color: var(--gray);
                font-size: 0.8rem;
            }
    
            .device-controls {
                background: white;
                border-radius: 15px;
                padding: 20px;
                box-shadow: var(--card-shadow);
                margin-top: 20px;
            }
    
            .device-header {
                display: flex;
                align-items: center;
                gap: 12px;
                margin-bottom: 20px;
            }
    
            .device-icon {
                width: 50px;
                height: 50px;
                background: var(--light);
                border-radius: 12px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 1.5rem;
                color: var(--primary);
            }
    
            .device-info h2 {
                font-weight: 600;
                margin-bottom: 5px;
                font-size: 1.2rem;
            }
    
            .device-info p {
                color: var(--gray);
                font-size: 0.9rem;
            }
    
            .switch-control {
                display: flex;
                align-items: center;
                justify-content: space-between;
                margin-bottom: 15px;
            }
    
            .toggle-switch {
                position: relative;
                display: inline-block;
                width: 50px;
                height: 26px;
            }
    
            .toggle-switch input {
                opacity: 0;
                width: 0;
                height: 0;
            }
    
            .toggle-slider {
                position: absolute;
                cursor: pointer;
                top: 0;
                left: 0;
                right: 0;
                bottom: 0;
                background-color: #ccc;
                transition: .4s;
                border-radius: 34px;
            }
    
            .toggle-slider:before {
                position: absolute;
                content: "";
                height: 18px;
                width: 18px;
                left: 4px;
                bottom: 4px;
                background-color: white;
                transition: .4s;
                border-radius: 50%;
            }
    
            input:checked + .toggle-slider {
                background-color: var(--success);
            }
    
            input:checked + .toggle-slider:before {
                transform: translateX(24px);
            }
    
            .slider-control {
                margin-bottom: 15px;
            }
    
            .slider-label {
                display: flex;
                justify-content: space-between;
                margin-bottom: 8px;
                font-size: 0.9rem;
            }
    
            .slider {
                -webkit-appearance: none;
                width: 100%;
                height: 6px;
                border-radius: 5px;
                background: var(--light);
                outline: none;
            }
    
    
            .scene-grid {
                display: grid;
                grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
                gap: 15px;
                margin-top: 20px;
            }
    
            .scene-item {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
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
            }
    
            .scene-item:hover {
                transform: translateY(-3px);
                box-shadow: 0 8px 16px rgba(0, 0, 0, 0.15);
            }
    
            .scene-item i {
                font-size: 1.5rem;
                margin-bottom: 5px;
            }
    
            .scene-item span {
                font-weight: 500;
                font-size: 0.9rem;
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
    
            .nav-tabs {
                display: flex;
                justify-content: space-around;
                background: white;
                padding: 15px;
                border-top: 1px solid rgba(0, 0, 0, 0.1);
                position: sticky;
                bottom: 0;
                width: 100%;
            }
    
            .nav-tab {
                display: flex;
                flex-direction: column;
                align-items: center;
                gap: 5px;
                cursor: pointer;
                opacity: 0.6;
                transition: var(--transition);
            }
    
            .nav-tab.active {
                opacity: 1;
                color: var(--primary);
            }
    
            .nav-tab i {
                font-size: 1.5rem;
            }
    
            .nav-tab span {
                font-size: 0.8rem;
            }
    
            .connection-status {
                padding: 10px 15px;
                border-radius: 8px;
                margin-bottom: 15px;
                display: flex;
                align-items: center;
                gap: 10px;
            }
    
            .status-connecting {
                background-color: #fff3cd;
                color: #856404;
            }
    
            .status-connected {
                background-color: #d4edda;
                color: #155724;
            }
    
            .status-error {
                background-color: #f8d7da;
                color: #721c24;
            }
    
            .device-selector {
                width: 100%;
                padding: 12px;
                border-radius: 8px;
                border: 1px solid var(--secondary);
                margin-bottom: 20px;
                font-size: 1rem;
            }
    
            .hidden {
                display: none;
            }
    
            .notification {
                position: fixed;
                top: 20px;
                right: 20px;
                padding: 15px 20px;
                border-radius: 8px;
                color: white;
                z-index: 1000;
                opacity: 0;
                transform: translateX(100px);
                transition: opacity 0.3s, transform 0.3s;
            }
    
            .notification.show {
                opacity: 1;
                transform: translateX(0);
            }
    
            .notification.success {
                background-color: var(--success);
            }
    
            .notification.error {
                background-color: var(--danger);
            }
    
            .floating-duck {
              display: inline-block;
              animation: float 3s ease-in-out infinite;
              display: inline-block;
              animation: float 3s ease-in-out infinite;
              transition: all 0.25s ease-in-out;
            }
    
            .floating-duck:hover {
              text-shadow: 
                0 0 6px #00ff00,
                0 0 12px #00ff00,
                0 0 24px #00ff00,
                0 0 48px #00ff00;
              transform: scale(1.15);
            }
    
            @keyframes float {
              0% { transform: translateY(0px); }
              50% { transform: translateY(-8px); }
              100% { transform: translateY(0px); }
            }
            .notify-btn {
              background: none;
              border: none;
              cursor: pointer;
              font-size: 1.2rem;
              margin-left: 5px;
            }
            .notify-btn:hover {
              transform: scale(1.2);
            }
    
            .mic-btn {
              background: none;
              border: none;
              cursor: pointer;
              font-size: 1.2rem;
              margin-left: 5px;
            }
            .mic-btn:hover {
              transform: scale(1.2);
            }
    
            @media (max-width: 768px) {
                .search-bar {
                    max-width: 200px;
                }
                
                .logo h1 {
                    font-size: 1.2rem;
                }
                
                .status-cards {
                    grid-template-columns: 1fr 1fr;
                }
            }
    
            @media (max-width: 480px) {
                .status-cards {
                    grid-template-columns: 1fr;
                }
                
                .scene-grid {
                    grid-template-columns: 1fr;
                }
                .logo h1 {
                    display: inline-block;
                    animation: floatDuck 6s infinite linear;
                    position: relative;
               }
    
               @keyframes floatDuck {
                 0%   { transform: translate(0, 0); }
                 25%  { transform: translate(50px, -30px); }
                 50%  { transform: translate(100px, 0); }
                 75%  { transform: translate(50px, 30px); }
                 100% { transform: translate(0, 0); }
               }
                
                .logo h1 {
                    font-size: 1rem;
                }
                
                .search-bar {
                    max-width: 150px;
                }
            }
    
             .status-connected span {
               display: inline-block;
               animation: greenGlow 1.5s ease-in-out infinite;
             }
    
             @keyframes greenGlow {
               0%   { text-shadow: 0 0 4px #00ff00, 0 0 8px #00ff00; }
               50%  { text-shadow: 0 0 12px #00ff00, 0 0 24px #00ff00; }
               100% { text-shadow: 0 0 4px #00ff00, 0 0 8px #00ff00; }
             }
      
            .device-selector {
              appearance: none;
              -webkit-appearance: none;
              -moz-appearance: none;
    
              width: 100%;
              max-width: 280px;
              padding: 12px 44px 12px 14px;
              font-size: 1rem;
              font-family: inherit;
              border: 2px solid #38bdf8;
              border-radius: 14px;
              background: #f0f9ff;
              color: #0c4a6e;
            
    
              box-shadow: 0 3px 8px rgba(0,0,0,0.08);
              transition: all 0.2s ease-in-out;
            }
    
          .dash-text {
              font-family: 'Poppins', sans-serif;
              font-size: 2rem;
              font-weight: 600;
              margin-left: 6px;
              background: linear-gradient(90deg, #38bdf8, #0ea5e9);
              -webkit-background-clip: text;
              -webkit-text-fill-color: transparent;
            }
    
            .device-selector:hover {
              border-color: #0ea5e9;
              box-shadow: 0 4px 10px rgba(14,165,233,0.25);
            }
            .device-selector:focus {
              outline: none;
              border-color: #0284c7;
              box-shadow: 0 0 0 3px rgba(2,132,199,0.3);
            }
    
            .device-selector {
              background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='20' height='20'%3E%3Cpath fill='%230c4a6e' d='M5 7l5 6 5-6'/%3E%3C/svg%3E");
              background-repeat: no-repeat;
              background-position: right 14px center;
              background-size: 20px 20px;
            }
    
            @media (max-width: 600px) {
              .device-selector {
                font-size: 1.1rem;
                padding: 14px 46px 14px 16px;
              }
            }
    
            .storage-controls {
                display: flex;
                justify-content: center;
                gap: 10px;
                margin: 15px 0;
            }
    
            .storage-btn {
                padding: 8px 15px;
                background: var(--primary);
                color: white;
                border: none;
                border-radius: 8px;
                cursor: pointer;
                transition: var(--transition);
            }
    
            .storage-btn:hover {
                background: var(--secondary);
            }
    
            /* Styles for renderMessage */
            .device-panel {
                margin-top: 15px;
            }
            
            .panel-title {
                font-size: 1.2rem;
                font-weight: 600;
                margin-bottom: 15px;
                color: var(--primary);
            }
            
            .row {
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 10px 0;
                border-bottom: 1px solid #eee;
            }
            
            .key {
                font-weight: 500;
                color: var(--dark);
            }
            
            .val-string, .val-number, .val-boolean {
                font-family: monospace;
            }
            
            .val-number {
                color: var(--primary);
            }
            
            .val-boolean {
                color: var(--success);
            }
            
            .slider-row {
                display: flex;
                align-items: center;
                gap: 10px;
                width: 100%;
            }
            
            .slider-row input[type="range"] {
                flex: 1;
            }
            
            .badge {
                background: var(--light);
                padding: 4px 8px;
                border-radius: 10px;
                font-size: 0.8rem;
                min-width: 30px;
                text-align: center;
            }
            
            .section {
                font-weight: 600;
                margin-top: 15px;
                margin-bottom: 10px;
                color: var(--secondary);
            }
            
            .switch {
                position: relative;
                display: inline-block;
                width: 50px;
                height: 26px;
            }
            
            .switch input {
                opacity: 0;
                width: 0;
                height: 0;
            }
            
            .slider-round {
                position: absolute;
                cursor: pointer;
                top: 0;
                left: 0;
                right: 0;
                bottom: 0;
                background-color: #ccc;
                transition: .4s;
                border-radius: 34px;
            }
            
            .slider-round:before {
                position: absolute;
                content: "";
                height: 18px;
                width: 18px;
                left: 4px;
                bottom: 4px;
                background-color: white;
                transition: .4s;
                border-radius: 50%;
            }
            
            input:checked + .slider-round {
                background-color: var(--success);
            }
            
            input:checked + .slider-round:before {
                transform: translateX(24px);
            }
            
            .time {
                font-size: 0.8rem;
                color: var(--gray);
                margin-bottom: 5px;
            }
            
            .msg {
                font-family: monospace;
                font-size: 0.8rem;
                color: var(--secondary);
                margin-bottom: 15px;
                word-break: break-all;
            }
            
            .json {
                max-height: 400px;
                overflow-y: auto;
            }
            
            .preview {
                width: 50px;
                height: 50px;
                border-radius: 8px;
                border: 1px solid #eee;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <header>
                <div class="logo">
                  <i class="fas fa-home"></i>
                  <h1 class="floating-duck">🦆</h1>
                  <span class="dash-text">'Dash!</span>
                </div>
                
                <button id="notifyButton" class="notify-btn">⚠️</button>
                <button id="shopButton" class="mic-btn">🛒</button>
                <button id="calButton" class="mic-btn">📅</button>
    
                
                <div class="search-bar">
                  <i class="fas fa-search"></i>
                  <input type="text" placeholder="🦆 quack quack, may I assist?" id="searchInput">
                </div>
    
                <button id="micButton" class="mic-btn">🎙️</button>
            </header>
    
            <select id="deviceSelect" class="device-selector">
            <option value="">device</option>
            </select>
    
            <div class="connection-status status-connecting" id="connectionStatus">
                <i class="fas fa-plug"></i>
                <span>...</span>
            </div>
    
    
            <div class="page-container" id="pageContainer">
                <!-- 🦆 says ⮞ PAGE 1 DEVICES -->
                <div class="page" id="pageDevices">
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
                                <div class="card-title">Energy Usage</div>
                                <i class="fas fa-bolt" style="color: #f39c12;"></i>
                            </div>
                            <div class="card-value" id="energyUsage">🦆 W</div>
                            <div class="card-details">
                                <i class="fas fa-clock"></i>
                                <span>Current usage</span>
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
                    
                    <div class="device-controls" id="deviceControls">
                        <div class="device-header">
                            <div class="device-icon">
                                <i class="fas fa-lightbulb"></i>
                            </div>
                            <div class="device-info">
                                <h2 id="currentDeviceName">quack or tap a device</h2>
                                <p id="currentDeviceStatus">up there yo</p>
                            </div>
                        </div>
                        
                        <div id="devicePanel" class="device-panel">

                        </div>
                    </div>
                </div>
                
                <!-- 🦆 says ⮞ PAGE 2 - SCENES -->
                <div class="page" id="pageScenes">
                    <h2>Scenes</h2>
                    <p>Tap to generate Nix code</p>
                    
                    <div class="scene-grid" id="scenesContainer">
                        <div class="scene-item" data-scene="morning">
                            <i class="fas fa-sun"></i>
                            <span>Morning</span>
                        </div>
                        
                        <div class="scene-item" data-scene="evening">
                            <i class="fas fa-moon"></i>
                            <span>Evening</span>
                        </div>
                        
                        <div class="scene-item" data-scene="movie">
                            <i class="fas fa-film"></i>
                            <span>Movie Night</span>
                        </div>
                        
                        <div class="scene-item" data-scene="dining">
                            <i class="fas fa-utensils"></i>
                            <span>Dining</span>
                        </div>
                        
                        <div class="scene-item" data-scene="sleep">
                            <i class="fas fa-bed"></i>
                            <span>Sleep</span>
                        </div>
                        
                        <div class="scene-item" data-scene="away">
                            <i class="fas fa-door-open"></i>
                            <span>Away</span>
                        </div>
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
                        
                        <div class="tv-navigation">
                            <button class="tv-btn channel-btn" data-channel="1">1</button>
                            <button class="tv-btn channel-btn" data-channel="2">2</button>
                            <button class="tv-btn channel-btn" data-channel="3">3</button>
                            <button class="tv-btn channel-btn" data-channel="4">4</button>
                            <button class="tv-btn channel-btn" data-channel="5">5</button>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="nav-tabs">
                <div class="nav-tab active" data-page="0">
                    <i class="mdi mdi-cellphone"></i>
                    <span>Devices</span>
                </div>
                <div class="nav-tab" data-page="1">
                    <i class="mdi mdi-lightbulb"></i>
                    <span>Scenes</span>
                </div>
                <div class="nav-tab" data-page="2">
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
                const brokerUrl = 'ws://192.168.1.211:9001';
                const statusElement = document.getElementById('connectionStatus');
                const notification = document.getElementById('notification');
                
                // 🦆 says ⮞ device state
                let devices = {};
                let selectedDevice = null;
                
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
                
                function setRangeGradient(slider, startColor, endColor) {
                    // 🦆 says ⮞ todo?
                    
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
                
                function publishPatch(payload) {
                    if (!selectedDevice) {
                        showNotification('Please select a device first', 'error');
                        return;
                    }
                    
                    sendCommand(selectedDevice, payload);
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
                
                // 🦆 says ⮞ connect da duck
                function connectToMQTT() {
                    statusElement.className = 'connection-status status-connecting';
                    statusElement.innerHTML = '<i class="fas fa-plug"></i><span>⚠️📛</span>';
                   
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
                    document.getElementById('currentDeviceName').textContent = selectedDevice;
                    
                    const statusText = data.state === 'ON' ? 'On • Connected' : 'Off • Connected';
                    document.getElementById('currentDeviceStatus').textContent = statusText;
                    
                    const topic = `zigbee2mqtt/''${selectedDevice}`;
                    renderMessage(data, topic);
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
                    pageContainer.style.transform = `translateX(-''${pageIndex * 33.333}%)`;
                    
                    navTabs.forEach((tab, index) => {
                        if (index === pageIndex) {
                            tab.classList.add('active');
                        } else {
                            tab.classList.remove('active');
                        }
                    });
                    
                    saveState();
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
                        controlsHtml += `
                            <div class="row">
                                <div class="key">Power</div>
                                <div>
                                    <label class="switch">
                                        <input type="checkbox" id="stateToggle" ''${checked}>
                                        <span class="slider-round"></span>
                                    </label>
                                </div>
                            </div>`;
                    }
                    
                    // 🦆 says ⮞ BRIGHTNESS
                    if ('brightness' in parsed) {
                        const v = clamp(Number(parsed.brightness) || 0, 0, 255);
                        controlsHtml += `
                            <div class="row">
                                <div class="key">Brightness</div>
                                <div class="slider-row">
                                    <input type="range" min="0" max="255" value="''${v}" id="brightnessSlider">
                                    <span class="badge" id="brightnessBadge">''${v}</span>
                                </div>
                            </div>`;
                    }
                    
                    // 🦆 says ⮞ COLOR PICKER
                    if ('color' in parsed) {
                        const col = normalizeColor(parsed.color);
                        controlsHtml += `
                            <div class="section">Color</div>
                            <div class="row">
                                <div class="key">Color Picker</div>
                                <div style="display:grid; gap:8px;">
                                    <input type="color" id="colorPicker" value="''${col.hex}" style="width:120px; height:36px; padding:0; border: 1px solid #ddd; border-radius:8px;">
                                    <div class="preview" id="colorPreview" style="background:''${col.hex};"></div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="key">RGBW Sliders</div>
                                <div style="display:grid; gap:8px;">
                                    <div class="slider-row">
                                        <span>R</span>
                                        <input type="range" min="0" max="255" value="''${col.r}" id="rSlider">
                                        <span class="badge" id="rBadge">''${col.r}</span>
                                    </div>
                                    <div class="slider-row">
                                        <span>G</span>
                                        <input type="range" min="0" max="255" value="''${col.g}" id="gSlider">
                                        <span class="badge" id="gBadge">''${col.g}</span>
                                    </div>
                                    <div class="slider-row">
                                        <span>B</span>
                                        <input type="range" min="0" max="255" value="''${col.b}" id="bSlider">
                                        <span class="badge" id="bBadge">''${col.b}</span>
                                    </div>
                                    <div class="slider-row">
                                        <span>W</span>
                                        <input type="range" min="0" max="255" value="''${col.w}" id="wSlider">
                                        <span class="badge" id="wBadge">''${col.w}</span>
                                    </div>
                                </div>
                            </div>`;
                    }
                    
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
                            publishPatch({ state: toggle.checked ? 'ON' : 'OFF' });
                        };
                    }
                    
                    const bright = document.getElementById('brightnessSlider');
                    const brightBadge = document.getElementById('brightnessBadge');
                    if (bright && brightBadge) {
                        setRangeGradient(bright, '#000', '#ffd166');
                        bright.oninput = () => {
                            const v = clamp(parseInt(bright.value), 0, 255);
                            brightBadge.textContent = v;
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
                    navTabs.forEach((tab, index) => {
                        tab.addEventListener('click', () => {
                            showPage(index);
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
                            if (diff > 0 && currentPage < 2) {
                                // 🦆 says ⮞ swipe left
                                showPage(currentPage + 1);
                            } else if (diff < 0 && currentPage > 0) {
                                // 🦆 says ⮞ swipe right
                                showPage(currentPage - 1);
                            }
                        }
                    });
                    
                    document.getElementById('deviceSelect').addEventListener('change', function() {
                        selectedDevice = this.value;
                        if (selectedDevice && devices[selectedDevice]) {
                            updateDeviceUI(devices[selectedDevice]);
                        } else {
                            document.getElementById('currentDeviceName').textContent = 'Select a device';
                            document.getElementById('currentDeviceStatus').textContent = 'Choose a device from the dropdown';
                            document.getElementById('devicePanel').innerHTML = "";
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
                
                function activateScene(scene) {
                    showNotification(`Activating ''${scene} scene`, 'success');
                    console.log(`Activating scene: ''${scene}`);
                    
                    switch(scene) {
                        case 'morning':
                            if (selectedDevice) {
                                sendCommand(selectedDevice, { state: 'ON', brightness: 100, color_temp: 100 });
                            }
                            break;
                        case 'evening':
                            if (selectedDevice) {
                                sendCommand(selectedDevice, { state: 'ON', brightness: 50, color_temp: 50 });
                            }
                            break;
                        case 'movie':
                            if (selectedDevice) {
                                sendCommand(selectedDevice, { state: 'ON', brightness: 10, color_temp: 30 });
                            }
                            break;
                        case 'sleep':
                            if (selectedDevice) {
                                sendCommand(selectedDevice, { state: 'OFF' });
                            }
                            break;
                    }
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



  networking.firewall.allowedTCPPorts = [ 13337 ];
  
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
  };}

