# dotfiles/modules/network/deploy-client.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
#  » ★ QuackHack-McBLindy.com ★ «
{
  config,
  lib,
  pkgs,
  self,
  ...
} : let
  potentialServers = lib.filter (cfg:
    lib.elem "wg-server" (cfg.config.this.host.modules.networking or [])
  ) (lib.attrValues self.nixosConfigurations);

  wgServer = if potentialServers != []
    then lib.head potentialServers
    else throw "No WireGuard server configuration found";

  builderPubKey = config.this.host.keys.publicKeys.builder
    or (throw "Set this.host.keys.publicKeys.builder to the pubkey of id_ed25519_builder");

  sshPort = config.this.user.me.sshPort or 2222;
in {
  config = lib.mkIf (lib.elem "deploy-client" config.this.host.modules.networking) {
    users.users.builder = {
      isSystemUser = true;
      group = "builder";
      openssh.authorizedKeys.keys = [
        ''command="sudo -n systemctl start auto-deploy.service",no-pty,no-port-forwarding,no-X11-forwarding,no-agent-forwarding ${builderPubKey}''
      ];
    };
    users.groups.builder = {};

    security.sudo.extraRules = [{
      users = [ "builder" ];
      commands = [{
        command = "/run/current-system/sw/bin/systemctl start auto-deploy.service";
        options = [ "NOPASSWD" ];
      }];
    }];

    networking.firewall.interfaces.wg0.allowedTCPPorts = [ sshPort ];

  };}
