# dotfiles/hosts/kotte/default.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 translatez "kotte" ⮞ PinePhone host  configuration
  config,
  lib, 
  pkgs,
  self,
  ...
} : { 

    # 🦆 duck say ⮞ this module           
    this = { # 🦆 duck say ⮞ this defines everythang
        home = ./../../home; # 🦆 duck say ⮞ nix store home path
        user = { 
            enable = true;
            me = { # 🦆 duck say ⮞ USER
                name = "pungkula";
                repo = "git@github.com:QuackHack-McBlindy/dotfiles.git";
                discord = "https://discordapp.com/users/675530282849533952";
                #matrix = "";
                email = "isthisrandomenough@protonmail.com";
                dotfilesDir = "/home/${config.this.user.me.name}/dotfiles"; 
                extraGroups = [ "networkmanager" "wheel" "dialout" "docker" "dockeruser" "users" "pungkula" "adbusers" "audio" "2000" ]; 
                mobileDevices = { # 🦆 duck say ⮞ non nixos devices
                    iphone = { wgip = "10.0.0.7"; pubkey = "UFB0T1Y/uLZi3UBtEaVhCi+QYldYGcOZiF9KKurC5Hw="; };
                    tablet = { wgip = "10.0.0.8"; pubkey = "ETRh93SQaY+Tz/F2rLAZcW7RFd83eofNcBtfyHCBWE4="; };   
                };
            }; # 🦆 says ⮞ language
            i18n = "sv_SE.UTF-8";
            # 🦆 says ⮞ yubikey
            yubikey.enable = false; 
            # 🦆 says ⮞ da builder
            builder = {
                enable = false;
                #sshKeys = [ config.this.host.keys.publicKeys.builder ];
            };    
        };
        # 🦆 say ⮞ define diz machine
        host = {
            system = "aarch64-linux";
            hostname = "kotte"; 
            interface = [ "wlan0" ]; # 🦆 duck say ⮞ don't forget your card yo
            ip = "192.168.1.23";
           # wgip = "10.0.0.2";
            # 🦆 duck say ⮞ modulez
            modules = {
                hardware = [ "pinephone" ];
                system = [ "nix" ];
                networking = [ "default" ];
                services = [ "ssh" ];
                programs = [ ];
                virtualisation = [ ];
            }; # 🦆 duck say ⮞ pub keyz yo
            keys.publicKeys = {
                #host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILdwPkRQxlbrbRGwEO5zMJ4m+7QqUQPZg1iqbd5HRP34";
                ssh = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPwZL27kGTQDIlSe03abT9F24nSAizORyjo5cI3BD92s";
                age = "age16utg7mmk73cn3glrwthtm0p7mf6g3vrd48h3ucpn6wnf28pgxvcsh4rjjp";
                #wireguard = "Oq0ZaYAnOo5sLpV//OEFwLgjVCxPyeQqf8cZBASluWk=";
                #builder = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINQ7c/AeIpmJS6cWQkHOe4ZEq3DXVRnjtTWuWfx6L46n";
                #cache = "cache:/pbj1Agw2OoSSDZcClS69RHa1aNcwwTOX3GIEGKYwPc=";
                #borg = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMVYczAOBSeS7WfSvzYDOS4Q9Ss+yxCf2G5MVfAALOx/";
                iPhone = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMcmr+z7k/yCbrFg+JDgo8JCuWqNVYn10ajRbNTp8fq";
                adb = "QAAAACEJNfsfRV4PQ9Ah87MbTVbMkbXC6CAMDOR+0K6mIpv/4TSzYMkc2qit3Kryc55IVOjwR3fJRjj/uL549gZ7nEemWtcd3AsYQBp0iIEor8nu1L/V6jfsTY6Xe/pl06xoroy6OwZRWuDbZ4wD2xQRRQjfPd+JtYnMAWneM6r1V15uR67w4ITvjk3ckyfgNeLZMUwahMRjC3wSjaU9sAdKNmg8yPd8uHZ+mK6mstxJFAGEpnnm1lE7Z2r0DF6h6MKY1++dwhU+WM5BRDNiBg+D4i6fDW4+Z1I9ENuFnjT17zAxZXch04SNlG3O94BANYP7jmKp60OvtDL6msfphntuIUzMCkndF9De0Kv4lJdQxe1d+wf+AFpmtd/xtrk45YdMV+eWCJf2OkidaHmSj4ffkAobpun0VrkZN2Z1JymmdsvUbyMjAsby3Zun0xr3EocUS8Jy5TcsK/dcpD6CB5dqzlHhsHSAWt2TDwPzZYXgV1xc+q+PqM09OVN1xActJu75UMkg5b84U15hwQvYdwB8UaopMWWk6p064c7gxYSfH7fSxwkW2Jy1CElgJa55Pp4SZG9b/3B+VcNL1WSf6v/lvJqPbrRvBqvS0+e9wcFMNZtQKTX3n5X0wW1/czZPCQX+hmM8Uu1qrtaz4rKViIEGf4YR0/9eUGYQVfuAxAh8ZmsroJlnAAEAAQA= pungkula@desktop";
            };       
        };    
    };                



    hardware.sensor.iio.enable = true;

    hardware.opengl.enable = true;
    hardware.opengl.driSupport = true;  

    # GPS
    services.geoclue2.enable = true;
    users.users.geoclue.extraGroups = [ "networkmanager" ];


    services.xserver.desktopManager.phosh = {
      enable = true;
      user = config.this.user.me.name;
      group = "users";
      # for better compatibility with x11 applications
      phocConfig.xwayland = "immediate";
    };

    environment.variables = {
      QT_QPA_PLATFORM = "wayland";
    };

    # Phone call
    programs.calls.enable = true;
    # Optional but recommended. https://github.com/NixOS/nixpkgs/pull/162894
    systemd.services.ModemManager.serviceConfig.ExecStart = [
      "" # clear ExecStart from upstream unit file.
      "${pkgs.modemmanager}/sbin/ModemManager --test-quick-suspend-resume"
    ];

    services.fwupd.enable = true;

    environment.systemPackages = with pkgs; [
      # Disabled since it uses `olm` which was marked insecure.
      #chatty
      epiphany
      gnome-console
      megapixels
    ];


#    assertions = [{
#      assertion = options.services.xserver.desktopManager.phosh.user.isDefined;
#      message = ''
#        `services.xserver.desktopManager.phosh.user` not set.
#          When importing the phosh configuration in your system, you need to set `services.xserver.desktopManager.phosh.user` to the username of the session user.
#      '';
#    }];  
    

    }

