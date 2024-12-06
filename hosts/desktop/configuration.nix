#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°•──→ DESKTOP CONFIGURATION ←──•°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
{ config, pkgs, lib, inputs, modulesPath, ... }:
{
    imports = [
        ./hardware-configuration.nix
        ./../../modules/hardware/battery.nix
        ./../../modules/nixos/users.nix
        ./../../modules/services/voice.nix
  #      ./../../modules/services/pipewire.nix
    ];
 

 
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°•──→ BOOTLOADER ←──•°
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.initrd.kernelModules = [ "amdgpu" ]; # ROCm
    boot.kernelParams = [ "intel_pstate=active" ];
    boot.supportedFilesystems = [ "ntfs" ];

    networking.hostName = "desktop";
    networking.networkmanager.enable = true; 
    hardware.bluetooth.enable = true;  # Bluethooth
    services.blueman.enable = true;   # Bluethooth
    xdg.portal.config.common.default = "*";
    nix.optimise.automatic = true;
    nixpkgs.config.allowUnfree = true;
    nix = {
        package = pkgs.nixFlakes;
        extraOptions = ''
            experimental-features = nix-command flakes
        '';
    };
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°•──→ VIRTUALISATION ←──•°
    virtualisation = {
      docker = {
        enable = true;
        autoPrune = {
          enable = true;
          dates = "weekly";
        };
        rootless = {
          enable = true;
          setSocketVariable = true;
        };
        daemon = {
          settings = {
            data-root = "/docker";
          };
        };
      };
    };
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°•──→ FONTS ←──•°
    services.gollum.emoji = true; # emojis
    fonts.packages = with pkgs; [
      font-awesome
      noto-fonts-emoji
     (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" "Iosevka"  ]; })
    ];

#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°•──→ SNAPSERVER ←──•°

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
  
    security.rtkit.enable = true;
    hardware.pulseaudio.enable = false;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
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

#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°•──→ LOCALE / i18n ←──•°
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
 
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°•──→ XSERVER ←──•°
    services.xserver = {
        exportConfiguration = true; # link /usr/share/X11/ properly
        xkb.layout = "se";
        xkb.options = "eurosign:e";
    };

#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°•──→ SERVICES ←──•°
    services.pcscd.enable = true; # Yubikey Smart Card
    services.xserver.enable = true; # Enable the X11 windowing system.
    services.flatpak.enable = true;
    services.locate.enable = true;
    services.printing.enable = true;   # Enable CUPS to print documents.
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°•──→ GNOME ←──•°
    services.gnome.gnome-browser-connector.enable = true; 
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.displayManager.gdm.wayland = true;
    services.xserver.desktopManager.gnome.enable = true;
      environment.gnome.excludePackages = 
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°   
#°•──→ GNOME EXCLUDE ←──•°
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
    services.voice = {
      enable = true;
      appPath = "/home/pungkula/flake/home/.config/voice";
      secretKey = "your_secure_secret_key";
      host = "127.0.0.1";
      port = 43334;
    };
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#──→ SYSTEM PACKAGES ←──
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
    environment.systemPackages = with pkgs; [
      pkgs.home-manager
      pkgs.pcsclite
      pkgs.snapcast
      pkgs.nixos-anywhere
      pkgs.yubico-piv-tool
      pkgs.age-plugin-yubikey
      pkgs.pam_u2f
      pkgs.piv-agent
      pkgs.yubico-piv-tool
   #  pkgs.hidapi
      pkgs.atuin
      pkgs.pcsc-tools
      pkgs.acsccid
      pkgs.sops
    # pkgs.rocmPackages_5.rpp-opencl
    # pkgs.crackle # crack and decrypt BLE
    # pkgs.bruteforce-luks
      pkgs.python312Packages.scp
      pkgs.python312Packages.paramiko
      #pkgs.python312Packages.requests
      pkgs.angryipscanner
      pkgs.python312Packages.nmapthon2
      pkgs.rocmPackages_5.rocm-runtime
    # pkgs.python312Packages.iosbackup 
      pkgs.alpnpass 
    # pkgs.ifuse
    # pkgs.bark-server
    # pkgs.idb-companion
    # pkgs.ipatool
      pkgs.nmap
      pkgs.hashcat
      pkgs.rocmPackages_5.rpp-opencl
      pkgs.libfido2
      pkgs.liboqs

      pkgs.mount
      pkgs.sqlite
      pkgs.duckdb
      pkgs.nfs-utils
      pkgs.exiftool
      pkgs.qemu_kvm
      pkgs.glib # cross compiling
      pkgs.pkg-config # cross compiling
      pkgs.alsa-utils
      pkgs.clutter # Mobile UI Tool (SERVER)
      pkgs.python311Packages.aiovlc
      pkgs.ntfy-sh
      pkgs.maestro # Mobile UI Automation Tool

      pkgs.fzf
      pkgs.snapcast
      pkgs.unbound
      pkgs.airscan
      pkgs.gnome.gnome-software
      pkgs.gnome.gnome-system-monitor
      pkgs.gnome.gnome-themes-extra
      pkgs.gnome.gnome-shell-extensions
      pkgs.gnome.gnome-shell
      pkgs.gnome.gnome-tweaks
      gnome.gnome-terminal
      pkgs.gnome-menus
      pkgs.gnomeExtensions.duckduckgo-search-provider
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
      pkgs.dconf2nix # dconf2nix -i dconf.settings -o output/dconf.nix
      pkgs.acpilight  
      pkgs.wyoming-piper
      pkgs.wyoming-satellite
      pkgs.wyoming-faster-whisper
      libykclient
      yubikey-agent
      yubico-piv-tool
      pkgs.age
      pkgs.pcsclite
      pkgs.pcscliteWithPolkit
      pkgs.libacr38u 
      pkgs.virtualbox
      pkgs.ollama 
      pkgs.fx-cast-bridge
      ffmpeg_7-full
      pkgs.portaudio
      xmrig-mo
      pkgs.rocmPackages.llvm.bintools
      pkgs.rocmPackages.llvm.clang-tools-extra
      pkgs.buildkit
      pkgs.docker-distribution 
      pkgs.distrobox
      pkgs.arion
      docker_27
      pass 
      pkgs.caddy
      pkgs.xcaddy
      pkgs.cmake
      pkgs.webfontkitgenerator
      pkgs.ddgr
      pkgs.godns
      pkgs.jq
      pkgs.dotenvy
      pkgs.jsduck
      pkgs.castnow
      poetry
      vim
      zig
      wget
      dconf2nix
      killall
      neofetch
      git
      gh
      gcc
      gccStdenv
      direnv
      nix-direnv
      wmctrl
      rar
      pipewire
      pulseaudio
      pamixer
    ];
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
   programs.direnv.enable = true;
   programs.mtr.enable = true;
   programs.gnupg.agent = {
     enable = true;
     enableSSHSupport = true;
   };
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#──→ SECURITY ←──
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
   networking.firewall.enable = true;
   networking.firewall.allowedUDPPorts = [
     1704
     1705
     6001
     6002
   ];
#  networking.firewall.allowedTCPPorts = [
  
#  ];
  sops = {
    defaultSopsFile = "/var/lib/sops-nix/.sops.yaml";
    defaultSopsFormat = "yaml";
    validateSopsFiles = false;
    age.keyFile = "/var/lib/sops-nix/key.txt";
    secrets = {
      SHADOWSOCKS_PASSWORD = {
        sopsFile = "/var/lib/sops-nix/secrets/SHADOWSOCKS_PASSWORD.json"; # Specify SOPS-encrypted secret file
        owner = config.users.users.secretservice.name;
        group = config.users.groups.secretservice.name;
        mode = "0440"; # Read-only for owner and group
      };
      secretservice = {
        sopsFile = "/var/lib/sops-nix/secrets/secretservice.json"; # Specify SOPS-encrypted secret file
        owner = config.users.users.secretservice.name;
        group = config.users.groups.secretservice.name;
        mode = "0440"; # Read-only for owner and group
      };
    };
  };  
  systemd.services.secretservice = {
    script = ''
        echo "
        Hey bro! I'm a service, and imma send this secure password:
        $(cat ${config.sops.secrets.secretservice.path})
        located in:
        ${config.sops.secrets.secretservice.path}
        to database and hack the mainframe
        " > /var/lib/secretservice/testfile
    '';
    serviceConfig = {
      User = "secretservice";
      WorkingDirectory = "/var/lib/secretservice";
    };
  };
  users.users.secretservice = {
    home = "/var/lib/secretservice";
    createHome = true;
    isSystemUser = true;
    group = "secretservice";
  };
  users.groups.secretservice = { };

  security.pam.u2f = {
    enable = true;
#    interactive = false; # Prompts for Enter
    cue = true; # Prompts for Touch
  };
  
  security.pam.services = {
    login.u2fAuth = true;
    sudo.u2fAuth = true;
  };

  security.pam.yubico = {
     enable = true;
     debug = true;
     mode = "challenge-response";  
     id = [ "16644366" ];
  };

  services.udev.extraRules = ''
    ACTION=="remove",\
    ENV{ID_BUS}=="usb",\
    ENV{ID_MODEL_ID}=="0407",\
    ENV{ID_VENDOR_ID}=="1050",\
    ENV{ID_VENDOR}=="Yubico",\
    RUN+="${pkgs.systemd}/bin/loginctl lock-sessions"
 '';
 
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#──→ CROSS ENV ←──
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
  # Ensure these packages are available in the PATH
  nixpkgs.config.packageOverrides = pkgs: {
    myCrossEnv = pkgs.stdenv.mkDerivation {
      name = "my-cross-env";
      buildInputs = [
        pkgs.glib
        pkgs.pkg-config
        pkgs.cmake
      ];
    };
  };
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#──→ VERSION ←──
  system.stateVersion = "22.11"; 
  #system.stateVersion = "24.05";  
}

