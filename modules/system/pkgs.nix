# dotfiles/modules/system/pkgs.nix
{ 
    config,
    lib,
    pkgs,
    inputs,
    self,
    ...
} : {
    config = lib.mkIf (lib.elem "pkgs" config.this.host.modules.system) {
        environment.systemPackages = lib.mkMerge [
            (lib.mkIf (config.networking.hostName == "desktop") [ 
                pkgs.nix-prefetch-github 
             #   inputs.voice-server.packages.x86_64-linux.voice-server
            ])
        
            (lib.mkIf (config.networking.hostName == "nasty") [ pkgs.hello ])
            (lib.mkIf (config.networking.hostName == "laptop") [ pkgs.hello ])
            (lib.mkIf (config.networking.hostName == "homie") [ pkgs.pairdrop ])
    
            [ 
                pkgs.npth
                #   esphome
                pkgs.python312Packages.httpx
                pkgs.python312Packages.aiocron
                pkgs.python312Packages.aioesphomeapi
                pkgs.python3Full
                pkgs.python312Packages.requests
                pkgs.python312Packages.pyaml
                pkgs.python312Packages.invoke
                pkgs.python312Packages.langid
                pkgs.python312Packages.pysilero-vad

                ## CLI TOOLS
               ###############
                pkgs.qrencode
                pkgs.ntfy-sh

                pkgs.imagemagick
                pkgs.smartmontools
                pkgs.xoscope
                pkgs.mdns
                pkgs.nssmdns
                pkgs.telegraf
                pkgs.procps
                pkgs.pv
                pkgs.nfs-utils
                pkgs.rclone
                pkgs.syncrclone
              #  pkgs.librclone
                pkgs.yq
                pkgs.efibootmgr
                pkgs.grafana-loki
                pkgs.pm2
                pkgs.home-manager
                pkgs.nixos-option
                pkgs.inotify-tools
                pkgs.wyoming-satellite
                pkgs.mpg123
                pkgs.hassil
               # vaultwarden-postgressql
                pkgs.neofetch
                pkgs.rsync
                pkgs.android-tools
                pkgs.libnotify
                pkgs.alsa-utils
                pkgs.nixos-facter
                pkgs.dig
                pkgs.nmap
                pkgs.snapcast
                pkgs.hddtemp
                pkgs.psutils
                #toybox # FIXME unable to use env -c when toybox installed
                pkgs.busybox
                pkgs.catimg # ascii art from img
                pkgs.ncurses
                pkgs.dialog
                pkgs.wget
                pkgs.curl
                pkgs.git
                pkgs.unzip
                pkgs.dunst
                pkgs.sox
                pkgs.wireguard-tools
                pkgs.nixos-anywhere
                pkgs.nix-serve
                pkgs.dconf
                pkgs.nvme-cli
               # pkgs.syncthing
           #     inputs.voice-client.packages.x86_64-linux.voice-client
              #  inputs.say.packages.x86_64-linux.say
                self.packages.${pkgs.system}.say
                self.packages.${pkgs.system}.health
               # inputs.tv.packages.x86_64-linux.tv
                # inputs.api.packages.x86_64-linux.api
            ]     
        ];
        
    };}   
