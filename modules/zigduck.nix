{ 
  self,
  config,
  lib,
  pkgs,
  ...
} : with lib;
let
  cfg = config.services.zigduck;
  house = config.house;
  zigduckDir = cfg.stateDir;
  

  # 🦆 says ⮞ define Zigbee devices here yo 
  zigbeeDevices = config.house.zigbee.devices;
  
  # 🦆 says ⮞ case-insensitive device matching
  normalizedDeviceMap = lib.mapAttrs' (id: device:
    lib.nameValuePair (lib.toLower device.friendly_name) device.friendly_name
  ) zigbeeDevices;

  # 🦆 says ⮞ device validation list
  deviceList = builtins.attrNames normalizedDeviceMap;

  # 🦆 says ⮞ Create reverse mapping from friendly_name to device ID
  friendlyNameToId = builtins.listToAttrs (
    lib.flatten (
      lib.mapAttrsToList (id: device: [
        { 
          name = device.friendly_name; 
          value = id; 
        }
      ]) zigbeeDevices
    )
  );


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
  # 🎨 Scenes for CLI
  sceneConfigCli = pkgs.writeText "scene-config-cli.json" (builtins.toJSON (
    lib.mapAttrs (sceneName: sceneDevices: {
      friendly_name = sceneName;
      devices = sceneDevices;
    }) scenes
  ));
  
  # 🦆 says ⮞ Generate scene commands    
  makeCommand = deviceName: settings:
    let
      # 🦆 says ⮞ Try to find device ID by friendly name
      deviceId = friendlyNameToId.${deviceName} or null;
      dev = if deviceId != null then zigbeeDevices.${deviceId} else null;
      json = builtins.toJSON settings;
      hue_id = if dev != null && dev.hue_id != null then toString dev.hue_id else "unknown";
      # 🦆 says ⮞ Use device's friendly name for MQTT topic
      mqttName = if dev != null then dev.friendly_name else deviceName;
    in
      if dev == null then
        # 🦆 says ⮞ Device not found - output error but continue
        ''echo "🦆 Warning: Device '${deviceName}' not found in zigbeeDevices"''
      else if dev.type == "hue_light" then
        ''yo house --device "${mqttName}" --json "${json}"''
      else
        ''mqtt_pub --topic "zigbee2mqtt/${mqttName}/set" -m '${json}''
      ;
      
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

  format = pkgs.formats.yaml { };
  configFile = format.generate "zigbee2mqtt.yaml" config.house.zigbee.settings;

  # 🦆 says ⮞ gen json from `config.house.tv`  
  tvDevicesJson = pkgs.writeText "tv-devices.json" (builtins.toJSON config.house.tv);

  # 🦆 says ⮞ IEEE not very human readable - lets fix dat yo
  ieeeToFriendly = lib.mapAttrs (ieee: dev: dev.friendly_name) zigbeeDevices;
  mappingJSON = builtins.toJSON ieeeToFriendly;
  mappingFile = pkgs.writeText "ieee-to-friendly.json" mappingJSON;


  # 🦆 says ⮞ Service expects 'id' field (friendly_name), CLI expects 'friendly_name' field
  deviceMeta = builtins.toJSON (
    lib.listToAttrs (
      lib.filter (attr: attr.name != null) (
        lib.mapAttrsToList (ieee: dev: {
          name = dev.friendly_name;
          value = {
            id = dev.friendly_name;
            room = dev.room;
            type = dev.type;
            endpoint = dev.endpoint;
            ieee = ieee;
          
            # CLI
            friendly_name = dev.friendly_name;
            hue_id = dev.hue_id or null;
            supports_color = dev.supports_color or null;
            supports_temperature = dev.supports_temperature or null;
            icon = dev.icon or null;
            battery_type = dev.battery_type or null;
          };
        }) zigbeeDevices
      )
    )
  );
  


  # 🦆 says ⮞ dis creates device configuration for Z2M yo
  deviceConfig = 
    let
      # 🦆 says ⮞ Z2M does not need hue lights
      filteredDevices = lib.filterAttrs (_: dev: dev.type != "hue_light") zigbeeDevices;
    in
    # 🦆 says ⮞ create map for Z2M
    lib.mapAttrs (id: dev: {
      friendly_name = dev.friendly_name;
    }) filteredDevices;


  # 🦆 says ⮞ Generate automations configuration
  automationsJSON = builtins.toJSON config.house.zigbee.automations;
  automationsFile = pkgs.writeText "automations.json" automationsJSON;

  # 🦆 says ⮞ Generate dashboard configuration
  dashboardConfig = lib.filterAttrs (_: card: card.enable) config.house.dashboard.statusCards;
  dashboardConfigJSON = builtins.toJSON {
      cards = lib.mapAttrs (name: card: {
          enable = card.enable;
          title = card.title;
          icon = card.icon;
          color = card.color;
          on_click_action = card.on_click_action or [];
      }) dashboardConfig;
  };
  dashboardConfigFile = pkgs.writeText "dashboard-config.json" dashboardConfigJSON;

  # 🦆 needz 4 rust  
  devices-json = pkgs.writeText "devices.json" deviceMeta;
  jsonFormat = pkgs.formats.json { };

  mainConfig = {
    mosquitto = {
      broker = house.zigbee.mosquitto.host;
      user = house.zigbee.mosquitto.username;
      password_file = house.zigbee.mosquitto.passwordFile; 
    };
    hue = {
      bridge_ip = house.zigbee.hueSyncBox.bridge.ip;
      password_file = house.zigbee.hueSyncBox.bridge.passwordFile;
    };
    dark_time = {
      enabled = house.zigbee.motion.enable;
      after = house.zigbee.motion.trigger.lights.after;
      before = house.zigbee.motion.trigger.lights.before;
      duration = house.zigbee.motion.trigger.lights.duration;
    };
    dimmer = {
      message_key = house.zigbee.dimmer.message;
      actions = {
        on_press = house.zigbee.dimmer.actions.onPress;
        on_hold = house.zigbee.dimmer.actions.onHold;
        off_press = house.zigbee.dimmer.actions.offPress;
        off_hold = house.zigbee.dimmer.actions.offHold;
        up_press = house.zigbee.dimmer.actions.upPress;
        up_hold = house.zigbee.dimmer.actions.upHold;
        down_press = house.zigbee.dimmer.actions.downPress;
        down_hold = house.zigbee.dimmer.actions.downHold;
      };
      double_click_timeout_ms = house.zigbee.dimmer.doubleClickTimeout;
    };
  };

  zigduckConfigFile = jsonFormat.generate "config.json" mainConfig;

