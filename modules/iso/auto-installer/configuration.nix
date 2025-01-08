{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/gdm-logo.nix
    ./modules/gnome-background.nix
    ./modules/plymouth-logo.nix
    ./modules/virtualization.nix
  ];

  nix = {
    package = pkgs.nixVersions.unstable;
    optimise.automatic = true;
    gc.automatic = true;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
  
  boot.initrd.systemd.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.tmp.cleanOnBoot = true;
  
  hardware.cpu.intel.updateMicrocode = pkgs.stdenv.isx86_64;
  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;
  services.fwupd.enable = true;
  
  boot.plymouth.enable = true;

  customization = {
    gdm-logo.enable = true;
    gnome-background.enable = true;
    plymouth-logo.enable = true;
  };


  services.journald.extraConfig = ''
    SystemMaxUse=250M
    SystemMaxFileSize=50M
  ''
  
  nixpkgs.config.allowUnfree = true;

  
  networking.hostName = "installer";


  networking.firewall.logRefusedConnections = false;
  networking.networkmanager.enable = true;

  services.avahi = {
    enable = true;
    ipv4 = true;
    ipv6 = true;
    nssmdns4 = true;
    publish = { enable = true; domain = true; addresses = true; };
  };

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    tmux
    unzip
  ];

  services.xserver = {
    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;
    enable = true;
    libinput.enable = true;
  };


  hardware.opengl = {
    # this fixes the "glXChooseVisual failed" bug,
    # context: https://github.com/NixOS/nixpkgs/issues/47932
    enable = true;
    driSupport32Bit = true;
  };

  security.sudo.wheelNeedsPassword = false;
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };
  users.mutableUsers = false;
  users.extraUsers.root.password = "nix";

  users.users.pungkula = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "kvm"
    ];
    initialPassword = "nix";
    openssh.authorizedKeys.keys = [
      "ssh-rsa x7qq8zRAH5jdxUduQ/ThAmvjYm91H42QVm70OCFjjb8dg9LIb/va2j1eakNlBiwCmUK7frmRkWjFj+2t5zCTd2iLpygLv7PvFVIidxAoXLdTxilAAg2ZlX/xSGvRPkaqX/ZQfR5j3OCVYy6aV4VonbIUids7kUynRz9SRN2AHmLpK/oniwlwhAS5aa0PvC8Ln7x3wzhH501sLKk+krNpOEr4E1AA/VwOMqSqU4KTMoYzkUix9YnnAf70AQV6rZ4NxNrqWcZve/UGqMxtUbxMP7rL8hxKihc0Zdus5zxDEZ36oXIDYq9kQ3KgJZx4aVPePEX68A8fxhx6zIOfsg0Hz6M3ko53MhG/qZhYmDvTG1548tgn24gQjEawRjUc2a6gEH+va+TP99260ELeWZD3AHzIzL+ln4BBGcYgNglkIxpI5gH7LqeQ+XHlW8iQbnlfRUYKo72MGA8KLDPP3IHhWa5cSN4DKBlgEJ8ijUbcYqES4dK34cqyM1JWVTnEdw== pungkula@desktop.com"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE6UXhj/qh1qSnHdAuPyOUr0OQyJ1QIy5QlZu3y7CaGV pungkula@desktop"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE6UXhj/qh1qSnHdAuPyOUr0OQyJ1QIy5QlZu3y7CaGV"       
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPwZL27kGTQDIlSe03abT9F24nSAizORyjo5cI3BD92s your_email@example.com"
    ];    
    
    
  };
}
