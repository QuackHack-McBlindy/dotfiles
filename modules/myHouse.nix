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

  # 🦆 says ⮞ load custom pages 4 dashboard
  customPages = import ./dashboard/customPages.nix { inherit lib config pkgs; };
  pages = customPages.pages;

  # 🦆 says ⮞ load css files
  css = {
    tv      = builtins.readFile ./themes/css/duckdash/tv.css;  
    health  = builtins.readFile ./themes/css/duckdash/health.css;
    chat    = builtins.readFile ./themes/css/duckdash/chat.css;
  };
  
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

  # 🦆 says ⮞ dis fetch what host has Mosquitto
  sysHosts = lib.attrNames self.nixosConfigurations; 
  mqttAuth = "-u ${config.house.zigbee.mosquitto.username} -P $(cat ${config.house.zigbee.mosquitto.passwordFile})"; 

  # 🦆 says ⮞ icon map
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


  Mqtt2jsonHistory = field: file: ''    
    FILE="/var/lib/zigduck/${file}"
    VALUE=$(echo "$MQTT_PAYLOAD" | jq '.${field}')
    mkdir -p "$(dirname "$FILE")"
    
    # 🦆 says ⮞ check current value
    if [ -s "$FILE" ]; then
        CURRENT=$(jq ".${field}" "$FILE")
        if [ "$CURRENT" = "$VALUE" ]; then
            exit 0 # 🦆 says ⮞ skip write – value unchanged
        fi
    fi
    
    # 🦆 says ⮞ otherwise, update
    if [ ! -s "$FILE" ]; then
        jq -n --argjson v "$VALUE" \
            '{ ${field}: $v, history: [$v] }' > "$FILE"
    else
        jq --argjson v "$VALUE" '
            .${field} = $v
            | .history += [$v]
            | .history = (.history[-200:])
        ' "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
    fi
  '';

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
    media.root = "/Pool";
    # 🦆says⮞ what machine should output sound   
    soundHost = "desktop";
    # 🦆 says ⮞ ROOM CONFIGURATION
    rooms = {
      bedroom.icon    = "mdi:bed";
      hallway.icon    = "mdi:door";
      kitchen.icon    = "mdi:food-fork-drink";
      livingroom.icon = "mdi:sofa";
      wc.icon         = "mdi:toilet";
      tv-area.icon    = "mdi:television";
      other.icon      = "mdi:misc";
    };
    
    # 🦆 says ⮞ DASHBOARD CONFIOGURATION 
    dashboard = { 
      passwordFile = config.sops.secrets.api.path; # 🦆 says ⮞  safety firzt!      
      # 🦆 says ⮞  home page information cards
      statusCards = {
        calendar = {
          enable = true;
          title = "𝑪𝑨𝑳𝑬𝑵𝑫𝑨𝑹";
          group = "1";
          icon = "fas fa-calendar";
          color = "#ff0000";
          theme = "glass";
          filePath = "/var/lib/zigduck/calendar.json";
          jsonField = "today_date";
          format = "{value}";
          detailsJsonField = "today_events";
          detailsFormat = "{value}";
          chart = false;
          on_click_action = [
            {
              type = "shell";
              command = "yo say \"detta är ett ank test - testar ankor ankor anka naka naka ojojojjoj vad många ankor detta blev oj oj\" --host desktop";
            }
          ];  
        };
            
        # 🦆 says ⮞ Monero USD price ticker
        xmr = {
          enable = true;
          title = "𝑿𝑴𝑹";
          group = "tickers";
          icon = "fab fa-monero";
          color = "#a78bfa";
          theme = "colorful";
          filePath = "/var/lib/zigduck/xmr.json";
          jsonField = "current_price";
          format = "{value}";
          detailsJsonField = "7d_change";
          detailsFormat = "7d: {value}%";
          chart = true;
        };

        # 🦆 says ⮞ Bitcoin USD price ticker
        btc = {
          enable = true;
          title = "𝑩𝑻𝑪";
          group = "tickers";
          icon = "fab fa-bitcoin";
          color = "#ff6600";
          filePath = "/var/lib/zigduck/btc.json";
          jsonField = "current_price";
          format = "{value}";
          detailsJsonField = "7d_change";
          detailsFormat = "7d: {value}%";
          chart = true;
          historyField = "history";
        };

        # 🦆 says ⮞ kWh/price chart card
        energyPrice = {
          enable = true;
          title = "𝑷𝑹𝑰𝑪𝑬";
          group = "energy";
          icon = "fas fa-bolt";
          color = "#ffff00";
          filePath = "/var/lib/zigduck/energy_price.json";          
          jsonField = "current_price";
          format = "{value} SEK/kWh";          
          chart = true;
          historyField = "history";
        };

        # 🦆 says ⮞ energy usage card
        energyUsage = {
          enable = true;
          title = "USAGE";
          group = "energy";
          icon = "fas fa-bolt";
          color = "#ffff00";
          filePath = "/var/lib/zigduck/energy_usage.json";          
          jsonField = "monthly_usage";
          format = "{value} kWh";
          chart = true;
          historyField = "history";
        };  

        # 🦆 says ⮞ show indoor temperature
        temperature = {
          enable = true;
          title = "TEMPERATURE C";
          group = "sensors";
          icon = "fas fa-thermometer-half";
          color = "#e74c3c";
          theme = "glass";
          filePath = "/var/lib/zigduck/temperature.json";          
          jsonField = "temperature";
          format = "{value} °C";
          detailsFormat = "Temperature in Hallway";
          chart = true;
          historyField = "history";
        };                   
      };

      # 🦆 says ⮞ DASHBOARD PAGES (extra tabs)      
      pages = {    
        # 🦆 says ⮞ (TV) remote page 
        "3" = {
          icon = "fas fa-television";
          title = "remote";
          # 🦆 says ⮞ symlink epg to webserver
          files = { tv = "/var/lib/zigduck/tv"; };
          css = css.tv;
          code = pages.remote;
        };  
      
        # 🦆 says ⮞ system-wide health monitoring page
        "4" = {
          icon = "fas fa-notes-medical";
          title = "health";
          # 🦆 says ⮞ symlink directory to webserver
          files = { health = "/var/lib/zigduck/health"; };
          css = css.health;
          code = pages.health;
        };
        
        # 🦆says⮞ ChatBot (no LLM) - Less thinkin', more doin'!
        "5" = {
          icon = "fas fa-comments";
          title = "chat";
          css = css.chat;
          # 🦆 says ⮞ symlink TTS audio to frontend webserver
          files = { tts = "/var/lib/zigduck/tts"; };
          code = pages.chat;
        };
      
      };
    };
  
