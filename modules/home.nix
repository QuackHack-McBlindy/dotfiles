{ 
  config,
  lib,
  pkgs,
  ...
} : let
  inherit (lib)
    mkOption mkEnableOption types
    filterAttrs attrNames attrValues listToAttrs
    mkIf mkDerivedConfig concatLines;


  mkService = user: {
    name = "my.home-${user}";
    value = {
      wantedBy = [ "multi-user.target" ];
      description = "Setup my.home environment for ${user}.";
      serviceConfig = {
        Type = "oneshot";
        User = user;
        ExecStart = "${config.system.build.my.home-link}/bin/my.home-link";
      };
    };
  };

  my.homeFiles = attrValues (filterAttrs (_: v: v.enable) config.my.home);

in {
  options.my.home = mkOption {
    type = types.attrsOf (types.submodule ({ name, config, ... }: {
      options = {
        target = mkOption {
          type = types.str;
          default = name;
          description = "Target path relative to home directory";
        };
        source = mkOption {
          type = types.path;
          description = "Source file/directory path";
        };
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Whether to enable this entry";
        };
        recursive = mkOption {
          type = types.bool;
          default = false;
          description = "For directories, create recursive parent directories";
        };
      };
    }));
    default = {};
  };

  config = let
    users = attrNames (filterAttrs (_: u: u ? my && u.my ? home) config.users.users);

  in {
    system.build.my.home-link = pkgs.writeShellScriptBin "my.home-link" ''
      set -euo pipefail
      ${concatLines (map (f: ''
        target="$HOME/${f.target}"
        ${lib.optionalString f.recursive "mkdir -p \"$(dirname \"$target\")\""}
        ln -sfn "${f.source}" "$target"
      '') my.homeFiles)}
    '';

    systemd.services = lib.listToAttrs (map mkService users);
  };
}
