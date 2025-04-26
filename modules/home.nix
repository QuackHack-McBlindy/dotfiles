{ 
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib)
    mkOption mkEnableOption types
    filterAttrs attrNames attrValues listToAttrs
    mkIf mkMerge mkDefault;

  mkUserService = user: {
    "home-${user}" = {
      wantedBy = ["multi-user.target"];
      description = "Set up home directory links for ${user}";
      serviceConfig = {
        Type = "oneshot";
        User = user;
        # Ensure script path is fully qualified
        ExecStart = "${config.system.build.my.home-link}/bin/my.home-link";
        # Protect against permission issues
        UMask = "0077";
        # Isolate environment
        PrivateTmp = true;
        # Set HOME explicitly despite User= directive
        Environment = "HOME=%d/%U";
      };
      # Trigger service when any source files change
      restartTriggers = [config.system.build.my.home-link];
    };
  };

  homeLinks = filterAttrs (_: v: v.enable) config.my.home;

in {
  options.my.home = mkOption {
    type = types.attrsOf (types.submodule ({name, config, ...}: {
      options = {
        target = mkOption {
          type = types.str;
          default = name;
          example = ".config/file.json";
          description = "Relative target path in home directory";
        };
        source = mkOption {
          type = types.path;
          description = "Absolute source path for file/link";
        };
        recursive = mkOption {
          type = types.bool;
          default = false;
          description = "Recursive mode";
        };
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Whether to enable this link";
        };
      };
    }));
    default = {};
  };

  config = mkIf (homeLinks != {}) {
    system.build.my.home-link = pkgs.writeShellScriptBin "my.home-link" ''
      set -euo pipefail
      ${lib.concatMapStrings ({target, source, ...}: ''
        target="$HOME/${target}"
        echo "Linking: ${source} -> $target"
        mkdir -vp "$(dirname "$target")"
        ln -vsfn "${source}" "$target"
      '') (attrValues homeLinks)}
    '';

    systemd.services = mkMerge (map mkUserService 
      (attrNames (filterAttrs (_: u: u ? my.home) config.users.users)));
  };
}
