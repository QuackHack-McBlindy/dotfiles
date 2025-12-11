# dotfiles/modules/myHouse.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ my house - qwack 
  config, # 🦆 says ⮞ more info ⮞ https://quackhack-mcblindy.github.io/blog/house/index.html
  lib,
  self,
  pkgs,
  ...
} : let # 🦆 say ⮞ load dash pages css files
  strip = text:
    builtins.replaceStrings [ "/*" "*/" ] [ "" "" ] text;

  css = {
    health   = builtins.readFile ./themes/css/health.css;
    chat     = builtins.readFile ./themes/css/chat.css;
    qwackify =  builtins.readFile ./themes/css/qwackify.css;
  };

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
  mqttAuth = "-u ${config.house.zigbee.mosquitto.username} -P $(cat ${config.house.zigbee.mosquitto.passwordFile})"; 
  mqttBroker =
    if mqttHostip == config.this.host.ip
    then "localhost"
    else mqttHostip;

  # 🦆 duck say ⮞ icon map
  icons = {
    light = {
      ceiling         = "mdi:ceiling-light";
      strip           = "mdi:light-strip";
      spotlight       = "mdi:spotlight";
      bulb            = "mdi:lightbulb";
      bulb_color      = "mdi:lightbulb-multiple";
      desk            = "mdi:desk-lamp";
      floor           = "mdi:floor-lamp";
      wall            = "mdi:wall-sconce-round";
      chandelier      = "mdi:chandelier";
      pendant         = "mdi:vanity-light";
      nightlight      = "mdi:lightbulb-night";
      strip_rgb       = "mdi:led-strip-variant";
      reading         = "mdi:book-open-variant";
      candle          = "mdi:candle";
      ambient         = "mdi:weather-night";
    };
    sensor = {
      motion          = "mdi:motion-sensor";
      smoke           = "mdi:smoke-detector";
      water           = "mdi:water";
      contact         = "mdi:door";
      temperature     = "mdi:thermometer";
      humidity        = "mdi:water-percent";
    };
    remote            = "mdi:remote";
    outlet            = "mdi:power-socket-eu";
    dimmer            = "mdi:toggle-switch";
    pusher            = "mdi:gesture-tap-button";
    blinds            = "mdi:blinds";
  };
  
  health = lib.mapAttrs (hostName: _: {
    enable = true;
    description = "Health Check: ${hostName}";
    topic = "zigbee2mqtt/health/${hostName}";
    actions = [
      {
         type = "shell";
         command = ''
           mkdir -p /var/lib/zigduck/health
           touch /var/lib/zigduck/health/${hostName}.json
           echo "$MQTT_PAYLOAD" > /var/lib/zigduck/health/${hostName}.json
        '';
       }
     ];
  }) self.nixosConfigurations;
  
