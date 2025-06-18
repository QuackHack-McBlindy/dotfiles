# dotfiles/modules/yo.nix
# 🦆 duck say ⮞ This module defines the main execution system of my dotfiles repository.
# 🦆 duck say ⮞ A customizable yo CLI tool with voice command capabilities (yo bitch intent parser) automatic documentation generation, 
# 🦆 duck say ⮞ it's meant to be easily extended by defining user scripts as yo.scripts
# 🦆 duck say ⮞ If you need to access defined scripts as packages you can do so with:
# 🦆 duck say ⮞ ${config.pkgs.yo}/bin/yo-<script-name>
{ 
  config,
  lib,
  pkgs,
  ...
} : with lib;
let
 
  parameterType = types.submodule {
    options = {
      name = mkOption { type = types.str; };
      entity = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
    };
  };

  intentPatternType = types.submodule {
    options = {
      template = mkOption { type = types.str; };
      parameters = mkOption {
        type = types.listOf parameterType;
        default = [];
      };
    };
  };

  entityType = types.submodule {
    options = {
      match = mkOption { type = types.listOf types.str; };
      value = mkOption { type = types.str; };
    };
  };

  generateRegex = listName:
    let
      list = config.yo.bitch.lists.${listName};
      patterns = if list.wildcard then "(.*)" else
        builtins.concatStringsSep "|" (map (v: v."in") list.values);
    in
      "(${patterns})";

  processSentence = sentence: builtins.replaceStrings
    (builtins.attrNames config.yo.bitch.lists)
    (map (name: generateRegex name) (builtins.attrNames config.yo.bitch.lists))
    sentence;

  intentRules = builtins.mapAttrs (intentName: intent:
    map (d: map processSentence d.sentences) intent.data
  ) config.yo.bitch.intents;

  nixosVersion = let
    raw = builtins.readFile /etc/os-release;
    versionMatch = builtins.match ".*VERSION_ID=([0-9\\.]+).*" raw;
  in builtins.replaceStrings [ "." ] [ "%2E" ] (builtins.elemAt versionMatch 0);
  
  # 🦆 duck say ⮞ Helper to escape markdown special characters
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
  # 🦆 duck say ⮞ Documentation generation with markdown escaping
  generateDocs = let
    scriptDocs = mapAttrsToList (name: script: 
      let
        safeDesc = escapeMD script.description;
        # 🦆 duck say ⮞ Handle aliases as string
        aliases = if script.aliases != [] then
          "*Aliases:* ${concatStringsSep ", " (map escapeMD script.aliases)}\n\n"
        else
          "";
        
        # 🦆 duck say ⮞ Handle parameters with escaped descriptions        
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

  # 🦆 duck say ⮞ manual readme is so 1800 duck
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

    # 🦆 duck say ⮞  Get generated help text
    HELP_CONTENT=$(<${helpTextFile})

    DOCS_CONTENT=$(cat <<'EOF'
## 🚀 **yo CLI TOol 🦆🦆🦆🦆🦆🦆**
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
The yo CLI tool supports flexible parameter parsing through two primary mechanisms:  

```bash
# Named Parameters  
$ yo deploy --host laptop --flake /home/pungkula/dotfiles

# Positional Parameters
$ yo deploy laptop /home/pungkula/dotfiles

# Scripts can also be executed with voice, by saying:
"yo bitch deploy laptop"

# If the server is not running, it can be manually started with:
$ yo-bitch

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
    
    FLAKE_OUTPUT=$(nix flake show "${config.this.user.me.dotfilesDir}" | sed -e 's/\x1B\[[0-9;]*[A-Za-z]//g')
    FLAKE_BLOCK=$(
      echo '```nix'
      echo "$FLAKE_OUTPUT"
      echo '```'
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
        echo "❌ Failed to update README.md (permissions?)" >&2
        rm "$tmpfile"
        exit 1
      fi
    else
      echo "✅ No content changes needed"
    fi

    if ! diff -q "$tmpfile" "$README_PATH" >/dev/null; then
      if [ -w "$README_PATH" ]; then
        cat "$tmpfile" > "$README_PATH"
        echo "🦆 duck say > Updated README.md"
      else
        echo "Cannot update $README_PATH: Permission denied" >&2
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
  
#== OPTIONS =====================#    
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
      category = mkOption {
        type = types.str;
        description = "Category of the script";
      };  
      helpFooter = mkOption {
        type = types.lines;
        default = "";
        description = "Additional shell code to run when generating help text";
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
      intents = {
        patterns = mkOption {
          type = types.listOf types.attrs;
          default = [];
          description = "List of intent patterns";
        };

        entities = mkOption {
          type = types.attrsOf (types.listOf types.attrs);
          default = {};
          description = "Entity match mappings";
        };
      };

      # 🦆 duck say ⮞ parameter options for the yo script 
      parameters = mkOption {
        type = types.listOf (types.submodule {
          options = {
            name = mkOption { type = types.str; };
            description = mkOption { type = types.str; };
            default = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Default value if parameter is not provided";
            };
            optional = mkOption { 
              type = types.bool; 
              default = ./default != null;
              description = "Whether this parameter can be omitted";
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

  # 🦆 duck say ⮞ dis and dat builds da script, yo! 
  yoScriptsPackage = pkgs.symlinkJoin {
    name = "yo-scripts";
    paths = mapAttrsToList (name: script:
      let
        # 🦆 duck say ⮞ Generate parameter usage string at Nix level
        param_usage = lib.concatMapStringsSep " " (param:
          if param.optional
          then "[--${param.name}]"
          else "--${param.name}"
        ) (lib.filter (p: !builtins.elem p.name ["!" "?"]) script.parameters);

        scriptContent = ''
          #!${pkgs.runtimeShell}
#          set -euo pipefail
          ${yoEnvGenVar script}
            
          # 🦆 duck say ⮞ Phase 1: Preprocess special flags
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
     
          # 🦆 duck say ⮞ Reset arguments without special flags
          set -- "''${FILTERED_ARGS[@]}"

          # 🦆 duck say ⮞ Phase 2: Regular parameter parsing
          declare -A PARAMS=()
          POSITIONAL=()
          VERBOSE=$VERBOSE
          DRY_RUN=$DRY_RUN
          
          # 🦆 duck say ⮞ Parse all parameters
          while [[ $# -gt 0 ]]; do
            case "$1" in
              --help|-h)
                width=$(tput cols 2>/dev/null || echo 100)
                help_footer=$(${script.helpFooter})
                cat <<EOF | ${pkgs.glow}/bin/glow --width "$width" -
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

            # 🦆 duck say ⮞ Phase 3: Assign parameters
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

          # 🦆 duck say ⮞ Apply default values for parameters
          ${concatStringsSep "\n" (map (param: 
            optionalString (param.default != null) ''
              if [[ -z "''${${param.name}:-}" ]]; then
                ${param.name}='${param.default}'
              fi
            '') script.parameters)}
            
          # 🦆 duck say ⮞ Then check required parameters
          ${concatStringsSep "\n" (map (param: ''
            ${optionalString (!param.optional && param.default == null) ''
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

  helpText2 = let
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

        # 🦆 duck say ⮞ Escape backticks by using a literal backtick (not shell-evaluated)
        syntax = "\\`yo ${script.name} ${paramHint}\\`";
      in "| ${syntax} | ${aliasList} | ${script.description} |"
    ) (attrValues cfg.scripts);
  in
    concatStringsSep "\n" rows;
 
  
  helpTextFile = pkgs.writeText "yo-helptext.md" helpText;
  helpText = let
    groupedScripts = lib.groupBy (script: script.category) (lib.attrValues cfg.scripts);
    sortedCategories = lib.sort (a: b: 
      if a == "🖥️ System Management" then true
      else if b == "🖥️ System Management" then false
      else a < b
    ) (lib.attrNames groupedScripts);
  
    # 🦆 duck say ⮞ Create table rows with category separators
    rows = lib.concatMap (category:
      let 
        scripts = lib.sort (a: b: a.name < b.name) groupedScripts.${category};
      in
        [
          "| **${escapeMD category}** | | |"
        ] 
        ++ 
        (map (script:
          let
            aliasList = if script.aliases != [] then
              concatStringsSep ", " (map escapeMD script.aliases)
            else "";
            paramHint = concatStringsSep " " (map (param:
              if param.optional || param.default != null
              then "[--${param.name}]"
              else "--${param.name}"
            ) script.parameters);
            syntax = "\\`yo ${escapeMD script.name} ${paramHint}\\`";
          in
            "| ${syntax} | ${aliasList} | ${escapeMD script.description} |"
        ) scripts)
    ) sortedCategories;
  in concatStringsSep "\n" rows;
  
in {
  options = {
    pkgs.yo = mkOption {
      type = types.package;
      readOnly = true;
      description = "The final yo scripts package";
    };
    yo.scripts = mkOption {
      type = types.attrsOf scriptType;
      default = {};
      description = "Attribute set of scripts to be made available";
    };
    yo.bitch = {
      language = mkOption {
        type = types.str;
        default = "en";
        description = "Language code for parsing rules";
      };
      intents = mkOption {
        type = types.attrsOf (types.submodule {
          options.data = mkOption {
            type = types.listOf (types.submodule {
              options.sentences = mkOption {
                type = types.listOf types.str;
                default = [];
                description = "Sentence patterns for intent matching";
              };

              options.lists = mkOption {
                type = types.attrsOf (types.submodule {
                  options.wildcard = mkOption {
                    type = types.bool;
                    default = false;
                    description = "Whether this list accepts free-form text";
                  };
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


  config = {
    assertions = let
      scripts = cfg.scripts;
      scriptNames = attrNames scripts;
      
      # 🦆 duck say ⮞ Build mapping of alias -> [script names that use it]
      aliasMap = lib.foldl' (acc: script:
        lib.foldl' (acc': alias:
          acc' // { 
            ${alias} = (acc'.${alias} or []) ++ [script.name]; 
          }
        ) acc script.aliases
      ) {} (attrValues scripts);

      # 🦆 duck say ⮞ Find conflicts with script names
      scriptNameConflicts = lib.filterAttrs (alias: _: lib.elem alias scriptNames) aliasMap;
      
      # 🦆 duck say ⮞ Find duplicate aliases (used by multiple scripts)
      duplicateAliases = lib.filterAttrs (_: scripts: lib.length scripts > 1) aliasMap;

      formatConflict = alias: scripts: 
        "Alias '${alias}' conflicts with script name (used by: ${lib.concatStringsSep ", " scripts})";
        
      formatDuplicate = alias: scripts: 
        "Alias '${alias}' used by multiple scripts: ${lib.concatStringsSep ", " scripts}";

    in [
      {
        assertion = scriptNameConflicts == {};
        message = "Alias/script name conflicts:\n" +
          lib.concatStringsSep "\n" (lib.mapAttrsToList formatConflict scriptNameConflicts);
      }
      {
        assertion = duplicateAliases == {};
        message = "Duplicate aliases:\n" +
          lib.concatStringsSep "\n" (lib.mapAttrsToList formatDuplicate duplicateAliases);
      }
    ];
  
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
      updateReadme
      (pkgs.writeShellScriptBin "yo" ''
        #!${pkgs.runtimeShell}
        script_dir="${yoScriptsPackage}/bin"
        
        # 🦆 duck say ⮞ help command data (yo --help
        show_help() {
          #width=$(tput cols) # 🦆 duck say ⮞ Auto detect width
          width=130 # 🦆 duck say ⮞ fixed width
          cat <<EOF | ${pkgs.glow}/bin/glow --width $width -
        ## ──────⋆⋅☆⋅⋆────── ##
        ## 🚀 **yo CLI TOol** 🦆🦆🦆🦆🦆🦆
        ## ──────⋆⋅☆⋅⋆────── ##
        **Usage:** \`yo <command> [arguments]\`
        
        ## ──────⋆⋅☆⋅⋆────── ##
        ## ✨ Available Commands
        | Command Syntax               | Aliases    | Description |
        |------------------------------|------------|-------------|
        ${helpText}
        ## ──────⋆⋅☆⋅⋆────── ##
        ## ℹ️ Detailed Help
        For specific command help: \`yo <command> --help\`
        EOF
          exit 0
        }     
        # 🦆 duck say ⮞ Handle zero arguments
        if [[ $# -eq 0 ]]; then
          show_help
          exit 1
        fi

        # 🦆 duck say ⮞ Parse command
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
    ];
    
    # 🦆 duck say ⮞ Expose dis module and all yo.scripts as a package
    pkgs.yo = yoScriptsPackage; # reference as: ${config.pkgs.yo}/bin/yo-<script name>
  };}


