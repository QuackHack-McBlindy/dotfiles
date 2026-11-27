{
  config,
  pkgs,
  lib,
  ...
} @ args:
let
  dynamicConfig = import ./template.nix {
    inherit lib;
    user = builtins.getEnv "INSTALL_USER";
    host = builtins.getEnv "INSTALL_HOST";
    ssid = builtins.getEnv "INSTALL_SSID";
    wifipass = builtins.getEnv "INSTALL_WIFI_PASS";
    publickey = builtins.getEnv "INSTALL_PUBKEY";
  };
in {
  imports = [
    ./hardware-configuration.nix
    ./modules/gdm-logo.nix
    ./modules/gnome-background.nix
    ./modules/plymouth-logo.nix
    dynamicConfig
  ];

  nixpkgs.config.allowUnfree = true;
  boot.initrd.systemd.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  boot.extraModprobeConfig = "options kvm-intel nested=Y";

  hardware.cpu.intel.updateMicrocode = pkgs.stdenv.isx86_64;
  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;
  services.fwupd.enable = true;

  networking.firewall.logRefusedConnections = false;
  networking.networkmanager.enable = true;

  services.avahi = {
    enable = true;
    ipv4 = true;
    ipv6 = true;
    nssmdns4 = true;
    publish = { enable = true; domain = true; addresses = true; };
  };

  boot.tmp.cleanOnBoot = true;

  services.journald.extraConfig = ''
    SystemMaxUse=250M
    SystemMaxFileSize=50M
  '';

  nix = {
    optimise.automatic = true;
    gc.automatic = true;
    package = pkgs.nixVersions.unstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  environment.systemPackages = with pkgs; [
    git
    wget
    tmux
    unzip
    libvirt
    virt-manager
    gnome.gnome-boxes
  ];

  systemd.services."getty@tty1".enable = true;
  systemd.services."autovt@tty1".enable = true;
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = builtins.getEnv "INSTALL_USER";
  services.xserver = {
    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;
    enable = true;
    libinput.enable = true;
    layout = "se";
    xkbVariant = "";

  };
  console.keyMap = "sv-latin1";


  boot.plymouth.enable = true;

  customization = {
    gdm-logo.enable = true;
    gnome-background.enable = true;
    plymouth-logo.enable = true;
  };

  hardware.opengl = {
    # this fixes the "glXChooseVisual failed" bug,
    # https://github.com/NixOS/nixpkgs/issues/47932
    enable = true;
    driSupport32Bit = true;
  };

  security.sudo.wheelNeedsPassword = false;
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PubkeyAuthentication = true;
    };
  };
  users.mutableUsers = false;
  users.extraUsers.root.password = "*";

  virtualisation.libvirtd.enable = true;

}
