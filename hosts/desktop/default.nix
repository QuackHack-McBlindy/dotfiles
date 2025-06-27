# hosts/desktop/default.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 duck say ⮞ diz iz my main machine & waz my entry 4 da steelseries world championship build contest
  config, # 🦆 duck say ⮞ 2 much pc 4 a simple duck like me - basically sittin' on 3 horses here
  lib, 
  pkgs,
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
    # 🦆 duck say ⮞ this module           
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
            me = { # 🦆 duck say ⮞ USER
                name = "pungkula";
                repo = "git@github.com:QuackHack-McBlindy/dotfiles.git";
                discord = "https://discordapp.com/users/675530282849533952";
                #matrix = "";
                email = "isthisrandomenough@protonmail.com";
                dotfilesDir = "/home/${config.this.user.me.name}/dotfiles"; 
                extraGroups = [ "networkmanager" "wheel" "dialout" "docker" "dockeruser" "users" "pungkula" "adbusers" "audio" ]; 
                mobileDevices = { # 🦆 duck say ⮞ non nixos devices
                    iphone = { wgip = "10.0.0.7"; pubkey = "UFB0T1Y/uLZi3UBtEaVhCi+QYldYGcOZiF9KKurC5Hw="; };
                    tablet = { wgip = "10.0.0.8"; pubkey = "ETRh93SQaY+Tz/F2rLAZcW7RFd83eofNcBtfyHCBWE4="; };   
                };
            }; # 🦆 duck say ⮞ language
            i18n = "sv_SE.UTF-8";
            # 🦆 duck say ⮞ yubikey
            yubikey.enable = true; 
            # 🦆 duck say ⮞ da builder
            builder = {
                enable = true;
                sshKeys = [ config.this.host.keys.publicKeys.builder ];
            };    
        };
        # 🦆 duck say ⮞ define diz machine
        host = {
            system = "x86_64-linux";
            hostname = "desktop";
            interface = [ "enp119s0" ];
            ip = "192.168.1.111";
            wgip = "10.0.0.2";
            # 🦆 duck say ⮞ modulez
            modules = {
                hardware = [ "cpu/intel" "gpu/amd" "audio" ];
                system = [ "nix" "pkgs" "gnome" "crossEnv" "gtk" ];
                networking = [ "default" "pool" ];
                services = [ "ssh" "adb" "backup" "cache" "keyd" "wake" "whisperd" ];
                programs = [ "default" "thunar" "firefox" "vesktop" ];
                virtualisation = [ "docker" "vm" ];
            }; # 🦆 duck say ⮞ pub keyz yo
            keys.publicKeys = {
                host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILdwPkRQxlbrbRGwEO5zMJ4m+7QqUQPZg1iqbd5HRP34";
                ssh = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPwZL27kGTQDIlSe03abT9F24nSAizORyjo5cI3BD92s";
                age = "age16utg7mmk73cn3glrwthtm0p7mf6g3vrd48h3ucpn6wnf28pgxvcsh4rjjp";
                wireguard = "Oq0ZaYAnOo5sLpV//OEFwLgjVCxPyeQqf8cZBASluWk=";
                builder = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINQ7c/AeIpmJS6cWQkHOe4ZEq3DXVRnjtTWuWfx6L46n";
                cache = "cache:/pbj1Agw2OoSSDZcClS69RHa1aNcwwTOX3GIEGKYwPc=";
                borg = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMVYczAOBSeS7WfSvzYDOS4Q9Ss+yxCf2G5MVfAALOx/";
                iPhone = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMcmr+z7k/yCbrFg+JDgo8JCuWqNVYn10ajRbNTp8fq";
                adb = "QAAAACEJNfsfRV4PQ9Ah87MbTVbMkbXC6CAMDOR+0K6mIpv/4TSzYMkc2qit3Kryc55IVOjwR3fJRjj/uL549gZ7nEemWtcd3AsYQBp0iIEor8nu1L/V6jfsTY6Xe/pl06xoroy6OwZRWuDbZ4wD2xQRRQjfPd+JtYnMAWneM6r1V15uR67w4ITvjk3ckyfgNeLZMUwahMRjC3wSjaU9sAdKNmg8yPd8uHZ+mK6mstxJFAGEpnnm1lE7Z2r0DF6h6MKY1++dwhU+WM5BRDNiBg+D4i6fDW4+Z1I9ENuFnjT17zAxZXch04SNlG3O94BANYP7jmKp60OvtDL6msfphntuIUzMCkndF9De0Kv4lJdQxe1d+wf+AFpmtd/xtrk45YdMV+eWCJf2OkidaHmSj4ffkAobpun0VrkZN2Z1JymmdsvUbyMjAsby3Zun0xr3EocUS8Jy5TcsK/dcpD6CB5dqzlHhsHSAWt2TDwPzZYXgV1xc+q+PqM09OVN1xActJu75UMkg5b84U15hwQvYdwB8UaopMWWk6p064c7gxYSfH7fSxwkW2Jy1CElgJa55Pp4SZG9b/3B+VcNL1WSf6v/lvJqPbrRvBqvS0+e9wcFMNZtQKTX3n5X0wW1/czZPCQX+hmM8Uu1qrtaz4rKViIEGf4YR0/9eUGYQVfuAxAh8ZmsroJlnAAEAAQA= pungkula@desktop";
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

