{ config, lib, pkgs, user, host, hostname, ... }:

let
  user = "pungkula";
  hostname = "homie";
in
{
  imports = [ ./hardware-configuration.nix
                  
                   #   ./../../modules/services/dns.nix 
                      ./../../modules/services/fail2ban.nix                       
                      ./../../modules/security.nix
                      ./../../modules/services/ssh.nix
                      ./../../modules/services/syslogd.nix
                      ./../../modules/virtualization/docker.nix
               #       ./../../modules/virtualization/vm.nix
                      ./../../modules/nixos/packages.nix
                    #  ./../../modules/nixos/gnome.nix
                    #  ./../../modules/nixos/xserver.nix
                      ./../../modules/nixos/default-apps.nix
                      ./../../modules/nixos/users.nix
                      ./../../modules/nixos/nix.nix
                      ./../../modules/nixos/fonts/default.nix
                      ./../../modules/nixos/i18n.nix
                      ./../../modules/nixos/pipewire.nix
                      ./../../modules/networking/stubby.nix
                      ./../../modules/networking/default.nix
  ];
                            
  networking.hostName = "homie";

  boot.initrd.systemd.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

#  services.avahi = {#
#    enable = true;
#    ipv4 = true;
#    ipv6 = true;
#    nssmdns4 = true;
#    publish = { enable = true; domain = true; addresses = true; };
#  };

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    tmux
    unzip
  ];

#  services.xserver = {
#    desktopManager.gnome.enable = true;
 #   displayManager.gdm.enable = true;
 #   enable = true;
 #   libinput.enable = true;
#  };

#  boot.plymouth.enable = true;

#  customization = {
#    gdm-logo.enable = true;
#    gnome-background.enable = true;
#    plymouth-logo.enable = true;
#  };

  hardware.opengl = {
    # this fixes the "glXChooseVisual failed" bug,
    # context: https://github.com/NixOS/nixpkgs/issues/47932
    enable = true;
    driSupport32Bit = true;
  };

#  security.sudo.wheelNeedsPassword = false;
 # services.openssh = {
#    enable = true;
 #   settings.PermitRootLogin = "yes";
#  };
 # users.mutableUsers = false;
 # users.extraUsers.root.password = "nixcademy";

 # users.users.nixcademy = {
 #   isNormalUser = true;
 #   extraGroups = [
 #     "wheel"
 #     "networkmanager"
 #     "kvm"
 #   ];
 #   initialPassword = "nixcademy";
 # };
  
  
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
 # system.stateVersion = "24.05"; # Did you read the comment?
}
