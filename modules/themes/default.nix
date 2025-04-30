# modules/themes/default.nix
{ 
  lib,
  config,
  ...
} : with lib;
let
  cfg = config.this.theme;
  themePath = ./css + "/${cfg.name}";
in {
  options.this.theme = {
    name = mkOption {
      type = types.str;
      default = "crazy.css";
      description = "Active theme file name";
      apply = v:
        if ! builtins.pathExists (./css + "/${v}") 
        then throw "Theme ${v} not found in ${toString ./css}"
        else v;
    };

    styles = mkOption {
      type = types.path;
      readOnly = true;
      default = themePath;
      description = "Resolved path to theme CSS file";
    };
  };
}

