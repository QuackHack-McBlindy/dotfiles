# dotfiles/hosts/laptop/default.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 duck say ⮞ trash - nuff said 
  config,
  lib,
  pkgs,
  self,
  ...
} : { 
   
#    nixpkgs.config.permittedInsecurePackages = [
#        "broadcom-sta-6.30.223.271-59-6.1.159"
#    ];

   
    boot = {
        loader = {
            systemd-boot.enable = true;
            efi.canTouchEfiVariables = true;
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
#        extraModulePackages = [
#            config.boot.kernelPackages.broadcom_sta
#        ];
    };
    
   
    this = { # 🦆 duck say ⮞ this defines everythang
        home = ./../../home; # 🦆 duck say ⮞ nix store home path
        theme = { # 🦆 duck say ⮞ themez
            name = "gtk3.css"; 
            iconTheme = {
                name = "Papirus-Dark";
                package = pkgs.papirus-icon-theme;
            };
            cursorTheme = {
                name = "Bibata-Modern-Classic";
                package = pkgs.bibata-cursors;
                size = 32;
            };
            fonts = {
                system = "Fira Sans";
                monospace = "Fira Code";
                packages = [ pkgs.fira-code ];
            };
        }; # 🦆 duck say ⮞ userz
        user = {       
            enable = true;
            me = {
                name = "pungkula";
                repo = "git@github.com:QuackHack-McBlindy/dotfiles.git";
                dotfilesDir = "/home/${config.this.user.me.name}/dotfiles"; 
                extraGroups = [ "networkmanager" "wheel" "dialout" "users" "pungkula" "adbusers" "audio" ]; 
                mobileDevices = {
                    iphone = { wgip = "10.0.0.7"; pubkey = "UFB0T1Y/uLZi3UBtEaVhCi+QYldYGcOZiF9KKurC5Hw="; };
                    tablet = { wgip = "10.0.0.8"; pubkey = "ETRh93SQaY+Tz/F2rLAZcW7RFd83eofNcBtfyHCBWE4="; };   
                };             
            };
            i18n = "sv_SE.UTF-8";    
            yubikey.enable = false;
        };
        host = {
            system = "x86_64-linux";
            hostname = "laptop";
            interface = [ "enp0s25" ];
            ip = "192.168.1.222";
            wgip = "10.0.0.3";
            modules = {
                hardware = [ "cpu/intel" "audio" ];
                system = [ "nix" "pkgs" "gnome" "crossEnv" "gtk" ];
                networking = [ "default" "pool" ];
                services = [ "ssh" "keyd" ];
                programs = [ "default" "thunar" "firefox" "vesktop" ];
                virtualisation = [  ];
            };  
            keys.publicKeys = {
                host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFSaGhXOT3kn3dUlZ699qwZShRvjAXXR0SlTulhk+P0W";
                ssh = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPwZL27kGTQDIlSe03abT9F24nSAizORyjo5cI3BD92s";
                age = "age16utg7mmk73cn3glrwthtm0p7mf6g3vrd48h3ucpn6wnf28pgxvcsh4rjjp";
                wireguard = "/n41MVtIQcQ0JuJkuh2SFlYN393KOWed76EwpnSugFk=";
                builder = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINQ7c/AeIpmJS6cWQkHOe4ZEq3DXVRnjtTWuWfx6L46n";
                cache = "cache:/pbj1Agw2OoSSDZcClS69RHa1aNcwwTOX3GIEGKYwPc=";
                borg = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMVYczAOBSeS7WfSvzYDOS4Q9Ss+yxCf2G5MVfAALOx/";
                iPhone = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMcmr+z7k/yCbrFg+JDgo8JCuWqNVYn10ajRbNTp8fq";
                adb = "QAAAACEJNfsfRV4PQ9Ah87MbTVbMkbXC6CAMDOR+0K6mIpv/4TSzYMkc2qit3Kryc55IVOjwR3fJRjj/uL549gZ7nEemWtcd3AsYQBp0iIEor8nu1L/V6jfsTY6Xe/pl06xoroy6OwZRWuDbZ4wD2xQRRQjfPd+JtYnMAWneM6r1V15uR67w4ITvjk3ckyfgNeLZMUwahMRjC3wSjaU9sAdKNmg8yPd8uHZ+mK6mstxJFAGEpnnm1lE7Z2r0DF6h6MKY1++dwhU+WM5BRDNiBg+D4i6fDW4+Z1I9ENuFnjT17zAxZXch04SNlG3O94BANYP7jmKp60OvtDL6msfphntuIUzMCkndF9De0Kv4lJdQxe1d+wf+AFpmtd/xtrk45YdMV+eWCJf2OkidaHmSj4ffkAobpun0VrkZN2Z1JymmdsvUbyMjAsby3Zun0xr3EocUS8Jy5TcsK/dcpD6CB5dqzlHhsHSAWt2TDwPzZYXgV1xc+q+PqM09OVN1xActJu75UMkg5b84U15hwQvYdwB8UaopMWWk6p064c7gxYSfH7fSxwkW2Jy1CElgJa55Pp4SZG9b/3B+VcNL1WSf6v/lvJqPbrRvBqvS0+e9wcFMNZtQKTX3n5X0wW1/czZPCQX+hmM8Uu1qrtaz4rKViIEGf4YR0/9eUGYQVfuAxAh8ZmsroJlnAAEAAQA= pungkula@desktop";
            };
            
        };    
    };                


  fileSystems."/" =
    { device = "/dev/disk/by-uuid/a5cae74b-f222-4a10-b254-63ab80a983ec";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/E803-F289";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/6e281696-5985-4a6a-bf59-034a826e48dd"; }
    ];

    hardware.enableAllFirmware = true;
    virtualisation.libvirtd.enable = true;
    
    environment.systemPackages = with pkgs; [
      libvirt
      virt-manager
    ];  
    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "25.05"; # Did you read the comment?
    }
