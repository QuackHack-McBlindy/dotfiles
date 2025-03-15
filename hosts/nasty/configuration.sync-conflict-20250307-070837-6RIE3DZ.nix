{ config, lib, pkgs, user, host, hostname, ... }:
let
  user = "pungkula";
  hostname = "nasty";
in
{
  imports = [ ./hardware-configuration.nix


                     # ./../../modules/services/satellite.nix
                      ./../../modules/services/openwakeword.nix
                      ./../../modules/networking/caddy2.nix
                      ./../../modules/networking/stubby.nix
                      ./../../modules/nixos/packages.nix
                      ./../../modules/services/avahi-client.nix
                    #  ./../../modules/services/dns.nix
                      ./../../modules/services/fail2ban.nix
                      ./../../modules/nixos/users.nix
                      ./../../modules/nixos/nix.nix
                      ./../../modules/nixos/fonts/default.nix
                      ./../../modules/nixos/i18n.nix
                      ./../../modules/nixos/pipewire.nix
                      ./../../modules/security.nix
                      ./../../modules/services/ssh.nix
                      ./../../modules/networking/default.nix
                      ./../../modules/nixos/default-apps.nix
                      ./../../modules/virtualization/duck-tv.nix
                      ./../../modules/virtualization/arr.nix
                      ./../../modules/virtualization/gluetun.nix
                      ./../../modules/virtualization/docker.nix
                  #    ./../../modules/virtualization/vm.nix

  ];

#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ BOOT LOADER ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

#  boot.loader.systemd-boot.enable = true;
#  boot.loader.efi.canTouchEfiVariables = true;
#  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  networking.hostName = "nasty";

  networking.firewall.allowedTCPPorts = [ 2049 ];
  networking.firewall.allowedUDPPorts = [ 2049 ];

  services.nfs.server = {
    enable = true;
    exports = ''
      /Pool  *(rw,fsid=0,no_subtree_check)
    '';
  };



  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
