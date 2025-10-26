# dotfiles/bin/media/vlc.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ playlist management 
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ... 
} : let # 🦆 says ⮞ yo    
  # 🦆 says ⮞ gen json from `config.house.tv`  
  channelsJson = pkgs.writeText "channels.json" (builtins.toJSON (
    lib.mapAttrs (deviceName: deviceConfig: deviceConfig.channels) config.house.tv
  ));  
  tvDevicesJson = pkgs.writeText "tv-devices.json" (builtins.toJSON config.house.tv);

  # 🦆 says ⮞ mqtt is used for tracking channel states on devices
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
  mqttAuth = "-u mqtt -P $(cat ${config.sops.secrets.mosquitto.path})";

in {   
   
  yo.scripts.vlc = {
    description = "Playlist management for the local machine";
    category = "🎧 Media Management";
    autoStart = false;
    logLevel = "INFO";
    parameters = [
      { name = "add"; type = "path"; description = "Append file path to playlist"; optional = true; }
      { name = "add_folder"; type = "path"; description = "Append directory path to playlist"; }      
      { name = "remove"; type = "path"; description = "Remove file path from playlist"; }      

    ];
    code = ''
      ${cmdHelpers}

    '';
  };
    
  sops.secrets = {
    webserver = { # 🦆 says ⮞ https required
      sopsFile = ../../secrets/webserver.yaml;
      owner = config.this.user.me.name;
      group = config.this.user.me.name;
      mode = "0440";
    }; # 🦆 says ⮞ required for youtube
    youtube_api_key = { 
      sopsFile = ../../secrets/youtube.yaml;
      owner = config.this.user.me.name;
      group = config.this.user.me.name;
      mode = "0440";
    };
    
  };}
