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
    <html>
    <head>
        <meta charset="utf-8" />
        <title>🦆'Dash</title>
        <script src="https://unpkg.com/mqtt/dist/mqtt.min.js"></script>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/quackhack-mcblindy/dotfiles@main/modules/themes/css/duckdash.css">
    </head>
    <body>
        <header>
            <div class="logo">
                <i class="fas fa-broadcast-tower"></i>
                <h1>🦆'Dash</h1>
            </div>
           
            <div class="search-bar">
                <i class="fas fa-search"></i>
                🎙️ <input type="text" placeholder="🦆 quack quack, may I assist?" id="searchInput">
            </div>
            
            <div class="device-selector-container">
                <select id="deviceSelect" class="device-selector"></select>
            </div>
        </header>


        <div class="page-container" id="pageContainer">
            <!-- 🦆 says ⮞ PAGE 1 -->
            <div class="page active" id="pageDevices">
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
                </div>
            </div>
                    
            <div id="latest">Waiting for data...</div>
                    
           
            <!-- 🦆 says ⮞ PAGE 2 -->
            <div class="page hidden" id="pageScenes">
                <h3>Scenes</h3>
                <div class="scenes-grid">
                    ''${sceneButtons}
                </div>
            </div>
            
                       
            <!-- 🦆 says ⮞ PAGE 3 -->
            <div class="page hidden" id="pageTV">
                <h3>TV</h3>
                <div class="tv-controls">
                    <div class="tv-power">
                        <button class="tv-btn power" onclick="sendTVCommand('power')">Power</button>
                    </div>
                    <div class="tv-volume">
                        <button class="tv-btn" onclick="sendTVCommand('volume_down')">🔉</button>
                        <button class="tv-btn" onclick="sendTVCommand('volume_up')">🔊</button>
                        <button class="tv-btn" onclick="sendTVCommand('mute')">🔇</button>
                    </div>
                    <div class="tv-navigation">
                        <button class="tv-btn" onclick="sendTVCommand('up')">↑</button>
                        <button class="tv-btn" onclick="sendTVCommand('left')">←</button>
                        <button class="tv-btn ok" onclick="sendTVCommand('select')">OK</button>
                        <button class="tv-btn" onclick="sendTVCommand('right')">→</button>
                        <button class="tv-btn" onclick="sendTVCommand('down')">↓</button>
                    </div>
                    <div class="tv-playback">
                        <button class="tv-btn" onclick="sendTVCommand('back')">◀◀</button>
                        <button class="tv-btn" onclick="sendTVCommand('play_pause')">⏯️</button>
                        <button class="tv-btn" onclick="sendTVCommand('forward')">▶▶</button>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="nav-tabs">
            <div class="nav-tab active" data-page="pageDevices">DEVICE</div>
            <div class="nav-tab" data-page="pageScenes">SCENE</div>
            <div class="nav-tab" data-page="pageTV">TV</div>
        </div>

      <script src="https://unpkg.com/mqtt/dist/mqtt.min.js"></script>
      
      <script>
      document.addEventListener('DOMContentLoaded', () => {
          /*🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆
           * ⮞ CONFIG
           🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆*/
          const brokerUrl = 'ws://${mqttHostip}:9001';
          const mqttOpts = { username: 'mqtt', password: "" };
          const devices = {};
          let selectedDevice = null;
          let currentPage = 'pageDevices';
          let startX = 0;
          let currentX = 0;             
      
          /*🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆
           * MQTT
           🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆*/
          const client = mqtt.connect(brokerUrl, mqttOpts);
          let lastSeenIso = null;
          let lastMessage = null;
      
          /*🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆
           * ⮞ HELPERS
           🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆*/
          function timeAgo(isoString) {
              if (!isoString) return "";
              const now = new Date(), past = new Date(isoString);
              const seconds = Math.max(0, Math.floor((now - past) / 1000));
              const minutes = Math.floor(seconds / 60);
              const hours = Math.floor(minutes / 60);
              const days = Math.floor(hours / 24);
              if (days > 0) return `''${days} day''${days>1?"s":""} ago`;
              if (hours > 0) return `''${hours} hour''${hours>1?"s":""} ago`;
              if (minutes > 0) return `''${minutes} minute''${minutes>1?"s":""} ago`;
              return `''${seconds} second''${seconds!==1?"s":""} ago`;
          }
      
          function linkQualityText(v) {
              if (v >= 80) return 'Excellent';
              if (v >= 60) return 'Good';
              if (v >= 40) return 'Bad';
              return 'Terrible';
          }
      
          function valueColor(key, value) {
              const k = key.toLowerCase();
              if (k === 'battery') return value > 20 ? 'var(--ok)' : 'var(--bad)';
              if (k === 'linkquality') return value >= 80 ? 'var(--ok)' : (value >= 60 ? 'var(--good)' : (value >= 40 ? 'var(--warn)' : 'var(--bad)'));
              if (k === 'temperature') return value < 18 ? '#2563eb' : (value <= 26 ? 'var(--ok)' : 'var(--bad)');
              if (k === 'brightness') return value < 50 ? 'var(--bad)' : (value <= 200 ? 'var(--ok)' : 'var(--warn)');
              return "";
          }
      
          function formatValue(key, value) {
              const k = key.toLowerCase();
              if (k === 'battery') return `''${value}%`;
              if (k === 'temperature') return `''${value}°C`;
              if (k === 'linkquality') return linkQualityText(Number(value));
              return String(value);
          }
      
          function clamp(n, min, max) { return Math.max(min, Math.min(max, n)); }
      
          function normalizeColor(val) {
              if (typeof val === 'string') {
                  const hex = val.trim();
                  const m = /^#?([0-9a-f]{6})$/i.exec(hex);
                  if (m) {
                      const n = parseInt(m[1], 16);
                      const r = (n >> 16) & 255;
                      const g = (n >> 8) & 255;
                      const b = n & 255;
                      return { r, g, b, w: 0, hex: `#''${m[1].toLowerCase()}` };
                  }
              } else if (val && typeof val === 'object') {
                  const r = clamp(parseInt(val.r ?? val.red ?? 0), 0, 255);
                  const g = clamp(parseInt(val.g ?? val.green ?? 0), 0, 255);
                  const b = clamp(parseInt(val.b ?? val.blue ?? 0), 0, 255);
                  const w = clamp(parseInt(val.w ?? val.white ?? 0), 0, 255);
                  const hex = '#' + [r, g, b].map(x => x.toString(16).padStart(2, '0')).join("");
                  return { r, g, b, w, hex };
              }
              return { r: 255, g: 255, b: 255, w: 0, hex: '#ffffff' };
          }
      
          function setRangeGradient(el, fromColor, toColor) {
              el.style.background = `linear-gradient(90deg, ''${fromColor} 0%, ''${toColor} 100%)`;
          }
      
          function refreshSliderBackgrounds() {
              const r = document.getElementById('rSlider');
              const g = document.getElementById('gSlider');
              const b = document.getElementById('bSlider');
              const w = document.getElementById('wSlider');
              if (r) setRangeGradient(r, '#000', '#f00');
              if (g) setRangeGradient(g, '#000', '#0f0');
              if (b) setRangeGradient(b, '#000', '#00f');
              if (w) setRangeGradient(w, '#000', '#fff');
          }
      
          function publishPatch(patch) {
              const topic = `zigbee2mqtt/''${selectedDevice}/set`;
              const payload = JSON.stringify(patch);
              client.publish(topic, payload);
          }
      
          function toggleDevice(deviceId, state) {
              const topic = `zigbee2mqtt/''${deviceId}/set`;
              const payload = JSON.stringify({ state: state ? 'ON' : 'OFF' });
              client.publish(topic, payload);
          }
      
          function updateRGBColor(slider) {
              const deviceId = slider.dataset.device;
              const hue = slider.value;
              const topic = `zigbee2mqtt/''${deviceId}/set`;
              const payload = JSON.stringify({ color: { hue: parseInt(hue) } });
              client.publish(topic, payload);
          }
      
          function toggleDeviceControls(deviceId) {
              const controls = document.getElementById('controls-' + deviceId);
              controls.style.display = (controls.style.display === 'none') ? 'block' : 'none';
          }
      
          function toggleRoom(room) {
              const content = document.getElementById('room-content-' + room);
              if (content.style.display === 'none') content.style.display = 'block';
              else content.style.display = 'none';
          }

          function toggleRoom(room) {
            const content = document.getElementById('room-content-' + room);
            if (content.style.display === 'none') content.style.display = 'block';
            else content.style.display = 'none';
          }
        
          function applyScene(sceneName) {
            const scenes = ''${builtins.toJSON scenes};
            const scene = scenes[sceneName];
          
            if (!scene) {
              console.error(`Scene ''${sceneName} not found`);
              return;
            }
          
            console.log(`Applying scene: ''${sceneName}`);
           
            Object.entries(scene).forEach(([device, settings]) => {
              const topic = `zigbee2mqtt/''${device}/set`;
              client.publish(topic, JSON.stringify(settings));
            });
          }

        function showPage(pageId) {
            document.querySelectorAll('.page').forEach(page => {
                page.classList.add('hidden');
                page.classList.remove('active');
            });
            
            document.querySelectorAll('.nav-tab').forEach(tab => {
                tab.classList.remove('active');
            });
            
            document.getElementById(pageId).classList.remove('hidden');
            document.getElementById(pageId).classList.add('active');
            document.querySelector(`[data-page="''${pageId}"]`).classList.add('active');
            
            currentPage = pageId;
        }
        
        document.querySelectorAll('.nav-tab').forEach(tab => {
            tab.addEventListener('click', () => {
                showPage(tab.dataset.page);
            });
        });
        
        const pageContainer = document.getElementById('pageContainer');
        
        pageContainer.addEventListener('touchstart', e => {
            startX = e.touches[0].clientX;
        });
        
        pageContainer.addEventListener('touchmove', e => {
            currentX = e.touches[0].clientX;
        });
        
        pageContainer.addEventListener('touchend', () => {
            const diff = startX - currentX;
            const swipeThreshold = 50;
            
            if (Math.abs(diff) > swipeThreshold) {
                const pages = ['pageDevices', 'pageScenes', 'pageTV'];
                const currentIndex = pages.indexOf(currentPage);
                
                if (diff > 0 && currentIndex < pages.length - 1) {
                    showPage(pages[currentIndex + 1]);
                } else if (diff < 0 && currentIndex > 0) {
                    showPage(pages[currentIndex - 1]);
                }
            }

        

          /*🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆
           * ⮞ TEMP CARD
           🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆*/
          function updateTemperatureCard() {
            const card = document.getElementById('temperature-card');
            const sensors = Object.entries(temperatureSensors);
          
            if (sensors.length === 0) {
              card.innerHTML = `
                <div class="card-item active">
                  <span class="value-large">--.-°C</span>
                  <span class="value-label">Waiting for data...</span>
                </div>
              `;
              return;
            }
          
            card.innerHTML = "";
          
            sensors.forEach(([name, data], index) => {
              const item = document.createElement('div');
              item.className = 'card-item';
              if (index === currentTempIndex) item.classList.add('active');
            
              item.innerHTML = `
                <span class="value-large">''${data.temperature}°C</span>
                <span class="value-label">''${name}</span>
              `;
            
              card.appendChild(item);
            });
          
            currentTempIndex = (currentTempIndex + 1) % sensors.length;
          }
        
          /*🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆
           * ⮞ TIBBER
           🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆*/
          function updateElectricityCard() {
            const card = document.getElementById('electricity-card');
            const items = card.querySelectorAll('.card-item');
          
            items.forEach(item => item.classList.remove('active'));
          
            if (items[currentElectricityView]) {
              items[currentElectricityView].classList.add('active');
            }
            
            if (electricityData.price !== null && items[0]) {
              items[0].innerHTML = `
                <span class="value-large">''${electricityData.price} öre/kWh</span>
                <span class="value-label">Current Price</span>
              `;
            }
          
            if (electricityData.usage !== null && items[1]) {
              items[1].innerHTML = `
                <span class="value-large">''${electricityData.usage} kWh</span>
                <span class="value-label">Monthly Usage</span>
              `;
            }
          
            currentElectricityView = (currentElectricityView + 1) % items.length;
          }
      
          /*🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆
           * ⮞ RENDER
           🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆*/
          function renderMessage(parsed, topic) {
              const latest = document.getElementById('latest');
              const title = document.getElementById('panelTitle');
              title.textContent = `Device Panel – ''${selectedDevice}`;
      
              let rowsHtml = "";
              const entries = Object.entries(parsed);
              let controlsHtml = "";
      
              // 🦆 says ⮞ STATE (toggle)
              if ('state' in parsed) {
                  const checked = String(parsed.state).toUpperCase() === 'ON' ? 'checked' : "";
                  controlsHtml += `
                      <div class="row">
                          <div class="key">state</div>
                          <div>
                              <label class="switch">
                                  <input type="checkbox" id="stateToggle" ''${checked}>
                                  <span class="slider"></span>
                              </label>
                          </div>
                      </div>`;
              }
      
              // 🦆 says ⮞  BRIGHTNESS
              if ('brightness' in parsed) {
                  const v = clamp(Number(parsed.brightness) || 0, 0, 255);
                  controlsHtml += `
                      <div class="row">
                          <div class="key">brightness</div>
                          <div class="slider-row">
                              <span>☀️</span>
                              <input type="range" min="0" max="255" value="''${v}" id="brightnessSlider">
                              <span class="badge" id="brightnessBadge">''${v}</span>
                          </div>
                      </div>`;
              }
      
              // 🦆 says ⮞  COLOR PICKER
              if ('color' in parsed) {
                  const col = normalizeColor(parsed.color);
                  controlsHtml += `
                      <div class="section">Color</div>
                      <div class="row">
                          <div class="key">color picker</div>
                          <div style="display:grid; gap:8px;">
                              <input type="color" id="colorPicker" value="''${col.hex}" style="width:120px; height:36px; padding:0; border: 1px solid var(--border); border-radius:8px;">
                              <div class="preview" id="colorPreview" style="background:''${col.hex};"></div>
                          </div>
                      </div>
      
                      <div class="row">
                          <div class="key">RGBW sliders</div>
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
      
              for (const [key, value] of entries) {
                  const lower = key.toLowerCase();
                  if (lower === 'state' || lower === 'brightness' || lower === 'color') continue;
      
                  let disp = value;
                  let typeClass = 'val-string';
                  let style = "";
      
                  if (lower === 'last_seen') {
                      lastSeenIso = value;
                      disp = timeAgo(value);
                      typeClass = "";
                      style = 'color: var(--muted)';
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
      
              const nowTime = new Date().toLocaleString();
              latest.innerHTML = `
                  <div class="time"><span id="updatedAt">''${nowTime}</span></div>
                  <div class="msg">''${topic}</div>
                  <div class="json">
                      ''${controlsHtml}
                      ''${rowsHtml}
                  </div>
              `;
      
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
      
              refreshSliderBackgrounds();
      
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
              [rS, gS, bS, wS].forEach(el => { if (el) el.oninput = syncFromSliders; });
          }
      
          function tickLastSeen() {
              if (!lastSeenIso) return;
              const els = document.querySelectorAll('.row .key');
              for (const el of els) {
                  if (el.textContent.trim().toLowerCase() === 'last_seen') {
                      const valEl = el.nextElementSibling?.firstElementChild;
                      if (valEl) valEl.textContent = timeAgo(lastSeenIso);
                  }
              }
              const updatedAt = document.getElementById('updatedAt');
              if (updatedAt) updatedAt.textContent = new Date().toLocaleString();
          }
      
          /*🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆
           * ⮞ EVENTS
           🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆*/
          client.on('connect', () => {
              console.log('Connected');
              client.subscribe('zigbee2mqtt/#');
              client.subscribe('zigbee2mqtt/bridge/devices');
          });
      
          client.on('message', (topic, message) => {
              if (topic === 'zigbee2mqtt/bridge/devices') {
                  const arr = JSON.parse(message.toString());
                  Object.keys(devices).forEach(key => delete devices[key]);
                  
                  arr.forEach(d => {
                      if (d.friendly_name) {
                          devices[d.friendly_name] = d;
                      }
                  });
                  
                  renderDeviceList();
                  return;
              }
      
              const m = /^zigbee2mqtt\/([^/]+)$/.exec(topic);
              if (!m) return;
              const dev = m[1];
              let parsed;
              try {
                  parsed = JSON.parse(message.toString());
              } catch {
                  parsed = { raw: message.toString() };
              }
      
              devices[dev] = parsed;
              if (!selectedDevice) {
                  selectedDevice = dev;
                  renderDeviceList();
              }
              if (dev === selectedDevice) {
                  renderMessage(parsed, topic);
              }
              
              updateRoomSection(dev, parsed);
          });
      
          function updateRoomSection(deviceName, data) {
              const deviceElement = document.querySelector(`.device[data-id="''${deviceName}"]`);
              if (!deviceElement) return;
              
              const toggle = deviceElement.querySelector('input[type="checkbox"]');
              if (toggle && data.state !== undefined) {
                  toggle.checked = data.state === 'ON';
              }
              
              const brightnessSlider = deviceElement.querySelector('.brightness-slider');
              if (brightnessSlider && data.brightness !== undefined) {
                  brightnessSlider.value = data.brightness;
              }

              if (data.color) {
                  const colorPicker = deviceElement.querySelector('.color-picker');
                  const rgbSlider = deviceElement.querySelector('.rgb-slider');
                  
                  if (colorPicker && data.color.hex) {
                      colorPicker.value = data.color.hex;
                  }
                  
                  if (rgbSlider && data.color.hue !== undefined) {
                      rgbSlider.value = data.color.hue;
                  }
              }
          }
      
          function renderDeviceList() {
              const sel = document.getElementById('deviceSelect');
              const deviceOptions = Object.keys(devices)
                  .filter(name => name !== 'bridge')
                  .map(d => `<option value="''${d}" ''${d === selectedDevice ? 'selected' : ""}>''${d}</option>`)
                  .join("");
                  
              sel.innerHTML = deviceOptions;
          }
      
          document.getElementById('deviceSelect').onchange = e => {
              selectedDevice = e.target.value;
              const msg = devices[selectedDevice];
              if (msg) renderMessage(msg, `zigbee2mqtt/''${selectedDevice}`);
          };
      
          setInterval(() => { tickLastSeen(); }, 1000);
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

  networking.firewall.allowedTCPPorts = [ 13337 ];
  
  yo.scripts = { 
    duckDash = {
      description = "Mobile-first dashboard, unified frontend for zigbee devices, tv remotes and other smart home tech stuff.";
      aliases = [ "dash" ];
      category = "🛖 Home Automation";  
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

