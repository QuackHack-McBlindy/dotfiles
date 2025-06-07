# dotfiles/modules/default.nix
{ 
  config,
  lib,
  pkgs,
  ...
} : let
  inherit (lib) types mkOption mkEnableOption mkMerge;
  importModulesRecursive = dir:
    let
      entries = builtins.readDir dir;
      processEntry = name: type:
        if type == "directory" then
          importModulesRecursive (dir + "/${name}")
        else if type == "regular" && lib.hasSuffix ".nix" name then
          [ (dir + "/${name}") ]
        else
          [];
    in
      lib.lists.flatten (lib.attrsets.mapAttrsToList processEntry entries);      
in {
    imports = [ ./security.nix ./this.nix ./yo.nix ] ++
        (importModulesRecursive ./hardware) ++
        (importModulesRecursive ./system) ++
        (importModulesRecursive ./networking) ++
        (importModulesRecursive ./services) ++
        (importModulesRecursive ./programs) ++
        (importModulesRecursive ./themes) ++
        (importModulesRecursive ./virtualisation);
    
        }
