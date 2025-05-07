{ 
  config,
  lib,
  pkgs,
  ...
} : {
    config = lib.mkIf (lib.elem "ip-updater" config.this.host.modules.services) {
        systemd.services.duckdns-updater = {
            description = "DuckDNS IP Updater";
            wantedBy = [ "multi-user.target" ];
            serviceConfig = {
                Type = "oneshot";
                ExecStart = "${pkgs.bash}/bin/bash /home/pungkula/dotfiles/home/bin/duck-updater";
               # ExecStart = "${duckdns-executable}/bin/duckdns-updater";
                Restart = "on-failure";
                RestartSec = "2s";
                RuntimeDirectory = [ config.this.user.me.name ];
                User = config.this.user.me.name;
            };
        };
        systemd.timers.duckdns-updater = {
            wantedBy = [ "timers.target" ];
            timerConfig = {
                OnBootSec = "1min";
                OnUnitActiveSec = "10min";
                Unit = "duckdns-updater.service";
            };
        };
      
        sops.secrets = lib.mkIf (!config.this.installer) {
            duckdnsEnv-x = {
                sopsFile = ./../../secrets/duckdnsEnv-x.yaml;
                owner = config.this.user.me.name;
                group = config.this.user.me.name;
                mode = "0660";
            };
            duckdnsEnv-gh-pungkula = {
                sopsFile = ./../../secrets/duckdnsEnv-gh-pungkula.yaml;
                owner = config.this.user.me.name;
                group = config.this.user.me.name;
                mode = "0660";
            };
            duckdnsEnv-gh-quackhack = {
                sopsFile = ./../../secrets/duckdnsEnv-gh-quackhack.yaml;
                owner = config.this.user.me.name;
                group = config.this.user.me.name;
                mode = "0660";
            };
        };
        
    };}





