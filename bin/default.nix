# dotfiles/bin/default.nix
{ 
    self,
    config,
    lib,
    pkgs,
    ...
} : let
  inherit (lib) types mkOption mkEnableOption mkMerge;

  importModulesRecursive = dir:
    let
      entries = builtins.readDir dir;
      modules = lib.attrsets.mapAttrsToList (name: type:
        let path = dir + "/${name}";
        in if type == "directory" then
          importModulesRecursive path
        else if lib.hasSuffix ".nix" name then
          [ path ]
        else
          []
      ) entries;
    in lib.flatten modules;

  sysHosts = lib.attrNames self.nixosConfigurations;
  sysDevShells = lib.attrNames self.devShells; 
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

    validate_devShell() {
      if [[ ! " ${lib.escapeShellArg (toString sysDevShells)} " =~ " $devShell " ]]; then
        echo -e "\033[1;31m❌ $1\033[0m Unknown devShell: $devShell" >&2
        echo "Available devShells: ${toString sysDevShells}" >&2
        exit 1
      fi
    }

    run_cmd() {
      if $DRY_RUN; then
        echo "[DRY RUN] Would execute:"
        echo "  ''${@}"
        "''${@}"
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
        inherit self config lib cmdHelpers pkgs sysHosts;
    }) (
        importModulesRecursive ./config ++
        importModulesRecursive ./system ++
        importModulesRecursive ./security ++
        importModulesRecursive ./maintenance ++
        importModulesRecursive ./productivity ++
        importModulesRecursive ./network ++
        importModulesRecursive ./misc
        
    );}  
