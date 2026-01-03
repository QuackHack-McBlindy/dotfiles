# dotfiles/bin/home/duckDash.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ auto generate smart home dashboard
  self, 
  config,
  lib, 
  pkgs,
  cmdHelpers,
  ...
}: let 
  css = {
    global  = builtins.readFile ./../../modules/themes/css/duckdash/global.css;
    home    = builtins.readFile ./../../modules/themes/css/duckdash/home.css;
    devices = builtins.readFile ./../../modules/themes/css/duckdash/devices.css;
    scenes  = builtins.readFile ./../../modules/themes/css/duckdash/scenes.css;
    tv      = builtins.readFile ./../../modules/themes/css/duckdash/tv.css;
  };


  enhancedChartJs = ''
    function renderEnhancedChart(cardId, historyData, color) {
      const canvas = document.getElementById('status-' + cardId + '-chart');
      if (!canvas) return;
      
      // 🦆 says ⮞ destroy current chart with style
      if (canvas.chartInstance) {
        canvas.chartInstance.destroy();
        canvas.classList.add('fade-out');
        setTimeout(() => canvas.classList.remove('fade-out'), 300);
      }
      
      // 🦆 says ⮞ calc delta
      const currentValue = historyData[historyData.length - 1];
      const previousValue = historyData.length > 1 ? historyData[historyData.length - 2] : currentValue;
      const delta = ((currentValue - previousValue) / (previousValue || 1) * 100).toFixed(1);
      
      // 🦆 says ⮞ animated delta display
      const deltaElement = document.getElementById('status-' + cardId + '-delta');
      if (deltaElement) {
        const arrow = delta >= 0 ? 'fa-arrow-up' : 'fa-arrow-down';
        deltaElement.innerHTML = '<i class="fas ' + arrow + '"></i> ' + Math.abs(delta) + '%';
        deltaElement.style.color = delta >= 0 ? '#22c55e' : '#ef4444';
        deltaElement.style.background = delta >= 0 ? 
          'rgba(34, 197, 94, 0.2)' : 'rgba(239, 68, 68, 0.2)';
        
        // 🦆 says ⮞ bounce animation
        deltaElement.classList.add('delta-update');
        setTimeout(() => deltaElement.classList.remove('delta-update'), 1000);
      }
      
      // 🦆 says ⮞ create gradient for chart
      const ctx = canvas.getContext('2d');
      const gradient = ctx.createLinearGradient(0, 0, 0, canvas.height);
      gradient.addColorStop(0, color + '80');
      gradient.addColorStop(0.7, color + '20');
      gradient.addColorStop(1, color + '05');
      
      // 🦆 says ⮞ create gradient for border
      const borderGradient = ctx.createLinearGradient(0, 0, canvas.width, 0);
      borderGradient.addColorStop(0, '#00e5ff');
      borderGradient.addColorStop(0.5, color);
      borderGradient.addColorStop(1, '#ff00ff');
      
      // 🦆 says ⮞ ultra maxd personality chart config
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
            x: {
              display: false,
              grid: { display: false }
            },
            y: {
              display: false,
              grid: {
                color: 'rgba(255, 255, 255, 0.1)',
                drawBorder: false
              },
              beginAtZero: false
            }
          },
          elements: {
            line: {
              tension: 0.4
            }
          },
          interaction: {
            intersect: false,
            mode: 'index'
          }
        }
      });
      
      // 🦆 says ⮞ particles for temperature charts
      if (cardId === 'temperature') {
        addChartParticles(canvas, historyData, color);
      }
    }
    
    // 🦆 says ⮞ floating particles to temperature chart
    function addChartParticles(canvas, data, color) {
      const particleContainer = document.createElement('div');
      particleContainer.className = 'chart-particles';
      particleContainer.style.position = 'absolute';
      particleContainer.style.top = '0';
      particleContainer.style.left = '0';
      particleContainer.style.width = '100%';
      particleContainer.style.height = '100%';
      particleContainer.style.pointerEvents = 'none';
      particleContainer.style.zIndex = '1';
      
      canvas.parentNode.style.position = 'relative';
      canvas.parentNode.appendChild(particleContainer);
      
      for (let i = 0; i < 10; i++) {
        const particle = document.createElement('div');
        particle.className = 'chart-particle';
        particle.style.position = 'absolute';
        particle.style.width = '4px';
        particle.style.height = '4px';
        particle.style.background = color;
        particle.style.borderRadius = '50%';
        particle.style.opacity = '0.6';
        particle.style.filter = 'blur(1px)';
        
        const x = Math.random() * 100;
        const y = Math.random() * 100;
        particle.style.left = x + '%';
        particle.style.top = y + '%';
        
        particle.animate([
          { 
            transform: 'translate(0, 0) scale(1)',
            opacity: 0.6 
          },
          { 
            transform: 'translate(' + (Math.random() * 20 - 10) + 'px, ' + (Math.random() * 20 - 10) + 'px) scale(1.5)',
            opacity: 0.2 
          }
        ], {
          duration: 2000 + Math.random() * 2000,
          iterations: Infinity,
          direction: 'alternate',
          easing: 'ease-in-out'
        });
        
        particleContainer.appendChild(particle);
      }
    }
    

    function updateCardValueWithAnimation(cardId, value) {
      const element = document.getElementById('status-' + cardId + '-value');
      if (!element) return;
      
      element.classList.add('value-update');
      
      const oldValue = parseFloat(element.textContent) || 0;
      const newValue = parseFloat(value) || 0;
      
      animateNumber(element, oldValue, newValue, 500);
      
      if (cardId === 'temperature') {
        let tempColor;
        if (newValue < 18) tempColor = '#3498db'; // Cold
        else if (newValue < 22) tempColor = '#2ecc71'; // Comfortable
        else if (newValue < 26) tempColor = '#f39c12'; // Warm
        else tempColor = '#e74c3c'; // Hot
        
        element.style.color = tempColor;
        element.style.textShadow = '0 0 20px ' + tempColor + ', 0 0 40px ' + tempColor + '40';
      }
      
      setTimeout(() => element.classList.remove('value-update'), 500);
    }
    
    // 🦆 says ⮞ Smooth number animation
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
    
    // 🦆 says ⮞ QUACK SOUND EFFECTS!
    function playQuackSound() {
      try {
        const audioContext = new (window.AudioContext || window.webkitAudioContext)();
        
        const oscillator = audioContext.createOscillator();
        const gainNode = audioContext.createGain();
        
        oscillator.connect(gainNode);
        gainNode.connect(audioContext.destination);
        
        oscillator.type = 'sine';
        oscillator.frequency.setValueAtTime(800, audioContext.currentTime);
        oscillator.frequency.exponentialRampToValueAtTime(400, audioContext.currentTime + 0.1);
        oscillator.frequency.exponentialRampToValueAtTime(600, audioContext.currentTime + 0.15);
        
        gainNode.gain.setValueAtTime(0.3, audioContext.currentTime);
        gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + 0.2);
        
        oscillator.start(audioContext.currentTime);
        oscillator.stop(audioContext.currentTime + 0.2);
        
        document.querySelectorAll('.duck-emoji').forEach(duck => {
          duck.style.animation = 'quackFast 0.5s ease-in-out';
          setTimeout(() => duck.style.animation = "", 500);
        });
        
      } catch (e) {
        console.log('🦆 No audio support, but still quacking in spirit!');
      }
    }
  '';


  pageFilesAndCss = let
    pages = config.house.dashboard.pages;
  in lib.concatStrings (lib.mapAttrsToList (pageId: page: 
    if page.css != "" then "echo '${page.css}' > $WORKDIR/page-${pageId}.css;" else ""
  ) pages);


  # 🦆 says ⮞ generate html for status cards
  statusCardsHtml = lib.concatStrings (lib.mapAttrsToList (name: card: 
    if card.enable then ''
      <div class="card${if card.chart then " has-chart" else ""}${if name == "temperature" then " quacking" else ""}" 
           data-card="${name}"
           style="border-color: ${card.color}; --card-glow-color: ${card.color}40;">
        
        ${if name == "temperature" then ''
          <div class="duck-emoji">🦆</div>
        '' else ""}
        
        <div class="card-header">
          <div class="card-title">${card.title}</div>
          <i class="${card.icon}" style="color: ${card.color}; 
            text-shadow: 0 0 15px ${card.color}80;"></i>
        </div>
        
        <div class="card-value" id="status-${name}-value" 
             style="color: ${card.color};">
          ${card.defaultValue}
        </div>
        
        ${if (card.detailsJsonField != null) || (card.details != "") then ''
          <div class="card-details">
            <i class="fas fa-info-circle"></i>
            <span id="status-${name}-details">${card.defaultDetails}</span>
          </div>
        '' else ""}
        
        ${if card.chart then ''
          <div class="card-delta" id="status-${name}-delta"
               style="background: ${card.color}30; color: ${card.color};">
            <i class="fas fa-arrow-up"></i> 0%
          </div>
          <div class="card-chart">
            <canvas id="status-${name}-chart"></canvas>
          </div>
        '' else ""}
      </div>
    '' else ""
  ) config.house.dashboard.statusCards);


  # 🦆 says ⮞ Enhanced update function
  enhancedUpdateAllCardsJs = let
    functionCalls = lib.mapAttrsToList (name: card: 
      if card.enable then 
        "update${lib.toUpper (lib.substring 0 1 name)}${lib.substring 1 (lib.stringLength name) name}Card();"
      else ""
    ) config.house.dashboard.statusCards;
  in ''
    // 🦆 says ⮞ Update all cards with personality!
    function updateAllStatusCards() {
      console.log('🦆 QUACK QUACK QUACK! Updating all cards!');
      
      // 🦆 says ⮞ Show loading state
      document.querySelectorAll('.card').forEach(card => {
        card.classList.add('loading-temp');
      });
      
      // 🦆 says ⮞ Update each card
      ${lib.concatStringsSep "\n      " functionCalls}
      
      // 🦆 says ⮞ Remove loading state
      setTimeout(() => {
        document.querySelectorAll('.card').forEach(card => {
          card.classList.remove('loading-temp');
        });
      }, 1000);
    }
  '';


  # 🦆 says ⮞ generate js update functions
  statusCardsJs = let
    cardUpdates = lib.mapAttrsToList (name: card: 
      if card.enable then ''
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
              
              ${if card.chart then ''
                const historyData = data['${card.historyField}'];
                if (historyData && Array.isArray(historyData) && historyData.length > 0) {
                  updateCardChart("${name}", historyData, '${card.color}');
                }
              '' else ""}
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
  customPagesJs = " ";

  # 🦆 says ⮞ Interactive card click handler JS
  interactiveCardJs = ''
    // 🦆 says ⮞ Interactive card clicks
    document.addEventListener('DOMContentLoaded', () => {
      setTimeout(() => {
        document.querySelectorAll('.card').forEach(card => {
          card.addEventListener('click', function() {
            // 🦆 says ⮞ Add click animation
            this.style.transform = 'scale(0.95)';
            setTimeout(() => {
              this.style.transform = "";
            }, 200);
            
            // 🦆 says ⮞ Play click sound (only sometimes)
            if (Math.random() > 0.5) {
              playQuackSound();
            }
          });
          
          // 🦆 says ⮞ Hover effects
          card.addEventListener('mouseenter', function() {
            this.style.zIndex = '10';
          });
          
          card.addEventListener('mouseleave', function() {
            this.style.zIndex = "";
          });
        });
      }, 1000);
    });
  '';



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
  roomControlsHtml = ''
    <div class="room-controls-section">
      <h3>🦆 ROOOOOMS CONTROL 🦆</h3>
      <div class="rooms" id="roomsContainer">
        ${lib.concatMapStrings (room: 
          let 
            iconName = lib.removePrefix "mdi:" (roomIcons.${room} or "mdi:home");
            roomLights = devicesByRoom.${room} or [];
            hasLights = roomLights != [];
            roomId = lib.toLower (lib.replaceStrings [" "] ["-"] room);
          in
            if hasLights then ''
              <div class="room" id="room-${roomId}" data-room="${roomId}">
                <div class="room-header">
                  <!-- Add brightness indicator overlay -->
                  <div class="brightness-indicator"></div>
                  <div class="brightness-value-display">100%</div>
                  </div>

                  <div class="room-brightness-container">
                  <div class="room-title">
                    <i class="mdi mdi-${iconName} room-icon"></i>
                    <span class="room-name">${lib.toUpper room}</span>
                  </div>
                  <div class="room-controls">
                    
                    <button class="collapse-btn" title="Expand/Collapse">▸</button>
                  </div>
                </div>
              
                <div class="room-brightness-container">
                  <div class="room-brightness-label">
                    <span>☀️</span>
                    <span class="brightness-value">100%</span>
                  </div>
                  <input class="brightness room-brightness" type="range" min="0" max="100" value="100" 
                         title="Adjust room brightness">
                </div>
                
                <div class="devices hidden" id="devices-${roomId}">
                  ${lib.concatMapStrings (device: 
                    let
                      deviceIconName = lib.removePrefix "mdi:" (device.icon or "mdi:lightbulb");
                      supportsColor = device.supports_color or false;
                      deviceColor = if device ? color && device.color ? hex then device.color.hex else "#ffffff";
                      deviceIdSafe = lib.replaceStrings [" " "/" "\\" "."] ["-" "-" "-" "-"] device.id;
                    in ''
                      <div class="device" id="device-${deviceIdSafe}" data-device="${device.id}">
                        <div class="device-top">
                          <div class="device-icon-container">
                            <div class="device-name">${device.friendly_name or device.id}</div>
                          </div>
                          <div class="device-controls">
                            <div class="controls-row">
                              ${if supportsColor then ''
                                <input class="color-picker" type="color" value="${deviceColor}" 
                                       title="Change color">
                              '' else ""}
                              <label class="switch">
                                <input type="checkbox" class="device-toggle">
                                <span class="toggle-slider"></span>
                              </label>
                            </div>
                          </div>
                        </div>
                        
                        <div class="room-brightness-container">
                          <div class="room-brightness-label">
                            <span>☀️</span>
                            <span class="brightness-value">100%</span>
                          </div>
                          <input class="brightness device-brightness" type="range" min="0" max="100" value="100"
                                 title="Adjust device brightness">
                        </div>
                      </div>
                    ''
                  ) roomLights}
                </div>
              </div>
            '' else ""
        ) sortedRooms}
      </div>
    </div>
    <br><br><br><br>
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
                
                playSuccessSound();
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
                    
                    playSuccessSound();
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


  enhancedRoomControlJs = ''
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
                    const roomColor = \`rgb(\''${r}, \''${g}, \''${b})\`;
                    roomEl.style.setProperty('--room-color', roomColor);
                    roomEl.style.setProperty('--room-color-rgb', \`\''${r}, \''${g}, \''${b}\`);
                    roomEl.classList.add('on');
                    
                    roomEl.classList.add('success');
                    setTimeout(() => roomEl.classList.remove('success'), 1000);
                } else {
                    roomEl.classList.remove('on');
                }
            } else {
                roomEl.classList.remove('on');
            }
        });
    }
  
    function updateDeviceInRoom(deviceId, data) {
        const deviceElementId = 'device-' + deviceId;
        let deviceEl = document.getElementById(deviceElementId);  
        if (!deviceEl) {
            console.warn('🦆 Device element not found for ID: ' + deviceId);
        
            const altEl = document.querySelector('[data-device="' + deviceId + '"]');
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
                console.error('🦆 Could not find device element for: ' + deviceId);
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
        
        console.log('🦆 Device ' + deviceId + ' state:', deviceState, 'from data:', data);
        
        if (toggle && deviceState !== undefined) {
            const isOn = typeof deviceState === 'string' 
                ? deviceState.toUpperCase() === 'ON'
                : Boolean(deviceState);
            
            // 🦆 says ⮞ Add toggle animation
            if (toggle.checked !== isOn) {
                deviceEl.classList.add('loading');
                setTimeout(() => {
                    toggle.checked = isOn;
                    deviceEl.classList.toggle('on', isOn);
                    deviceEl.classList.toggle('off', !isOn);
                    deviceEl.classList.remove('loading');
                    
                    // 🦆 says ⮞ Play sound for state change
                    if (isOn) playSuccessSound();
                }, 300);
            } else {
                toggle.checked = isOn;
                deviceEl.classList.toggle('on', isOn);
                deviceEl.classList.toggle('off', !isOn);
            }
            
            if (brightnessSlider) {
                brightnessSlider.style.display = isOn ? 'block' : 'none';
            }
        } else if (toggle) {
            console.warn('🦆 No state found for device ' + deviceId);
        }
        
        if (brightnessSlider && data.brightness !== undefined) {
            const percent = Math.round((data.brightness / 254) * 100);
            brightnessSlider.value = percent;
            
            // 🦆 says ⮞ Add visual feedback for brightness changes
            if (Math.abs(percent - parseInt(brightnessSlider.dataset.lastValue || 0)) > 10) {
                brightnessSlider.classList.add('brightness-active');
                setTimeout(() => brightnessSlider.classList.remove('brightness-active'), 500);
            }
            brightnessSlider.dataset.lastValue = percent;
            
            // 🦆 says ⮞ Update brightness value display
            const brightnessValue = deviceEl.querySelector('.brightness-value');
            if (brightnessValue) {
                brightnessValue.textContent = percent + '%';
            }
        }
        
        if (colorPicker && data.color) {
            const colorHex = normalizeColorFromState(data.color);
            if (colorHex) {
                colorPicker.value = colorHex;
                deviceEl.style.setProperty('--device-color', colorHex);
                deviceEl.style.setProperty('--device-color-rgb', 
                    parseInt(colorHex.substr(1, 2), 16) + ', ' +
                    parseInt(colorHex.substr(3, 2), 16) + ', ' +
                    parseInt(colorHex.substr(5, 2), 16)
                );
                
                // 🦆 says ⮞ Add color change animation
                deviceEl.style.animation = 'none';
                setTimeout(() => {
                    deviceEl.style.animation = 'deviceAppear 0.3s ease-out';
                }, 10);
            }
        }
        
        updateRoomColors();
    }
  
    // 🦆 says ⮞ Success sound for device actions
    function playSuccessSound() {
        try {
            const audioContext = new (window.AudioContext || window.webkitAudioContext)();
            const oscillator = audioContext.createOscillator();
            const gainNode = audioContext.createGain();
            
            oscillator.connect(gainNode);
            gainNode.connect(audioContext.destination);
            
            // Success tone
            oscillator.type = 'sine';
            oscillator.frequency.setValueAtTime(800, audioContext.currentTime);
            oscillator.frequency.exponentialRampToValueAtTime(1200, audioContext.currentTime + 0.1);
            
            gainNode.gain.setValueAtTime(0.2, audioContext.currentTime);
            gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + 0.2);
            
            oscillator.start(audioContext.currentTime);
            oscillator.stop(audioContext.currentTime + 0.2);
        } catch (e) {
            console.log('🦆 Audio not supported, silent success!');
        }
    }
  
    // 🦆 says ⮞ Enhanced init with personality
    function initRoomControlsWithPersonality() {
        console.log('🦆 Initializing room controls with personality!');
        
        // 🦆 says ⮞ Add loading animation to all rooms
        document.querySelectorAll('.room').forEach(room => {
            room.classList.add('loading');
        });
        
        setTimeout(() => {
            document.querySelectorAll('.room').forEach(room => {
                room.classList.remove('loading');
            });
        }, 1000);
        
        document.querySelectorAll('.room-header').forEach(header => {
            header.addEventListener('click', function(e) {
                if (e.target.classList.contains('collapse-btn')) return;
                
                const roomEl = this.closest('.room');
                const roomName = roomEl.getAttribute('data-room');
                const devices = roomEl.querySelectorAll('.device');
                const anyOn = Array.from(devices).some(device => 
                    device.classList.contains('on')
                );
                
                // 🦆 says ⮞ Add click animation
                roomEl.classList.add('loading');
                setTimeout(() => {
                    toggleRoom(roomName, !anyOn);
                    roomEl.classList.remove('loading');
                    
                    // 🦆 says ⮞ Play quack for room toggle
                    if (Math.random() > 0.5) playQuackSound();
                }, 200);
            });
        });
        
        // 🦆 says ⮞ Enhanced collapse button with animation
        document.querySelectorAll('.collapse-btn').forEach(btn => {
            btn.addEventListener('click', function(e) {
                e.stopPropagation();
                const roomEl = this.closest('.room');
                const devicesEl = roomEl.querySelector('.devices');
                
                // 🦆 says ⮞ Add rotation animation
                this.style.transform = 'rotate(180deg)';
                setTimeout(() => {
                    devicesEl.classList.toggle('hidden');
                    this.textContent = devicesEl.classList.contains('hidden') ? '▸' : '▾';
                    this.style.transform = "";
                }, 300);
                
                // 🦆 says ⮞ Play subtle sound
                playSuccessSound();
            });
        });
        
        // 🦆 says ⮞ Enhanced device toggle with animation
        document.querySelectorAll('.device-toggle').forEach(toggle => {
            toggle.addEventListener('change', function() {
                const deviceEl = this.closest('.device');
                const deviceId = deviceEl.getAttribute('data-device');
                const command = { state: this.checked ? 'ON' : 'OFF' };
                
                // 🦆 says ⮞ Add loading state
                deviceEl.classList.add('loading');
                
                setTimeout(() => {
                    if (window.sendCommand) {
                        window.sendCommand(deviceId, command);
                    }
                    
                    deviceEl.classList.toggle('on', this.checked);
                    deviceEl.classList.toggle('off', !this.checked);
                    deviceEl.classList.remove('loading');
                    
                    const brightnessSlider = deviceEl.querySelector('.device-brightness');
                    if (brightnessSlider) {
                        brightnessSlider.style.display = this.checked ? 'block' : 'none';
                    }
                    
                    // 🦆 says ⮞ Play success sound
                    playSuccessSound();
                    updateRoomColors();
                }, 300);
            });
        });
        
        // 🦆 says ⮞ Enhanced brightness slider with visual feedback
        document.querySelectorAll('.device-brightness').forEach(slider => {
            slider.addEventListener('input', function() {
                const deviceEl = this.closest('.device');
                const deviceId = deviceEl.getAttribute('data-device');
                
                // 🦆 says ⮞ Update value display
                const valueDisplay = deviceEl.querySelector('.brightness-value') || 
                                    (() => {
                                        const span = document.createElement('span');
                                        span.className = 'brightness-value';
                                        span.style.cssText = 'position: absolute; top: 5px; right: 5px; font-size: 0.9rem; color: var(--neon-yellow);';
                                        deviceEl.appendChild(span);
                                        return span;
                                    })();
                
                valueDisplay.textContent = this.value + '%';
                
                // 🦆 says ⮞ Debounce the command
                clearTimeout(slider._timeout);
                slider._timeout = setTimeout(() => {
                    setDeviceBrightness(deviceId, this.value);
                }, 200);
            });
        });
        
        // 🦆 says ⮞ Enhanced room brightness slider
        document.querySelectorAll('.room-brightness').forEach(slider => {
            slider.addEventListener('input', function() {
                const roomEl = this.closest('.room');
                const roomName = roomEl.getAttribute('data-room');
                
                // 🦆 says ⮞ Add visual feedback
                this.classList.add('brightness-active');
                
                // 🦆 says ⮞ Debounce the command
                clearTimeout(this._timeout);
                this._timeout = setTimeout(() => {
                    setRoomBrightness(roomName, this.value);
                    this.classList.remove('brightness-active');
                }, 300);
            });
        });
        
        // 🦆 says ⮞ Enhanced color picker with animation
        document.querySelectorAll('.color-picker').forEach(picker => {
            picker.addEventListener('input', function() {
                const deviceEl = this.closest('.device');
                const deviceId = deviceEl.getAttribute('data-device');
                
                // 🦆 says ⮞ Add color change animation
                deviceEl.style.animation = 'none';
                setTimeout(() => {
                    deviceEl.style.animation = 'deviceAppear 0.5s ease-out';
                    setDeviceColor(deviceId, this.value);
                    
                    deviceEl.style.setProperty('--device-color', this.value);
                    deviceEl.classList.add('on');
                    
                    // 🦆 says ⮞ Convert hex to RGB for CSS variable
                    const hex = this.value.replace('#', "");
                    const r = parseInt(hex.substr(0, 2), 16);
                    const g = parseInt(hex.substr(2, 2), 16);
                    const b = parseInt(hex.substr(4, 2), 16);
                    deviceEl.style.setProperty('--device-color-rgb', \`\''${r}, \''${g}, \''${b}\`);
                    
                    updateRoomColors();
                    
                    // 🦆 says ⮞ Play color change sound
                    playSuccessSound();
                }, 10);
            });
        });
        
        console.log('🦆 Room controls initialized with personality! 🦆✨');
    }
  
    window.initRoomControls = initRoomControlsWithPersonality;
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
        <link href="https://cdn.jsdelivr.net/npm/@mdi/font/css/materialdesignicons.min.css" rel="stylesheet">
        <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@600&display=swap" rel="stylesheet">
        <script src="https://unpkg.com/mqtt/dist/mqtt.min.js"></script>        

        <style> 
            .page {
                display: none;
                width: 100%;
                min-height: 100%;
                padding: 20px;
                box-sizing: border-box;
            }
        
            ${css.global}
            ${css.devices}
            ${css.scenes}
            ${sceneGradientCss}
            ${css.tv}
        </style>
        
    </head>
    <body>
        <div class="container">
            
            <div id="deviceSelectorContainer" class="device-selector-container hidden">
                <select id="deviceSelect" class="device-selector">
                    <option value="">🦆 says ▶ pick a device! </option>
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
                                <p id="currentDeviceStatus">Choose a device from dropdown</p>
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
                    <div class="room-controls-section">
                      <h3>🦆<i class="fas fa-palette"></i> SCENES <i class="fas fa-palette"></i>🦆</h3>
                    </div>  
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
                        <!-- 🦆 says ⮞ ROW 1 - GREEN -->
                        <div class="tv-control-row">
                          <button class="tv-control-btn channel green" onclick="sendTVCommand('channel_up')">
                            <i class="fas fa-arrow-up"></i>
                          </button>
                          <button class="tv-control-btn volume green" onclick="sendTVCommand('up')">
                            <i class="fas fa-volume-up"></i>
                          </button>
                        </div>
      
                        <!-- 🦆 says ⮞ ROW 2 - RED -->
                        <div class="tv-control-row">
                          <button class="tv-control-btn channel red" onclick="sendTVCommand('channel_down')">
                            <i class="fas fa-arrow-down"></i>
                          </button>
                          <button class="tv-control-btn volume red" onclick="sendTVCommand('down')">
                            <i class="fas fa-volume-down"></i>
                          </button>
                        </div>
      
                        <!-- 🦆 says ⮞ ROW 3 - ORANGE for nav up -->
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
      
                        <!-- 🦆 says ⮞ ROW 5 - ORANGE for nav down -->
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
            ${enhancedChartJs}
            ${enhancedUpdateAllCardsJs}
            ${interactiveCardJs}
            
            // 🦆 says ⮞ chart functions
            function updateCardChart(cardId, historyData, color) {
                const canvas = document.getElementById('status-' + cardId + '-chart');
                if (!canvas) return;
                
                // 🦆 says ⮞ check if Chart.js is loaded
                if (typeof Chart === 'undefined') {
                    loadChartJS().then(() => {
                        renderEnhancedChart(cardId, historyData, color);
                    });
                } else {
                    renderEnhancedChart(cardId, historyData, color);
                }
            }
            
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

            function updateCardValue(cardId, value) {
                updateCardValueWithAnimation(cardId, value);
            }

            function updateCardDetails(cardId, details) {
                const element = document.getElementById('status-' + cardId + '-details');
                if (element) {
                    element.textContent = details;
                }
            }

            ${enhancedChartJs}
            ${enhancedUpdateAllCardsJs}
            ${interactiveCardJs}
            
            // 🦆 says ⮞ chart functions
            function updateCardChart(cardId, historyData, color) {
                const canvas = document.getElementById('status-' + cardId + '-chart');
                if (!canvas) return;
                
                // 🦆 says ⮞ check if Chart.js is loaded
                if (typeof Chart === 'undefined') {
                    loadChartJS().then(() => {
                        renderEnhancedChart(cardId, historyData, color);
                    });
                } else {
                    renderEnhancedChart(cardId, historyData, color);
                }
            }
            
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

            // 🦆 says ⮞ Keep original update functions for compatibility
            function updateCardValue(cardId, value) {
                updateCardValueWithAnimation(cardId, value);
            }

            function updateCardDetails(cardId, details) {
                const element = document.getElementById('status-' + cardId + '-details');
                if (element) {
                    element.textContent = details;
                }
            }         
            
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
                
                const brokerUrl = 'ws://${config.house.zigbee.mosquitto.host}:9001';              
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


                // 🦆 says ⮞ create room to devices mapping & init
                window.roomDeviceMappings = {};
                ${roomDeviceMappings}

                // 🦆 says ⮞ & create roomDevices (legacy)
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


                
                function addDeviceParticles() {
                    const devicesPage = document.getElementById('pageDevices');
                    if (!devicesPage) return;
                    
                    const particleContainer = document.createElement('div');
                    particleContainer.className = 'devices-particles';
                    devicesPage.appendChild(particleContainer);
                    
                    // Create particles
                    for (let i = 0; i < 50; i++) {
                        const particle = document.createElement('div');
                        particle.className = 'devices-particle';
                        
                        const x = Math.random() * 100;
                        const y = Math.random() * 100;
                        const size = Math.random() * 10 + 2;
                        particle.style.left = x + '%';
                        particle.style.top = y + '%';
                        particle.style.width = size + 'px';
                        particle.style.height = size + 'px';
                        
                        // Random color
                        const colors = ['#00ffaa', '#38bdf8', '#8b5cf6', '#facc15', '#ef4444', '#22c55e'];
                        particle.style.background = `radial-gradient(circle at 30% 30%, ''${colors[Math.floor(Math.random() * colors.length)]}, transparent 70%)`;
                        
                        // Animation
                        particle.animate([
                            { 
                                transform: 'translate(0, 0) rotate(0deg)',
                                opacity: Math.random() * 0.5 + 0.3
                            },
                            { 
                                transform: `translate(''${Math.random() * 100 - 50}px, ''${Math.random() * 100 - 50}px) rotate(''${Math.random() * 360}deg)`,
                                opacity: 0.1
                            }
                        ], {
                            duration: 5000 + Math.random() * 5000,
                            iterations: Infinity,
                            direction: 'alternate',
                            easing: 'ease-in-out'
                        });
                        
                        particleContainer.appendChild(particle);
                    }
                }
                
                // 🦆 says ⮞ Enhanced device control sounds
                function playDeviceSound(type) {
                    try {
                        const audioContext = new (window.AudioContext || window.webkitAudioContext)();
                        const oscillator = audioContext.createOscillator();
                        const gainNode = audioContext.createGain();
                        
                        oscillator.connect(gainNode);
                        gainNode.connect(audioContext.destination);
                        
                        let frequency = 800;
                        let duration = 0.2;
                        
                        switch(type) {
                            case 'toggle':
                                frequency = 600;
                                duration = 0.3;
                                break;
                            case 'slider':
                                frequency = 400;
                                duration = 0.1;
                                break;
                            case 'color':
                                frequency = 1000;
                                duration = 0.4;
                                break;
                            case 'success':
                                frequency = 1200;
                                duration = 0.5;
                                break;
                            case 'error':
                                frequency = 300;
                                duration = 0.3;
                                break;
                            default:
                                frequency = 800;
                                duration = 0.2;
                        }
                        
                        oscillator.type = 'sine';
                        oscillator.frequency.setValueAtTime(frequency, audioContext.currentTime);
                        oscillator.frequency.exponentialRampToValueAtTime(frequency * 1.5, audioContext.currentTime + duration);
                        
                        gainNode.gain.setValueAtTime(0.2, audioContext.currentTime);
                        gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + duration);
                        
                        oscillator.start(audioContext.currentTime);
                        oscillator.stop(audioContext.currentTime + duration);
                        
                    } catch (e) {
                        console.log('🦆 No audio support, silent device control!');
                    }
                }
                
                // 🦆 says ⮞ Enhanced device toggle animation
                function enhancedToggleAnimation(checkbox) {
                    const toggleContainer = checkbox.closest('.state-display');
                    if (!toggleContainer) return;
                    
                    if (checkbox.checked) {
                        toggleContainer.classList.remove('state-off');
                        toggleContainer.classList.add('state-on');
                        playDeviceSound('toggle');
                        
                        // Add success animation
                        toggleContainer.classList.add('success');
                        setTimeout(() => toggleContainer.classList.remove('success'), 500);
                    } else {
                        toggleContainer.classList.remove('state-on');
                        toggleContainer.classList.add('state-off');
                        playDeviceSound('toggle');
                    }
                }
                
                // 🦆 says ⮞ Enhanced color picker with ripple
                function enhancedColorPick(color, element) {
                    const ripple = document.createElement('span');
                    const rect = element.getBoundingClientRect();
                    const size = Math.max(rect.width, rect.height) * 2;
                    const x = rect.left + rect.width / 2 - size / 2;
                    const y = rect.top + rect.height / 2 - size / 2;
                    
                    ripple.style.cssText = `
                        position: fixed;
                        border-radius: 50%;
                        background: ''${color};
                        transform: scale(0);
                        animation: ripple 0.6s linear;
                        width: ''${size}px;
                        height: ''${size}px;
                        top: ''${y}px;
                        left: ''${x}px;
                        pointer-events: none;
                        z-index: 1000;
                        opacity: 0.3;
                    `;
                    
                    document.body.appendChild(ripple);
                    setTimeout(() => ripple.remove(), 600);
                    
                    playDeviceSound('color');
                    playQuackSound(); // Always quack for color changes!
                }
                
                // 🦆 says ⮞ Initialize devices page with personality
                function initDevicesPageWithPersonality() {
                    console.log('🦆 Initializing devices page with maximum personality!');
                    
                    // Add particles
                    setTimeout(addDeviceParticles, 500);
                    
                    // Enhanced event listeners for devices page
                    document.querySelectorAll('.switch input').forEach(checkbox => {
                        checkbox.addEventListener('change', function() {
                            enhancedToggleAnimation(this);
                        });
                    });
                    
                    document.querySelectorAll('.color-preset').forEach(preset => {
                        preset.addEventListener('click', function() {
                            const color = this.style.backgroundColor || this.style.background;
                            enhancedColorPick(color, this);
                        });
                    });
                    
                    // Enhanced brightness slider
                    document.querySelectorAll('.brightness-slider').forEach(slider => {
                        let timeout;
                        slider.addEventListener('input', function() {
                            clearTimeout(timeout);
                            timeout = setTimeout(() => {
                                playDeviceSound('slider');
                                
                                // Visual feedback
                                const valueDisplay = this.closest('.brightness-display').querySelector('.brightness-value');
                                if (valueDisplay) {
                                    valueDisplay.style.transform = 'scale(1.1)';
                                    setTimeout(() => valueDisplay.style.transform = 'scale(1)', 200);
                                }
                            }, 200);
                        });
                    });
                    
                    // Add ripple effects to all buttons
                    document.querySelectorAll('.color-picker-btn, .cover-btn').forEach(btn => {
                        btn.addEventListener('click', function(e) {
                            const ripple = document.createElement('span');
                            const rect = this.getBoundingClientRect();
                            const size = Math.max(rect.width, rect.height);
                            const x = e.clientX - rect.left - size / 2;
                            const y = e.clientY - rect.top - size / 2;
                            
                            ripple.style.cssText = `
                                position: absolute;
                                border-radius: 50%;
                                background: rgba(255, 255, 255, 0.6);
                                transform: scale(0);
                                animation: ripple 0.6s linear;
                                width: ''${size}px;
                                height: ''${size}px;
                                top: ''${y}px;
                                left: ''${x}px;
                                pointer-events: none;
                            `;
                            
                            this.appendChild(ripple);
                            setTimeout(() => ripple.remove(), 600);
                        });
                    });
                    
                    // Add hover effects to device header
                    const deviceHeader = document.querySelector('.device-header');
                    if (deviceHeader) {
                        deviceHeader.addEventListener('mouseenter', () => {
                            playDeviceSound('success');
                        });
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
                                            🦆 says ▶ <i class="fas fa-palette"></i> custom color
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
        { name = "cert"; description = "Path to SSL certificate to run the sever on"; } 
        { name = "key"; description = "Path to key file to run the sever on"; } 
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
