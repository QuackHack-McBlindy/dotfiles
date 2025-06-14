# dotfiles/default.nix
{
  config,
  self,
  lib,
  pkgs,
  modulesPath,
  ...
} : let
  sysHosts = builtins.attrNames self.nixosConfigurations;
  vmHosts = builtins.filter (host:
    self.nixosConfigurations.${host}.config.system.build ? vm
  ) sysHosts;  
  nixFiles = builtins.filter (f: builtins.match ".*\.nix" f != null)
               (builtins.map (file: ./bin + "/${file}")
                 (builtins.attrNames (import ./bin)));
in { # 🦆 duck say > eval all modules and all scripts on every host
    imports = [ (modulesPath + "/installer/scan/not-detected.nix")
        ./modules
        ./bin
    ]; 
    # 🦆 duck say > default configuration
    nixpkgs.hostPlatform = config.this.host.system; 
    networking = {
        hostName = config.this.host.hostname;
        useDHCP = lib.mkDefault true;           
   };}
