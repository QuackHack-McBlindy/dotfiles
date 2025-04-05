{ 
    config,
    lib,
    pkgs,
    user,
    hostname,
    inputs,
    ...
} : let
    pubkey = import ./../pubkeys.nix;
in {
    imports = [ ./hardware-configuration.nix ./../backup.nix

                      ./../../modules/networking/wg-client.nix
                      ./../../modules/services/faster-whisper.nix
                      ./../../modules/services/openwakeword.nix
                      ./../../modules/services/systemd/systemd-mnt.nix
                      ./../../modules/services/keyd.nix
                      ./../../modules/nixos/cross-env.nix
                      ./../../modules/nixos/packages.nix
                      ./../../modules/nixos/gnome.nix
                      ./../../modules/services/avahi-client.nix
                      ./../../modules/services/avahi-server.nix
                      ./../../modules/users.nix
                      ./../../modules/nixos/nix.nix
                      ./../../modules/nixos/fonts/default.nix
                      ./../../modules/nixos/pipewire.nix
                      ./../../modules/security.nix
                      ./../../modules/services/ssh.nix
                      ./../../modules/programs/thunar.nix
                      ./../../modules/networking/default.nix
                      ./../../modules/networking/dns.nix
                      ./../../modules/nixos/cache.nix
                      ./../../modules/nixos/default-apps.nix
                      ./../../modules/virtualization/dockerr.nix
                      ./../../modules/virtualization/vm.nix

    ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

    networking.hostName = "desktop";

    gui.gnome = {
        enable = true;
        background = ./../../home/.config/qh.png;
        xserver.enable = true;
        autoLogin.enable = true;
    };
    my.users = {
        enable = true;
        yubikey.enable = true;
        builder.enable = true;
        builder.sshKeys = [ pubkey.desktop pubkey.laptop pubkey.nasty pubkey.homie ];
    };
    modules.services.nixCache.enable = true;
    
    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "24.05"; # Did you read the comment?

    }
