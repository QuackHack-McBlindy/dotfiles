# dotfiles/hosts/nasty/default.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 duck say ⮞ huge nasty server - poolin dem drivez yo  
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
        home = ./../../home;
        theme.name = "gtk3.css"; 
        user = {       
            enable = true;
            me = {
                name = "pungkula";
                repo = "git@github.com:QuackHack-McBlindy/dotfiles.git";
                dotfilesDir = "/home/${config.this.user.me.name}/dotfiles"; 
                extraGroups = [ "networkmanager" "wheel" "dialout" "docker" "dockeruser" "users" "pungkula" "adbusers" "audio" ]; 
                mobileDevices = {
                    iphone = { wgip = "10.0.0.7"; pubkey = "UFB0T1Y/uLZi3UBtEaVhCi+QYldYGcOZiF9KKurC5Hw="; };
                    tablet = { wgip = "10.0.0.8"; pubkey = "ETRh93SQaY+Tz/F2rLAZcW7RFd83eofNcBtfyHCBWE4="; };   
                };
            };
            i18n = "sv_SE.UTF-8";
        };
        host = {
            system = "x86_64-linux";
            hostname = "nasty";
            interface = [ "enp3s0" ];
            ip = "192.168.1.28";
            wgip = "10.0.0.4";
            modules = {
                hardware = [ "cpu/intel" "audio" ];
                system = [ "nix" "pkgs" ];
                networking = [ "default" "caddy" ];
                services = [ "ssh" "adb" "backup" "borg" "navidrome" ];
                programs = [ "default" ];
                virtualisation = [ "docker-rootless" "arr" ];
            };  
            keys.publicKeys = {
                host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIARvG4osF3sXi0nN1fMQecMZaUmiOADw8o6+Wis2q77O";
                ssh = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPwZL27kGTQDIlSe03abT9F24nSAizORyjo5cI3BD92s"; 
#                age = "age1ylcyklqjfz330e75vufmq4g0mtkl2xqmdfkehywcgdhnxfyhesnqf9dz5m";
                age = "age16utg7mmk73cn3glrwthtm0p7mf6g3vrd48h3ucpn6wnf28pgxvcsh4rjjp";
                wireguard = "rP+XbuiiTPmsPB1yJ4BHHOtmVVOfn3ucnV4YdfbqAnw=";
                builder = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINQ7c/AeIpmJS6cWQkHOe4ZEq3DXVRnjtTWuWfx6L46n";
                cache = "cache:/pbj1Agw2OoSSDZcClS69RHa1aNcwwTOX3GIEGKYwPc=";
                borg = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMVYczAOBSeS7WfSvzYDOS4Q9Ss+yxCf2G5MVfAALOx/";
                iPhone = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMcmr+z7k/yCbrFg+JDgo8JCuWqNVYn10ajRbNTp8fq";
                adb = "QAAAACEJNfsfRV4PQ9Ah87MbTVbMkbXC6CAMDOR+0K6mIpv/4TSzYMkc2qit3Kryc55IVOjwR3fJRjj/uL549gZ7nEemWtcd3AsYQBp0iIEor8nu1L/V6jfsTY6Xe/pl06xoroy6OwZRWuDbZ4wD2xQRRQjfPd+JtYnMAWneM6r1V15uR67w4ITvjk3ckyfgNeLZMUwahMRjC3wSjaU9sAdKNmg8yPd8uHZ+mK6mstxJFAGEpnnm1lE7Z2r0DF6h6MKY1++dwhU+WM5BRDNiBg+D4i6fDW4+Z1I9ENuFnjT17zAxZXch04SNlG3O94BANYP7jmKp60OvtDL6msfphntuIUzMCkndF9De0Kv4lJdQxe1d+wf+AFpmtd/xtrk45YdMV+eWCJf2OkidaHmSj4ffkAobpun0VrkZN2Z1JymmdsvUbyMjAsby3Zun0xr3EocUS8Jy5TcsK/dcpD6CB5dqzlHhsHSAWt2TDwPzZYXgV1xc+q+PqM09OVN1xActJu75UMkg5b84U15hwQvYdwB8UaopMWWk6p064c7gxYSfH7fSxwkW2Jy1CElgJa55Pp4SZG9b/3B+VcNL1WSf6v/lvJqPbrRvBqvS0+e9wcFMNZtQKTX3n5X0wW1/czZPCQX+hmM8Uu1qrtaz4rKViIEGf4YR0/9eUGYQVfuAxAh8ZmsroJlnAAEAAQA= pungkula@desktop";
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
