# dotfiles/modules/dashboard/js.nix.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ javascript for dashboard
  lib, 
  config,
  pkgs,
  ...
}: let 

  # 🦆 says ⮞ generate status cards configuration
  enabledCards = lib.filterAttrs (_: card: card.enable) config.house.dashboard.statusCards;
  
  # 🦆 says ⮞ convert Nix cards to JavaScript object
  cardsConfigJson = builtins.toJSON (lib.mapAttrs (name: card: {
    inherit name;
    title = card.title;
    group = card.group or "default";
    icon = card.icon;
    color = card.color;
    theme = card.theme or "neon";
    fileName = builtins.baseNameOf card.filePath;
    jsonField = card.jsonField;
    format = card.format;
    detailsJsonField = card.detailsJsonField or null;
    detailsFormat = card.detailsFormat or "";
    details = card.details or "";
    defaultDetails = card.defaultDetails or "";
    defaultValue = card.defaultValue or "--";
    chart = card.chart or false;
    historyField = card.historyField or "history";
    on_click_action = card.on_click_action or [];
  }) enabledCards);

  # 🦆 says ⮞ generate enabled cards array
  enabledCardsJson = builtins.toJSON (lib.attrNames enabledCards);

  jScript = {    
    rooms = {
      slidingRoomsJS = ''
        let currentOpenRoom = null;
        
        function playTemperatureChangeSound() {
            try {
                const audioContext = new (window.AudioContext || window.webkitAudioContext)();
                const oscillator = audioContext.createOscillator();
                const gainNode = audioContext.createGain();
        
                oscillator.connect(gainNode);
                gainNode.connect(audioContext.destination);
        
                oscillator.type = 'sine';
                oscillator.frequency.setValueAtTime(600, audioContext.currentTime);
                oscillator.frequency.linearRampToValueAtTime(400, audioContext.currentTime + 0.2);
        
                gainNode.gain.setValueAtTime(0.1, audioContext.currentTime);
                gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + 0.2);
        
                oscillator.start(audioContext.currentTime);
                oscillator.stop(audioContext.currentTime + 0.2);
            } catch (e) {
                console.log('🦆 No audio support for temperature changes');
            }
        }        
         
        function openRoomDevicesPanel(roomId, roomName) {
            console.log('🦆 Opening devices panel for room:', roomId, roomName);
            
            currentOpenRoom = roomId;
            
            document.getElementById('panelRoomName').textContent = roomName.toUpperCase();
            
            const roomEl = document.getElementById('room-' + roomId);
            const roomIcon = roomEl.querySelector('.room-icon').className;
            const iconClass = roomIcon.match(/mdi-([^ ]+)/)[1];
            document.getElementById('panelRoomIcon').className = 'mdi mdi-' + iconClass + ' panel-room-icon';
            
            populateRoomDevices(roomId);
            
            const panel = document.getElementById('devicesSlidePanel');
            const backdrop = document.getElementById('panelBackdrop');
            
            panel.classList.add('open');
            backdrop.classList.add('active');
            
            document.body.style.overflow = 'hidden';
            
            playPanelOpenSound();
        }
        
        function closeRoomDevicesPanel() {
            console.log('🦆 Closing devices panel');            
            const panel = document.getElementById('devicesSlidePanel');
            const backdrop = document.getElementById('panelBackdrop');
            
            panel.classList.remove('open');
            backdrop.classList.remove('active');
            
            document.body.style.overflow = "";
            
            currentOpenRoom = null;
            
            playPanelCloseSound();
        }
        
        function populateRoomDevices(roomId) {
            const container = document.getElementById('panelDevicesContainer');
            container.innerHTML = "";
            
            const deviceMappings = window.roomDeviceMappings[roomId] || [];
            
            if (deviceMappings.length === 0) {
                container.innerHTML = `
                    <div class="no-devices-message">
                        <i class="fas fa-lightbulb" style="font-size: 4rem; opacity: 0.3;"></i>
                        <p>No devices in this room</p>
                    </div>
                `;
                return;
            }
            
            deviceMappings.forEach(deviceInfo => {
                const deviceId = deviceInfo.id;
                const friendlyName = deviceInfo.friendly_name;
                let deviceData = window.devices[deviceInfo.friendly_name] || 
                                 window.devices[deviceId] || 
                                 {};
                

                const supportsColor = deviceData.supports_color || false;
                const supportsTemperature = deviceData.supports_temperature || false;
                const deviceColor = deviceData.color?.hex || '#ffffff';
                const deviceTemperature = deviceData.color_temp || 153; // Default mired value
                const isOn = deviceData.state === 'ON';
                const brightness = deviceData.brightness || 100;
                
                let deviceIcon = deviceData.icon || "mdi:lightbulb";
                let iconClass = "";
                if (deviceIcon.startsWith("mdi:")) {
                    iconClass = "mdi mdi-" + deviceIcon.substring(4);
                } else if (deviceIcon.startsWith("fas ")) {
                    iconClass = deviceIcon;
                } else {
                    iconClass = "fas fa-lightbulb"; // Default icon
                }
                
                const deviceEl = document.createElement('div');
                deviceEl.className = `panel-device ''${isOn ? 'on' : ""}`;
                deviceEl.dataset.deviceId = deviceId;
                
                deviceEl.style.cursor = 'pointer';
                
                if (isOn && deviceColor) {
                    deviceEl.style.setProperty('--device-color', deviceColor);
                    const rgb = hexToRgb(deviceColor);
                    if (rgb) {
                        deviceEl.style.setProperty('--device-color-rgb', `''${rgb.r}, ''${rgb.g}, ''${rgb.b}`);
                    }
                }
                
                deviceEl.innerHTML = `
                    <div class="panel-device-header">
                        <div class="panel-device-icon-name">
                            <i class="''${iconClass} panel-device-icon"></i>
                            <div class="panel-device-name">''${friendlyName || deviceId}</div>
                        </div>
                        <label class="panel-device-toggle">
                            <input type="checkbox" class="device-toggle-checkbox" ''${isOn ? 'checked' : ""}>
                            <span class="panel-device-toggle-slider"></span>
                        </label>
                    </div>
                    <div class="panel-device-controls">
                        ''${supportsColor ? `
                        <div class="panel-color-control">
                            <input type="color" class="panel-color-picker" value="''${deviceColor}" 
                                   ''${!isOn ? 'disabled' : ""}>
                            <span class="panel-color-label">Color</span>
                        </div>
                        ` : ""}
                        ''${supportsTemperature ? `
                        <div class="panel-temperature-control">
                            <div class="panel-temperature-label">
                                <span>Temperature</span>
                                <span class="panel-temperature-value">''${deviceTemperature} mired</span>
                            </div>
                            <input type="range" class="panel-temperature-slider" min="153" max="500" 
                                   value="''${deviceTemperature}" ''${!isOn ? 'disabled' : ""}
                                   title="153 mired = 6500K (cool), 500 mired = 2000K (warm)">
                        </div>
                        ` : ""}
                        <div class="panel-brightness-control">
                            <div class="panel-brightness-label">
                                <span>Brightness</span>
                                <span class="panel-brightness-value">''${brightness}%</span>
                            </div>
                            <input type="range" class="panel-brightness-slider" min="0" max="100" 
                                   value="''${brightness}" ''${!isOn ? 'disabled' : ""}>
                        </div>
                    </div>
                `;
                
                const toggle = deviceEl.querySelector('.device-toggle-checkbox');
                const colorPicker = deviceEl.querySelector('.panel-color-picker');
                const temperatureSlider = deviceEl.querySelector('.panel-temperature-slider');
                const brightnessSlider = deviceEl.querySelector('.panel-brightness-slider');
                
                deviceEl.addEventListener('click', function(e) {
                    if (e.target.closest('.panel-device-controls') || 
                        e.target.closest('.panel-device-toggle')) {
                        return;
                    }
                    
                    closeRoomDevicesPanel();
                    
                    const deviceTab = document.querySelector('.nav-tab[data-page="1"]');
                    if (deviceTab) {
                        deviceTab.click();
                        
                        setTimeout(() => {
                            const deviceSelect = document.getElementById('deviceSelect');
                            if (deviceSelect) {
                                deviceSelect.value = deviceId;
                                deviceSelect.dispatchEvent(new Event('change'));
                            }
                        }, 100);
                    }
                });
                
                toggle.addEventListener('change', function(e) {
                    e.stopPropagation();
                    setDeviceState(deviceId, this.checked);
                });
                
                if (colorPicker) {
                    colorPicker.addEventListener('input', function(e) {
                        e.stopPropagation();
                        setDeviceColor(deviceId, this.value);
                    });
                }
                
                if (temperatureSlider) {
                    temperatureSlider.addEventListener('input', function(e) {
                        e.stopPropagation();
                        const value = this.value;
                        setDeviceTemperature(deviceId, value);
                        this.closest('.panel-temperature-control').querySelector('.panel-temperature-value').textContent = value + ' mired';
                    });
                }
                
                if (brightnessSlider) {
                    brightnessSlider.addEventListener('input', function(e) {
                        e.stopPropagation();
                        const value = this.value;
                        setDeviceBrightness(deviceId, value);
                        deviceEl.querySelector('.panel-brightness-value').textContent = value + '%';
                    });
                }
                
                container.appendChild(deviceEl);
            });
        }
        

        
        function setDeviceState(deviceId, state) {
            const command = { state: state ? 'ON' : 'OFF' };
            if (window.sendCommand) {
                window.sendCommand(deviceId, command);
            }
        }
        
        function hexToRgb(hex) {
            const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
            return result ? {
                r: parseInt(result[1], 16),
                g: parseInt(result[2], 16),
                b: parseInt(result[3], 16)
            } : null;
        }
        
        function playPanelOpenSound() {
            try {
                const audioContext = new (window.AudioContext || window.webkitAudioContext)();
                const oscillator = audioContext.createOscillator();
                const gainNode = audioContext.createGain();
                
                oscillator.connect(gainNode);
                gainNode.connect(audioContext.destination);
                
                oscillator.type = 'sine';
                oscillator.frequency.setValueAtTime(500, audioContext.currentTime);
                oscillator.frequency.exponentialRampToValueAtTime(800, audioContext.currentTime + 0.1);
                
                gainNode.gain.setValueAtTime(0.2, audioContext.currentTime);
                gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + 0.3);
                
                oscillator.start(audioContext.currentTime);
                oscillator.stop(audioContext.currentTime + 0.3);
            } catch (e) {
                console.log('🦆 Audio not supported');
            }
        }
        
        function playPanelCloseSound() {
            try {
                const audioContext = new (window.AudioContext || window.webkitAudioContext)();
                const oscillator = audioContext.createOscillator();
                const gainNode = audioContext.createGain();
                
                oscillator.connect(gainNode);
                gainNode.connect(audioContext.destination);
                
                oscillator.type = 'sine';
                oscillator.frequency.setValueAtTime(800, audioContext.currentTime);
                oscillator.frequency.exponentialRampToValueAtTime(400, audioContext.currentTime + 0.2);
                
                gainNode.gain.setValueAtTime(0.2, audioContext.currentTime);
                gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + 0.2);
                
                oscillator.start(audioContext.currentTime);
                oscillator.stop(audioContext.currentTime + 0.2);
            } catch (e) {
                console.log('🦆 Audio not supported');
            }
        }
        
        // 🦆 says ⮞ Update room devices when MQTT updates
        function updateRoomDevicesInPanel() {
            if (currentOpenRoom) {
                populateRoomDevices(currentOpenRoom);
            }
        }
        
        // 🦆 says ⮞ make global
        window.openRoomDevicesPanel = openRoomDevicesPanel;
        window.closeRoomDevicesPanel = closeRoomDevicesPanel;
        window.updateRoomDevicesInPanel = updateRoomDevicesInPanel;
      ''; 
    
      # ROOMCONTROLJS   
      roomControlJs = ''         
        function updateRoomStats() {
            console.log('🦆 Updating room stats...');         
            if (!window.roomDeviceMappings || !window.devices) return;
            
            Object.entries(window.roomDeviceMappings).forEach(([roomName, deviceMappings]) => {
                const roomEl = document.getElementById('room-' + roomName);
                if (!roomEl) return;
                
                let onCount = 0;
                let totalBrightness = 0;
                let deviceCount = 0;
                
                deviceMappings.forEach(deviceInfo => {
                    const deviceId = deviceInfo.id;
                    const friendlyName = deviceInfo.friendly_name;
                    
                    let deviceData = window.devices[friendlyName] || window.devices[deviceId];
                    
                    if (deviceData) {
                        deviceCount++;               
                        if (deviceData.state === 'ON') {
                            onCount++;
                            
                            if (deviceData.brightness) {
                                let brightness = deviceData.brightness;
                                if (brightness > 100) {
                                    brightness = Math.round((brightness / 254) * 100);
                                }
                                totalBrightness += brightness;
                            }
                        }
                    }
                });
                
                const onCountSpan = roomEl.querySelector('.room-on-devices');
                if (onCountSpan) {
                    onCountSpan.textContent = `''${onCount} on`;
                }
                
                const deviceCountSpan = roomEl.querySelector('.room-devices-count');
                if (deviceCountSpan) {
                    deviceCountSpan.textContent = `''${deviceCount} devices`;
                }
                
                let avgBrightness = 0; // Default to 0
                
                if (onCount > 0) {
                    avgBrightness = Math.round(totalBrightness / onCount);
                }
                
                avgBrightness = Math.max(0, Math.min(100, avgBrightness));
                
                const brightnessSlider = roomEl.querySelector('.room-brightness');
                const brightnessValue = roomEl.querySelector('.brightness-value');
                
                if (brightnessSlider) {
                    brightnessSlider.value = avgBrightness;
                    brightnessSlider.style.display = onCount > 0 ? 'block' : 'none';
                }
                
                if (brightnessValue) {
                    brightnessValue.textContent = `''${avgBrightness}%`;
                }
                
                if (onCount > 0) {
                    roomEl.classList.add('on');
                    roomEl.classList.remove('off');
                } else {
                    roomEl.classList.add('off');
                    roomEl.classList.remove('on');
                }
            });            
            console.log('🦆 Room stats updated!');
        }
        
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
          
          const command = { brightness: Math.round((parseInt(brightness) / 100) * 254) };
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
            
                    let deviceData = null;
                    if (deviceInfo?.friendly_name) {
                        deviceData = window.devices[deviceInfo.friendly_name];
    
                        if (!deviceData) {
                            const lowerName = deviceInfo.friendly_name.toLowerCase();
                            const foundKey = Object.keys(window.devices).find(key => 
                                key.toLowerCase() === lowerName
                            );
                            if (foundKey) {
                                deviceData = window.devices[foundKey];
                            }
                        }
                    }

                    if (!deviceData) {
                        deviceData = window.devices[deviceId];
                    }

                
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
            updateRoomStats();
            console.log('🦆 Room controls updated');
        }
        
        function updateDeviceInRoom(deviceId, data) {
            let deviceEl = null;    
            deviceEl = document.getElementById('device-' + deviceId);
    
            if (!deviceEl) {
                deviceEl = document.querySelector(`[data-device="''${deviceId}"]`);
            }
    
            if (!deviceEl && window.deviceMappings) {
                const deviceInfo = Object.values(window.deviceMappings).find(d => d.id === deviceId);
                if (deviceInfo && deviceInfo.friendly_name) {
                    const friendlyName = deviceInfo.friendly_name;
                    const allElements = document.querySelectorAll('.device-name');
                    for (const el of allElements) {
                        if (el.textContent.trim() === friendlyName) {
                            deviceEl = el.closest('.device');
                            break;
                        }
                    }
                }
            }
    
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
        
     
        
        function initRoomControlsWithSlide() {
            console.log('🦆 Initializing room controls with horizontal slide-to-brightness!');
            document.querySelectorAll('.room').forEach(roomEl => {
                let isSliding = false;
                let startX = 0;
                let startBrightness = 0;
                let touchStartX = 0;
                
                roomEl.addEventListener('mousedown', function(e) {
                    if (!roomEl.classList.contains('on')) return;
                    if (e.target.closest('.collapse-btn')) return;
                    
                    isSliding = true;
                    startX = e.clientX;
                    startBrightness = parseInt(roomEl.querySelector('.room-brightness').value) || 100;
                    
                    roomEl.classList.add('brightness-sliding');
                    roomEl.classList.add('brightness-active');
                    
                    updateBrightnessDisplay(roomEl, startBrightness);
                    
                    e.preventDefault();
                    e.stopPropagation();
                });
                
                roomEl.addEventListener('touchstart', function(e) {
                    if (!roomEl.classList.contains('on')) return;
                    if (e.target.closest('.collapse-btn')) return;
                    
                    isSliding = true;
                    touchStartX = e.touches[0].clientX;
                    startBrightness = parseInt(roomEl.querySelector('.room-brightness').value) || 100;
                    
                    roomEl.classList.add('brightness-sliding');
                    roomEl.classList.add('brightness-active');
                    
                    updateBrightnessDisplay(roomEl, startBrightness);
                    
                    e.preventDefault();
                    e.stopPropagation();
                }, { passive: false });
                
                document.addEventListener('mousemove', function(e) {
                    if (!isSliding) return;
                    
                    const deltaX = e.clientX - startX;
                    const newBrightness = calculateNewBrightness(startBrightness, deltaX);
                    
                    updateRoomBrightness(roomEl, newBrightness);
                    updateBrightnessDisplay(roomEl, newBrightness);
                    
                    e.preventDefault();
                });
                
                document.addEventListener('touchmove', function(e) {
                    if (!isSliding) return;
                    
                    const deltaX = e.touches[0].clientX - touchStartX;
                    const newBrightness = calculateNewBrightness(startBrightness, deltaX);
                    
                    updateRoomBrightness(roomEl, newBrightness);
                    updateBrightnessDisplay(roomEl, newBrightness);
                    
                    e.preventDefault();
                }, { passive: false });
                
                function endSlide() {
                    if (!isSliding) return;
                    
                    isSliding = false;
                    roomEl.classList.remove('brightness-sliding');
                    roomEl.classList.remove('brightness-active');
                    
                    setTimeout(() => {
                        const display = roomEl.querySelector('.brightness-value-display');
                        if (display) display.style.opacity = '0';
                    }, 500);
                    
                    playBrightnessSound();
                }
                
                document.addEventListener('mouseup', endSlide);
                document.addEventListener('touchend', endSlide);
                document.addEventListener('touchcancel', endSlide);
                document.addEventListener('mouseleave', function(e) {
                    if (isSliding) endSlide();
                });
            });
            
            function calculateNewBrightness(startBrightness, deltaX) {
                const brightnessChange = Math.round(deltaX * 0.5);
                let newBrightness = startBrightness + brightnessChange;
                
                newBrightness = Math.max(0, Math.min(100, newBrightness));          
                return newBrightness;
            }
        
            
            function updateRoomBrightness(roomEl, brightness) {
                const roomName = roomEl.getAttribute('data-room');
                const brightnessSlider = roomEl.querySelector('.room-brightness');
                const brightnessValue = roomEl.querySelector('.room-brightness-container .brightness-value');
                const indicator = roomEl.querySelector('.brightness-indicator');
                
                brightnessSlider.value = brightness;
                if (brightnessValue) brightnessValue.textContent = brightness + '%';
                
                if (indicator) {
                    indicator.style.height = brightness + '%';
                }
                
                const currentColor = getComputedStyle(roomEl).getPropertyValue('--room-color') || '#2ecc71';
                const adjustedColor = adjustColorForBrightness(currentColor, brightness);
                roomEl.style.setProperty('--room-color', adjustedColor);
                
                clearTimeout(roomEl._brightnessTimeout);
                roomEl._brightnessTimeout = setTimeout(() => {
                    setRoomBrightness(roomName, brightness);
                }, 150);
            }
            
            function updateBrightnessDisplay(roomEl, brightness) {
                const display = roomEl.querySelector('.brightness-value-display');
                if (display) {
                    display.textContent = brightness + '%';
                    display.style.opacity = '1';
                }
            }
            
            function adjustColorForBrightness(color, brightness) {
                const factor = brightness / 100;
                return color.replace('rgb(', 'rgba(').replace(')', `, ''${0.3 + factor * 0.7})`);
            }
            
            function playBrightnessSound() {
                try {
                    const audioContext = new (window.AudioContext || window.webkitAudioContext)();
                    const oscillator = audioContext.createOscillator();
                    const gainNode = audioContext.createGain();
                    
                    oscillator.connect(gainNode);
                    gainNode.connect(audioContext.destination);
                    
                    oscillator.type = 'sine';
                    oscillator.frequency.setValueAtTime(500, audioContext.currentTime);
                    
                    gainNode.gain.setValueAtTime(0.1, audioContext.currentTime);
                    gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + 0.1);
                    
                    oscillator.start(audioContext.currentTime);
                    oscillator.stop(audioContext.currentTime + 0.1);
                } catch (e) {
                    console.log('🦆 No audio support for brightness changes');
                }
            }
            
            document.querySelectorAll('.collapse-btn').forEach(btn => {
                btn.addEventListener('click', function(e) {
                    e.stopPropagation();
                    const roomEl = this.closest('.room');
                    const devicesEl = roomEl.querySelector('.devices');
                    
                    this.style.transform = 'rotate(180deg)';
                    setTimeout(() => {
                        devicesEl.classList.toggle('hidden');
                        this.textContent = devicesEl.classList.contains('hidden') ? '▸' : '▾';
                        this.style.transform = "";
                    }, 300);
                    
                    // playSuccessSound();
                });
            });
            
            document.querySelectorAll('.device-toggle').forEach(toggle => {
                toggle.addEventListener('change', function() {
                    const deviceEl = this.closest('.device');
                    const deviceId = deviceEl.getAttribute('data-device');
                    
                    deviceEl.classList.add('loading');
                    setTimeout(() => {
                        if (window.sendCommand) {
                            window.sendCommand(deviceId, { state: this.checked ? 'ON' : 'OFF' });
                        }
                        
                        deviceEl.classList.toggle('on', this.checked);
                        deviceEl.classList.toggle('off', !this.checked);
                        deviceEl.classList.remove('loading');
                        
                        const brightnessSlider = deviceEl.querySelector('.device-brightness');
                        if (brightnessSlider) {
                            brightnessSlider.style.display = this.checked ? 'block' : 'none';
                        }
                        
                        // playSuccessSound();
                        updateRoomColors();
                    }, 300);
                });
            });
            
            document.querySelectorAll('.device-brightness').forEach(slider => {
                slider.addEventListener('input', function() {
                    const deviceEl = this.closest('.device');
                    const deviceId = deviceEl.getAttribute('data-device');
                    
                    clearTimeout(this._timeout);
                    this._timeout = setTimeout(() => {
                        setDeviceBrightness(deviceId, this.value);
                        
                        updateRoomBrightnessFromDevices(deviceEl.closest('.room'));
                    }, 200);
                });
            });
            
            document.querySelectorAll('.color-picker').forEach(picker => {
                picker.addEventListener('input', function() {
                    const deviceEl = this.closest('.device');
                    const deviceId = deviceEl.getAttribute('data-device');
                    
                    deviceEl.style.animation = 'none';
                    setTimeout(() => {
                        deviceEl.style.animation = 'deviceAppear 0.5s ease-out';
                        setDeviceColor(deviceId, this.value);
                        
                        deviceEl.style.setProperty('--device-color', this.value);
                        deviceEl.classList.add('on');
                        
                        updateRoomColors();
                        playQuackSound();
                    }, 10);
                });
            });
            
    
            function updateRoomBrightnessFromDevices(roomEl) {
                const deviceBrightnesses = Array.from(roomEl.querySelectorAll('.device.on .device-brightness'))
                    .map(slider => parseInt(slider.value))
                    .filter(value => !isNaN(value));
                
                if (deviceBrightnesses.length > 0) {
                    const avgBrightness = Math.round(deviceBrightnesses.reduce((a, b) => a + b) / deviceBrightnesses.length);
                    const roomSlider = roomEl.querySelector('.room-brightness');
                    const roomValue = roomEl.querySelector('.room-brightness-container .brightness-value');
                    
                    if (roomSlider && roomValue) {
                        roomSlider.value = avgBrightness;
                        roomValue.textContent = avgBrightness + '%';
                    }
                }
            }
            
            console.log('🦆 Slide-to-brightness controls initialized! 🦆✨');
        }
        
        window.initRoomControls = initRoomControlsWithSlide;
            
        window.updateDeviceUIFromMQTT = updateDeviceUIFromMQTT;
        window.updateAllRoomControls = updateAllRoomControls;
        window.syncRoomTogglesFromState = syncRoomTogglesFromState;
        window.setInitialRoomCollapse = setInitialRoomCollapse;
      '';
        
    };  
    
        
    animations = {
      thief = ''
        class DuckStealer {
            constructor() {
                this.idleTime = 0;
                this.idleThreshold = 10000; // 🦆 says ⮞ 10 seconds idle
                this.duckActive = false;
                this.animationDuration = 8000; // 🦆 says ⮞ total animation time
                this.interval = null;
        
                this.init();
            }
    
            init() {
                const duckContainer = document.createElement('div');
                duckContainer.id = 'duck-container';
                document.body.appendChild(duckContainer);
        
                // 🦆 says ⮞ reset idle timer on user activity
                this.resetIdleTimer();
        
                // 🦆 says ⮞ listen 4 user activity
                ['mousemove', 'keydown', 'click', 'scroll', 'touchstart'].forEach(event => {
                    document.addEventListener(event, () => {
                        this.resetIdleTimer();
                        // 🦆 says ⮞ if duck is active - make it run away on user activity
                       if (this.duckActive) {
                            this.duckRunAway();
                        }
                    });
                });
        
                // 🦆 says ⮞ start timer
                this.startIdleTimer();
            }
    
            resetIdleTimer() {
                this.idleTime = 0;
                if (this.duckActive) {
                    clearInterval(this.interval);
                    this.duckRunAway();
                }
            }
    
            startIdleTimer() {
                setInterval(() => {
                    this.idleTime += 1000;
                    if (this.idleTime >= this.idleThreshold && !this.duckActive) {
                        this.activateDuck();
                    }
                }, 1000);
            }
    
            activateDuck() {
                this.duckActive = true;
                const duckContainer = document.getElementById('duck-container');
                const h3 = document.querySelector('.room-controls-section h3');
        
                if (!h3) return;
        
                const duck = document.createElement('div');
                duck.className = 'duck walking';
                duck.innerHTML = '🦆';
                duck.style.bottom = '-50px';
                duck.style.right = '-50px';
                duckContainer.appendChild(duck);
        
                // 🦆 says ⮞  show duck container
                duckContainer.style.bottom = '0px';
                duckContainer.style.right = '0px';
        
                // 🦆 says ⮞ phase 1 walk to header
                setTimeout(() => {
                    const h3Rect = h3.getBoundingClientRect();
                    const duckRect = duck.getBoundingClientRect();
            
                    // 🦆 says ⮞  position duck near header
                    duck.style.bottom = `''${window.innerHeight - h3Rect.top + 20}px`;
                    duck.style.right = `''${window.innerWidth - h3Rect.left - 50}px`;
            
                    // 🦆 says ⮞ phase 2 pick up header
                    setTimeout(() => {
                        duck.classList.remove('walking');
                
                        // 🦆 says ⮞ clone header 4 steal
                        const stolenH3 = h3.cloneNode(true);
                        stolenH3.className = 'stolen-h3';
                        stolenH3.style.bottom = '15px';
                        stolenH3.style.right = '40px';
                        duck.appendChild(stolenH3);
                
                        // 🦆 says ⮞  effect to original header
                        h3.classList.add('h3-stolen');
                
                        // 🦆 says ⮞ phase 3 steal header yo
                        setTimeout(() => {
                            duck.classList.add('walking');
                    
                            // 🦆 says ⮞  Walk away innocently...
                            duck.style.bottom = '-100px';
                            duck.style.right = '-100px';
                    
                            // 🦆 says ⮞  phase 4 cleanup
                            setTimeout(() => {
                                duck.remove();
                                duckContainer.style.bottom = '-100px';
                                duckContainer.style.right = '-100px';
                                h3.classList.remove('h3-stolen');
                                this.duckActive = false;
                            }, 2000);
                        }, 1000);
                    }, 1500);
                }, 1000);
            }
    
            duckRunAway() {
                const duck = document.querySelector('.duck');
                if (!duck) return;
        
                duck.classList.add('walking');
                duck.style.bottom = '-100px';
                duck.style.right = '-100px';
        
                // 🦆 says ⮞ remove stolen header
                const stolenH3 = document.querySelector('.stolen-h3');
                if (stolenH3) stolenH3.remove();
        
                // 🦆 says ⮞  restore orig header
                const h3 = document.querySelector('.room-controls-section h3');
                if (h3) h3.classList.remove('h3-stolen');
        
                setTimeout(() => {
                    duck.remove();
                    const duckContainer = document.getElementById('duck-container');
                    duckContainer.style.bottom = '-100px';
                    duckContainer.style.right = '-100px';
                    this.duckActive = false;
                }, 1000);
            }
        }

        document.addEventListener('DOMContentLoaded', () => {
            new DuckStealer();
        }); 
      '';  
    };
    
    statusCards = ''
      // 🦆 says ⮞ Status Cards Configuration
      window.statusCardsConfig = ${cardsConfigJson};
      window.enabledCards = ${enabledCardsJson};
      
      // 🦆 says ⮞ Chart functions
      function loadChartJS() {
        return new Promise((resolve, reject) => {
          if (typeof Chart !== 'undefined') {
            resolve();
            return;
          }
          
          const script = document.createElement('script');
          script.src = 'https://cdn.jsdelivr.net/npm/chart.js';
          script.onload = resolve;
          script.onerror = reject;
          document.head.appendChild(script);
        });
      }

      // 🦆 says ⮞ Enhanced chart rendering
      function renderEnhancedChart(cardId, historyData, color) {
        const canvas = document.getElementById('status-' + cardId + '-chart');
        if (!canvas) return;
        
        if (canvas.chartInstance) {
          canvas.chartInstance.destroy();
          canvas.classList.add('fade-out');
          setTimeout(() => canvas.classList.remove('fade-out'), 300);
        }
        
        const ctx = canvas.getContext('2d');
        const gradient = ctx.createLinearGradient(0, 0, 0, canvas.height);
        gradient.addColorStop(0, color + '80');
        gradient.addColorStop(0.7, color + '20');
        gradient.addColorStop(1, color + '05');
        
        const borderGradient = ctx.createLinearGradient(0, 0, canvas.width, 0);
        borderGradient.addColorStop(0, '#00e5ff');
        borderGradient.addColorStop(0.5, color);
        borderGradient.addColorStop(1, '#ff00ff');
        
        canvas.chartInstance = new Chart(canvas, {
          type: 'line',
          data: {
            labels: historyData.map((_, i) => i),
            datasets: [{
              data: historyData,
              borderColor: borderGradient,
              backgroundColor: gradient,
              borderWidth: 3,
              tension: 0.4,
              pointRadius: 4,
              pointBackgroundColor: color,
              pointBorderColor: '#fff',
              pointBorderWidth: 2,
              pointHoverRadius: 8,
              pointHoverBackgroundColor: '#fff',
              pointHoverBorderColor: color,
              pointHoverBorderWidth: 3,
              fill: true,
              cubicInterpolationMode: 'monotone'
            }]
          },
          options: {
            responsive: true,
            maintainAspectRatio: false,
            animation: {
              duration: 1000,
              easing: 'easeOutQuart',
              onComplete: () => {
                canvas.classList.add('chart-loaded');
              }
            },
            plugins: {
              legend: { display: false },
              tooltip: {
                backgroundColor: 'rgba(0, 0, 0, 0.8)',
                titleColor: '#fff',
                bodyColor: color,
                borderColor: color,
                borderWidth: 1,
                cornerRadius: 8,
                displayColors: false,
                callbacks: {
                  label: function(context) {
                    return cardId + ': ' + context.parsed.y.toFixed(2);
                  }
                }
              }
            },
            scales: {
              x: { display: false, grid: { display: false } },
              y: { display: false, grid: { color: 'rgba(255, 255, 255, 0.1)', drawBorder: false } }
            }
          }
        });
        
        if (cardId === 'temperature') {
          addChartParticles(canvas, historyData, color);
        }
      }

      // 🦆 says ⮞ Particle effects for charts
      function addChartParticles(canvas, data, color) {
        const particleContainer = document.createElement('div');
        particleContainer.className = 'chart-particles';
        particleContainer.style.cssText = 
          'position: absolute; top: 0; left: 0; width: 100%; height: 100%; pointer-events: none; z-index: 1;';
        
        canvas.parentNode.style.position = 'relative';
        canvas.parentNode.appendChild(particleContainer);
        
        for (let i = 0; i < 10; i++) {
          const particle = document.createElement('div');
          particle.className = 'chart-particle';
          particle.style.cssText = 
            'position: absolute; width: 4px; height: 4px; background: ' + color + 
            '; border-radius: 50%; opacity: 0.6; filter: blur(1px);';
          
          const x = Math.random() * 100;
          const y = Math.random() * 100;
          particle.style.left = x + '%';
          particle.style.top = y + '%';
          
          particle.animate([
            { transform: 'translate(0, 0) scale(1)', opacity: 0.6 },
            { transform: 'translate(' + (Math.random() * 20 - 10) + 'px, ' + 
              (Math.random() * 20 - 10) + 'px) scale(1.5)', opacity: 0.2 }
          ], {
            duration: 2000 + Math.random() * 2000,
            iterations: Infinity,
            direction: 'alternate',
            easing: 'ease-in-out'
          });
          
          particleContainer.appendChild(particle);
        }
      }

      // 🦆 says ⮞ smooth number animation
      function animateNumber(element, start, end, duration) {
        const startTime = performance.now();
        
        function update(currentTime) {
          const elapsed = currentTime - startTime;
          const progress = Math.min(elapsed / duration, 1);
          
          const easeOutQuart = 1 - Math.pow(1 - progress, 4);
          const current = start + (end - start) * easeOutQuart;
          
          element.textContent = current.toFixed(1);
          
          if (progress < 1) {
            requestAnimationFrame(update);
          }
        }
        
        requestAnimationFrame(update);
      }

      function updateCardValueWithAnimation(cardId, value) {
        const element = document.getElementById('status-' + cardId + '-value');
        if (!element) {
          console.error('Card element not found:', 'status-' + cardId + '-value');
          return;
        }
        
        element.classList.add('value-update');
        
        const oldValue = parseFloat(element.textContent) || 0;
        const newValue = parseFloat(value) || 0;
        
        if (oldValue !== newValue) {
          animateNumber(element, oldValue, newValue, 500);
        } else {
          element.textContent = value;
        }
        
        if (cardId === 'temperature') {
          let tempColor;
          if (newValue < 18) tempColor = '#3498db';
          else if (newValue < 22) tempColor = '#2ecc71';
          else if (newValue < 26) tempColor = '#f39c12';
          else tempColor = '#e74c3c';
          
          element.style.color = tempColor;
          element.style.textShadow = '0 0 20px ' + tempColor + ', 0 0 40px ' + tempColor + '40';
        }
        
        setTimeout(() => element.classList.remove('value-update'), 500);
      }

      // 🦆 says ⮞ Update card details
      function updateCardDetails(cardId, details) {
        const element = document.getElementById('status-' + cardId + '-details');
        if (element) {
          element.textContent = details;
          element.classList.add('details-update');
          setTimeout(() => element.classList.remove('details-update'), 300);
        }
      }

      // 🦆 says ⮞ Update card chart
      function updateCardChart(cardId, historyData, color) {
        const canvas = document.getElementById('status-' + cardId + '-chart');
        if (!canvas) return;
        
        if (typeof Chart === 'undefined') {
          loadChartJS().then(() => {
            renderEnhancedChart(cardId, historyData, color);
          });
        } else {
          renderEnhancedChart(cardId, historyData, color);
        }
      }

      // 🦆 says ⮞ Update a single card
      function updateCard(cardName) {
        const config = window.statusCardsConfig[cardName];
        if (!config) {
          console.error('No config for card:', cardName);
          return;
        }
        
        fetch('/' + config.fileName)
          .then(response => {
            if (!response.ok) throw new Error('HTTP ' + response.status);
            return response.json();
          })
          .then(data => {
            console.log('🦆 Card data for', cardName, ':', data);
            
            const value = data[config.jsonField];
            if (value === undefined) {
              throw new Error(`Field ''${config.jsonField} not found in JSON`);
            }
            
            const formattedValue = config.format.replace(/\{value\}/g, value);
            updateCardValueWithAnimation(cardName, formattedValue);
            
            if (config.detailsJsonField && data[config.detailsJsonField] !== undefined) {
              const detailsValue = data[config.detailsJsonField];
              const formattedDetails = config.detailsFormat.replace(/\{value\}/g, detailsValue);
              updateCardDetails(cardName, formattedDetails);
            } else if (config.details) {
              updateCardDetails(cardName, config.details);
            } else {
              updateCardDetails(cardName, config.defaultDetails);
            }
            
            if (config.chart && data[config.historyField]) {
              const historyData = data[config.historyField];
              if (Array.isArray(historyData) && historyData.length > 0) {
                updateCardChart(cardName, historyData, config.color);
              }
            }
          })
          .catch(error => {
            console.error('🦆 Error updating card', cardName, ':', error);
            updateCardValueWithAnimation(cardName, config.defaultValue);
            updateCardDetails(cardName, config.defaultDetails);
          });
      }

      // 🦆 says ⮞ Update all cards
      function updateAllCards() {
        console.log('🦆 Updating all status cards');
        window.enabledCards.forEach(cardName => {
          updateCard(cardName);
        });
      }

      // 🦆 says ⮞ Handle card click for MQTT automation
      function handleCardClick(cardName) {
        const config = window.statusCardsConfig[cardName];
        if (!config) {
          console.error('No config for card:', cardName);
          return;
        }  
        console.log('🦆 Card clicked:', cardName);
  
        // 🦆 says ⮞ publish click message to backend
        const topic = `zigbee2mqtt/dashboard/card/''${cardName}/click`;
        const message = JSON.stringify({ 
          action: 'click', 
          card: cardName, 
          timestamp: new Date().toISOString(),
          config: {
            hasActions: config.on_click_action && config.on_click_action.length > 0,
            title: config.title
          }
        });
  
        if (window.client && window.client.connected) {
          window.client.publish(topic, message);
          console.log('🦆 Published card click to MQTT:', topic, message);
    
        } else {
          console.error('🦆 MQTT client not connected');
          showNotification('Not connected to home automation', 'error');
        }
      }

      // 🦆 says ⮞ init cards with click handlers
      function initStatusCards() {
        console.log('🦆 Initializing status cards');
        
        window.enabledCards.forEach(cardName => {
          const cardElement = document.querySelector('.card[data-card="' + cardName + '"]');
          if (cardElement) {
            cardElement.addEventListener('click', () => handleCardClick(cardName));
            cardElement.style.cursor = 'pointer';
          }
        });
        
        updateAllCards();
        
        setInterval(updateAllCards, 30000);
        
        console.log('🦆 Status cards initialized');
      }

      // 🦆 says ⮞ make these func global!
      window.updateCard = updateCard;
      window.updateAllCards = updateAllCards;
      window.updateCardValue = updateCardValueWithAnimation;
      window.updateCardDetails = updateCardDetails;
      window.updateCardChart = updateCardChart;
      window.initStatusCards = initStatusCards;
    '';
  };
  
in {
  jScript = jScript;
}
