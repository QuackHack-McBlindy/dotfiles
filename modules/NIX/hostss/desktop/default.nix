{ 
  config,
  lib,
  self,
  ...
} : {
    boot = {
        kernelModules = [ "kvm-intel" "linux_6_12_hardened.system76-io" ];
        extraModulePackages = [ ];   
        loader = {
            systemd-boot.enable = true;
            efi.canTouchEfiVariables = true;
        };    
        initrd = {
            availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
            kernelModules = [ ];
        };
        binfmt.emulatedSystems = [ "aarch64-linux" ];
    };
    
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    
    this = {
        user = {       
            enable = true;
            me.name = "pungkula";
            yubikey.enable = true;
            builder = {
                enable = true;
                sshKeys = [ config.this.host.keys.publicKeys.builder ];
            };    
        };
        host = {
            system = "x86_64-linux";
            hostname = "desktop";
            autoPull = true;
            interface = [ "enp119s0" ];
            ip = "192.168.1.111";
            wgip = "10.0.0.2";
            modules = {
                hardware = [ "cpu/intel" "gpu/amd" "audio" ];
                system = [ "nix" "pkgs" "gnome" "crossEnv" ];
                networking = [ "default" "pool" ];
                services = [ "ssh" "node-red" "backup" "cache" "keyd" ];
                programs = [ "thunar" ];
                virtualisation = [ "docker" "vm" ];
            };  
            keys.publicKeys = {
                host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILdwPkRQxlbrbRGwEO5zMJ4m+7QqUQPZg1iqbd5HRP34";
                ssh = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPwZL27kGTQDIlSe03abT9F24nSAizORyjo5cI3BD92s";
                age = "age16utg7mmk73cn3glrwthtm0p7mf6g3vrd48h3ucpn6wnf28pgxvcsh4rjjp";
                wireguard = "Oq0ZaYAnOo5sLpV//OEFwLgjVCxPyeQqf8cZBASluWk=";
                builder = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINQ7c/AeIpmJS6cWQkHOe4ZEq3DXVRnjtTWuWfx6L46n";
                cache = "cache:/pbj1Agw2OoSSDZcClS69RHa1aNcwwTOX3GIEGKYwPc=";
            };
            
        };    
    };                

    fileSystems."/" =
        { device = "/dev/disk/by-label/nixos";
          fsType = "ext4";
        };

    fileSystems."/boot" =
        { device = "/dev/disk/by-label/boot";
          fsType = "vfat";
          options = [ "fmask=0022" "dmask=0022" ];
        };
    
    swapDevices = [ ]; 
    
    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "24.05"; # Did you read the comment?
    }
