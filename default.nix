{
  config,
  self,
  lib,
  pkgs,
  modulesPath,
  ...
} : let

  sysHosts = builtins.attrNames self.nixosConfigurations;
  isoHosts = builtins.attrNames (self.installerIsos or {});
  vmHosts = builtins.filter (host:
    self.nixosConfigurations.${host}.config.system.build ? vm
  ) sysHosts;
  
  # List all files in the ./bin directory and filter for .nix files
  nixFiles = builtins.filter (f: builtins.match ".*\.nix" f != null)
               (builtins.map (file: ./bin + "/${file}")
                 (builtins.attrNames (import ./bin)));

in {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./modules
    ./home
    ./bin
  ]; #++ (builtins.attrValues (lib.mapAttrs
#    (name: _: import (./bin) { inherit self config pkgs lib; })
#    (lib.filterAttrs (name: type: name != "default.nix" && lib.hasSuffix ".nix" name) (builtins.readDir ./bin))
#  ));

  networking.hostName = config.this.host.hostname;
  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = config.this.host.system;
}
