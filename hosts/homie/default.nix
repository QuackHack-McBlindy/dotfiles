#                       ./../../modules/services/navidrome.nix
                   #   ./../../modules/services/telegraf.nix
                   #   ./../../modules/services/homepage.nix
                    #  ./../../modules/services/systemd/voice-server.nix
                    #  ./../../modules/services/loki.nix
#                      ./../../modules/services/mosquitto.nix
#                      ./../../modules/services/zigbee2mqtt.nix
#                      ./../../modules/virtualization/home-assistant.nix
#                      ./../../modules/services/openwakeword.nix
#                      ./../../modules/services/faster-whisper.nix
#                      ./../../modules/services/ntfy.nix
#                      ./../../modules/services/systemd/systemd-mnt.nix
#                      ./../../modules/services/avahi-client.nix
#                      ./../../modules/security.nix
#                      ./../../modules/services/ssh.nix
#                    #  ./../../modules/services/syslogd.nix
#                      ./../../modules/virtualization/docker.nix
#               #       ./../../modules/virtualization/vm.nix

{ 
  config,
  lib,
  self,
  ...
} : {
    
    boot = {
        loader = {
            systemd-boot.enable = true;
        };  
        initrd = {
            kernelModules = [
                "kvm-intel"
                "virtio_balloon"
                "virtio_console"
                "virtio_rng"
            ];
            availableKernelModules = [
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
            systemd.enable = true;
        };
        kernelPackages = pkgs.linuxPackages_6_1; 
        extraModulePackages = [
            config.boot.kernelPackages.broadcom_sta
        ];
    };
    
    this = {
        user = {       
            enable = true;
            me.name = "pungkula";
        };
        host = {
            system = "x86_64-linux";
            hostname = "homie";
            autoPull = false;
            interface = [ "eno1" ];
            ip = "192.168.1.211";
            wgip = "10.0.0.1";
            modules = {
                hardware = [ "cpu/intel" "audio" ];
                system = [ "nix" "pkgs" ];
                networking = [ "default" "dns" "pool" "wg-server" ];
                services = [ "ssh" "backup" "pairdrop" "mqtt" "zigbee2mqtt" "navidrome" ];
                programs = [ ];
                virtualisation = [ "docker-rootless" "home-assistant" ];
            };  
            keys.publicKeys = {
                host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIgxAwZZQF+fjTx4l9tfXKRyK4WqPojU1OuDshcbLAnD";
                ssh = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOJ6+aLTPanIYS88EjCVtCZv6pw2jC4lIIZNRY6VrnoF";
                age = "age16utg7mmk73cn3glrwthtm0p7mf6g3vrd48h3ucpn6wnf28pgxvcsh4rjjp";
                wireguard = "BlpQEu1MJbNmx32zgTFO0Otnkb+4XA1pwVdhjHtJBiQ=";
                builder = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINQ7c/AeIpmJS6cWQkHOe4ZEq3DXVRnjtTWuWfx6L46n";
                cache = "cache:/pbj1Agw2OoSSDZcClS69RHa1aNcwwTOX3GIEGKYwPc=";
            };
            
        };    
    };                

    fileSystems."/boot" = {
        device = "/dev/disk/by-label/boot";
        fsType = "vfat";
    };

    fileSystems."/" = {
        device = "/dev/disk/by-label/nixos";
        fsType = "ext4";
    };

    swapDevices = [{ device = "/dev/disk/by-label/swap"; }];

    hardware.enableAllFirmware = true;

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "24.05"; # Did you read the comment?


    }

