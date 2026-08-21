# dotfiles/modules/services/duckdns.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ 
  config,
  lib,
  pkgs,
  ...
} : let
  domainsPath = {
    homie   = config.sops.secrets.duckdns-gh-quackhack.path;
    nasty   = config.sops.secrets.duckdns-x.path;
    desktop = config.sops.secrets.duckdns-gh-pungkula.path;
  }.${config.this.host.hostname};

  tokenPath = {
    homie   = config.sops.secrets.duckdns-gh-quackhack-token.path;
    nasty   = config.sops.secrets.duckdns-x-token.path;
    desktop = config.sops.secrets.duckdns-gh-pungkula-token.path;
  }.${config.this.host.hostname};
    
in {
  config = lib.mkIf (lib.elem "duckdns" config.this.host.modules.services) {

    services.duckdns = {
      enable = true;
      domainsFile = domainsPath;
      tokenFile = tokenPath;
    };

    users.groups.duckdns = {};

    users.users.duckdns = {
      isSystemUser = true;
      group = "duckdns";
    };

    sops.secrets = {
      duckdns-x = {
        sopsFile = ./../../secrets/duckdns-x.yaml;
        owner = "duckdns";
        group = "duckdns";
        mode = "0660";
      };
      duckdns-x-token = {
        sopsFile = ./../../secrets/duckdns-x-token.yaml;
        owner = "duckdns";
        group = "duckdns";
        mode = "0660";
      };      
      duckdns-gh-pungkula = {
        sopsFile = ./../../secrets/duckdns-gh-pungkula.yaml;
        owner = "duckdns";
        group = "duckdns";
        mode = "0660";
      };
      duckdns-gh-pungkula-token = {
        sopsFile = ./../../secrets/duckdns-gh-pungkula-token.yaml;
        owner = "duckdns";
        group = "duckdns";
        mode = "0660";
      };      
      duckdns-gh-quackhack = {
        sopsFile = ./../../secrets/duckdns-gh-quackhack.yaml;
        owner = "duckdns";
        group = "duckdns";
        mode = "0660";
      };
      duckdns-gh-quackhack-token = {
        sopsFile = ./../../secrets/duckdns-gh-quackhack-token.yaml;
        owner = "duckdns";
        group = "duckdns";
        mode = "0660";
      };      
    };
        
  };}
