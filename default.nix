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
  nixFiles = builtins.filter (f: builtins.match ".*\.nix" f != null)
               (builtins.map (file: ./bin + "/${file}")
                 (builtins.attrNames (import ./bin)));
in {
    imports = [ (modulesPath + "/installer/scan/not-detected.nix")
        ./modules
        ./bin
    ]; 
  
    nixpkgs.hostPlatform = config.this.host.system; 
    networking = {
        hostName = config.this.host.hostname;
        useDHCP = lib.mkDefault true;
#        hosts = {
#            config.this.host.ip = [ config.this.host.hostname".löcal" ];
#        };
   
   };}
