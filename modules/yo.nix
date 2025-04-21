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

      parameters = mkOption {
        type = types.listOf (types.submodule {
          options = {
            name = mkOption { type = types.str; };
            description = mkOption { type = types.str; };
            optional = mkOption { 
              type = types.bool; 
              default = false; 
              description = "Whether this parameter can be omitted";
            };
            default = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Default value if parameter is not provided";
            };
          };
        });
        default = [];
        description = "Parameters accepted by this script";
      };
    };    
    
  });

  cfg = config.yo;

  yoScriptsPackage = pkgs.symlinkJoin {
    name = "yo-scripts";
    paths = mapAttrsToList (name: script:
      let
        scriptContent = ''
          #!${pkgs.runtimeShell}
        #  set -euo pipefail

          # Dynamic parameter handling
          declare -A PARAMS=()
          POSITIONAL=()
          
          # Parse all parameters
          while [[ $# -gt 0 ]]; do
            case "$1" in
              --help|-h)
                width=90
                cat <<EOF | ${pkgs.glow}/bin/glow --width "$width" -
## 🚀🦆 ${script.name} Command
**Usage:** \`yo ${script.name} [parameters]\`

${script.description}

${optionalString (script.parameters != []) ''
### Parameters
${concatStringsSep "\n" (map (param: ''
- \`--${param.name}\` ${optionalString param.optional "(optional)"} ${optionalString (param.default != null) "[default: ${param.default}]"}  
  ${param.description}
'') script.parameters)}
''}
EOF
                exit 0
                ;;
              --*)
                param_name=''${1##--}
                if [[ " ${concatMapStringsSep " " (p: p.name) script.parameters} " =~ " $param_name " ]]; then
                  PARAMS["$param_name"]="$2"
                  shift 2
                else
                  echo "Unknown parameter: $1"
                  exit 1
                fi
                ;;
              *)
                POSITIONAL+=("$1")
                shift
                ;;
            esac
          done

          # Set parameters from either named or positional arguments
          ${concatStringsSep "\n" (lib.imap0 (idx: param: ''
            if [[ $# -ge $((idx + 1)) ]]; then
              ${param.name}="''${POSITIONAL[$idx]}"
            fi
          '') script.parameters)}

          ${concatStringsSep "\n" (map (param: ''
            if [[ -n "''${PARAMS[${param.name}]:-}" ]]; then
              ${param.name}="''${PARAMS[${param.name}]}"
            fi
          '') script.parameters)}



          # Apply default values for parameters
          ${concatStringsSep "\n" (map (param: 
            optionalString (param.default != null) ''
              if [[ -z "\${param.name}:-}" ]]; then
                ${param.name}='${param.default}'  # Single quotes preserve spaces
              fi
            '') script.parameters)}

          ${concatStringsSep "\n" (map (param: ''
            ${optionalString (!param.optional) ''
              if [[ -z "\${param.name}:-}" ]]; then
                echo "Missing required parameter: ${param.name}" >&2
                exit 1
              fi
            ''}
          '') script.parameters)}

          # Validate required parameters
#          ${concatStringsSep "\n" (map (param: ''
#            ${optionalString (!param.optional) ''
            #  if [[ -z "\{${param.name}:-}" ]]; then
#              if [[ -z "\${param.name}:-}" ]]; then
#                echo "Missing required parameter: ${param.name}" >&2
#                exit 1
#              fi
#            ''}
#          '') script.parameters)}

          # ====== Script Execution ======
          ${script.code}
        '';
        
        mainScript = pkgs.writeShellScriptBin "yo-${script.name}" scriptContent;
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

  helpText = (
    let
      rows = map (script:
        let
          aliasList = if script.aliases != [] then
            concatStringsSep ", " script.aliases
          else
            "";
          paramHint = let
            optionsPart = lib.concatMapStringsSep " " (param: "[--${param.name}]") script.parameters;
          in optionsPart;
          syntax = "\\`yo ${script.name} ${paramHint}\\`";
        in "| ${syntax} | ${aliasList} | ${script.description} |"
      ) (attrValues cfg.scripts);
    in
      concatStringsSep "\n" rows
  );
    
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
          #width=$(tput cols)
          width=100
          cat <<EOF | ${pkgs.glow}/bin/glow --width $width -
## 🚀🦆 Yo! Waz Qwackin' yo?! 🦆🦆
**Usage:** \`yo <command> [arguments]\`  
## ✨ Available Commands
| Command Syntax               | Aliases    | Description |
|------------------------------|------------|-------------|
${helpText}
## ℹ️ Detailed Help
For specific command help: \`yo <command> --help\`
EOF
          exit 0
        }
        # Handle zero arguments
        if [[ $# -eq 0 ]]; then
          show_help
          exit 1
        fi

        # Parse command
        case "$1" in
          -h|--help) show_help; exit 0 ;;
          *) command="$1"; shift ;;
        esac

        script_path="$script_dir/yo-$command"
        if [[ -x "$script_path" ]]; then
          exec "$script_path" "$@"
        else
          echo "Error: Unknown command '$command'" >&2
          show_help
          exit 1
        fi
      '')
      yoScriptsPackage
    ];
  };
}
