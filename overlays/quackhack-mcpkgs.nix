# dotfiles/overlays/quackhack-mcpkgs.nix ⮞
{  # 🦆 ⮞ overlay that moves my packages into nixpkgs
  self,
  inputs,
  ...
} : final: prev: let
  # 🦆 says ⮞ use nixpkgs lib
  lib = inputs.nixpkgs.lib;

  # 🦆 says ⮞ my pkgs
  quackpackDir = ./../packages;

  # 🦆 says ⮞ get dem files
  packageFiles = builtins.attrNames (lib.filterAttrs (n: v: v == "regular") (builtins.readDir quackpackDir));

  # 🦆 says ⮞ strip nix suffix & import via callPackage
  packageSet = lib.genAttrs (map (name: lib.removeSuffix ".nix" name) packageFiles) (name:
    let path = quackpackDir + "/${name}.nix";
    in if builtins.pathExists path
       then final.callPackage path { inherit self; }
       else null
  );

in # 🦆 says ⮞ now use ${pkgs.myPackage}
  packageSet