in { # 🦆 duck say ⮞ qwack
  house = {
    # 🦆 says ⮞ ROOM CONFIGURATION
    rooms = {
      bedroom.icon    = "mdi:bed";
      hallway.icon    = "mdi:door";
      kitchen.icon    = "mdi:food-fork-drink";
      livingroom.icon = "mdi:sofa";
      wc.icon         = "mdi:toilet";
      other.icon      = "mdi:misc";
    };  

    # 🦆 says ⮞ DASHBOARD CONFIOGURATION 
    dashboard = {
       # 🦆 says ⮞  safety firzt!
      passwordFile = config.sops.secrets.api.path;
      
      # 🦆 says ⮞  home page information cards
      statusCards = {
        # 🦆 says ⮞ Monero USD price ticker
        xmr = {
          enable = true;
          title = "XMR";
          icon = "fab fa-monero";
          color = "#ff6600";
          filePath = "/var/lib/zigduck/xmr.json";
          jsonField = "current_price";
          format = "\${value}";
          detailsJsonField = "24h_change";
          detailsFormat = "24h: {value}%";
        };

        # 🦆 says ⮞ Bitcoin USD price ticker
        btc = {
          enable = true;
          title = "BTC";
          icon = "fab fa-bitcoin";
          color = "#ff6600";
          filePath = "/var/lib/zigduck/btc.json";
          jsonField = "current_price";
          format = "\${value}";
          detailsJsonField = "24h_change";
          detailsFormat = "24h: {value}%";
        };

        # 🦆 says ⮞ kWh/price and energy usage ticker
        energy = {
          enable = true;
          title = "Energy";
          icon = "fas fa-bolt";
          color = "#4caf50";
          filePath = "/var/lib/zigduck/energy.json";          
          jsonField = "current_price";
          format = "{value} SEK/kWh";          
          detailsJsonField = "monthly_usage";
          detailsFormat = "Usage: {value} kWh";
        };

      };


    # 🦆 says ⮞ DASHBOARD PAGES (tabs)      
      pages = {        
      # 🦆 says ⮞ system-wide health monitoring page
        "4" = {
          icon = "fas fa-notes-medical";
          title = "health";
          # 🦆 says ⮞ symlink directory to webserver
          files = { health = "/var/lib/zigduck/health"; };
          css = css.health;
          code = ''
            <h1 style="text-align:center;">Machines Health</h1>
            <div id="healthContainer" class="health-grid"></div>

            <script>
              async function loadHealthData() {
                try {
                  const response = await fetch('/health/');
                  const text = await response.text();
                  
                  const parser = new DOMParser();
                  const htmlDoc = parser.parseFromString(text, 'text/html');
                  const links = Array.from(htmlDoc.querySelectorAll('a'));
                  const jsonFiles = links
                    .map(link => link.href)
                    .filter(href => href.endsWith('.json'))
                    .map(href => href.split('/').pop());
                  
                  console.log('Found health files:', jsonFiles);
                  
                  const container = document.getElementById('healthContainer');
                  container.innerHTML = "";
                  
                  for (const file of jsonFiles) {
                    try {
                      const healthResponse = await fetch('/health/' + file);
                      const healthData = await healthResponse.json();
                      createHealthCard(healthData, container);
                    } catch (error) {
                      console.error('Error loading health file:', file, error);
                    }
                  }
                  
                } catch (error) {
                  console.error('Error loading health directory:', error);
                  document.getElementById('healthContainer').innerHTML = 
                    '<div class="error">Unable to load health data</div>';
                }
              }
              
              function createHealthCard(data, container) {
                const card = document.createElement('div');
                card.className = 'health-card';
                
                const status = calculateOverallStatus(data);
                
                card.innerHTML = `
                  <div class="health-card-header">
                    <div class="health-hostname"><strong><h1>''${data.hostname}</h1></strong></div><br>
                    <div class="health-uptime">''${data.uptime}</div>
                  </div>
                  <div class="health-status">
                    <div class="health-item">
                      <span class="health-label"><strong>CPU:</strong></span>
                      <span class="health-value ''${getCPUStatusClass(data.cpu_usage)}">''${data.cpu_usage}%</span>
                    </div>
                    <div class="health-item">
                      <span class="health-label"><strong>Memory:</strong></span>
                      <span class="health-value ''${getMemoryStatusClass(data.memory_usage)}">''${data.memory_usage}%</span>
                    </div>
                    <div class="health-item">
                      <span class="health-label"><strong>CPU 🌡️:</strong></span>
                      <span class="health-value ''${getTempStatusClass(data.cpu_temperature)}">''${data.cpu_temperature}</span>
                    </div>
                    ''${createDiskUsageHTML(data.disk_usage)}
                    ''${createDiskTempHTML(data.disk_temperature)}
                  </div>
                `;
                
                container.appendChild(card);
              }
              
              function calculateOverallStatus(data) {
                if (data.cpu_usage > 90 || data.memory_usage > 90) return 'critical';
                if (data.cpu_usage > 80 || data.memory_usage > 80) return 'warning';
                return 'good';
              }
              
              function getCPUStatusClass(usage) {
                if (usage > 80) return 'status-critical';
                if (usage > 60) return 'status-warning';
                return 'status-good';
              }
              
              function getMemoryStatusClass(usage) {
                if (usage > 90) return 'status-critical';
                if (usage > 75) return 'status-warning';
                return 'status-good';
              }
              
              function getTempStatusClass(temp) {
                const tempValue = parseFloat(temp);
                if (tempValue > 70) return 'status-critical';
                if (tempValue > 60) return 'status-warning';
                return 'status-good';
              }
              
              function createDiskUsageHTML(diskUsage) {
                if (!diskUsage) return "";
                return Object.entries(diskUsage).map(([device, usage]) => `
                  <div class="health-item">
                    <span class="health-label"><strong>Disk</strong> (''${device}):</span>
                    <span class="health-value ''${getDiskStatusClass(usage)}">''${usage}</span>
                  </div>
                `).join("");
              }
              
              function createDiskTempHTML(diskTemp) {
                if (!diskTemp) return "";
                return Object.entries(diskTemp).map(([device, temp]) => `
                  <div class="health-item">
                    <span class="health-label"><strong>Disk 🌡️</strong>(''${device}):</span>
                    <span class="health-value ''${getTempStatusClass(temp)}">''${temp}</span>
                  </div>
                `).join("");
              }
              
              function getDiskStatusClass(usage) {
                const usageValue = parseFloat(usage);
                if (usageValue > 90) return 'status-critical';
                if (usageValue > 80) return 'status-warning';
                return 'status-good';
              }
              
              document.addEventListener('DOMContentLoaded', function() {
                if (document.getElementById('healthContainer')) {
                  loadHealthData();
                  setInterval(loadHealthData, 30000);
                }
              });
            </script>                
          '';
        };
        

      # 🦆 says ⮞ duckGPT - better than regularGPT - less thinkin' more doin'
        "5" = {
          icon = "fas fa-comments";
          title = "chat";
          css = css.chat;
          # 🦆 says ⮞ symlink TTS audio to frontend webserver
          files = { tts = "/var/lib/zigduck/tts"; };
          code = ''
            <div id="chat-container">
                <div id="chat">
                    <div class="chat-bubble suggestion-bubble">
                        Visa inköpslistan
                    </div>
                    <div class="chat-bubble suggestion-bubble">
                        Visa påminnelser
                    </div>
                    <div class="chat-bubble suggestion-bubble">
                        Visa alarm
                    </div>
                    <div class="chat-bubble suggestion-bubble">
                        När går tåget till Hörnefors Resecentrum från Umeå Central ? 
                    </div>
                    <div class="chat-bubble suggestion-bubble">
                       Släck alla lampor
                    </div>                 
                    <div class="chat-bubble suggestion-bubble">
                       Jag vill höra nyheterna
                    </div>
                    <div class="chat-bubble ai-bubble">
                        🦆Quack quack! 🦆 I'm a 🦆 here to help! Qwack to me yo!
                    </div>
                </div>
                <div id="input-container">
                    <button id="attachment-button" title="Attach file">📎</button>                
                    <input type="text" id="prompt" placeholder="Qwack something ... ">
                    <input type="file" id="file-input" style="display: none;" multiple>
                    <button id="send-button">🦆⮞</button>
                </div>
                <div id="file-preview" style="display: none;"></div>
            </div>
            
            <script>
                function fixViewportHeight() {
                    const vh = window.innerHeight * 0.01;
                    document.documentElement.style.setProperty('--vh', `''${vh}px`);
                    const inputContainer = document.getElementById('input-container');
                    const chat = document.getElementById('chat');
                    if (inputContainer && chat) {
                        const inputHeight = inputContainer.offsetHeight;
                        chat.style.paddingBottom = `''${inputHeight + 20}px`;
                    }
                }

                window.addEventListener('load', fixViewportHeight);
                window.addEventListener('resize', fixViewportHeight);
                window.addEventListener('orientationchange', fixViewportHeight);
          
                const AUDIO_CONFIG = {
                    enabled: true,
                    volume: 0.8
                };

                const API_CONFIG = {
                  host: '${mqttHostip}',
                  port: '9815',
                  baseUrl: 'http://${mqttHostip}:9815'
                };       
       
                function getAuthToken() {
                  function getCookie(name) {
                    const value = `; ''${document.cookie}`;
                    const parts = value.split(`; ''${name}=`);
                    if (parts.length === 2) return parts.pop().split(';').shift();
    
                    const cookies = document.cookie.split(';').map(c => c.trim());
                    for (const cookie of cookies) {
                      if (cookie.startsWith(name + '=')) {
                        return cookie.substring(name.length + 1);
                      }
                    }
                    return null;
                  }
  
                  const cookiePassword = getCookie('api_password');
                  if (cookiePassword) return cookiePassword;
  
                  return localStorage.getItem('mqttPassword') || 
                         localStorage.getItem('dashboardPassword') || 
                         "";
                }

             
                function showNotification(message, type) {
                    let notification = document.getElementById('chat-notification');
                    if (!notification) {
                        notification = document.createElement('div');
                        notification.id = 'chat-notification';
                        notification.style.cssText = `
                            position: fixed;
                            top: 20px;
                            right: 20px;
                            background: ''${type === 'error' ? '#ff4444' : type === 'success' ? '#4CAF50' : '#2196F3'};
                            color: white;
                            padding: 12px 20px;
                            border-radius: 8px;
                            box-shadow: 0 4px 12px rgba(0,0,0,0.3);
                            z-index: 10000;
                            font-family: monospace;
                            font-size: 14px;
                            opacity: 0;
                            transform: translateY(-20px);
                            transition: all 0.3s ease;
                        `;
                        document.body.appendChild(notification);
                    }
    
                    notification.textContent = message;
                    notification.style.background = type === 'error' ? '#ff4444' : type === 'success' ? '#4CAF50' : '#2196F3';
    
                    notification.style.opacity = '1';
                    notification.style.transform = 'translateY(0)';
    
                    setTimeout(() => {
                        notification.style.opacity = '0';
                        notification.style.transform = 'translateY(-20px)';
                    }, 3000);
                }
                      
                let isFirstMessage = true;
                let apiConnected = false;
                let selectedFiles = [];
                
                const connectionStatus = document.createElement('div');
                connectionStatus.id = 'chat-connection-status';
                connectionStatus.className = 'connection-status disconnected';
                connectionStatus.innerHTML = '<i class="fas fa-plug"></i><span>API: Disconnected</span>';
                document.getElementById('chat-container').insertBefore(connectionStatus, document.getElementById('chat'));
                
                function setupFileUpload() {
                    const attachmentButton = document.getElementById('attachment-button');
                    const fileInput = document.getElementById('file-input');
                    const filePreview = document.getElementById('file-preview');
                    
                    attachmentButton.addEventListener('click', () => {
                        fileInput.click();
                    });
                    
                    fileInput.addEventListener('change', (event) => {
                        selectedFiles = Array.from(event.target.files);
                        updateFilePreview();
                    });
                }

                function hasMarkdownTable(text) {
                    const lines = text.split('\n');
                    let pipeCount = 0;
                    for (const line of lines) {
                        if (line.trim().startsWith('|') && line.includes('|') && line.split('|').length > 2) {
                            pipeCount++;
                        }
                    }             
                }

                function convertMarkdownTableToHTML(text) {
                    const lines = text.split('\n').filter(line => 
                        line.trim().startsWith('|') && line.trim().endsWith('|')
                    );
    
                    if (lines.length < 2) return text;
    
                    const tableData = lines.map(line => 
                        line.split('|')
                            .slice(1, -1)
                            .map(cell => cell.trim())
                    );
    
                    const isSecondRowSeparator = tableData[1] && tableData[1].every(cell => 
                        /^:?-+:?$/.test(cell)
                    );
    
                    const headers = isSecondRowSeparator ? tableData[0] : [];
                    const dataRows = isSecondRowSeparator ? tableData.slice(2) : tableData;
    
                    let html = '<div class="markdown-table-container"><table class="markdown-table">';
                    if (headers.length > 0) {
                        html += '<thead><tr>';
                        headers.forEach(header => {
                            html += `<th>''${header}</th>`;
                        });
                        html += '</tr></thead>';
                    }
    
                    html += '<tbody>';
                    dataRows.forEach(row => {
                        if (row.length === headers.length || headers.length === 0) {
                            row.forEach(cell => {
                                const tag = headers.length === 0 && row === dataRows[0] ? 'th' : 'td';
                                html += `<''${tag}>''${cell}</''${tag}>`;
                            });
                            html += '</tr>';
                        }
                    });
                    html += '</tbody></table></div>';
    
                    return html;
                }
                                         
                function updateFilePreview() {
                    const filePreview = document.getElementById('file-preview');              
                    if (selectedFiles.length === 0) {
                        filePreview.style.display = 'none';
                        filePreview.innerHTML = "";
                        return;
                    }
                    
                    filePreview.style.display = 'block';
                    filePreview.innerHTML = '<strong>Attached files:</strong><br>';           
                    selectedFiles.forEach((file, index) => {
                        const fileElement = document.createElement('div');
                        fileElement.className = 'file-preview-item';
                        fileElement.innerHTML = `
                            📄 ''${file.name} (''${formatFileSize(file.size)})
                            <button onclick="removeFile(''${index})" class="remove-file-btn">❌</button>
                        `;
                        filePreview.appendChild(fileElement);
                    });
                }
                
                function removeFile(index) {
                    selectedFiles.splice(index, 1);
                    updateFilePreview();          
                    document.getElementById('file-input').value = "";
                }
                
                function formatFileSize(bytes) {
                    if (bytes === 0) return '0 Bytes';
                    const k = 1024;
                    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
                    const i = Math.floor(Math.log(bytes) / Math.log(k));
                    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
                }
                
                async function uploadFiles() {
                    if (selectedFiles.length === 0) return true;    
                    showTypingIndicator();
                    try {
                        const password = getAuthToken();        
                        for (const file of selectedFiles) {
                            const formData = new FormData();
                            formData.append('file', file);
                            const response = await fetch(API_CONFIG.baseUrl + '/upload?password=' + encodeURIComponent(password), {
                                method: 'POST',
                                body: formData
                            });

                            if (!response.ok) {
                                const errorText = await response.text();
                                throw new Error(`Upload failed: ''${response.status} - ''${errorText}`);
                            }
            
                            const result = await response.json();
                            addAIMessage(`🦆 say ⮞ Quack safe backed up: ''${file.name} (''${formatFileSize(file.size)})`);
                        }
                        selectedFiles = [];
                        updateFilePreview();
                        document.getElementById('file-input').value = "";
                        return true;
                    } catch (error) {
                        console.error('File upload failed:', error);
                        addErrorMessage(`❌ File upload failed: ''${error.message}`);
                        return false;
                    }
                }
                
                function extractOutputFromResponse(responseText) {
                    try {
                        const data = JSON.parse(responseText);
                        if (data.output) {
                            return data.output;
                        }
                    } catch (e) {
                        console.log('JSON parse failed, trying regex');
                    }         
                    const outputMatch = responseText.match(/"output":"([\s\S]*?)"(?=,|\})/);
                    if (outputMatch && outputMatch[1]) {
                        return outputMatch[1];
                    }
                    
                    return responseText;
                }
                
                function cleanAPIResponse(output) {
                    if (!output) return "Command executed!";         
                    let cleaned = output.replace(/\u001b\[[0-9;]*m/g, "");
                    cleaned = cleaned.replace(/\\n/g, '\n');         
                    return cleaned;
                }
                
                async function checkAPIHealth() {
                    try {
                        const response = await fetch(API_CONFIG.baseUrl + '/health');
                        if (response.ok) {
                            const data = await response.json();
                            updateConnectionStatus(true, 'API: Connected');
                            apiConnected = true;
                            return true;
                        }
                    } catch (error) {
                        console.log('API health check failed:', error);
                    }
                    updateConnectionStatus(false, 'API: Disconnected');
                    apiConnected = false;
                    return false;
                }
                
                function updateConnectionStatus(connected, message) {
                    const statusElement = document.getElementById('chat-connection-status');
                    if (statusElement) {
                        if (connected) {
                            statusElement.innerHTML = '<i class="fas fa-plug"></i><span>' + message + '</span>';
                            statusElement.className = 'connection-status connected';
                        } else {
                            statusElement.innerHTML = '<i class="fas fa-plug"></i><span>' + message + '</span>';
                            statusElement.className = 'connection-status disconnected';
                        }
                    }
                }
                
                function addAIMessage(content, options = {}) {
                    const chatContainer = document.getElementById('chat');
                    const typingIndicator = document.querySelector('.typing-indicator');
                    if (typingIndicator) {
                        chatContainer.removeChild(typingIndicator);
                    }

                    const aiBubble = document.createElement('div');
                    aiBubble.className = 'chat-bubble ai-bubble';
                    aiBubble.innerHTML = content;
                    chatContainer.appendChild(aiBubble);

                    chatContainer.scrollTop = chatContainer.scrollHeight;

                    // 🦆 play TTS audio file
                    const playTTSAudio = () => {
                        const cacheBuster = Date.now() + '-' + Math.random().toString(36).substr(2, 9);
                        const audio = new Audio('/tts/tts.wav?' + cacheBuster);
                        audio.volume = AUDIO_CONFIG.enabled ? AUDIO_CONFIG.volume : 0;        
                        audio.play().catch(error => {
                            console.warn('Audio playback failed:', error);
                        });
                    };
                    setTimeout(playTTSAudio, 500);    
                }
          
                function addErrorMessage(text) {
                    const chatContainer = document.getElementById('chat');
                    const typingIndicator = document.querySelector('.typing-indicator');
                    if (typingIndicator) {
                        chatContainer.removeChild(typingIndicator);
                    }
        
                    const errorBubble = document.createElement('div');
                    errorBubble.className = 'chat-bubble error-bubble';
                    errorBubble.textContent = text;
                    chatContainer.appendChild(errorBubble);                
                    chatContainer.scrollTop = chatContainer.scrollHeight;
                }
                
                function showTypingIndicator() {
                    const chatContainer = document.getElementById('chat');
                    const existingIndicator = document.querySelector('.typing-indicator');
                    if (existingIndicator) {
                        chatContainer.removeChild(existingIndicator);
                    }
                
                    const typingIndicator = document.createElement('div');
                    typingIndicator.className = 'typing-indicator';
                    typingIndicator.innerHTML = '<div class="typing-dot"></div><div class="typing-dot"></div><div class="typing-dot"></div>';
                    chatContainer.appendChild(typingIndicator);
                    chatContainer.scrollTop = chatContainer.scrollHeight;
                }
                
                async function sendCommandToAPI(command) {
                    if (!apiConnected) {
                        addErrorMessage("❌ Not connected to API. Check if the API server is running.");
                        return false;
                    }
                
                    const uploadSuccess = await uploadFiles();
                    if (!uploadSuccess) {
                        return false;
                    }
                
                    showTypingIndicator(); 
                    try {
                        const lowerCommand = command.toLowerCase();                    
                        if (lowerCommand.startsWith('do ')) {
                            const naturalLanguageCommand = command.substring(3);
                            return await sendNaturalLanguageCommand(naturalLanguageCommand);
                        } else if (lowerCommand.includes('shopping') || lowerCommand.includes('shopping list')) {
                            return await fetchShoppingList();
                        } else if (lowerCommand.includes('reminder') || lowerCommand.includes('remind')) {
                            return await fetchReminders();
                        } else if (lowerCommand.includes('timer')) {
                            return await fetchTimers();
                        } else if (lowerCommand.includes('alarm')) {
                            return await fetchAlarms();
                        } else if (lowerCommand.includes('location') || lowerCommand.includes('where am i')) {
                            return await fetchLocation();
                        } else {
                            return await sendNaturalLanguageCommand(command);
                        }
                    } catch (error) {
                        console.error('API call failed:', error);
                        addErrorMessage("❌ Failed to send command to API. Please check the connection.");
                        return false;
                    }
                }
                
                async function sendNaturalLanguageCommand(command) {  // Remove ttsOptions parameter
                  try {
                    const password = getAuthToken();
                    const response = await fetch(API_CONFIG.baseUrl + '/do?cmd=' + encodeURIComponent(command) + '&password=' + encodeURIComponent(password));

                    if (response.ok) {
                      let responseText = await response.text();
                      const rawOutput = extractOutputFromResponse(responseText);
                      const cleanOutput = cleanAPIResponse(rawOutput);

                      addAIMessage(cleanOutput);  // ✅ Simplified - just pass the content
                      return true;
                    } else {
                      addErrorMessage('❌ API Error: ' + response.status + ' - ' + response.statusText);
                      return false;
                    }
                  } catch (error) {
                    console.error('Yo DO command failed:', error);
                    addAIMessage("Command sent to API! (Check API logs for details)");
                    return true;
                  }
                }


                function sendMessage() {
                    const promptInput = document.getElementById('prompt');
                    const prompt = promptInput.value.trim();
                    const chatContainer = document.getElementById('chat');
                
                    if (prompt === "" && selectedFiles.length === 0) return;
                
                    if (prompt !== "") {
                        const userBubble = document.createElement('div');
                        userBubble.className = 'chat-bubble user-bubble';
                        userBubble.textContent = prompt;
                        chatContainer.appendChild(userBubble);
                    }             
                    promptInput.value = "";               
                    chatContainer.scrollTop = chatContainer.scrollHeight;          
                    sendCommandToAPI(prompt);         
                    isFirstMessage = false;
                }
                
                function sendSuggestion(element) {
                    const text = element.textContent;
                    document.getElementById('prompt').value = text;
                    sendMessage();
                }
                
                function checkEnter(event) {
                    if (event.key === 'Enter') {
                        sendMessage();
                    }
                }
                
                setupFileUpload();
                checkAPIHealth();     
                document.getElementById('prompt').addEventListener('keydown', checkEnter);
                document.getElementById('send-button').addEventListener('click', sendMessage);        
                document.querySelectorAll('.suggestion-bubble').forEach(bubble => {
                    bubble.addEventListener('click', function() {
                        sendSuggestion(this);
                    });
                });            
                setTimeout(() => {
                    if (isFirstMessage) {
                        addAIMessage("duckpuck![🏒🦆] !");
                    }
                }, 2000);
                
                setInterval(checkAPIHealth, 30000);
            </script>
            
          '';
        };
      
      };
    };
  
# 🦆 ⮞ ZIGBEE ⮜ 🐝
    zigbee = {
      # 🦆 says ⮞ encrypted zigbee network key
      networkKeyFile = config.sops.secrets.z2m_network_key.path;
      
      # 🦆 says ⮞ mosquitto authentication
      mosquitto = {
        username = "mqtt";
        passwordFile = config.sops.secrets.mosquitto.path;
      };
      
      # 🦆says⮞ coordinator configuration
      coordinator = {
        vendorId =  "10c4";
        productId = "ea60";
        symlink = "zigbee"; # 🦆 says ⮞ diz symlinkz da serial port to /dev/zigbee
      };
    
      # 🦆 says ⮞ when motion triggers lights
      darkTime = {
        enable = true;
        after = "14";
        before = "9";
        duration = "900";
      };
      
  # 🦆 ⮞ AUTOMATIONS ⮜
      automations = {  
      # 🦆 says ⮞ there are 6 different automation types
        # 🦆 says ⮞ + a greeting automation
        greeting = {
          enable = true;
          awayDuration = "7200";
          greeting = "Borta bra, hemma bäst. Välkommen idiot! ";
          delay = "10";
          sayOnHost = "desktop";
        };
        
        # 🦆 says ⮞ 1. mqtt triggered automations
        mqtt_triggered = {
          xmr = {
            enable = true;
            description = "Writes XMR data to file for dashboard";
            topic = "zigbee2mqtt/crypto/xmr/price";
            actions = [
              {
                type = "shell";
                command = ''
                  touch /var/lib/zigduck/xmr.json
                  echo "$MQTT_PAYLOAD" > /var/lib/zigduck/xmr.json
                '';
              }
            ];
          };
          
          btc = {
            enable = true;
            description = "Writes BTC data to file for dashboard";
            topic = "zigbee2mqtt/crypto/btc/price";
            actions = [
              {
                type = "shell";
                command = ''
                  touch /var/lib/zigduck/btc.json
                  echo "$MQTT_PAYLOAD" > /var/lib/zigduck/btc.json
                '';
              }
            ];
          };

          energy = {
            enable = true;
            description = "Writes tibber data to file for dashboard";
            topic = "zigbee2mqtt/tibber/energy";
            actions = [
              {
                type = "shell";
                command = ''
                  touch /var/lib/zigduck/energy.json
                  echo "$MQTT_PAYLOAD" > /var/lib/zigduck/energy.json
                  current_price=$(echo "$MQTT_PAYLOAD" | jq -r '.current_price' | sed 's/\"//g')
                  # 🦆says⮞ notify if high energy price
                  if [ $(echo "$current_price > 2.0" | bc -l) -eq 1 ]; then
                    yo notify "⚡ High energy price: $current_price SEK/kWh"
                  fi
                '';
              }
            ];
          };
        } // health; 
        
        # 🦆 says ⮞ 2. room action automations
        room_actions = {
          hallway = { 
            door_opened = [];
            door_closed = [];
          };  
          bedroom = { 
            # 🦆 says ⮞ default actions already configured - room lights will turn on upon motion (if darkTime)
            motion_detected = [
              {
                type = "scene";
                scene = "Chill Scene";
              }           
            ];
            motion_not_detected = [
              {
                type = "mqtt";
                topic = "zigbee2mqtt/Sänggavel/set";
                message = ''{"state":"OFF", "brightness": 80}'';
              }              
            ];
          };
        };
          
        # 🦆 says ⮞ 3. global actions automations  
        global_actions = {
          leak_detected = [
            {
              type = "shell";
              command = "yo notify '🚨 WATER LEAK DETECTED!'";
            }
          ];
          smoke_detected = [
            {
              type = "shell";
              command = "yo notify '🔥 SMOKE DETECTED!'";
            }
          ];
        };

        # 🦆 says ⮞ 4. dimmer actions automations
        dimmer_actions = {          
          bedroom = {
            on_hold_release = {
              enable = true;
              description = "Turn off all configured light devices";
              extra_actions = [];
              override_actions = [];
            };

            off_hold_release = {
              enable = true;
              description = "Turn off all configured light devices";
              extra_actions = [];
              override_actions = [
                {
                  type = "scene";
                  command = "dark";
                }
              ];
            };   
          };              
        };
        
        # 🦆 says ⮞ 5. time based automations
        time_based = {};
        
        # 🦆 says ⮞ 6. presence based automations
        presence_based = {};
        
      };  


  # 🦆 ⮞ DEVICES ⮜      
      devices = { 
        # 🦆 says ⮞ Kitchen   
        "0x0017880103ca6e95" = { # 🦆 says ⮞ 64bit IEEE adress (this is the unique device ID)  
          friendly_name = "Dimmer Switch Kök"; # 🦆 says ⮞ simple human readable friendly name
          room = "kitchen"; # 🦆 says ⮞ bind to group
          type = "dimmer"; # 🦆 says ⮞ set a custom device type
          icon = icons.dimmer;
          endpoint = 1; # 🦆 says ⮞ endpoint to call the device on
          batteryType = "CR2450"; # 🦆 says ⮞ optional yo
        }; 
        "0x0017880102f0848a" = { 
          friendly_name = "Spotlight kök 1";
          room = "kitchen";
          type = "light";
          icon = icons.light.spotlight;
          endpoint = 11;
        };
        "0x0017880102f08526" = { friendly_name = "Spotlight Kök 2"; room = "kitchen"; type = "light"; icon = icons.light.spotlight; endpoint = 11; };
        "0x0017880103a0d280" = { friendly_name = "Uppe"; room = "kitchen"; type = "light"; icon = icons.light.strip; endpoint = 11; supports_color = true; };
        "0x0017880103e0add1" = { friendly_name = "Golvet"; room = "kitchen"; type = "light"; icon = icons.light.strip; endpoint = 11; supports_color = true; };
        "0xa4c13873044cb7ea" = { friendly_name = "Kök Bänk Slinga"; room = "kitchen"; type = "light"; icon = icons.light.strip; endpoint = 11; };
        "0x70ac08fffe9fa3d1" = { friendly_name = "Motion Sensor Kök"; room = "kitchen"; type = "motion"; icon = icons.sensor.motion; endpoint = 1; batteryType = "CR2032"; }; 
        "0xa4c1380afa9f7f3e" = { friendly_name = "Smoke Alarm Kitchen"; room = "kitchen"; type = "sensor"; icon = icons.sensor.smoke; endpoint = 1; };
        "0x0c4314fffe179b05" = { friendly_name = "Fläkt"; room = "kitchen"; type = "outlet"; icon = icons.outlet; endpoint = 1; };    
        # 🦆 says ⮞ LIVING ROOM
        "0x0017880104f78065" = { friendly_name = "Dimmer Switch Vardagsrum"; room = "livingroom"; type = "dimmer"; icon = icons.dimmer; endpoint = 1; batteryType = "CR2450"; };
        "0x00178801037e754e" = { friendly_name = "Takkrona 1"; room = "livingroom"; type = "light"; icon = icons.light.chandelier; endpoint = 1; supports_color = true; };   
        "0x0017880103c73f85" = { friendly_name = "Takkrona 2"; room = "livingroom"; type = "light"; icon = icons.light.chandelier; endpoint = 1; supports_color = true; };  
        "0x0017880103f94041" = { friendly_name = "Takkrona 3"; room = "livingroom"; type = "light"; icon = icons.light.chandelier; endpoint = 1; supports_color = true; };                  
        "0x0017880103c753b8" = { friendly_name = "Takkrona 4"; room = "livingroom"; type = "light"; icon = icons.light.chandelier; endpoint = 1; supports_color = true; };  
        "0x54ef4410003e58e2" = { friendly_name = "Roller Shade"; room = "livingroom"; type = "blind"; icon = icons.blinds; endpoint = 1; };
        "0x0017880104540411" = { friendly_name = "PC"; room = "livingroom"; type = "light"; icon = icons.light.spotlight; endpoint = 11; supports_color = true; };
        "0x0017880102de8570" = { friendly_name = "Rustning"; room = "livingroom"; type = "light"; icon = icons.light.spotlight; endpoint = 11; supports_color = true; };
        "0x540f57fffe85c9c3" = { friendly_name = "Water Sensor"; room = "livingroom"; type = "sensor"; icon = icons.sensor.water; endpoint = 1; };
        # 🦆 says ⮞ HALLWAY
        "0x00178801021311c4" = { friendly_name = "Motion Sensor Hall"; room = "hallway"; type = "motion"; icon = icons.sensor.motion; endpoint = 1; batteryType = "AAA"; };#⮜ AAA-AWESOME 🦆 
        "0x00158d00053ec9b1" = { friendly_name = "Door Sensor Hall"; room = "hallway"; type = "sensor"; icon = icons.sensor.contact; endpoint = 1; };
        "0x0017880103eafdd6" = { friendly_name = "Tak Hall";  room = "hallway"; type = "light"; icon = icons.light.ceiling; supports_color = true; endpoint = 11; };
        "0x000b57fffe0e2a04" = { friendly_name = "Vägg"; room = "hallway"; type = "light"; icon = icons.light.wall; supports_temperature = true; endpoint = 1; };
        # 🦆 says ⮞ WC
        "0x001788010361b842" = { friendly_name = "WC 1"; room = "wc"; type = "light"; icon = icons.light.ceiling; supports_temperature = true; endpoint = 11; };
        "0x0017880103406f41" = { friendly_name = "WC 2"; room = "wc"; type = "light"; icon = icons.light.ceiling; supports_temperature = true; endpoint = 11; };
        # 🦆 says ⮞ BEDROOM  
        "0xa4c13832742c96f7" = { friendly_name = "Robot Arm 1"; room = "bedroom"; type = "pusher"; endpoint = 11; icon = icons.pusher; batteryType = "CR02"; };
        "0xa4c138387966b58d" = { friendly_name = "Robot Arm 2"; room = "bedroom"; type = "pusher"; endpoint = 11; icon = icons.pusher; batteryType = "CR02"; };
        "0xa4c1380c0a35052e" = { friendly_name = "Robot Arm 3"; room = "bedroom"; type = "pusher"; endpoint = 11; icon = icons.pusher; batteryType = "CR02"; };
        "0xa4c1381e74b6d2e6" = { friendly_name = "Robot Arm 4"; room = "bedroom"; type = "pusher"; endpoint = 11; icon = icons.pusher; batteryType = "CR02"; };
        "0x0017880104f77d61" = { friendly_name = "Dimmer Switch Sovrum"; room = "bedroom"; type = "dimmer"; icon = icons.dimmer; endpoint = 1; batteryType = "CR2450"; }; 
        "0x0017880106156cb0" = { friendly_name = "Taket Sovrum 1"; room = "bedroom"; type = "light"; icon = icons.light.ceiling; endpoint = 11; supports_color = true; };
        "0x0017880103c7467d" = { friendly_name = "Taket Sovrum 2"; room = "bedroom"; type = "light"; icon = icons.light.ceiling; endpoint = 11; supports_color = true; };
        "0x0017880109ac14f3" = { friendly_name = "Sänglampa"; room = "bedroom"; type = "light"; icon = icons.light.bulb; endpoint = 11; supports_color = true; };
        "0x0017880104051a86" = { friendly_name = "Sänggavel"; room = "bedroom"; type = "light"; icon = icons.light.strip; endpoint = 11; supports_color = true; };
        "0xf4b3b1fffeaccb27" = { friendly_name = "Motion Sensor Sovrum"; room = "bedroom"; type = "motion"; icon = icons.sensor.motion; endpoint = 1; batteryType = "CR2032"; };
        "0x0017880103f44b5f" = { friendly_name = "Dörr"; room = "bedroom"; type = "light"; icon = icons.light.strip; endpoint = 11; supports_color = true; };
        "0x00178801001ecdaa" = { friendly_name = "Bloom"; room = "bedroom"; type = "light"; icon = icons.light.desk; endpoint = 11; supports_color = true; };
        # 🦆 says ⮞ MISCELLANEOUS
        "0xa4c1382553627626" = { friendly_name = "Power Plug"; room = "other"; type = "outlet"; icon = icons.outlet; endpoint = 1; };
        "0xa4c138b9aab1cf3f" = { friendly_name = "Power Plug 2"; room = "other"; type = "outlet"; icon = icons.outlet; endpoint = 1; };
        "0x000b57fffe0f0807" = { friendly_name = "IKEA 5 Dimmer"; room = "other"; type = "remote"; icon = icons.remote; endpoint = 1; };
        "0x70ac08fffe6497be" = { friendly_name = "On/Off Switch 1"; room = "other"; type = "remote"; icon = icons.remote; endpoint = 1; batteryType = "CR2032"; };
        "0x70ac08fffe65211e" = { friendly_name = "On/Off Switch 2"; room = "other"; type = "remote"; icon = icons.remote; endpoint = 1; batteryType = "CR2032"; };
      };
      
  # 🦆 ⮞ SCENES ⮜
      scenes = {
          # 🦆 says ⮞ Scene name
          "Duck Scene" = {
              # 🦆 says ⮞ Device friendly_name
              "PC" = { # 🦆 says ⮞ Device state
                  state = "ON";
                  brightness = 200;
                  color = { hex = "#00FF00"; };
              };
          };
          # 🦆 says ⮞ Scene 2    
          "Chill Scene" = {
              "PC" = { state = "ON"; brightness = 200; color = { hex = "#8A2BE2"; }; };               # 🦆 says ⮞ Blue Violet
              "Golvet" = { state = "ON"; brightness = 200; color = { hex = "#40E0D0"; }; };           # 🦆 says ⮞ Turquoise
              "Uppe" = { state = "ON"; brightness = 200; color = { hex = "#FF69B4"; }; };             # 🦆 says ⮞ Hot Pink
              "Spotlight kök 1" = { state = "OFF"; brightness = 200; color = { hex = "#FFD700"; }; }; # 🦆 says ⮞ Gold
              "Spotlight Kök 2" = { state = "OFF"; brightness = 200; color = { hex = "#FF8C00"; }; }; # 🦆 says ⮞ Dark Orange
              "Taket Sovrum 1" = { state = "ON"; brightness = 200; color = { hex = "#00CED1"; }; };   # 🦆 says ⮞ Dark Turquoise
              "Taket Sovrum 2" = { state = "ON"; brightness = 200; color = { hex = "#9932CC"; }; };   # 🦆 says ⮞ Dark Orchid
              "Bloom" = { state = "ON"; brightness = 200; color = { hex = "#FFB6C1"; }; };            # 🦆 says ⮞ Light Pink
              "Sänggavel" = { state = "ON"; brightness = 200; color = { hex = "#7FFFD4"; }; };        # 🦆 says ⮞ Aquamarine
              "Takkrona 1" = { state = "ON"; brightness = 200; color = { hex = "#7FFFD4"; }; };        # 🦆 says ⮞ Aquamarine   
              "Takkrona 2" = { state = "ON"; brightness = 200; color = { hex = "#7FFFD4"; }; };        # 🦆 says ⮞ Aquamarine   
              "Takkrona 3" = { state = "ON"; brightness = 200; color = { hex = "#7FFFD4"; }; };        # 🦆 says ⮞ Aquamarine   
              "Takkrona 4" = { state = "ON"; brightness = 200; color = { hex = "#7FFFD4"; }; };        # 🦆 says ⮞ Aquamarine   
          }; 
          "Green D" = {
              "PC" = { state = "ON"; brightness = 200; color = { hex = "#00FF00"; }; };
              "Golvet" = { state = "ON"; brightness = 200; color = { hex = "#00FF00"; }; };
              "Uppe" = { state = "ON"; brightness = 200; color = { hex = "#00FF00"; }; };
              "Spotlight kök 1" = { state = "OFF"; brightness = 200; color = { hex = "#00FF00"; }; };
              "Spotlight Kök 2" = { state = "OFF"; brightness = 200; color = { hex = "#00FF00"; }; };
              "Taket Sovrum 1" = { state = "ON"; brightness = 200; color = { hex = "#00FF00"; }; };
              "Taket Sovrum 2" = { state = "ON"; brightness = 200; color = { hex = "#00FF00"; }; };
              "Bloom" = { state = "ON"; brightness = 200; color = { hex = "#00FF00"; }; };
              "Sänggavel" = { state = "ON"; brightness = 200; color = { hex = "#00FF00"; }; };
              "Takkrona 1" = { state = "ON"; brightness = 200; color = { hex = "#7FFFD4"; }; };        # 🦆 says ⮞ Aquamarine   
              "Takkrona 2" = { state = "ON"; brightness = 200; color = { hex = "#7FFFD4"; }; };        # 🦆 says ⮞ Aquamarine   
              "Takkrona 3" = { state = "ON"; brightness = 200; color = { hex = "#7FFFD4"; }; };        # 🦆 says ⮞ Aquamarine   
              "Takkrona 4" = { state = "ON"; brightness = 200; color = { hex = "#7FFFD4"; }; };        # 🦆 says ⮞ Aquamarine   
          };  
          "dark" = { # 🦆 says ⮞ eat darkness... lol YO! You're as blind as me now! HA HA!  
              "Bloom" = { state = "OFF"; transition = 10; };
              "Dörr" = { state = "OFF"; transition = 10; };
              "Golvet" = { state = "OFF"; transition = 10; };
              "Kök Bänk Slinga" = { state = "OFF"; transition = 10; };
              "PC" = { state = "OFF"; transition = 10; };
              "Rustning" = { state = "OFF"; transition = 10; };
              "Spotlight Kök 2" = { state = "OFF"; transition = 10; };
              "Spotlight kök 1" = { state = "OFF"; transition = 10; };
              "Sänggavel" = { state = "OFF"; transition = 10; };
              "Sänglampa" = { state = "OFF"; transition = 10; };
              "Tak Hall" = { state = "OFF"; transition = 10; };
              "Taket Sovrum 1" = { state = "OFF"; transition = 10; };
              "Taket Sovrum 2" = { state = "OFF"; transition = 10; };
              "Uppe" = { state = "OFF"; transition = 10; };
              "Vägg" = { state = "OFF"; transition = 10; };
              "WC 1" = { state = "OFF"; transition = 10; };
              "WC 2" = { state = "OFF"; transition = 10; };
              "Takkrona 1" = { state = "OFF"; transition = 10; };   
              "Takkrona 2" = { state = "OFF"; transition = 10; };
              "Takkrona 3" = { state = "OFF"; transition = 10; };   
              "Takkrona 4" = { state = "OFF"; transition = 10; };   
          };  
          "dark-fast" = { # 🦆 says ⮞ eat darkness... NAO!  
              "Bloom" = { state = "OFF"; };
              "Dörr" = { state = "OFF"; };
              "Golvet" = { state = "OFF"; };
              "Kök Bänk Slinga" = { state = "OFF"; };
              "PC" = { state = "OFF"; };
              "Rustning" = { state = "OFF"; };
              "Spotlight Kök 2" = { state = "OFF"; };
              "Spotlight kök 1" = { state = "OFF"; };
              "Sänggavel" = { state = "OFF"; };
              "Sänglampa" = { state = "OFF"; };
              "Tak Hall" = { state = "OFF"; };
              "Taket Sovrum 1" = { state = "OFF"; };
              "Taket Sovrum 2" = { state = "OFF"; };
              "Uppe" = { state = "OFF"; };
              "Vägg" = { state = "OFF"; };
              "WC 1" = { state = "OFF"; };
              "WC 2" = { state = "OFF"; };
              "Takkrona 1" = { state = "OFF"; };   
              "Takkrona 2" = { state = "OFF"; };
              "Takkrona 3" = { state = "OFF"; };   
              "Takkrona 4" = { state = "OFF"; };   
          };  
          "max" = { # 🦆 says ⮞ let there be light
              "Bloom" = { state = "ON"; brightness = 255; color = { hex = "#FFFFFF"; }; };
              "Dörr" = { state = "ON"; brightness = 255; color = { hex = "#FFFFFF"; }; };
              "Golvet" = { state = "ON"; brightness = 255; color = { hex = "#FFFFFF"; }; };
              "Kök Bänk Slinga" = { state = "ON"; brightness = 255; color = { hex = "#FFFFFF"; }; };
              "PC" = { state = "ON"; brightness = 255; color = { hex = "#FFFFFF"; }; };
              "Rustning" = { state = "ON"; brightness = 255; color = { hex = "#FFFFFF"; }; };
              "Spotlight Kök 2" = { state = "ON"; brightness = 255; color = { hex = "#FFFFFF"; }; };
              "Spotlight kök 1" = { state = "ON"; brightness = 255; color = { hex = "#FFFFFF"; }; };
              "Sänggavel" = { state = "ON"; brightness = 255; color = { hex = "#FFFFFF"; }; };
              "Sänglampa" = { state = "ON"; brightness = 255; color = { hex = "#FFFFFF"; }; };
              "Tak Hall" = { state = "ON"; brightness = 255; color = { hex = "#FFFFFF"; }; };
              "Taket Sovrum 1" = { state = "ON"; brightness = 255; color = { hex = "#FFFFFF"; }; };
              "Taket Sovrum 2" = { state = "ON"; brightness = 255; color = { hex = "#FFFFFF"; }; };
              "Uppe" = { state = "ON"; brightness = 255; color = { hex = "#FFFFFF"; }; };
              "Vägg" = { state = "ON"; brightness = 255; color = { hex = "#FFFFFF"; }; };
              "WC 1" = { state = "ON"; brightness = 255; color = { hex = "#FFFFFF"; }; };
              "WC 2" = { state = "ON"; brightness = 255; color = { hex = "#FFFFFF"; }; };
              "Takkrona 1" = { state = "ON"; brightness = 255; color = { hex = "#FFFFFF"; }; };   
              "Takkrona 2" = { state = "ON"; brightness = 255; color = { hex = "#FFFFFF"; }; };
              "Takkrona 3" = { state = "ON"; brightness = 255; color = { hex = "#FFFFFF"; }; };   
              "Takkrona 4" = { state = "ON"; brightness = 255; color = { hex = "#FFFFFF"; }; };
          };    
      };       
    };
    
    # 🦆 ⮞ TV ⮜
    # 🦆says⮞ configure TV devices with: room, ip, apps & channel information
    tv = {
      # 🦆 says ⮞ Livingroom
      shield = {
        enable = true;
        room = "livingroom";
        ip = "192.168.1.223";
        apps = {
          telenor = "se.telenor.stream/.MainActivity";
          tv4 = "se.tv4.tv4playtab/se.tv4.tv4play.ui.mobile.main.BottomNavigationActivity";
        };  
        channels = {     
          "1" = {
            name = "SVT1";
            id = 1; # 🦆 says ⮞ adb channel ID
            # 🦆 says ⮞ OR
            # stream_url = "https://url.com/";
            cmd = "open_telenor && wait 5 && start_channel_1";
            # 🦆 says ⮞ automagi generated tv-guide web & EPG          
            icon = ./themes/icons/tv/1.png;
            scrape_url = "https://tv-tabla.se/tabla/svt1/";          
          };
          "2" = {
            id = 2; 
            name = "SVT2";
            cmd = "open_telenor && wait 5 && start_channel_2";
            icon = ./themes/icons/tv/2.png;          
            scrape_url = "https://tv-tabla.se/tabla/svt2/";
          };
          "3" = {
            id = 3;
            name = "Kanal 3";
            cmd = "open_telenor && wait 5 && start_channel_3";
            icon = ./themes/icons/tv/3.png;
            scrape_url = "https://tv-tabla.se/tabla/tv3/";
          };
          "4" = {
            id = 4;
            name = "TV4";
            cmd = "open_telenor && wait 5 && start_channel_4";
            icon = ./themes/icons/tv/4.png;
            scrape_url = "https://tv-tabla.se/tabla/tv4/";
          };
          "5" = {
            id = 5;
            name = "Kanal 5";
            cmd = "open_telenor && wait 5 && start_channel_5";
            icon = ./themes/icons/tv/5.png;
            scrape_url = "https://tv-tabla.se/tabla/kanal_5/";
          };
          "6" = {
            id = 6;
            name = "Kanal 6";
            cmd = "open_telenor && wait 5 && start_channel_6";
            icon = ./themes/icons/tv/6.png;
            scrape_url = "https://tv-tabla.se/tabla/tv6/";
          };
          "7" = {
            id = 7;
            name = "Sjuan";
            cmd = "open_telenor && wait 5 && start_channel_7";
            icon = ./themes/icons/tv/7.png;
            scrape_url = "https://tv-tabla.se/tabla/sjuan/";
          };
          "8" = {
            id = 8;
            name = "TV8";
            icon = ./themes/icons/tv/8.png;          
            scrape_url = "https://tv-tabla.se/tabla/tv8/";
          };
          "9" = {
            id = 9;
            name = "Kanal 9";
            icon = ./themes/icons/tv/9.png;          
            scrape_url = "https://tv-tabla.se/tabla/kanal_9/";
          };
          "10" = {
            id = 10;
            name = "Kanal 10";
            icon = ./themes/icons/tv/10.png;
            scrape_url = "https://tv-tabla.se/tabla/tv10/";
          };
          "11" = {
            id = 11;
            name = "Kanal 11";
            icon = ./themes/icons/tv/11.png;
            scrape_url = "https://tv-tabla.se/tabla/tv11/";
          };
          "12" = {
            id = 12;
            name = "Kanal 12";
            icon = ./themes/icons/tv/12.png;
            scrape_url = "https://tv-tabla.se/tabla/tv12/";
          };
          "13" = {
            id = 13;
            name = "TV4 Hockey";
            icon = ./themes/icons/tv/13.png;
            cmd = "open_tv4 && nav_select && nav_left && nav_down && nav_doown && nav_down && nav_select && wait 3 && nav_down && nav_down && nav_down && nav_down && nav_down && nav_select";
            scrape_url = "https://tv-tabla.se/tabla/tv4_hockey/";
          };        
          "14" = {
            id = 14;
            name = "TV4 Sport Live 1";
            icon = ./themes/icons/tv/14.png;
            cmd = "open_tv4 && nav_left && nav_down && nav_down && nav_down && nav_select && wait 3 && nav_down && nav_down && nav_down && nav_down && nav_down && nav_right && nav_right && nav_select";
            scrape_url = "https://tv-tabla.se/tabla/tv4_sport_live_1/";
          };
          "15" = {
            id = 15;
            name = "TV4 Sport Live 2";
            icon = ./themes/icons/tv/15.png;
            cmd = "open_tv4 && nav_select && nav_left && nav_down && nav_down && nav_down && nav_select && wait 3 && nav_down && nav_down && nav_down && nav_down && nav_down && nav_down && nav_select";    
            scrape_url = "https://tv-tabla.se/tabla/tv4_sport_live_2/";
          };
          "16" = {
            id = 16;
            name = "TV4 Sport Live 3";
            icon = ./themes/icons/tv/16.png;
            cmd = "open_tv4 && nav_down && nav_right && nav_right && nav_center";
            scrape_url = "https://tv-tabla.se/tabla/tv4_sport_live_3/";
          };
          "17" = {
            id = 17;
            name = "TV4 Sport Live 4";
            icon = ./themes/icons/tv/17.png;
            cmd = "open_tv4 && nav_left && nav_down && nav_down && nav_down && nav_select && wait 3 && nav_down && nav_down && nav_down && nav_down && nav_down && nav_down && nav_right && nav_right && nav_select";
            scrape_url = "https://tv-tabla.se/tabla/tv4_sport_live_4/";
          };       
        };
      };
      # 🦆 says ⮞ Bedroom
      arris = {
        enable = true;
        room = "bedroom";
        ip = "192.168.1.152"; 
        apps = {
          telenor = "se.telenor.stream/.MainActivity   ";
          tv4 = "se.tv4.tv4playtab/se.tv4.tv4play.ui.mobile.main.BottomNavigationActivity";
        };
        channels = {     
          "1" = {
            id = 1;
            name = "SVT1";
            icon = ./themes/icons/tv/1.png;
            scrape_url = "https://tv-tabla.se/tabla/svt1/";
          };
          "2" = {
            id = 2; 
            name = "SVT2";
            icon = ./themes/icons/tv/2.png;
            scrape_url = "https://tv-tabla.se/tabla/svt2/";
          };
          "3" = {
            id = 3;
            name = "Kanal 3";
            icon = ./themes/icons/tv/3.png;
            scrape_url = "https://tv-tabla.se/tabla/tv3/";
          };
          "4" = {
            id = 4;
            name = "TV4";
            icon = ./themes/icons/tv/4.png;
            scrape_url = "https://tv-tabla.se/tabla/tv4/";
          };
          "5" = {
            id = 5;
            name = "TV5";
            icon = ./themes/icons/tv/5.png;
            scrape_url = "https://tv-tabla.se/tabla/kanal_5/";
          };
          "6" = {
            id = 6;
            name = "Kanal 6";
            icon = ./themes/icons/tv/6.png;
            scrape_url = "https://tv-tabla.se/tabla/tv6/";
          };
          "7" = {
            id = 7;
            name = "Sjuan";
            icon = ./themes/icons/tv/7.png;
            scrape_url = "https://tv-tabla.se/tabla/sjuan/";
          };
          "8" = {
            id = 8;
            name = "TV8";
            icon = ./themes/icons/tv/8.png;          
            scrape_url = "https://tv-tabla.se/tabla/tv8/";
          };
          "9" = {
            id = 9;
            name = "Kanal 9";
            icon = ./themes/icons/tv/9.png;          
            scrape_url = "https://tv-tabla.se/tabla/kanal_9/";
          };
          "10" = {
            id = 10;
            name = "Kanal 10";
            icon = ./themes/icons/tv/10.png;
            scrape_url = "https://tv-tabla.se/tabla/tv10/";
          };
          "11" = {
            id = 11;
            name = "Kanal 11";
            icon = ./themes/icons/tv/11.png;
            scrape_url = "https://tv-tabla.se/tabla/tv11/";
          };
          "12" = {
            id = 12;
            name = "Kanal 12";
            icon = ./themes/icons/tv/12.png;
            scrape_url = "https://tv-tabla.se/tabla/tv12/";
          };
          "13" = {
            id = 13;
            name = "TV4 Hockey";
            icon = ./themes/icons/tv/13.png;
            cmd = "nav_down && nav_down && nav_right && nav_right && nav_center";          
            scrape_url = "https://tv-tabla.se/tabla/tv4_hockey/";
          };        
          "14" = {
            id = 14;
            name = "TV4 Sport Live 1";
            icon = ./themes/icons/tv/14.png;
            cmd = "nav_down && nav_down && nav_right && nav_right && nav_center";     
            scrape_url = "https://tv-tabla.se/tabla/tv4_sport_live_1/";
          };
          "15" = {
            id = 15;
            name = "TV4 Sport Live 2";
            icon = ./themes/icons/tv/15.png;
            cmd = "nav_down && nav_down && nav_right && nav_right && nav_center";      
            scrape_url = "https://tv-tabla.se/tabla/tv4_sport_live_2/";
          };
          "16" = {
            id = 16;
            name = "TV4 Sport Live 3";
            icon = ./themes/icons/tv/16.png;
            cmd = "nav_down && nav_down && nav_right && nav_right && nav_center";      
            scrape_url = "https://tv-tabla.se/tabla/tv4_sport_live_3/";
          };
          "17" = {
            id = 17;
            name = "TV 4 Sport Live 4";
            icon = ./themes/icons/tv/17.png;
            cmd = "nav_down && nav_down && nav_right && nav_right && nav_center";
            scrape_url = "https://tv-tabla.se/tabla/tv4_sport_live_4/";
          };       
        };
      };
    };
  };

  sops = {  
    secrets =  {
      api = {
        sopsFile = ./../secrets/api.yaml;
        owner = config.this.user.me.name;
        group = config.this.user.me.name;
        mode = "0440"; # Read-only for owner and group
      };  
    };
    
  };}

