{ config, lib, pkgs-mobile, ... }:

let
  hostName = "pinephone";
  user = "pungkula";
  passwd = "$y$j9T$Sd5Hu.x6Io8RbOhyV6vva.$8TCUZZphtmEXqfubohFW4hVnQR5z8rcOoK2WUUp9PO.";
  pubkey = import ./../pubkeys.nix;
  terminal = pkgs-mobile.kgx.override { genericBranding = true; };
in

{
  imports = [
  
  ];

  config = {
    users.users.${user} = {
      isNormalUser = true;
      hashedPassword = passwd;     
      home = "/home/${user}";
      createHome = true;
      extraGroups = [
        "wheel"
        "networkmanager"
        "video"
        "feedbackd"
        "dialout"
      ];
      uid = 1000;
      openssh.authorizedKeys.keys = [
        pubkey.desktop
        pubkey.laptop
      ];
    };

    users.users.root.hashedPassword = passwd;

    # "desktop" environment configuration
    powerManagement.enable = true;
    hardware.opengl.enable = true;

    systemd.defaultUnit = "graphical.target";
    systemd.services.phosh = {
      wantedBy = [ "graphical.target" ];
      serviceConfig = {
        ExecStart = "${pkgs-mobile.phosh}/bin/phosh";
        User = 1000;
        PAMName = "login";
        WorkingDirectory = "~";

        TTYPath = "/dev/tty7";
        TTYReset = "yes";
        TTYVHangup = "yes";
        TTYVTDisallocate = "yes";

        StandardInput = "tty-fail";
        StandardOutput = "journal";
        StandardError = "journal";

        UtmpIdentifier = "tty7";
        UtmpMode = "user";

        Restart = "always";
      };
    };

    services.xserver.desktopManager.gnome.enable = true;

    # unpatched gnome-initial-setup is partially broken in small screens
    #services.gnome.gnome-initial-setup.enable = false;

    programs.phosh.enable = true;
    environment.gnome.excludePackages = with pkgs-mobile.gnome3; [
      gnome-terminal
    ];
    environment.systemPackages = with pkgs-mobile; [
      git
      pipes
      terminal
      wget
    ];

    environment.etc."machine-info".text = lib.mkDefault ''
      CHASSIS="handset"
    '';

    ##########################################################################
    ## networking, modem and misc.
    ##########################################################################

    networking = {
      inherit hostName;

      wireless.enable = false;
      networkmanager.enable = true;

      # FIXME : configure usb rndis through networkmanager in the future.
      # Currently this relies on stage-1 having configured it.
      networkmanager.unmanaged = [ "rndis0" "usb0" ];
    };

    # Setup USB gadget networking in initrd...
    mobile.boot.stage-1.networking.enable = lib.mkDefault true;

    # Bluetooth
    hardware.bluetooth.enable = true;

    ##########################################################################
    ## SSH
    ##########################################################################

    services.openssh = {
      enable = true;
      passwordAuthentication = false;
      permitRootLogin = "no";
      allowSFTP = false;
    };

    programs.mosh.enable = true;

    # Don't start it in stage-1 though.
    # (Currently doesn't quit on switch root)
    # mobile.boot.stage-1.ssh.enable = true;

    ##########################################################################
    # default quirks
    ##########################################################################

    # Ensures this demo rootfs is useable for platforms requiring FBIOPAN_DISPLAY.
    mobile.quirks.fb-refresher.enable = true;

    # Okay, systemd-udev-settle times out... no idea why yet...
    # Though, it seems fine to simply disable it.
    # FIXME : figure out why systemd-udev-settle doesn't work.
    systemd.services.systemd-udev-settle.enable = false;

    # Force userdata for the target partition. It is assumed it will not
    # fit in the `system` partition.
    mobile.system.android.system_partition_destination = "userdata";

    ##########################################################################
    ## misc "system"
    ##########################################################################

    # No mutable users. This requires us to set passwords with hashedPassword.
    users.mutableUsers = false;

    nix = {
      gc = {
        automatic = true;
        options = "--delete-older-than 8d";
      };

      # nix flakes
      package = pkgs-mobile.nixUnstable;
      extraOptions = ''
        experimental-features = nix-command flakes
      '';
    };

    # This value determines the NixOS release with which your system is to be
    # compatible, in order to avoid breaking some software such as database
    # servers. You should change this only after NixOS release notes say you
    # should.
    system.stateVersion = "21.11"; # Did you read the comment?

  };
}
