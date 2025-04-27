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
in {
    imports = [ (modulesPath + "/installer/scan/not-detected.nix")
            ./modules
            ./home
            ./bin
    ];
    
    networking.hostName = config.this.host.hostname;
    networking.useDHCP = lib.mkDefault true;
    nixpkgs.hostPlatform = config.this.host.system;
    

       
    }

    
