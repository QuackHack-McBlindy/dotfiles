{ config, lib, pkgs, user, inputs, host, hostname, ... }:
let
  user = "pungkula";
  hostname = "desktop";
in
{
  imports = [ ./hardware-configuration.nix ./backup.nix

                      
                     # ./../../modules/services/systemd/voice-server.nix
                 #     ./../../modules/services/satellite.nix
                      ./../../modules/services/faster-whisper.nix
                      ./../../modules/services/openwakeword.nix
                      ./../../modules/services/systemd/systemd-mnt.nix
                      ./../../modules/services/rclone.nix
                      ./../../modules/services/syncthing.nix
                      ./../../modules/services/keyd.nix
                      ./../../modules/networking/stubby.nix
                      ./../../modules/hardware/pam.nix
                      ./../../modules/nixos/cross-env.nix
                      ./../../modules/nixos/packages.nix
                      ./../../modules/nixos/gnome.nix
                      ./../../modules/nixos/xserver.nix
                      ./../../modules/services/avahi-client.nix
                      ./../../modules/services/jails.nix                       
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
                      ./../../modules/networking/default.nix
                      ./../../modules/nixos/gnome-background.nix
                      ./../../modules/nixos/default-apps.nix
                      ./../../modules/virtualization/docker.nix
                      ./../../modules/virtualization/vm.nix
                      #/../../modules/virtualization/arr.nix
                    #  ./../../modules/virtualization/gluetun.nix
  
  ];

#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ BOOT LOADER ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  
  networking.hostName = "desktop";


  environment.systemPackages = with pkgs; [
    inputs.voice-server.packages.x86_64-linux.voice-server

  ];

 
      
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
