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
      { name = "typ"; description = "Specify the type of command or the media type to search for. Supported commands: on, off, up, down, call, favorites, add. Media Types: tv, movie, livetv, podcast, news, music, song, musicvideo, jukebox (random music), othervideo, youtube, nav_up, nav_down, nav_left, nav_right, nav_select, nav_menu, nav_back"; default = "tv"; optional = true; }
      { name = "search"; type = "string"; description = "Media to search"; optional = true; }
      { name = "device"; description = "Device IP to play on"; default = "192.168.1.223"; }      
      { name = "shuffle"; type = "bool"; description = "Shuffle Toggle, true or false"; default = true; }   
      { name = "tvshowsDir"; type = "path"; description = "TV shows directory"; default = "/Pool/TV"; }
      { name = "moviesDir"; type = "path"; description = "Movies directory"; default = "/Pool/Movies"; }
      { name = "musicDir"; type = "path"; description = "Music directory"; default = "/Pool/Music"; }
      { name = "musicvideoDir"; type = "path"; description = "Music videos directory"; default = "/Pool/Music_Videos"; }      
      { name = "videosDir"; type = "path"; description = "Other videos directory"; default = "/Pool/Other_Videos"; }
      { name = "podcastDir"; type = "path"; description = "Podcasts directory"; default = "/Pool/Podcasts"; }
      { name = "audiobookDir"; type = "path"; description = "Audiobooks directory"; default = "/Pool/Audiobooks"; }
      { name = "youtubeAPIkeyFile"; type = "path"; description = "File containing YouTube API key"; default = config.sops.secrets.youtube_api_key.path; }
      { name = "webserver"; type = "path"; description = "File containing webserver URL that stores media"; default = config.sops.secrets.webserver.path; }     
      { name = "defaultPlaylist"; description = "Default playlist path"; default = "/Pool/playlist.m3u"; }
      { name = "favoritesPlaylist"; description = "File path for Favouyrites tagged entries"; default = "/Pool/favorites.m3u"; }      
      { name = "max_items"; type = "int"; description = "Set a maximum number of items in playlist"; default = 200; }       
      { name = "mqttUser"; type = "string"; description = "User which Mosquitto runs on"; default = "mqtt"; optional = false; }
      { name = "mqttPWFile"; type = "path"; description = "Password file for Mosquitto user"; optional = false; default = config.sops.secrets.mosquitto.path; }
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
