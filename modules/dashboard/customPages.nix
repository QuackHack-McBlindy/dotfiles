# dotfiles/modules/dashboard/customPages.nix.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ custom dashboard pages
  lib, 
  config,
  pkgs,
  ...
}: let 

  # 🦆 says ⮞ get house.tv configuration with debug info
  tvConfig = builtins.trace "TV config: ${builtins.toJSON config.house.tv}" config.house.tv;
    
  # 🦆 says ⮞ generate TV selector options with debug
  tvOptions = let
    tvNames = lib.attrNames tvConfig;
    options = lib.concatMapStrings (tvName: 
      let tv = tvConfig.${tvName};
      in if tv.enable then ''<option value="${tv.ip}">${tvName}</option>'' else ""
    ) tvNames;
  in builtins.trace "TV options: ${options}" options;


  pages = {    
    remote = ''    
      <div class="tv-selector-container">
          <select id="targetTV" class="tv-selector">
              <option value="">🦆 says ▶ pick a TV source</option>
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
            <button class="tv-control-btn channel green" onclick="sendTVCommand('channel_up')">
              <i class="fas fa-arrow-up"></i>
            </button>
            <button class="tv-control-btn volume green" onclick="sendTVCommand('up')">
              <i class="fas fa-volume-up"></i>
            </button>
          </div>

          <!-- 🦆 says ⮞ ROW 2 -->
          <div class="tv-control-row">
            <button class="tv-control-btn channel red" onclick="sendTVCommand('channel_down')">
              <i class="fas fa-arrow-down"></i>
            </button>
            <button class="tv-control-btn volume red" onclick="sendTVCommand('down')">
              <i class="fas fa-volume-down"></i>
            </button>
          </div>

          <!-- 🦆 says ⮞ ROW 3 -->
          <div class="tv-control-row">
            <button class="tv-control-btn icon-only system" onclick="sendTVCommand('menu')">
              <i class="mdi mdi-menu"></i>
            </button>
            <button class="tv-control-btn nav orange" onclick="sendTVCommand('nav_up')">
              <i class="fas fa-arrow-up"></i>
            </button>
            <button class="tv-control-btn icon-only system" onclick="sendTVCommand('home')">
              <i class="mdi mdi-home"></i>
            </button>
          </div>

          <!-- 🦆 says ⮞ ROW 4 - ORANGE with BLUE DUCK center -->
          <div class="tv-control-row">
            <button class="tv-control-btn nav orange" onclick="sendTVCommand('nav_left')">
              <i class="fas fa-arrow-left"></i>
            </button>
            <button class="tv-control-btn ok blue" onclick="sendTVCommand('nav_select')">
              <span class="duck-emoji">🦆</span>
            </button>
            <button class="tv-control-btn nav orange" onclick="sendTVCommand('nav_right')">
              <i class="fas fa-arrow-right"></i>
            </button>
          </div>

          <!-- 🦆 says ⮞ ROW 5 -->
          <div class="tv-control-row">
            <button class="tv-control-btn icon-only system" onclick="sendTVCommand('back')">
              <i class="mdi mdi-arrow-left-circle"></i>
            </button>
            <button class="tv-control-btn nav orange" onclick="sendTVCommand('nav_down')">
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

      <script>             
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

      </script>    

    '';


    health = ''



      <h1 style="text-align:center;">Machines Health</h1>
      <div id="healthContainer" class="health-grid"></div>

      <script>
        async function loadHealthData() {
          try {
            const response = await fetch('http://${config.house.zigbee.mosquitto.host}}:9815/health/all');
            if (!response.ok) throw new Error('HTTP ' + response.status);

            const healthData = await response.json();
            console.log('🦆 Health data from API:', healthData);

            const container = document.getElementById('healthContainer');
            container.innerHTML = "";

            Object.entries(healthData).forEach(([hostname, data]) => {
              createHealthCard(data, container);
            });

          } catch (error) {
            console.error('🦆 Error loading health data:', error);
            document.getElementById('healthContainer').innerHTML = 
              '<div class="error">Failed to fetch data: ' + error.message + '</div>';
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
      


    chat = ''
      <div id="chat-container">            
          <div id="chat">

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
          
          // 🦆 says ⮞ click handler 4 fullscreen bubble
          document.addEventListener('click', function(e) {
            const bubble = e.target.closest('.chat-bubble');
            
            if (!bubble) return;
            if (e.target.closest('button') || 
                e.target.closest('a') || 
                e.target.closest('input') ||
                e.target.closest('video') ||
                e.target.closest('.remove-file-btn') ||
                e.target.closest('.playlist-controls')) {
              return;
            }
            
            // 🦆 says ⮞toggle fullscreen
            bubble.classList.toggle('fullscreen');
            
            if (bubble.classList.contains('fullscreen')) {
              const handleEscape = (event) => {
                if (event.key === 'Escape') {
                  bubble.classList.remove('fullscreen');
                  document.removeEventListener('keydown', handleEscape);
                }
              };
              document.addEventListener('keydown', handleEscape);
              const closeHandler = (event) => {
                if (event.target === bubble || event.target.closest('.chat-bubble') === bubble) {
                  const rect = bubble.getBoundingClientRect();
                  const x = event.clientX;
                  const y = event.clientY;
                  
                  if (x > rect.right - 60 && y < rect.top + 60) {
                    bubble.classList.remove('fullscreen');
                    document.removeEventListener('keydown', handleEscape);
                  }
                }
              };
              
              bubble.addEventListener('click', closeHandler, { once: true });
            }
          });
                 
          // 🦆 says ⮞ message history
          let messageHistory = [];
          let historyIndex = -1;

          // 🦆 says ⮞ add to history when message is sent
          function addToHistory(message) {
              if (!message.trim()) return;

              // 🦆 says ⮞ same as last msg? don't add!
              if (messageHistory.length > 0 && messageHistory[messageHistory.length - 1] === message) {
                  return;
              }
              messageHistory.push(message);

              // 🦆 says ⮞ limit history to 50
              if (messageHistory.length > 50) {
                  messageHistory.shift();
              }
              // 🦆 says ⮞ reset history index to the end
              historyIndex = messageHistory.length;
          }

          // 🦆 says ⮞ navigate history with up/down keys
          function navigateHistory(direction) {
              const promptInput = document.getElementById('prompt');
              if (messageHistory.length === 0) return;

              if (direction === 'up') {
                  if (historyIndex > 0) {
                      historyIndex--;
                  } else {
                      historyIndex = 0;
                  }
              } else if (direction === 'down') {
                  if (historyIndex < messageHistory.length - 1) {
                      historyIndex++;
                  } else {
                      promptInput.value = "";
                      historyIndex = messageHistory.length;
                      return;
                  }
              }

              if (historyIndex >= 0 && historyIndex < messageHistory.length) {
                  promptInput.value = messageHistory[historyIndex];
              }
          }
 
          const AUDIO_CONFIG = {
              enabled: true,
              volume: 0.8
          };

          const API_CONFIG = {
            host: '${config.house.zigbee.mosquitto.host}',
            port: '9815',
            baseUrl: 'http://${config.house.zigbee.mosquitto.host}:9815'
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
          let lastTtsCheck = 0;






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
                  addErrorMessage(`File upload failed: ''${error.message}`);
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

                      apiConnected = true;
                      return true;
                  }
              } catch (error) {
                  console.log('API health check failed:', error);
              }

              apiConnected = false;
              return false;
          }
          


          function enhanceContent(content) {
              // 🦆 says ⮞ cleanup on ile 3!!
              const cleaned = content
                  .split('\n')
                  .filter(line => !line.includes('Loading fuzzy index from:'))
                  .join('\n');

              const noAnsi = cleaned.replace(/\x1b\[[0-9;]*m/g, "");
              const isTerminalOutput = noAnsi.includes('│') || noAnsi.includes('┌') || 
                                       noAnsi.includes('─') || noAnsi.includes('└');
              if (isTerminalOutput) {
                  return {
                      type: 'terminal',
                      content: noAnsi
                  };
              } else {
                  // 🦆 says ⮞ text - convert markdown headers to html
                  let html = noAnsi
                      .replace(/# 🏆(.*)/g, '<h3 style="color: #FFD700; margin: 15px 0 8px 0; font-size: 1.3em; font-weight: bold;">🏆$1</h3>')
                      .replace(/# 🗞️(.*)/g, '<h3 style="color: #4CAF50; margin: 15px 0 8px 0; font-size: 1.3em; font-weight: bold;">🗞️$1</h3>')
                      .replace(/### (.*)/g, '<h5 style="color: #2196F3; margin: 12px 0 6px 0; font-weight: bold;">$1</h5>')
                      .replace(/## (.*)/g, '<h4 style="color: #FF9800; margin: 14px 0 7px 0; font-weight: bold;">$1</h4>')
                      .replace(/# (.*)/g, '<h3 style="color: #4CAF50; margin: 16px 0 8px 0; font-size: 1.3em; font-weight: bold;">$1</h3>')
                      .replace(/\n/g, '<br>');        
                  return {
                      type: 'html',
                      content: html
                  };
              }
          }
      
          // 🦆 says ⮞ let'z make chat handle video/music playlists yo
          function extractVideoUrls(text) {
              const urlRegex = /https?:\/\/[^\s]+/g;
              const urls = text.match(urlRegex) || [];
              return urls.filter(url => {
                  try {
                      const urlObj = new URL(url);
                      const pathname = urlObj.pathname.toLowerCase();
                      const videoExtensions = ['.mp4', '.webm', '.avi', '.mov', '.mkv', '.flv', '.wmv'];
                      const playlistExtensions = ['.m3u', '.m3u8'];
                      
                      if (videoExtensions.some(ext => pathname.endsWith(ext))) {
                          return true;
                      }
                      
                      if (playlistExtensions.some(ext => pathname.endsWith(ext))) {
                          return true;
                      }
                      
                      const streamingKeywords = ['stream', 'hls', 'live', 'm3u8', 'playlist'];
                      const urlLower = url.toLowerCase();
                      return streamingKeywords.some(keyword => urlLower.includes(keyword));
                  } catch (e) {
                      return false;
                  }
              });
          }
          
          function getVideoMimeType(url) {
              try {
                  const urlObj = new URL(url);
                  const pathname = urlObj.pathname.toLowerCase();
                  const extension = pathname.includes('.') ? pathname.split('.').pop() : "";
                  
                  const searchParams = new URLSearchParams(urlObj.search);
                  const formatParam = searchParams.get('format') || "";
                  
                  switch(true) {
                      case extension === 'mp4' || formatParam.includes('mp4'):
                          return 'video/mp4';
                      case extension === 'webm' || formatParam.includes('webm'):
                          return 'video/webm';
                      case extension === 'avi':
                          return "";
                      //    return 'video/x-msvideo';
                      case extension === 'mov':
                          return 'video/quicktime';
                      case extension === 'mkv':
                          return "";                      
                      //    return 'video/x-matroska';
                      case extension === 'flv':
                          return 'video/x-flv';
                      case extension === 'wmv':
                          return 'video/x-ms-wmv';
                      case extension === 'm3u' || extension === 'm3u8' || formatParam.includes('hls'):
                          return 'application/vnd.apple.mpegurl';
                      default:
                          if (url.includes('hls') || url.includes('m3u')) {
                              return 'application/vnd.apple.mpegurl';
                          }
                          return 'video/mp4';
                  }
              } catch (e) {
                  return 'application/vnd.apple.mpegurl';
              }
          }

          let hlsJsLoaded = false;
          let hlsJsLoading = false;
          
          function loadHlsJs() {
              return new Promise((resolve, reject) => {
                  if (typeof Hls !== 'undefined' && Hls.isSupported()) {
                      hlsJsLoaded = true;
                      resolve(true);
                      return;
                  }
                  
                  if (hlsJsLoading) {
                      const checkInterval = setInterval(() => {
                          if (typeof Hls !== 'undefined') {
                              clearInterval(checkInterval);
                              hlsJsLoaded = true;
                              resolve(true);
                          }
                      }, 100);
                      return;
                  }
                  
                  hlsJsLoading = true;
                  const script = document.createElement('script');
                  script.src = 'https://cdn.jsdelivr.net/npm/hls.js@1.4.10/dist/hls.min.js';
                  script.onload = function() {
                      hlsJsLoading = false;
                      if (typeof Hls !== 'undefined' && Hls.isSupported()) {
                          hlsJsLoaded = true;
                          console.log('🦆 HLS.js loaded successfully');
                          resolve(true);
                      } else {
                          console.warn('🦆 HLS.js loaded but not supported');
                          resolve(false);
                      }
                  };
                  script.onerror = function() {
                      hlsJsLoading = false;
                      console.warn('🦆 Failed to load HLS.js');
                      resolve(false);
                  };
                  document.head.appendChild(script);
              });
          }
          
          // 🦆 says ⮞ playlist?
          function isPlaylistUrl(url) {
              try {
                  const urlObj = new URL(url);
                  const pathname = urlObj.pathname.toLowerCase();
                  return pathname.endsWith('.m3u') || 
                         pathname.endsWith('.m3u8') || 
                         url.toLowerCase().includes('m3u8') ||
                         url.toLowerCase().includes('/hls/') ||
                         url.toLowerCase().includes('playlist');
              } catch (e) {
                  return false;
              }
          }
          
          // 🦆says⮞ m3u ?
          async function isSimpleM3U(url) {
              try {
                  const response = await fetch(url);
                  const text = await response.text();
                  const firstLine = text.split('\n')[0].trim();
                  return !firstLine.startsWith('#');
              } catch (e) {
                  return false;
              }
          }
     
          // 🦆 says ⮞ create HLS video player
          function createHlsPlayer(videoUrl, container) {
              const video = document.createElement('video');
              video.controls = true;
              video.style.maxWidth = '100%';
              video.style.borderRadius = '8px';
              video.style.background = '#000';
              video.style.marginBottom = '10px';
              
              const statusDiv = document.createElement('div');
              statusDiv.className = 'hls-status';
              statusDiv.style.fontSize = '0.9em';
              statusDiv.style.color = '#666';
              statusDiv.style.marginTop = '5px';
              statusDiv.textContent = 'Loading HLS stream...';
              
              const errorDiv = document.createElement('div');
              errorDiv.className = 'hls-error';
              errorDiv.style.fontSize = '0.9em';
              errorDiv.style.color = '#ff4444';
              errorDiv.style.marginTop = '5px';
              errorDiv.style.display = 'none';
              
              const source = document.createElement('source');
              source.src = videoUrl;
              source.type = 'application/vnd.apple.mpegurl';
              video.appendChild(source);
              
              container.appendChild(video);
              container.appendChild(statusDiv);
              container.appendChild(errorDiv);
              
              loadHlsJs().then(hlsAvailable => {
                  if (hlsAvailable && Hls.isSupported()) {
                      const hls = new Hls({
                          debug: false,
                          enableWorker: true,
                          lowLatencyMode: true,
                          backBufferLength: 90
                      });
                      
                      hls.loadSource(videoUrl);
                      hls.attachMedia(video);
                      
                      hls.on(Hls.Events.MANIFEST_PARSED, function() {
                          statusDiv.textContent = 'HLS stream ready';
                          statusDiv.style.color = '#4CAF50';
                          video.play().catch(e => {
                              console.log('Auto-play prevented:', e);
                              statusDiv.textContent = 'Click play to start stream';
                          });
                      });
                      
                      hls.on(Hls.Events.ERROR, function(event, data) {
                          console.warn('🦆 HLS error:', data);
                          if (data.fatal) {
                              switch(data.type) {
                                  case Hls.ErrorTypes.NETWORK_ERROR:
                                      statusDiv.textContent = 'Network error, trying fallback...';
                                      hls.startLoad();
                                      break;
                                  case Hls.ErrorTypes.MEDIA_ERROR:
                                      statusDiv.textContent = 'Media error, trying fallback...';
                                      hls.recoverMediaError();
                                      break;
                                  default:
                                      statusDiv.textContent = 'Stream error, trying native playback...';
                                      hls.destroy();
                                      video.src = videoUrl;
                                      errorDiv.textContent = 'Using native playback (may not work in all browsers)';
                                      errorDiv.style.display = 'block';
                                      break;
                              }
                          }
                      });
                  } else if (video.canPlayType('application/vnd.apple.mpegurl')) {
                      statusDiv.textContent = 'Using native HLS playback (Safari/Apple devices)';
                      video.src = videoUrl;
                      video.load();
                  } else {
                      statusDiv.textContent = 'HLS not supported in this browser';
                      statusDiv.style.color = '#ff4444';
                      errorDiv.textContent = 'For HLS streams, use Chrome/Firefox or Safari on Apple devices';
                      errorDiv.style.display = 'block';
                      
                      const link = document.createElement('a');
                      link.href = videoUrl;
                      link.target = '_blank';
                      link.textContent = 'Open stream in external player';
                      link.style.display = 'block';
                      link.style.marginTop = '10px';
                      link.style.color = '#2196F3';
                      errorDiv.appendChild(link);
                  }
              });
              
              return video;
          }
          
          // 🦆 says ⮞ create a player that cycles a playlist
          function createPlaylistPlayer(videoUrls, container, isLocalFile) {
              const video = document.createElement('video');
              video.controls = true;
              video.style.maxWidth = '100%';
              video.style.borderRadius = '8px';
              video.style.background = '#000';
              video.style.marginBottom = '10px';

              const controlsDiv = document.createElement('div');
              controlsDiv.className = 'playlist-controls';
              controlsDiv.style.marginTop = '10px';
              controlsDiv.style.fontSize = '0.9em';
              controlsDiv.style.color = '#666';

              let currentIndex = 0;
              let isPlaying = false;

              // 🦆 says ⮞ load and play specific index
              function playVideoAtIndex(index) {
                  if (index < 0 || index >= videoUrls.length) return;
                  currentIndex = index;
                  const currentUrl = videoUrls[currentIndex];
  
                  video.src = currentUrl;
                  video.load();
  
                  updateControls();
  
                  if (isPlaying) {
                      video.play().catch(e => {
                          console.log('Auto-play prevented:', e);
                          isPlaying = false;
                      });
                  }
              }

              // 🦆 says ⮞ update playback controls
              function updateControls() {
                  controlsDiv.innerHTML = `
                      <div style="margin-bottom: 5px;">
                          <span>''${currentIndex + 1}/''${videoUrls.length}: ''${videoUrls[currentIndex].split('/').pop() || 'Video'}</span>
                      </div>
                      <div>
                          <button onclick="playPrev()" style="margin-right: 10px; background: #2196F3; color: white; border: none; padding: 5px 10px; border-radius: 4px; cursor: pointer;">◀ Prev</button> <button onclick="playNext()" style="background: #4CAF50; color: white; border: none; padding: 5px 10px; border-radius: 4px; cursor: pointer;">Next ▶</button>                            
                      </div>
                  `;
              }

              // 🦆 says ⮞ playback buttons
              window.playPrev = () => {
                  if (currentIndex > 0) {
                      playVideoAtIndex(currentIndex - 1);
                  }
              };

              window.playNext = () => {
                  if (currentIndex < videoUrls.length - 1) {
                      playVideoAtIndex(currentIndex + 1);
                  } else {
                      playVideoAtIndex(0);
                  }
              };

              // 🦆 says ⮞ event listener 4 first item ends
              video.addEventListener('ended', () => {
                  isPlaying = false;
                  if (currentIndex < videoUrls.length - 1) {
                      setTimeout(() => {
                          playNext();
                          video.play().catch(e => console.log('Auto-play prevented after end:', e));
                      }, 500);
                  }
              });

              video.addEventListener('play', () => { isPlaying = true; });
              video.addEventListener('pause', () => { isPlaying = false; });

              container.appendChild(video);
              container.appendChild(controlsDiv);
              playVideoAtIndex(0);

              return video;
          }
          
          function createRegularVideoPlayer(videoUrl, container) {
              const video = document.createElement('video');
              video.controls = true;
              video.style.maxWidth = '100%';
              video.style.borderRadius = '8px';
              video.style.background = '#000';
              video.style.marginBottom = '10px';
              // 🦆 says ⮞ crossorigin to handle CORS
              video.crossOrigin = 'anonymous';

              const source = document.createElement('source');
              source.src = videoUrl;
              source.type = getVideoMimeType(videoUrl);
              video.appendChild(source);
              
              const fallback = document.createElement('p');
              fallback.textContent = 'Your browser does not support this video format. ';
              fallback.style.color = '#666';
              fallback.style.fontSize = '0.9em';
              fallback.style.marginTop = '5px';
              
              const downloadLink = document.createElement('a');
              downloadLink.href = videoUrl;
              downloadLink.target = '_blank';
              downloadLink.textContent = 'Download video';
              downloadLink.style.color = '#2196F3';
              downloadLink.style.textDecoration = 'none';
              downloadLink.style.marginLeft = '5px';
              
              fallback.appendChild(downloadLink);
              video.appendChild(fallback);
              
              container.appendChild(video);
              return video;
          }
                   
          function addAIMessage(content, options = {}) {
              const chatContainer = document.getElementById('chat');
              const typingIndicator = document.querySelector('.typing-indicator');
              if (typingIndicator) {
                  chatContainer.removeChild(typingIndicator);
              }
              
              const videoUrls = extractVideoUrls(content);
              let textContent = content;
              
              videoUrls.forEach(url => {
                  textContent = textContent.replace(url, "").trim();
              });
              
              const enhanced = enhanceContent(textContent);
              const aiBubble = document.createElement('div');
              aiBubble.className = 'chat-bubble ai-bubble';
              
              if (enhanced.type === 'terminal') {
                  const pre = document.createElement('pre');
                  pre.style.cssText = `
                      font-family: 'Fira Code', 'DejaVu Sans Mono', monospace;
                      white-space: pre;
                      overflow-x: auto;
                      margin: 0;
                      padding: 15px;
                      background: #1e1e1e;
                      color: #f0f0f0;
                      border-radius: 10px;
                      border: 1px solid #333;
                      font-size: 13px;
                      line-height: 1.4;
                      max-height: 400px;
                      overflow-y: auto;
                  `;
                  pre.textContent = enhanced.content;
                  aiBubble.appendChild(pre);
              } else if (textContent.trim()) {
                  aiBubble.innerHTML = enhanced.content;
              }
              
              if (videoUrls.length > 0) {
                  if (textContent.trim()) {
                      const separator = document.createElement('div');
                      separator.style.height = '20px';
                      aiBubble.appendChild(separator);
                  }
                  
                  videoUrls.forEach((videoUrl, index) => {
                      const videoContainer = document.createElement('div');
                      videoContainer.className = 'video-container';
                      
                      const title = document.createElement('div');
                      title.className = 'video-title';
                      title.textContent = `Media: ''${videoUrl.split('/').pop() || 'Stream'}`;
                      title.style.fontWeight = 'bold';
                      title.style.marginBottom = '10px';
                      title.style.color = '#2196F3';
                      videoContainer.appendChild(title);
                      
                      const isLocalFile = videoUrl.startsWith('file://') || videoUrl.startsWith('/');
                      const isPlaylist = isPlaylistUrl(videoUrl);

                      if (isPlaylist) {
                          // 🦆 says ⮞ playlist? fetch and play all
                          (async () => {
                              try {
                                  const response = await fetch(videoUrl);
                                  const text = await response.text();
                                  const videoUrlsList = text.split('\n')
                                      .map(line => line.trim())
                                      .filter(line => line && !line.startsWith('#') && line.length > 0);

                                  if (videoUrlsList.length === 0) {
                                      videoContainer.innerHTML = 'No valid video URLs found in playlist';
                                      return;
                                  }
                                  console.log('🦆 Playlist detected with', videoUrlsList.length, 'items');

                                  createPlaylistPlayer(videoUrlsList, videoContainer, isLocalFile);
                              } catch (error) {
                                  console.error('Failed to process playlist:', error);
                                  videoContainer.innerHTML = `Failed to load playlist: ''${error.message}`;
                              }
                          })();
                      } else {
                          createRegularVideoPlayer(videoUrl, videoContainer, isLocalFile);
                      }
                      
                      const infoDiv = document.createElement('div');
                      infoDiv.style.marginTop = '8px';
                      infoDiv.style.fontSize = '0.85em';
                      infoDiv.style.color = '#666';
                                                  
                      videoContainer.appendChild(infoDiv);
                      aiBubble.appendChild(videoContainer);
                  });
              }
              
              chatContainer.appendChild(aiBubble);
              chatContainer.scrollTop = chatContainer.scrollHeight;
              
              const playTTSAudio = async () => {
                  try {
                      const response = await fetch('/tts/tts.wav', { method: 'HEAD' });
                      if (!response.ok) return;
                      const lastModified = new Date(response.headers.get('Last-Modified')).getTime();
                      const now = Date.now();
                      const lastCheck = window.lastTtsCheck || 0;
                      
                      if (lastModified > lastCheck && (now - lastModified) < 30000) {
                          const cacheBuster = Date.now();
                          const audio = new Audio(`/tts/tts.wav?cb=''${cacheBuster}`);
                          audio.volume = AUDIO_CONFIG.enabled ? AUDIO_CONFIG.volume : 0;
                          audio.play().catch(error => {
                              console.warn('Audio playback failed:', error);
                          });
                          window.lastTtsCheck = lastModified;
                      }
                  } catch (error) {
                      console.warn('TTS check failed:', error);
                  }
              };
              setTimeout(() => {
                  playTTSAudio().catch(console.error);
              }, 500);
          }
          
          function createStreamingPlayer(videoUrl, container, isLocalFile) {
              const video = document.createElement('video');
              video.controls = true;
              video.style.maxWidth = '100%';
              video.style.borderRadius = '8px';
              video.style.background = '#000';
              video.style.marginBottom = '10px';
              video.preload = 'auto';
              
              const statusDiv = document.createElement('div');
              statusDiv.className = 'stream-status';
              statusDiv.style.fontSize = '0.9em';
              statusDiv.style.color = '#666';
              statusDiv.style.marginTop = '5px';
              statusDiv.textContent = 'Testing stream accessibility...';
              
              const errorDiv = document.createElement('div');
              errorDiv.className = 'stream-error';
              errorDiv.style.fontSize = '0.9em';
              errorDiv.style.color = '#ff4444';
              errorDiv.style.marginTop = '5px';
              errorDiv.style.display = 'none';
              
              container.appendChild(video);
              container.appendChild(statusDiv);
              container.appendChild(errorDiv);
              
              testStreamAccessibility(videoUrl).then(accessible => {
                  if (!accessible) {
                      statusDiv.textContent = 'Stream not accessible (CORS/network issue)';
                      statusDiv.style.color = '#ff9800';
                      return;
                  }
                  
                  statusDiv.textContent = 'Stream accessible, loading player...';   
                  loadHlsJs().then(hlsAvailable => {
                      if (hlsAvailable && Hls.isSupported()) {
                          const hls = new Hls({
                              debug: false,
                              enableWorker: true,
                              lowLatencyMode: true,
                              xhrSetup: function(xhr, url) {
                                  xhr.withCredentials = false;
                              }
                          });
                          
                          hls.loadSource(videoUrl);
                          hls.attachMedia(video);
                          
                          hls.on(Hls.Events.MANIFEST_PARSED, function() {
                              statusDiv.textContent = 'Stream ready - click play';
                              statusDiv.style.color = '#4CAF50';
                              video.play().catch(e => {
                                  console.log('Auto-play prevented, waiting for user interaction');
                              });
                          });
                          
                          hls.on(Hls.Events.ERROR, function(event, data) {
                              console.warn('Stream error:', data);
                              if (data.fatal) {
                                  hls.destroy();
                                  statusDiv.textContent = 'HLS playback failed';
                                  statusDiv.style.color = '#ff4444';
                                                                         
                                  if (video.canPlayType('application/vnd.apple.mpegurl')) {
                                      video.src = videoUrl;
                                      video.load();
                                  }
                              }
                          });
                      } else if (video.canPlayType('application/vnd.apple.mpegurl')) {
                          statusDiv.textContent = 'Using Safari native HLS playback';
                          video.src = videoUrl;
                          video.load();
                      } else {
                          statusDiv.textContent = 'HLS not supported in this browser';
                          statusDiv.style.color = '#ff4444';
                      }
                  });
              }).catch(error => {
                  statusDiv.textContent = 'Cannot test stream accessibility';
                  statusDiv.style.color = '#ff4444';
                  errorDiv.textContent = `Error: ''${error.message}`;
                  errorDiv.style.display = 'block';
              });
          }
          
          async function testStreamAccessibility(url) {
              try {
                  const response = await fetch(url, {
                      method: 'HEAD',
                      mode: 'cors',
                      cache: 'no-cache'
                  });
                  return response.ok;
              } catch (headError) {
                  console.log('HEAD failed, trying GET with timeout:', headError);        
                  try {
                      const controller = new AbortController();
                      const timeoutId = setTimeout(() => controller.abort(), 5000);       
                      const response = await fetch(url, {
                          method: 'GET',
                          mode: 'cors',
                          cache: 'no-cache',
                          signal: controller.signal,
                          headers: {
                              'Range': 'bytes=0-100'
                          }
                      });
                      
                      clearTimeout(timeoutId);
                      return response.ok;
                  } catch (getError) {
                      console.log('GET also failed:', getError);
                      return false;
                  }
              }
          }
                        
          // 🦆 says ⮞ FUCK!
          function addErrorMessage(text) {
              const chatContainer = document.getElementById('chat');
              const typingIndicator = document.querySelector('.typing-indicator');
              if (typingIndicator) {
                  chatContainer.removeChild(typingIndicator);
              }

              const cleanedText = text
                  .split('\n')
                  .filter(line => !line.includes('Loading fuzzy index from:'))
                  .join('\n');

              const errorBubble = document.createElement('div');
              errorBubble.className = 'chat-bubble error-special-bubble';

              // 🦆 says ⮞ extraction
              const errorMatch = cleanedText.match(/🦆 says ⮞ fuck ❌[^\n]*/);
              const errorMessage = errorMatch ? errorMatch[0].replace('🦆 says ⮞ ', "") : 'Error!';

              errorBubble.innerHTML = `
                  <div class="error-special-text">🦆says⮞''${errorMessage}</div>
              `;

              chatContainer.appendChild(errorBubble);

              const matches = [];
              const lines = cleanedText.split('\n');
              lines.forEach(line => {
                  const match = line.match(/(\d+)%:\s*'([^']+)'\s*->\s*(.*)/);
                  if (match) {
                      const [, percentage, pattern, command] = match;
                      matches.push({ percentage, pattern, command });
                  }
              });

              if (matches.length > 0) {
                  const suggestionBubble = document.createElement('div');
                  suggestionBubble.className = 'chat-bubble suggestion-header-bubble';
                  suggestionBubble.innerHTML = `
                      <div class="suggestion-header">Did you mean?</div>
                  `;
                  chatContainer.appendChild(suggestionBubble);
  
                  matches.forEach(match => {
                      const matchBubble = document.createElement('div');
                      matchBubble.className = 'chat-bubble suggestion-match-bubble';
                      matchBubble.innerHTML = `
                          <div class="match-percentage">''${match.percentage}% match</div>
                          <div class="match-pattern">''${match.pattern}</div>
                          <div class="match-command">→ ''${match.command}</div>
                      `;

                      matchBubble.style.cursor = 'pointer';
                      matchBubble.addEventListener('click', () => {
                          document.getElementById('prompt').value = match.pattern.replace(/\{[^}]+\}/g, '...');
                          sendMessage();
                      });
                      chatContainer.appendChild(matchBubble);
                  });
              }

              chatContainer.scrollTop = chatContainer.scrollHeight;

              // 🦆 says ⮞ FUCK.wav
              const playFailAudio = () => {
                  const cacheBuster = Date.now() + '-' + Math.random().toString(36).substr(2, 9);
                  const audio = new Audio('/tts/fail.wav?' + cacheBuster);
                  audio.volume = AUDIO_CONFIG.enabled ? AUDIO_CONFIG.volume : 0.8;
                  audio.play().catch(error => {
                      console.warn('Fail audio playback failed:', error);
                  });
              };
              setTimeout(playFailAudio, 300);
          }

          function formatCommandError(errorText) {
            const lines = errorText.split('\n');
            let html = "";

            lines.forEach(line => {
              if (line.includes('Input:')) {
                html += `<div class="error-input"><strong>Your input:</strong> ''${line.replace('Input: ', "")}</div>`;
              } else if (line.includes('%:')) {
                const match = line.match(/(\d+)%:\s*'([^']+)'\s*->\s*(.*)/);
                if (match) {
                  const [, percentage, pattern, command] = match;
                  html += `
                    <div class="close-match">
                      <span class="match-percentage">''${percentage}% match:</span>
                      <code class="match-pattern">''${pattern}</code>
                      <span class="match-command">→ ''${command}</span>
                    </div>
                  `;
                }
              } else if (!line.includes('Loading fuzzy index')) {
                html += line + '<br>';
              }
            });

            return html;
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
                  addErrorMessage("Not connected to API. Check if the API server is running.");
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
                  addErrorMessage("Failed to send command to API. Please check the connection.");
                  return false;
              }
          }
          
          async function sendNaturalLanguageCommand(command) {
            try {
              const password = getAuthToken();
              const response = await fetch(API_CONFIG.baseUrl + '/do?cmd=' + encodeURIComponent(command) + '&password=' + encodeURIComponent(password));
              console.error(response); 
              if (response.ok) {
                let responseText = await response.text();
                console.error(responseText); 
                const rawOutput = extractOutputFromResponse(responseText);
                console.error(rawOutput);
                const cleanOutput = cleanAPIResponse(rawOutput);
                console.error(cleanOutput);
                const isError = cleanOutput.match(/(No matching command found|System rebuild failed)/);

                if (isError) {   
                  addErrorMessage(cleanOutput);
                } else {
                  addAIMessage(cleanOutput);
                }
                return true;
              } else {
                addErrorMessage('API Error: ' + response.status + ' - ' + response.statusText);
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
                  addToHistory(prompt);
              }             
              promptInput.value = "";
              historyIndex = messageHistory.length;
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
              } else if (event.key === 'ArrowUp') {
                  event.preventDefault();
                  navigateHistory('up');
              } else if (event.key === 'ArrowDown') {
                  event.preventDefault();
                  navigateHistory('down');
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
                  addAIMessage("Quack quack! I'm a 🦆 here to help! Qwack me a question yo!");
              }
          }, 2000);
          
          setInterval(checkAPIHealth, 30000);
      </script>  


      
    '';
  };

in {
  pages = pages;
}
