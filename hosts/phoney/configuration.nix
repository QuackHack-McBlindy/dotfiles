# -> PHONE <- #
{ config, pkgs, lib, inputs, modulesPath, ... }:

{
  imports = [ ./hardware-configuration

  ];

  # -> BOOT
    #boot.loader.systemd-boot.enable = true;
    #boot.loader.efi.canTouchEfiVariables = true;
  # ntfs support
   # boot.supportedFilesystems = [ "ntfs" ];
    
  # -> HARDWARE
  hardware.sensor.iio.enable = true;
  hardware.bluetooth.enable = true;
  mobile.boot.stage-1.firmware = [
    config.mobile.device.firmware
  ];
  hardware.firmware = [ config.mobile.device.firmware ];

  # -> USER
    users.users.${defaultUserName} = {
      isNormalUser = true;

      # TODO change me!
      #hashedPassword = "$6$zActsdzv754qmpNR$TVgNLHx4/0Q3GIqirequckS252LvYFomx11IimP8uuk.soV8CQFIUDcjhhF7lHz5BurJZJLj/QlGOHZTYAX8R1";

      home = "/home/pungkula";
      createHome = true;
      extraGroups = [
        "wheel"
        "networkmanager"
        "video"
        "feedbackd"
        "dialout" # required for modem access
      ];
      #uid = 1000;
      openssh.authorizedKeys.keys = [
        "ssh-rsa x7qq8zRAH5jdxUduQ/ThAmvjYm91H42QVm70OCFjjb8dg9LIb/va2j1eakNlBiwCmUK7frmRkWjFj+2t5zCTd2iLpygLv7PvFVIidxAoXLdTxilAAg2ZlX/xSGvRPkaqX/ZQfR5j3OCVYy6aV4VonbIUids7kUynRz9SRN2AHmLpK/oniwlwhAS5aa0PvC8Ln7x3wzhH501sLKk+krNpOEr4E1AA/VwOMqSqU4KTMoYzkUix9YnnAf70AQV6rZ4NxNrqWcZve/UGqMxtUbxMP7rL8hxKihc0Zdus5zxDEZ36oXIDYq9kQ3KgJZx4aVPePEX68A8fxhx6zIOfsg0Hz6M3ko53MhG/qZhYmDvTG1548tgn24gQjEawRjUc2a6gEH+va+TP99260ELeWZD3AHzIzL+ln4BBGcYgNglkIxpI5gH7LqeQ+XHlW8iQbnlfRUYKo72MGA8KLDPP3IHhWa5cSN4DKBlgEJ8ijUbcYqES4dK34cqyM1JWVTnEdw== pungkula@desktop.com"
      ];
    };

  # -> NETWORK
    networking.hostName = "phone";
    networking.networkmanager.enable = true; 

  # -> DESKTOP
  xserver.desktopManager.phosh = {
    enable = true;
    user = "pungkula";
    group = "users";
    # for better compatibility with x11 applications
    phocConfig.xwayland = "immediate";
  };
					  
  # -> SYSTEM <- #
  environment.systemPackages = [ 
    pkgs.phosh-mobile-settings
    pkgs.phosh
    #pkgs.jellyfin-mpv-shim
    #pkgs.vlc
    pkgs.megapixels
    pkgs.portfolio-filemanager
    #pkgs.notify-client
    #pkgs.home-assistant-component-tests.mobile_app
    #pkgs.modem-manager-gui
    #pkgs.firefox-mobile
    #pkgs.radicale2 #vcard caldav server
    
    # Gnome
    pkgs.gnome-control-center
					    
    # Camera
    pkgs.megapixels
                      
    # MMS
    pkgs.mmsd-tng

    # SMS
    pkgs.chatty 
  ]; 
					 
  # -> SERVICES <- #
  # Modem Firmware
  services.fwupd.enable = true;
  # Bluetooth
  #services.blueman.enable = true;
  # GPS
  services.geoclue2.enable = true;
  users.users.geoclue.extraGroups = [ "networkmanager" ];
  
  # -> PROGRAMS
  # Calls
  programs.calls.enable = true;
  # Optional but recommended. https://github.com/NixOS/nixpkgs/pull/162894
  systemd.services.ModemManager.serviceConfig.ExecStart = [
    "" # clear ExecStart from upstream unit file.
    "${pkgs.modemmanager}/sbin/ModemManager --test-quick-suspend-resume"
  ];
  
  # 
  
}  

