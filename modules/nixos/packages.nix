{ 
  config,
  inputs,
  self,
  lib,
  pkgs,
  ...
} : {
    environment.systemPackages = with pkgs; [   
        pkgs.npth
     #   esphome
        pkgs.python312Packages.httpx
        pkgs.python312Packages.aiocron
        python312Packages.aioesphomeapi
        python3Full
        python312Packages.requests
        python312Packages.pyaml
        python312Packages.invoke
        python312Packages.langid
        python312Packages.pysilero-vad

    ## CLI TOOLS
    ###############

        pkgs.ntfy-sh

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
        mpg123
        hassil
       # vaultwarden-postgressql
        neofetch
        rsync
        android-tools
        libnotify
        alsa-utils
        nixos-facter
        dig
        nmap
        snapcast
        hddtemp
        psutils
        #toybox # FIXME unable to use env -c when toybox installed
        busybox
        catimg # ascii art from img
        ncurses
        dialog
        wget
        curl
        git
        unzip
        wireguard-tools
        pkgs.nixos-anywhere
        pkgs.syncthing
        inputs.voice-client.packages.x86_64-linux.voice-client
        inputs.say.packages.x86_64-linux.say
        
   #     inputs.api.packages.x86_64-linux.api
   
    ];
}   
