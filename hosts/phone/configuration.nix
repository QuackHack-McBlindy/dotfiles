defaultUserName:
{ config, lib, pkgs, ... }:

let
  hostName = "pinephone";
  terminal = pkgs.kgx.override { genericBranding = true; };
in

{
  imports = [
  ];

  config = {

    # numeric password is currently required to unlock a session
    # with the plasma mobile shell
    users.users.${defaultUserName} = {
      isNormalUser = true;

      # TODO change me!
      hashedPassword = "$6$zActsdzv754qmpNR$TVgNLHx4/0Q3GIqirequckS252LvYFomx11IimP8uuk.soV8CQFIUDcjhhF7lHz5BurJZJLj/QlGOHZTYAX8R1";

      home = "/home/${defaultUserName}";
      createHome = true;
      extraGroups = [
        "wheel"
        "networkmanager"
        "video"
        "feedbackd"
        "dialout" # required for modem access
      ];
      uid = 1000;
      openssh.authorizedKeys.keys = [
        # TODO add keys
      ];
    };

    # TODO change me!
    users.users.root.hashedPassword = "$6$Jv0Cl55I5TN$BAwcCxOv7Yvy3z369jwFU7/x.TfUOCEvM6FVxsQOPWJEFgKYhZvsgDmvF3gb8dgOAntHvYHR8QF0obpezLx3v1";

    # "desktop" environment configuration
    powerManagement.enable = true;
    hardware.opengl.enable = true;

    systemd.defaultUnit = "graphical.target";
    systemd.services.phosh = {
      wantedBy = [ "graphical.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.phosh}/bin/phosh";
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
    services.gnome.gnome-initial-setup.enable = false;

    programs.phosh.enable = true;
    environment.gnome.excludePackages = with pkgs.gnome3; [
      gnome-terminal
    ];
    environment.systemPackages = with pkgs; [
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
      package = pkgs.nixUnstable;
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
