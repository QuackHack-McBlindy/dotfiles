# nix-instantiate --eval --strict -A my.host --json default.nix
let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-23.11.tar.gz";
  lib = import (nixpkgs + "/lib");
  eval = lib.evalModules {
    modules = [
      ./modules/my.nix
      {
        # Mock minimal config
        networking.hostName = "test";
        _module.check = true;  # Enable strict checking
      }
    ];
  };
in eval.config
