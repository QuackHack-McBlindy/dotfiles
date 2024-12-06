{ config, pkgs, lib, inputs, modulesPath, ... }:

{
  # Include the results of the hardware scan.
    imports = [ ./hardware-configuration.nix
                 ./../../modules/nixos/battery.nix
                # ./../../modules/nixos/shell.nix
                 ./../../modules/nixos/users.nix
         #        ./../../modules/home/gnome/firefox.nix

    ];

  # TEMP
    xdg.portal.config.common.default = "*";
  # fix
    boot.kernelParams = [ "intel_pstate=active" ];

  # Nix
    nix.optimise.automatic = true;
    nixpkgs.config.allowUnfree = true;
    nix = {
      package = pkgs.nixFlakes;
      extraOptions = ''
        experimental-features = nix-command flakes
      '';
    };
 
  # ntfs support
    boot.supportedFilesystems = [ "ntfs" ];
    
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };
  virtualisation.docker.daemon.settings = {
    data-root = "/docker";
  };
  # https://github.com/NixOS/nixpkgs/blob/e2dd4e18cc1c7314e24154331bae07df76eb582f/nixos/modules/virtualisation/oci-containers.nix
   virtualisation.oci-containers = {
     backend = "docker";
     containers = {
      # HOMEPAGE
      homepage = {
        image = "ghcr.io/gethomepage/homepage:latest";
        hostname = "homepage";  # Set container name
        ports = [ "3000:3000" ];  # Define ports
        volumes = [ "/home/pungkula/.config/docker/startsida/config:/app/config" ];  
    #    user = "1000";  
      #  extraOptions = ["--network=host"];
      #  environmentFiles = [ "/$HOME/docker/startsida/config/.env" "/$HOME/docker/startsida/config/.env.secret" ]        
 #      "/home/pungkula/docker/${toString config.virtualisation.docker.containers.homepage.hostname}/config/.env.secret" 
      };
    };
  };

  #     invokeai = {
     #    image = "local/invokeai:latest";
   #      build = {
    #       context = "..";
      #     dockerfile = "/homepungkula/docker/invokeai/docker/Dockerfile";
    #     };
        # environment = {
        #   INVOKEAI_ROOT = "<value>"; # Replace with actual value or fetch from .env
        #   HF_HOME = "<value>";       # Replace with actual value or fetch from .env
        # };
      #   environmentFiles = [
          # "/homepungkula/docker/invokeai/docker/.env"
         #];
        # ports = [
       #    "9595:9090"
       #  ];
       #  volumes = [
     #      {
       #      type = "bind";
       #      source = "${HOST_INVOKEAI_ROOT:-${INVOKEAI_ROOT:-~/invokeai}}";
       #      target = "${INVOKEAI_ROOT:-/invokeai}";
   #        }
     #      {
   #          type = "bind";
    #         source = "${HF_HOME:-~/.cache/huggingface}";
    #         target = "${HF_HOME:-/invokeai/.cache/huggingface}";
    #       }
 #        ];
 #        tty = true;
   #      stdin_open = true;
 #        extraOptions = [
   #        "--device=/dev/kfd:/dev/kfd"
  #         "--device=/dev/dri:/dev/dri"
     #      "--network=host"
    #     ];
  #      profiles = [
   #        "rocm"
     #    ];
