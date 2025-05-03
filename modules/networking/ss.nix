# modules/networking/ss.nix
{ 
  config,
  lib,
  pkgs,
  ...
} : with lib;
let
  cfg = config.services.shadowsocks-client;
  proxyUser = "ssclient";
  
in {
  options.services.shadowsocks-client = {
    enable = mkEnableOption "Shadowsocks client service";
    server = mkOption {
      type = types.str;
      default = "192.168.1.28";
      description = "Shadowsocks server IP address";
    };
    server_port = mkOption {
      type = types.port;
      default = 8388;
      description = "Shadowsocks server port";
    };
    local_port = mkOption {
      type = types.port;
      default = 1080;
      description = "Local port to listen on";
    };
    passwordFile = mkOption {
      type = types.path;
      default = config.sops.secrets.SHADOWSOCKS_PASSWORD.path;
      description = "Path to file containing Shadowsocks password";
    };
    method = mkOption {
      type = types.str;
      default = "aes-256-gcm";
      description = "Encryption method";
    };
    enableKillSwitch = mkOption {
      type = types.bool;
      default = true;
      description = "Enable firewall kill switch to prevent IP leaks";
    };
  };

  config = lib.mkIf (lib.elem "ss" config.this.host.modules.networking) {
    # Dedicated user for security
    users.users.${proxyUser} = {
      isSystemUser = true;
      group = proxyUser;
    };
    users.groups.${proxyUser} = {};

    systemd.services.shadowsocks-client = {
      description = "Shadowsocks Client Service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      
      serviceConfig = {
        User = proxyUser;
        Group = proxyUser;
        ExecStart = "${pkgs.shadowsocks-libev}/bin/ss-local -c /run/shadowsocks/client.json";
        Restart = "on-failure";
        RestartSec = "10s";
        AmbientCapabilities = mkIf cfg.enableKillSwitch [ "CAP_NET_ADMIN" ];
      };

      preStart = ''
        mkdir -p /run/shadowsocks
        chown ${proxyUser}:${proxyUser} /run/shadowsocks
        
        # Read password from secure file
        password=$(cat "${cfg.passwordFile}")
        
        cat > /run/shadowsocks/client.json <<EOF
        {
          "server": "${cfg.server}",
          "server_port": ${toString cfg.server_port},
          "local_port": ${toString cfg.local_port},
          "password": "$password",
          "method": "${cfg.method}"
        }
        EOF
        chmod 600 /run/shadowsocks/client.json
      '';
    };

    # Kill switch implementation using nftables
    networking.nftables.ruleset = mkIf cfg.enableKillSwitch ( ''
      table inet kill_switch {
        chain forward {
          type filter hook forward priority 0; policy drop;
        }

        chain output {
          type filter hook output priority 0; policy drop;
          
          # Allow loopback
          oifname "lo" accept
          
          # Allow established connections
          ct state established,related accept
          
          # Allow Shadowsocks server
          ip daddr ${cfg.server} tcp dport ${toString cfg.server_port} accept
          ip daddr ${cfg.server} udp dport ${toString cfg.server_port} accept
          
          # Allow local proxy
          ip daddr 127.0.0.1 tcp dport ${toString cfg.local_port} accept
          ip daddr 127.0.0.1 udp dport ${toString cfg.local_port} accept
        }
      }
    '');

    sops.secrets = {
        SHADOWSOCKS_PASSWORD = {
            sopsFile = ./../../secrets/SHADOWSOCKS_PASSWORD.yaml;
            owner = proxyUser;
            group = proxyUser;
            mode = "0440";
        };
    };

    environment.systemPackages = [ pkgs.shadowsocks-libev ];

  };}
