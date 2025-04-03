{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkOption types mkIf;
  cfg = config.modules.services.nixCache;
  username = "pungkula";  # Hardcoded user
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
      default = builtins.readFile /etc/nix/public-key.pem;
      description = "Public key contents (read directly from file)";
    };

    secretsPath = mkOption {
      type = types.path;
      default = ./../../secrets;
      description = "Path to secrets directory";
    };
  };

  config = mkIf cfg.enable {
    nix.settings.trusted-public-keys = [ cfg.publicKey ];

    services.nix-serve = {
      enable = true;
      port = cfg.port;
      secretKeyFile = "/etc/nix/private-key.pem";
    };

    networking.firewall.allowedTCPPorts = [ 80 cfg.port ];

    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts."cache" = {
        locations."/".proxyPass = 
          "http://${config.services.nix-serve.bindAddress}:${toString config.services.nix-serve.port}";
      };
    };

    system.activationScripts.sshConfig = {
      text = ''
        mkdir -p /etc/nix
        cat ${config.sops.secrets.nix_cache_private_key.path} > /etc/nix/private-key.pem
        cat ${config.sops.secrets.nix_cache_public_key.path} > /etc/nix/public-key.pem
      '';
    };

    sops.secrets = {
      nix_cache_public_key = {
        sopsFile = cfg.secretsPath + "/nixcache_public_desktop.yaml";
        owner = username;
        group = username;
        mode = "0440";
      };
      nix_cache_private_key = {
        sopsFile = cfg.secretsPath + "/nixcache_private_desktop.yaml";
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
