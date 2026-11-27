# **zigduck**

[![Sponsors](https://img.shields.io/github/sponsors/QuackHack-McBlindy?logo=githubsponsors&label=Sponsor&style=flat&labelColor=ff1493&logoColor=fff&color=rgba(234,74,170,0.5) "")](https://github.com/sponsors/QuackHack-McBlindy) [![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-Sponsor?style=flat&logo=buymeacoffee&logoColor=fff&labelColor=ff1493&color=ff1493)](https://buymeacoffee.com/quackhackmcblindy)

<br>

<div align="center">
  <a href="https://quackhack-mcblindy.github.io/zigduck">
    <img src="https://raw.githubusercontent.com/QuackHack-McBlindy/zigduck/refs/heads/main/images/logo.png" alt="Logo" width="440">
  </a>

  <br>

  <a href="https://quackhack-mcblindy.github.io/zigduck">
    <img src="https://raw.githubusercontent.com/QuackHack-McBlindy/zigduck/refs/heads/main/images/automations.png" alt="automations" width="800">
  </a>



<!-- VERSIONS_START -->

  ![License](https://img.shields.io/badge/license-MIT-black?style=flat-square&logo=opensourceinitiative&logoColor=white)
  ![zigduck](https://img.shields.io/badge/🦆%20zigduck-0.2.16-black?style=flat)

  ![Build](https://github.com/QuackHack-McBlindy/zigduck/actions/workflows/ci.yml/badge.svg)
  ![Docs](https://github.com/QuackHack-McBlindy/zigduck/actions/workflows/wiki.yml/badge.svg)

  ![Mosquitto](https://img.shields.io/badge/Mosquitto-2.1.2-yellow?style=flat-square&logo=eclipsemosquitto&logoColor=white)
  ![Zigbee2MQTT](https://img.shields.io/badge/Zigbee2MQTT-2.14.3-yellow?style=flat-square&logo=zigbee2mqtt&logoColor=white)
  ![ADB](https://img.shields.io/badge/ADB-1.0.41-green?style=flat-square&logo=android&logoColor=white)
  ![yo](https://img.shields.io/badge/💬%20yo-0.2.15-black?style=flat)

<!-- VERSIONS_END -->



  <br>
  <a href="https://quackhack-mcblindy.github.io/zigduck/">🦆 Zigduck Wiki</a>.
  <br>


  # **A Flake For Your House**

</div>

A declarative, reproducible smart-home operating system (NixOS) for people who want their home automation to be as maintainable as their infrastructure.
Zigduck home automation system brings reproducibility, version control, and natural-language control to your deployable smart home.<br>

Nix for configuration, Rust for **blazing fast** responsive async runtime.<br>
Under the hood: zigbee2mqtt, Mosquitto, tokio/serde_json, adb and yo.<br>

**Define once, deploy forever.**

<br>

## **🦆🪾 Detailed project tree view**

<details><summary><strong>
--> View project tree (with info)
</strong></summary>


```markdown
zigduck/
├── flake.nix         
├── README.md
├── CHANGELOG.md
├── CONTRIBUTING.md              # guidelines / templates for contributions
│    

├── .github/  
│   └── workflows/  
│       ├── ci.nix               # release ci / tests
│       └── wiki.nix             # docs workflow 
│   
│    𝑴𝑶𝑫𝑼𝑳𝑬𝑺
├── modules/            # NixOS modules - what services run
│   ├── zigduck.nix              # Main daemon
│   ├── dashboard.nix            # Web dashboard / API
│   ├── tv.nix                   # TV control
│   ├── cards.nix                # Dashboard cards
│   │
│   ├── grammar/        # Natural-language grammar
│   │   ├── lib.nix              #   Grammar library
│   │   ├── en/         #   English
│   │   │   └── words.nix        #     english common words / numbers
│   │   │
│   │   └── sv/         #   Swedish
│   │       ├── words.nix        #      swedish common words / numbers
│   │       └── automate.nix     #     grammar for automate script.
│   │
│   └── scripts/        # Natural-language automations
│       ├── lib.nix              #   Script helpers
│       │
│       ├── core/       #   Core scripts
│       │   ├── automate.nix     #     `automate` commands
│       │   ├── chain.nix        #     `chain` commands
│       │   ├── if.nix           #     `if` commands
│       │   ├── loop.nix         #     `loop` commands
│       │   ├── while.nix        #     `while` commands
│       │   ├── wait.nix         #     `wait` commands
│       │   └── until.nix        #     `until` commands
│       │
│       ├── media/      #   zigduck-tv & zigduck-epg
│       │
│       ├── misc/                #   Misc voice control commands
│       │   ├── alarms.nix       #   full zigduck cli controller 
│       │   └── timer.nix        #   State queries
│       │
│       └── zigbee/     #   zigduck-cli
│           ├── house.nix        #   full zigduck cli controller 
│           ├── state.nix        #   State queries
│           ├── countdown.nix    #   shutdown counter
│           └── compare.nix      #   compare metrics queries
│
│   𝑶𝑷𝑻𝑰𝑶𝑵𝑺
├── options/            # NixOS options - how it's configured
│   ├── devices.nix
│   ├── rooms.nix
│   ├── presence.nix
│   ├── dashboard.nix
│   ├── tv.nix
│   ├── https.nix
│   └── zigbee/         # Coordinator, automations, scenes, dimmer, …
│
│   𝑷𝑨𝑪𝑲𝑨𝑮𝑬𝑺
├── packages/           # Buildable artifacts
│   │
│   ├── zigduck/        # 🦆 Daemon (Rust) + API/dashboard binary.
│   │   └── src/
│   │       ├── lib.rs                   # Crate root - re-exports all modules
│   │       ├── main.rs                  # bin: zigduck (the daemon, 44 lines)
│   │       ├── zigduck-api.rs           # bin: zigduck-api (HTTP server)
│   │       │
│   │       ├── state.rs                 # ZigduckState - shared application state
│   │       ├── scheduler.rs             # Periodic task tickers
│   │       ├── net.rs                   # Network reachability probes
│   │       │
│   │       ├── domain/ # Pure data types (no logic)
│   │       │   ├── mod.rs
│   │       │   ├── automation.rs        # AutomationAction, Condition, schedules
│   │       │   ├── dashboard.rs         # DashboardConfig, DashboardCardConfig
│   │       │   ├── device.rs            # Device
│   │       │   └── scene.rs             # Scene, SceneConfig
│   │       │
│   │       ├── config/ # Config file parsing (serde)
│   │       │   ├── mod.rs               # HouseConfig (root)
│   │       │   ├── dark_time.rs         # DarkTimeConfig
│   │       │   ├── dimmer.rs            # DimmerConfig, DimmerActions
│   │       │   ├── house_device.rs      # HouseDevice, HouseControl
│   │       │   ├── hue.rs               # HueConfig
│   │       │   ├── mqtt.rs              # MosquittoConfig
│   │       │   ├── no_motion.rs         # NoMotionConfig
│   │       │   ├── presence.rs          # PresenceConfig
│   │       │   ├── simple_actions.rs    # SimpleActionsConfig
│   │       │   └── tv.rs                # TvConfig
│   │       │
│   │       ├── automations/ # Automation engine
│   │       │   ├── mod.rs               # away_duration helper
│   │       │   ├── action.rs            # execute_automation_action*, run_simple_action
│   │       │   ├── condition.rs         # check_conditions, is_dark_time, time/presence
│   │       │   ├── presence.rs          # execute_presence_action, presence shell
│   │       │   └── trigger.rs           # execute_automations, MQTT triggers
│   │       │
│   │       ├── mqtt/        # MQTT transport
│   │       │   ├── mod.rs               # mqtt_publish
│   │       │   ├── listener.rs          # start_listening (event loop, reconnect)
│   │       │   └── router.rs            # process_message dispatcher, perf stats
│   │       │
│   │       ├── devices/     # Device state & control
│   │       │   ├── mod.rs
│   │       │   ├── command.rs           # handle_device_command (Hue/Z2M routing)
│   │       │   ├── house.rs             # handle_house_device_set, control actions
│   │       │   └── state.rs             # update_device_state*, get_state, refreshers
│   │       │
│   │       ├── presence/    # Presence detection
│   │       │   └── mod.rs               # start_presence_probes, check_presence_transition
│   │       │
│   │       ├── motion/      # Motion tracking
│   │       │   └── mod.rs               # MotionTracker, has_recent_motion_in_room
│   │       │
│   │       ├── lights/      # Light groups & control
│   │       │   └── mod.rs               # room_lights_on/off, control_all_lights
│   │       │
│   │       ├── scenes/      # Scene activation
│   │       │   └── mod.rs               # activate_scene, resolve_scene_name
│   │       │
│   │       ├── snapshots/   # State snapshots
│   │       │   └── mod.rs               # create_snapshot, restore_snapshot
│   │       │
│   │       ├── dimmer/      # Dimmer switch handling
│   │       │   └── mod.rs               # handle_room_dimmer_action, check_double_click
│   │       │
│   │       ├── hue/         # Hue Bridge client
│   │       │   └── mod.rs               # HueClient, convert_to_hue_payload
│   │       │
│   │       └── tv/          # TV state tracking (ADB)
│   │           ├── mod.rs               # TvProbe, check_tv_power
│   │           └── tracker.rs           # start_tv_state_trackers
│   │
│   ├── zigduck-cli/         # 🦆 Command-line controller
│   ├── zigduck-tv/          # 🦆 TV control (ADB)
│   ├── zigduck-epg/         # 🦆 EPG scraper (Python)
│   └── zigduck.nix          # Package aggregator
│
├── static/                  # Web dashboard assets
├── wiki/                    # Documentation site
├── hooks/                   # CI hooks
└── devShells/               # Development shells / grammar testing
``` 

</details>

<br><br>


**zigduck** uses smart defaults, after defining your rooms & devices --<br>
most users don’t need to write any automations at all.<br>
Lights, dimmers, motion sensors - it should all work as expected **out of the box**.<br>

A built-in natural-language automation engine supporting hundreds of millions of possible phrases, with full device, TV and EPG control, timers, alarms, notifications, text-to-speech, and advanced logic (if not, if, while, until, when, chain, state) - all ready to use out of the box, with no grammar definitions or scripts to configure. <br>
Much much faster than any LLM and at a much lower power consumption - plus no hallucinations!<br>
Users can even write their automations at runtime.

**EVERYTHING** is configurable via NixOS options.<br>


Use the <a href="https://raw.githubusercontent.com/QuackHack-McBlindy/zigduck/refs/heads/main/images/screenshot02.png">GNOME Shell extension</a> *(seperate flake)* for a handy top bar desktop widget and also an optional dashboard page is generated from the defined Nix configuration to display customized cards as well as scene activation and device control on-the-fly.<br><br>




<br>


![Zigduck GNOME Shell extension](https://raw.githubusercontent.com/QuackHack-McBlindy/zigduck/refs/heads/main/Screenshots/zigduck-widget.gif)

<br>



# **Installation**


### **Two installation paths**

**Automated USB installer** *(dedicated host)*
 - **Pick me** if you never heard about NixOS and don't want to hear about NixOS.
 - Insert USB, boot, wait for shutdown. Eject USB, boot & you are done.


**Nix flake module** *(recommended)*
 - For users already running NixOS with flakes
 - Ideal for power users and custom configurations

 
#### **Installing using automated USB installer**

<details><summary><strong>
💾 Installing Using USB Stick
</strong></summary>

#### **To Be Announced**

Coming soon....

<br>

</details>


#### **Installing using Flakes**

<details><summary><strong>
❄️ Installing Using Flakes
</strong></summary>


#### **1: Add zigduck as inputs in your flake.nix**

```nix
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    zigduck.url = "github:quackhack-mcblindy/zigduck";
  };
```


#### **2: Import the module into your configuration**


```nix
  imports = [
    zigduck.nixosModules.zigduck
  ];
```

> **Note:** the module also requires `self` and `inputs` as module arguments. Pass them to your `nixosSystem` via `specialArgs`:

```nix
  nixosSystem {
    specialArgs = { inherit self inputs; };
    ...
  }
```


#### **3: Enable the services**

```nix
    services.zigduck = {
      enable = true;
      cli.enable = true;

      # for security reasons, it's highly recommended to serve the dashboard over a reverse proxy (Nginx, Caddy, Traefik, etc).
      dashboard = {
        enable = true;
        # set to false if using http (not recommended)
        secure = true;
        port = 13336;
        openFirewall = true;
        passwordFile = config.sops.secrets.dashboard.path;
      };
    };
```

</details>


### **Two configuration paths (initial device/room/scenes config)**


 - Generate your Nix device config using JS from GitHub Pages. Phone/bbrowser friendly.
 - Write it yourself. (fun)

<br>

## **Configuration / Setup / Quick Start**


📖 **Full documentation:** [quackhack-mcblindy.github.io/zigduck](https://quackhack-mcblindy.github.io/zigduck)

<br>



## **Example Usage**

Just at a glance, please see the [documentation](https://quackhack-mcblindy.github.io/zigduck) for more information.


<details><summary><strong>
Example usage (automations written in Emgish) 
</strong></summary>

<br>

```nix
{
  config,
  lib,
  pkgs,
  ...
}: {
  house = {
    languages = [ "en" ];

    zigbee = {
      # 🦆 says ⮞ coordinator configuration
      coordinator = {
        vendorId  = "10c4";
        productId = "ea60";
        symlink   = "zigbee"; # 🦆 says ⮞ creates a symlink to the serial port at /dev/zigbee
      };

      # 🦆 ⮞ clicking through scenes quickly in the dimmer room!
      dimmer.doubleClickTimeout = 500;

      # 🦆 says ⮞ when motion triggers the lights to turn on
      motion = {
        when.dark.enable = true;
        trigger.lights = {
          after      = 14;
          before     = 9;
          duration   = 700;
          transition = true;
        };
      };

      # 🦆 says ⮞ when no motion triggers ALL lights to turn off
      no.motion.trigger = {
        all.lights.off = {
          enable  = true;
          after   = 90;  # 🦆 says ⮞ minutes
          exclude = [ ]; # 🦆 says ⮞ list of strings, devices to exclude (friendly name/alias, leaves their states unchanged)
        };
      };

      automations = {
        string.prefix = "hey do";

        # 🦆 says ⮞ there are 6 different automation types
        # 🦆 ⮞ + a greeting automation
        greeting = {
          enable       = true;
          awayDuration = 7200;
          door         = "Door Sensor Hall";
          delay        = 10; # 🦆 ⮞ welcome home, idiot
          actions      = [ "say welcome home, idiot" ];
        };

        # 🦆 says ⮞ 2. room action automations
        room_actions = {
          kitchen = {
            motion_not_detected = [
              # 🦆 ⮞ if the fan is consuming more than 20 watts, start a countdown to turn it off after 180 seconds, then slowly turn off the kitchen lights.
              "if the fan is consuming more than twenty watts, turn off the fan in one hundred and eighty seconds, then slowly turn off the kitchen lights"
            ];

            motion_detected = [
              # 🦆 ⮞ big 20ms window - worth it here
              { type = "scene"; scene = "kitchenInstant"; }

              # 🦆 ⮞ 1: turn on the lights.
              # 🦆 ⮞ 2: cancel the fan shutoff countdown.
              # 🦆 ⮞ 3: if my team is playing RIGHT NOW, activate the scene, and if the TV is off, start the game on TV and use TTS to announce that the game is on.
              "turn off the fan in zero seconds and if the fan is off, turn it on"

              "if Björklöven is playing right now, activate the Löven scene, and if the TV is off, start the live Björklöven game on TV, for fuck's sake, and say the game is starting now, idiot"
            ];
          };
        };

        time_based = {
          tv_scraping = {
            enable      = true;
            description = "Scrape TV guide";

            # 🦆 says ⮞ 3:30 AM every day
            schedule = {
              start = "03:30";
              days  = [ "mon" "tue" "wed" "thu" "fri" "sat" "sun" ];
            };

            # 🦆 says ⮞ scrape and save so the frontend can read it (from the zigduck user)
            actions = [
              "scrape the web for the TV guide and save it in ${zigduck.stateDir}"
            ];
          };
        };
      };
    };

  };}
```

<br>

</details>


<details><summary><strong>
Example usage (automations written in Swedish) 
</strong></summary>

<br>

```nix
{
  config,
  lib,
  pkgs,
  ...
} : {
  house = {
    languages = [ "en" ];

    zigbee = {
      # 🦆says⮞ coordinator configuration
      coordinator = {
        vendorId  =  "10c4";
        productId = "ea60";
        symlink   = "zigbee"; # 🦆 says ⮞ diz symlinkz da serial port to /dev/zigbee
      };

      # 🦆 ⮞ clickin' fast cyclez scnes in da dimmers room!
      dimmer.doubleClickTimeout = 500;

      # 🦆 says ⮞ when motion triggers lights on
      motion = {
        when.dark.enable = true;
        trigger.lights = {
          after        = 14;
          before       = 9;
          duration     = 700;
          transition   = true;
        };
      };

      # 🦆 says ⮞ when no motion triggers ALL lights off
      no.motion.trigger = {
        all.lights.off  = {
          enable  = true;
          after   = 90;  # 🦆 says ⮞ min
          exclude = [ ]; # 🦆 says ⮞ list of strings, devices to exclude (friendly name/alias, leaves their states as-is)
        };
      };

      automations = { 
        string.prefix = "yo do";
        # 🦆 says ⮞ there are 6 different automation types
        # 🦆 ⮞ + a greeting automation
        greeting  = {
          enable       = true;
          awayDuration = 7200;
          door         = "Door Sensor Hall";
          delay        = 10; # 🦆 ⮞ welcome back home idiot
          actions = [ "säg välkommen hem idiot" ];
        };

        # 🦆 says ⮞ 2. room action automations
        room_actions = {
          kitchen = {
            motion_not_detected = [
              # 🦆 ⮞ if fan is on and consuming power, start countdown to turn fan off. and slowly fade off lights.
              "om fläkten drar mer än tjugo watt så stäng fläkten om etthundraåttio sekunder sedan släck köket långsamt"
            ];

            motion_detected = [
              # 🦆 ⮞ "big" 20ms win - worth it here
              { type = "scene"; scene = "kitchenInstant"; }
              # 🦆 ⮞ 1: start lights.
              # 🦆 ⮞ 2: cancel the off-countdown on fan.
              # 🦆 ⮞ 3: if my team is playin' NOW activate scene & if tv is off start the game on TV and TTS dat the game is on now
              "stäng fläkten om noll sekunder samt om fläkten är av så sätt på fläkten"
              "om björklöven spelar just nu så aktivera scenen löven och om tvn är av så släng igång lajv björklöven för fan plus säg nu börjar match klant"
            ];
          };
        };

        time_based = {
          tv_scraping   = {
            enable      = true;
            description = "Scrape TV-guide";
            # 🦆 says ⮞ 03:30 AM everyday
            schedule    = {
              start     = "03:30";
              days      = ["mon" "tue" "wed" "thu" "fri" "sat" "sun"];
            };
            # 🦆 says ⮞ scrape & save so frontend can read it (from zigduck user)
            actions  = [ "skrapa webben efter tv guiden och spara i ${zigduck.stateDir}" ];
          };
        };  
      };
    };  

  };}
```

<br>

</details>

<br>

<details><summary><strong>
Example usage (automations written in Nix) 
</strong></summary>

<br>

```nix
{
  config,
  lib,
  pkgs,
  ...
} : {
  house = {
    zigbee = {
      networkKeyFile = config.sops.secrets.z2m_network_key.path;

      automations = {
        mqtt_triggered = {
          flash_lights = {
            enable = true;
            description = "Flash lights";
            topic = "zigduck/effects/flash";
            actions = [
              { type = "snapshot"; snapshot_name = "before_timer"; }
              { type = "scene"; scene = "max"; }
              { type = "wait"; duration = 2; }
              { type = "scene"; scene = "dark-fast"; }
              { type = "wait"; duration = 2; }
              { type = "scene"; scene = "max"; }
              { type = "wait"; duration = 2; }
              { type = "scene"; scene = "dark-fast"; }
              { type = "wait"; duration = 2; }
              { type = "scene"; scene = "max"; }
              { type = "wait"; duration = 2; }
              { type = "restore"; snapshot_name = "before_timer"; }
            ];
          };


          alarm_wakeup = {
            enable = true;
            description = "Time to wake up!";
            topic = "zigduck/alarm/triggered";
            actions = [
              { type = "mqtt"; topic = "zigduck/effects/flash"; message = " "; }
              # 🦆 says ⮞ TTS time to wake up
              { type = "shell"; command = "yo say 'wakieee wakiee dags att vaknaaaaaaa'"; }
              # 🦆 says ⮞ fuck up bed (neck up + feet up)
              { type = "mqtt"; topic = "zigduck/Robot Arm 3/set"; message = ''{"state":"OFF"}''; }
              { type = "mqtt"; topic = "zigduck/Robot Arm 4/set"; message = ''{"state":"OFF"}''; }
              { type = "wait"; duration = 10; }
              # 🦆 says ⮞ FLASH!
              { type = "mqtt"; topic = "zigduck/effects/flash"; message = " "; }
              # 🦆 ⮞ play sound on bedroom esp32 assistant
              { type = "shell"; command = "curl http://192.168.1.13/api/settings/speaker/play/ding"; }

              { type = "wait"; duration = 2; }
              # 🦆 says ⮞ ping watch with a ding
              { type = "shell"; command = "curl http://192.168.1.15/api/settings/speaker/play/ding"; }
              # 🦆 says ⮞ gib me a sec pls...
              { type = "wait"; duration = 10; }
              # 🦆 says ⮞ roll up da blindz let da sun come in
              { type = "mqtt"; topic = "zigduck/Roller Shade/set"; message = ''{"state":"ON"}''; }
              # 🦆 says ⮞ check if im up yet....
              { type = "shell"; command = ''
                motion=$(jq -r '."Motion Sensor Sovrum".occupancy' /var/lib/zigduck/state.json)
                # 🦆 says ⮞  if my lazy ass is still in bed, try calling the TV remote!
                if [[ "$motion" == "false" ]]; then
                  tv --typ call
                fi
              ''; }
            ];
          };
        };
      };  
    };

  };}
```

<br>

</details>


<br>


## **Supported Languages**

For language grammar contributions , see [CONTRIBUTING.md](CONTRIBUTING.md) <br>

<!-- LANGUAGES_START -->
| Language | Scripts | Voice scripts | Voice script coverage | Patterns | Phrases |
|----------|--------:|--------------:|:------------------------|---------:|--------:|
| 🇸🇪 Swedish | 20 | 20 | `████████████████████░` 100% | 6794 | 292198943 |
| 🇬🇧 English | 20 | 18 | `██████████████████░░` 90% | 2589 | 77536829 |
| 🇪🇸 Spanish | 20 | 8 | `████████░░░░░░░░░░░░` 40% | 1854 | 3254206 |
| 🇩🇪 German | 20 | 15 | `███████████████░░░░░` 75% | 1527 | 2798404 |
| 🇫🇷 French | 20 | 2 | `██░░░░░░░░░░░░░░░░░░` 10% | 0 | 0 |
| **Total** | **20** | **63** | | **12764** | **375788382** |
<!-- LANGUAGES_END -->

<br>



## **License**

This project is licensed under the terms of the MIT license.<br>
See the `LICENSE` file in the repository for full details.<br>

Contributions are welcomed.
