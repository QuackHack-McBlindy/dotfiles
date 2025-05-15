{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkOption types mkIf mkDefault;
  cfg = config.modules.services.nixCache;
in {
  options.modules.services.nixCache = {
    enable = mkEnableOption "Self-hosted Nix binary cache data";

    port = mkOption {
      type = types.port;
      default = 10000;
      description = "Port number for nix-serve";
    };

    user = mkOption {
      type = types.str;
      default = "root";
      description = "User to own the cache resources";
    };

    publicKey = mkOption {
      type = types.str;
      default = "cache:/pbj1Agw2OoSSDcClS69RHa1aNcwwTOX3GIEGKYwPc=";
      description = "Public key for the cache";
    };

    secretsPath = mkOption {
      type = types.path;
      default = ./../../secrets;
      description = "Path to secrets directory";
    };
  };

  config = mkIf cfg.enable {
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

    system.activationScripts.cacheConfig = {
      text = ''
        mkdir -p /etc/nix
        cat ${config.sops.secrets.nix_cache_private_key.path} > /etc/nix/private-key.pem
        cat ${config.sops.secrets.nix_cache_public_key.path} > /etc/nix/public-key.pem
      '';
    };

    sops.secrets = {
      nix_cache_public_key = {
        sopsFile = cfg.secretsPath + "/nixcache_public_desktop.yaml";
        owner = cfg.user;
        group = cfg.user;
        mode = "0440";
      };
      nix_cache_private_key = {
        sopsFile = cfg.secretsPath + "/nixcache_private_desktop.yaml";
        owner = cfg.user;
        group = cfg.user;
        mode = "0440";
      };
    };

    # Optional: Add automatic service dependencies
    systemd.services.nginx = {
      after = [ "nix-serve.service" ];
      requires = [ "nix-serve.service" ];
    };
  };
}
