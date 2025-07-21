{ 
  config, 
  lib, 
  pkgs, 
  ... 
} : { 

  services.jellyfin = lib.mkIf (lib.elem "jelly" config.this.host.modules.services) {
    enable = true;
    package = pkgs.jellyfin-ffmpeg;
    openFirewall = true;
#    webPackage = pkgs.jellyfin-web.override {
#      forceEnableBackdrops = true;
#    };

#    ffmpegPackage = pkgs.jellyfin-ffmpeg;

#    settings = {
#      system = {
#        enableMetrics = true;
#        quickConnectAvailable = false;
#        preferredMetadataLanguage = "de";
#        metadataOptions = [
#          {
#            itemType = "MusicArtist";
#            disabledMetadataFetchers = ["TheAudioDB"];
#          }
#        ];
#        pluginRepositories = [
#          {
#            name = "MyPlugins";
#            url = "https://myplugins.example.org/manifest.json";
#          }
#        ];
#      };      
      
#      branding = {
#        loginDisclaimer = "This service is provided for personal use only.";
#        customCss = builtins.readFile ./../themes/css/jellyfin.css; 
#        splashscreenEnabled = true;
#      };

#      encoding = {
#        encodingThreadCount = 4;
#        enableFallbackFont = true;
#        hardwareAccelerationType = "nvenc";
#        encoderPreset = "fast";
#        h264Crf = 20;
#        enableHardwareEncoding = true;
  
#      };

#      metadata = {
#        useFileCreationTimeForDateAdded = true;       
#      };


    };}
#  };
#}

