# dotfiles/modules/file.nix
{ 
  config,
  lib,
  pkgs,
  ...
} : with lib;
let
  homeBase = config.this.user.me.dotfilesDir + "/home"; # Since we are symlinkiong ./home > /home anyway
  sanitize = path: 
    replaceStrings ["/"] ["-"] (removePrefix "/" (removePrefix "./" path));
in {
  options.file = mkOption {
    type = types.attrsOf types.lines;
    default = {};
    description = "Files to create directly under ${homeBase}";
  };

  config.system.activationScripts.simpleFiles = let
    files = config.file;
  in {
    text = concatStringsSep "\n" (mapAttrsToList (path: content:
      let
        storeName = "file-${sanitize path}";
        storePath = pkgs.writeText storeName content;
        fullPath = "${homeBase}/${path}";
        dir = dirOf fullPath;
        username = config.this.user.me.name;
      in ''
        mkdir -p "${dir}"
        cp -f "${storePath}" "${fullPath}"
        chown "${username}:users" "${fullPath}"
        chmod 600 "${fullPath}"
        echo "Created file: ${fullPath}"
      '') files);
    deps = [];
    
  };}