#       };
     #};

  # Fonts
    fonts.packages = with pkgs; [
      font-awesome
      noto-fonts-emoji
     (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" "Iosevka"  ]; })
     ];
  #emojis
    services.gollum.emoji = true;


    # Bootloader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
	  
    # ROCm
    boot.initrd.kernelModules = [ "amdgpu" ];

    networking.hostName = "desktop";
    networking.networkmanager.enable = true; 
  # Bluethooth
    hardware.bluetooth.enable = true;
    services.blueman.enable = true;
    
 # ->SOUND SNAPCAST SERVER & PIPEWIRE <- #
    services.snapserver = {
      enable = true;
      codec = "flac";
      streams = {
        pipewire  = {
          type = "pipe";
          location = "/run/snapserver/pipewire";
        };
      };
    };


    systemd.user.services.snapcast-sink = {
      wantedBy = [
        "pipewire.service"
      ];
      after = [
        "pipewire.service"
      ];
      bindsTo = [
        "pipewire.service"
     ];
      path = with pkgs; [
        gawk
       pulseaudio
      ];
      script = ''
        pactl load-module module-pipe-sink file=/run/snapserver/pipewire sink_name=Snapcast format=s16le rate=48000
      '';
    };
  
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      # jack.enable = true;
      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      # media-session.enable = true;
    };
    # playback
    systemd.user.services.snapclient-local = {
      wantedBy = [
        "pipewire.service"
      ];
      after = [
        "pipewire.service"
      ];
      serviceConfig = {
       ExecStart = "${pkgs.snapcast}/bin/snapclient -h ::1";
      };
    };
 
    time.timeZone = "Europe/Stockholm";
    i18n.defaultLocale = "sv_SE.UTF-8";
   # i18n.consoleFont   = "lat9w-16";
    i18n.consoleKeyMap = "sv-latin1";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "sv_SE.UTF-8";
      LC_IDENTIFICATION = "sv_SE.UTF-8";
      LC_MEASUREMENT = "sv_SE.UTF-8";
      LC_MONETARY = "sv_SE.UTF-8";
      LC_NAME = "sv_SE.UTF-8";
      LC_NUMERIC = "sv_SE.UTF-8";
      LC_PAPER = "sv_SE.UTF-8";
      LC_TELEPHONE = "sv_SE.UTF-8";
      LC_TIME = "sv_SE.UTF-8";
    };
 
  # -> XSERVER <- #
    services.xserver = {
        exportConfiguration = true; # link /usr/share/X11/ properly
        xkb.layout = "se";
        xkb.options = "eurosign:e";
        # xkb.variant = '"
        # xkb.variant = "qwerty_digits";
    };

  ###Services###
  # Enable the X11 windowing system.
    services.xserver.enable = true;
  # Flatpak
    services.flatpak.enable = true;
  # locate
    services.locate.enable = true;
  # Enable CUPS to print documents.
    services.printing.enable = true;
  # Enable touchpad support (enabled default in most desktopManager).
  #  services.libinput.enable = true;
   # services.libinput.touchpad.tapping = true; #tap

  #polkit Auth Agent
   # systemd = {
   #   user.services.polkit-gnome-authentication-agent-1 = {
   #     description = "polkit-gnome-authentication-agent-1";
   #     wantedBy = [ "graphical-session.target" ];
     #   wants = [ "graphical-session.target" ];
     #   after = [ "graphical-session.target" ];
     #   serviceConfig = {
       #   Type = "simple";
       #   ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
       #   Restart = "on-failure";
       #   RestartSec = 1;
       #   TimeoutStopSec = 10;
       # };
   #   };
 #   };

  
  ###Display###
  # Enable Gnome login
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.displayManager.gdm.wayland = true;
    services.xserver.desktopManager.gnome.enable = true;
      environment.gnome.excludePackages = 
        (with pkgs; [
          gnome-photos
          gnome-tour
        ]) ++ (with pkgs.gnome; [
          cheese # webcam tool
          gnome-music
          file-roller
          #gedit # text editor
          epiphany # web browser
          geary # email reader
          evince # document viewer
          gnome-characters
          totem # video player
          tali # poker game
          iagno # go game
          hitori # sudoku game
          atomix # puzzle game
          rygel
          yelp
          gnome-logs
          gnome-clocks
          gnome-contacts
        ]);

   services.gnome.gnome-browser-connector.enable = true; 
  
  ###SystemPackages###
  # List packages installed in system profile. To search, run:
  # $ nix search wget
    environment.systemPackages = with pkgs; [
    # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
     ##################################
     # -> SYSTEM PACKAGES <- #
     ##############################
     # TEST 
     pkgs.python312Packages.flask
     pkgs.python312Packages.sh
     pkgs.python312Packages.flask-sock
     pkgs.traefik
     pkgs.authelia
     pkgs.yai
     pkgs.fzf
     pkgs.snapcast
     pkgs.python312Packages.pyfzf
     pkgs.unbound
     pkgs.python312Packages.snapcast
     pkgs.python312Packages.pyarr
     pkgs.airscan
     pkgs.passExtensions.pass-import
     pkgs.passExtensions.pass-otp
     pkgs.passff-host
     
     # GNOME # 
     pkgs.gnomecast
     pkgs.gnome.gnome-software
     pkgs.gnome.gnome-system-monitor
     pkgs.gnome.gnome-themes-extra
     pkgs.gnome.gnome-shell-extensions
     pkgs.gnome.gnome-shell
     pkgs.gnome.gnome-tweaks
     gnome.gnome-terminal
     pkgs.gnome-menus
     pkgs.gnomeExtensions.duckduckgo-search-provider
     # pkgs.gnome.nixos-gsettings-overrides
    
     # GNOME THEME 
     pkgs.gnome-extension-manager
     pkgs.gnomeExtensions.dashbar
     pkgs.gnome-extensions-cli
     pkgs.gnomeExtensions.task-up
     pkgs.gnomeExtensions.logo-widget
     pkgs.gnomeExtensions.emoji-copy
     pkgs.gnomeExtensions.todotxt
     pkgs.gnomeExtensions.space-bar
     pkgs.gnomeExtensions.extensions-sync
     pkgs.gnomeExtensions.appindicator 

     # CONVERTERS
     # dconf2nix # dconf2nix -i dconf.settings -o output/dconf.nix
     pkgs.dconf2nix
     # pkgs.nix2nix - Generate nix expressions from mix.lock file.	    
     # stack2nix - Convert stack.yaml files into Nix build instructions.
     # pkgs.stack2nix
     # MONITOR / SCREEN BRIGHTNESS
     pkgs.acpilight  
     
    ## Voice
    # pkgs.python312Packages.wyoming
     pkgs.wyoming-satellite
     pkgs.wyoming-faster-whisper
     #pkgs.wyoming-openwakeword
     #pkgs.wyoming-openwakeword
     #pkgs.wyoming-piper
     #pkgs.piper-train
     pkgs.piper-tts
     
     # Yubikey
     libykclient
     yubikey-agent
     yubico-piv-tool
     age-plugin-yubikey
     yubikey-personalization-gui
     yubikey-personalization
      
      
      # VM
      pkgs.virtualbox
      
      #  AI
      pkgs.local-ai
      pkgs.chatd
      pkgs.aichat
      pkgs.ollama
      
     # Firefox  
     pkgs.fx-cast-bridge
     
     ffmpeg_7-full
     pkgs.portaudio
     xmrig-mo

     # ROCm
     pkgs.rocmPackages.llvm.bintools
     pkgs.rocmPackages.llvm.clang-tools-extra
     # Docker & VM's
     pkgs.docker-distribution 
     pkgs.distrobox
     pkgs.arion
     # docker-compose
     docker_27
     pass
     pkgs.android-tools 
     pkgs.ubootTools 
     
     # DEV
     pkgs.python312Packages.torch
     pkgs.python312Packages.torchaudio
     # 
     # NEJ! # pkgs.python312Packages.torchWithRocm 
     pkgs.python312Packages.diffusers # AI music & image
     pkgs.python312Packages.transformers # AI
     #  python chromecast
    pkgs.python312Packages.pychromecast
     # duck language scripting
     pkgs.duckscript
     python3
     python312Packages.pip
     python312Packages.mypy
     python312Packages.quart-cors
     pkgs.python312Packages.poyo
     pkgs.python312Packages.duckduckgo-search
     pkgs.python312Packages.websockets
     #pkgs.python312Packages.tensorflow
     #pkgs.python312Packages.tensorflow-probability
     pkgs.python312Packages.requests
     #python312Packages.tensorflow-datasets
     #pkgs.tensorflow-lite
     #pkgs.libtensorflow
     pkgs.npth
     pkgs.vcard
     pkgs.cmake
    #  webfont creator
     pkgs.webfontkitgenerator
     # Search DuckDuckGo from terminal
     pkgs.ddgr
     # Dynamic DNS client tool supports AliDNS, Cloudflare, Google Domains, DNSPod, HE.net & DuckDNS & DreamHost, etc
     pkgs.godns
     # Simple JavaScript Duckumentation generator
     pkgs.jsduck
     # Chromecast CLI
     pkgs.castnow
     # 
     
     vim
     zig
     wget
     dconf2nix
     killall
     neofetch
     git
     gh
     direnv
     wmctrl
    ];

   programs.mtr.enable = true;
	   programs.gnupg.agent = {
	     enable = true;
	     enableSSHSupport = true;
	   };



  #Firewall
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
    #For Chromecast from chrome
    #networking.firewall.allowedUDPPortRanges = [ { from = 32768; to = 60999; } ];
  # Or disable the firewall altogether.
   networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

}


