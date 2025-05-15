{ 
  config,
  lib,
  pkgs,
  ...
} : with lib;
let
  nixosVersion = let
    raw = builtins.readFile /etc/os-release;
    versionMatch = builtins.match ".*VERSION_ID=([0-9\\.]+).*" raw;
  in builtins.replaceStrings [ "." ] [ "%2E" ] (builtins.elemAt versionMatch 0);
  
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
    # Inside the shell script portion, use Nix-provided version
    FLAKE_OUTPUT=$(nix flake show "${config.this.user.me.dotfilesDir}" | sed -e 's/\x1B\[[0-9;]*[A-Za-z]//g')
    FLAKE_BLOCK=$(
      echo '```nix'
      echo "$FLAKE_OUTPUT"
      echo '```'
    )

    #  Get generated help text from Nix-built file
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

1. **Named Parameters:**  

```bash
$ yo deploy --host laptop --flake /home/pungkula/dotfiles
```

2. **Positional Parameters:**  

```bash
$ yo deploy laptop /home/pungkula/dotfiles
```

3. **Scripts can also be executed by voice, say:**  

```bash
$ yo bitch tv Duck Tales 
$ yo bitch reboot laptop 
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

    bash_version=$(bash --version | head -n1 | awk '{print $4}' | cut -d'(' -f1)
    gnome_version=$(gnome-shell --version | awk '{print $3}')
    sanitized_bash=''${bash_version//./%2E}
    sanitized_gnome=''${gnome_version//./%2E}

    bash_badge="https://img.shields.io/badge/Bash-''${sanitized_bash}-red"
    gnome_badge="https://img.shields.io/badge/GNOME-''${sanitized_gnome}-purple"
    sed -i "s|https://img.shields.io/badge/Bash-[^-]*-red|$bash_badge|g" "$README_PATH"
    sed -i "s|https://img.shields.io/badge/GNOME-[^-]*-purple|$gnome_badge|g" "$README_PATH"

    # Get current versions
    nixos_version=$(nixos-version | cut -d. -f1-2 | tr . %2E)
    kernel_version=$(uname -r | cut -d'-' -f1)
    nix_version=$(nix --version | awk '{print $3}')

    # Update README.md with proper escaping
    sed -i -E \
      -e "s/NixOS-[0-9]+%2E[0-9]+/NixOS-$nixos_version/g" \
      -e "s/Linux-[0-9]+\.[0-9]+\.[0-9]+/Linux-$kernel_version/g" \
      -e "s/Nix-[0-9]+\.[0-9]+\.[0-9]+/Nix-$nix_version/g" \
      "$README_PATH"
    
    # Version extraction
    VERSION=$( (grep VERSION_ID= /etc/os-release || echo 'VERSION_ID="0.0"') | cut -d= -f2 | tr -d '"')
    if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+$ ]]; then
      echo "⚠️  Invalid version detected: $VERSION, using fallback"
      VERSION="unknown"
    fi

    # Sanitized badge URL construction
    VERSION=$(grep VERSION_ID= /etc/os-release | cut -d= -f2 | tr -d '"')
    SANITIZED_VERSION=''${VERSION//./%2E}
    BADGE_URL="https://img.shields.io/badge/NixOS-''${SANITIZED_VERSION}-blue"
    sed -i "s|https://img.shields.io/badge/NixOS-[^-]*-blue|''${BADGE_URL}|g" README.md

    FLAKE_OUTPUT=$(nix flake show "${config.this.user.me.dotfilesDir}" | sed -e 's/\x1B\[[0-9;]*[A-Za-z]//g')
    FLAKE_BLOCK=$(
      echo '```nix'
      echo "$FLAKE_OUTPUT"
      echo '```'
    )

    # flake.nix content
    FLAKE_BLOCK_NIX=$(
      echo '```nix'
      cat "${config.this.user.me.dotfilesDir}/flake.nix"
      echo '```'
    )

    awk -v docs="$DOCS_CONTENT" -v tree="$FLAKE_BLOCK" -v flake="$FLAKE_BLOCK_NIX" '
      BEGIN { in_docs=0; in_tree=0; in_flake=0 }
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
      /<!-- FLAKE_START -->/ {
        print
        print flake
        in_flake=1
        next
      }
      /<!-- FLAKE_END -->/ {
        in_flake=0
        print
        next
      }
      !in_docs && !in_tree && !in_flake { print }
    ' "$README_PATH" > "$tmpfile"


    # Diff check
    if ! cmp -s "$tmpfile" "$README_PATH"; then
      echo "🌀 Changes detected, updating README.md"
      if ! install -m 644 "$tmpfile" "$README_PATH"; then
        echo "❌ Failed to update README.md (permissions?)" >&2
        rm "$tmpfile"
        exit 1
      fi
    else
      echo "✅ No content changes needed"
    fi

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
      
      category = mkOption {
        type = types.str;
        description = "Category of the script";
      };
    
      packages = mkOption {
        type = types.listOf types.package;
        default = [];
        description = "List of packages needed by this script";
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
        # Generate parameter usage string at Nix level
        param_usage = lib.concatMapStringsSep " " (param:
          if param.optional
          then "[--${param.name}]"
          else "--${param.name}"
        ) (lib.filter (p: !builtins.elem p.name ["!" "?"]) script.parameters);

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
#  helpTextFile = pkgs.writeText "yo-helptext.md" helpText;
#  helpText = (
#    let
#      rows = map (script:
#        let
#          aliasList = if script.aliases != [] then
#            concatStringsSep ", " script.aliases
#          else
#            "";
#          paramHint = let
#            optionsPart = lib.concatMapStringsSep " " (param: 
              # Show as optional if EITHER has default OR explicitly marked optional
#              if (param.default != null || param.optional) 
#              then "[--${param.name}]" 
#              else "--${param.name}"
#            ) script.parameters;
#          in optionsPart;
#          syntax = "\\`yo ${script.name} ${paramHint}\\`";
#        in "| ${syntax} | ${aliasList} | ${script.description} |"
#      ) (attrValues cfg.scripts);
#    in
#      concatStringsSep "\n" rows
#  );

  helpTextFile = pkgs.writeText "yo-helptext.md" helpText;
  helpText = let
    groupedScripts = lib.groupBy (script: script.category) (lib.attrValues cfg.scripts);
    sortedCategories = lib.sort (a: b: a < b) (lib.attrNames groupedScripts);
    
    # Create table rows with category separators
    rows = lib.concatMap (category:
      let 
        scripts = lib.sort (a: b: a.name < b.name) groupedScripts.${category};
      in
        [
          # Category separator row
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
  in concatStringsSep "\n" rows;  # Add this final expression  

in {
  options.yo.scripts = mkOption {
    type = types.attrsOf scriptType;
    default = {};
    description = "Attribute set of scripts to be made available";
  };

  config = {
 
    assertions = let
      scripts = cfg.scripts;
      scriptNames = attrNames scripts;
      
      # Build mapping of alias -> [script names that use it]
      aliasMap = lib.foldl' (acc: script:
        lib.foldl' (acc': alias:
          acc' // { 
            ${alias} = (acc'.${alias} or []) ++ [script.name]; 
          }
        ) acc script.aliases
      ) {} (attrValues scripts);

      # Find conflicts with script names
      scriptNameConflicts = lib.filterAttrs (alias: _: lib.elem alias scriptNames) aliasMap;
      
      # Find duplicate aliases (used by multiple scripts)
      duplicateAliases = lib.filterAttrs (_: scripts: lib.length scripts > 1) aliasMap;

      formatConflict = alias: scripts: 
        "Alias '${alias}' conflicts with script name (used by: ${lib.concatStringsSep ", " scripts})";
        
      formatDuplicate = alias: scripts: 
        "Alias '${alias}' used by multiple scripts: ${lib.concatStringsSep ", " scripts}";

    #  Get generated help text from Nix-built file
#    HELP_CONTENT=$(<${helpTextFile})

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

### **Usage Examples:**
The yo CLI tool supports flexible parameter parsing through two primary mechanisms:  

1. **Named Parameters:**  

```bash
$ yo deploy --host laptop --flake /home/pungkula/dotfiles
```

2. **Positional Parameters:**  

```bash
$ yo deploy laptop /home/pungkula/dotfiles
```

3. **Scripts can also be executed by voice, say:**  

```bash
$ yo bitch tv Duck Tales 
$ yo bitch reboot laptop 
```

## ✨ Available Commands
Set default values for your parameters to have them marked [optional]
| Command Syntax               | Aliases    | Description |
|------------------------------|------------|-------------|
${helpText}
## ❓ Detailed Help
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
    ];
    
  };}


