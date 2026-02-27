{ 
  self,
  config,
  lib,
  pkgs,
  ...
} : with lib;
let
  cfg = config.services.zigduck;
  zigduckDir = cfg.stateDir;
  
  zigbeeDevices = config.house.zigbee.devices;
  
  normalizedDeviceMap = lib.mapAttrs' (id: device:
    lib.nameValuePair (lib.toLower device.friendly_name) device.friendly_name
  ) zigbeeDevices;

  deviceList = builtins.attrNames normalizedDeviceMap;

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

  sceneLight = {state, brightness ? 200, hex ? null, temp ? null}:
    let
      colorValue = if hex != null then { inherit hex; } else null;
    in
    {
      inherit state brightness;
    } // (if colorValue != null then { color = colorValue; } else {})
      // (if temp != null then { color_temp = temp; } else {});

  scenes = config.house.zigbee.scenes;
  sceneConfig = pkgs.writeText "scene-config.json" (builtins.toJSON {
    scenes = scenes;
  });
  
  makeCommand = deviceName: settings:
    let
      deviceId = friendlyNameToId.${deviceName} or null;
      dev = if deviceId != null then zigbeeDevices.${deviceId} else null;
      json = builtins.toJSON settings;
      hue_id = if dev != null && dev.hue_id != null then toString dev.hue_id else "unknown";
      mqttName = if dev != null then dev.friendly_name else deviceName;
    in
      if dev == null then
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

  byRoom = lib.foldlAttrs (acc: id: dev:
    lib.recursiveUpdate acc {
      ${dev.room} = (acc.${dev.room} or []) ++ [ id ];
    }) {} zigbeeDevices;

  byType = lib.foldlAttrs (acc: id: dev:
    lib.recursiveUpdate acc {
      ${dev.type} = (acc.${dev.type} or []) ++ [ id ];
    }) {} zigbeeDevices;

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

  yamlFormat = pkgs.formats.yaml { };
  configFile = yamlFormat.generate "zigbee2mqtt.yaml" config.house.zigbee.settings;

  tvDevicesJson = pkgs.writeText "tv-devices.json" (builtins.toJSON config.house.tv);

  ieeeToFriendly = lib.mapAttrs (ieee: dev: dev.friendly_name) zigbeeDevices;
  mappingJSON = builtins.toJSON ieeeToFriendly;
  mappingFile = pkgs.writeText "ieee-to-friendly.json" mappingJSON;

  deviceMeta = builtins.toJSON (
    lib.listToAttrs (
      lib.filter (attr: attr.name != null) (
        lib.mapAttrsToList (ieee: dev: {
          name = dev.friendly_name;
          value = {
            room = dev.room;
            type = dev.type;
            id = dev.friendly_name;
            endpoint = dev.endpoint;
            ieee = ieee;            
          };
        }) zigbeeDevices
      )
    )
  );

  deviceConfig = 
    let
      filteredDevices = lib.filterAttrs (_: dev: dev.type != "hue_light") zigbeeDevices;
    in
    lib.mapAttrs (id: dev: {
      friendly_name = dev.friendly_name;
    }) filteredDevices;


  automationsJSON = builtins.toJSON config.house.zigbee.automations;
  automationsJSONFile = pkgs.writeText "automations.json" automationsJSON;

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

  devices-json = pkgs.writeText "devices.json" deviceMeta;  

  house = config.house;

  jsonFormat = pkgs.formats.json { };

  mainConfig = {
    dark_time = {
      enabled = house.zigbee.darkTime.enable;
      after = house.zigbee.darkTime.after;
      before = house.zigbee.darkTime.before;
      duration = house.zigbee.darkTime.duration;
    };
    automations = house.zigbee.automations;     
    greeting = {
      away_duration = house.zigbee.automations.greeting.awayDuration;
      greeting = house.zigbee.automations.greeting.greeting;
      say_on_host = house.zigbee.automations.greeting.sayOnHost;
      delay = house.zigbee.automations.greeting.delay;
    };
    dimmer = {
      message = house.zigbee.dimmer.message;
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
    };
  };

  automationsWithoutGreeting = filterAttrs (n: v: n != "greeting") house.zigbee.automations;
  zigduckConfigFile = jsonFormat.generate "config.json" mainConfig;

