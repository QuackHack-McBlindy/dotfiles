{ config, lib, pkgs, user, host, hostname, ... }: {
  
  imports = [ ./hardware-configuration.nix 
                     
                      "/home/pungkula/dotfiles/modules/nixos/packages.nix"
                      #./../../modules/nixos/packages.nix
                      ./../../modules/services/avahi-client.nix
                      ./../../modules/networking/default.nix 
                      ./../../modules/services/dns.nix 
                      ./../../modules/services/fail2ban.nix   
                      ./../../modules/nixos/users.nix
                      ./../../modules/nixos/nix.nix
                      ./../../modules/nixos/fonts/default.nix
                      ./../../modules/nixos/i18n.nix
                      ./../../modules/nixos/pipewire.nix     
                      ./../../modules/security.nix
                      ./../../modules/services/ssh.nix
                      ./../../modules/services/syslog.nix
                      ./../../modules/networking/samba.nix
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
  
  networking.hostName = "nixos";

   
     
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}

