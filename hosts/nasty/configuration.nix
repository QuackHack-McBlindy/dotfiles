{ config, lib, pkgs, user, host, hostname, ... }:

{
    impor= [  ./../../../modules/hardware/mergerfs.nix
        ./modules/networking/default.nix 
        ./modules/services/fail2ban.nix   
        ./modules/nixos/users.nix
        ./modules/nixos/nix.nix
        ./modules/nixos/fonts/default.nix
        ./modules/nixos/i18n.nix   
        ./modules/security.nix
        ./modules/services/ssh.nix
        ./modules/services/syslog.nix
    ];

#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ BOOT LOADER ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°

 # boot.loader.systemd-boot.enable = true;
 # boot.loader.efi.canTouchEfiVariables = true;

  fileSystems."/pool" = { 
    fsType = "fuse.mergerfs";
    device = "/mnt/disks/*";  # Throw it all in the Pool
    options = ["cache.files=partial" "dropcacheonclose=true" "category.create=mfs"];
  };    
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ XSERVER ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°

 # services.xserver = {
 #   enable = true;
 #   displayManager.gdm.enable = true;
 #   desktopManager.gnome.enable = true;
 #   layout = "se";
 #   xkbVariant = "";
 #   # Enable automatic login for the user.
 #   displayManager.autoLogin.enable = true;
 #   displayManager.autoLogin.user = "pungkula";
 # };

  # Configure console keymap
  console.keyMap = "sv-latin1";

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


      
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
