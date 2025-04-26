{ 
  config,
  lib,
  pkgs,
  ...
} : with lib;
let
  # Helper function to escape markdown special characters
  escapeMD = str: let
    replacements = [
      [ "\\" "\\\\" ]
      [ "*" "\\*" ]
      [ "`" "\\`" ]
      [ "_" "\\_" ]
      [ "[" "\\[" ]
      [ "]" "\\]" ]
    ];
  in
    lib.foldl (acc: r: replaceStrings [ (builtins.elemAt r 0) ] [ (builtins.elemAt r 1) ] acc) str replacements;
  # Documentation generation with markdown escaping
  generateDocs = let
    scriptDocs = mapAttrsToList (name: script: 
      let
        safeDesc = escapeMD script.description;
        # Handle aliases as string
        aliases = if script.aliases != [] then
          "*Aliases:* ${concatStringsSep ", " (map escapeMD script.aliases)}\n\n"
        else
          "";
        
        # Handle parameters with escaped descriptions
        
        params = if script.parameters != [] then
          "### Parameters\n" + 
          concatStringsSep "\n" (map (param: 
            let
              defaultText = optionalString (param.default != null) 
                " (default: `${escapeMD param.default}`)";
              optionalText = optionalString param.optional " *(optional)*";
            in
            "- `--${escapeMD param.name}`${defaultText}${optionalText}\n  ${param.description}"
          ) script.parameters) + "\n"    
        
        
#        params = if script.parameters != [] then
#          "### Parameters\n" + 
#          concatStringsSep "\n" (map (param: 
#            let
#              safeParamDesc = escapeMD param.description;
#              defaultText = optionalString (param.default != null) " (default: `${escapeMD param.default}`)";
#              optionalText = optionalString param.optional " *(optional)*";
#            in
#            "- `--${escapeMD param.name}` (${param.type})${defaultText}${optionalText}\n  ${safeParamDesc}"
#          ) script.parameters) + "\n"
        else
          "";
      in
        ''
        <details>
        <summary><code>yo ${escapeMD script.name}</code> - ${safeDesc}</summary>

        ${aliases}
        ${params}
        </details>
        ''
    ) cfg.scripts;
  
    fullDoc = concatStringsSep "\n" scriptDocs;
  
  in fullDoc;

  updateReadme = pkgs.writeShellScriptBin "update-readme" ''
    set -euo pipefail

    README_PATH="${config.this.user.me.dotfilesDir}/README.md"

    FLAKE_OUTPUT=$(nix flake show "${config.this.user.me.dotfilesDir}" | sed -e 's/\x1B\[[0-9;]*[A-Za-z]//g')
    FLAKE_BLOCK=$(
      echo '```nix'
      echo "$FLAKE_OUTPUT"
      echo '```'
    )

    #  Get generated help text from Nix-built file
    HELP_CONTENT=$(<${helpTextFile})


    DOCS_CONTENT=$(cat <<'EOF'
## Define scripts

```nix

```

## 🚀 **yo CLI TOol 🦆🦆🦆🦆🦆🦆**
**Usage:** \`yo <command> [arguments]\`  

**yo CLI config mode:** \`yo config\`, \`yo edit\` 

``` 
❄️ yo CLI Tool
🦆 ➤ Edit hosts
     Edit yo CLI scripts
     Edit flake
     Add new host
     🚫 Exit
``` 

## **Usage Examples:**
\`yo deploy laptop\`
\`yo deploy user@hostname\`
\`yo health\`
\`yo health --host desktop\` 

## ✨ Available Commands
Set default values for your parameters to have them marked [optiional]
| Command Syntax               | Aliases    | Description |
|------------------------------|------------|-------------|
${helpText}
## ℹ️ Detailed Help
For specific command help: 
\`yo <command> --help\`
\`yo <command> -h\`
EOF
    )

    tmpfile=$(mktemp)


    # Single AWK command handling both replacements
    awk -v docs="$DOCS_CONTENT" -v tree="$FLAKE_BLOCK" '
      BEGIN { in_docs=0; in_tree=0 }
      /<!-- YO_DOCS_START -->/ {
        print
        print docs
        in_docs=1
        next
      }
      /<!-- YO_DOCS_END -->/ {
        in_docs=0
        print
        next
      }
      /<!-- TREE_START -->/ {
        print
        print tree
        in_tree=1
        next
      }
      /<!-- TREE_END -->/ {
        in_tree=0
        print
        next
      }
      !in_docs && !in_tree { print }
    ' "$README_PATH" > "$tmpfile"


    # Only replace if different and writable
    if ! diff -q "$tmpfile" "$README_PATH" >/dev/null; then
      if [ -w "$README_PATH" ]; then
        cat "$tmpfile" > "$README_PATH"
        echo "Updated README.md"
      else
        echo "Cannot update $README_PATH: Permission denied" >&2
        exit 1
      fi
    else
      echo "No changes needed"
    fi

    rm "$tmpfile"
  '';


  yoEnvGenVar = script: let
    withDefaults = builtins.filter (p: p.default != null) script.parameters;
    exports = map (p: "export ${p.name}=${lib.escapeShellArg p.default}") withDefaults;
  in lib.concatStringsSep "\n" exports;

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
              default = config.default != null;  # Automatically optional if default exists
              description = "Whether this parameter can be omitted";
            };
            default = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Default value if parameter is not provided";
            };
            type = mkOption {
              type = types.enum ["string" "int" "path"];
              default = "string";
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
          set -euo pipefail
          ${yoEnvGenVar script}
        
          # Phase 1: Preprocess special flags
          VERBOSE=0
          DRY_RUN=false
          FILTERED_ARGS=()
   
          while [[ $# -gt 0 ]]; do
            case "$1" in
              \?) ((VERBOSE++)); shift ;;
              '!') DRY_RUN=true; shift ;;
              *) FILTERED_ARGS+=("$1"); shift ;;
            esac
          done  
  
          VERBOSE=$VERBOSE
          export VERBOSE DRY_RUN
     
          # Reset arguments without special flags
          set -- "''${FILTERED_ARGS[@]}"

          # Phase 2: Regular parameter parsing
          declare -A PARAMS=()
          POSITIONAL=()
          VERBOSE=$VERBOSE
          DRY_RUN=$DRY_RUN
          
          # Parse all parameters
          while [[ $# -gt 0 ]]; do
            case "$1" in
              --help|-h)
                width=$(tput cols 2>/dev/null || echo 100)
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
                  echo -e "\033[1;31m❌ $1\033[0m Unknown parameter: $1"
                  exit 1
                fi
                ;;
              *)
                POSITIONAL+=("$1")
                shift
                ;;
            esac
          done

            # Phase 3: Assign parameters
            ${concatStringsSep "\n" (lib.imap0 (idx: param: ''
              if (( ${toString idx} < ''${#POSITIONAL[@]} )); then
                ${param.name}="''${POSITIONAL[${toString idx}]}"
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
              if [[ -z "''${${param.name}:-}" ]]; then
                ${param.name}='${param.default}'
              fi
            '') script.parameters)}

          ${concatStringsSep "\n" (map (param: ''
            ${optionalString (!param.optional) ''
              if [[ -z "''${${param.name}:-}" ]]; then
                echo -e "\033[1;31m❌ Missing required parameter: ${param.name}\033[0m" >&2
                exit 1
              fi
            ''}
          '') script.parameters)}

          # ==== Script Execution ======
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
  helpTextFile = pkgs.writeText "yo-helptext.md" helpText;
  helpText = (
    let
      rows = map (script:
        let
          aliasList = if script.aliases != [] then
            concatStringsSep ", " script.aliases
          else
            "";
          paramHint = let
            optionsPart = lib.concatMapStringsSep " " (param: 
              # Show as optional if EITHER has default OR explicitly marked optional
              if (param.default != null || param.optional) 
              then "[--${param.name}]" 
              else "--${param.name}"
            ) script.parameters;
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
#    flakeTree = pkgs.runCommand "flake-tree" {
#       buildInputs = [ pkgs.nix ];
#     } ''
 #      nix flake show ${config.this.user.me.dotfilesDir} > $out
#     '';
      
    system.build.updateReadme = pkgs.runCommand "update-readme" {
      helpTextFile = helpTextFile;
    } ''
      mkdir -p $out
      cp ${toString ./../README.md} $out/README.md

      # Insert helpTextFile between YO_DOCS_START and YO_DOCS_END
      ${pkgs.gnused}/bin/sed -i '/<!-- YO_DOCS_START -->/,/<!-- YO_DOCS_END -->/c\
    <!-- YO_DOCS_START -->\
    ## 🦆 **Yo Commands Reference**\
    *Automagiduckically generated from module definitions*\
    \
    '"$(cat ${helpTextFile})"'\
    <!-- YO_DOCS_END -->' $out/README.md
    '';
    environment.systemPackages = [
      updateReadme
      (pkgs.writeShellScriptBin "yo" ''
        #!${pkgs.runtimeShell}
        script_dir="${yoScriptsPackage}/bin"
        show_help() {
          # width=100
          width=$(tput cols)
          cat <<EOF | ${pkgs.glow}/bin/glow --width $width -
## 🚀 **yo CLI TOol 🦆🦆🦆🦆🦆🦆**
**Usage:** \`yo <command> [arguments]\`  

**Edit configurations** \`yo edit\` 

## **Usage Examples:**
\`yo deploy laptop\`
\`yo deploy user@hostname\`
\`yo health\`
\`yo health --host desktop\` 

## ✨ Available Commands
Set default values for your parameters to have them marked [optiional]
| Command Syntax               | Aliases    | Description |
|------------------------------|------------|-------------|
${helpText}
## ℹ️ Detailed Help
For specific command help: 
\`yo <command> --help\`
\`yo <command> -h\`
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
          echo -e "\033[1;31m❌ $1\033[0m Error: Unknown command '$command'" >&2
          show_help
          exit 1
        fi
      '')
      yoScriptsPackage
      updateReadme
#      config.system.build.updateReadme # this did not work
    ];
  };

}
