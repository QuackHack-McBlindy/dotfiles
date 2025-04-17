{ 
  config,
  lib,
  pkgs,
  ...
} : with lib;
let
  scriptType = types.submodule ({ name, ... }: {
    options = {
      name = mkOption {
        type = types.str;
        internal = true;
        readOnly = true;
        default = name;
        description = "Script name (derived from attribute key)";
      };
      description = mkOption {
        type = types.str;
        description = "Description of the script";
      };
      code = mkOption {
        type = types.lines;
        description = "The script code";
      };
      aliases = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Alternative command names for this script";
      };
    };
  });

  cfg = config.yo;
  
  # Create package with all scripts and aliases
  yoScriptsPackage = pkgs.symlinkJoin {
    name = "yo-scripts";
    paths = mapAttrsToList (name: script:
      let
        mainScript = pkgs.writeShellScriptBin "yo-${script.name}" script.code;
      in
        pkgs.runCommand "yo-script-${script.name}" {} ''
          mkdir -p $out/bin
          ln -s ${mainScript}/bin/yo-${script.name} $out/bin/yo-${script.name}
          ${concatMapStrings (alias: ''
            ln -s ${mainScript}/bin/yo-${script.name} $out/bin/yo-${alias}
          '') script.aliases}
        ''
    ) cfg.scripts;
  };

  # Generate help text with aliases
  helpText = let
    rows = map (script:
      let
        aliasList = if script.aliases != [] then
          concatStringsSep ", " script.aliases
        else
          "";
      in "| ${script.name} | ${aliasList} | ${script.description} |"
    ) (attrValues cfg.scripts);
  in
    concatStringsSep "\n" rows;

in {
  options.yo.scripts = mkOption {
    type = types.attrsOf scriptType;
    default = {};
    description = "Attribute set of scripts to be made available";
  };

  config = {
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "yo" ''
        #!${pkgs.runtimeShell}
        script_dir="${yoScriptsPackage}/bin"

        show_help() {
          cat <<EOF | ${pkgs.glow}/bin/glow -
        ## ❄️🧑‍🦯 Yo! Nix OS Helper
        **Usage:** \`yo <command> [arguments]\`
        ## ✨ Available Commands
        | Command | Aliases | Description |
        |--------|---------|-------------|
        ${helpText}
        EOF
          exit 0
        }


        if [[ "$1" = "-h" || "$1" = "--help" ]]; then
          show_help
        fi

        command="$1"
        shift
        
        if [[ -z "$command" ]]; then
          show_help
          exit 1
        fi

        script_path="$script_dir/yo-$command"
        
        if [[ -x "$script_path" ]]; then
          exec "$script_path" "$@"
        else
          echo "Error: Unknown command '$command'"
          show_help
          exit 1
        fi
      '')

      yoScriptsPackage
    ];
  };
}
