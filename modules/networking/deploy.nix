# dotfiles/modules/network/deploy.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
#  » ★ QuackHack-McBLindy.com ★ «

{
  config,
  lib,
  pkgs,
  self,
  ...
} : let
  cfg = config.services.auto-deploy-server;

  serverCfg = config.this.host;
  peerHosts = lib.filterAttrs (_: c:
    lib.elem "wg-client" (c.config.this.host.modules.networking or [])
  ) self.nixosConfigurations;
  peerWgIP    = h: h.config.this.host.wgip;
  peerSSHPort = h: h.config.this.user.me.sshPort or 2222;

  fanout = pkgs.writeShellApplication { /* unchanged */ };
in
{
  options.services.auto-deploy-server = {
    enable = lib.mkEnableOption "auto deploy webhook server";
    enableHmac = lib.mkOption {
      type = lib.types.bool;
      default = true;   # ← change to false if you want no-HMAC by default
    };
  };

  config = lib.mkIf (cfg.enable && lib.elem "wg-server" serverCfg.modules.networking) {
    sops.secrets = lib.mkIf cfg.enableHmac {
      auto_deploy_webhook_hmac = {
        sopsFile = ./../../secrets/hosts/${config.networking.hostName}/auto_deploy_webhook_hmac.yaml;
        owner = "root"; group = "root"; mode = "0400";
      };
    };

    services.webhook = { enable = true; port = 9000; hooks = []; };

    systemd.services.webhook = {
      after    = [ "build_config.service" ];
      requires = [ "build_config.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = { RuntimeDirectory = "webhook"; RuntimeDirectoryMode = "0700"; };

      preStart = ''
        set -eu
        ${lib.optionalString cfg.enableHmac ''
          SECRET=$(cat ${config.sops.secrets.auto_deploy_webhook_hmac.path})
        ''}
        cat > /run/webhook/hooks.json <<EOF
        [{
          "id": "auto-deploy",
          "execute-command": "${fanout}/bin/auto-deploy-fanout",
          "command-working-directory": "/",
          "pass-arguments-to-command": [],
          "trigger-rule": {
            "match": {
              "type": "payload-hmac-sha256",
              "secret": "${if cfg.enableHmac then "$SECRET" else ""}",
              "parameter": { "source": "header", "name": "X-Hub-Signature-256" }
            }
          }
        }]
        EOF
        chmod 600 /run/webhook/hooks.json
      '';

      script = lib.mkForce ''
        exec ${pkgs.webhook}/bin/webhook -hooks /run/webhook/hooks.json -port 9000 -verbose
      '';
    };

    networking.firewall.allowedTCPPorts = [ 9000 ];
    systemd.tmpfiles.rules = [ "d /var/lib/auto-deploy 0700 root root -" ];

  };}