in {

  options.services.zigduck = {
    enable = mkEnableOption "Zigduck";

    # Command line options
    cli = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to install the zg wrapper with default settings.";
      };

      broker = mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = "Default MQTT broker host for the zg wrapper.";
      };

      user = mkOption {
        type = types.str;
        default = config.house.zigbee.mosquitto.username or "mqtt";
        description = "Default MQTT username for the zg wrapper.";
      };

      passwordFile = mkOption {
        type = types.nullOr types.path;
        default = config.house.zigbee.mosquitto.passwordFile or null;
        description = "Default path to MQTT password file for the zg wrapper.";
      };

      hueBridgeIp = mkOption {
        type = types.nullOr types.str;
        default = config.house.zigbee.hueBridgeIp or null;
        description = "Default Hue Bridge IP for the zg wrapper.";
      };

      hueApiKeyFile = mkOption {
        type = types.nullOr types.path;
        default = config.house.zigbee.hueApiKeyFile or null;
        description = "Default path to Hue API key file for the zg wrapper.";
      };
    };

    # Zigduck Service options
    broker = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "MQTT broker hostname or IP address";
    };

    user = mkOption {
      type = types.str;
      default = config.house.zigbee.mosquitto.username;
      description = "MQTT username";
    };

    passwordFile = mkOption {
      type = types.nullOr types.path;
      default = config.house.zigbee.mosquitto.passwordFile;
      description = ''
        Path to a file containing the MQTT password.
        If not set, the service will try to read `/run/secrets/mosquitto`.
      '';
    };

    configFile = mkOption {
      type = types.path;
      description = "Path to zigduck JSON configuration file";
      default = "/etc/zigduck/config.json";
    };

    devicesFile = mkOption {
      type = types.path;
      default = "/etc/zigduck/devices.json"; 
      description = "Path to devices JSON file";
    };

    sceneFile = mkOption {
      type = types.path;
      default = sceneConfig;
      description = "Path to scenes JSON file";
    };

    automationsFile = mkOption {
      type = types.path;
      default = automationsJSONFile;
      description = "Path to automations JSON file";
    };

    stateDir = mkOption {
      type = types.path;
      default = "/var/lib/zigduck";
      description = "Directory for runtime state files";
    };

    debug = mkOption {
      type = types.bool;
      default = false;
      description = "Enable debug logging (sets DEBUG=1)";
    };

    extraEnv = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Extra environment variables to pass to the service";
    };
  };

  
  config = mkMerge [
    (mkIf cfg.enable {
      environment.systemPackages = [ 
        pkgs.clang
        pkgs.mosquitto
        pkgs.zigbee2mqtt      
      ];
  
      networking.firewall.allowedTCPPorts =
        (map (l: l.port) config.services.mosquitto.listeners)
        ++ [ config.house.zigbee.settings.frontend.port ];
    
      house.zigbee = {
        enable = true;
        dataDir = lib.mkForce "/var/lib/zigbee";
        settings = {
          homeassistant = lib.mkDefault false;
          mqtt = {
            server = "mqtt://localhost:1883";
            user = config.house.zigbee.mosquitto.username;
            password = config.house.zigbee.mosquitto.passwordFile;
            base_topic = "zigbee2mqtt";
          };
          serial = {
            port = "/dev/" + config.house.zigbee.coordinator.symlink;
            adapter = config.house.zigbee.coordinator.adapter;
          };
          frontend = { 
            enabled = true;
            host = "0.0.0.0";   
            port = 8099; 
          };
          advanced = {
            homeassistant_legacy_entity_attributes = false;
            homeassistant_legacy_triggers = false;
            legacy_api = false;
            legacy_availability_payload = false;
            transmit_power = 9;
            channel = 15;
            last_seen = "ISO_8601_local";
            pan_id = 60410;
          };
          device_options = { legacy = false; };
          availability = false;
          permit_join = false;
          devices = deviceConfig;
          groups = groupConfig // {
            all_lights = {
              friendly_name = "all";
              devices = lib.concatMap (id: 
                let dev = zigbeeDevices.${id};
                in if dev.type == "light" then ["${id}/${toString dev.endpoint}"] else []
              ) (lib.attrNames zigbeeDevices);
            };
          };
        }; 
      };
      
      systemd.services.zigbee2mqtt = {
        wantedBy = [ "multi-user.target" ];
        after = [ "sops-nix.service" "network.target" "systemd-tmpfiles-setup.service" ];
        wants = [ "systemd-tmpfiles-setup.service" ];
        environment.ZIGBEE2MQTT_DATA = config.house.zigbee.dataDir;
        preStart = ''
          mkdir -p ${config.house.zigbee.dataDir}
          cp --no-preserve=mode ${configFile} ${config.house.zigbee.dataDir}/configuration.yaml
          mosquitto_password=$(cat ${config.house.zigbee.mosquitto.passwordFile})
          network_key=$(cat ${config.house.zigbee.networkKeyFile})
          sed -i "s|/run/secrets/mosquitto|$mosquitto_password|" ${config.house.zigbee.dataDir}/configuration.yaml
          TMPFILE="${config.house.zigbee.dataDir}/config.yaml"
          CFGFILE="${config.house.zigbee.dataDir}/configuration.yaml"
          ${pkgs.gawk}/bin/awk -v keyfile="${config.house.zigbee.networkKeyFile}" '
            /(^|[[:space:]])network_key:/ { found = 1 }
            { lines[NR] = $0 }
            END {
              if (found) {
                for (i = 1; i <= NR; i++) print lines[i]
              } else {
                print lines[1]
                print "  network_key:"
                while ((getline line < keyfile) > 0) {
                  print "    " line
                }
                close(keyfile)
                for (i = 2; i <= NR; i++) print lines[i]
              }
            }
          ' "$CFGFILE" > "$TMPFILE"      
          cp "$TMPFILE" "$CFGFILE"
        '';
  
        serviceConfig = {
          ExecStart = "${pkgs.zigbee2mqtt}/bin/zigbee2mqtt";
          User = "zigbee2mqtt";
          Group = "zigbee2mqtt";
          WorkingDirectory = config.house.zigbee.dataDir;
          CapabilityBoundingSet = "";
          DeviceAllow = lib.optionals (lib.hasPrefix "/" config.house.zigbee.settings.serial.port) [
            config.house.zigbee.settings.serial.port
          ];
          DevicePolicy = "closed";
          LockPersonality = true;
          MemoryDenyWriteExecute = false;
          NoNewPrivileges = true;
          PrivateDevices = false;
          PrivateUsers = true;
          PrivateTmp = true;
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectProc = "invisible";
          ProcSubset = "pid";
          ProtectSystem = "strict";
          ReadWritePaths = config.house.zigbee.dataDir;
          RemoveIPC = true;
          RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_NETLINK" ];
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          SupplementaryGroups = [ "dialout" ];
          SystemCallArchitectures = "native";
          SystemCallFilter = [ "@system-service @pkey" "~@privileged @resources" "@chown" ];
          UMask = "0077";
        };
      };
  
      services.mosquitto = {
        enable = true;
        listeners = [
          {
            acl = [ "pattern readwrite #" ];
            port = 1883;
            omitPasswordAuth = false;
            users.${config.house.zigbee.mosquitto.username}.passwordFile = config.house.zigbee.mosquitto.passwordFile;
            settings.allow_anonymous = false;
          }   
          {
            acl = [ "pattern readwrite #" ];
            port = 9001;
            settings.protocol = "websockets";
            omitPasswordAuth = false;
            users.${config.house.zigbee.mosquitto.username}.passwordFile = config.house.zigbee.mosquitto.passwordFile;
            settings.allow_anonymous = false;
            settings.require_certificate = false;
          } 
        ];
      };
  
      systemd.services.zigduck = {
        description = "Zigduck Home Automation Service";
        after = [ "network.target" "mosquitto.service" ];
        wants = [ "mosquitto.service" ];
        wantedBy = [ "multi-user.target" ];
  
        serviceConfig = {
          Type = "simple";
          User = "zigduck";
          Group = "zigduck";
          StateDirectory = "zigduck";
          StateDirectoryMode = "0750";
          WorkingDirectory = cfg.stateDir;
          ExecStart = "${pkgs.zigduck-rs}/bin/zigduck-rs";
          Restart = "on-failure";
          RestartSec = "45s";

          Environment = let
            env = {
              MQTT_BROKER = cfg.broker;
              MQTT_USER = cfg.user;
              MQTT_PASSWORD_FILE = cfg.passwordFile;
              ZIGDUCK_CONFIG = cfg.configFile;
              STATE_DIR = cfg.stateDir;
              DT_LOG_LEVEL = "INFO";
              DT_LOG_FILE = cfg.stateDir + "/zigduck.log";
              PATH = "/run/current-system/sw/bin:/run/wrappers/bin:/nix/var/nix/profiles/default/bin:/nix/var/nix/profiles/default/sbin:/run/current-system/sw/sbin";
            } // optionalAttrs cfg.debug { DEBUG = "1"; } // cfg.extraEnv;
          in mapAttrsToList (name: value: "${name}=${value}") env;
        };
      };
  
  
      systemd.tmpfiles.rules = [
        "d ${cfg.stateDir} 0755 zigduck zigduck - -"
        "d ${cfg.stateDir}/timers 0755 zigduck zigduck - -"
        "f ${cfg.stateDir}/state.json 0644 zigduck zigduck - -"
        "d ${config.house.zigbee.dataDir} 0755 zigbee2mqtt zigbee2mqtt -"
      ];  
    })

    (mkIf cfg.cli.enable {
      environment.systemPackages = [ pkgs.zigduck-rs ];
    })
  
    {
      environment.systemPackages = [ pkgs.zigduck-rs ];
      environment.etc."zigduck/config.json".source = zigduckConfigFile;
      environment.etc."zigduck/devices.json".source = devices-json;
      environment.etc."zigduck/automations.json".source = automationsFile;
      environment.etc."zigduck/scenes.json".source = sceneConfig;
      environment.etc."zigduck/scenesCLI.json".source = sceneConfigCli;
      environment.etc."zigduck/dashboard.json".source = dashboardConfigFile;
      

      users.users.zigduck = {
        isSystemUser = true;
        group = "zigduck";
        home = cfg.stateDir;
        createHome = true;
      };
  
      users.groups.zigduck = { };
    }
    
  ];}
