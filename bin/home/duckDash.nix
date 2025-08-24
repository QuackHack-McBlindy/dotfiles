# dotfiles/bin/home/duckDash.nix
{ # 🦆 says ⮞ This file automatically generates and serves an advanced web interface -
  self, # 🦆 says ⮞ for all declared zugbee and other smart home gadgets for full control through the browser
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

  # 🦆 says ⮞ get house.zigbee.devices
  zigbeeDevices = config.house.zigbee.devices;
  # 🦆 says ⮞ get house.tv devices
  tvDevices = config.house.tv;
  # 🦆 says ⮞ get house.rooms
  roomIcons = lib.mapAttrs' (name: room: {
    name = name;
    value = room.icon;
  }) config.house.rooms;
  
  # 🦆 says ⮞ show ALL devices
  devicesWithId = lib.mapAttrsToList (id: value: { inherit id; } // value) zigbeeDevices;
  # 🦆 says ⮞ add TV devices
  tvDevicesWithId = lib.mapAttrsToList (id: value: { 
    inherit id; 
    type = "tv";
    friendly_name = id; # Use the ID as friendly name for TVs
    room = value.room;
    status = "online";
    signalStrength = "Excellent";
    lastSeen = "Just now";
  }) tvDevices;
  
  devicesByRoom = lib.groupBy (device: device.room) devicesWithId;
  sortedRooms = lib.sort (a: b: a < b) (lib.attrNames devicesByRoom);
  
  # 🦆 says ⮞ generate device data
  deviceData = builtins.toJSON (
    (lib.mapAttrsToList (id: device: {
      inherit id;
      name = device.friendly_name;
      type = device.type;
      room = device.room;
      status = "online";
      manufacturer = "Zigbee";
      model = "Unknown";
      zigbeeVersion = "3.0";
      signalStrength = "Excellent";
      lastSeen = "Just now";
      powerSource = "Mains";
      supports_color = device.supports_color or false;
    }) zigbeeDevices)
    ++
    (map (device: {
      id = device.id;
      name = device.friendly_name;
      type = device.type;
      room = device.room;
      status = device.status;
      manufacturer = "Android TV";
      model = "Smart TV";
      zigbeeVersion = "N/A";
      signalStrength = device.signalStrength;
      lastSeen = device.lastSeen;
      powerSource = "Mains";
      supports_color = false;
    }) tvDevicesWithId)
  );
  
  roomData = builtins.toJSON (lib.mapAttrs' (name: room: {
    name = name;
    value = {
      name = name;
      icon = room.icon or "💡";
      deviceIds = lib.filter (device: device.room == name) devicesWithId;
    };
  }) config.house.rooms);

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

  # 🦆 says ⮞ TV control functions
  tvControlScript = pkgs.writeShellScriptBin "tv-control" ''
    TV_NAME=$1
    COMMAND=$2
    VALUE=$3   
    TV_IP="''${config.house.tv.''${TV_NAME}.ip}"  
    case $COMMAND in
      "power")
        ${pkgs.android-tools}/bin/adb connect $TV_IP:5555
        ${pkgs.android-tools}/bin/adb -s $TV_IP:5555 shell input keyevent 26
        ;;
      "volume")
        ${pkgs.android-tools}/bin/adb connect $TV_IP:5555
        ${pkgs.android-tools}/bin/adb -s $TV_IP:5555 shell media volume --stream 3 --set $VALUE
        ;;
      "input")
        ${pkgs.android-tools}/bin/adb connect $TV_IP:5555
        ${pkgs.android-tools}/bin/adb -s $TV_IP:5555 shell am start -a android.intent.action.VIEW -d "content://android.media.tv.channel/-1"
        ;;
      "app")
        ${pkgs.android-tools}/bin/adb connect $TV_IP:5555
        ${pkgs.android-tools}/bin/adb -s $TV_IP:5555 shell monkey -p $VALUE -c android.intent.category.LAUNCHER 1
        ;;
      *)
        echo "Unknown TV command: $COMMAND"
        ;;
    esac
  '';

  httpServer = pkgs.writeShellScriptBin "serve-dashboard" ''
    HOST=''${1:-0.0.0.0}
    PORT=''${2:-13337}
    ${pkgs.python3}/bin/python3 -m http.server "$PORT" --bind "$HOST" -d /etc/
  '';

  webFrontend = ''
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>🦆'Dash</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
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
            }

            .container {
                max-width: 1400px;
                margin: 0 auto;
            }

            header {
                display: flex;
                flex-direction: column;
                gap: 15px;
                margin-bottom: 20px;
                padding-bottom: 15px;
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

            .tv-app-grid {
                display: grid;
                grid-template-columns: repeat(3, 1fr);
                gap: 10px;
                margin-top: 15px;
            }
            
            .tv-app-btn {
                padding: 10px;
                border-radius: 8px;
                background: var(--light);
                border: 1px solid var(--secondary);
                cursor: pointer;
                text-align: center;
                transition: var(--transition);
            }
            
            .tv-app-btn:hover {
                background: var(--secondary);
                color: white;
            }
            
            .tv-input-grid {
                display: grid;
                grid-template-columns: repeat(2, 1fr);
                gap: 10px;
                margin-top: 15px;
            }
            
            .logo h1 {
                font-weight: 600;
                font-size: 1.8rem;
            }

            .search-bar {
                display: flex;
                background: white;
                border-radius: 30px;
                padding: 8px 15px;
                box-shadow: var(--card-shadow);
                width: 100%;
            }

            .search-bar input {
                border: none;
                outline: none;
                width: 100%;
                font-size: 1rem;
            }

            .dashboard {
                display: grid;
                grid-template-columns: 1fr;
                gap: 20px;
            }

            .sidebar {
                background: white;
                border-radius: 15px;
                padding: 20px;
                box-shadow: var(--card-shadow);
                overflow-x: auto;
            }

            .scene-item {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                padding: 12px;
                border-radius: 10px;
                cursor: pointer;
                transition: var(--transition);
                margin-bottom: 10px;
            }

            .scene-item:hover {
                transform: translateY(-2px);
                box-shadow: 0 6px 20px rgba(0, 0, 0, 0.15);
            }

            .scene-grid {
                display: grid;
                grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
                gap: 15px;
                margin-top: 20px;
            }

            .sidebar-content {
                display: flex;
                flex-direction: column;
                gap: 20px;
                min-width: 250px;
            }

            .sidebar h2 {
                color: var(--primary);
                display: flex;
                align-items: center;
                gap: 10px;
                font-size: 1.3rem;
            }

            .device-category {
                margin-bottom: 20px;
            }

            .device-category h3 {
                font-size: 1rem;
                margin-bottom: 12px;
                color: var(--secondary);
                display: flex;
                align-items: center;
                gap: 8px;
            }

            .device-list {
                list-style: none;
                display: grid;
                grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
                gap: 10px;
            }

            .device-item {
                padding: 12px;
                border-radius: 10px;
                cursor: pointer;
                transition: var(--transition);
                display: flex;
                align-items: center;
                gap: 8px;
                background: var(--light);
            }

            .device-item:hover {
                background: var(--secondary);
                color: white;
            }

            .device-item.active {
                background: var(--primary);
                color: white;
            }

            .main-content {
                display: grid;
                grid-template-rows: auto 1fr;
                gap: 20px;
            }

            .status-cards {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
                gap: 15px;
            }

            .card {
                background: white;
                border-radius: 12px;
                padding: 15px;
                box-shadow: var(--card-shadow);
                display: flex;
                flex-direction: column;
                gap: 12px;
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
                display: grid;
                grid-template-columns: 1fr;
                gap: 20px;
            }

            .control-panel {
                background: white;
                border-radius: 15px;
                padding: 20px;
                box-shadow: var(--card-shadow);
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

            .scene-item {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                padding: 15px;
                border-radius: 12px;
                cursor: pointer;
                transition: var(--transition);
                margin-bottom: 12px;
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

            .scene-grid {
                display: grid;
                grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
                gap: 15px;
                margin-top: 20px;
            }

            .control-section {
                margin-bottom: 20px;
            }

            .control-title {
                font-size: 1rem;
                margin-bottom: 12px;
                color: var(--secondary);
                display: flex;
                align-items: center;
                gap: 8px;
            }

            .switch-control {
                display: flex;
                align-items: center;
                justify-content: space-between;
                margin-bottom: 15px;
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

            .slider::-webkit-slider-thumb {
                -webkit-appearance: none;
                appearance: none;
                width: 18px;
                height: 18px;
                border-radius: 50%;
                background: var(--primary);
                cursor: pointer;
            }

            .color-picker {
                display: grid;
                grid-template-columns: repeat(4, 1fr);
                gap: 8px;
                margin-top: 12px;
            }

            .color-option {
                width: 35px;
                height: 35px;
                border-radius: 50%;
                cursor: pointer;
                transition: var(--transition);
            }

            .color-option:hover {
                transform: scale(1.1);
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

            .device-details {
                background: white;
                border-radius: 15px;
                padding: 20px;
                box-shadow: var(--card-shadow);
            }

            .detail-item {
                display: flex;
                justify-content: space-between;
                padding: 12px 0;
                border-bottom: 1px solid var(--light);
                font-size: 0.9rem;
            }

            .detail-item:last-child {
                border-bottom: none;
            }

            .btn {
                padding: 10px 16px;
                border: none;
                border-radius: 8px;
                cursor: pointer;
                font-weight: 500;
                transition: var(--transition);
                font-size: 0.9rem;
                margin-right: 10px;
                margin-bottom: 10px;
            }

            .btn-primary {
                background: var(--primary);
                color: white;
            }

            .btn-primary:hover {
                background: var(--secondary);
            }

            .btn-outline {
                background: transparent;
                border: 1px solid var(--primary);
                color: var(--primary);
            }

            .btn-outline:hover {
                background: var(--light);
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

            .loading {
                text-align: center;
                padding: 20px;
                color: var(--gray);
            }

            .notification-success {
                background-color: var(--success) !important;
            }

            .notification-error {
                 background-color: var(--danger) !important;
             }

             .notification-warning {
                  background-color: var(--warning) !important;
                 color: var(--dark) !important;
             }

             .notification-info {
                 background-color: var(--primary) !important;
             }

            /* 🦆 say Mobile menu button */
            .menu-toggle {
                display: none;
                background: var(--primary);
                color: white;
                border: none;
                border-radius: 8px;
                padding: 10px 15px;
                cursor: pointer;
                margin-bottom: 15px;
            }

            @media (min-width: 768px) {
                header {
                    flex-direction: row;
                    justify-content: space-between;
                    align-items: center;
                }
                
                .search-bar {
                    width: 300px;
                }
                
                .dashboard {
                    grid-template-columns: 1fr 3fr;
                }
                
                .sidebar {
                    height: fit-content;
                }
                
                .device-list {
                    grid-template-columns: 1fr;
                }
                
                .device-controls {
                    grid-template-columns: 2fr 1fr;
                }
            }

            @media (min-width: 1024px) {
                .status-cards {
                    grid-template-columns: repeat(4, 1fr);
                }
            }

            @media (max-width: 767px) {
                .menu-toggle {
                    display: block;
                }
                
                .sidebar {
                    display: none;
                }
                
                .sidebar.active {
                    display: block;
                }
            }
            @keyframes fadeIn {
                from { opacity: 0; transform: translateY(20px); }
                to { opacity: 1; transform: translateY(0); }
            }
            @keyframes fadeOut {
                from { opacity: 1; transform: translateY(0); }
                to { opacity: 0; transform: translateY(20px); }
            }
            
            .temperature-cycle {
                position: relative;
                overflow: hidden;
            }

            .fade-out {
                animation: fadeOut 0.5s ease forwards;
            }

            .fade-in {
                animation: fadeIn 0.5s ease forwards;
            }

            @keyframes fadeOut {
                from { opacity: 1; transform: translateY(0); }
                to { opacity: 0; transform: translateY(-10px); }
            }

            @keyframes fadeIn {
                from { opacity: 0; transform: translateY(10px); }
                to { opacity: 1; transform: translateY(0); }
            }
        </style>
    </head>
    <body>
        <div class="container">
            <header>
                <div class="logo">
                    <i class="fas fa-broadcast-tower"></i>
                    <h1>🦆'Dash</h1>
                </div>
                <div class="search-bar">
                    <i class="fas fa-search"></i>
                    <input type="text" placeholder="🦆 quack quack, how can I assist?" id="searchInput">
                </div>
            </header>

            <div class="connection-status" id="connectionStatus">
                <i class="fas fa-sync fa-spin"></i>
                <span></span>
            </div>

            <button class="menu-toggle" id="menuToggle">
                <i class="fas fa-bars"></i> Menu
            </button>

            <div class="dashboard">
                <div class="sidebar" id="sidebar">
                    <div class="sidebar-content">
                        <h2><i class="fas fa-th-large"></i> Devices</h2>
                        <div id="categoriesList">
                            <div class="loading">
                                <i class="fas fa-spinner fa-spin"></i> quack quack devices where are you..?
                            </div>
                        </div>
                    </div>
                </div>

                <div class="main-content">
                    <div class="status-cards" id="statusCards">
                        <div class="card">
                            <div class="card-header">
                                <div class="card-title">Connected Devices</div>
                                <i class="fas fa-network-wired" style="color: #2ecc71;"></i>
                            </div>
                            <div class="card-value" id="connectedDevicesCount">0</div>
                            <div class="card-details">
                                <i class="fas fa-check-circle"></i>
                                <span id="devicesStatus">Loading...</span>
                            </div>
                        </div>
                        
                        <div class="card temperature-cycle" id="temperatureCard">
                            <div class="card-header">
                                <div class="card-title">Temperature</div>
                                <i class="fas fa-thermometer-half" style="color: #e74c3c;"></i>
                            </div>
                            <div class="card-value" id="temperatureValue">23.5°C</div>
                            <div class="card-details">
                                <i class="fas fa-map-marker-alt"></i>
                                <span id="temperatureLocation">Living Room</span>
                            </div>
                        </div>
                       
                        <div class="card">
                            <div class="card-header">
                                <div class="card-title">Energy Usage</div>
                                <i class="fas fa-bolt" style="color: #f39c12;"></i>
                            </div>
                            <div class="card-value" id="connectedDevicesCount">350W</div>
                            <div class="card-details">
                                <i class="fas fa-clock"></i>
                                <span id="devicesStatus">This month</span>
                            </div>
                        </div>
                    </div>

                    <div class="device-controls" id="deviceControls">
                        <div class="control-panel" id="controlPanel">
                            <div class="loading">
                                <i class="fas fa-lightbulb"></i>
                                <p>Select a device</p>
                            </div>
                        </div>
                        
                        <div class="device-details" id="deviceDetails">
                            <h2 class="control-title">Device Details</h2>
                            <div class="loading">
                                <p>Select a device to view details</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <script src="https://unpkg.com/mqtt/dist/mqtt.min.js"></script>
        <script>

            // 🦆 says ⮞ embedded device data
            const DEVICES = ${deviceData};
            const ROOMS = ${roomData};
            const SCENES = ${sceneData};

            // 🦆 says ⮞ mqtt configuration
            const MQTT_HOST = '${mqttHostip}';
            const MQTT_PORT = 1883;
            const MQTT_USERNAME = 'mqtt';
            
            let client = null;
            let currentDevice = null;
            let deviceStates = {};
        
             // 🦆 says ⮞ temperature cycling variables
             let temperatureReadings = [];
             let currentTempIndex = 0;
             let tempCycleInterval = null;

        
            // 🦆 says ⮞ DOM
            const menuToggle = document.getElementById('menuToggle');
            const sidebar = document.getElementById('sidebar');
            const categoriesList = document.getElementById('categoriesList');
            const searchInput = document.getElementById('searchInput');
            const connectionStatus = document.getElementById('connectionStatus');
            const controlPanel = document.getElementById('controlPanel');
            const deviceDetails = document.getElementById('deviceDetails');
            const connectedDevicesCount = document.getElementById('connectedDevicesCount');
            const devicesStatus = document.getElementById('devicesStatus');
        
            // 🦆 say toggle mobile menu
            menuToggle.addEventListener('click', function() {
                sidebar.classList.toggle('active');
            });
        
            // 🦆 says ⮞ search func
            searchInput.addEventListener('input', function() {
                const searchTerm = this.value.toLowerCase();
                const deviceItems = document.querySelectorAll('.device-item');
                
                deviceItems.forEach(item => {
                    const deviceName = item.textContent.toLowerCase();
                    if (deviceName.includes(searchTerm)) {
                        item.style.display = 'flex';
                    } else {
                        item.style.display = 'none';
                    }
                });
            });
        
            // 🦆 says ⮞ function to collect temperature data from sensors
            function collectTemperatureData() {
                temperatureReadings = [];
    
                DEVICES.forEach(device => {
                    const state = deviceStates[device.id];
                    if (state && state.temperature !== undefined) {
                        temperatureReadings.push({
                            value: state.temperature,
                            location: device.name,
                            room: device.room,
                            timestamp: state.last_seen || 'Recently',
                            deviceId: device.id
                        });
                    }
                });
    
                if (temperatureReadings.length === 0) {
                    temperatureReadings.push({
                        value: 23.5,
                        location: 'No temperature sensors found',
                        room: 'Check device states',
                        timestamp: 'N/A',
                        deviceId: null
                    });
                }
    
                return temperatureReadings;
            }

            // 🦆 says ⮞ function to update temperature display with animation
            function updateTemperatureDisplay() {
                const tempCard = document.getElementById('temperatureCard');
                const tempValue = document.getElementById('temperatureValue');
                const tempLocation = document.getElementById('temperatureLocation');
    
                if (temperatureReadings.length === 0) {
                    collectTemperatureData();
                }
    
                if (temperatureReadings.length > 0) {
                    const reading = temperatureReadings[currentTempIndex];
        
                    tempCard.classList.add('fade-out');
        
                    setTimeout(() => {
                        tempValue.textContent = `''${reading.value}°C`;
                        tempLocation.textContent = reading.location;
            
                        tempCard.classList.remove('fade-out');
                        tempCard.classList.add('fade-in');
            
                        setTimeout(() => {
                            tempCard.classList.remove('fade-in');
                        }, 500);
            
        	                // 🦆 says ⮞ move to next reading
                        currentTempIndex = (currentTempIndex + 1) % temperatureReadings.length;
                    }, 500);
                }
            }

            // 🦆 says ⮞ start temperature cycling
            function startTemperatureCycle() {
                collectTemperatureData();
    
                updateTemperatureDisplay();
    
                // 🦆 says ⮞ interval for cycling
                if (tempCycleInterval) {
                    clearInterval(tempCycleInterval);
                }
    
                tempCycleInterval = setInterval(updateTemperatureDisplay, 10000);
            }

            // 🦆 says ⮞ update temperature data when new sensor data arrives
            function updateDeviceState(topic, message) {
                try {
                    const data = JSON.parse(message);
                    const deviceId = topic.split('/')[1];
        
                    // 🦆 says ⮞ store device state
                    if (!deviceStates[deviceId]) {
                        deviceStates[deviceId] = {};
                    }
        
                    Object.assign(deviceStates[deviceId], data);
        
                    // 🦆 says ⮞ if this is a temperature sensor, update our readings
                    const device = DEVICES.find(d => d.id === deviceId);
                    if (device && device.type === 'sensor' && data.temperature !== undefined) {
                        collectTemperatureData();
                    }
        
                    // 🦆 says ⮞ this current device? update UI
                    if (currentDevice && currentDevice.id === deviceId) {
                        updateDeviceControls(currentDevice);
                    }
                } catch (e) {
                    console.error('Error parsing message:', e);
                }
            }        

            // 🦆 says ⮞ duck assist 
            searchInput.addEventListener('input', function() {
                const searchTerm = this.value.toLowerCase();
                const deviceItems = document.querySelectorAll('.device-item');
    
                deviceItems.forEach(item => {
                    const deviceName = item.textContent.toLowerCase();
                    if (deviceName.includes(searchTerm)) {
                        item.style.display = 'flex';
                    } else {
                        item.style.display = 'none';
                    }
                });
            });

            searchInput.addEventListener('keydown', function(event) {
                if (event.key === 'Enter') {
                    const query = this.value.trim();
                    if (query) {
                        executeYoDoCommand(query);
                        this.value = "";
                    }
                }
            });

  
            // 🦆 says ⮞ update notification function to support different types
            function showNotification(message, type = 'success') {
                const notification = document.createElement('div');
    
                let bgColor = 'var(--success)';
                let icon = 'fa-check-circle';
    
                if (type === 'error') {
                    bgColor = 'var(--danger)';
                    icon = 'fa-exclamation-circle';
                } else if (type === 'warning') {
                    bgColor = 'var(--warning)';
                    icon = 'fa-exclamation-triangle';
                } else if (type === 'info') {
                    bgColor = 'var(--primary)';
                    icon = 'fa-info-circle';
                }
    
                notification.style = `
                    position: fixed;
                    bottom: 20px;
                    right: 20px;
                    background: ''${bgColor};
                    color: white;
                    padding: 15px 20px;
                    border-radius: 8px;
                    box-shadow: var(--card-shadow);
                    z-index: 1000;
                    animation: fadeIn 0.3s ease;
                    max-width: 300px;
                `;
    
                notification.innerHTML = `
                    <i class="fas ''${icon}"></i>
                    <span>''${message}</span>
                `;
    
                document.body.appendChild(notification);
    
                setTimeout(() => {
                    notification.style.animation = 'fadeOut 0.3s ease';
                    setTimeout(() => notification.remove(), 300);
                }, 5000);
            }


           
            // 🦆 says ⮞ render sidebar and devices
            function renderSidebar() {
                // 🦆 says ⮞ group by type
                const devicesByType = {};
                DEVICES.forEach(device => {
                    if (!devicesByType[device.type]) {
                        devicesByType[device.type] = [];
                    }
                    devicesByType[device.type].push(device);
                });
                
                let html = "";
                
                for (const type in devicesByType) {
                    const typeDevices = devicesByType[type];
                    const icon = getIconForType(type);
                    
                    html += `
                        <div class="device-category">
                            <h3><i class="fas fa-''${icon}"></i> ''${type.charAt(0).toUpperCase() + type.slice(1)}</h3>
                            <ul class="device-list">
                                ''${typeDevices.map(device => `
                                    <li class="device-item" data-device-id="''${device.id}">
                                        <i class="fas fa-''${icon}"></i> ''${device.name}
                                    </li>
                                `).join("")}
                            </ul>
                        </div>
                    `;
                }
                
                // 🦆 says ⮞ scenes section
                html += `
                    <div class="device-category">
                        <h3><i class="fas fa-theater-masks"></i> Scenes</h3>
                        <div class="scene-grid">
                            ''${SCENES.map(scene => `
                                <div class="scene-item" data-scene-name="''${scene.name}">
                                    <i class="fas fa-palette"></i>
                                    <span>''${scene.name}</span>
                                </div>
                            `).join("")}
                        </div>
                    </div>
                `;
                
                categoriesList.innerHTML = html;
                
                // 🦆 says ⮞ event listeners 4 device items
                const deviceItems = document.querySelectorAll('.device-item');
                deviceItems.forEach(item => {
                    item.addEventListener('click', function() {
                        deviceItems.forEach(i => i.classList.remove('active'));
                        this.classList.add('active');
                        
                        const deviceId = this.getAttribute('data-device-id');
                        const device = DEVICES.find(d => d.id === deviceId);
                        if (device) {
                            updateDeviceControls(device);
                        }
                    });
                });
                
                // 🦆 says ⮞ event listeners 4 scenes
                const sceneItems = document.querySelectorAll('.scene-item');
                sceneItems.forEach(item => {
                    item.addEventListener('click', function() {
                        const sceneName = this.getAttribute('data-scene-name');
                        const scene = SCENES.find(s => s.name === sceneName);
                        if (scene) {
                            activateScene(scene);
                        }
                    });
                });
                
                // 🦆 says ⮞ connected devices check
                connectedDevicesCount.textContent = DEVICES.length;
                devicesStatus.textContent = 'All devices';
            }
            
            // 🦆 says ⮞ add scene activation function
            function activateScene(scene) {
                if (!client || !client.connected) {
                    alert('Not connected to MQTT broker');
                    return;
                }
            
                scene.devices.forEach(device => {
                    const topic = `zigbee2mqtt/''${device.id}/set`;
                    const message = JSON.stringify(device.state);
                    client.publish(topic, message);
                    console.log('Activating scene device:', topic, message);
                });
                
                // 🦆 says ⮞ show notification
                showNotification(`Activated scene: ''${scene.name}`);
            }
            
            // 🦆 says ⮞ add notification function
            function showNotification(message) {
                const notification = document.createElement('div');
                notification.style = `
                    position: fixed;
                    bottom: 20px;
                    right: 20px;
                    background: var(--success);
                    color: white;
                    padding: 15px 20px;
                    border-radius: 8px;
                    box-shadow: var(--card-shadow);
                    z-index: 1000;
                    animation: fadeIn 0.3s ease;
                `;
                notification.innerHTML = `
                    <i class="fas fa-check-circle"></i>
                    <span>''${message}</span>
                `;
                
                document.body.appendChild(notification);
                
                // Remove after 3 seconds
                setTimeout(() => {
                    notification.style.animation = 'fadeOut 0.3s ease';
                    setTimeout(() => notification.remove(), 300);
                }, 3000);
            }
          
        
            // 🦆 says ⮞ device controls based on selected device
            function updateDeviceControls(device) {
                currentDevice = device;
                const deviceState = deviceStates[device.id] || {};
    
                // 🦆 says ⮞ control panel
                let controlsHtml = `
                    <div class="device-header">
                        <div class="device-icon">
                            <i class="fas fa-''${getIconForType(device.type)}"></i>
                        </div>
                        <div class="device-info">
                            <h2>''${device.name}</h2>
                            <p>''${device.manufacturer} • ''${deviceState.state || device.status}</p>
                        </div>
                    </div>
                `;
    
                // 🦆 says ⮞ device-specific controls
                if (device.type === 'light' || device.type === 'outlet') {
                    const isOn = deviceState.state === 'ON';
                    controlsHtml += `
                        <div class="control-section">
                            <div class="switch-control">
                                <div class="control-title">
                                    <i class="fas fa-power-off"></i>
                                    Power
                                </div>
                                <label class="toggle-switch">
                                    <input type="checkbox" class="device-toggle" ''${isOn ? 'checked' : ""}>
                                    <span class="toggle-slider"></span>
                                </label>
                            </div>
                        </div>
                    `;
        
                    if (device.type === 'light') {
                        const brightness = deviceState.brightness || 254;
                        controlsHtml += `
                            <div class="control-section">
                                <div class="slider-control">
                                    <div class="slider-label">
                                        <div class="control-title">
                                            <i class="fas fa-sun"></i>
                                            Brightness
                                        </div>
                                        <span class="brightness-value">''${Math.round(brightness/254*100)}%</span>
                                    </div>
                                    <input type="range" min="1" max="254" value="''${brightness}" class="slider brightness-slider">
                                </div>
                            </div>
                        `;
            
                        if (device.supports_color) {
                            controlsHtml += `
                                <div class="control-section">
                                    <div class="control-title">
                                        <i class="fas fa-palette"></i>
                                        Color
                                    </div>
                                    <input type="color" class="color-picker" value="#ffffff">
                                </div>
                            `;
                        }
                    }
                } 
                // 🦆 says ⮞ motion sensor controls
                else if (device.type === 'motion') {
                    const occupancy = deviceState.occupancy || false;
                    const battery = deviceState.battery || 'Unknown';
                    const voltage = deviceState.voltage || 'Unknown';
        
                    controlsHtml += `
                        <div class="control-section">
                            <div class="control-title">
                                <i class="fas fa-running"></i>
                                Motion Detection
                            </div>
                            <div class="detail-item">
                                <span>Status</span>
                                <span style="color: ''${occupancy ? 'var(--success)' : 'var(--gray)'};">
                                    ''${occupancy ? 'Motion Detected' : 'No Motion'}
                                </span>
                            </div>
                        </div>
                        <div class="control-section">
                            <div class="control-title">
                                <i class="fas fa-battery-half"></i>
                                Battery
                            </div>
                            <div class="detail-item">
                                <span>Level</span>
                                <span>''${battery}%</span>
                            </div>
                            <div class="detail-item">
                                <span>Voltage</span>
                                <span>''${voltage}V</span>
                            </div>
                        </div>
                    `;
        
                    if (deviceState.temperature !== undefined) {
                        controlsHtml += `
                            <div class="control-section">
                                <div class="control-title">
                                    <i class="fas fa-thermometer-half"></i>
                                    Temperature
                                </div>
                                <div class="detail-item">
                                    <span>Current</span>
                                    <span>''${deviceState.temperature}°C</span>
                                </div>
                            </div>
                        `;
                    }
                }
                
                // 🦆 says ⮞ tv
                else if (device.type === 'tv') {
                    const isOn = deviceState.state === 'ON';
                    controlsHtml += `
                        <div class="control-section">
                            <div class="switch-control">
                                <div class="control-title">
                                    <i class="fas fa-power-off"></i>
                                    Power
                                </div>
                                <label class="toggle-switch">
                                    <input type="checkbox" class="device-toggle" ''${isOn ? 'checked' : ""}>
                                    <span class="toggle-slider"></span>
                                </label>
                            </div>
                        </div>
                    `;
        
                    if (isOn) {
                        controlsHtml += `
                            <div class="control-section">
                                <div class="slider-control">
                                    <div class="slider-label">
                                        <div class="control-title">
                                            <i class="fas fa-volume-up"></i>
                                            Volume
                                        </div>
                                        <span class="volume-value">''${deviceState.volume || 50}%</span>
                                    </div>
                                    <input type="range" min="0" max="100" value="''${deviceState.volume || 50}" class="slider volume-slider">
                                </div>
                            </div>
                            
                            <div class="control-section">
                                <div class="control-title">
                                    <i class="fas fa-play-circle"></i>
                                    Apps
                                </div>
                                <div class="tv-app-grid">
                                    ''${Object.entries(TV_APPS).map(([name, pkg]) => `
                                        <button class="tv-app-btn" data-app="''${name}">
                                            <i class="fab fa-''${name}"></i>
                                            <span>''${name.charAt(0).toUpperCase() + name.slice(1)}</span>
                                        </button>
                                    `).join("")}
                                </div>
                            </div>
                            
                            <div class="control-section">
                                <div class="control-title">
                                    <i class="fas fa-input"></i>
                                    Input Sources
                                </div>
                                <div class="tv-input-grid">
                                    ''${TV_INPUTS.map(input => `
                                        <button class="tv-input-btn" data-input="''${input}">
                                            ''${input}
                                        </button>
                                    `).join("")}
                                </div>
                            </div>
                        `;
                    }
                }
                
                // 🦆 says ⮞ BLINDs are the best NcBLindy recognize!
                else if (device.type === 'blind' || device.type === 'curtain') {
                    const position = deviceState.position || 100;
                    const state = deviceState.state || 'STOP';
        
                    controlsHtml += `
                        <div class="control-section">
                            <div class="control-title">
                                <i class="fas fa-window-maximize"></i>
                                Position Control
                            </div>
                            <div class="slider-control">
                                <div class="slider-label">
                                    <div class="control-title">
                                        <i class="fas fa-sliders-h"></i>
                                        Position
                                    </div>
                                    <span class="position-value">''${position}%</span>
                                </div>
                                <input type="range" min="0" max="100" value="''${position}" class="slider position-slider">
                            </div>
                            <div class="button-group" style="display: flex; gap: 10px; margin-top: 15px;">
                                <button class="btn btn-primary blind-control" data-action="OPEN">
                                    <i class="fas fa-arrow-up"></i> Open
                                </button>
                                <button class="btn btn-primary blind-control" data-action="STOP">
                                    <i class="fas fa-stop"></i> Stop
                                </button>
                                <button class="btn btn-primary blind-control" data-action="CLOSE">
                                    <i class="fas fa-arrow-down"></i> Close
                                </button>
                            </div>
                        </div>
                    `;
        
                    if (deviceState.temperature !== undefined) {
                        controlsHtml += `
                            <div class="control-section">
                                <div class="control-title">
                                    <i class="fas fa-thermometer-half"></i>
                                    Temperature
                                </div>
                                <div class="detail-item">
                                    <span>Current</span>
                                    <span>''${deviceState.temperature}°C</span>
                                </div>
                            </div>
                        `;
                    }
                }
                // 🦆 says ⮞ generic sensor controls
                else if (device.type === 'sensor') {
                    controlsHtml += `
                        <div class="control-section">
                            <div class="control-title">
                                <i class="fas fa-info-circle"></i>
                                Sensor Data
                            </div>
                    `;
        
                    Object.entries(deviceState).forEach(([key, value]) => {
                        if (key !== 'linkquality' && key !== 'last_seen') {
                            let displayName = key.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase());
                            let icon = 'fas fa-info-circle';
                
                            if (key === 'temperature') icon = 'fas fa-thermometer-half';
                            if (key === 'humidity') icon = 'fas fa-tint';
                            if (key === 'pressure') icon = 'fas fa-tachometer-alt';
                            if (key === 'battery') icon = 'fas fa-battery-half';
                
                            controlsHtml += `
                                <div class="detail-item">
                                    <span><i class="''${icon}"></i> ''${displayName}</span>
                                    <span>''${value}''${key === 'temperature' ? '°C' : key === 'humidity' ? '%' : key === 'pressure' ? 'hPa' : ""}</span>
                                </div>
                            `;
                        }
                    });
        
                    controlsHtml += `</div>`;
                }
                // 🦆 says ⮞ default for unknown devices
                else {
                    controlsHtml += `
                        <div class="control-section">
                            <div class="control-title">
                                <i class="fas fa-info-circle"></i>
                                Device Information
                            </div>
                            <div class="detail-item">
                                <span>Type</span>
                                <span>''${device.type}</span>
                            </div>
                            <div class="detail-item">
                                <span>Status</span>
                                <span>''${deviceState.state || 'Unknown'}</span>
                            </div>
                        </div>
                        <div class="control-section">
                            <div class="control-title">
                                <i class="fas fa-code"></i>
                                Raw Data
                            </div>
                            <pre style="background: var(--light); padding: 10px; border-radius: 5px; overflow: auto; max-height: 200px;">
                                ''${JSON.stringify(deviceState, null, 2)}
                            </pre>
                        </div>
                    `;
                }
    
                controlPanel.innerHTML = controlsHtml;
    
                // 🦆 says ⮞ event listeners for controls
                setupDeviceControlListeners(device);
                // 🦆 says ⮞ setup for tv controls
                if (device.type === 'tv') {
                    setupTVControls(device);
                }
            }
        
            // 🦆 says ⮞ update device details panel
            function updateDeviceDetails(device) {
                const deviceState = deviceStates[device.id] || {};
                
                deviceDetails.innerHTML = `
                    <h2 class="control-title">Device Details</h2>
                    <div class="detail-item">
                        <span>Status</span>
                        <span style="color: ''${deviceState.state === 'ON' ? 'var(--success)' : 'var(--gray)'};">
                            ''${deviceState.state || 'Unknown'}
                        </span>
                    </div>
                    <div class="detail-item">
                        <span>Manufacturer</span>
                        <span>''${device.manufacturer}</span>
                    </div>
                    <div class="detail-item">
                        <span>Model</span>
                        <span>''${device.model}</span>
                    </div>
                    <div class="detail-item">
                        <span>Type</span>
                        <span>''${device.type}</span>
                    </div>
                    <div class="detail-item">
                        <span>Room</span>
                        <span>''${device.room}</span>
                    </div>
                    <div class="detail-item">
                        <span>Signal Strength</span>
                        <span>
                            <i class="fas fa-wifi" style="color: var(--success);"></i>
                            Excellent
                        </span>
                    </div>
                    ''${deviceState.brightness ? `
                    <div class="detail-item">
                        <span>Brightness</span>
                        <span>''${Math.round(deviceState.brightness/254*100)}%</span>
                    </div>
                    ` : ""}
                `;
            }
        
            // 🦆 says ⮞ fetch icon 4 device type
            function getIconForType(type) {
                const iconMap = {
                    'light': 'lightbulb',
                    'outlet': 'plug',
                    'sensor': 'thermometer-half',
                    'motion': 'running',
                    'dimmer': 'sliders-h',
                    'blind': 'window-maximize',
                    'remote': 'remote'
                };
                return iconMap[type] || 'microchip';
            }
        
            // 🦆 says ⮞ MQTT func
            async function connectMqtt() {
                let password = localStorage.getItem('mqtt_password');
                
                if (!password) {
                    password = prompt("Authorization required. Enter MQTT password:");
                    if (!password) {
                        updateConnectionStatus('error', 'No password entered');
                        return;
                    }
                    // 🦆 says ⮞ save password?
                    if (confirm("🦆 quack cache a lot? (Remember password)")) {
                        localStorage.setItem('mqtt_password', password);
                    }
                }
        
                const options = {
                    host: MQTT_HOST,
                    port: MQTT_PORT,
                    username: MQTT_USERNAME,
                    password: password.trim(),
                    protocol: 'mqtt'
                };
        
                try {
                    client = mqtt.connect(options);
                    client.on('connect', () => {
                        updateConnectionStatus('connected', 'Connected to MQTT');
                        console.log('Connected to MQTT broker');
                        
                        // 🦆 says ⮞ subscribez?
                        client.subscribe('zigbee2mqtt/#', (err) => {
                            if (!err) {
                                console.log('Subscribed to all devices');
                            }
                        });
                    });
        
                    client.on('error', (err) => {
                        updateConnectionStatus('error', 'Connection failed: ' + err.message);
                        console.error('Connection error:', err);
                        // 🦆 says ⮞ clear password on failure
                        localStorage.removeItem('mqtt_password');
                    });
                    
                    client.on('message', (topic, message) => {
                        console.log('Received message:', topic, message.toString());
                        updateDeviceState(topic, message.toString());
                    });
                } catch (err) {
                    updateConnectionStatus('error', 'Connection error: ' + err.message);
                    console.error('Connection error:', err);
                }
            }
            
            function updateConnectionStatus(status, message) {
                connectionStatus.className = 'connection-status';
                const icon = connectionStatus.querySelector('i');
                
                switch(status) {
                    case 'connecting':
                        connectionStatus.classList.add('status-connecting');
                        icon.className = 'fas fa-sync fa-spin';
                        break;
                    case 'connected':
                        connectionStatus.classList.add('status-connected');
                        icon.className = 'fas fa-check-circle';
                        break;
                    case 'error':
                        connectionStatus.classList.add('status-error');
                        icon.className = 'fas fa-exclamation-circle';
                        break;
                }
                
                connectionStatus.querySelector('span').textContent = message;
            }
            
            function updateDeviceState(topic, message) {
                try {
                    const data = JSON.parse(message);
                    const deviceId = topic.split('/')[1];
                    
                    // 🦆 says ⮞ store device state
                    if (!deviceStates[deviceId]) {
                        deviceStates[deviceId] = {};
                    }
                    
                    Object.assign(deviceStates[deviceId], data);
                    
                    // 🦆 says ⮞ this current device? update UI
                    if (currentDevice && currentDevice.id === deviceId) {
                        updateDeviceControls(currentDevice);
                    }
                } catch (e) {
                    console.error('Error parsing message:', e);
                }
            }
        
            function toggleDevice(device, state) {
                if (!client || !client.connected) return;
                const topic = `zigbee2mqtt/''${device.id}/set`;
                const message = JSON.stringify({ state: state ? 'ON' : 'OFF' });
                client.publish(topic, message);
                console.log('Published to ' + topic + ': ' + message);
            }

            // 🦆 says ⮞ setup event listeners for device controls
            function setupDeviceControlListeners(device) {
                const toggle = controlPanel.querySelector('.device-toggle');
                if (toggle) {
                    toggle.addEventListener('change', function() {
                        toggleDevice(device, this.checked);
                    });
                }
    
                // 🦆 says ⮞ brightness
                const brightnessSlider = controlPanel.querySelector('.brightness-slider');
                if (brightnessSlider) {
                    brightnessSlider.addEventListener('input', function() {
                        const value = parseInt(this.value);
                        controlPanel.querySelector('.brightness-value').textContent = Math.round(value/254*100) + '%';
                        setBrightness(device, value);
                    });
                }
    
                const colorPicker = controlPanel.querySelector('.color-picker');
                if (colorPicker) {
                    colorPicker.addEventListener('input', function() {
                        setColor(device, this.value);
                    });
                }
    
                // 🦆 says ⮞ position slider
                const positionSlider = controlPanel.querySelector('.position-slider');
                if (positionSlider) {
                    positionSlider.addEventListener('input', function() {
                        const value = parseInt(this.value);
                        controlPanel.querySelector('.position-value').textContent = value + '%';
                        setPosition(device, value);
                    });
                }
    
                // 🦆 says ⮞ blinds
                const blindControls = controlPanel.querySelectorAll('.blind-control');
                blindControls.forEach(button => {
                    button.addEventListener('click', function() {
                        const action = this.getAttribute('data-action');
                        controlBlind(device, action);
                    });
                });
            }

            // 🦆 says ⮞ add functions for controlling blinds
            function setPosition(device, position) {
                if (!client || !client.connected) return;
                const topic = `zigbee2mqtt/''${device.id}/set`;
                const message = JSON.stringify({ position: parseInt(position) });
                client.publish(topic, message);
            }

            function controlBlind(device, action) {
                if (!client || !client.connected) return;
                const topic = `zigbee2mqtt/''${device.id}/set`;
                const message = JSON.stringify({ state: action });
                client.publish(topic, message);
            }


            // 🦆 says ⮞ fetch icon for device type
            function getIconForType(type) {
                const iconMap = {
                    'light': 'lightbulb',
                    'outlet': 'plug',
                    'sensor': 'thermometer-half',
                    'motion': 'running',
                    'dimmer': 'sliders-h',
                    'blind': 'window-maximize',
                    'curtain': 'window-maximize',
                    'remote': 'remote',
                    'switch': 'toggle-on',
                    'contact': 'door-open',
                    'vibration': 'wave-square',
                    'water': 'tint',
                    'smoke': 'fire',
                    'gas': 'wind',
                    'occupancy': 'user',
                    'climate': 'thermometer-full',
                    'fan': 'fan',
                    'lock': 'lock',
                    'cover': 'window-maximize',
                    'tv': 'tv'
                };
                return iconMap[type] || 'microchip';
            }
        
            function setBrightness(device, value) {
                if (!client || !client.connected) return;
                const topic = `zigbee2mqtt/''${device.id}/set`;
                const message = JSON.stringify({ brightness: parseInt(value) });
                client.publish(topic, message);
            }
        
            function setColor(device, color) {
                if (!client || !client.connected) return;
                const topic = `zigbee2mqtt/''${device.id}/set`;
                // 🦆 says ⮞ convert hex to RGB
                const hex = color.replace('#', "");
                const r = parseInt(hex.substring(0, 2), 16);
                const g = parseInt(hex.substring(2, 4), 16);
                const b = parseInt(hex.substring(4, 6), 16);
                const message = JSON.stringify({ color: { rgb: `''${r},''${g},''${b}` } });
                client.publish(topic, message);
            }
            
            function forgetPassword() {
                localStorage.removeItem('mqtt_password');
                if (client) {
                    client.end();
                    client = null;
                }
                updateConnectionStatus('connecting', 'Connecting to MQTT...');
                connectMqtt();
            }
          
            // 🦆 says ⮞ start the temperature cycle when the DOM is loaded
            document.addEventListener('DOMContentLoaded', function() {
                renderSidebar();
                connectMqtt();
                const logoutBtn = document.createElement('button');
                logoutBtn.className = 'btn btn-outline';
                logoutBtn.innerHTML = '<i class="fas fa-sign-out-alt"></i>Logout';
                logoutBtn.onclick = forgetPassword;
                connectionStatus.appendChild(logoutBtn);
                setTimeout(startTemperatureCycle, 2000);
            });
       
            function executeYoDoCommand(command) {
                if (!client || !client.connected) {
                    showNotification('Error: Not connected to MQTT broker', 'error');
                    return;
                }

                const topic = 'zigbee2mqtt/do';
                const message = JSON.stringify({
                    command: command,
                    timestamp: new Date().toISOString(),
                    origin: 'dashboard'
                });

                client.publish(topic, message);
                console.log('Published yo do command:', topic, message);
                showNotification('Executing: yo do "' + command + '"');
            }
               
            // 🦆 says ⮞ tv apps
            const TV_APPS = {
                "netflix": "com.netflix.ninja",
                "youtube": "com.google.android.youtube.tv",
                "spotify": "com.spotify.tv.android",
                "plex": "com.plexapp.android",
                "kodi": "org.xbmc.kodi",
                "disney": "com.disney.disneyplus",
                "prime": "com.amazon.amazonvideo.livingroom"
            };

            // 🦆 says ⮞ tv input
            const TV_INPUTS = [
                "HDMI 1", "HDMI 2", "HDMI 3", "HDMI 4",
                "AV", "Component", "TV", "VGA"
            ];

            // 🦆 says ⮞ control TV
            function controlTV(device, command, value = null) {
                fetch(`/tv-control?device=''${device.id}&command=''${command}&value=''${value}`)
                    .then(response => response.json())
                    .then(data => {
                        if (data.success) {
                            showNotification(`TV command sent: ''${command}`);
                        } else {
                            showNotification(`TV command failed: ''${data.error}`, 'error');
                        }
                    })
                    .catch(error => {
                        console.error('Error controlling TV:', error);
                        showNotification('Error controlling TV', 'error');
                    });
            }

            // 🦆 says ⮞ update device controls for TV
            function setupTVControls(device) {
                const tvPowerToggle = controlPanel.querySelector('.device-toggle');
                if (tvPowerToggle) {
                    tvPowerToggle.addEventListener('change', function() {
                        controlTV(device, 'power', this.checked ? 'on' : 'off');
                    });
                }

                const volumeSlider = controlPanel.querySelector('.volume-slider');
                if (volumeSlider) {
                    volumeSlider.addEventListener('input', function() {
                        const value = parseInt(this.value);
                        controlPanel.querySelector('.volume-value').textContent = value + '%';
                        controlTV(device, 'volume', value);
                    });
                }

                const appButtons = controlPanel.querySelectorAll('.tv-app-btn');
                appButtons.forEach(button => {
                    button.addEventListener('click', function() {
                        const app = this.getAttribute('data-app');
                        controlTV(device, 'app', TV_APPS[app]);
                    });
                });

                const inputButtons = controlPanel.querySelectorAll('.tv-input-btn');
                inputButtons.forEach(button => {
                    button.addEventListener('click', function() {
                        const input = this.getAttribute('data-input');
                        controlTV(device, 'input', input);
                    });
                });
            }

        </script>
        
    </body>
    </html>
  '';

in {

  environment.etc."zigbee-control.html" = {
    text = webFrontend;
    mode = "0644";
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
        dt_info "Starting 🦆'Dash server on http://${mqttHostip}:$PORT/zigbee-control.html"
        ${httpServer}/bin/serve-dashboard "$HOST" "$PORT" 
      '';
    };  
  };
  
  services.nginx = {
    enable = true;
    virtualHosts."localhost" = {
      locations."/tv-control" = {
        extraConfig = ''
          add_header Content-Type application/json;
          return 200 '{"success": true}';
        '';
      };
    };
  };}
