{ 
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib)
    mkOption mkEnableOption types
    filterAttrs mkIf mkMerge groupBy mapAttrs';

#dconf dump / > ~/dotfiles/dconf-settings.ini

#home.activation.dconfLoad = ''
#  if [ -e ~/dotfiles/dconf-settings.ini ]; then
#    dconf load / < ~/dotfiles/dconf-settings.ini
#  fi
#'';

  mkUserService = user: links: {
    "home-${user}" = {
      wantedBy = ["multi-user.target"];
      description = "Set up home directory links for ${user}";
      serviceConfig = {
        Type = "oneshot";
        User = user;
        ExecStart = "${config.system.build.this.home-links.${user}}/bin/my-home-link-${user}";
        UMask = "0077";
        PrivateTmp = true;
      };
    };
  };

  homeLinks = filterAttrs (_: v: v.enable) config.this.home;
  linksByUser = groupBy (link: link.user) (lib.attrValues homeLinks);

in {
  options.this.home = mkOption {
    type = types.attrsOf (types.submodule ({name, config, ...}: {
      options = {
        user = mkOption {
          type = types.str;
          default = "pungkula";
          description = "User account for which the link is created";
        };
        target = mkOption {
          type = types.str;
          default = builtins.baseNameOf config.source;  # Auto-detect from source
          defaultText = "baseNameOf source";
          description = "Relative target path in home directory";
        };
        source = mkOption {
          type = types.path;
          description = "Source path (relative to this Nix file)";
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
    system.build.this.home-links = lib.mapAttrs (user: links:
      pkgs.writeShellScriptBin "my-home-link-${user}" ''
        set -euo pipefail
        ${lib.concatMapStrings ({target, source, ...}: ''
          target="$HOME/${target}"
          echo "Linking: ${toString source} -> $target"
          mkdir -vp "$(dirname "$target")"
          ln -vsfn "${toString source}" "$target"
        '') links}
      ''
    ) linksByUser;

    systemd.services = mkMerge (
      lib.mapAttrsToList mkUserService linksByUser
    );
  };
}
