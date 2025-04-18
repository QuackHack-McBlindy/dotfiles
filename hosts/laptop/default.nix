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
            systemd.enable = true;
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
        };
        extraModulePackages = [
            config.boot.kernelPackages.broadcom_sta
        ];
        kernelPackages = pkgs.linuxPackages_latest;
        tmp.cleanOnBoot = true;
    };
    hardware.enableAllFirmware = true;
    hardware.enableRedistributableFirmware = true;
    services.fwupd.enable = true;
   
    this = {
        user = {       
            enable = true;
            me.name = "pungkula";
            yubikey.enable = false;
        };
        host = {
            system = "x86_64-linux";
            hostname = "laptop";
            autoPull = false;
            interface = [ "wlan0" ];
            ip = "192.168.1.222";
            wgip = "10.0.0.3";
            modules = {
                hardware = [ "cpu/intel" "audio" ];
                system = [ "nix" "pkgs" "gnome" ];
                networking = [ "wireless" "pool" ];
                services = [ "ssh" "adb" "keyd" ];
                programs = [ "thunar" ];
                virtualisation = [ ];
            };  
            keys.publicKeys = {
                host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFSaGhXOT3kn3dUlZ699qwZShRvjAXXR0SlTulhk+P0W";
                ssh = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOJ6+aLTPanIYS88EjCVtCZv6pw2jC4lIIZNRY6VrnoF";
                age = "age16utg7mmk73cn3glrwthtm0p7mf6g3vrd48h3ucpn6wnf28pgxvcsh4rjjp";
                wireguard = "/n41MVtIQcQ0JuJkuh2SFlYN393KOWed76EwpnSugFk=";
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

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "24.05"; # Did you read the comment?
    }
    




