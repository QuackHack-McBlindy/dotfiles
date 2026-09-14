# dotfiles/bin/system/deploy.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 duck say ⮞ yubikey encrypted deployment yystem - built by ducks for ducks
  self,
  config,
  pkgs,
  cmdHelpers,
  ...
} : let
  sysHosts = builtins.attrNames self.nixosConfigurations;
  vmHosts = builtins.filter (host:
    self.nixosConfigurations.${host}.self.config.system.build ? vm
  ) sysHosts;
in {
  yo.scripts = {
   dry = {
     description = "Build and deploy a NixOS configuration to a remote host. Bootstraps, builds locally, activates remotely, and auto-tags the generation.";
     category = "🖥️ System Management";
     code = ''
       ${cmdHelpers}
       echo "$DRY_RUN"
       echo "$VERBOSE"
     '';

    };

  };}