in {
  options.services.zigduck = {
    enable = mkEnableOption "Zigduck";

    broker = mkOption {
      type = types.str;
      default = "0.0.0.0";
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
        The file must contain a line like: `MQTT_PASSWORD=yourpassword`
        If not set, the service will try to read `/run/secrets/mosquitto`.
      '';
    };

    configFile = mkOption {
      type = types.path;
      description = "Path to zigduck JSON configuration file";
      default = zigduckConfigFile;
      example = "/etc/zigduck/config.json";
    };

    devicesFile = mkOption {
      type = types.path;
      default = devices-json; 
      description = "Path to devices JSON file";
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

  config = mkIf cfg.enable {
    environment.systemPackages = [ 
      self.packages.x86_64-linux.zigduck-rs
      pkgs.clang
      pkgs.mosquitto
      pkgs.zigbee2mqtt      
    ];

    # 🦆 says ⮞ open firewall 4 Z2MQTT & Mosquitto on the server host
    networking.firewall.allowedTCPPorts =
      (map (l: l.port) config.services.mosquitto.listeners)
      ++ [ config.house.zigbee.settings.frontend.port ];


    # Zigbee2MQTT configuration
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
            channel = 15; # 🦆 says ⮞ channel 15 optimized for minimal interference from other 2.4Ghz devices, provides good stability  
            last_seen = "ISO_8601_local";
            #network_key = [ ];
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
      after = [ "sops-nix.service" "network.target" "systemd-tmpfiles-setup.service" ];  # ← added
      wants = [ "systemd-tmpfiles-setup.service" ];                                      # ← added
      environment.ZIGBEE2MQTT_DATA = config.house.zigbee.dataDir;
      preStart = ''
        # 🦆 says ⮞ Let's do some clean quacktastic config setup!
        # 🦆 says ⮞ Cceate data dir
        mkdir -p ${config.house.zigbee.dataDir}
    
        # 🦆 says ⮞ copy base setings
        cp --no-preserve=mode ${configFile} ${config.house.zigbee.dataDir}/configuration.yaml
 
        # 🦆 says ⮞ our real mosquitto password quack quack
        mosquitto_password=$(cat ${config.sops.secrets.z2m_mosquitto.path})
        network_key=$(cat ${config.house.zigbee.networkKeyFile})

        # 🦆 says ⮞ Injecting password into config...
        sed -i "s|/run/secrets/mosquitto|$mosquitto_password|" ${config.house.zigbee.dataDir}/configuration.yaml  
        # 🦆 says ⮞ da real zigbee network key boom boom quack quack yo yo
        TMPFILE="${config.house.zigbee.dataDir}/config.yaml"
        CFGFILE="${config.house.zigbee.dataDir}/configuration.yaml"
        # 🦆 says ⮞ starting awk decryption magic..."
        ${pkgs.gawk}/bin/awk -v keyfile="${config.sops.secrets.z2m_network_key.path}" '
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
      ''; # 🦆 says ⮞ thnx fo quackin' along!

      serviceConfig = {
        ExecStart = "${pkgs.zigbee2mqtt}/bin/zigbee2mqtt";
        User = "zigbee2mqtt";
        Group = "zigbee2mqtt";
        WorkingDirectory = config.house.zigbee.dataDir;
        #StateDirectory = "zigbee2mqtt";
        #StateDirectoryMode = "0700";

        # Hardening
        CapabilityBoundingSet = "";
        DeviceAllow = lib.optionals (lib.hasPrefix "/" config.house.zigbee.settings.serial.port) [
          config.house.zigbee.settings.serial.port
        ];
        DevicePolicy = "closed";
        LockPersonality = true;
        MemoryDenyWriteExecute = false;
        NoNewPrivileges = true;
        PrivateDevices = false; # prevents access to /dev/serial, because it is set 0700 root:root
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
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SupplementaryGroups = [
          "dialout"
        ];
        SystemCallArchitectures = "native";
        SystemCallFilter = [
          "@system-service @pkey"
          "~@privileged @resources"
          "@chown"
        ];
        UMask = "0077";
      };
    };


    # Mosquitto configuration
    services.mosquitto = {
      enable = true;
      listeners = [
        {
          acl = [ "pattern readwrite #" ];
          port = 1883;
          omitPasswordAuth = false;
          users.${config.house.zigbee.mosquitto.username}.passwordFile = config.house.zigbee.mosquitto.passwordFile;
          settings.allow_anonymous = false;
  #        settings.require_certificate = true;
  #        settings.use_identity_as_username = true;
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

    # Zigduck configuration
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
        ExecStart = "${self.packages.x86_64-linux.zigduck-rs}/bin/zigduck-rs";
        Restart = "on-failure";
        RestartSec = "45s";
        EnvironmentFile = mkIf (cfg.passwordFile != null) [ cfg.passwordFile ];
        Environment = let
          env = {
            MQTT_BROKER = cfg.broker;
            MQTT_USER = cfg.user;
            ZIGDUCK_CONFIG = cfg.configFile;
            ZIGBEE_DEVICES_FILE = cfg.devicesFile;
            AUTOMATIONS_FILE = cfg.automationsFile;
            STATE_DIR = cfg.stateDir;
            SCENE_CONFIG_FILE = sceneConfig;
          } // optionalAttrs cfg.debug { DEBUG = "1"; } // cfg.extraEnv;
        in mapAttrsToList (name: value: "${name}=${value}") env;
      };
    };

    users.users.zigduck = {
      isSystemUser = true;
      group = "zigduck";
      home = cfg.stateDir;
      createHome = true;
    };

    users.groups.zigduck = { };
    
    systemd.tmpfiles.rules = [
      "d ${cfg.stateDir} 0755 zigduck zigduck - -"
      "d ${cfg.stateDir}/timers 0755 zigduck zigduck - -"
      "f ${cfg.stateDir}/state.json 0644 zigduck zigduck - -"
      "d ${config.house.zigbee.dataDir} 0755 zigbee2mqtt zigbee2mqtt -"
    ]; 
    
  };}
