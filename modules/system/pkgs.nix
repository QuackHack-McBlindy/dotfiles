# dotfiles/modules/system/pkgs.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says⮞ system packages
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
                pkgs.cargo
                pkgs.rustc
                pkgs.openssl
                pkgs.pkg-config
                pkgs.rustfmt
                pkgs.clippy
                pkgs.ollama-rocm
                pkgs.jellyfin-web
                pkgs.jellycli
                pkgs.kanata
                pkgs.arduino-ide
                pkgs.arduino-cli
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
                pkgs.python312
                pkgs.python312Packages.requests
                pkgs.python312Packages.pyaml
                pkgs.python312Packages.invoke
                pkgs.python312Packages.langid
                pkgs.python312Packages.pysilero-vad

                ## CLI TOOLS
               ###############
                pkgs.qrencode
                pkgs.ntfy-sh
                pkgs.ghostty
                pkgs.imagemagick
                pkgs.smartmontools
                pkgs.xoscope
                pkgs.mdns
                pkgs.nssmdns
                pkgs.telegraf
                pkgs.procps
                pkgs.pv
                pkgs.starship
                pkgs.nfs-utils
                pkgs.rclone
                pkgs.syncrclone
              #  pkgs.librclone
                pkgs.yq
                pkgs.efibootmgr
                pkgs.grafana-loki
                pkgs.pm2
                pkgs.mosquitto
                pkgs.nixos-option
                pkgs.inotify-tools
                pkgs.bark-server
                pkgs.wyoming-satellite
                pkgs.mpg123
                pkgs.hassil
                pkgs.gnuplot
                pkgs.sunwait
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
               # inputs.say.packages.x86_64-linux.say
                self.packages.${pkgs.system}.health
                pkgs.nix-index
                pkgs.rich-cli
                pkgs.lsd
                pkgs.gedit
                pkgs.firefox-esr
                pkgs.vscodium
                pkgs.transmission_4-qt
                pkgs.file
                pkgs.chromium 	       # yuck
                pkgs.neovim
                pkgs.librewolf 	# privacy firefox
                pkgs.libsForQt5.qt5.qtwayland
                pkgs.jellyfin-ffmpeg   # transcoding
                pkgs.drawing 	       # simple image editing
                pkgs.vlc  			# media player
                #   amberol
                pkgs.cava
                pkgs.nordic 		# theme
                pkgs.papirus-icon-theme # theme
                pkgs.poweralertd
                pkgs.signal-desktop 		# signal messaging w/ API
                pkgs.signal-cli
                pkgs.speedtest-cli
                pkgs.jellyfin-media-player
                pkgs.jftui
                pkgs.keepass		# password management
                pkgs.gnome-terminal
                pkgs.gnome-text-editor
                pkgs.you-have-mail-cli   
                pkgs.bat
                pkgs.ripgrep
                pkgs.vim
                pkgs.libgedit-tepl
                pkgs.gedit
                pkgs.gthumb
                pkgs.ghostty
                pkgs.brave
                pkgs.systemctl-tui
                pkgs.cheat
                pkgs.pkg-config
                pkgs.fzf
                pkgs.xclip
                pkgs.jq
                pkgs.atuin
                pkgs.direnv
                pkgs.nix-direnv 
                pkgs.sops 		# secrets 
                pkgs.age		# actually good encryption
                pkgs.rage
                pkgs.syslogng
                pkgs.gum		# scripts 
                pkgs.wyoming-piper # wy0ming server
                pkgs.ripgrep 		# Better `grep`
                pkgs.fd
                pkgs.sd
                pkgs.gnumake
                pkgs.nil 		# Nix language server
                pkgs.nix-info
                pkgs.nixpkgs-fmt
                pkgs.scrcpy
                pkgs.nixos-anywhere
                pkgs.piper-tts
                pkgs.keyd
            ]     
        ];
        
    };}   
