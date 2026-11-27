# dotfiles/hosts/fatlap/default.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 duck say ⮞ 19" asus laptop
  config,
  lib,
  pkgs,
  self,
  ...
} : {

    boot = {
        loader.systemd-boot.enable = true;
        initrd = {
            kernelModules = [
                "kvm-intel"
                "virtio_balloon"
                "virtio_console"
                "virtio_rng"
            ];
            availableKernelModules = [
              "xhci_pci" "ehci_pci" "ahci" "sd_mod" "sr_mod"
            ];
        };
        kernelPackages = pkgs.linuxPackages_6_1;
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
        };
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
            hostname = "fatlap";
            interface = [ "enp4s0" ];
            ip = "192.168.1.254";
            wgip = "10.0.0.3";
            modules = {
                hardware = [ "cpu/intel" "audio" ];
                system = [ "nix" "pkgs" "gnome" "crossEnv" "gtk" ];
                networking = [ "wireless" "pool" "wg-client" ];
                services = [ "ssh" "keyd" "yo-client" ];
                programs = [ "default" "thunar" "firefox" "vesktop" ];
                virtualisation = [  ];
            };
            keys.publicKeys = {
                host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFSz6e911QVv8HptH8835tv/2K14ypgdsq7xJmTKZsfr";
                ssh = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPwZL27kGTQDIlSe03abT9F24nSAizORyjo5cI3BD92s";
                age = "age16utg7mmk73cn3glrwthtm0p7mf6g3vrd48h3ucpn6wnf28pgxvcsh4rjjp";
                wireguard = "rSQ+GbME0xOkNaZ7VK24nPblu5x2JYVT8XPi4ZyzrAs=";
                builder = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINQ7c/AeIpmJS6cWQkHOe4ZEq3DXVRnjtTWuWfx6L46n";
                cache = "cache:/pbj1Agw2OoSSDZcClS69RHa1aNcwwTOX3GIEGKYwPc=";
                borg = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMVYczAOBSeS7WfSvzYDOS4Q9Ss+yxCf2G5MVfAALOx/";
                iPhone = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMcmr+z7k/yCbrFg+JDgo8JCuWqNVYn10ajRbNTp8fq";
                adb = "QAAAACEJNfsfRV4PQ9Ah87MbTVbMkbXC6CAMDOR+0K6mIpv/4TSzYMkc2qit3Kryc55IVOjwR3fJRjj/uL549gZ7nEemWtcd3AsYQBp0iIEor8nu1L/V6jfsTY6Xe/pl06xoroy6OwZRWuDbZ4wD2xQRRQjfPd+JtYnMAWneM6r1V15uR67w4ITvjk3ckyfgNeLZMUwahMRjC3wSjaU9sAdKNmg8yPd8uHZ+mK6mstxJFAGEpnnm1lE7Z2r0DF6h6MKY1++dwhU+WM5BRDNiBg+D4i6fDW4+Z1I9ENuFnjT17zAxZXch04SNlG3O94BANYP7jmKp60OvtDL6msfphntuIUzMCkndF9De0Kv4lJdQxe1d+wf+AFpmtd/xtrk45YdMV+eWCJf2OkidaHmSj4ffkAobpun0VrkZN2Z1JymmdsvUbyMjAsby3Zun0xr3EocUS8Jy5TcsK/dcpD6CB5dqzlHhsHSAWt2TDwPzZYXgV1xc+q+PqM09OVN1xActJu75UMkg5b84U15hwQvYdwB8UaopMWWk6p064c7gxYSfH7fSxwkW2Jy1CElgJa55Pp4SZG9b/3B+VcNL1WSf6v/lvJqPbrRvBqvS0+e9wcFMNZtQKTX3n5X0wW1/czZPCQX+hmM8Uu1qrtaz4rKViIEGf4YR0/9eUGYQVfuAxAh8ZmsroJlnAAEAAQA= pungkula@desktop";
            };

        };
    };

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/5aab4a05-d34d-4956-b491-c2e87fb5ee22";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/BEA5-1FB5";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/cd86c28d-de55-4928-9066-e06be489a3b7"; }
    ];


    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "24.05"; # Did you read the comment?
    }
