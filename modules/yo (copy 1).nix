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
      
      requiresHost = mkOption {
        type = types.bool;
        default = false;
        description = "Whether this command requires a host parameter";
      };

      parameters = mkOption {
        type = types.listOf (types.submodule {
          options = {
            name = mkOption { type = types.str; };
            description = mkOption { type = types.str; };
            optional = mkOption { type = types.bool; default = false; };
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
         # set -euxo pipefail  
          # Generic parameter parser
          declare -A PARAMS=()
          POSITIONAL=()

          # Parse named and positional parameters
          while [[ $# -gt 0 ]]; do
            case "$1" in
              --help|-h)
                echo "Usage: yo ${script.name} [machine|user@host] [host] [--hermetic] [--remote]"
                echo
                echo "${script.description}"
                echo
                echo "Parameters:"
                ${concatStringsSep "\n" (map (param: ''
                  echo "  ${param.name} - ${param.description}${optionalString param.optional " (optional)"}"
                '') script.parameters)}
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

          ${concatStringsSep "\n" (lib.imap0 (idx: param: ''
            if [ -n "''${POSITIONAL[${toString idx}]:-}" ]; then
              ${param.name}="''${POSITIONAL[${toString idx}]}"
            fi
          '') script.parameters)}

          ${concatStringsSep "\n" (map (param: ''
            if [[ -n "''${PARAMS[${param.name}]:-}" ]]; then
              ${param.name}="''${PARAMS[${param.name}]}"
            fi
          '') script.parameters)}

          if [[ -n "''${machine:-}" ]] && [[ "''${machine}" == *"@"* ]]; then
            IFS='@' read -r user host <<< "''${machine}"
            machine="''${host}"
          fi

          export machine="''${machine:-''${host:-}}"
          export host="''${host:-''${machine:-}}"
          hermetic="''${hermetic:-false}"
          remote="''${remote:-false}"

          export host="''${host:-}"
          machine="''${machine:-}"
          user="''${user:-$(whoami)}"

          ${lib.optionalString script.requiresHost ''
            host="''${host:-''${machine:-${config.networking.hostName}}}"
            if [[ -z "$host" ]]; then
              host="${config.networking.hostName}"
            fi
          ''}

          ${lib.optionalString script.requiresHost ''
            if [[ -z "$host" ]]; then
              echo "Error: Host must be specified!"
              exit 1
            fi
          ''}

          # ====== Original Script Code ======
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

  helpText = let
    rows = map (script:
      let
        aliasList = if script.aliases != [] then
          concatStringsSep ", " script.aliases
        else
          "";
        paramHint = let
          hostPart = lib.optionalString script.requiresHost "<host> ";
          optionsPart = lib.concatMapStringsSep " " (param: "[--${param.name}]") script.parameters;
        in hostPart + optionsPart;

        syntax = "\\`yo ${script.name} ${paramHint}\\`";
      in "| ${syntax} | ${aliasList} | ${script.description} |"
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
          #cat <<EOF | ${pkgs.glow}/bin/glow -
          #width=$(tput cols)
          width=130
          cat <<EOF | ${pkgs.glow}/bin/glow --width $width -
        ## 🦆 Yo! Waz Qwackin' yo?! 🦆🦆🥹🚀🚀🚀
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
