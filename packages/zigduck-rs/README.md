# **zigduck-rs**

**zigduck-rs** takes care of house, home and heart. *(lights, automations, dimmers, etc ..)*  
High performance Rust home automation system that uses your Nix defined devices and automations to control your smart home.   

  
  
## **Package includes two binaries:**
  
1. `zigduck-rs` - The server-side automation service.

2. `zigduck-cli` - The client-side CLI controller.

  
## **NixOS modules**

  
[Use the house.nix module](https://github.com/QuackHack-McBlindy/dotfiles/tree/main/modules/house.nix)

The strength of this modules configuration is that your doing it correct the first time, no nix-store exposed secrets and fully declarative - configure once, and never again.  
Your secrets and zigbee network key is safe outside the nix store.  

**Minimal configuration:**

```nix
  house = {  
    rooms = {
      livingroom.icon = "mdi:sofa";
      # ...
    };
    
    zigbee = {
      enable = true;         
      # 🦆 says ⮞ encrypted zigbee network key
      networkKeyFile = config.sops.secrets.z2m_network_key.path;     
      
      # 🦆 says ⮞ mosquitto authentication
      mosquitto = {
        host = "192.168.1.211";
        username = "mqtt";
        passwordFile = config.sops.secrets.mosquitto.path;
      };
      
      # 🦆says⮞ coordinator configuration
      coordinator = {
        vendorId =  "10c4";
        productId = "ea60";
        symlink = "zigbee"; # 🦆 says ⮞ diz symlinkz da serial port to /dev/zigbee
      };
      
      # Add your devices by it's IEEE
      devices = { 
        "0x0017880103ca6e95" = { # 🦆 says ⮞ 64bit IEEE adress (this is the unique device ID)  
          friendly_name = "Dimmer Switch Livingroom";
          room = "livingroom";
          type = "dimmer";
          icon = "mdi:toggle-switch";
          endpoint = 1; # 🦆 says ⮞ endpoint to call the device on
          batteryType = "CR2450"; # 🦆 says ⮞ optional
        };
        "0x0017880103c73f85" = { 
          friendly_name = "Cealing light 1";
          room = "livingroom";
          type = "light";
          icon = "mdi:chandelier";
          endpoint = 1;
          supports_color = true;
        };
      };
      
      # Create your scenes:
      scenes = {
        # 🦆 says ⮞ Scene name
        "Duck Scene" = {
          # 🦆 says ⮞ Device friendly_name
          "PC" = { # 🦆 says ⮞ Device state
            state = "ON";
            brightness = 200;
            color = { hex = "#00FF00"; };
          };
          # ...
        };
      };
    };
    
```

Automations/dimmer switch programming is optional as `Zigduck-rs` handle sensible defaults out of the box.  

**But hey!** We're here because we like automations - **right?!**  

  

<details><summary><strong>
Detailed: Writing Automations 
</strong></summary>


You can have a lot of fun here for sure.  
Let the qwackin' begin!

## Action Types Supported

All automations can execute actions.  
There are **four** different types of actions that can be executed.  

**1. Shell Commands**

```nix
{
  type = "shell";
  command = "echo 'Hello World'";
}
```

**2. MQTT Messages**

```nix
{
  type = "mqtt";
  topic = "zigbee2mqtt/device/set";
  message = ''{"state":"ON"}'';
}
```

**3. Scene Activation**

```nix
{
  type = "scene"; 
  scene = "movie_time";
}
```

**4. Simple String (legacy)**

```nix
"echo 'Hello Ducks'"
```

## Dark Time

It might be one of the most important automation. Short and boring - but important.  
Define when motion sensors should trigger lights, and for how long they should be turned on.

```nix
{ 
  config,
  lib,
  pkgs,
  ...
} : let
in {
  house = {
    darkTime = {
      enable = true;
      after = "14";
      before = "9";
      duration = "900";
    };  
  };
}
```

## Greeting

When no motion has been detected in your house for x seconds - welcome you home with a greeting!

```nix
{ 
  config,
  lib,
  pkgs,
  ...
} : let
in {
  house = {
    zigbee = {
      automations = {
        greeting = {
          enable = true;
          awayDuration = "7200";
          greeting = "Welcome back! Starting the party!";
          sayOnHost = "desktop";
          delay = "5";
          action = {
            type = "shell";
            command = ''
              ...
            '';
          };
        };   
      };
    };
  };
}
```

## Automation Types

There are currently **six** different automation types:

### Dimmer Action Automations

Configure your dimmers.  
This is optional, as they have default action's pre-configured in zigduck-rs (next page).  

**Default actions are:**  
- **on_press_release:** Turn on all zigbee devices with type 'light' in the dimmers room at last known state.  
- **on_hold_release:** Turn on all zigbee devices with type 'light' at maximum brightness.  
- **up_press_release:** Increase brightness of all zigbee devices with type 'light' in dimmers room.  
- **up_hold_release:** None.  
- **down_press_release:** Decrease brightness of all zigbee devices with type 'light' in dimmers room.  
- **down_hold_release:** None.  
- **off_press_release:** Turn off all zigbee devices with type 'light' in dimmer's room.  
- **off_hold_release:** Turn off all zigbee devices with type 'light'.

This is an example snippet of how a dimmer override automation may look:

```nix
{
  config,
  lib,
  pkgs,
  ...
} : let
in {
  house = {
    zigbee = {
      automations = {
        dimmer_actions = {
          livingroom = {
            off_hold_release = { 
              enable = true;
              description = "Description of automation";
              extra_actions = [];
              override_actions = [
                {
                  type = "mqtt";
                  topic = "zigbee2mqtt/Fläkt/set";
                  message = ''{"state":"OFF"}'';
                }
                {
                  type = "scene";
                  scene = "dark";
                }
              ];
            }; 
          };  
        };    
      };
    };
  };
}
```

### Global Action Automations

**Supported Global Action Triggers:**  
- **"leak_detected"** - When water sensors detect leaks.  
- **"smoke_detected"** - When smoke detectors trigger.  

If you have smoke detectors or water sensors, this is a very important example:

```nix
{
  config,
  lib,
  pkgs,
  ...
} : let
in {
  house = {
    zigbee = {
      automations = {
        global_actions = {
          leak_detected = [
            {
              type = "shell";
              command = "${config.pkgs.yo}/bin/yo-notify '🚨 WATER LEAK DETECTED!'";
            }
            {
              type = "mqtt";
              topic = "zigbee2mqtt/all_valves/set";
              message = ''{"state":"OFF"}'';
            }
            "echo 'EMERGENCY: Water leak!' | wall"
          ];
  
          smoke_detected = [
            {
              type = "shell"; 
              command = "${pkgs.paplay}/bin/paplay ${config.this.user.me.dotfilesDir}/modules/themes/sounds/fire-alarm.wav";
            }
            {
              type = "mqtt";
              topic = "zigbee2mqtt/all_lights/set";
              message = ''{"state":"ON", "brightness": 255, "color": {"hex": "FF0000"}}'';
            }
            "curl -X POST http://localhost:8080/emergency/fire"
          ];
        };
      };
    };
  };
}
```

### Room Action Automations

**Supported Room Action Triggers:**  
- **"motion_detected"** - When motion sensors detect movement.  
  Default Action: Turn on all light devices in the motion sensors room. *(if darkTime)*  
- **"motion_not_detected"** - When motion stops being detected.  
  Default Action: Turn off all light devices in the motion sensors room. *(after time configured in darkTime)*  
- **"door_opened"** - When door/window sensors open.  
- **"door_closed"** - When door/window sensors close.  

Take a look at an example snippet of how a room action automation may look:

```nix
{
  config,
  lib,
  pkgs,
  ...
} : let
in {
  house = {
    zigbee = {
      automations = {
        room_actions = {
          hallway = {
            door_opened = [];
            door_closed = [];
          };  
          bedroom = {
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
      };
    };
  };
}
```

### MQTT Triggered Automations

Triggers the automation when a specified Mosquitto topic (and optionally message) is received and processed.  
This enables the user to automate, well - basically anything.  

**Supported MQTT triggered Conditions:**  
- **"dark_time"** - Checks: If current time is within configured dark time range.  

```nix
{ type = "dark_time"; }
```

Here is an example snippet of how the mqtt triggered automation may look:

```nix
{
  config,
  lib,
  pkgs,
  ...
} : let
in {
  house = {
    zigbee = {
      automations = {
        mqtt_triggered = {
          dashboard_command = {
            enable = true;
            description = "Handle custom commands from web dashboard";
            topic = "house/command";
            message = null;
            actions = [
              {
                type = "shell";
                command = ''
                  echo "Topic: $MQTT_TOPIC"
                  echo "Device: $MQTT_DEVICE"
                  echo "Room: $MQTT_ROOM"
                  echo "Payload: $MQTT_PAYLOAD"
                  echo "Action: $MQTT_ACTION"
                  echo "State: $MQTT_STATE"
                '';
              }
            ];
          };
        };
      };
    };
  };
}  
```

### Time Based Action Automations

Triggers the automation on a specified time and days.  

**Supported Time Based Conditions:**  
- **"dark_time"** - Checks: If current time is within configured dark time range.  

```nix
{ type = "dark_time"; }
```

Here is an example snippet of how the time based automation may look:

```nix
{
  config,
  lib,
  pkgs,
  ...
} : let
in {
  house = {
    zigbee = {
      automations = {
        time_based = {
          smart_wakeup = {
            enable = true;
            description = "Gradual wake-up with news and coffee";
            schedule = {
              start = "06:30";
              end = "07:00";
              days = ["mon" "tue" "wed" "thu" "fri"];
            };
            conditions = [
              { type = "someone_home"; value = true; }
            ];
            actions = [
              {
                type = "scene";
                scene = "sunrise_simulation";
              }
              {
                type = "shell";
                command = "${pkgs.mpg123}/bin/mpg123 ${config.this.user.me.dotfilesDir}/modules/themes/sounds/alarm.mp3";
              }
              {
                type = "mqtt";
                topic = "zigbee2mqtt/CoffeeMaker/set";
                message = ''{"state":"ON", "time": 300}'';
              }
              {
                type = "shell";
                command = "${config.pkgs.yo}/bin/yo-say 'Good morning! Time to wake up.'";
              }
            ];
          };
        };
      };
    };  
  };
}
```

### Presence Based Action Automations

**Supported Presence Based Conditions:**  
- **"someone_home"** - Checks: If someone is home.  

```nix
{ 
  type = "someone_home"; 
  value = true;
}
```

- **"room_occupied"** - Checks: If a specific room is occupied.  

```nix
{
  type = "room_occupied";
  room = "livingroom";
  value = true;
}
```

Here is an example snippet of how the presence based automations may look:

```nix
{
  config,
  lib,
  pkgs,
  ...
} : let
in {
  house = {
    zigbee = {
      automations = {
        presence_based = {
          arrival_party = {
            enable = true;
            description = "Fun lighting when arriving home";
            motion_sensors = ["Front Door Motion"];
            no_motion_duration = 30;
            conditions = [
              { type = "dark_time"; }
            ];
            actions = [
              {
                type = "scene"; 
                scene = "welcome_home";
              }
              {
                type = "mqtt";
                topic = "zigbee2mqtt/DiscoBall/set";
                message = ''{"state":"ON", "speed": 200}'';
              }
            ];
          };
        };
      };  
    };
  };
}
```

> **Important Notes:**  
> - Room names must match your house.rooms configuration.  
> - Device names must match exactly what's in house.zigbee.devices  
> - Global actions fire regardless of room context.  
> - Room actions only fire for devices in that specific room.  
> - All actions run sequentially when the trigger condition is met.

I hope you do see the full potential of this powerful automation system.  
I realize it's a lot to take in at once, but hopefully I made it pretty clear of how it all works.  
The examples are very basic, and that is how I recommend you start out if you are aiming to test this out.  
Extending the configurations into complex automations is so simple it needs no instructions.

</details>

<br><br>
  
[My full configuration](https://github.com/QuackHack-McBlindy/dotfiles/tree/main/modules/myHouse.nix)
  


## **zigduck-cli**

  
High‑performance client for controlling Zigbee and Hue devices, scenes, and automations from the command line.    


**Options:**


```bash
--broker (default: 127.0.0.1) [$MQTT_BROKER]
--user (default: mqtt ) [$MQTT_USER]
--password-file [$MQTT_PASSWORD_FILE]
--password [$MQTT_PASSWORD]
--devices-config [$DEVICES_CONFIG]
--scenes-config [$SCENES_CONFIG]
--hue-bridge-ip [$HUE_BRIDGE_IP]
--hue-api-key [$HUE_API_KEY]

--device
--state
--brightness
--color
--temperature
--room
--scene
--list
--pair
--help
```


