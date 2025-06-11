# dotfiles/bin/default.nix
{ 
    self,
    config,
    lib,
    pkgs,
    ...
} : let # 🦆 duck say > this file just sets simple helpers and auto imports all scripts
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
  
  # 🦆 duck say > Create helper functions for yo scripts
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

    # 🦆 duck say > check development enviorment exist yo!
    validate_devShell() {
      if [[ ! " ${lib.escapeShellArg (toString sysDevShells)} " =~ " $devShell " ]]; then
        echo -e "\033[1;31m❌ $1\033[0m Unknown devShell: $devShell" >&2
        echo "Available devShells: ${toString sysDevShells}" >&2
        exit 1
      fi
    }

    # 🦆 duck say > run commands safely, yo!
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

    say_duck() {
      echo -e "\e[3m\e[38;2;0;150;150m🦆 duck say >\e[0m $1"
    }

    # 🦆 duck say > fail? i usually don't, yo!
    type fail >/dev/null 2>&1 || fail() { 
      echo -e "$1" >&2
      exit 1
    }
    
    # 🦆 duck say > validate flags, yo!
    validate_flags() {
      verbosity_level=$(grep -o '?' <<< "$@" | wc -l)
      DRY_RUN=$(grep -q '!' <<< "$@" && echo true || echo false)
    }

    # 🦆 duck say > plays failing sound
    play_fail() {
      aplay "${config.this.user.me.dotfilesDir}/modules/themes/sounds/fail.wav" >/dev/null 2>&1
    }

    # 🦆 duck say > plays winning sound
    play_win() {
      aplay "${config.this.user.me.dotfilesDir}/modules/themes/sounds/win.wav" >/dev/null 2>&1
    }

    # 🦆 duck say > Prompt for input by voice
    mic_input() {
      yo-mic | jq -r '.transcription // empty'
    }
    
    # 🦆 duck say > validate host, yo!
    validate_host() {
      if [[ ! " ${lib.escapeShellArg (toString sysHosts)} " =~ " $host " ]]; then
        echo -e "\033[1;31m❌ $1\033[0m Unknown host: $host" >&2
        echo "Available hosts: ${toString sysHosts}" >&2
        exit 1
      fi
    }
  '';
in { # 🦆 duck say > import everythang in defined directories
    imports = builtins.map (file: import file {
        inherit self config lib cmdHelpers pkgs sysHosts;
    }) (
        importModulesRecursive ./config ++# 🦆 duck say > plus
        importModulesRecursive ./system ++# 🦆 duck say > plus
        importModulesRecursive ./security ++ # 🦆 duck say > plus plus plus lots of luck?
        importModulesRecursive ./maintenance ++
        importModulesRecursive ./productivity ++
        importModulesRecursive ./network ++
        importModulesRecursive ./misc # 🦆 duck say > last one i swear
        
    );} # 🦆 duck say > bye