# 🦆 ⮞ ZIGBEE ⮜ 🐝
    zigbee = {      
      # 🦆 says ⮞ encrypted zigbee network key
      networkKeyFile = config.sops.secrets.z2m_network_key.path;
      
      # 🦆 says ⮞ mosquitto authentication
      mosquitto = {
        host = "192.168.1.211";
        username = "mqtt";
        passwordFile = config.sops.secrets.mosquitto.path;
      };
      
      # 🦆 says ⮞ TV light syncin' 
      hueSyncBox = { 
        enable = true;
        # 🦆 says ⮞ sadly needed (i disable itz internet access - u should too)
        bridge = { 
          ip = "192.168.1.33";
          # 🦆 says ⮞ run the following to get api token:
          # curl -X POST http://192.168.1.33/api -d '{"devicetype":"house#nixos"}'
          passwordFile = config.sops.secrets.hueBridgeAPI.path;
        }; 
        syncBox = { # C42996020AAE
          ip = "192.168.1.34";
          passwordFile = config.sops.secrets.hueBridgeAPI.path;
          tv = "shield";
        };
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
        after = 14;
        before = 9;
        duration = 900;
      };
      
  # 🦆 ⮞ AUTOMATIONS ⮜
      automations = {  
      # 🦆 says ⮞ there are 6 different automation types
        # 🦆 says ⮞ + a greeting automation
        greeting = {
          enable = true;
          awayDuration = 7200;
          delay = 10;
          actions = [
            {
              type = "shell";
              command = ''
                yo say "Borta bra, hemma bäst. Välkommen idiot!"
              '';
            }
          ];
        };
        

        # 🦆 says ⮞ 1. MQTT triggered automations
        mqtt_triggered = {
          # 🦆say⮞ crypto tickers 
          xmr = {
            enable = true;
            description = "Updating XMR price data on dashboard";
            topic = "zigbee2mqtt/crypto/xmr/price";
            actions = [{ type = "shell"; command = Mqtt2jsonHistory "current_price" "xmr.json"; }];
          };            
          btc = {
            enable = true;
            description = "Updating BTC price data on dashboard";
            topic = "zigbee2mqtt/crypto/btc/price";
            actions = [{ type = "shell"; command = Mqtt2jsonHistory "current_price" "btc.json"; }];
          };
          # 🦆say⮞ energy tracking 
          energyPrice = {
            enable = true;
            description = "Updating energy data on dashboard";
            topic = "zigbee2mqtt/tibber/energy";
            actions = [{ type = "shell"; command = Mqtt2jsonHistory "current_price" "energy_price.json"; }];
          };
          energyUsage = {
            enable = true;
            description = "Updating energy data on dashboard";
            topic = "zigbee2mqtt/tibber/energy";
            actions = [{ type = "shell"; command = Mqtt2jsonHistory "monthly_usage" "energy_usage.json"; }];
          };   
          # 🦆say⮞ hallway temperature  
          temperature = {
            enable = true;
            description = "Updating temperature data on dashboard";
            topic = "zigbee2mqtt/Motion Sensor Hall";
            actions = [{ type = "shell"; command = Mqtt2jsonHistory "temperature" "temperature.json"; }];
          };
          # 🦆say⮞ calendar 
          calendar = {
            enable = true;
            description = "Updated calendar events";
            topic = "zigbee2mqtt/calendar";
            actions = [
              {
                type = "shell";
                command = ''
                  iso_date=$(echo "$MQTT_PAYLOAD" | jq -r '.today_date')
                  formatted_date=$(date -d "$iso_date" +"%b %d")
                  MQTT_PAYLOAD=$(echo "$MQTT_PAYLOAD" | jq --arg d "$formatted_date" '.today_date = $d')
                  echo "$MQTT_PAYLOAD" > /var/lib/zigduck/calendar.json
                '';
              }
            ];
          };
          

          # 🦆say⮞ tv control 
          tv_command = {
            enable = true;
            description = "TV command sent";
            topic = "zigbee2mqtt/tvCommand";
            actions = [
              {
                type = "shell";
                command = ''
                  tv_command=$(echo "$MQTT_PAYLOAD" | jq -r '.tvCommand')
                  ip=$(echo "$MQTT_PAYLOAD" | jq -r '.ip // "192.168.1.223"')
                  yo tv --typ "$tv_command" --device "$ip"
                  echo "TV command received! Command: $tv_command. IP: $ip"
                '';
              }
            ];
          };
          tv_channel_change = {
            enable = true;
            description = "Change TV channel via yo command";
            topic = "zigbee2mqtt/tvChannelCommand";
            actions = [
              {
                type = "shell";
                command = ''
                  channel=$(echo "$MQTT_PAYLOAD" | jq -r '.tvChannel')
                  ip=$(echo "$MQTT_PAYLOAD" | jq -r '.ip // "192.168.1.223"')
                  yo tv --typ livetv --device "$ip" --search "$channel"
                '';
              }
            ];
          }; # 🦆says⮞health checks (from let block)
        } // health; 
        

        # 🦆 says ⮞ 2. room action automations
        room_actions = {
          hallway = { 
            door_opened = [];
            door_closed = [];
          };
          

          kitchen = { 
            motion_not_detected = [
              {
                type = "shell";
                command = ''
                  power=$(jq -r '."Fläkt".power' /var/lib/zigduck/state.json)
                  # 🦆 says ⮞ no need 2 turn off if it'z not on
                  if (( power > 20 )); then
                    yo mqtt_pub --topic "zigbee2mqtt/Fläkt/set" --message '{"countdown": 120}'
                  fi
                '';
              }
              { # 🦆 says ⮞  slow go light go bye bye
                type = "scene";
                scene = "kitchenFadeOff";
              }
            ];  

            motion_detected = [
              {
                type = "shell";
                command = ''
                  STATE=$(jq -r '."Fläkt".state' /var/lib/zigduck/state.json)
                  if [ "$STATE" = "OFF" ]; then               
                    nqtt --device "Fläkt" --state on
                  fi
                '';
              }
              { # 🦆 SCREAM ⮞ INSTANT LIGHT QWACK
                type = "scene";
                scene = "kitchenInstant";
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
            off_hold_release = {
              enable = true;
              description = "Turn off all configured light devices";
              extra_actions = [];
              override_actions = [
                {
                  type = "scene";
                  scene = "dark";
                }
                {
                  type = "mqtt";
                  topic = "zigbee2mqtt/Fläkt/set";
                  message = ''{"state":"OFF"}'';
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
        "0xa4c138b9aab1cf3f" = { friendly_name = "Fläkt"; room = "kitchen"; type = "outlet"; icon = icons.outlet; endpoint = 1; };
        # 🦆 says ⮞ LIVING ROOM
        "0x0c4314fffe179b05" = { friendly_name = "Larm"; room = "livingroom"; type = "outlet"; icon = icons.outlet; endpoint = 1; };    
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
        "0x00178801001ecdaa" = { friendly_name = "Bloom"; room = "bedroom"; type = "light"; icon = "./themes/icons/zigbee/bloom.png"; endpoint = 11; supports_color = true; };
        # 🦆 says ⮞ MISCELLANEOUS
        "0xa4c1382543627626" = { friendly_name = "Power Plug"; room = "other"; type = "outlet"; icon = icons.outlet; endpoint = 1; };
        "0x000b57fffe0f0807" = { friendly_name = "IKEA 5 Dimmer"; room = "other"; type = "remote"; icon = icons.remote; endpoint = 1; };
        "0x70ac08fffe6497be" = { friendly_name = "On/Off Switch 1"; room = "other"; type = "remote"; icon = icons.remote; endpoint = 1; batteryType = "CR2032"; };
        "0x70ac08fffe65211e" = { friendly_name = "On/Off Switch 2"; room = "other"; type = "remote"; icon = icons.remote; endpoint = 1; batteryType = "CR2032"; };

        # 🦆 says ⮞ TV-AREA (entertainment area)
        "00178801095f06300b" = { friendly_name = "TV Play Strip"; room = "tv-area"; type = "hue_light"; icon = icons.light.strip; endpoint = 1; supports_color = true; hue_id = 38; };
        "0017880106ff30720b" = { friendly_name = "TV Play 1"; room = "tv-area"; type = "hue_light"; icon = icons.light.ambient; endpoint = 1; supports_color = true; hue_id = 40; };
        "0017880109f06a700b" = { friendly_name = "TV Play 2"; room = "tv-area"; type = "hue_light"; icon = icons.light.ambient; endpoint = 1; supports_color = true; hue_id = 41; };
        "0017880109f06a7c0b" = { friendly_name = "TV Play 3"; room = "tv-area"; type = "hue_light"; icon = icons.light.ambient; endpoint = 1; supports_color = true; hue_id = 37; };
        "0017880106ff22530b" = { friendly_name = "TV Play 4"; room = "tv-area"; type = "hue_light"; icon = icons.light.ambient; endpoint = 1; supports_color = true; hue_id = 39; };
        "001788010985d1820b" = { friendly_name = "Play Top L"; room = "tv-area"; type = "hue_light"; icon = icons.light.ambient; endpoint = 1; supports_color = true; hue_id = 61; };                        
        "00178801098d5b320b" = { friendly_name = "Play Top R"; room = "tv-area"; type = "hue_light"; icon = icons.light.ambient; endpoint = 1; supports_color = true; hue_id = 60; };     
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
              "Takkrona 1" = { state = "ON"; brightness = 200; color = { hex = "#7FFFD4"; }; };       # 🦆 says ⮞ Aquamarine   
              "Takkrona 2" = { state = "ON"; brightness = 200; color = { hex = "#7FFFD4"; }; };       # 🦆 says ⮞ Aquamarine   
              "Takkrona 3" = { state = "ON"; brightness = 200; color = { hex = "#7FFFD4"; }; };       # 🦆 says ⮞ Aquamarine   
              "Takkrona 4" = { state = "ON"; brightness = 200; color = { hex = "#7FFFD4"; }; };       # 🦆 says ⮞ Aquamarine   
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

          "kitchenInstant" = {
              "Golvet" = { state = "ON"; brightness = 254; color = { hex = "#FFFFFF"; }; };
              "Kök Bänk Slinga" = { state = "ON"; brightness = 254; color = { hex = "#FFFFFF"; }; };
              "Spotlight Kök 2" = { state = "ON"; brightness = 254; color = { hex = "#FFFFFF"; }; };
              "Spotlight kök 1" = { state = "ON"; brightness = 254; color = { hex = "#FFFFFF"; }; };
              "Uppe" = { state = "ON"; brightness = 254; color = { hex = "#FFFFFF"; }; }; 
          };
          # 🦆 says ⮞ veeeery slow turn off
          "kitchenFadeOff" = {
              "Golvet" = { state = "OFF"; transition = 1000; };
              "Kök Bänk Slinga" = { state = "OFF"; transition = 1000; };
              "PC" = { state = "OFF"; transition = 1000; };
              "Spotlight Kök 2" = { state = "OFF"; transition = 1000; };
              "Spotlight kök 1" = { state = "OFF"; transition = 1000; };
              "Uppe" = { state = "OFF"; transition = 1000; };
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
              "TV Play Strip" = { state = "OFF"; transition = 150; };
              "TV Play 1" = { state = "OFF"; transition = 150; };
              "TV Play 2" = { state = "OFF"; transition = 150; };
              "TV Play 3" = { state = "OFF"; transition = 150; };
              "TV Play 4" = { state = "OFF"; transition = 150; };
              "Play Top L" = { state = "OFF"; transition = 150; };
              "Play Top R" = { state = "OFF"; transition = 150; };
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
              "TV Play Strip" = { state = "OFF"; };
              "TV Play 1" = { state = "OFF"; };
              "TV Play 2" = { state = "OFF"; };
              "TV Play 3" = { state = "OFF"; };
              "TV Play 4" = { state = "OFF"; };
              "Play Top L" = { state = "OFF"; };
              "Play Top R" = { state = "OFF"; };
          };
          "max" = { # 🦆 says ⮞ let there be light
              "Bloom" = { state = "ON"; brightness = 254; color = { hex = "#FFFFFF"; }; };
              "Dörr" = { state = "ON"; brightness = 254; color = { hex = "#FFFFFF"; }; };
              "Golvet" = { state = "ON"; brightness = 254; color = { hex = "#FFFFFF"; }; };
              "Kök Bänk Slinga" = { state = "ON"; brightness = 254; color = { hex = "#FFFFFF"; }; };
              "PC" = { state = "ON"; brightness = 254; color = { hex = "#FFFFFF"; }; };
              "Rustning" = { state = "ON"; brightness = 254; color = { hex = "#FFFFFF"; }; };
              "Spotlight Kök 2" = { state = "ON"; brightness = 254; color = { hex = "#FFFFFF"; }; };
              "Spotlight kök 1" = { state = "ON"; brightness = 254; color = { hex = "#FFFFFF"; }; };
              "Sänggavel" = { state = "ON"; brightness = 254; color = { hex = "#FFFFFF"; }; };
              "Sänglampa" = { state = "ON"; brightness = 254; color = { hex = "#FFFFFF"; }; };
              "Tak Hall" = { state = "ON"; brightness = 254; color = { hex = "#FFFFFF"; }; };
              "Taket Sovrum 1" = { state = "ON"; brightness = 254; color = { hex = "#FFFFFF"; }; };
              "Taket Sovrum 2" = { state = "ON"; brightness = 254; color = { hex = "#FFFFFF"; }; };
              "Uppe" = { state = "ON"; brightness = 254; color = { hex = "#FFFFFF"; }; };
              "Vägg" = { state = "ON"; brightness = 1; };
              "WC 1" = { state = "ON"; brightness = 254; color = { hex = "#FFFFFF"; }; };
              "WC 2" = { state = "ON"; brightness = 254; color = { hex = "#FFFFFF"; }; };
              "Takkrona 1" = { state = "ON"; brightness = 254; color = { hex = "#FFFFFF"; }; };   
              "Takkrona 2" = { state = "ON"; brightness = 254; color = { hex = "#FFFFFF"; }; };
              "Takkrona 3" = { state = "ON"; brightness = 254; color = { hex = "#FFFFFF"; }; };   
              "Takkrona 4" = { state = "ON"; brightness = 254; color = { hex = "#FFFFFF"; }; };
              "TV Play Strip" = { state = "ON"; brightness = 254; color = { xy = [ 0.3127 0.3290 ]; }; };
              "TV Play 1" = { state = "ON"; brightness = 254; color = { xy = [ 0.3127 0.3290 ]; }; };
              "TV Play 2" = { state = "ON"; brightness = 254; color = { xy = [ 0.3127 0.3290 ]; }; };
              "TV Play 3" = { state = "ON"; brightness = 254; color = { xy = [ 0.3127 0.3290 ]; }; };
              "TV Play 4" = { state = "ON"; brightness = 254; color = { xy = [ 0.3127 0.3290 ]; }; };
              "Play Top L" = { state = "ON"; brightness = 254; color = { xy = [ 0.3127 0.3290 ]; }; };
              "Play Top R" = { state = "ON"; brightness = 254; color = { xy = [ 0.3127 0.3290 ]; }; };
          };     
          "tv-area1" = {
              "TV Play Strip" = { state = "ON"; brightness = 254; hue = 49460; sat = 242; color = { xy = [ 0.6321 0.2678 ]; }; transition = 150; };
              "TV Play 1"     = { state = "ON"; brightness = 254; hue = 49460; sat = 242; color = { xy = [ 0.1491 0.3012 ]; }; transition = 150; };
              "TV Play 2"     = { state = "ON"; brightness = 254; hue = 49460; sat = 242; color = { xy = [ 0.2654 0.6680 ]; }; transition = 150; };
              "TV Play 3"     = { state = "ON"; brightness = 254; hue = 49460; sat = 242; color = { xy = [ 0.4995 0.4697 ]; }; transition = 150; };
              "TV Play 4"     = { state = "ON"; brightness = 254; hue = 49460; sat = 242; color = { xy = [ 0.2293 0.0945 ]; }; transition = 150; };
              "Play Top L"    = { state = "ON"; brightness = 254; hue = 49460; sat = 242; color = { xy = [ 0.6187 0.3687 ]; }; transition = 150; };
              "Play Top R"    = { state = "ON"; brightness = 254; hue = 49460; sat = 242; color = { xy = [ 0.1611 0.5294 ]; }; transition = 150; };
          };
          "tv-area2" = {
              "TV Play Strip" = { state = "ON"; brightness = 254; hue = 56100; sat = 250; color = { xy = [ 0.3824 0.1600 ]; }; transition = 150; };
              "TV Play 1"     = { state = "ON"; brightness = 240; hue = 56100; sat = 250; color = { xy = [ 0.1682 0.0410 ]; }; transition = 150; };
              "TV Play 2"     = { state = "ON"; brightness = 240; hue = 56100; sat = 250; color = { xy = [ 0.1532 0.0475 ]; }; transition = 150; };
              "TV Play 3"     = { state = "ON"; brightness = 240; hue = 56100; sat = 250; color = { xy = [ 0.2746 0.1320 ]; }; transition = 150; };
              "TV Play 4"     = { state = "ON"; brightness = 240; hue = 56100; sat = 250; color = { xy = [ 0.4088 0.5170 ]; }; transition = 150; };
              "Play Top L"    = { state = "ON"; brightness = 254; hue = 56100; sat = 250; color = { xy = [ 0.2255 0.3299 ]; }; transition = 150; };
              "Play Top R"    = { state = "ON"; brightness = 254; hue = 56100; sat = 250; color = { xy = [ 0.1670 0.3520 ]; }; transition = 150; };
          };
          "tv-area3" = {
              "TV Play Strip" = { state = "ON"; brightness = 254; hue = 12750; sat = 200; color = { xy = [ 0.5128 0.4147 ]; }; transition = 150; };
              "TV Play 1"     = { state = "ON"; brightness = 230; hue = 12750; sat = 200; color = { xy = [ 0.5752 0.3850 ]; }; transition = 150; };
              "TV Play 2"     = { state = "ON"; brightness = 230; hue = 12750; sat = 200; color = { xy = [ 0.4597 0.4106 ]; }; transition = 150; };
              "TV Play 3"     = { state = "ON"; brightness = 230; hue = 12750; sat = 200; color = { xy = [ 0.3690 0.3576 ]; }; transition = 150; };
              "TV Play 4"     = { state = "ON"; brightness = 230; hue = 12750; sat = 200; color = { xy = [ 0.5016 0.4400 ]; }; transition = 150; };
              "Play Top L"    = { state = "ON"; brightness = 254; hue = 12750; sat = 200; color = { xy = [ 0.4448 0.4066 ]; }; transition = 150; };
              "Play Top R"    = { state = "ON"; brightness = 254; hue = 12750; sat = 200; color = { xy = [ 0.4020 0.3810 ]; }; transition = 150; };
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
      bedroom = {
        enable = true;
        room = "bedroom";
        ip = "192.168.1.153";
        apps = config.house.tv.shield.apps;
        channels = config.house.tv.shield.channels;
      };      
      
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
      hueBridgeAPI = {
        sopsFile = ./../secrets/hueBridgeAPI.yaml;
        owner = config.this.user.me.name;
        group = config.this.user.me.name;
        mode = "0440"; # Read-only for owner and group
      };
      mosquitto = { # 🦆 says ⮞ quack, stupid!
        sopsFile = ./../secrets/mosquitto.yaml; 
        owner = config.this.user.me.name;
        group = config.this.user.me.name;
        mode = "0444"; # 🦆 says ⮞ Read-only for owner and group
      }; # 🦆 says ⮞ Z2MQTT encryption key - if changed needs re-pairing devices
      z2m_network_key = { 
        sopsFile = ./../secrets/z2m_network_key.yaml; 
        owner = "zigbee2mqtt";
        group = "zigbee2mqtt";
        mode = "0440"; # 🦆 says ⮞ Read-only for owner and group
      };
      z2m_mosquitto = { 
        sopsFile = ./../secrets/z2m_mosquitto.yaml; 
        owner = "zigbee2mqtt";
        group = "zigbee2mqtt";
        mode = "0440"; # 🦆 says ⮞ Read-only for owner and group
      };
    };
    
  };}
