{ config, lib, pkgs, user, host, hostname, ... }:

let
  user = "pungkula";
  hostname = "homie";
in
{
  imports = [ ./hardware-configuration.nix ./../backup.nix

                      ./../../modules/networking/wg-server.nix
                      ./../../modules/networking/dns.nix
                      ./../../modules/nixos/cache.nix
                      ./../../modules/services/telegraf.nix
                      ./../../modules/services/homepage.nix
                      ./../../modules/services/systemd/voice-server.nix
                    #  ./../../modules/services/loki.nix
                      ./../../modules/services/mosquitto.nix
                      ./../../modules/services/zigbee2mqtt.nix
                      ./../../modules/virtualization/home-assistant.nix
                      ./../../modules/services/vaultwarden.nix
                      ./../../modules/services/openwakeword.nix
                      ./../../modules/services/faster-whisper.nix
                     # ./../../modules/services/ntfy.nix
                      ./../../modules/services/systemd/systemd-mnt.nix
                      ./../../modules/services/syncthing.nix
                      ./../../modules/services/avahi-client.nix
                      ./../../modules/security.nix
                      ./../../modules/services/ssh.nix
                      ./../../modules/services/syslogd.nix
                      ./../../modules/virtualization/docker.nix
               #       ./../../modules/virtualization/vm.nix
                      ./../../modules/nixos/packages.nix
                      ./../../modules/nixos/default-apps.nix
                      ./../../modules/nixos/users.nix
                      ./../../modules/nixos/nix.nix
                      ./../../modules/nixos/fonts/default.nix
                      ./../../modules/nixos/i18n.nix
                      ./../../modules/nixos/pipewire.nix
                      ./../../modules/programs/localsend.nix
                      ./../../modules/networking/default.nix
  ];

  networking.hostName = "homie";

  boot.initrd.systemd.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
 # system.stateVersion = "24.05"; # Did you read the comment?
}
