# dotfiles/lib/dirMap.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 duck say ⮞ dis provides helpful toolz when working with directories
  lib
} : {
    # 🦆 duck say ⮞ this reads all entries in da dir, filters only da directories, and imports each directory as a Nix expression
    mapHosts = dir: # 🦆 duck say ⮞ mapping the directory name to its imported content
        lib.mapAttrs' (name: _:
            lib.nameValuePair name (import (dir + "/${name}"))
        ) (lib.filterAttrs (n: t: t == "directory") (builtins.readDir dir));

    # 🦆 duck say ⮞ given da dir and a function this reads all entries,
    mapModules = dir: fn:
        # 🦆 duck say ⮞ filters nix files and applies function to each file's path
        lib.mapAttrs' # 🦆 duck say ⮞ maps each filename to da result of function
            (name: _: lib.nameValuePair (lib.removeSuffix ".nix" name) (fn (dir + "/${name}")))
            (lib.filterAttrs (n: _: lib.hasSuffix ".nix" n) (builtins.readDir dir));

    # 🦆 duck say ⮞ dis one map all .nix overlay files and return dem as a list for nixpkgs.overlays
    mapOverlays = dir: args:
      lib.mapAttrsToList
        (name: _: import (dir + "/${name}") args)
        (lib.filterAttrs (name: type: lib.hasSuffix ".nix" name) (builtins.readDir dir));

    }
