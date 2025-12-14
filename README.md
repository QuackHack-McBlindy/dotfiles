# ❄️🦆 **QuackHack-McBLindy NixOS dotfiles** <br>

<!-- VERSIONS_START -->
![NixOS](https://img.shields.io/badge/NixOS-25.11-blue?style=flat-square&logo=NixOS&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-black?style=flat-square&logo=opensourceinitiative&logoColor=white)
![Linux Kernel](https://img.shields.io/badge/Linux-6.12.30-red?style=flat-square&logo=linux&logoColor=white)
![GNOME](https://img.shields.io/badge/GNOME-48.1-purple?style=flat-square&logo=gnome&logoColor=white)
![Bash](https://img.shields.io/badge/bash-5.2.37-red?style=flat-square&logo=gnubash&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.12.10-%23FFD43B?style=flat-square&logo=python&logoColor=white)
![Rust](https://img.shields.io/badge/Rust-1.86.0-orange?style=flat-square&logo=rust&logoColor=white)
![Nix](https://img.shields.io/badge/Nix-2.28.3-blue?style=flat-square&logo=nixos&logoColor=white)


<!-- VERSIONS_END -->

[![Sponsors](https://img.shields.io/github/sponsors/QuackHack-McBlindy?logo=githubsponsors&label=?&style=flat&labelColor=ff1493&logoColor=fff&color=rgba(234,74,170,0.5) "")](https://github.com/sponsors/QuackHack-McBlindy)<div align="right"><sub>

_This is a <abbr title="Magically automated with duck-powered quackery">automagiduckically</abbr> updated README.md_

</sub></div> 


> [!CAUTION]
> __Do not blindly run this flake.__ <br>
> **That's my job.** 🧑‍🦯
<br>


__Here lives home machines configurations,__  
__and home automations, fully reproducible,__  
__crafted as a tiny Nix flake__  
__Glued together by a Nix-flavoured command line utility,__  
__easiy expanded and used to deploy, doc, and duck around__ 🦆✨  



## **What makes this configuration unique?** 

Nix declarative configuration style, custom modules evaluated dynamically for each host. <br>
Home Manager - __No ducking way!__ I just auto symlink ./home to /home <br>
Zigbee and smart home tightly integrated with Nix. For not just a declarative house but also deployable apartments. <br>
Not only that - voice assistant is LIGHTNIGHT FAST! (ms) ⚡🏆 <br><br>

<!-- SCRIPT_STATS_START -->
- __99 qwacktastic scripts in /bin - 59 scripts have voice commands.__ <br>
- __2468 dynamically generated regex patterns - makes 294355072 phrases available as commands.__ <br>
- __Smart Home Nix Style - Managing 2 TV's, 41 devices & 6 scenes.__ <br>
<!-- SCRIPT_STATS_END -->
- __Natural Language support with complete voice pipeline__ <br>
- __duckGPT Frontend Chatbot - Better than regularGPT, less thinking more doing__ <br>
- __Infra as everyday accessibility__ <br>
- __Yubikey encrypted deployment system__ <br>
- __Self Documenting__<br>

_List would get long, very quackly._ <br>
_perhaps a more suitable question would be:_ <br>
_"What makes this configuration common?_" <br>


<br> 
  
## ❄️ **Flake**

<details><summary><strong>
Define yourself at `config.this.user.me`.
</strong></summary>

<!-- USER_START -->
```nix
{
  discord = "https://discordapp.com/users/675530282849533952";
  dotfilesDir = "/home/pungkula/dotfiles";
  email = "isthisrandomenough@protonmail.com";
  extraGroups = [ "networkmanager" "wheel" "dialout" "docker" "dockeruser" "users" "pungkula" "adbusers" "audio" "2000" ];
  hashedPassword = "$y$j9T$m8hPD36i1VMaO5rurbZ4j0$KpzQyat.F6NoWFKpisEj77TvpN2wBGB8ezd26QoKDj6";
  matrix = "";
  mobileDevices =   {
    iphone =     {
      pubkey = "UFB0T1Y/uLZi3UBtEaVhCi+QYldYGcOZiF9KKurC5Hw=";
      wgip = "10.0.0.7"
    };
    tablet =     {
      pubkey = "ETRh93SQaY+Tz/F2rLAZcW7RFd83eofNcBtfyHCBWE4=";
      wgip = "10.0.0.8"
    };
  };
  name = "pungkula";
  repo = "git@github.com:QuackHack-McBlindy/dotfiles.git"
};
```
<!-- USER_END -->

</details>


<details><summary><strong>
Define each hosts data at `config.this.host`.
</strong></summary>

<!-- HOST_START -->
```nix
{
  hostname = "desktop";
  interface = [ "enp119s0" ];
  ip = "192.168.1.111";
  keys =   {
    privateKeys =     {
    };
    publicKeys =     {
      adb = "QAAAACEJNfsfRV4PQ9Ah87MbTVbMkbXC6CAMDOR+0K6mIpv/4TSzYMkc2qit3Kryc55IVOjwR3fJRjj/uL549gZ7nEemWtcd3AsYQBp0iIEor8nu1L/V6jfsTY6Xe/pl06xoroy6OwZRWuDbZ4wD2xQRRQjfPd+JtYnMAWneM6r1V15uR67w4ITvjk3ckyfgNeLZMUwahMRjC3wSjaU9sAdKNmg8yPd8uHZ+mK6mstxJFAGEpnnm1lE7Z2r0DF6h6MKY1++dwhU+WM5BRDNiBg+D4i6fDW4+Z1I9ENuFnjT17zAxZXch04SNlG3O94BANYP7jmKp60OvtDL6msfphntuIUzMCkndF9De0Kv4lJdQxe1d+wf+AFpmtd/xtrk45YdMV+eWCJf2OkidaHmSj4ffkAobpun0VrkZN2Z1JymmdsvUbyMjAsby3Zun0xr3EocUS8Jy5TcsK/dcpD6CB5dqzlHhsHSAWt2TDwPzZYXgV1xc+q+PqM09OVN1xActJu75UMkg5b84U15hwQvYdwB8UaopMWWk6p064c7gxYSfH7fSxwkW2Jy1CElgJa55Pp4SZG9b/3B+VcNL1WSf6v/lvJqPbrRvBqvS0+e9wcFMNZtQKTX3n5X0wW1/czZPCQX+hmM8Uu1qrtaz4rKViIEGf4YR0/9eUGYQVfuAxAh8ZmsroJlnAAEAAQA= pungkula@desktop";
      age = "age16utg7mmk73cn3glrwthtm0p7mf6g3vrd48h3ucpn6wnf28pgxvcsh4rjjp";
      borg = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMVYczAOBSeS7WfSvzYDOS4Q9Ss+yxCf2G5MVfAALOx/";
      builder = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINQ7c/AeIpmJS6cWQkHOe4ZEq3DXVRnjtTWuWfx6L46n";
      cache = "cache:/pbj1Agw2OoSSDZcClS69RHa1aNcwwTOX3GIEGKYwPc=";
      host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILdwPkRQxlbrbRGwEO5zMJ4m+7QqUQPZg1iqbd5HRP34";
      iPhone = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMcmr+z7k/yCbrFg+JDgo8JCuWqNVYn10ajRbNTp8fq";
      ssh = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPwZL27kGTQDIlSe03abT9F24nSAizORyjo5cI3BD92s";
      wireguard = "Oq0ZaYAnOo5sLpV//OEFwLgjVCxPyeQqf8cZBASluWk="
    };
  };
  modules =   {
    hardware = [ "cpu/intel" "gpu/amd" "audio" ];
    networking = [ "default" "pool" ];
    programs = [ "default" "thunar" "firefox" "vesktop" ];
    services = [ "ssh" "default" "adb" "backup" "cache" "keyd" "jelly" "duck-tv" ];
    system = [ "nix" "pkgs" "gnome" "crossEnv" "gtk" ];
    virtualisation = [ "docker" "vm" ]
  };
  system = "x86_64-linux";
  wgip = "10.0.0.2"
};
```
<!-- HOST_END -->

</details>


<details><summary><strong>
Define any optional theme configuration at `config.this.theme`.
</strong></summary>

<!-- THEME_START -->
```nix
{
  cursorTheme =   {
    name = "Bibata-Modern-Classic";
    package = "/nix/store/1np4cfqil5jh04zmscj3i6h2zvh9yqvv-bibata-cursors-2.0.7";
    size = 32
  };
  enable = false;
  fonts =   {
    monospace = "Fira Code";
    packages = [ "/nix/store/k4s2ckig2pyi2lzzaxmh8wcwbq7n7pz3-fira-code-6.2" ];
    system = "Fira Sans"
  };
  gtkSettings =   {
    gtk-application-prefer-dark-theme = "1";
    gtk-cursor-theme-name = "Bibata-Modern-Classic";
    gtk-icon-theme-name = "elementary-xfce-icon-theme"
  };
  iconTheme =   {
    name = "Papirus-Dark";
    package = "/nix/store/5ncf05fvvy7zmb2azprzq1qhymwh733h-papirus-icon-theme-20250201"
  };
  name = "gtk3.css";
  styles = "/nix/store/wwymsjp8d6kiryy9n4hdd1zgmxlpzr26-source/modules/themes/css/gtk3.css"
};
```
<!-- THEME_END -->

</details>


<details><summary><strong>
Define Zigbee-devices, scenes, automations, tv's, channels, etc at `config.house`.
</strong></summary>

<!-- SMARTHOME_START -->
```nix
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
        lib.lists.head (lib.strings.splitString " " (lib.lists.elemAt (lib.strings.splitString "
" resolved) 0))
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
          format = "${value}";
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
          format = "${value}";
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
                  const response = await fetch('http://${mqttHostip}:9815/health/all');
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
                    <div class="chat-bubble ai-bubble">
                        🦆Quack quack! 🦆 I'm a 🦆 here to help! Qwack to me yo!
                    </div>
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
                  host: '192.168.1.211',
                  port: '9815',
                  baseUrl: 'http://192.168.1.211:9815'
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
                    const lines = text.split('
');
                    let pipeCount = 0;
                    for (const line of lines) {
                        if (line.trim().startsWith('|') && line.includes('|') && line.split('|').length > 2) {
                            pipeCount++;
                        }
                    }             
                }

                function convertMarkdownTableToHTML(text) {
                    const lines = text.split('
').filter(line => 
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
                    const outputMatch = responseText.match(/"output":"([sS]*?)"(?=,|})/);
                    if (outputMatch && outputMatch[1]) {
                        return outputMatch[1];
                    }
                    
                    return responseText;
                }
                
                function cleanAPIResponse(output) {
                    if (!output) return "Command executed!";         
                    let cleaned = output.replace(/[[0-9;]*m/g, "");
                    cleaned = cleaned.replace(/\n/g, '
');         
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

                function enhanceContent(content) {
                    // 🦆 says ⮞ cleanup on ile 3!!
                    const cleaned = content
                        .split('
')
                        .filter(line => !line.includes('Loading fuzzy index from:'))
                        .join('
');

                    const noAnsi = cleaned.replace(/[[0-9;]*m/g, "");
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
                            .replace(/
/g, '<br>');        
                        return {
                            type: 'html',
                            content: html
                        };
                    }
                }

                function addAIMessage(content, options = {}) {
                    const chatContainer = document.getElementById('chat');
                    const typingIndicator = document.querySelector('.typing-indicator');
                    if (typingIndicator) {
                        chatContainer.removeChild(typingIndicator);
                    }

                    // 🦆 says ⮞ pretty chat bubble up                  
                    const enhanced = enhanceContent(content);
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
                    } else {
                        aiBubble.innerHTML = enhanced.content;
                    }

                    chatContainer.appendChild(aiBubble);
                    chatContainer.scrollTop = chatContainer.scrollHeight;

                    // 🦆 play TTS audio file
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

                // 🦆 says ⮞ FUCK!
                function addErrorMessage(text) {
                    const chatContainer = document.getElementById('chat');
                    const typingIndicator = document.querySelector('.typing-indicator');
                    if (typingIndicator) {
                        chatContainer.removeChild(typingIndicator);
                    }

                    const cleanedText = text
                        .split('
')
                        .filter(line => !line.includes('Loading fuzzy index from:'))
                        .join('
');

                    const errorBubble = document.createElement('div');
                    errorBubble.className = 'chat-bubble error-special-bubble';
    
                    // 🦆 says ⮞ extraction
                    const errorMatch = cleanedText.match(/🦆 says ⮞ fuck ❌[^
]*/);
                    const errorMessage = errorMatch ? errorMatch[0].replace('🦆 says ⮞ ', "") : 'Error!';
    
                    errorBubble.innerHTML = `
                        <div class="error-special-text">🦆says⮞''${errorMessage}</div>
                    `;
    
                    chatContainer.appendChild(errorBubble);
    
                    const matches = [];
                    const lines = cleanedText.split('
');
                    lines.forEach(line => {
                        const match = line.match(/(d+)%:s*'([^']+)'s*->s*(.*)/);
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
                                document.getElementById('prompt').value = match.pattern.replace(/{[^}]+}/g, '...');
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
                  const lines = errorText.split('
');
                  let html = "";
  
                  lines.forEach(line => {
                    if (line.includes('Input:')) {
                      html += `<div class="error-input"><strong>Your input:</strong> ''${line.replace('Input: ', "")}</div>`;
                    } else if (line.includes('%:')) {
                      const match = line.match(/(d+)%:s*'([^']+)'s*->s*(.*)/);
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
        
        # 🦆 says ⮞ 1. MQTT triggered automations
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


          alarms = {
            enable = true;
            description = "Sets an alarm";
            topic = "zigbee2mqtt/alarm/set";
            actions = [
              {
                type = "shell";
                command = ''
                  SOUNDHOST="desktop"
                  hours=$(echo "$MQTT_PAYLOAD" | jq -r '.hours')
                  minutes=$(echo "$MQTT_PAYLOAD" | jq -r '.minutes')
                  sound=$(echo "$MQTT_PAYLOAD" | jq -r '.sound // ""')
          
                  LOGFILE_DIR="/var/lib/zigduck/alarms"
                  mkdir -p "$LOGFILE_DIR"
          
                  now=$(date +%s)
                  target=$(date -d "today $hours:$minutes" +%s)
                  if [ $target -le $now ]; then
                    target=$(date -d "tomorrow $hours:$minutes" +%s)
                  fi       
                  (
                    while [ $(date +%s) -lt $target ]; do
                      remaining=$((target - $(date +%s)))
                      echo -ne "Time until alarm: ''${remaining}s"
                      sleep 1
                    done
                    echo -e "
e[1;5;31m[ALARM RINGS]e[0m"
                    rm -rf "$LOGFILE_DIR/$$.pid"
                    if [ -f "$sound" ]; then
                      for i in {1..10}; do
                        ssh $SOUNDHOST aplay "$sound" >/dev/null 2>&1
                      done
                      sleep 30
                      for i in {1..8}; do
                        ssh $SOUNDHOST aplay "$sound" >/dev/null 2>&1
                      done
                    fi
                  ) > /var/lib/zigduck/alarms/yo-alarm.log 2>&1 &
                  pid=$!
                  echo "$pid $target" > "$LOGFILE_DIR/$pid.pid"
                  disown "$pid"
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
                  current_price=$(echo "$MQTT_PAYLOAD" | jq -r '.current_price' | sed 's/"//g')
                  # 🦆says⮞ notify if high energy price
                  if [ $(echo "$current_price > 2.0" | bc -l) -eq 1 ]; then
                    yo notify "⚡ High energy price: $current_price SEK/kWh"
                  fi
                '';
              }
            ];
          }; # health checks
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
```
<!-- SMARTHOME_END -->

</details>


<details><summary><strong>
And you'll get a dashboard for your devices generated and found at http://localhost:13337 <br> 


[Watch demo](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/home/duckdash.mp4)


</strong></summary>
<img src="https://github.com/QuackHack-McBlindy/dotfiles/blob/main/home/duckdash1.png?raw=true" width="25%">
<img src="https://github.com/QuackHack-McBlindy/dotfiles/blob/main/home/duckdash2.png?raw=true" width="25%">
<img src="https://github.com/QuackHack-McBlindy/dotfiles/blob/main/home/duckdash3.png?raw=true" width="25%">
<img src="https://github.com/QuackHack-McBlindy/dotfiles/blob/main/home/duckdash4.png?raw=true" width="25%">
<img src="https://github.com/QuackHack-McBlindy/dotfiles/blob/main/home/duckdash5.png?raw=true" width="25%">

<br>
The dashboard currently gives you: <br><br>

- __Advanced zigbee device control__ <br>
- __Remote for your Android TV devices__ <br>
- __Set scenes__ <br>
- __Access to `yo do` through both an text input field aswell as microphone__ <br>
- __and more...__ <br>


</details>



<details><summary><strong>
I like my flakes tiny & ny modules dynamically loaded,  
</strong></summary>

<!-- FLAKE_START -->
```nix
# dotfiles/flake.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{
    description = "❄️🦆 ⮞ QuackHack-McBLindy's NixOS flake";
    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";        
        sops-nix.url = "github:Mic92/sops-nix";
        sops-nix.inputs.nixpkgs.follows = "nixpkgs";  
        caddy-duckdns.url = "github:QuackHack-McBlindy/nix-caddy-duckdns";
        installer.url = "github:QuackHack-McBlindy/auto-installer-nixos";
    };
    outputs = inputs @ { self, systems, nixpkgs, ... }:
        let
            lib = import ./lib { 
                inherit self inputs;
                lib = nixpkgs.lib;      
            };                   
        in lib.makeFlake {
            systems = [ "x86_64-linux" "aarch64-linux" ]; 
            overlays = lib.mapOverlays ./overlays { inherit lib; };
            hosts = lib.mapHosts ./hosts;
            specialArgs = { pkgs = system: nixpkgs.legacyPackages.${system}; };
            packages = lib.mapModules ./packages import;
            devShells = lib.mapModules ./devShells (path: import path);     
        };} # 🦆 duck say ⮞ flakes all set, with no debating — next nix file awaiting, ducks be there waitin'
```
<!-- FLAKE_END -->
</details>

<br>

<details><summary><strong>
View Flake Outputs
</strong></summary>

  <!-- TREE_START -->
```nix
git+file:///home/pungkula/dotfiles
├───devShells
│   ├───aarch64-linux
│   │   ├───android omitted (use '--all-systems' to show)
│   │   ├───esphome omitted (use '--all-systems' to show)
│   │   ├───go omitted (use '--all-systems' to show)
│   │   ├───java omitted (use '--all-systems' to show)
│   │   ├───node omitted (use '--all-systems' to show)
│   │   ├───python312 omitted (use '--all-systems' to show)
│   │   ├───python38 omitted (use '--all-systems' to show)
│   │   └───rust omitted (use '--all-systems' to show)
│   └───x86_64-linux
│       ├───android: development environment 'nix-shell'
│       ├───esphome: development environment 'nix-shell'
│       ├───go: development environment 'nix-shell'
│       ├───java: development environment 'nix-shell'
│       ├───node: development environment 'nix-shell'
│       ├───python312: development environment 'nix-shell'
│       ├───python38: development environment 'nix-shell'
│       └───rust: development environment 'nix-shell'
├───nixosConfigurations
│   ├───desktop: NixOS configuration
│   ├───homie: NixOS configuration
│   ├───laptop: NixOS configuration
│   └───nasty: NixOS configuration
├───overlays
│   └───noisereduce: Nixpkgs overlay
└───packages
    ├───aarch64-linux
    │   ├───health omitted (use '--all-systems' to show)
    │   ├───installer omitted (use '--all-systems' to show)
    │   ├───jellyfin omitted (use '--all-systems' to show)
    │   ├───say omitted (use '--all-systems' to show)
    │   ├───tv omitted (use '--all-systems' to show)
    │   └───yo-bitch omitted (use '--all-systems' to show)
    └───x86_64-linux
        ├───health: package 'health'
        ├───installer: package 'nixos-auto-installer-24.05.20240406.ff0dbd9-x86_64-linux.iso'
        ├───jellyfin: package 'jellyfin'
        ├───say: package 'say'
        ├───tv: package 'tv'
        └───yo-bitch: package 'yo-bitch'
```
  <!-- TREE_END -->

</details>  
  

## **🛟 Quick Start**

**Build automated, offline USB NixOS installer** 

```bash
$ sudo bash usb-installer \
  --user "pungkula" \
  --host "laptop" \
  --ssid "IfYouDontHaveEthernet" \
  --wifipass "CanBeOmitted" \
  --publickey "ssh-ed25519 AAAAC3FoRSsHCoNnEcTiOn..."
``` 

<br>

```bash
# dd result to flash drive (replace sdX)
$ sudo dd if="$(readlink -f ./result/iso/*.iso)" of=/dev/sdX bs=4M status=progress oflag=sync
``` 

Plug in flash drive into laptop and boot. Let it work and wait until it powers down.  
Remove flash drive, boot it up again and deploy configuration from your main machine:

```bash
# 🦆🔓 First deploy? Get your Yubikey: PIN+Touch unlocks host specific AGE key for sops-nix 
$ yo deploy laptop
```

**Any builds after first deployment will use local cached binaries for enhanced build time.**  

<br>

<!-- YO_DOCS_START -->
## 🚀 **yo CLI 🦆**
The `yo` CLI is a framework designed to execute scripts defined in the `./bin` directory.  
It provides a unified interface for script execution, centralizes all help commands, and automatically validates parametrs and updates the documentation.  

**Usage:** `yo <command> [arguments]`  

### **Usage Examples:**  
The yo CLI supports flexible parameter parsing through two primary mechanisms:  

```bash
# Named Parameters  
$ yo deploy --host laptop --flake /home/pungkula/dotfiles

# Positional Parameters
$ yo deploy laptop /home/pungkula/dotfiles

# Scripts can also be executed with natural language text by typing:
$ yo do "is laptop overheating"
# Natural language voice commands are also supported, say:
"yo bitch reboot the laptop"

# If the server is not running, it can be manually started with:
$ yo transcribe
$ yo wake
```

### ✨ Available Commands
Set default values for your parameters to have them marked [optional]
| Command Syntax               | Aliases    | Description | VoiceReady |
|------------------------------|------------|-------------|--|
| **🖥️ System Management** | | | |
| [yo deploy](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/system/deploy.nix) --host [--flake] [--user] [--repo] [--port] [--test] |  | Build and deploy a NixOS configuration to a remote host. Bootstraps, builds locally, activates remotely, and auto-tags the generation. | ✅ |
| [yo dev](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/system/dev.nix) [--devShell] |  | Start development enviorment | 📛 |
| [yo dry](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/system/dry.nix)  |  | Build and deploy a NixOS configuration to a remote host. Bootstraps, builds locally, activates remotely, and auto-tags the generation. | 📛 |
| [yo esp](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/system/esp.nix) [--device] [--serialPort] [--ota] [--otaPort] [--OTAPwFile] [--wifiSSID] [--wifiPwFile] [--mqttHost] [--mqttUser] [--mqttPwFile] [--transcriptionHostIP] |  | Declarative firmware deployment tool for ESP32 boards with built-in version control. | 📛 |
| [yo espOTA](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/system/espOTA.nix)  |  | Updates ESP32 devices over the air. | 📛 |
| [yo reboot](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/system/reboot.nix) [--host] | restart | Force reboot and wait for host | ✅ |
| [yo rollback](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/system/rollback.nix) --host [--flake] [--user] |  | Rollback a host to a previous NixOS generation. Fetches Git tags and reverts system+config to a synced, tagged state. | 📛 |
| [yo services](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/system/services.nix) --operation --service --host [--user] [--port] [--!] |  | Systemd service handler. | ✅ |
| [yo switch](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/system/switch.nix) [--flake] [--!] | rb | Rebuild and switch Nix OS system configuration. ('!' to test) | ✅ |
| **⚡ Productivity** | | | |
| [yo calculator](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/productivity/calculator.nix) --expression | calc | Calculate math expressions | ✅ |
| [yo calendar](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/productivity/calendar.nix) [--operation] [--calenders] | kal | Calendar assistant. Provides easy calendar access. Interactive terminal calendar, or manage the calendar through yo commands or with voice. | ✅ |
| [yo clip2phone](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/productivity/clip2phone.nix) --copy |  | Send clipboard to an iPhone, for quick copy paste | ✅ |
| [yo fzf](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/productivity/fzf.nix)  | f | Interactive fzf search for file content with quick edit & jump to line | 📛 |
| [yo google](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/productivity/google.nix) --search [--apiKeyFile] [--searchIDFile] | g | Perform web search on google | ✅ |
| [yo hitta](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/productivity/hitta.nix) --search |  | Locate a persons address with help of Hitta.se | ✅ |
| [yo img2phone](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/productivity/img2phone.nix) --image |  | Send images to an iPhone | 📛 |
| [yo pull](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/productivity/pull.nix) [--flake] [--host] |  | Pull the latest changes from your dotfiles repo. Resets tracked files to origin/main but keeps local extras. | ✅ |
| [yo push](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/productivity/push.nix) [--flake] [--repo] [--host] [--generation] | ps | Commit, tag, and push dotfiles and system state to GitHub. Tags based on host + generation, auto-updates README, and preserves history. | 📛 |
| [yo scp](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/productivity/scp.nix) --host [--path] [--username] [--downloadPath] |  | Move files between hosts interactively | 📛 |
| [yo update-readme](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/productivity/update-readme.nix) [--readmePath] |  | Updates the documentation in README.md | 📛 |
| **🌍 Localization** | | | |
| [yo stores](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/stores.nix) --store_name [--location] [--radius] | store, shop | Finds nearby stores using OpenStreetMap data with fuzzy name matching. Returns results with opening hours. | ✅ |
| [yo travel](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/travel.nix) [--arrival] [--departure] [--type] [--apikeyPath] |  | Public transportation helper. Fetches current bus and train schedules. (Sweden) | ✅ |
| [yo weather](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/weather.nix) [--location] [--day] [--condition] [--locationPath] | weat | Weather Assistant. Ask anything weather related (3 day forecast) | ✅ |
| **🌐 Networking** | | | |
| [yo api](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/network/api.nix) [--host] [--port] [--dir] |  | API endpoints for smart home control, virtual media playlist management, system wide health checks and more. | 📛 |
| [yo block](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/network/block.nix) --url [--blocklist] | ad | Block URLs using DNS | 📛 |
| [yo ip-updater](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/network/ip-updater.nix) [--token1] [--token2] [--token3] |  | DDNS updater | ✅ |
| [yo notify](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/network/notify.nix) [--text] [--title] [--icon] [--url] [--group] [--sound] [--volume] [--copy] [--autoCopy] [--level] [--encrypt] [--base_urlFile] [--deviceKeyFile] |  | Send custom push to iOS devices | 📛 |
| [yo notify-me](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/network/notify-me.nix) [--address] [--port] [--dataDir] |  | Notification server for iOS devices | 📛 |
| [yo shareWiFi](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/network/shareWiFi.nix) [--ssidFile] [--passwordFile] |  | creates a QR code of guest WiFi and push image to iPhone | ✅ |
| [yo speed](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/network/speed.nix)  | st | Test internet download speed | ✅ |
| **🎧 Media Management** | | | |
| [yo call-remote](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/media/call-remote.nix)  | call | Used to call the tv remote, for easy localization. | ✅ |
| [yo hacker-news](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/media/hacker-news.nix) [--show] [--item] [--user] [--clear] [--number] | hn | Hacker news API controller | 📛 |
| [yo news](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/media/news.nix) [--apis] [--clear] [--playedFile] |  | API caller and playlist manager for latest Swedish news from SR. | ✅ |
| [yo transcode](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/media/transcode.nix) [--directory] | trans | Transcode media files | 📛 |
| [yo tv](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/media/tv.nix) [--typ] [--search] [--device] [--season] [--shuffle] [--tvshowsDir] [--moviesDir] [--musicDir] [--musicvideoDir] [--videosDir] [--podcastDir] [--audiobookDir] [--youtubeAPIkeyFile] [--webserver] [--defaultPlaylist] [--favoritesPlaylist] [--max_items] [--mqttUser] [--mqttPWFile] | remote | Android TV Controller. Fuzzy search all media types and creates playlist and serves over webserver for casting. Fully conttrollable. | ✅ |
| [yo tv-guide](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/media/tv-guide.nix) [--search] [--channel] [--jsonFilePath] | tvg | TV-guide assistant.. | ✅ |
| [yo tv-scraper](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/media/tv-scraper.nix) [--epgFilePath] [--jsonFilePath] [--flake] | tvs | Scrapes web for tv-listing data. Builds EPG and generates HTML. | 📛 |
| [yo vlc](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/media/vlc.nix) [--add] [--addDir] [--remove] [--list] [--shuffle] [--clear] [--playlist] |  | Playlist management for the local machine | 📛 |
| **📁 File Operations** | | | |
| [yo copy](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/files/copy.nix) --from --to | cp | Copy a file or directory to a new location | ✅ |
| [yo list](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/files/list.nix) [--path] | ls | List directory contents with details | ✅ |
| [yo makedir](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/files/makedir.nix) --path | mkd | Create a new directory with parents if needed | ✅ |
| [yo move](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/files/move.nix) --from --to | mv | Move a file or directory to a new location | ✅ |
| [yo nano](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/files/nano.nix) --file --content |  | Write content to filepath | ✅ |
| [yo remove](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/files/remove.nix) --target | rm, delete | Remove files or directories safely | ✅ |
| **🔐 Security & Encryption** | | | |
| [yo sops](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/security/sops.nix) --input [--operation] [--value] [--output] [--agePub] | e | Encrypts a file with sops-nix | 📛 |
| [yo yubi](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/security/yubi.nix) --operation --input | yk | Encrypts and decrypts files using a Yubikey and AGE | 📛 |
| **🗣️ Voice** | | | |
| [yo cancel](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/voice/cancel.nix) [--input] |  | Cancel coammands microphone recording sent to transcription. | ✅ |
| [yo do](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/voice/do.nix) [--input] [--fuzzy] [--dir] [--build] [--realtime] | brain | Brain (do) is a Natural Language to Shell script translator that generates dynamic regex patterns at build time for defined yo.script sentences. At runtime it runs exact and fuzzy pattern matching with automatic parameter resolution and seamless execution | 📛 |
| [yo do-bash](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/voice/do-bash.nix) --input [--fuzzy] |  | [🦆🧠] yo do - The Brain of this repository. Natural language to Shell script translator with dynamic regex matching and automatic parameter resolutiion with some fuzzy on top of that. Written in Bash (slower, but more dope🦆, don't ya think?) | 📛 |
| [yo espaudio](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/voice/espaudio.nix)  |  | WIP! ESP32 audio development | 📛 |
| [yo kill-mic](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/voice/kill-mic.nix)  |  | Kill mic-stream by port with voice | ✅ |
| [yo memory](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/voice/memory.nix) [--show] [--record] [--good] [--tail] [--reset] | stats | Memory is stats and metrics that acts as contexual awareness for the natural langugage processor.  | 📛 |
| [yo mic](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/voice/mic.nix) [--port] [--host] [--seconds] |  | [🦆🎙️] Trigger microphone recording sent to transcription. | 📛 |
| [yo mic-stream](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/voice/mic-stream.nix) [--chunk] [--silence] [--silenceLevel] |  | Stream microphone audio to WS chunk transcription | 📛 |
| [yo say](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/voice/say.nix) --text [--model] [--modelDir] [--silence] [--host] [--blocking] [--file] [--caf] [--web] |  | Text to speech with built in language detection and automatic model downloading | ✅ |
| [yo sleep](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/voice/sleep.nix) --time |  | Waits for specified time (seconds). Useful in command chains. | ✅ |
| [yo tests](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/voice/tests.nix) [--input] [--stats] |  | Extensive automated sentence testing for the NLP | ✅ |
| [yo tests-rs](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/voice/tests-rs.nix) [--input] [--stats] [--fuzzy] [--dir] [--build] [--realtime] |  | Extensive automated sentence testing for the NLP () | 📛 |
| [yo train](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/voice/train.nix) --phrase |  | Trains the NLP module. Correct misclassified commands and update NLP patterns | 📛 |
| [yo transcribe](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/voice/transcribe.nix) [--port] [--model] [--language] [--beamSize] [--gpu] [--cert] [--key] |  | Transcription server-side service. Sit and waits for audio that get transcribed and returned. | 📛 |
| [yo transcription-ws](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/voice/transcription-ws.nix)  |  | WebSocket server for real-time transcription streaming to NLP | 📛 |
| [yo wake](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/voice/wake.nix) [--threshold] [--cooldown] [--sound] [--remoteSound] [--redisHost] [--redis_pwFIle] |  | Run Wake word detection for audio recording and transcription | 📛 |
| **🛖 Home Automation** | | | |
| [yo alarm](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/alarm.nix) --hours --minutes [--list] [--sound] | wakeup | Set an alarm for a specified time | ✅ |
| [yo battery](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/battery.nix) [--device] |  | Fetch battery level for specified device. | ✅ |
| [yo bed](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/bed.nix) [--part] [--state] |  | Bed controller | ✅ |
| [yo blinds](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/blinds.nix) [--state] |  | Turn blinds up/down | ✅ |
| [yo chair](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/chair.nix) [--part] [--state] |  | Chair controller | ✅ |
| [yo display](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/display.nix) --path |  | Creates a HTML image that can be displayed on the chat frontend. | ✅ |
| [yo duckDash](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/duckDash.nix) [--host] [--port] [--cert] [--key] | dash | Mobile-first dashboard, unified frontend for Zigbee devices, tv remotes, and other smart home gadgets. Includes DuckCloud page for easy access to your files. (Use WireGuard) | 📛 |
| [yo findPhone](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/findPhone.nix)  |  | Helper for locating Phone | ✅ |
| [yo house](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/house.nix) [--device] [--state] [--brightness] [--color] [--temperature] [--scene] [--room] [--user] [--passwordfile] [--flake] [--pair] [--cheapMode] |  | Control lights and other home automatioon devices | ✅ |
| [yo kitchenFan](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/kitchenFan.nix) [--state] |  | Turns kitchen fan on/off | ✅ |
| [yo leaving](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/leaving.nix)  |  | Run when leaving house to set away state | 📛 |
| [yo mqtt_pub](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/mqtt_pub.nix) --topic --message |  | Mosquitto publisher | 📛 |
| [yo returned](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/returned.nix)  |  | Run when returned home to set home state | 📛 |
| [yo robobot](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/robobot.nix) --device [--mode] [--state] [--delay] [--reverse] [--lower] [--upper] [--touch] [--user] [--passwordfile] |  | Designed to simplify configuring the Zigbee Fingerbot Plus | 📛 |
| [yo state](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/state.nix) [--device] |  | Fetches the state of the specified device. | ✅ |
| [yo temperatures](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/temperatures.nix)  |  | Get all temperature values from sensors and return a average value. | ✅ |
| [yo tibber](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/tibber.nix) [--mode] [--homeIDFile] [--APIKeyFile] [--filePath] [--user] [--pwfile] | el | Fetches home electricity price data | ✅ |
| [yo timer](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/timer.nix) [--minutes] [--seconds] [--hours] [--list] [--sound] |  | Set a timer | ✅ |
| [yo toilet](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/toilet.nix)  |  | Flush the toilet | ✅ |
| [yo zigduck](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/zigduck.nix) [--user] [--pwfile] |  | [🦆🏡] yo zigduck - Home automation system written in Bash | 📛 |
| [yo zigduck-rs](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/zigduck-rs.nix) [--dir] [--user] [--pwfile] |  | [🦆🏡] ZigDuck - Home automation system! Devices, scenes, automations -- EVERYTHING is defined using Nix options from the module 'house.nix'. (Written in Rust) | 📛 |
| **🧩 Miscellaneous** | | | |
| [yo btc](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/btc.nix) [--filePath] [--user] [--pwfile] |  | Crypto currency BTC price tracker | ✅ |
| [yo chat](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/chat.nix) --text |  | No fwendz? Let's chat yo! | ✅ |
| [yo duckPUCK](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/duckPUCK.nix) [--mode] [--team] [--stat] [--count] [--dataDir] | puck | [🏒🦆] - Your Personal Hockey Assistant! - Expert commentary and analyzer specialized on Hockey Allsvenskan (SWE). Analyzing games, scraping scoreboards and keeping track of all dates annd numbers. | ✅ |
| [yo hockeyGames](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/hockeyGames.nix) [--type] [--days] [--team] [--dataDir] [--debug] | hag | Hockey Assistant. Provides Hockey Allsvenskan data and deliver analyzed natural language responses (TTS). | ✅ |
| [yo invokeai](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/invokeai.nix) --prompt [--host] [--port] [--outputDir] [--width] [--height] [--steps] [--cfgScale] [--seed] [--model] | genimg | AI generated images powered by InvokeAI | ✅ |
| [yo joke](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/joke.nix) [--jokeFile] |  | Duck says s funny joke. | ✅ |
| [yo post](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/post.nix) [--postalCodeFile] [--postalCode] |  | Check for the next postal delivery day. (Sweden) | ✅ |
| [yo qr](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/qr.nix) --input [--icon] [--output] |  | Create fun randomized QR codes from input. | 📛 |
| [yo reminder](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/reminder.nix) [--about] [--list] [--clear] [--user] [--pwfile] | remind | Reminder Assistant | ✅ |
| [yo shop-list](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/shop-list.nix) [--operation] [--item] [--list] [--mqttUser] [--mqttPWFile] |  | Shopping list management | ✅ |
| [yo suno](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/suno.nix) --prompt [--genre] | mg | AI generated lyrics and music files powered by Suno | ✅ |
| [yo time](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/time.nix)  |  | Tells time, day and date | ✅ |
| [yo xmr](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/xmr.nix) [--filePath] [--user] [--pwfile] |  | Crypto currency XMR price tracker | ✅ |
| **🧹 Maintenance** | | | |
| [yo clean](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/maintenance/clean.nix)  | gc | Run a total garbage collection: Removes old NixOS generations, empty trash, flush tmp files, whipes cache and runs a docker prune | 📛 |
| [yo duckTrace](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/maintenance/duckTrace.nix) [--script] [--host] [--errors] [--monitor] | log | View duckTrace logs quick and quack, unified logging system | ✅ |
| [yo health](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/maintenance/health.nix)  | hc | Check system health status across your machines. Returns JSON structured responses. | ✅ |
### ❓ Detailed Help
For specific command help: 
`yo <command> --help`
`yo <command> -h`
<!-- YO_DOCS_END -->


<br>



## 💬 **Comments?**

**Nix Talk? Or just say tiny flake sucks?**   
**That's cool!**  
**I am all ears. 👀**  

<br>


<!-- CONTACT_START -->
[![Discord](https://img.shields.io/badge/Discord-Chat-5865F2?style=flat-square&logo=discord&logoColor=white)](https://discordapp.com/users/675530282849533952)
[![Email](https://img.shields.io/badge/Email-Contact-6D4AFF?style=flat-square&logo=protonmail&logoColor=white)](mailto:isthisrandomenough@protonmail.com)
[![GitHub Discussions](https://img.shields.io/badge/Discussions-Join-181717?style=flat-square&logo=github&logoColor=white)](https://github.com/QuackHack-McBlindy/dotfiles/discussions)

<!-- CONTACT_END -->

<br>

## 🦆 **Follow my Adventures**

[𝑸𝓾𝒂𝒄𝒌𝑯𝒂𝒄𝒌-𝑴𝒄𝑩𝒍𝒊𝒏𝒅𝒚 𝗕𝗹𝗼𝗴](https://quackhack-mcblindy.github.io/blog/)


<br>

> [!NOTE]
> __Im not blind.__ <br>
> **I just can't see.** 🧑‍🦯
<br>
