# dotfiles/modules/yo.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 duck say ⮞ Nix DSL yo CLI - Defines & Unifies all my scripts into a smart & duck powered script execution system   
  config,# 🦆 says ⮞ 📌 FEATURES:   
  lib,       # 🦆 duck say ⮞ ⭐ Flexible parameters (Named + positional) - Support default values and optional parameters.
  pkgs,      # 🦆 duck say ⮞ ⭐ Voice command integration with declarative defined sentences and entity lists.
  ...        # 🦆 duck say ⮞ ⭐ Unified help commands + DuckTrace integrated logging + Start at Boot features.
} : with lib;# 🦆 duck say ⮞ ⭐ Automatic README injection - display scripts in Markdown + Dynamic badge updates based on system versions. 
let 
  # 🦆 says ⮞ for README version badge yo
  nixosVersion = let
    raw = builtins.readFile /etc/os-release;
    versionMatch = builtins.match ".*VERSION_ID=([0-9\\.]+).*" raw;
  in builtins.replaceStrings [ "." ] [ "%2E" ] (builtins.elemAt versionMatch 0);
  
  # 🦆 duck say ⮞ quacky hacky helper 2 escape md special charizardz yo
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

  # 🦆 duck say ⮞ manual readme is so 1999 duckie
  updateReadme = pkgs.writeShellScriptBin "update-readme" ''
    set -euo pipefail
    README_PATH="${config.this.user.me.dotfilesDir}/README.md"
    CONTACT_OUTPUT=""
    USER_TMP=$(mktemp)
    HOST_TMP=$(mktemp)
    
    # 🦆 duck say ⮞ Extract versions
    nixos_version=$(nixos-version | cut -d. -f1-2)
    kernel_version=$(uname -r | cut -d'-' -f1)
    nix_version=$(nix --version | awk '{print $3}')
    bash_version=$(bash --version | head -n1 | awk '{print $4}' | cut -d'(' -f1)
    gnome_version=$(gnome-shell --version | awk '{print $3}')
    python_version=$(python3 --version | awk '{print $2}')  

    # 🦆 duck say ⮞ Construct badge URLs
    nixos_badge="https://img.shields.io/badge/NixOS-''${nixos_version}-blue?style=flat-square\\&logo=NixOS\\&logoColor=white"
    linux_badge="https://img.shields.io/badge/Linux-''${kernel_version}-red?style=flat-square\\&logo=linux\\&logoColor=white"
    nix_badge="https://img.shields.io/badge/Nix-''${nix_version}-blue?style=flat-square\\&logo=nixos\\&logoColor=white"
    bash_badge="https://img.shields.io/badge/bash-''${bash_version}-red?style=flat-square\\&logo=gnubash\\&logoColor=white"
    gnome_badge="https://img.shields.io/badge/GNOME-''${gnome_version}-purple?style=flat-square\\&logo=gnome\\&logoColor=white"
    python_badge="https://img.shields.io/badge/Python-''${python_version}-%23FFD43B?style=flat-square\\&logo=python\\&logoColor=white"
  
    # 🦆 duck say ⮞ Contact badges
    matrix_url="${config.this.user.me.matrix}"
    if [[ -n "${config.this.user.me.matrix}" ]]; then
      CONTACT_OUTPUT+="[![Matrix](https://img.shields.io/badge/Matrix-Chat-000000?style=flat-square&logo=matrix&logoColor=white)](${config.this.user.me.matrix})"$'\n'
    fi
    discord_url="${config.this.user.me.discord}"
    if [[ -n "${config.this.user.me.discord}" ]]; then
      CONTACT_OUTPUT+="[![Discord](https://img.shields.io/badge/Discord-Chat-5865F2?style=flat-square&logo=discord&logoColor=white)](${config.this.user.me.discord})"$'\n'
    fi
    email_address="${config.this.user.me.email}"
    if [[ -n "${config.this.user.me.email}" ]]; then
      CONTACT_OUTPUT+="[![Email](https://img.shields.io/badge/Email-Contact-6D4AFF?style=flat-square&logo=protonmail&logoColor=white)](mailto:${config.this.user.me.email})"$'\n'
    fi
    repo_url="${config.this.user.me.repo}"
    if [[ -n "$repo_url" ]]; then
      if [[ "$repo_url" =~ git@github.com:([^/]+)/([^/]+)\.git ]]; then
        repo_owner="''${BASH_REMATCH[1]}"
        repo_name="''${BASH_REMATCH[2]%.git}"
        github_discussions_url="https://github.com/''${repo_owner}/''${repo_name}/discussions"
      elif [[ "$repo_url" =~ https://github.com/([^/]+)/([^/]+)\.git ]]; then
        repo_owner="''${BASH_REMATCH[1]}"
        repo_name="''${BASH_REMATCH[2]%.git}"
        github_discussions_url="https://github.com/''${repo_owner}/''${repo_name}/discussions"
      else
        github_discussions_url=""
      fi
    else
      github_discussions_url=""
    fi
    if [[ -n "${config.this.user.me.repo}" ]]; then
      if [[ "${config.this.user.me.repo}" =~ (git@|https://)github.com(:|/)([^/]+)/([^/]+).git ]]; then
        repo_owner="''${BASH_REMATCH[3]}"
        repo_name="''${BASH_REMATCH[4]%.git}"
        CONTACT_OUTPUT+="[![GitHub Discussions](https://img.shields.io/badge/Discussions-Join-181717?style=flat-square&logo=github&logoColor=white)](https://github.com/''${repo_owner}/''${repo_name}/discussions)"$'\n'
      fi
    fi

    FLAKE_OUTPUT=$(nix flake show "${config.this.user.me.dotfilesDir}" | sed -e 's/\x1B\[[0-9;]*[A-Za-z]//g')
    FLAKE_BLOCK=$(
      echo '```nix'
      echo "$FLAKE_OUTPUT"
      echo '```'
    )

    # 🦆 duck say ⮞  get generated help text
    HELP_CONTENT=$(<${helpTextFile})

    DOCS_CONTENT=$(cat <<'EOF'
## 🚀 **yo CLI 🦆🦆🦆🦆🦆🦆**
**Usage:** \`yo <command> [arguments]\`  

**yo CLI config mode:** \`yo config\`, \`yo edit\` 

``` 
❄️ yo CLI Tool
🦆 ➤ Edit hosts
     Edit flake
     Edit yo CLI scripts
     🚫 Exit
``` 

### **Usage Examples:**  
The yo CLI supports flexible parameter parsing through two primary mechanisms:  

```bash
# Named Parameters  
$ yo deploy --host laptop --flake /home/pungkula/dotfiles

# Positional Parameters
$ yo deploy laptop /home/pungkula/dotfiles

# Scripts can also be executed with voice, by saying:
"yo bitch deploy laptop"

# If the server is not running, it can be manually started with:
$ yo transcription
$ yo wake

# Get list of all defined sentences for voice commands:
$ yo bitch --help
```

### ✨ Available Commands
Set default values for your parameters to have them marked [optional]
| Command Syntax               | Aliases    | Description |
|------------------------------|------------|-------------|
${helpText}
### ❓ Detailed Help
For specific command help: 
\`yo <command> --help\`
\`yo <command> -h\`
EOF
    )

    tmpfile=$(mktemp)
    CONTACT_BLOCK=$(
      echo "<!-- CONTACT_START -->"
      echo "$CONTACT_OUTPUT"
      echo "<!-- CONTACT_END -->"
    )

    FLAKE_BLOCK_NIX=$(
      echo '```nix'
      cat "${config.this.user.me.dotfilesDir}/flake.nix"
      echo '```'
    )
    
    USER_BLOCK=$(
      echo '```nix'
      nix eval --json \
        "${config.this.user.me.dotfilesDir}#nixosConfigurations.${config.this.host.hostname}.config.this.user.me" \
        | jq -r '
          def to_nix($indent):
            def ind: ("  " * $indent);
            if type == "object" then
              "\(ind){\n" + (
                to_entries | map(
                  "\(ind)  \(.key) = \(.value | to_nix($indent + 1))"
                ) | join(";\n")
              ) + "\n\(ind)};"
            elif type == "array" then
              if map(type == "string") | all then
                "[ " + (map("\"\(.)\"") | join(" ")) + " ]"
              else
                "[\n" + (
                  map(to_nix($indent + 1)) | join("\n")
                ) + "\n\(ind)];"
              end
            elif type == "string" then
              "\"\(.)\""
            else
              tostring
            end;
          to_nix(0)' \
      | sed -e '1s/^{/{/' -e 's/;;/;/g' -e '/^$/d'
      echo '```'
    )
    
    HOST_BLOCK=$(
      echo '```nix'
      nix eval --json \
        "${config.this.user.me.dotfilesDir}#nixosConfigurations.${config.this.host.hostname}.config.this.host" \
        | jq -r '
          def to_nix($indent):
            def ind: ("  " * $indent);
            if type == "object" then
              "\(ind){\n" + (
                to_entries | map(
                  "\(ind)  \(.key) = \(.value | to_nix($indent + 1))"
                ) | join(";\n")
              ) + "\n\(ind)};"
            elif type == "array" then
              if map(type == "string") | all then
                "[ " + (map("\"\(.)\"") | join(" ")) + " ]"
              else
                "[\n" + (
                  map(to_nix($indent + 1)) | join("\n")
                ) + "\n\(ind)];"
              end
            elif type == "string" then
              "\"\(.)\""
            else
              tostring
            end;
          to_nix(0)' \
      | sed -e '1s/^{/{/' -e 's/;;/;/g' -e '/^$/d'
      echo '```'
    )
       
    THEME_BLOCK=$(
      echo '```nix'
      nix eval --json \
        "${config.this.user.me.dotfilesDir}#nixosConfigurations.${config.this.host.hostname}.config.this.theme" \
        | jq -r '
          def to_nix($indent):
            def ind: ("  " * $indent);
            if type == "object" then
              "\(ind){\n" + (
                to_entries | map(
                  "\(ind)  \(.key) = \(.value | to_nix($indent + 1))"
                ) | join(";\n")
              ) + "\n\(ind)};"
            elif type == "array" then
              if map(type == "string") | all then
                "[ " + (map("\"\(.)\"") | join(" ")) + " ]"
              else
                "[\n" + (
                  map(to_nix($indent + 1)) | join("\n")
                ) + "\n\(ind)];"
              end
            elif type == "string" then
              "\"\(.)\""
            else
              tostring
            end;
          to_nix(0)' \
      | sed -e '1s/^{/{/' -e 's/;;/;/g' -e '/^$/d'
      echo '```'
    )    
     
    # 🦆 duck say ⮞ Update version badges
    sed -i -E \
      -e "s|https://img.shields.io/badge/NixOS-[^)]*|$nixos_badge|g" \
      -e "s|https://img.shields.io/badge/Linux-[^)]*|$linux_badge|g" \
      -e "s|https://img.shields.io/badge/Nix-[^)]*|$nix_badge|g" \
      -e "s|https://img.shields.io/badge/bash-[^)]*|$bash_badge|g" \
      -e "s|https://img.shields.io/badge/GNOME-[^)]*|$gnome_badge|g" \
      -e "s|https://img.shields.io/badge/Python-[^)]*|$python_badge|g" \
      "$README_PATH"
     
    awk -v docs="$DOCS_CONTENT" \
        -v contact="$CONTACT_BLOCK" \
        -v tree="$FLAKE_BLOCK" \
        -v flake="$FLAKE_BLOCK_NIX" \
        -v host="$HOST_BLOCK" \
        -v user="$USER_BLOCK" \
        -v theme="$THEME_BLOCK" \
        '
      BEGIN { in_docs=0; in_contact=0; in_tree=0; in_flake=0; in_host=0; in_user=0; printed=0 }
      /<!-- YO_DOCS_START -->/ { in_docs=1; print; print docs; next }
      /<!-- YO_DOCS_END -->/ { in_docs=0; print; next }
      /<!-- HOST_START -->/ { in_host=1; print; print host; next }
      /<!-- HOST_END -->/ { in_host=0; print; next }
      /<!-- THEME_START -->/ { in_theme=1; print; print theme; next }
      /<!-- THEME_END -->/ { in_theme=0; print; next }
      /<!-- USER_START -->/ { in_user=1; print; print user; next }
      /<!-- USER_END -->/ { in_user=0; print; next }
      /<!-- TREE_START -->/ { in_tree=1; print; print tree; next }
      /<!-- TREE_END -->/ { in_tree=0; print; next }
      /<!-- FLAKE_START -->/ { in_flake=1; print; print flake; next }
      /<!-- FLAKE_END -->/ { in_flake=0; print; next }
      !in_docs && !in_tree && !in_theme && !in_flake && !in_host && !in_user { print }
      ' "$README_PATH" > "$tmpfile"  

    # 🦆 duck say ⮞ Diff check
    if ! cmp -s "$tmpfile" "$README_PATH"; then
      echo "🦆 duck say > Changes detected, updating README.md"
      if ! install -m 644 "$tmpfile" "$README_PATH"; then
        echo -e "\033[1;31m 🦆 duck say ⮞ fuck ❌ Failed to update README.md (permissions?)" >&2
        rm "$tmpfile"
        exit 1
      fi
    else
      echo "🦆 duck say > ✅ No content changes needed"
    fi
  
    if ! diff -q "$tmpfile" "$README_PATH" >/dev/null; then
      if [ -w "$README_PATH" ]; then
        cat "$tmpfile" > "$README_PATH"
        echo "🦆 duck say > Updated README.md"
      else
        echo -e "\033[1;31m 🦆 duck say ⮞ fuck ❌ Cannot update $README_PATH: Permission denied" >&2
        exit 1
      fi
    else
      echo "No changes needed"
    fi

    rm "$tmpfile"
    rm "$USER_TMP" "$HOST_TMP"
  '';

  # 🦆 duck say ⮞ expoort param into shell script
  yoEnvGenVar = script: let
    withDefaults = builtins.filter (p: p.default != null) script.parameters;
    exports = map (p: "export ${p.name}=${lib.escapeShellArg p.default}") withDefaults;
  in lib.concatStringsSep "\n" exports;
  scriptType = types.submodule ({ name, ... }: {
  
# 🦆 ⮞ OPTIONS 🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆#    
    options = { # 🦆 duck say > a name cool'd be cool right?
      name = mkOption {
        type = types.str;
        internal = true;
        readOnly = true;
        default = name;
        description = "Script name (derived from attribute key)";
      }; 
      description = mkOption {
        type = types.str;
        default = "";
        description = "Description of the script";
      }; # 🦆 duck say > categoryiez da script (for sorting in `yo --help` & README.md    
      category = mkOption {
        type = types.str;
        default = "";
        description = "Category of the script";
      }; # 🦆 duck say > yo go ahead describe da script yo     
      visibleInReadme = mkOption {
        type = types.bool;
        default = ./category != "";
        defaultText = "category != \"\"";
        description = "Whether to include this script in README.md";
      }; # 🦆 duck say > duck trace log level
      logLevel = mkOption {
        type = types.enum ["DEBUG" "INFO" "WARNING" "ERROR" "CRITICAL"];
        default = "INFO";
        description = "Sets the log level for Duck Trace";
      }; 
# 🦆 duck say > extra code to be ran & displayed whelp calling da scripts --help cmd  
      helpFooter = mkOption {
        type = types.lines;
        default = "";
        description = "Additional shell code to run when generating help text";
      }; # 🦆 duck say ># 🦆 duck say > generatez systemd service for da script if true 
      autoStart = mkOption {
        type = types.bool;
        default = false;
        description = "Run the script in the background at startup";
      }; # 🦆 duck say > code to be executed when calling tda script yo      
      code = mkOption {
        type = types.lines;
        description = "The script code";
      }; # 🦆 duck say > alias for da script for extra execution triggerz 
      aliases = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Alternative command names for this script";
      };     
      # 🦆 duck say ⮞ parameter options for the yo script we writin' 
      parameters = mkOption {
        type = types.listOf (types.submodule {
          options = { # 🦆 duck say > parameters = [{ name = ""; description = ""; default = "": optional = "": type = ""; }]; 
            name = mkOption { type = types.str; };
            description = mkOption { type = types.str; };
            default = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Default value if parameter is not provided";
            }; # 🦆 duck say > i likez diz option - highly useful
            optional = mkOption { 
              type = types.bool; 
              default = ./default != null;
              description = "Whether this parameter can be omitted";
            }; # 🦆 duck say > diz makez da param sleazy eazy to validate yo 
            type = mkOption {
              type = types.enum ["string" "int" "path"];
              default = "string";
              description = "Type of parameter. Use path for filepath int for numbers and string (default) for all others";
            };
          };
        });
        default = [];
        description = "Parameters accepted by this script";
      };
    };        
  });
  cfg = config.yo;

  # 🦆 duck say ⮞ letz create da yo scripts pkgs - we symlinkz all yo scripts togetha .. quack quack 
  yoScriptsPackage = pkgs.symlinkJoin {
    name = "yo-scripts"; # 🦆 duck say ⮞ map over yo scripts and gen dem shell scriptz wrapperz!!
    paths = mapAttrsToList (name: script:
      let
        # 🦆 duck say ⮞ generate a string for da CLI usage optional parameters [--like] diz yo
        param_usage = lib.concatMapStringsSep " " (param:
          if param.optional
          then "[--${param.name}]" # 🦆 duck say ⮞ iptional params baked inoto brackets
          else "--${param.name}" # 🦆 duck say ⮞ otherz paramz shown az iz yo
        # 🦆 duck say ⮞ filter out da special flagz from standard usage 
        ) (lib.filter (p: !builtins.elem p.name ["!" "?"]) script.parameters);
        # 🦆 duck say ⮞ diz iz where da magic'z at yo! trust da duck yo 
        scriptContent = ''
          #!${pkgs.runtimeShell}
#          set -euo pipefail # 🦆 duck say ⮞ strict error handlin' yo - will exit on errorz
          ${yoEnvGenVar script} # 🦆 duck say ⮞ inject da env quack quack.... quack
          export LC_NUMERIC=C
          start=$(date +%s.%N)
          trap 'end=$(date +%s.%N); elapsed=$(echo "$end - $start" | bc); printf "[🦆⏱] Total time: %.3f seconds\n" "$elapsed"' EXIT
          export DT_LOG_FILE="${name}" # 🦆 duck say ⮞ duck tracin' be namin' da log file for da ran script
          export DT_LOG_LEVEL="${script.logLevel}" # 🦆 duck say ⮞ da tracin' duck back to fetch da log level yo
          export PATH="$PATH:/run/current-system/sw/bin" # 🦆 says ⮞ annoying but easy      
          
          # 🦆 duck say ⮞ PHASE 1: preprocess special flagz woop woop
          VERBOSE=0
          DRY_RUN=false
          FILTERED_ARGS=()
          # 🦆 duck say ⮞ LOOP through da ARGz til' duckie duck all  dizzy duck
          while [[ $# -gt 0 ]]; do
            case "$1" in
              \?) ((VERBOSE++)); shift ;;        # 🦆 duck say ⮞ if da arg iz '?' == increment verbose counter
              '!') DRY_RUN=true; shift ;;        # 🦆 duck say ⮞ if da arg iz '!' == enablez da dry run mode yo
              *) FILTERED_ARGS+=("$1"); shift ;; # 🦆 duck say ⮞ else we collect dem arguments for script processin'
            esac
          done  
          VERBOSE=$VERBOSE
          export VERBOSE DRY_RUN
     
          # 🦆 duck say ⮞ reset arguments without special flags
          set -- "''${FILTERED_ARGS[@]}"

          # 🦆 duck say ⮞ PHASE 2: regular parameter parsin' flappin' flappin' quack quack yo
          declare -A PARAMS=()
          POSITIONAL=()
          VERBOSE=$VERBOSE
          DRY_RUN=$DRY_RUN
          
          # 🦆 duck say ⮞ Parse all parameters
          while [[ $# -gt 0 ]]; do
            case "$1" in
              --help|-h) # 🦆 duck say ⮞ if  u needz help call `--help` or `-h`
                width=$(tput cols 2>/dev/null || echo 100) # 🦆 duck say ⮞ get terminal width for formatin' - fallin' back to 100
                help_footer=$(${script.helpFooter}) # 🦆 duck say ⮞ dynamically generatez da helpFooter if ya defined it yo
                cat <<EOF | ${pkgs.glow}/bin/glow --width "$width" - # 🦆 duck say ⮞ renderin' da cool & duckified CLI docz usin' Markdown & Glow yo 
## 🚀🦆 ${escapeMD script.name} Command
**Usage:** \`yo ${escapeMD script.name}\` ${lib.optionalString (script.parameters != []) "\\\n  ${param_usage}"}

${script.description}
${lib.optionalString (script.parameters != []) ''
### Parameters
${lib.concatStringsSep "\n" (map (param: ''
- `--${escapeMD param.name}` ${lib.optionalString param.optional "(optional)"} ${lib.optionalString (param.default != null) "(default: ${escapeMD param.default})"}  
  ${param.description}
'') script.parameters)}
''}

$help_footer
EOF
                exit 0
                ;;
              --*) # 🦆 duck say ⮞ parse named paramz like: "--duck"
                param_name=''${1##--} 
                # 🦆 duck say ⮞ let'z check if diz param existz in da scriptz defined parameterz
                if [[ " ${concatMapStringsSep " " (p: p.name) script.parameters} " =~ " $param_name " ]]; then
                  PARAMS["$param_name"]="$2" # 🦆 duck say ⮞ assignz da value
                  shift 2
                else # 🦆 duck say ⮞ unknown param? duck say fuck
                  echo -e "\033[1;31m 🦆 duck say ⮞ fuck ❌ $1\033[0m Unknown parameter: $1"
                  exit 1
                fi
                ;;
              *) # 🦆 duck say ⮞ none of the above matchez? i guezz itz a positional param yo
                POSITIONAL+=("$1")
                shift
                ;;
            esac
          done

            # 🦆 duck say ⮞ PHASE 3: assign dem' parameterz!
            ${concatStringsSep "\n" (lib.imap0 (idx: param: '' # 🦆 duck say ⮞ match positional paramz to script paramz by index
              if (( ${toString idx} < ''${#POSITIONAL[@]} )); then
                ${param.name}="''${POSITIONAL[${toString idx}]}" # 🦆 duck say ⮞ assign positional paramz to variable
              fi
            '') script.parameters)}
          # 🦆 duck say ⮞ assign named paramz! PARAMS ⮞ their variable
          ${concatStringsSep "\n" (map (param: ''
            if [[ -n "''${PARAMS[${param.name}]:-}" ]]; then
              ${param.name}="''${PARAMS[${param.name}]}"
            fi
          '') script.parameters)}

          # 🦆 duck say ⮞ count da paramz you cant bring too many to da party yo
          ${optionalString (script.parameters != []) ''
            if [ ''${#POSITIONAL[@]} -gt ${toString (length script.parameters)} ]; then
              echo -e "\033[1;31m 🦆 duck say ⮞ fuck ❌ Too many arguments (max ${toString (length script.parameters)})\033[0m" >&2
              exit 1
            fi
          ''}

          # 🦆 duck say ⮞ param type validation quuackidly quack yo
          ${concatStringsSep "\n" (map (param: 
            optionalString (param.type != "string") ''
              if [ -n "''${${param.name}:-}" ]; then
                case "${param.type}" in
                  int)
                    if ! [[ "''${${param.name}}" =~ ^[0-9]+$ ]]; then
                      echo -e "\033[1;31m 🦆 duck say ⮞ fuck ❌ ${param.name} must be integer\033[0m" >&2
                      exit 1
                    fi
                    ;;
                  path)
                    if ! [ -e "''${${param.name}}" ]; then
                      echo -e "\033[1;31m 🦆 duck say ⮞ fuck ❌ Path not found: ''${${param.name}}\033[0m" >&2
                      exit 1
                    fi
                    ;;
                esac
              fi
            ''
          ) script.parameters)}

          # 🦆 duck say ⮞ apply defaultz for paramz if missin'
          ${concatStringsSep "\n" (map (param: 
            optionalString (param.default != null) ''
              if [[ -z "''${${param.name}:-}" ]]; then
                ${param.name}='${param.default}'
              fi
            '') script.parameters)}
            
          # 🦆 duck say ⮞ checkz required param yo - missing? errorz out 
          ${concatStringsSep "\n" (map (param: ''
            ${optionalString (!param.optional && param.default == null) ''
              if [[ -z "''${${param.name}:-}" ]]; then
                echo -e "\033[1;31m 🦆 duck say ⮞ fuck ❌ Missing required parameter: ${param.name}\033[0m" >&2
                exit 1
              fi
            ''}
          '') script.parameters)}

          # 🦆 duck say ⮞ EXECUTEEEEEAAAOO 🦆quack🦆quack🦆quack🦆quack🦆quack🦆quack🦆quack🦆quack🦆quack🦆quack🦆quack🦆yo
          ${script.code}
        '';
        # 🦆 duck say ⮞ generate da entrypoint
        mainScript = pkgs.writeShellScriptBin "yo-${script.name}" scriptContent;
      in # 🦆 duck say ⮞ letz wrap diz up already  
        pkgs.runCommand "yo-script-${script.name}" {} ''
          mkdir -p $out/bin  # 🦆 duck say ⮞ symlinkz da main script
          ln -s ${mainScript}/bin/yo-${script.name} $out/bin/yo-${script.name} 
          ${concatMapStrings (alias: '' # 🦆 duck say ⮞ dont forget to symlinkz da aliases too yo!
            ln -s ${mainScript}/bin/yo-${script.name} $out/bin/yo-${alias}
          '') script.aliases}
        ''
    ) cfg.scripts; # 🦆 duck say ⮞ apply da logic to da yo scriptz
  }; 

  # 🦆 duck say ⮞ build da .md file
  helpTextFile = pkgs.writeText "yo-helptext.md" helpText;
  # 🦆 duck say ⮞ markdown help text
  helpText = let # 🦆 duck say ⮞ categorize scripts
#    groupedScripts = lib.groupBy (script: script.category) (lib.attrValues cfg.scripts);
    # 🦆 duck say ⮞ sort da scriptz by category
    visibleScripts = lib.filterAttrs (_: script: script.visibleInReadme) cfg.scripts;
    groupedScripts = lib.groupBy (script: script.category) (lib.attrValues visibleScripts);
    sortedCategories = lib.sort (a: b: 
      # 🦆 duck say ⮞ system management goes first yo
      if a == "🖥️ System Management" then true
      else if b == "🖥️ System Management" then false
      else a < b # 🦆 duck say ⮞ after dat everything else quack quack
    ) (lib.attrNames groupedScripts);
  
    # 🦆 duck say ⮞ create table rows with category separatorz 
    rows = lib.concatMap (category:
      let  # 🦆 duck say ⮞ sort from A to Ö  
        scripts = lib.sort (a: b: a.name < b.name) groupedScripts.${category};
      in
        [ # 🦆 duck say ⮞ add **BOLD** header table row for category
          "| **${escapeMD category}** | | |"
        ] 
        ++ # 🦆 duck say ⮞ each yo script goes into a table row
        (map (script:
          let # 🦆 duck say ⮞ format list of aliases
            aliasList = if script.aliases != [] then
              concatStringsSep ", " (map escapeMD script.aliases)
            else "";
            # 🦆 duck say ⮞ generate CLI parameter hints, with [] for optional/defaulted
            paramHint = concatStringsSep " " (map (param:
              if param.optional || param.default != null
              then "[--${param.name}]"
              else "--${param.name}"
            ) script.parameters);
            # 🦆 duck say ⮞ render yo script syntax with param
            syntax = "\\`yo ${escapeMD script.name} ${paramHint}\\`";
          in # 🦆 duck say ⮞ write full md table row - command | aliases | description
            "| ${syntax} | ${aliasList} | ${escapeMD script.description} |"
        ) scripts)
    ) sortedCategories;
  in concatStringsSep "\n" rows;
  
in { # 🦆 duck say ⮞ options options duck duck
  options = { # 🦆 duck say ⮞ 
    yo = {
      pkgs = mkOption {
        type = types.package;
        readOnly = true;
        description = "The final yo scripts package";
      }; # 🦆 duck say ⮞ yo scriptz optionz yo
      scripts = mkOption {
        type = types.attrsOf scriptType;
        default = {};
        description = "Attribute set of scripts to be made available";
      }; # 🦆 duck say ⮞ intent options
      bitch = {
        intents = mkOption {
          type = types.attrsOf (types.submodule {
            options.data = mkOption {
              type = types.listOf (types.submodule {
                options.sentences = mkOption { # 🦆 duck say ⮞ intent sentences
                  type = types.listOf types.str;
                  default = [];
                  description = "Sentence patterns for intent matching";
                }; # 🦆 duck say ⮞ entity lists definitiion
                options.lists = mkOption {
                  type = types.attrsOf (types.submodule {
                    options.wildcard = mkOption { # 🦆 duck say ⮞ wildcard matches everything
                      type = types.bool;
                      default = false;
                      description = "Whether this list accepts free-form text";
                    }; # 🦆 duck say ⮞ "in" values becomes ⮞ "out" values
                    options.values = mkOption {
                     type = types.listOf (types.submodule {
                        options."in" = mkOption { type = types.str; };
                        options.out = mkOption { type = types.str; };
                      });
                      default = [];
                    };
                  });
                  default = {};
                };
              });
            };
          });
          default = {};
        };
      };
    };
  };  
  # 🦆 ⮞ CONFIG  🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆#    
  config = { 
    # 🦆 duck say ⮞ expose diz module and all yo.scripts as a package
    yo.pkgs = yoScriptsPackage; # 🦆 duck say ⮞ reference as: ${config.pkgs.yo}/bin/yo-<name>
    assertions = let # 🦆 ⮞ safety first
      scripts = cfg.scripts;
      scriptNames = attrNames scripts;      
      # 🦆 duck say ⮞ quackin' flappin' mappin' aliasez ⮞ script dat belong to it 
      aliasMap = lib.foldl' (acc: script:
        lib.foldl' (acc': alias:
          acc' // { 
            ${alias} = (acc'.${alias} or []) ++ [script.name]; # 🦆 duck say ⮞ mmerge or start a list yo
          }
        ) acc script.aliases
      ) {} (attrValues scripts);
      # 🦆 duck say ⮞ find conflicts between script names & script aliases
      scriptNameConflicts = lib.filterAttrs (alias: _: lib.elem alias scriptNames) aliasMap;  
      # 🦆 duck say ⮞ find dem' double aliasez 
      duplicateAliases = lib.filterAttrs (_: scripts: lib.length scripts > 1) aliasMap;
      # 🦆 duck say ⮞ build da alias conflict error msg
      formatConflict = alias: scripts: 
        "Alias '${alias}' conflicts with script name (used by: ${lib.concatStringsSep ", " scripts})";       
      # 🦆 duck say ⮞ build da double rainbowz error msg yo
      formatDuplicate = alias: scripts: 
        "Alias '${alias}' used by multiple scripts: ${lib.concatStringsSep ", " scripts}";
      # 🦆 duck say ⮞ find auto-start scriptz - if i find i make sure it haz default values for all required paramz
      autoStartErrors = lib.mapAttrsToList (name: script:
        if script.autoStart then
          let # 🦆 duck say ⮞ filter dem not optional no defaultz
            missingParams = lib.filter (p: !p.optional && p.default == null) script.parameters;
          in
            if missingParams != [] then
              "🦆 duck say ⮞ fuck ❌ Cannot auto-start '${name}' - missing defaults for: " +
              lib.concatMapStringsSep ", " (p: p.name) missingParams
            else null
        else null
      ) scripts;    
      # 🦆 duck say ⮞ clean out dem' nullz! no nullz in ma ASSertionthz! ... quack
      actualAutoStartErrors = lib.filter (e: e != null) autoStartErrors;
   
    in [
      { # 🦆 duck say ⮞ assert no alias name cpmflict with script name 
        assertion = scriptNameConflicts == {};
        message = "🦆 duck say ⮞ fuck ❌ Alias/script name conflicts:\n" +
          lib.concatStringsSep "\n" (lib.mapAttrsToList formatConflict scriptNameConflicts);
      }
      { # 🦆 duck say ⮞ make sure dat aliases unique are yo
        assertion = duplicateAliases == {};
        message = "🦆 duck say ⮞ fuck ❌ Duplicate aliases:\n" +
          lib.concatStringsSep "\n" (lib.mapAttrsToList formatDuplicate duplicateAliases);
      }
      { # 🦆 duck say ⮞ autoStart scriptz must be fully configured of course!
        assertion = actualAutoStartErrors == [];
        message = "Auto-start errors:\n" + lib.concatStringsSep "\n" actualAutoStartErrors;
      }
    ];
    # 🦆 duck say ⮞ TODO replace with: system.activationScripts.update-readme.text = "${updateReadme}/bin/update-readme";
    system.build.updateReadme = pkgs.runCommand "update-readme" {
      helpTextFile = helpTextFile;
    } ''
      mkdir -p $out
      cp ${toString ./../README.md} $out/README.md
      ${pkgs.gnused}/bin/sed -i '/<!-- YO_DOCS_START -->/,/<!-- YO_DOCS_END -->/c\
    <!-- YO_DOCS_START -->\
    ## 🦆 **Yo Commands Reference**\
    *Automagiduckically generated from module definitions*\
    \
    '"$(cat ${helpTextFile})"'\
    <!-- YO_DOCS_END -->' $out/README.md
    '';
    environment.systemPackages = [
      config.yo.pkgs
      pkgs.glow # 🦆 duck say ⮞ For markdown renderin' in da terminal
      updateReadme # 🦆 duck say ⮞ to update da readme of course ya non duck
      (pkgs.writeShellScriptBin "yo" ''
        #!${pkgs.runtimeShell}
        script_dir="${yoScriptsPackage}/bin" 
        # 🦆 duck say ⮞ help command data (yo --help
        show_help() {
          #width=$(tput cols) # 🦆 duck say ⮞ Auto detect width
          width=130 # 🦆 duck say ⮞ fixed width
          cat <<EOF | ${pkgs.glow}/bin/glow --width $width -
        ## ──────⋆⋅☆☆☆⋅⋆────── ##
        ## 🦆🚀 **yo CLI** 🦆🦆 
        ## ──────⋆⋅☆☆☆⋅⋆────── ##
        **Usage:** \`yo <command> [arguments]\`
        ## ──────⋆⋅☆☆☆⋅⋆────── ##
        ## 🦆✨ Available Commands
        Parameters inside brackets are [optional]
        | Command Syntax               | Aliases    | Description |
        |------------------------------|------------|-------------|
        ${helpText}
        ## ──────⋆⋅☆☆☆⋅⋆────── ##
        ## 🦆❓ Detailed Help
        For specific command help: \`yo <command> --help\`
        \`yo bitch --help\` will list all defined voice intents.
        \`yo zigduck --help\` will display a battery status report for your deevices.
        🦆🦆
        EOF
          exit 0
        } # 🦆 duck say ⮞ handle zero args           
        if [[ $# -eq 0 ]]; then
          show_help
          exit 1
        fi
        # 🦆 duck say ⮞ parse da command
        case "$1" in # 🦆 duck say ⮞ handle zero args "-h" & "--help" to show da help
          -h|--help) show_help; exit 0 ;;
          *) command="$1"; shift ;;
        esac

        script_path="$script_dir/yo-$command"
        if [[ -x "$script_path" ]]; then
          exec "$script_path" "$@"
        else
          # 🦆 duck say ⮞ TODO FuzzYo commands! but until then..
          echo -e "\033[1;31m 🦆 duck say ⮞ fuck ❌ $1\033[0m Error: Unknown command '$command'" >&2
          show_help
          exit 1
        fi
      '')
      yoScriptsPackage
      updateReadme
    ];

    # 🦆 duck say ⮞ buildz systemd services if autoStart set to ttrue
    systemd.services = lib.mapAttrs' (name: script:
      lib.nameValuePair "yo-${name}" (mkIf script.autoStart {
        enable = true;
        wantedBy = ["multi-user.target"];
        after = ["sound.target" "network.target"  "pulseaudio.socket"];
        serviceConfig = {
          ExecStart = let
            args = lib.concatMapStringsSep " " (param:
              "--${param.name} ${lib.escapeShellArg param.default}"
            ) (lib.filter (p: p.default != null) script.parameters);
          in "${yoScriptsPackage}/bin/yo-${name} ${args}";
          User = config.this.user.me.name;
          Group = "audio";
          RestartSec = 45;
          Restart = "on-failure";
          Environment = [ # 🦆 ⮞ for microphone
            "XDG_RUNTIME_DIR=/run/user/1000"
            "PULSE_SERVER=unix:%t/pulse/native"
            "HOME=/home/${config.this.user.me.name}"
            "PATH=/run/current-system/sw/bin:/bin:/usr/bin"
          ];
        };
      })
    ) cfg.scripts;    
  };} # 🦆 duck say ⮞ 2 long script 4 jokez.. nao bai bai yo
# 🦆 says ⮞ QuackHack-McBLindy out!
# ... 🛌🦆💤


