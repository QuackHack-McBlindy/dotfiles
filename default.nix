# dotfiles/default.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{
  config,
  self,
  lib,
  pkgs,
  modulesPath,
  ...
} : let # 🦆 duck say ⮞ get list of all them hosts yo
  sysHosts = builtins.attrNames self.nixosConfigurations; 

  # 🦆 duck say ⮞ virtual host? sounds like fake host to duck
  vmHosts = builtins.filter (host:
    self.nixosConfigurations.${host}.config.system.build ? vm
  ) sysHosts;  
  
  # 🦆 duck say ⮞ cool duck's write scripts eveery day yo  
  nixFiles = builtins.filter (f: builtins.match ".*\.nix" f != null)
               (builtins.map (file: ./bin + "/${file}")
                 (builtins.attrNames (import ./bin)));
                 
in { # 🦆 duck say ⮞ all machines needz some of dis
    imports = [ (modulesPath + "/installer/scan/not-detected.nix")
        self.inputs.yo.nixosModules.yo
        ./modules # 🦆 duck say ⮞ load ./modules/default.nix
        ./bin     # 🦆 duck say ⮞ loadz yo script's default.nix
    ]; 
    
    # 🦆 says ⮞ each host haz it's own system defined in dis `this` config
    nixpkgs.hostPlatform = config.this.host.system; 
    
    networking = { # 🦆 say ⮞ ducks don't like netz =( 
        hostName = config.this.host.hostname; # 🦆 says ⮞ here we go again with dis `this` and dat
        useDHCP = lib.mkDefault true; # 🦆 says ⮞ if nuthin else is said         
   };} # 🦆 says ⮞ i'll say dat's dat
