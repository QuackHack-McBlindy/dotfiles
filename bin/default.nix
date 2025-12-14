# dotfiles/bin/default.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 duck say ⮞ dis file just sets simple helpers, loads loggers and auto imports all scripts
    self,
    config,
    lib,
    pkgs,
    ...
} : let # 🦆 duck say ⮞ grabbin' some of dat sweet sweet nix option for fancy fancy configz
  inherit (lib) types mkOption mkEnableOption mkMerge;
  # 🦆 duck say ⮞ recursive nix importer — let'z waddle throu' them dirz through the reeds
  importModulesRecursive = dir: 
    let
      entries = builtins.readDir dir;# 🦆 duck say ⮞ read all files & subfolders in dir i say no duck left behind
      modules = lib.attrsets.mapAttrsToList (name: type: # 🦆 duck say ⮞ map over entries, check if directory or nix file
        let path = dir + "/${name}"; # 🦆 duck say ⮞ build path quackfully
        in if type == "directory" then
          importModulesRecursive path # 🦆 duck say ⮞ dive down the directory pond recursively
        else if lib.hasSuffix ".nix" name then
          [ path ] # 🦆 duck say ⮞ found nix file! add it to da list, quack yees
        else
          [] # 🦆 duck say ⮞ no nix file? no worries move along little ducky
      ) entries;
    in lib.flatten modules; # 🦆 duck say ⮞ flatten list of lists go single list - no nested duck nestz here

  # 🦆 duck say ⮞ list all hostz — all ducks in the pond
  sysHosts = lib.attrNames self.nixosConfigurations;
  # 🦆 duck say ⮞ list all devShells — ducklingz ready to hatch dem dev env
  sysDevShells = lib.attrNames self.devShells; 
  
  # 🦆 duck say ⮞ stash house for massive amounts of helper functions for yo scripts
  cmdHelpers = import ./helpers.nix {
    inherit config lib pkgs self sysHosts sysDevShells;
  };
  
  # 🦆BEtracin'⮞RUST'logggin'DUCK'pleasin'
  RustDuckTrace = import ./DuckTrace/rust.nix {
    inherit config lib pkgs self sysHosts sysDevShells;
  }; # 🦆 duck say ⮞ we be duckTracin' even when on da zzznake
  PythonDuckTrace = import ./DuckTrace/python.nix {
    inherit config lib pkgs self sysHosts sysDevShells;
  };  
in { # 🦆 duck say ⮞ import everythang in defined directories
    imports = builtins.map (file: import file {
        inherit self config lib cmdHelpers PythonDuckTrace RustDuckTrace pkgs sysHosts;
    }) (
        importModulesRecursive ./voice ++   # 🦆 duck say ⮞ ++
        importModulesRecursive ./system ++    # 🦆 duck say ⮞ ++
        importModulesRecursive ./home ++    # 🦆 duck say ⮞ ++
        importModulesRecursive ./security ++   # 🦆 duck say ⮞ ++
        importModulesRecursive ./maintenance ++ # 🦆 duck say ⮞ +++++ plus plus plus rots of duck's give lot'z of luck
        importModulesRecursive ./productivity ++
        importModulesRecursive ./network ++
        importModulesRecursive ./media ++
        importModulesRecursive ./files ++
        importModulesRecursive ./misc # 🦆 duck say ⮞ enuff enuff dis iz last you have ducks word on dat        
    );} # 🦆 duck say ⮞ bye!
