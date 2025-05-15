# dotfiles/modules/yo.nix
{ lib, pkgs, config, ... }:

with lib;
let
  cfg = config.yo;
  binDir = ./../bin;  # Path to your bin directory
  yoScript = "${binDir}/yo";
  hooksDir = "${binDir}/hooks.d";

  # Python environment with all dependencies
  yoEnv = pkgs.python312.withPackages (ps: with ps; [
    setuptools
    click
    rich
  ]);

  # Wrapped yo command
  yoWrapped = pkgs.writeShellScriptBin "yo" ''
    ${yoEnv}/bin/python ${yoScript} "$@"
  '';

in {
  options.yo = {
    enable = mkEnableOption "yo CLI management system";
    
    hooks = mkOption {
      type = types.attrsOf (types.listOf types.str);
      default = {};
      description = "Hook scripts for yo operations";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      yoWrapped  # This adds the 'yo' command to PATH
      yoEnv
      nodePackages.bash-language-server
      shellcheck
      shfmt
      jq
      yq-go
    ];

    system.activationScripts.yoSetup = ''
      # Create config directories
      mkdir -p ~/.config/yo/hooks.d
      
      # Deploy hooks if they exist
      if [ -d "${hooksDir}" ]; then
        cp -r "${hooksDir}"/* ~/.config/yo/hooks.d/ || true
      fi
    '';

    environment.sessionVariables = {
      YO_CONFIG_DIR = "$HOME/.config/yo";
      PYTHONPATH = "${yoEnv}/${yoEnv.sitePackages}";
    };

    programs.bash.shellInit = ''
      # Load dynamic hooks
      ${concatStringsSep "\n" (mapAttrsToList (name: scripts: 
        ''function _yo_${name}_hook() { ${concatStringsSep "\n" scripts} }''
      ) cfg.hooks)}
    '';
  };
}
