{ config, lib, pkgs, user, host, hostname, ... }:
let
  user = "pungkula";
  hostname = "desktop";
in
{
  imports = [ ./hardware-configuration.nix
                      ./../../modules/services/home-assistant/home-assistant.nix
                     # ./modules/home-assistant/database.nix
                    #  ./modules/home-assistant/media2.nix
                      ./../../modules/services/mosquitto.nix
                      ./../../modules/services/zigbee2mqtt.nix
            #          ./../../modules/virtualization/home-assistant.nix
                      
                     # ./../../modules/networking/adguard.nix
                      
                 #     ./../../modules/services/promtail-server.nix
                      ./../../modules/networking/stubby.nix
                      ./../../modules/networking/caddy/caddy.nix
                      ./../../modules/networking/caddy.nix
                   #   ./../../modules/services/nginx/default.nix
                      ./../../modules/hardware/pam.nix
                      ./../../modules/nixos/cross-env.nix
                      ./../../modules/nixos/packages.nix
                      ./../../modules/nixos/gnome.nix
                      ./../../modules/nixos/xserver.nix
                      ./../../modules/services/avahi-client.nix
                      ./../../modules/services/dns.nix 
                      ./../../modules/services/fail2ban.nix                       
                      ./../../modules/nixos/users.nix
                      ./../../modules/nixos/nix.nix
                      ./../../modules/nixos/fonts/default.nix
                      ./../../modules/nixos/i18n.nix
                      ./../../modules/nixos/pipewire.nix
                      ./../../modules/security.nix
                      ./../../modules/services/ssh.nix
                      ./../../modules/services/syslogd.nix
                      ./../../modules/services/syslog.nix
                      ./../../modules/programs/thunar.nix
                      ./../../modules/networking/samba.nix
                      ./../../modules/nixos/gnome-background.nix
                      ./../../modules/nixos/default-apps.nix
                      ./../../modules/virtualization/docker.nix
                      ./../../modules/virtualization/vm.nix
  
  ];

#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ BOOT LOADER ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "desktop";




 
      
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
