# dotfiles/bin/home/duckDash.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ auto generate smart home dashboard
  self, 
  config,
  lib, 
  pkgs,
  cmdHelpers,
  ...
}: let 

  login = import ./../../modules/dashboard/login.nix { inherit lib pkgs; };
  javascript = import ./../../modules/dashboard/js.nix { inherit lib config pkgs; };
  cards = import ./../../modules/dashboard/cards.nix { inherit lib pkgs; };
  generateCardStyle = cards.generateCardStyle;
  statusCardThemes = cards.statusCardThemes;

  # 🦆 says ⮞ css iz fun yo
  css = {
    global  = builtins.readFile ./../../modules/themes/css/duckdash/global.css;
    home    = builtins.readFile ./../../modules/themes/css/duckdash/home.css;
    devices = builtins.readFile ./../../modules/themes/css/duckdash/devices.css;
    scenes  = builtins.readFile ./../../modules/themes/css/duckdash/scenes.css;
  };

  # 🦆 says ⮞ js iz not fun ,,,,
  js = javascript.jScript;

  # 🦆 says ⮞ get house.tv configuration with debug info
  tvConfig = builtins.trace "TV config: ${builtins.toJSON config.house.tv}" config.house.tv;

  # 🦆 says ⮞ define Zigbee devices here yo 
  zigbeeDevices = config.house.zigbee.devices;
  lightDevices = lib.filterAttrs (_: device: 
    device.type == "light" || device.type == "hue_light"
  ) zigbeeDevices;
  
  # 🦆 says ⮞ case-insensitive device matching
  normalizedDeviceMap = lib.mapAttrs' (id: device:
    lib.nameValuePair (lib.toLower device.friendly_name) device.friendly_name
  ) zigbeeDevices;

  # 🦆 says ⮞ device validation list
  deviceList = builtins.attrNames normalizedDeviceMap;

  # 🦆 says ⮞ scene simplifier? or not
  sceneLight = {state, brightness ? 200, hex ? null, temp ? null}:
    let
      colorValue = if hex != null then { inherit hex; } else null;
    in
    {
      inherit state brightness;
    } // (if colorValue != null then { color = colorValue; } else {})
      // (if temp != null then { color_temp = temp; } else {});

  # 🎨 Scenes  🦆 YELLS ⮞ SCENES!!!!!!!!!!!!!!!11
  scenes = config.house.zigbee.scenes; # 🦆 says ⮞ Declare light states, quack dat's a scene yo!   
  sceneConfig = pkgs.writeText "scene-config.json" (builtins.toJSON {
    scenes = scenes;
  });
  
  # 🦆 says ⮞ Generate scene commands    
  makeCommand = device: settings:
    let
      json = builtins.toJSON settings;
    in
      ''
      mqtt_pub -t "zigbee2mqtt/''${device}/set" -m '''${json}'
      '';
      
  sceneCommands = lib.mapAttrs
    (sceneName: sceneDevices:
      lib.mapAttrs (device: settings: makeCommand device settings) sceneDevices
    ) scenes;  

  # 🦆 says ⮞ Filter devices by rooms
  byRoom = lib.foldlAttrs (acc: id: dev:
    lib.recursiveUpdate acc {
      ${dev.room} = (acc.${dev.room} or []) ++ [ id ];
    }) {} zigbeeDevices;

  # 🦆 says ⮞ Filter by device type
  byType = lib.foldlAttrs (acc: id: dev:
    lib.recursiveUpdate acc {
      ${dev.type} = (acc.${dev.type} or []) ++ [ id ];
    }) {} zigbeeDevices;

  # 🦆 says ⮞ dis creates group configuration for Z2M yo
  groupConfig = lib.mapAttrs' (room: ids: {
    name = room;
    value = {
      friendly_name = room;
      devices = map (id: 
        let dev = zigbeeDevices.${id};
        in "${id}/${toString dev.endpoint}"
      ) ids;
    };
  }) byRoom;

  # 🦆 says ⮞ gen json from `config.house.tv`  
  tvDevicesJson = pkgs.writeText "tv-devices.json" (builtins.toJSON config.house.tv);

  # 🦆 says ⮞ dis creates device configuration for Z2M yo
  deviceConfig = lib.mapAttrs (id: dev: {
    friendly_name = dev.friendly_name;
  }) zigbeeDevices;

  # 🦆 says ⮞ IEEE not very human readable - lets fix dat yo
  ieeeToFriendly = lib.mapAttrs (ieee: dev: dev.friendly_name) zigbeeDevices;
  mappingJSON = builtins.toJSON ieeeToFriendly;
  mappingFile = pkgs.writeText "ieee-to-friendly.json" mappingJSON;

  # 🦆 says ⮞ user defined dashboard pages
  pageFilesAndCss = let
    pages = config.house.dashboard.pages;
  in lib.concatStrings (lib.mapAttrsToList (pageId: page: 
    if page.css != "" then "echo '${page.css}' > $WORKDIR/page-${pageId}.css;" else ""
  ) pages);

  # 🦆says⮞ generate html for status cards with grouping and themes
  statusCardsHtml = let
    # 🦆says⮞filter
    enabledCards = lib.filterAttrs (name: card: card.enable) config.house.dashboard.statusCards;    
    # 🦆says⮞ convert to list & add name
    cardsList = lib.mapAttrsToList (name: card: card // { _name = name; }) enabledCards;
    # 🦆says⮞ group cards by their group
    groupedCards = lib.groupBy (card: card.group or "default") cardsList;    
    groups = lib.attrNames groupedCards;
    
    # 🦆says⮞ generate CSS variables for a card
    generateCardStyle = cardName: card:
      let
        themeName = card.theme or "neon";
        theme = statusCardThemes.${themeName} or statusCardThemes.neon;
        # 🦆says⮞ convert css vars 2 inline
        themeVars = lib.concatStringsSep " " (lib.mapAttrsToList (name: value: 
          "${name}: ${value};"
        ) theme.cssVars);
      in
        ''style="
          --card-color: ${card.color};
          --card-glow-color: ${card.color}40;
          ${themeVars}
        "'';
    
    # 🦆says⮞ generate html single card
    generateCardHtml = card: 
      let 
        name = card._name;
        cardStyle = generateCardStyle name card;
        themeName = card.theme or "neon";
      in
        ''
        <div class="card${if card.chart then " has-chart" else ""}${if name == "temperature" then " quacking" else ""}" 
             data-card="${name}"
             data-theme="${themeName}"
             ${cardStyle}>
          
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
        '';
    
    # 🦆says⮞ generate html for groups
    generateGroupHtml = groupName: cards: 
      let
        cardsHtml = lib.concatMapStrings generateCardHtml cards;
      in
        cardsHtml + (if groupName != lib.last groups then "<br><br>" else "");    
  in
    lib.concatStrings (lib.mapAttrsToList generateGroupHtml groupedCards);
     
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
        if device.state == "ON" && device ? color && device.color ? hex then 
          [ device.color.hex ]
        else []
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
        if device.state == "ON" && device ? color.hex then [device.color.hex] else []
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

  statusCards = ''
    <div class="status-cards">
      <h3>🦆 STATUS 🦆</h3>
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
    devicesData = config.house.zigbee.devices;
    
    isDeviceOn = deviceId: 
      let device = devicesData.${deviceId} or {};
      in device.state or "OFF" == "ON";
  in ''
    <div class="room-controls-section">
      <h3>🦆 ROOOOMS 🦆</h3>
      <div class="rooms" id="roomsContainer">
        ${lib.concatMapStrings (room: 
          let 
            iconName = lib.removePrefix "mdi:" (roomIcons.${room} or "mdi:home");
            roomLights = devicesByRoom.${room} or [];
            hasLights = roomLights != [];
            roomId = lib.toLower (lib.replaceStrings [" "] ["-"] room);
            deviceCount = lib.length roomLights;
            initialOnCount = lib.length (lib.filter (device: 
              isDeviceOn device.id
            ) roomLights);
          in
            if hasLights then ''
              <div class="room" id="room-${roomId}" data-room="${roomId}">
                <div class="room-header" onclick="openRoomDevicesPanel('${roomId}', '${room}')">
                  <div class="room-title">
                    <i class="mdi mdi-${iconName} room-icon"></i>
                    <span class="room-name">${lib.toUpper room}</span>
                  </div>
                  <div class="room-controls">
                    <button class="collapse-btn" title="View Devices" onclick="event.stopPropagation(); openRoomDevicesPanel('${roomId}', '${room}')">
                      ▸
                    </button>
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
                
                <div class="room-devices-summary">
                  <i class="fas fa-lightbulb"></i>
                  <span class="room-devices-count">${toString deviceCount} lights</span>
                  <span>•</span>
                  <span class="room-on-devices" id="room-${roomId}-on-count">${toString initialOnCount} on</span>
                </div>
              </div>
            '' else ""
        ) sortedRooms}
      </div>
    </div>
  '';

  
  # 🦆 says ⮞ SERVER CONFIGURATION
  httpServer = pkgs.writeShellScriptBin "serve-dashboard" ''
    HOST=''${1:-0.0.0.0}
    PORT=''${2:-13337}
    CERT=''${3:-}
    KEY=''${4:-}
    WORKDIR=$(mktemp -d)

    # 🦆 says ⮞ symlink html files & manifest
    ln -sf /etc/login.html $WORKDIR/  
    ln -sf /etc/index.html $WORKDIR/
    ln -sf /etc/static/tv.html $WORKDIR/
    ln -sf /etc/site.webmanifest $WORKDIR/
            
    # 🦆 says ⮞ & favicons
    ln -sf /etc/favicon-32x32.png $WORKDIR/
    ln -sf /etc/favicon-16x16.png $WORKDIR/
    ln -sf /etc/favicon.ico $WORKDIR/
    ln -sf /etc/apple-touch-icon.png $WORKDIR/
    ln -sf /etc/android-chrome-512x512.png $WORKDIR/
    ln -sf /etc/android-chrome-192x192.png $WORKDIR/

    # 🦆 says ⮞ symlink json files
    ln -sf /etc/devices.json $WORKDIR/
    ln -sf /etc/rooms.json $WORKDIR/
    ln -sf /etc/tv.json $WORKDIR/
    ln -sf /var/lib/zigduck/state.json $WORKDIR/  
    ln -sf /etc/static/epg.json $WORKDIR/   

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
        <link rel="manifest" href="/site.webmanifest">
  
        <link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png">
        <link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png">
        <link rel="icon" type="image/png" sizes="16x16" href="/favicon-16x16.png">

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
        </style>
        
    </head>
    <body>
        <div class="container">    
            <div id="mqttStatus" style="position: fixed; top: 10px; right: 10px; z-index: 1000; 
                 background: rgba(0,0,0,0.8); color: white; padding: 5px 10px; border-radius: 5px;">
                 ...
            </div>
            <div id="connectionStatus" style="display: none;"></div>
            <div id="deviceSelectorContainer" class="device-selector-container hidden">
                <select id="deviceSelect" class="device-selector">
                    <option value="">🦆 says ▶ pick a device! </option>
                </select>
            </div>
            
            <div class="page-container" id="pageContainer"> 
                <!-- 🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆
                 🦆 says ⮞ PAGE 0 HOME (STATUS CARDS)
                 🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆 -->
                <div class="page" id="pageHome" data-page="0">
                    
                    <div class="status-cards">
                    <div class="status-cards">
                        ${statusCardsHtml}
                    </div>
                    </div>
                    ${roomControlsHtml}
                </div><br><br><br>
                  <!-- 🦆says⮞ slide out a room panel with devices -->
                <div class="panel-backdrop" id="panelBackdrop" onclick="closeRoomDevicesPanel()"></div>
                <div class="slide-out-panel" id="devicesSlidePanel">
                  <div class="panel-header">
                    <button class="panel-back-btn" onclick="closeRoomDevicesPanel()">
                      ←
                    </button>
                    <div class="panel-title">
                      <div class="panel-room-name" id="panelRoomName">Room Name</div>
                      <i class="mdi mdi-home panel-room-icon" id="panelRoomIcon"></i>
                    </div>
                  </div>
                    
                  <div class="panel-controls" id="panelDevicesContainer">
                  <!--  <div class="panel-devices-container" id="panelDevicesContainer">  -->
                    <!-- 🦆says⮞ room devices is shown here  -->
                  </div>
                </div>
                
                
                <!-- 🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆
                 🦆 says ⮞ PAGE 1 DEVICES
                 🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆 -->                
                <div class="page" id="pageDevices" data-page="1">

                    <!-- 🦆says⮞ main device content  -->
                    <div class="device-controls" id="deviceControls">
                        <!-- 🦆says⮞ device header (title, icon, signal) -->
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
                                <span class="lq-value">??</span>
                            </div>
                        </div>
                        
                        <!-- 🦆says⮞ device controls  -->
                        <div id="devicePanel" class="device-panel">
                            <!-- 🦆says⮞ will be dynamically rendered here by renderMessage()  -->
                        </div>
                    </div>
                </div>
                
                
                <!-- 🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆
                 🦆 says ⮞ PAGE 2 - SCENES
                 🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆 -->
                <div class="page" id="pageScenes" data-page="2">
                    <div class="room-controls-section">
                      <h3>SCENES <i class="fas fa-palette"></i>🦆</h3>
                    </div>
                    <div class="scene-grid" id="scenesContainer">
                      ${sceneGridHtml}
                    </div>
                </div>
                                    
               <!-- 🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆
               🦆 says ⮞ USER CONFIGURATION PAGES
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
                <!-- 🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆
              🦆 says ⮞ USER CONFIGURED TABS 🦆 -->
                ${customTabsHtml}
            </div>
        </div>
    
        <div class="notification hidden" id="notification"></div>
     
        <script>
            // 🦆 says ⮞ load Chart.js if needed
            function loadChartJS() {
              return new Promise((resolve) => {
                if (typeof Chart !== 'undefined') {
                  resolve();
                  return;
                }
                const script = document.createElement('script');
                script.src = 'https://cdn.jsdelivr.net/npm/chart.js';
                script.onload = resolve;
                document.head.appendChild(script);
              });
            }

            // 🦆 says ⮞ LOAD STATUS CARD JS
            ${js.statusCards}
  
            // 🦆 says ⮞ LOAD ROOM JS
            ${js.rooms.roomControlJs}
            ${js.rooms.slidingRoomsJS}
  
            
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

            
            // 🦆 says ⮞ EVENT LISTNER DOMCONTENTLOADED
            document.addEventListener('DOMContentLoaded', function() {
                // 🦆 says ⮞ mqtt
                let client = null;
                
                const brokerUrl = 'ws://${config.house.zigbee.mosquitto.host}:9001';              
                const statusElement = document.getElementById('connectionStatus');
                const notification = document.getElementById('notification');
        
                // 🦆 says ⮞ auto-hide connection status
                let connectionHideTimeout = null;
                
                // 🦆 says ⮞ init status cards 
                if (window.initStatusCards) {
                  window.initStatusCards();
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
                
                // 🦆says⮞ LAST SEEN
                function formatValue(key, value) {
                    if (key === 'last_seen') {
                        return new Date(value).toLocaleString();
                    }
                    if (typeof value === 'number') {
                        return Number(value.toFixed(2)).toString();
                    }
                    return String(value);
                }
                
                // 🦆says⮞ SIGNAL STRENGTH
                function linkQualityText(value) {
                    if (value > 200) return 'Excellent';
                    if (value > 100) return 'Good';
                    if (value > 50) return 'Fair';
                    return 'Poor';
                }
                
                // 🦆says⮞ TIME AGO
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
                                // updateStatusCards();
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
                        // updateStatusCards();
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


                // 🦆says⮞ anunated background
                function addDeviceParticles() {
                    const devicesPage = document.getElementById('pageDevices');
                    if (!devicesPage) return;
                    
                    const particleContainer = document.createElement('div');
                    particleContainer.className = 'devices-particles';
                    devicesPage.appendChild(particleContainer);
                    
                    // 🦆 says ⮞ particles
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
                        
                        // 🦆 says ⮞ rng
                        const colors = ['#00ffaa', '#38bdf8', '#8b5cf6', '#facc15', '#ef4444', '#22c55e'];
                        particle.style.background = `radial-gradient(circle at 30% 30%, ''${colors[Math.floor(Math.random() * colors.length)]}, transparent 70%)`;
                        
                        // 🦆 says ⮞ ANIMATION
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
                
                // 🦆 says ⮞ device control sounds
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
                
                // 🦆 says ⮞ device toggle animation
                function enhancedToggleAnimation(checkbox) {
                    const toggleContainer = checkbox.closest('.state-display');
                    if (!toggleContainer) return;
                    
                    if (checkbox.checked) {
                        toggleContainer.classList.remove('state-off');
                        toggleContainer.classList.add('state-on');
                        playDeviceSound('toggle');
                        
                        toggleContainer.classList.add('success');
                        setTimeout(() => toggleContainer.classList.remove('success'), 500);
                    } else {
                        toggleContainer.classList.remove('state-on');
                        toggleContainer.classList.add('state-off');
                        playDeviceSound('toggle');
                    }
                }
                
                // 🦆 says ⮞ color picker with ripple
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
                    playQuackSound(); // 🦆 says ⮞ always quack for color changes!
                }
                
                // 🦆 says ⮞ init devices page my way
                function initDevicesPageWithPersonality() {
                    console.log('🦆 Initializing devices page!!');   
                    setTimeout(addDeviceParticles, 500);
                    
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
                    
                    document.querySelectorAll('.brightness-slider').forEach(slider => {
                        let timeout;
                        slider.addEventListener('input', function() {
                            clearTimeout(timeout);
                            timeout = setTimeout(() => {
                                playDeviceSound('slider');
                                
                                const valueDisplay = this.closest('.brightness-display').querySelector('.brightness-value');
                                if (valueDisplay) {
                                    valueDisplay.style.transform = 'scale(1.1)';
                                    setTimeout(() => valueDisplay.style.transform = 'scale(1)', 200);
                                }
                            }, 200);
                        });
                    });
                    
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
                    
                    const deviceHeader = document.querySelector('.device-header');
                    if (deviceHeader) {
                        deviceHeader.addEventListener('mouseenter', () => {
                            playDeviceSound('success');
                        });
                    }
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
                        
                        window.mqttClient = client; 
                        
                        client.on('connect', function() {
                            window.mqttConnected = true;
                            showConnectionStatus();
                            statusElement.className = 'connection-status status-connected';
                            statusElement.innerHTML = '<i class="fas fa-plug"></i><span>🟢</span>';
                            
                            client.subscribe('zigbee2mqtt/#', function(err) {
                                if (!err) {
                                    showNotification('Subscribed to all devices', 'success');
                                }
                            });
                       
                        });
                        
                        client.on('error', function(err) {
                            window.mqttConnected = false; 
                            showConnectionStatus(); // 🦆 says ⮞ show on error
                            statusElement.className = 'connection-status status-error';
                            statusElement.innerHTML = '<i class="fas fa-exclamation-triangle"></i><span>⚠️📛</span>';
                            console.error('Connection error: ', err);
                        });
                        
                        client.on('message', function(topic, message) {
                            const topicParts = topic.split('/');
                            const deviceName = topicParts[1];

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


                            if (topicParts.length === 2) {
                                try {
                                    const data = JSON.parse(message.toString());
                                    devices[deviceName] = data;    
                                    saveState();     
                                    updateDeviceSelector(); 
                                    if (selectedDevice === deviceName) {
                                        updateDeviceUI(data);
                                    }      
                                    // updateStatusCards();
                                    onMQTTDataUpdate();   
                                    
                                    // 🦆 says ⮞ update room control UI
                                    if (window.updateDeviceUIFromMQTT) {
                                      updateDeviceUIFromMQTT(deviceName, data);
                                    }
                                    
                                    if (window.updateRoomStats) {
                                        setTimeout(() => {
                                            updateRoomStats();
                                        }, 100);
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
                            window.mqttConnected = false; 
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
                    updateRoomStats();
                }
                      
                function updateDeviceIcon(deviceName) {
                    console.log('updateDeviceIcon called for:', deviceName);
                    const icon = deviceIdToIcon[deviceName] || deviceIcons[deviceName] || "mdi:duck";
                    console.log('Resolved icon for', deviceName, ':', icon);
                    const iconName = icon.replace("mdi:", "");
                    const iconElement = document.getElementById('currentDeviceIcon');
                    
                    if (icon.startsWith('./') || icon.startsWith('/') || icon.includes('.png') || icon.includes('.svg')) {
                        // 🦆 says ⮞ image icon
                        iconElement.innerHTML = `<img src="''${icon}" alt="''${deviceName}" class="device-image-icon">`;
                    } else if (icon.startsWith('<') && icon.includes('>')) {
                        // 🦆 says ⮞ already html
                        iconElement.innerHTML = icon;
                    } else {
                        // 🦆 says ⮞ default behavior
                        console.log('Icon element found:', !!iconElement);
                        if (iconElement) {
                            iconElement.className = 'mdi mdi-' + iconName;
                            console.log('Final icon classes:', iconElement.className);
                        }
                    }
                }    
      

                // 🦆 says ⮞ unified command topic (hue + z2m)
                function sendCommand(deviceId, command) {
                    const client = window.mqttClient;
                    if (!client || !client.connected) {
                        showNotification('Not connected to MQTT, reconnecting...', 'warning');
                        connectToMQTT();
                        setTimeout(() => {
                            if (window.mqttClient && window.mqttClient.connected) {
                                window.mqttClient.publish(`zigbee2mqtt/device_command/''${deviceId}`, JSON.stringify(command));
                            } else {
                                showNotification('Still not connected to MQTT', 'error');
                            }
                        }, 1000);
                        return;
                    }

                    const topic = `zigbee2mqtt/device_command/''${deviceId}`;
                    client.publish(topic, JSON.stringify(command), function(err) {
                        if (err) {
                            showNotification('Failed to send command', 'error');
                            console.error('Publish error: ', err);
                        } else {
                            if (window.devices && window.devices[deviceId]) {
                                window.devices[deviceId] = { ...window.devices[deviceId], ...command };
                            }
                        }
                    });
                }



                    //const client = window.mqttClient;
                    //if (!client || !client.connected) {
                     //   showNotification('Not connected to MQTT, reconnecting...', 'warning');
                    //    connectToMQTT();
                    //    setTimeout(() => {
                    //        if (window.mqttClient && window.mqttClient.connected) {
                    //            window.mqttClient.publish(`zigbee2mqtt/''${device}/set`, JSON.stringify(command));
                    //        } else {
                    //            showNotification('Still not connected to MQTT', 'error');
                   //         }
                   //     }, 1000);
                   //     return;
                   // }
    
                   // const topic = `zigbee2mqtt/''${device}/set`;
                   // client.publish(topic, JSON.stringify(command), function(err) {
                   //     if (err) {
                   //         showNotification('Failed to send command', 'error');
                   //         console.error('Publish error: ', err);
                   //     } else {
                   //         if (window.devices && window.devices[device]) {
                  //              window.devices[device] = { ...window.devices[device], ...command };
                 //           }
                 //       }
                 //   });
                //}
                
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
                    selectedDevice =  deviceName;
                    devicePanel.appendChild(title);
                        
                    const jsonDiv = document.createElement('div');
                    jsonDiv.className = 'json';
                    devicePanel.appendChild(jsonDiv);
                    
                    const entries = Object.entries(parsed);
                    let controlsHtml = "";
                    let rowsHtml = "";
                    updateRoomStats();
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
                        const v = clamp(Number(parsed.brightness) || 0, 0, 254);
                        const percent = Math.round((v / 254) * 100);
    
                        controlsHtml += `
                            <div class="section">Brightness</div>
                            <div class="row special">
                                <div class="brightness-display">
                                    <div class="brightness-value">''${percent}%</div>
                                    <div class="slider-row">
                                        <input type="range" min="0" max="254" value="''${v}" id="brightnessSlider" class="brightness-slider">
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
                                        <div class="color-preset" style="background: #4cd964;" onclick="setColor('#4cd964')"></div>
                                        <div class="color-preset" style="background: #5ac8fa;" onclick="setColor('#5ac8fa')"></div>
                                        <div class="color-preset" style="background: #007aff;" onclick="setColor('#007aff')"></div>
                                    </div>
                                    <div class="color-picker-container">
                                        <button class="color-picker-btn" onclick="openColorPicker()">
                                            🦆say▶ <i class="fas fa-palette"></i> custom color
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
                        const currentDeviceName = selectedDevice;
    
                        toggle.onchange = () => {
                            const stateText = document.querySelector('.state-text');
                            const stateDisplay = document.querySelector('.state-display');

                            if (toggle.checked) {
                                stateText.textContent = 'ON';
                                stateDisplay.classList.remove('state-off');
                                stateDisplay.classList.add('state-on');
                                sendCommand(currentDeviceName, { state: 'ON' });
                            } else {
                                stateText.textContent = 'OFF';
                                stateDisplay.classList.remove('state-on');
                                stateDisplay.classList.add('state-off');
                                sendCommand(currentDeviceName, { state: 'OFF' });
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
            
                            if (normalizedData.id) {
                                window.devices[normalizedData.id] = normalizedData;
                            }
            
                            if (!normalizedData.icon && deviceIcons[deviceKey]) {
                                normalizedData.icon = deviceIcons[deviceKey];
                            }
                        }

                        window.deviceIdToMqttTopic = {};
                        Object.entries(window.devices).forEach(([mqttTopic, deviceData]) => {
                            if (deviceData.id) {
                                window.deviceIdToMqttTopic[deviceData.id] = mqttTopic;
                            }
                        });
        
                        console.log('🦆 Loaded devices with icons:', Object.keys(window.devices));
                        console.log('🦆 Room mappings:', window.roomDeviceMappings);
                        if (window.updateAllRoomControls) {
                            window.updateAllRoomControls();
                        }
        
                        if (window.syncRoomTogglesFromState) {
                            window.syncRoomTogglesFromState();
                        }
        
                        // 🦆 says ⮞ update status cards
                        // updateAllStatusCards();
  
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
                        setTimeout(() => {
                            updateDeviceSelector();
                            // 🦆 says ⮞ if we have a selected device in state, pre-select it!
                            if (window.selectedDevice && window.devices[window.selectedDevice]) {
                                const selector = document.getElementById('deviceSelect');
                                if (selector) {
                                    selector.value = window.selectedDevice;
                                }
                            }  
                            
                            // 🦆 says ⮞ update room controls with current state
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
                        
                        navTabs.forEach((tab) => {
                            tab.addEventListener('click', () => {
                                const pageIndex = parseInt(tab.getAttribute('data-page'));
                                showPage(pageIndex);
                            });
                        });
        
                  
                        // 🦆 says ⮞ DEVICE SELECTOR EVENT LISTENER
                        document.getElementById('deviceSelect')?.addEventListener('change', function() {
                            const selectedDeviceValue = this.value;
                            window.selectedDevice = selectedDeviceValue;
                            selectedDevice = selectedDeviceValue;

                            updateDeviceUI(devices[selectedDeviceValue]);
                            document.getElementById('currentDeviceName').textContent =
                              devices[selectedDeviceValue]?.friendly_name || selectedDeviceValue;
                            if (!selectedDeviceValue) return;

                            const deviceData = window.devices?.[selectedDeviceValue] || 
                                               devices?.[selectedDeviceValue] ||
                                               (window.devices && Object.values(window.devices).find(d => d.id === selectedDeviceValue));
    
                            console.log('🦆 Found device data:', deviceData);
    
                            if (deviceData) {
                                window.selectedDevice = selectedDeviceValue;
                                updateDeviceUI(deviceData);
                                showPage(1);
                                updateDeviceIcon(selectedDeviceValue);
                            } else {
                                console.warn('🦆 No device data found for:', selectedDeviceValue);
                                showNotification('Device data not available', 'error');
                            }
    
                            saveState();
                        });
                        
                        document.querySelectorAll('.device').forEach(device => {
                            device.addEventListener('click', function(e) {
                                e.stopPropagation();
                                const deviceName = this.getAttribute('data-device-name') || 
                                                  this.querySelector('.device-name')?.textContent ||
                                                  this.textContent.trim();
        
                                console.log(`🦆 Device clicked: ''${deviceName}`);
        
                                const deviceData = window.devices[deviceName];
                                if (deviceData) {
                                    const newState = deviceData.state === 'ON' ? 'OFF' : 'ON';
                                    sendDeviceCommand(deviceName, { state: newState });
                                }
                            });
                        });
        
                        document.querySelectorAll('.scene-item').forEach(scene => {
                            scene.addEventListener('click', () => {
                                const sceneName = scene.getAttribute('data-scene');
                                const topic = `zigbee2mqtt/scene/''${sceneName}`;
                                const message = "{}";
                                client.publish(topic, message);
                                console.log(`Publishing to ''${topic}`);
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
                             
                const apiEndpoints = {
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
                                                                                                       
                initDashboard();
                
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
  
  # 🦆says⮞ write html to file
  environment.etc."index.html" = {
    text = indexHtml;
    mode = "0644";
  };

  environment.etc."login.html" = {
    text = login.loginHtml;
    mode = "0644";
  };
  
  # 🦆says⮞ write json files
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

  # 🦆 says ⮞ favicons
  environment.etc."favicon-32x32.png".source = ./../../modules/themes/icons/favicons/duckdash/favicon-32x32.png;
  environment.etc."favicon-16x16.png".source = ./../../modules/themes/icons/favicons/duckdash/favicon-16x16.png;
  environment.etc."favicon.ico".source = ./../../modules/themes/icons/favicons/duckdash/favicon.ico;
  environment.etc."apple-touch-icon.png".source = ./../../modules/themes/icons/favicons/duckdash/apple-touch-icon.png;
  environment.etc."android-chrome-512x512.png".source = ./../../modules/themes/icons/favicons/duckdash/android-chrome-512x512.png;
  environment.etc."android-chrome-192x192.png".source = ./../../modules/themes/icons/favicons/duckdash/android-chrome-192x192.png;

  # 🦆 says ⮞ lastly a manifest 4 iOS "app" 
  environment.etc."site.webmanifest".source = login.iOSmanifest;

  }
