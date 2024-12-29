#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°•──→ DESKTOP CONFIGURATION ←──•°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
{ config, dotfiles, mods, pkgs, lib, inputs, modulesPath, ... }:


let
  # Example: We can use the hostname value to define another variable
  hostname = config.networking.hostName;
in

{
    imports = [
        ./hardware-configuration.nix

    ];  
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°•──→ BOOT ←──•°
    boot = {
        loader.systemd-boot.enable = true;
        loader.efi.canTouchEfiVariables = true;
        initrd.kernelModules = [ "amdgpu" ]; # ROCm
        kernelParams = [ "intel_pstate=active" ];
        supportedFilesystems = [ "ntfs" ];
    };
    environment.variables.HOSTNAME = hostname; 
    networking = { 
        hosts = {
           # "127.0.0.1" = [ "foo.bar.baz" ];
            "192.168.1.1" = [ "archer.lan" "archer.local" "archer" ];
            "192.168.1.111" = [ "desktop.lan" "desktop.local" "desktop" ];
            "192.168.1.122" = [ "lappy.lan" "lappy.local" "lappy" ];
            "192.168.1.28" = [ "nasty.lan" "nasty.local" "nasty" ];
            "192.168.1.44" = [ "iphone.lan" "iphone.local" "iphone" ];
            "192.168.1.45" = [ "phone.lan" "phone.local" "phone" ];
            "192.168.1.150" = [ "usb.lan" "usb.local" "usb" ];
            "192.168.1.155" = [ "arris.lan" "arris.local" "arris" ];
            "192.168.1.159" = [ "pi.lan" "pi.local" "pi" ];
            "192.168.1.181" = [ "ha.lan" "ha.local" "ha" ];
            "192.168.1.223" = [ "shield.lan" "shield.local" "shield" ];
        };   
        hostName = "desktop";
        networkmanager.enable = true; 
        firewall = {
            enable = true;
            allowedUDPPorts = [ 1704 1705 6001 6002 ];
            allowedTCPPorts = [ ];
        };
    };    
    
    xdg.portal.config.common.default = "*";
    services.flatpak.enable = true;
    
    users.users.pungkula.group = "pungkula";
    users.groups.pungkula = {};    
    
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°•──→ XSERVER ←──•°
    services.libinput.enable = true;
    services.xserver = {
        enable = true;  # Enable the X11 windowing system.
        exportConfiguration = true; # link /usr/share/X11/ properly
        videoDrivers = [ "amdgpu" ];
        xkb.layout = "se";
        xkb.options = "eurosign:e";
        displayManager = {
           gdm.enable = true;
           gdm.wayland = true;
          # autoLogin = {
          #     enable = true;
          #     user = "pungkula";
          # };
        };
        desktopManager = {
            gnome.enable = true;
        };     
    };
  #systemd.services."getty@tty1".enable = false;
  #systemd.services."autovt@tty1".enable = false;
  

#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°   
#°•──→ XSERVER EXCLUDE ←──•°
#    services.excludePackages = with pkgs; [
 #       xterm
#    ];      
       
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°•──→ GNOME ←──•°   
    services.udev.packages = [ pkgs.gnome-settings-daemon ];
    services.dbus.packages = with pkgs; [ gnome2.GConf ];
    services.gnome = {
        gnome-browser-connector.enable = true; 
        at-spi2-core.enable = true; # Required for orca
    };    
    environment.gnome.excludePackages = 
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°   
#°•──→ GNOME EXCLUDE ←──•°
      (with pkgs; [
        gnome-photos
        gnome-tour
        gnome-maps
        gnome-weather
        gnome-clocks
      ]) ++ (with pkgs.gnome; [
        pkgs.cheese # webcam tool
        pkgs.gnome-music
        pkgs.file-roller
        pkgs.gedit # text editor
        pkgs.epiphany # web browser
        pkgs.geary # email reader
        pkgs.evince # document viewer
        pkgs.gnome-characters
        pkgs.totem # video player
        pkgs.tali # poker game
        pkgs.iagno # go game
        pkgs.hitori # sudoku game
        pkgs.rygel
        pkgs.yelp
        pkgs.gnome-clocks
        pkgs.gnome-contacts
      ]);      
      
      

#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#──→ SYSTEM PACKAGES ←──
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
    environment.systemPackages = with pkgs; [
  # CLI Util
      pkgs.python312Packages.dbus-python
      pkgs.nixos-facter
      pkgs.mono5
      pkgs.font-awesome
      pkgs.disko
      pkgs.python312Packages.langid
      pkgs.python312Packages.langdetect
      pkgs.mpg123
      pkgs.ventoy-full
      pkgs.cryptsetup
      pkgs.transmission_4-qt
      pkgs.wireguard-tools
      pkgs.dotbot
      pkgs.speedtest-cli
      pkgs.busybox
      pkgs.dig
      pkgs.usbutils
      pkgs.nixos-generators
      pkgs.tridactyl-native
  # Screenreader   
      pkgs.orca
      pkgs.speechd
      pkgs.piper-tts
      
      pkgs.gtk2
      pkgs.gtk3
      pkgs.gtk4
  
  # Gnome
      pkgs.gnome-shell
      pkgs.gnome-tweaks
      pkgs.mousetweaks 		# mouse accessibility
      pkgs.gnome-software
      pkgs.gnome-system-monitor
      pkgs.gnome-themes-extra
      pkgs.gnome-shell-extensions
      pkgs.gnome-menus        
      pkgs.gnomeExtensions.wireguard-vpn-extension
      pkgs.gnomeExtensions.open-bar
      pkgs.gnomeExtensions.duckduckgo-search-provider
      pkgs.gnome-extension-manager
      pkgs.gnomeExtensions.dashbar
      pkgs.gnome-extensions-cli
      pkgs.gnomeExtensions.task-up
      pkgs.gnomeExtensions.emoji-copy
      pkgs.gnomeExtensions.todotxt
      pkgs.gnomeExtensions.space-bar
      pkgs.gnomeExtensions.vitals
      pkgs.gnomeExtensions.appindicator 
      pkgs.gnomeExtensions.systemd-manager
      pkgs.dconf2nix # dconf2nix -i dconf.settings -o output/dconf.nix
      pkgs.dconf-editor
      pkgs.dconf
      pkgs.glib
      pkgs.gsettings-desktop-schemas

      pkgs.libnotify	# notify-send	
      pkgs.dunst 	# notificatins
      pkgs.wl-clipboard # wayland clipboard
      pkgs.xdotool	# fake keyboard/mouse input
      pkgs.wlogout	# sway
      pkgs.swayidle	# sway
      pkgs.swaylock-fancy # sway
      pkgs.dbus
      pkgs.python312Packages.pydbus
      pkgs.mako		# notifications
      pkgs.python312Packages.pygobject3
      pkgs.meson	# builder dep
      pkgs.home-manager
      pkgs.pcsclite
      pkgs.nixos-anywhere
      pkgs.python312Packages.scp
      pkgs.python312Packages.paramiko
      pkgs.angryipscanner
      pkgs.python312Packages.nmapthon2
      pkgs.rocmPackages_5.rocm-runtime
      pkgs.alpnpass 
      pkgs.nmap
      pkgs.hashcat
      pkgs.rocmPackages_5.rpp-opencl
      pkgs.libfido2
      pkgs.liboqs
      pkgs.mount
      pkgs.sqlite
      pkgs.nfs-utils
      pkgs.exiftool
      pkgs.qemu_kvm
      pkgs.glib # cross compiling
      pkgs.pkg-config # cross compiling
      pkgs.alsa-utils
      pkgs.clutter # Mobile UI Tool (SERVER)
      pkgs.ntfy-sh
      pkgs.maestro # Mobile UI Automation Tool
      pkgs.unbound
      pkgs.airscan
      pkgs.acpilight      
      pkgs.libacr38u 
      pkgs.virtualbox
      ffmpeg_7-full
      pkgs.portaudio
      xmrig-mo
      pkgs.rocmPackages.llvm.bintools
      pkgs.rocmPackages.llvm.clang-tools-extra
      pkgs.buildkit
      pkgs.docker-distribution 
      pkgs.distrobox
      docker_27
      pkgs.caddy
      pkgs.xcaddy
      pkgs.cmake   # builder dep
      pkgs.godns
      pkgs.dotenvy
 #     pkgs.jsduck
      poetry
      vim
      zig
      killall
      neofetch
      gh
      gcc
      gccStdenv
      wmctrl
      rar
      pipewire
      pulseaudio
      pamixer
      pkgs.nautilus
      pkgs.nautilus-python
    ];
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#──→ SECURITY ←──
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°       
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
#──→ VERSION ←── # 
  system.stateVersion = "22.11"; 
}

