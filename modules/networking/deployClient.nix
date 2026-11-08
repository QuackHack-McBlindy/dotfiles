# dotfiles/modules/network/deployClient.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
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

  # 🦆 the fleet-wide builder pubkey — set once, same on every host
  builderPubKey = config.this.host.keys.publicKeys.builder
    or (throw "Set this.host.keys.publicKeys.builder to the pubkey of id_ed25519_builder");

  sshPort = config.this.user.me.sshPort or 2222;
in {
  config = lib.mkIf (lib.elem "wg-client" config.this.host.modules.networking) {
    # 🦆 builder user already exists on every host for distributed builds —
    # give it a command-restricted entry that only starts auto-deploy.service
    users.users.builder = {
      isSystemUser = true;
      group = "builder";
      openssh.authorizedKeys.keys = [
        ''command="sudo -n systemctl start auto-deploy.service",no-pty,no-port-forwarding,no-X11-forwarding,no-agent-forwarding ${builderPubKey}''
      ];
    };
    users.groups.builder = {};

    # 🦆 one NOPASSWD rule, exactly that one command
    security.sudo.extraRules = [{
      users = [ "builder" ];
      commands = [{
        command = "/run/current-system/sw/bin/systemctl start auto-deploy.service";
        options = [ "NOPASSWD" ];
      }];
    }];

    # 🦆 SSH reachable only over wg0
    networking.firewall.interfaces.wg0.allowedTCPPorts = [ sshPort ];
  };}
