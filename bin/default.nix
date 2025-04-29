{ 
  config,
  pkgs,
  self,
  lib,
  ...
}: let
  inherit (lib) types mkOption;

  importModulesRecursive = dir:
    let
      entries = builtins.readDir dir;
      processEntry = name: type:
        if type == "directory" then
          importModulesRecursive (dir + "/${name}")
        else if type == "regular" && lib.hasSuffix ".nix" name then
          [ (dir + "/${name}") ]
        else [];
    in
      lib.lists.flatten (lib.attrsets.mapAttrsToList processEntry entries);

  sysHosts = lib.attrNames self.nixosConfigurations;

  
  cmdHelpers = ''
    parse_flags() {
      VERBOSE=0
      DRY_RUN=false
      HOST=""
      for arg in "$@"; do
        case "$arg" in
          '?') ((VERBOSE++)) ;;
          '!') DRY_RUN=true ;;
          *) HOST="$arg" ;;
        esac
      done
      FLAGS=()
      (( VERBOSE > 0 )) && FLAGS+=(--show-trace "-v''${VERBOSE/#0/}")
    }

    run_cmd() {
      if $DRY_RUN; then
        echo "[DRY RUN] Would execute:"
        echo "  ''${@}"
      else
        if (( VERBOSE > 0 )); then
          echo "Executing: ''${@}"
        fi
        "''${@}"
      fi
    }

    fail() {
      echo -e "\033[1;31m❌ $1\033[0m" >&2
      exit 1
    }

    validate_flags() {
      verbosity_level=$(grep -o '?' <<< "$@" | wc -l)
      DRY_RUN=$(grep -q '!' <<< "$@" && echo true || echo false)
    }

    validate_host() {
      if [[ ! " ${lib.escapeShellArg (toString sysHosts)} " =~ " $host " ]]; then
        echo -e "\033[1;31m❌ $1\033[0m Unknown host: $host" >&2
        echo "Available hosts: ${toString sysHosts}" >&2
        exit 1
      fi
    }
  '';

in {
    imports = builtins.map (file: import file {
      # Explicitly pass cmdHelpers to child modules
      inherit self config lib cmdHelpers pkgs sysHosts;
    }) (importModulesRecursive ./bin);
    
}
