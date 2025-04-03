{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkOption types mkIf;
  cfg = config.modules.services.nixCache;
  username = "pungkula";
in {
  options.modules.services.nixCache = {
    enable = mkEnableOption "Nix binary cache with web interface";

    port = mkOption {
      type = types.port;
      default = 10000;
      description = "Port number for nix-serve";
    };

    publicKey = mkOption {
      type = types.str;
      default = config.sops.secrets.nix_cache_public_key.path;
      description = "Path to public key file in Nix store";
    };
  };

  config = mkIf cfg.enable {
    nix.settings.trusted-public-keys = [ (builtins.readFile cfg.publicKey) ];

    services.nix-serve = {
      enable = true;
      port = cfg.port;
      secretKeyFile = config.sops.secrets.nix_cache_private_key.path;
    };

    # Keep the activation script to copy to /etc if needed by other services
    system.activationScripts.sshConfig = {
      text = ''
        mkdir -p /etc/nix
        cp ${config.sops.secrets.nix_cache_private_key.path} /etc/nix/private-key.pem
        cp ${cfg.publicKey} /etc/nix/public-key.pem
        chown ${username}:${username} /etc/nix/*.pem
        chmod 600 /etc/nix/private-key.pem
        chmod 644 /etc/nix/public-key.pem
      '';
      deps = ["sops-nix"];
    };

    # Rest of your configuration remains the same...
    networking.firewall.allowedTCPPorts = [ 80 cfg.port ];
    
    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts."cache" = {
        locations."/".proxyPass = 
          "http://${config.services.nix-serve.bindAddress}:${toString config.services.nix-serve.port}";
      };
    };

    sops.secrets = {
      nix_cache_public_key = {
        sopsFile = ./../../secrets/nixcache_public_desktop.yaml;
        owner = username;
        group = username;
        mode = "0440";
      };
      nix_cache_private_key = {
        sopsFile = ./../../secrets/nixcache_private_desktop.yaml;
        owner = username;
        group = username;
        mode = "0440";
      };
    };

    systemd.services.nginx = {
      after = [ "nix-serve.service" ];
      requires = [ "nix-serve.service" ];
    };
  };
}
