# bin/health.nix
{
  pkgs,
  lib,
  sysHosts,
  cmdHelpers,
  ...
} : let
  importedFiles = lib.mapAttrs
    (name: _: import (./. + "/${name}"))
    (lib.filterAttrs (name: type: name != "default.nix" && lib.hasSuffix ".nix" name) (builtins.readDir ./.));
in
  importedFiles // {
  # your custom definitions

    cmdHelpers = ''
        tag_generation() {
          CURRENT_GEN=$(${pkgs.nix}/bin/nix-env -p /nix/var/nix/profiles/system --list-generations | grep "(current)" | awk '{print $1}')
          COMMIT_HASH=$(git -C /etc/nixos rev-parse HEAD)
          git -C /etc/nixos tag -f "generation-$CURRENT_GEN" "$COMMIT_HASH"
          echo "🔖 Tagged generation $CURRENT_GEN → commit $COMMIT_HASH"
        }

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
          if [[ ! " ${toString sysHosts} " =~ " $host " ]]; then
            echo -e "\033[1;31m❌ $1\033[0m Unknown host: $host" >&2
            echo "Available hosts: ${toString sysHosts}" >&2
            exit 1
          fi
        }  
    '';
}
