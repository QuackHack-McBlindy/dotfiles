# dotfiles/lib/dirMap.nix
{ 
  lib
} : {
    mapHosts = dir:
        lib.mapAttrs' (name: _: 
            lib.nameValuePair name (import (dir + "/${name}"))  
        ) (lib.filterAttrs (n: t: t == "directory") (builtins.readDir dir));

    mapModules = dir: fn:
        lib.mapAttrs'
            (name: _: lib.nameValuePair (lib.removeSuffix ".nix" name) (fn (dir + "/${name}")))
            (lib.filterAttrs (n: _: lib.hasSuffix ".nix" n) (builtins.readDir dir));
    }
