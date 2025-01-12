# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, user, host, hostname, ... }:

{
  imports = [ ./hardware-configuration.nix
  
  ];

#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ BOOT LOADER ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ NETWORKING ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°

 # networking.hostName = "desktop"; 
    #  hosts = {
        #  "192.168.1.1" = [ "archer.lan" "archer.local" "archer" ];
        #  "192.168.1.111" = [ "desktop.lan" "desktop.local" "desktop" ];
        #  "192.168.1.222" = [ "laptop.lan" "laptop.local" "laptop" ];
        #  "192.168.1.28" = [ "nasty.lan" "nasty.local" "nasty" ];
       #   "192.168.1.44" = [ "iphone.lan" "iphone.local" "iphone" ];
       #   "192.168.1.45" = [ "phone.lan" "phone.local" "phone" ];
       #   "192.168.1.150" = [ "usb.lan" "usb.local" "usb" ];
        #  "192.168.1.155" = [ "arris.lan" "arris.local" "arris" ];
       #   "192.168.1.159" = [ "pi.lan" "pi.local" "pi" ];
        #  "192.168.1.181" = [ "ha.lan" "ha.local" "ha" ];
       #   "192.168.1.99" = [ "sovrum.lan" "sovrum.local" "sovrum" ];
       #   "192.168.1.100" = [ "shield.lan" "shield.local" "shield" ];
       #   "192.168.1.11" = [ "sw1.lan" "sw1.local" "sw1" ];
       #   "192.168.1.12" = [ "sw2.lan" "sw2.local" "sw2" ];
          
     # };   
  #    hostName = "desktop";
  #    networkmanager.enable = true; 
  #    firewall = {
   #       enable = true;
    #      logRefusedConnections = true;
                          #      
    #      allowedUDPPorts = [ ];
                          #              
    #      allowedTCPPorts = [ ];
   #   };
#  };    
    
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ XSERVER ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°

  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    layout = "se";
    xkbVariant = "";
    # Enable automatic login for the user.
    displayManager.autoLogin.enable = true;
    displayManager.autoLogin.user = "pungkula";
  };

  # Configure console keymap
  console.keyMap = "sv-latin1";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;


#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ SYSTEM PACKAGES ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
  environment.systemPackages = with pkgs; [   
   # Dev
    python3Full
    python312Packages.requests
    python312Packages.invoke
    python312Packages.langid
        
    rsync    
    libnotify
    alsa-utils   
    nixos-facter
    dig
    nmap
    #toybox # FIXME unable to use env -c when toybox installed
    busybox
    catimg # ascii art from img
    ncurses
    dialog
    vim
    wget
    curl
    git
    unzip
    libgedit-tepl
    gedit

# GTK
    pkgs.gtk2
    pkgs.gtk3
    pkgs.gtk4
  
  # Gnome
    dconf-editor
    pkgs.gnome-shell
    pkgs.gnome-system-monitor 
    gnomeExtensions.gsconnect
    pkgs.gnomeExtensions.docker
    pkgs.gnomeExtensions.wireguard-vpn-extension
    pkgs.gnomeExtensions.gsconnect
    pkgs.gnomeExtensions.open-bar
   # pkgs.gnomeExtensions.duckduckgo-search-provider
   # pkgs.gnome-extension-manager
    pkgs.gnomeExtensions.dashbar
   # pkgs.gnome-extensions-cli
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
    pkgs.nautilus
    
    
    rage
    # Yubikey
    age-plugin-yubikey
    yubioath-flutter
    yubikey-agent
    yubikey-manager-qt
    yubikey-touch-detector
    yubikey-personalization-gui
    yubikey-personalization    
    yubikey-manager 
    pam_u2f
    libu2f-host
    libykclient
    yubico-pam
    yubico-piv-tool
    piv-agent
    pcsclite
    pcscliteWithPolkit
    pcsc-tools
    acsccid    

  ];

  # Yubi
  # smart card mode (CCID) for gpg keys
  services.pcscd.enable = true;

#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ GNOME ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•° 

    services.udev.packages = [ pkgs.gnome-settings-daemon ];
 #   services.dbus.packages = with pkgs; [ gnome2.GConf ];
    services.gnome = {
  #      gnome-browser-connector.enable = true; 
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
        pkgs.epiphany # web browser
        pkgs.geary # email reader
        pkgs.evince # document viewer
        pkgs.gnome-characters
        pkgs.gnome-font-viewer
        pkgs.gnome-disk-utility
        pkgs.totem # video player
        pkgs.tali # poker game
        pkgs.iagno # go game
        pkgs.hitori # sudoku game
        pkgs.rygel
        pkgs.yelp
        pkgs.gnome-clocks
        pkgs.gnome-contacts
      ]);      
      
      


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
