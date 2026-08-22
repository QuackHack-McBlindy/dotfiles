# dotfiles/modules/services/default.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ 
  config,
  lib,
  pkgs,
  ...
} : let
  cfg = config.this.host.modules.services;
in {
    config = lib.mkIf (lib.elem "default" cfg) {
        services.atd.enable = true; 
        services.dbus.implementation = "dbus";
        
        services.fail2ban = {
          enable = true;
          bantime = "1h";
          maxretry = 3;
          
          jails = {
            sshd = {
              settings = {
                port = lib.concatMapStringsSep "," toString config.services.openssh.ports;
                filter = "sshd";
                #logpath = "/var/log/auth.log";
                maxretry = 3;
              };
            };  
          };
        };
        
    };}
