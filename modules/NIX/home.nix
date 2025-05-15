{ 
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib)
    mkOption types filterAttrs mkIf mapAttrs' groupBy listToAttrs mapAttrsToList;

  # Generate home links configuration from directory contents
  generateLinksFromDir = { dir, user }: let
    entries = builtins.readDir dir;
    files = mapAttrsToList (name: type: { inherit name type; }) entries;
  in listToAttrs (map ({ name, type }: 
    lib.nameValuePair name {
      inherit user;
      source = dir + "/${name}";
      target = name;
      recursive = type == "directory";
      enable = true;
    }) files);

#######
#  inherit (lib)
#    mkOption types filterAttrs mkIf mapAttrs' groupBy;

  mkUserLinks = user: links: let
    userHome = config.users.users.${user}.home;  # Implicit user existence check
  in lib.concatMapStrings ({ target, source, recursive, ... }: ''
    target="${userHome}/${target}"
    echo "Linking [${user}]: ${toString source} -> $target"
    mkdir -vp "$(dirname "$target")"
    if [[ -e "$target" && ! -L "$target" ]]; then
      echo "Backing up existing file at $target"
      mv -f "$target" "$target.backup"
    fi
    ${if recursive then
      ''ln -vsfnT "${toString source}" "$target"'' 
     else
      ''ln -vsfn "${toString source}" "$target"''}
  '') links;

  enabledLinks = filterAttrs (_: v: v.enable) config.this.home;
  linksByUser = groupBy (link: link.user) (lib.attrValues enabledLinks);

in {
  options.this.home = mkOption {
    type = types.attrsOf (types.submodule ({name, config, ...}: {
      options = {
        user = mkOption {
          type = types.str;
          default = "pungkula";
          description = "User account for the link";
        };
        target = mkOption {
          type = types.str;
          default = name;
          description = "Target path relative to home";
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
        recursive = mkOption {
          type = types.bool;
          default = false;
          description = "Create directory symlinks recursively";
        };
      };
    }));
    default = {};
  };

  config = mkIf (enabledLinks != {}) {
#    meta.attributes = { inherit generateLinksFromDir; };
    system.activationScripts = mapAttrs' (user: links: 
      lib.nameValuePair "home-links-${user}" {
        text = ''
          #!/usr/bin/env bash
          set -euo pipefail  # Enable strict error handling
          ${mkUserLinks user links}
        '';
        deps = [ "users" ];  # Ensure users are created first
      }
    ) linksByUser;
  };
#  meta.attributes = { inherit generateLinksFromDir; };
}
