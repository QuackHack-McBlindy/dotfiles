{ 
  config,
  lib,
  pkgs,
  ...
} : let
  mediaDisks = [
    "/mnt/disks/media1"
    "/mnt/disks/media2"
    "/mnt/disks/media3"
    "/mnt/disks/media4"
    "/mnt/disks/media5"
  ];

in {

    boot = {
        loader = {
            grub.enable = true;
            grub.device = "/dev/sda";
            grub.useOSProber = true;
        };
        initrd = {
            availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
            kernelModules = [ ];
        };    
        kernelModules = [ "kvm-intel" ];
        extraModulePackages = [ ];
    };  

    this = {
        user = {       
            enable = true;
            me.name = "pungkula";
        };
        host = {
            system = "x86_64-linux";
            hostname = "nasty";
            autoPull = false;
            interface = [ "enp3s0" ];
            ip = "192.168.1.28";
            wgip = "10.0.0.4";
            modules = {
                hardware = [ "cpu/intel" "audio" ];
                system = [ "nix" "pkgs" ];
                networking = [ "default" "caddy" "wg-client" ];
                services = [ "ssh" "backup" "borg" ];
                programs = [ ];
                virtualisation = [ "docker-rootless" "arr" ];
            };  
            keys.publicKeys = {
                host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIARvG4osF3sXi0nN1fMQecMZaUmiOADw8o6+Wis2q77O";
                ssh = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPwZL27kGTQDIlSe03abT9F24nSAizORyjo5cI3BD92s"; 
                age = "age16utg7mmk73cn3glrwthtm0p7mf6g3vrd48h3ucpn6wnf28pgxvcsh4rjjp";
                wireguard = "rP+XbuiiTPmsPB1yJ4BHHOtmVVOfn3ucnV4YdfbqAnw=";
                builder = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINQ7c/AeIpmJS6cWQkHOe4ZEq3DXVRnjtTWuWfx6L46n";
                cache = "cache:/pbj1Agw2OoSSDZcClS69RHa1aNcwwTOX3GIEGKYwPc=";
            };
            
        };    
    };                

    networking.firewall.allowedTCPPorts = [ 2049 ];
    networking.firewall.allowedUDPPorts = [ 2049 ];

    services.nfs.server = {
        enable = true;
        exports = ''
            /Pool  *(rw,fsid=0,no_subtree_check)
        '';
    };


    fileSystems."/" =
        { device = "/dev/disk/by-uuid/005e77e7-16cb-40de-9076-2123feb2ed67";
          fsType = "ext4";
    };
                                                                                      
    swapDevices = [ ];
                                                                                   ########################
  
    fileSystems."/mnt/disks/media1" = {
        device = "/dev/disk/by-label/media1";
        fsType = "ext4";
        options = [ "defaults" "users" "x-gvfs-show" ];
    };

    fileSystems."/mnt/disks/media2" = {
        device = "/dev/disk/by-label/media2";
        fsType = "ext4";
        options = [ "defaults" "users" "x-gvfs-show" ];         
    };

    fileSystems."/mnt/disks/media3" = {
        device = "/dev/disk/by-label/media3";
        fsType = "ext4";
        options = [ "defaults" "users" "x-gvfs-show" ];
    };

    fileSystems."/mnt/disks/media4" = {
        device = "/dev/disk/by-label/media4";
        fsType = "ext4";
        options = [ "defaults" "users" "x-gvfs-show" ];
    };

    fileSystems."/mnt/disks/media5" = {
        device = "/dev/disk/by-label/media5";
        fsType = "ext4";
        options = [ "defaults" "users" "x-gvfs-show" ];
    };


    environment.systemPackages = [ pkgs.mergerfs ];

    fileSystems."/mnt/Pool" = {
        depends = mediaDisks;
        device = builtins.concatStringsSep ":" mediaDisks;
        fsType = "mergerfs";
        options = ["defaults" "minfreespace=250G" "fsname=mergerfs-Pool"];
    };
   
    fileSystems."/Pool" = {
        device = "/mnt/Pool";
        options = [ "bind" ];
    };
   
    fileSystems."/mnt/backup" = {
        device = "/dev/disk/by-label/backup";
        fsType = "ext4";
        options = [ "defaults" "users" "x-gvfs-show" ];
    };

    fileSystems."/backup" = {
        device = "/mnt/backup";
        options = [ "bind" ];
    };
   

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "24.11"; # Did you read the comment?

    }
