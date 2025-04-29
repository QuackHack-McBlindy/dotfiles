# lib/home.nix
{ 
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib)
    mkOption types filterAttrs mkIf mapAttrs' groupBy listToAttrs mapAttrsToList;

  # Recursive directory processing
  collectFiles = baseDir: let
    processEntry = path: type:
      if type == "directory" then
        lib.flatten (mapAttrsToList 
          (name: _: processEntry "${path}/${name}" (builtins.readFileType "${path}/${name}")) 
          (builtins.readDir path))
      else
        [{
          relPath = lib.removePrefix (toString baseDir + "/") path;
          inherit path type;
        }];
  in processEntry baseDir "directory";

  # Generate home links configuration
  generateLinksFromDir = { dir, user }: 
    listToAttrs (map ({ relPath, path, type }: 
      lib.nameValuePair relPath {
        inherit user;
        source = path;
        target = relPath;
        recursive = type == "directory";
        enable = true;
      }) (collectFiles dir));

  mkUserLinks = user: links: let
    userHome = config.users.users.${user}.home;
  in lib.concatMapStrings ({ target, source, recursive, ... }: ''
    full_target="${userHome}/${target}"
    echo "Linking [${user}]: ${toString source} -> $full_target"
    mkdir -vp "$(dirname "$full_target")"
    if [[ -e "$full_target" && ! -L "$full_target" ]]; then
      echo "Backing up existing file at $full_target"
      mv -f "$full_target" "$full_target.backup"
    fi
    ${if recursive then
      ''ln -vsfnT "${toString source}" "$full_target"'' 
     else
      ''ln -vsfn "${toString source}" "$full_target"''}
  '') links;

  enabledLinks = filterAttrs (_: v: v.enable) config.this.home;
  linksByUser = groupBy (link: link.user) (lib.attrValues enabledLinks);

in {
  options.this.home = mkOption {
    type = types.attrsOf (types.submodule ({ name, ... }: {
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
    description = "Home directory symlink configuration";
  };

  config = lib.mkIf (enabledLinks != {}) {
    system.activationScripts = lib.mapAttrs' (user: links: 
      lib.nameValuePair "home-links-${user}" {
        text = ''
          #!/usr/bin/env bash
          set -euo pipefail
          ${mkUserLinks user links}
        '';
        deps = [ "users" ];
      }
    ) linksByUser;
  };
}
