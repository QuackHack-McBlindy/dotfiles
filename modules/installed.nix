{ 
  config,
  pkgs,
  lib,
  modulesPath,
  ...
} : let
  username = "nix";
  password = "*"; # no ppassword
  repoDir = "/home/${username}/dotfiles"
  repoUrl = "https://github.com/QuackHack-McBlindy/dotfiles"
  publicKey = "";
in {
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  nixpkgs.config.allowUnfree = true;
  
  networking.hostName = username;

  boot.initrd.systemd.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.firewall.logRefusedConnections = false;
  networking.networkmanager.enable = true;

  hardware.cpu.intel.updateMicrocode = pkgs.stdenv.isx86_64;
  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;
  services.fwupd.enable = true;

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };


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

#  boot.plymouth.enable = true;

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
  users.extraUsers.root.password = password;

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "kvm"
    ];
    initialPassword = password;
  };
  
  
  systemd.services.dotfiles-setup = {
    enable = true;
    description = "Clone and update dotfiles repository";    
    # Start after network is available
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    
    serviceConfig = {
      Type = "oneshot";
      User = username;  
      Group = username; 
      WorkingDirectory = "/home/${username}";
      ExecStart = pkgs.writeScript "dotfiles-setup" ''
        #!${pkgs.bash}/bin/bash
        set -euo pipefail

        REPO_DIR="${repoDir}"
        REPO_URL="${repoUrl}"

        # Clone or update repository
        if [ -d "$REPO_DIR/.git" ]; then
          echo "Updating existing repository..."
          git -C "$REPO_DIR" pull
        else
          echo "Cloning repository..."
          git clone "$REPO_URL" "$REPO_DIR"
        fi

        # Change directory and print message
        cd "$REPO_DIR"
        echo "hello world"
      '';
    };
    
    # Make this service part of the default target
    wantedBy = [ "multi-user.target" ];
  };


  hardware.enableAllFirmware = true;

  boot.loader.systemd-boot.enable = true;

  boot.initrd.kernelModules = [
    "kvm-intel"
    "virtio_balloon"
    "virtio_console"
    "virtio_rng"
  ];

  boot.extraModulePackages = [
    config.boot.kernelPackages.broadcom_sta
  ];

  boot.initrd.availableKernelModules = [
    "9p"
    "9pnet_virtio"
    "ata_piix"
    "nvme"
    "sr_mod"
    "uhci_hcd"
    "virtio_blk"
    "virtio_mmio"
    "virtio_net"
    "virtio_pci"
    "virtio_scsi"
    "xhci_pci"
  ];

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  swapDevices = [{ device = "/dev/disk/by-label/swap"; }];

  networking.useDHCP = lib.mkDefault true;
}
 

