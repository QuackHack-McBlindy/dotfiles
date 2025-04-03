{ lib, config, pkgs, ... }:
let
  cfg = config.yo;
  GITHUB_REPO = cfg.githubRepo;
  GITHUB_URL = "https://github.com/${lib.escapeShellArg GITHUB_REPO}.git";
in {
  options.yo = {
    enable = lib.mkEnableOption "Enable the yo CLI tool";
    host = lib.mkOption {
      type = lib.types.str;
      default = "${config.networking.hostName}";
      description = "Hostname of the machine";
    };
    username = lib.mkOption {
      type = lib.types.str;
      default = "${config.networking.hostName}";
      description = "Username for the machine";
    };
    sopsSecretDir = lib.mkOption {
      type = lib.types.str;
      default = "~/dotfiles/secrets/${config.yo.host}";
      description = "Location to store host specific sops secrets";
    };
    githubRepo = lib.mkOption {
      type = lib.types.str;
      default = "yourusername/dotfiles";
      description = "GitHub repository for dotfiles (username/repo)";
    };
    autoPull = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Automatically pull before rebuilding";
    };
    rebuildFlake = lib.mkOption {
      type = lib.types.str;
      default = "~/dotfiles#${config.yo.host}";
      description = "Flake target for rebuilding (e.g., 'path#hostname')";
    };

  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "yo" ''
        set -eo pipefail

        # Parse flags
        VERBOSE=0
        DRY_RUN=0
        while [[ $# -gt 0 ]]; do
          case "$1" in
            -!|--dry-run) DRY_RUN=1; shift ;;
            -\?*) VERBOSE=$((${#1} - 1)); shift ;;  # -? → 1, -?? → 2, etc.
            -h|--help) exec man yo ;;  # Assumes a manpage exists
            *) break ;;
          esac
        done

        cmd="$1"
        shift || true

        case "$cmd" in
          rebuild|rb)
            echo "🔨 Rebuilding system..."
            ${lib.optionalString (DRY_RUN == 1) "echo 'DRY RUN: Not actually rebuilding!'"}
            FLAGS=""
            (( DRY_RUN )) && FLAGS+=" --dry-run"
            (( VERBOSE >= 1 )) && FLAGS+=" --print-build-logs"
            sudo nixos-rebuild switch --flake "${cfg.rebuildFlake}" $FLAGS
            ;;

          gc|c)
            echo "🗑️ Cleaning garbage..."
            nix-collect-garbage -d
            nix-store --optimise
            ;;

          pull)
            echo "⬇️ Pulling dotfiles from ${GITHUB_URL}"
            git -C "$(dirname ${lib.escapeShellArg cfg.rebuildFlake%%#*})" pull ${GITHUB_URL}
            ;;

          push)
            echo "⬆️ Pushing dotfiles to ${GITHUB_URL}"
            git -C "$(dirname ${lib.escapeShellArg cfg.rebuildFlake%%#*})" push ${GITHUB_URL}
            ;;

          *)
            echo "Usage: yo [--dry-run] [--help] COMMAND [ARGS...]"
            echo "Commands:"
            echo "  rebuild, rb    Rebuild system configuration"
            echo "  gc, clean        Clean nix store garbage"
            echo "  pull           Pull dotfiles from GitHub"
            echo "  push           Push dotfiles to GitHub"
            exit 1
            ;;
        esac
      '')
    ];
  };
}
