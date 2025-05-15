{ lib } :
let
  inherit (builtins) readDir filterAttrs attrNames pathExists;
  hostsDir = ../hosts;

  # Filter directories only
  hostDirs = lib.attrNames (lib.filterAttrs (_: v: v == "directory") (readDir hostsDir));

  # Load each host's `default.nix`
  loadHost = hostName: import (hostsDir + "/${hostName}");

  # Map over directories and generate a list of host configs
  hostModules = lib.genAttrs hostDirs (name: loadHost name);
in
  hostModules
