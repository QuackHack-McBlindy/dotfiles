{ config, lib, pkgs, user, host, hostname, ... }: {
  
  imports = [ ./hardware-configuration.nix 


                      ./../../modules/services/syncthing.nix
                      ./../../modules/nixos/packages.nix
                      ./../../modules/services/avahi-client.nix
                    #  ./../../modules/networking/default.nix 
                    #  ./../../modules/services/dns.nix 
                      ./../../modules/services/fail2ban.nix   
                      ./../../modules/nixos/users.nix
                      ./../../modules/nixos/nix.nix
                      ./../../modules/nixos/fonts/default.nix
                      ./../../modules/nixos/i18n.nix
                      ./../../modules/nixos/pipewire.nix     
                      ./../../modules/security.nix
                      ./../../modules/services/ssh.nix
                      ./../../modules/services/syslog.nix
                 #     ./../../modules/networking/samba.nix
                      ./../../modules/programs/thunar.nix
                      ./../../modules/nixos/gnome-background.nix
                      ./../../modules/nixos/default-apps.nix
                      ./../../modules/networking/iwd.nix
                      ./../../modules/networking/default.nix 
  ];

#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ BOOT LOADER ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
  boot.initrd.systemd.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.tmp.cleanOnBoot = true;
  
  hardware.cpu.intel.updateMicrocode = pkgs.stdenv.isx86_64;
  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;
  services.fwupd.enable = true;
  
  networking.hostName = "laptop";

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

  console.keyMap = "sv-latin1";


  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;



#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ GNOME ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•° 

    services.udev.packages = [ pkgs.gnome-settings-daemon ];
   # services.dbus.packages = with pkgs; [ gnome2.GConf ];
    services.gnome = {
   #     gnome-browser-connector.enable = true; 
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
