# dotfiles/modules/programs/firejail.nix
{ config, self, lib, pkgs, ... }:
let
  cfg = config.this.host.modules.programs;

  proxyFirewall = pkgs.writeText "firefox-proxy.net" ''
    *filter
    :INPUT DROP [0:0]
    :FORWARD DROP [0:0]
    :OUTPUT DROP [0:0]

    -A INPUT -i lo -j ACCEPT
    -A OUTPUT -o lo -j ACCEPT

    -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
    -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

    COMMIT
  '';

  proxyFirewall6 = pkgs.writeText "firefox-proxy6.net" ''
    *filter
    :INPUT DROP [0:0]
    :FORWARD DROP [0:0]
    :OUTPUT DROP [0:0]

    -A INPUT -i lo -j ACCEPT
    -A OUTPUT -o lo -j ACCEPT
    -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

    COMMIT
  '';

  firefoxIcon = "${self}/modules/themes/icons/firefox.png";

  jailfoxDesktopEntry = pkgs.writeText "jailfox.desktop" ''
    [Desktop Entry]
    Type=Application
    Name=Firefox (Firejail)
    Comment=Firefox running in Firejail
    Exec=jailfox %u
    Icon=${firefoxIcon}
    Terminal=false
    Categories=Network;WebBrowser;
    MimeType=text/html;text/xml;application/xhtml+xml;
  '';

  torfoxDesktopEntry = pkgs.writeText "torfox.desktop" ''
    [Desktop Entry]
    Type=Application
    Name=Firefox (Tor)
    Comment=Firefox running over Tor
    Exec=torfox %u
    Icon=${firefoxIcon}
    Terminal=false
    Categories=Network;WebBrowser;
    MimeType=text/html;text/xml;application/xhtml+xml;
  '';
  
  localProfile = pkgs.writeText "firefox.local" ''    
    # /etc/firejail/firefox.local
    #
    # Local Firejail overrides for Firefox.
    # This file is included by firefox.profile before globals.local.
    # It is the correct place for user-specific customizations.
    #
    # IMPORTANT:
    # - Do NOT put "include /etc/firejail/firefox.local" in this file.
    #   That is only the Nix store stub. Your real file must contain rules.
    # - Comments start with #.
    # - ''${HOME}, ''${RUNUSER}, etc. are expanded by Firejail.
    #
    # Test with:
    #   firejail --profile=firefox firefox
    #   firejail --debug-firefox firefox
    
    # ---------------------------------------------------------------------
    # Filesystem access
    # ---------------------------------------------------------------------
    
    # Firefox already has whitelisted access to its own config/cache dirs.
    # To let Firefox access other directories, both noblacklist and whitelist.
    # Uncomment the ones you need.
    
    # Downloads
    noblacklist ''${HOME}/Downloads
    whitelist ''${HOME}/Downloads
    
    # Documents (for uploading files)
    # noblacklist ''${HOME}/Documents
    # whitelist ''${HOME}/Documents
    
    # Pictures (for uploading images)
    # noblacklist ''${HOME}/Pictures
    # whitelist ''${HOME}/Pictures
    
    # Music/Videos (for uploading media)
    # noblacklist ''${HOME}/Music
    # whitelist ''${HOME}/Music
    # noblacklist ''${HOME}/Videos
    # whitelist ''${HOME}/Videos
    
    # Trash (so deleted downloads go to trash correctly)
    # noblacklist ''${HOME}/.local/share/Trash
    # whitelist ''${HOME}/.local/share/Trash
    
    # If you use a custom profile directory:
    # whitelist ''${HOME}/.mozilla/firefox/yourprofile.default
    
    # Make a directory read-only:
    # read-only ''${HOME}/Documents
    
    # Blacklist sensitive directories (recommended):
    # blacklist ''${HOME}/.ssh
    # blacklist ''${HOME}/.gnupg
    # blacklist ''${HOME}/.config/keepassxc
    # blacklist ''${HOME}/.password-store
    
    # ---------------------------------------------------------------------
    # System files
    # ---------------------------------------------------------------------
    
    # private-etc is already set to "firefox" in firefox.profile.
    # Add more entries by repeating private-etc:
    # private-etc firefox,fonts,resolv.conf,ssl
    
    # Allow access to system fonts, icons, themes:
    # whitelist /usr/share/fonts
    # whitelist /usr/share/icons
    # whitelist /usr/share/themes
    # whitelist /usr/share/mime
    
    # ---------------------------------------------------------------------
    # D-Bus
    # ---------------------------------------------------------------------
    
    # The default profile already filters D-Bus and allows org.mozilla.*.
    # Add more rules if needed. For file chooser portals:
    # dbus-user.talk org.freedesktop.portal.*
    # dbus-user.own org.freedesktop.portal.*
    
    # For notifications:
    # dbus-user.talk org.freedesktop.Notifications
    # dbus-user.own org.freedesktop.Notifications
    
    # For secret service (password manager integration):
    # dbus-user.talk org.freedesktop.secrets
    # dbus-user.own org.freedesktop.secrets
    
    # ---------------------------------------------------------------------
    # Network
    # ---------------------------------------------------------------------
    
    # Disable network access entirely (offline mode):
    # net none
    
    # Allow only local network:
    # net none
    # net ${lib.head config.this.host.interface}
    # net enp116s0
    net gluenet
    netfilter ${proxyFirewall}
    netfilter6 ${proxyFirewall6}
    
    # ---------------------------------------------------------------------
    # Sound
    # ---------------------------------------------------------------------
    
    # Disable sound:
    # nosound
    
    # Allow sound but block microphone:
    # nosound
    # alsa
    # pulse
    
    # ---------------------------------------------------------------------
    # Binary whitelisting
    # ---------------------------------------------------------------------
    
    # Uncomment to restrict executables Firefox can run.
    # See firefox.profile comments for suggestions.
    # private-bin bash,dbus-launch,dbus-send,env,firefox,sh,which
    # private-bin basename,bash,cat,dirname,expr,false,firefox,firefox-wayland,getenforce,ln,mkdir,pidof,restorecon,rm,rmdir,sed,sh,tclsh,true,uname
    
    # ---------------------------------------------------------------------
    # Hardware
    # ---------------------------------------------------------------------
    
    # Allow a specific USB device (e.g. YubiKey for WebAuthn):
    # usb-device 1050:0407
    
    # Allow webcam:
    # noblacklist /dev/video*
    # whitelist /dev/video*
    
    # Allow microphone:
    # noblacklist /dev/snd/*
    # whitelist /dev/snd/*
    
    # ---------------------------------------------------------------------
    # Resource limits
    # ---------------------------------------------------------------------
    
    # rlimit-as 4G
    # rlimit-nproc 1000
    # rlimit-cpu 3600
    
    # ---------------------------------------------------------------------
    # Seccomp
    # ---------------------------------------------------------------------
    
    # Default seccomp is enabled in globals.local.
    # To drop additional syscalls:
    # seccomp.drop syscall1,syscall2
    
    # ---------------------------------------------------------------------
    # Other
    # ---------------------------------------------------------------------
    
    # Add environment variable:
    # setenv FOO bar
    
    # Include another local file:
    # include /etc/firejail/firefox-extra.local
  '';  

  
  redsocksConf = pkgs.writeText "redsocks.conf" ''
    base {
      log_debug = off;
      log_info  = on;
      daemon    = off;
      redirector = iptables;
    }
  
    redsocks {
      local_ip   = 127.0.0.1;
      local_port = 9040;
      ip         = 192.168.1.28;
      port       = 8888;
      type       = http-connect;
    }
  '';
  

