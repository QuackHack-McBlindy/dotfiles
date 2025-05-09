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
  pkgs,
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
        home = ./../../home;
        theme.name = "gtk3.css"; 
        user = {       
            enable = true;
            me.name = "pungkula";
        };
        host = {
            system = "x86_64-linux";
            hostname = "homie";
            interface = [ "eno1" ];
            ip = "192.168.1.211";
            wgip = "10.0.0.1";
            modules = {
                hardware = [ "cpu/intel" "audio" ];
                system = [ "nix" "pkgs" ];
                networking = [ "default" "dns" "pool" "wg-server" ];
                services = [ "ssh" "adb" "backup" "pairdrop" "mqtt" "zigbee2mqtt" "navidrome" "ip-updater" ];
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
                borg = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMVYczAOBSeS7WfSvzYDOS4Q9Ss+yxCf2G5MVfAALOx/";
                iPhone = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMcmr+z7k/yCbrFg+JDgo8JCuWqNVYn10ajRbNTp8fq";
                adb = "QAAAACEJNfsfRV4PQ9Ah87MbTVbMkbXC6CAMDOR+0K6mIpv/4TSzYMkc2qit3Kryc55IVOjwR3fJRjj/uL549gZ7nEemWtcd3AsYQBp0iIEor8nu1L/V6jfsTY6Xe/pl06xoroy6OwZRWuDbZ4wD2xQRRQjfPd+JtYnMAWneM6r1V15uR67w4ITvjk3ckyfgNeLZMUwahMRjC3wSjaU9sAdKNmg8yPd8uHZ+mK6mstxJFAGEpnnm1lE7Z2r0DF6h6MKY1++dwhU+WM5BRDNiBg+D4i6fDW4+Z1I9ENuFnjT17zAxZXch04SNlG3O94BANYP7jmKp60OvtDL6msfphntuIUzMCkndF9De0Kv4lJdQxe1d+wf+AFpmtd/xtrk45YdMV+eWCJf2OkidaHmSj4ffkAobpun0VrkZN2Z1JymmdsvUbyMjAsby3Zun0xr3EocUS8Jy5TcsK/dcpD6CB5dqzlHhsHSAWt2TDwPzZYXgV1xc+q+PqM09OVN1xActJu75UMkg5b84U15hwQvYdwB8UaopMWWk6p064c7gxYSfH7fSxwkW2Jy1CElgJa55Pp4SZG9b/3B+VcNL1WSf6v/lvJqPbrRvBqvS0+e9wcFMNZtQKTX3n5X0wW1/czZPCQX+hmM8Uu1qrtaz4rKViIEGf4YR0/9eUGYQVfuAxAh8ZmsroJlnAAEAAQA= pungkula@desktop";
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