in {
  config = lib.mkIf (lib.elem "firefox" cfg) {

    programs.firejail = {
      enable = true;
      wrappedBinaries = {
        jailfox = {
          executable = "${pkgs.firefox-esr}/bin/firefox-esr";
          profile = "${pkgs.firejail}/etc/firejail/firefox.profile";
          desktop = jailfoxDesktopEntry;
          extraArgs = [
            "--ignore=private-dev"
            "--env=GTK_THEME=Adwaita:dark"
            "--dbus-user.talk=org.freedesktop.Notifications"

            "--net=gluenet"
            "--ip=10.100.100.2"
            "--defaultgw=10.100.100.1"

            "--netfilter=${proxyFirewall}"
          ];
        };
        
        
        torfox = {
          executable = "${pkgs.firefox-esr}/bin/firefox-esr";
          profile = "${pkgs.firejail}/etc/firejail/firefox.profile";
          desktop = torfoxDesktopEntry;
          extraArgs = [
            "--ignore=private-dev"
            "--env=GTK_THEME=Adwaita:dark"
            "--dbus-user.talk=org.freedesktop.Notifications"
            "--net=tornet"
            "--dns=10.100.100.1"
          ];
        };
      };
    };


    environment.etc."firejail/firefox.local".source = localProfile;
    file.".config/firejail/firefox.local" = 
      lib.concatStringsSep "\n" (lib.splitString "\n" (builtins.readFile localProfile)) + "\n";

    networking = {
      
      nftables = {
        enable = true;
        ruleset = ''
          table ip nat {
            chain PREROUTING {
              type nat hook prerouting priority dstnat; policy accept;
              iifname "gluenet" meta l4proto tcp dnat to 127.0.0.1:9040
            }
          }
        '';
      };
      
      firewall = {
        interfaces.gluenet = {
          allowedTCPPorts = [ 9040 ];
        };
      };
      
      networkmanager.ensureProfiles.profiles = {
        gluenet = {
          connection = {
            id = "gluenet";
            type = "bridge";
            interface-name = "gluenet";
            autoconnect = true;
          };
          ipv4 = {
            method = "manual";
            address1 = "10.100.100.1/24";
          };
          ipv6.method = "disabled";
          bridge = {
            stp = false;
            forward-delay = 0;
          };
        };
      };
    };

    boot.kernel.sysctl = {
      "net.ipv4.conf.gluenet.route_localnet" = 1;
    };
           

    systemd.services.redsocks = {
      description = "Transparent redirector → gluetun HTTP proxy";
      wantedBy = [ "multi-user.target" ];
      after = [ "NetworkManager-wait-online.service" ];
      serviceConfig = {
        ExecStart = "${pkgs.redsocks}/bin/redsocks -c ${redsocksConf}";
        Restart = "always";
        RestartSec = "2s";
      };
    };
    
    sops.secrets = {
      SHADOWSOCKS_PASSWORD = {
        sopsFile = ./../../secrets/SHADOWSOCKS_PASSWORD.yaml;
        owner = config.this.user.me.name;
        group = config.this.user.me.name;
        mode = "0440";
      };
    };
    
  };}
