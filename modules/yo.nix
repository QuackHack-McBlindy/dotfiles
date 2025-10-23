# dotfiles/modules/yo.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 duck say ⮞ CLI framework - centralized script handling
  config,
  lib,       
  pkgs,   
  ...
} : with lib;
let # 🦆 says ⮞ for README version badge yo
  nixosVersion = let
    raw = builtins.readFile /etc/os-release;
    versionMatch = builtins.match ".*VERSION_ID=([0-9\\.]+).*" raw;
  in builtins.replaceStrings [ "." ] [ "%2E" ] (builtins.elemAt versionMatch 0);

  # 🦆 duck say ⮞ validate time format - HH:MM (24h)
  isValidTime = timeStr:
    let
      matches = builtins.match "([0-9]{1,2}):([0-9]{2})" timeStr;
    in
      if matches != null then
        let
          hourStr = builtins.elemAt matches 0;
          minuteStr = builtins.elemAt matches 1;
          # 🦆 duck say ⮞ remove leading zeros for JSON parsin'
          cleanNumber = str:
            if builtins.substring 0 1 str == "0" && builtins.stringLength str > 1
            then builtins.substring 1 (builtins.stringLength str) str
            else str;
          hour = builtins.fromJSON (cleanNumber hourStr);
          minute = builtins.fromJSON (cleanNumber minuteStr);
        in
          hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59
      else false;
  
  # 🦆 duck say ⮞ validate list of timez
  validateTimes = times:
    if times == null then null
    else
      let
        invalidTimes = lib.filter (time: !isValidTime time) times;
      in
        if invalidTimes != [] then
          throw "🦆 duck say ⮞ fuck ❌ Invalid time format in runAt: ${lib.concatStringsSep ", " invalidTimes}. Use HH:MM (24-hour format)"
        else times;

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

  # 🦆 says ⮞ we be doin' sorta da same wit dem listz
  expandListInputVariants = value: 
    let # 🦆 says ⮞ first we choppy choppy - break up da list into word tokenz
      tokens = lib.splitString " " value;
      # 🦆 says ⮞ checkin' if a token be wrapped like [diz] = optional, ya feel?
      isOptional = t: lib.hasPrefix "[" t && lib.hasSuffix "]" t;
      # 🦆 says ⮞ now ducklin' expandz each token — either real or optional wit options
      expandToken = token:
        if isOptional token then
          let # 🦆 says ⮞ time 2 clean dat square junk up 4 yo bro
            clean = lib.removePrefix "[" (lib.removeSuffix "]" token);
             # 🦆 says ⮞ u know da drill - splittin' on da "|" to find alt optionalz
            alternatives = lib.splitString "|" clean;
          in
            alternatives
        else # 🦆 says ⮞ not optional? just be givin' back da token as iz
          [ token ];
      expanded = cartesianProductOfLists (map expandToken tokens);
      variants = map (tokenList:
        lib.replaceStrings [ "  " ] [ " " ] (lib.concatStringsSep " " tokenList)
      ) expanded;  # 🦆 says ⮞ only da fresh unique non-emptiez stayin’ in da pond
    in lib.unique (lib.filter (s: s != "") variants);


  # 🦆 duck say ⮞ manual readme is so 1999 duckie
  updateReadme = pkgs.writeShellScriptBin "update-readme" ''
    README_PATH="${config.this.user.me.dotfilesDir}/README.md"
    CONTACT_OUTPUT=""
    USER_TMP=$(mktemp)
    HOST_TMP=$(mktemp)

    # 🦆 duck say ⮞ count scripts in bin
    count_bin() {
      nix eval ${config.this.user.me.dotfilesDir}#nixosConfigurations.${config.this.host.hostname}.config.yo.scripts --json | jq 'keys | length'
    }
    # 🦆 duck say ⮞ count scripts with sentences defined
    count_voice() {
      nix eval ${config.this.user.me.dotfilesDir}#nixosConfigurations.${config.this.host.hostname}.config.yo.scripts --json \
        | jq '[.[] | select(.voice? and .voice.sentences?)] | length'
    }
    # 🦆 duck say ⮞ count generated patterns
    count_patterns() {
      nix eval ${config.this.user.me.dotfilesDir}#nixosConfigurations.${config.this.host.hostname}.config.yo.generatedPatterns
    }
    # 🦆 duck say ⮞ count generated patterns
    count_phrases() {
      nix eval ${config.this.user.me.dotfilesDir}#nixosConfigurations.${config.this.host.hostname}.config.yo.understandsPhrases
    }    

    # 🦆 duck say ⮞ Get script counts
    total_scripts=$(count_bin)
    voice_scripts=$(count_voice)    
    total_patterns=$(count_patterns)
    total_phrases=$(count_phrases)

    # 🦆 duck say ⮞ nix > json > nix lol
    json2nix() {
      nix eval ${config.this.user.me.dotfilesDir}#nixosConfigurations.${config.this.host.hostname}.config."$1" --json | jq -r -f <(cat <<'JQ'
def indent(n): reduce range(0;n) as $i (""; . + "  ");
def toNixValue(level):
  if type == "object" then
    "{\n" +
    (to_entries
     | map(indent(level+1) + "\(.key) = \(.value|toNixValue(level+1));")
     | join("\n")) +
    "\n" + indent(level) + "}"
  elif type == "array" then
    "[\n" +
    (map(indent(level+1) + (toNixValue(level+1)))
     | join("\n")) +
    "\n" + indent(level) + "]"
  elif type == "string" then
    "\"\(.|tostring)\""
  elif type == "boolean" then
    if . then "true" else "false" end
  elif . == null then
    "null"
  else
    tostring
  end;

def toNix: toNixValue(0);
toNix
JQ
)
    }

    # 🦆 duck say ⮞ get da defined smart home
    ZIGBEE_DEVICES_BLOCK=$(json2nix house.zigbee.devices)
    ZIGBEE_SCENES_BLOCK=$(json2nix house.zigbee.scenes)
    TVS_BLOCK=$(json2nix house.tv)

    SMART_HOME_BLOCK=$(
      echo "<details><summary><strong>"
      echo "Zigbee devices at \`config.house.zigbee.devices\`."
      echo "</strong></summary>"
      echo "<!-- ZIGBEE_DEVICES_START -->"
      echo '```nix'
      echo "$ZIGBEE_DEVICES_BLOCK"
      echo '```'
      echo "<!-- ZIGBEE_DEVICES_END -->"
      echo "</details>"
  
      echo "<br>"
      echo "<details><summary><strong>"
      echo "Zigbee scenes at \`config.house.zigbee.scenes\`."
      echo "</strong></summary>"
      echo "<!-- ZIGBEE_SCENES_START -->"
      echo '```nix'
      echo "$ZIGBEE_SCENES_BLOCK"
      echo '```'
      echo "<!-- ZIGBEE_SCENES_END -->"
      echo "</details>"

      echo "<br>"
      echo "<details><summary><strong>"
      echo "Android TV devices at \`config.house.tv\`."
      echo "</strong></summary>"
      echo "<!-- TVS_START -->"
      echo '```nix'
      echo "$TVS_BLOCK"
      echo '```'
      echo "<!-- TVS_END -->"
      echo "</details>"      
    )

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
## 🚀 **yo CLI 🦆**
The \`yo\` CLI is a framework designed to execute scripts defined in the \`./bin\` directory.  
It provides a unified interface for script execution, centralizes all help commands, and automatically validates parametrs and updates the documentation.  

**Usage:** \`yo <command> [arguments]\`  

### **Usage Examples:**  
The yo CLI supports flexible parameter parsing through two primary mechanisms:  

```bash
# Named Parameters  
$ yo deploy --host laptop --flake /home/pungkula/dotfiles

# Positional Parameters
$ yo deploy laptop /home/pungkula/dotfiles

# Scripts can also be executed with natural language text by typing:
$ yo do "is laptop overheating"
# Natural language voice commands are also supported, say:
"yo bitch reboot the laptop"

# If the server is not running, it can be manually started with:
$ yo transcribe
$ yo wake
```

### ✨ Available Commands
Set default values for your parameters to have them marked [optional]
| Command Syntax               | Aliases    | Description | VoiceReady |
|------------------------------|------------|-------------|--|
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

    STATS_BLOCK=$(
      echo "- __$total_scripts qwacktastic scripts in /bin - $voice_scripts scripts have voice commands.__ <br>"
      echo "- __$total_patterns dynamically generated regex patterns - makes $total_phrases phrases available as commands.__ <br>"            
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
        -v stats="$STATS_BLOCK" \
        -v smart="$SMART_HOME_BLOCK" \
        '
      BEGIN { in_docs=0; in_contact=0; in_tree=0; in_flake=0; in_host=0; in_user=0; in_stats=0; in_smart=0; printed=0 }

      /<!-- YO_DOCS_START -->/ { in_docs=1; print; print docs; next }
      /<!-- YO_DOCS_END -->/ { in_docs=0; print; next }
      /<!-- SCRIPT_STATS_START -->/ { in_stats=1; print; print stats; next }
      /<!-- SCRIPT_STATS_END -->/ { in_stats=0; print; next }
      /<!-- HOST_START -->/ { in_host=1; print; print host; next }
      /<!-- HOST_END -->/ { in_host=0; print; next }
      /<!-- THEME_START -->/ { in_theme=1; print; print theme; next }
      /<!-- THEME_END -->/ { in_theme=0; print; next }
      /<!-- SMARTHOME_START -->/ { in_smart=1; print; print smart; next }
      /<!-- SMARTHOME_END -->/ { in_smart=0; print; next }
      /<!-- USER_START -->/ { in_user=1; print; print user; next }
      /<!-- USER_END -->/ { in_user=0; print; next }
      /<!-- TREE_START -->/ { in_tree=1; print; print tree; next }
      /<!-- TREE_END -->/ { in_tree=0; print; next }
      /<!-- FLAKE_START -->/ { in_flake=1; print; print flake; next }
      /<!-- FLAKE_END -->/ { in_flake=0; print; next }
      !in_docs && !in_tree && !in_theme && !in_flake && !in_smart && !in_stats && !in_host && !in_user { print }
      ' "$README_PATH" > "$tmpfile"  

    # 🦆 duck say ⮞ diff check
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
    exports = map (p: 
      let # 🦆 duck say ⮞ convert dem Nix types 2 shell strings
        defaultValue = 
          if p.type == "string" then lib.escapeShellArg (toString p.default)
          else if p.type == "int" then toString p.default
          else if p.type == "bool" then (if p.default then "true" else "false")
          else if p.type == "path" then lib.escapeShellArg (toString p.default)
          else lib.escapeShellArg (toString p.default);
      in
        "export ${p.name}=${defaultValue}"
    ) withDefaults;
  in lib.concatStringsSep "\n" exports;

  scriptType = types.submodule ({ name, configFinal, ... }: {   
# 🦆 ⮞ OPTIONS 🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆#    
    options = { # 🦆 duck say ⮞ a name cool'd be cool right?
      name = mkOption {
        type = types.str;
        internal = true;
        readOnly = true;
        default = name;
        description = "Script name derived from attribute key";
      }; # 🦆 duck say ⮞ describe yo script yo!
      description = mkOption {
        type = types.str;
        default = "";
        description = "Description of the script";
      }; # 🦆 duck say > categoryiez da script (for sorting in `yo --help` & README.md    
      category = mkOption {
        type = types.str;
        default = "";
        description = "Category of the script";
      };
      filePath = mkOption {
        type = types.str;
        readOnly = true;
      };
      # 🦆 duck say ⮞ yo go ahead describe da script yo     
      visibleInReadme = mkOption {
        type = types.bool;
        default = ./category != "";
        defaultText = "category != \"\"";
        description = "Whether to include this script in README.md";
      }; # 🦆 duck say ⮞ duck trace log level
      logLevel = mkOption {
        type = types.enum ["DEBUG" "INFO" "WARNING" "ERROR" "CRITICAL"];
        default = "INFO";
        description = "Sets the log level for Duck Trace";
      }; # 🦆 duck say ⮞ extra code to be ran & displayed whelp calling da scripts --help cmd  
      helpFooter = mkOption {
        type = types.lines;
        default = "";
        description = "Additional shell code to run when generating help text";
      }; # 🦆 duck say ⮞ generatez systemd service for da script if true 
      autoStart = mkOption {
        type = types.bool;
        default = false;
        description = "Run the script in the background at startup";
      };
      runEvery = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Run this script periodically every X minutes";
      }; # 🦆 duck say ⮞ run at specific time
      runAt = mkOption {
        type = types.nullOr (types.listOf (types.strMatching "[0-9]{1,2}:[0-9]{2}"));
        default = null;
        description = "Run this script at specific times daily (format: [HH:MM, ...], 24-hour)";
        apply = validateTimes;
      }; # 🦆 duck say ⮞ code to be executed when calling tda script yo      
      code = mkOption {
        type = types.lines;
        description = "The script code";
      }; # 🦆 duck say ⮞ alias for da script for extra execution triggerz 
      aliases = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Alternative command names for this script";
      }; # 🦆 duck say ⮞ read-only option dat showz da number of generated regex patternz
      voicePatterns = mkOption {
        type = types.int;
        internal = true;
        readOnly = true;
        description = "Number of regex patterns generated for this script's voice commands";      
      }; # 🦆 duck say ⮞ phrase coverage for this script
      voicePhrases = mkOption {
        type = types.int;
        internal = true;
        readOnly = true;
        description = "Theoretical number of unique spoken phrases this script can understand";   
      }; # 🦆 duck say ⮞ parameter options for the yo script we writin' 
      parameters = mkOption {
        type = types.listOf (types.submodule {
          options = { # 🦆 duck say ⮞ parameters = [{ name = ""; description = ""; default = "": optional = "": type = ""; }]; 
            name = mkOption { type = types.str; };
            description = mkOption { type = types.str; };
            default = mkOption {
              type = types.nullOr (types.oneOf [
                types.str
                types.int
                types.bool
                types.path
              ]);
              default = null;
              description = "Default value if parameter is not provided";
            }; # 🦆 duck say ⮞ i likez diz option - highly useful
            optional = mkOption { 
              type = types.bool; 
              default = ./default != null;
              description = "Whether this parameter can be omitted";
            }; # 🦆 duck say ⮞ diz makez da param sleazy eazy to validate yo 
            type = mkOption {
              type = types.enum ["string" "int" "path" "bool"];
              default = "string";
              description = "Type of parameter. Use path for filepath int for numbers, bool for true/false flags, and string (default) for all others";
            };
          };
        });
        default = [];
        description = "Parameters accepted by this script";
      };
      voice = mkOption {
        type = types.nullOr (types.submodule {
          options = {
            enabled = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Whether to generate voice intents for this script";
            };
            priority = mkOption {
              type = types.ints.between 1 5;
              default = 3;
              description = "Processing priority (1=highest, 5=lowest)";
            };
            sentences = mkOption {
              type = types.listOf types.str;
              default = [];
              description = "Voice command patterns for this script";
            };
            lists = mkOption {
              type = types.attrsOf (types.submodule {
                options = {
                  wildcard = mkOption {
                    type = types.bool;
                    default = false;
                    description = "Accept free-form text input";
                  };
                  values = mkOption {
                    type = types.listOf (types.submodule {
                      options."in" = mkOption { type = types.str; };
                      options.out = mkOption { type = types.str; };
                    });
                    default = [];
                  };
                };
              });
              default = {};
              description = "Entity lists for voice parameters";
            };
          };
        });
        default = null;
        description = "Voice command configuration for this script";
      }; # 🦆 duck say ⮞ read-only option dat showz if da script haz voice
      voiceReady = mkOption {
        type = types.bool;
        internal = true;
        readOnly = true;
        description = "Whether this script has voice commands configured";
      };
    };
    config = let # 🦆 duck say ⮞ map categories to bin directories
      categoryDirMap = {
        "🎧 Media Management" = "bin/media";
        "⚙️ Configuration" = "bin/config";
        "🛖 Home Automation" = "bin/home";
        "🧹 Maintenance" = "bin/maintenance";
        "🧩 Miscellaneous" = "bin/misc";
        "🌐 Networking" = "bin/network";
        "🌍 Localization" = "bin/misc";
        "⚡ Productivity" = "bin/productivity";
        "🖥️ System Management" = "bin/system";
        "🔐 Security & Encryption" = "bin/security";
      };  
      script = config.yo.scripts.${name};      
      vr = config.yo.scripts.${name}.voiceReady;      
      category = config.yo.scripts.${name}.category;
      resolvedDir = categoryDirMap.${category} or "bin/misc"; # 🦆 duck say ⮞ falback to bin/misc
    in { # 🦆 duck say ⮞ set scripts filepath
      filePath = mkDefault "${resolvedDir}/${name}.nix";
      voiceReady = mkDefault (
        script.voice != null && 
        script.voice.sentences != [] &&
        script.voice.sentences != null
      );
      # 🦆 duck say ⮞ set script counterz
      voicePatterns = mkDefault (countGeneratedPatterns script);
      voicePhrases = mkDefault (countUnderstoodPhrases script);
    };
  });
  cfg = config.yo;

  # 🦆 duck say ⮞ letz create da yo scripts pkgs - we symlinkz all yo scripts togetha .. quack quack 
  yoScriptsPackage = pkgs.symlinkJoin {
    name = "yo-scripts"; # 🦆 duck say ⮞ map over yo scripts and gen dem shell scriptz wrapperz!!
    paths = mapAttrsToList (name: script:
      let # 🦆 duck say ⮞ compile help sentences at build time      
        # 🦆 duck say ⮞ compile help sentences at build time
        voiceSentencesHelp = if script.voice != null && script.voice.sentences != [] then
          let
            patterns = countGeneratedPatterns script;
            phrases = countUnderstoodPhrases script;
            # 🦆 duck say ⮞ copy the parameter replacement logic from voiceSentencesHelpFile
            replaceParamsWithValues = sentence: voiceData:
              let
                processToken = token:
                  if lib.hasPrefix "{" token && lib.hasSuffix "}" token then
                    let
                      paramName = lib.removePrefix "{" (lib.removeSuffix "}" token);
                      listData = voiceData.lists.${paramName} or null;
                    in
                      if listData != null then
                        if listData.wildcard or false then
                          "ANYTHING"
                        else
                          let
                            # 🦆 duck say ⮞ get all possible input values
                            values = map (v: v."in") listData.values;
                            # 🦆 duck say ⮞ expand any optional patterns like [foo|bar]
                            expandedValues = lib.concatMap expandListInputVariants values;
                            # 🦆 duck say ⮞ take first few examples for display
                            examples = lib.take 3 (lib.unique expandedValues);
                          in
                            if examples == [] then "ANYTHING"
                            else "(" + lib.concatStringsSep "|" examples + 
                                 (if lib.length examples < lib.length expandedValues then "|...)" else ")")
                      else
                        "ANYTHING" # 🦆 duck say ⮞ fallback if param not found
                  else
                    token;
                
                # 🦆 duck say ⮞ split sentence and process each token
                tokens = lib.splitString " " sentence;
                processedTokens = map processToken tokens;
              in
                lib.concatStringsSep " " processedTokens;
            
            # 🦆 duck say ⮞ replace params in each sentence for the help display
            processedSentences = map (sentence: 
              replaceParamsWithValues sentence script.voice
            ) script.voice.sentences;
            
            sentencesMarkdown = lib.concatMapStrings (sentence: 
              "- \"${escapeMD sentence}\"\n"
            ) processedSentences;
          in
            "## Voice Commands\n\nPatterns: ${toString patterns}  \nPhrases: ${toString phrases}  \n\n${sentencesMarkdown}"
        else "";
       
      
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
          set -o noglob  # 🦆 duck say ⮞ disable wildcard expansion for ? and ! flags
          ${yoEnvGenVar script} # 🦆 duck say ⮞ inject da env quack quack.... quack
          export LC_NUMERIC=C
          start=$(date +%s.%N)
#          trap 'end=$(date +%s.%N); elapsed=$(echo "$end - $start" | bc); printf "[🦆⏱] Total time: %.3f seconds\n" "$elapsed"' EXIT
          # 🦆 duck say ⮞ duckTrace log setup
          export DT_LOG_PATH="$HOME/.config/duckTrace/"
          mkdir -p "$DT_LOG_PATH"   
          export DT_LOG_FILE="${name}.log" # 🦆 duck say ⮞ duck tracin' be namin' da log file for da ran script
          touch "$DT_LOG_PATH/$DT_LOG_FILE"
          export DT_LOG_LEVEL="${script.logLevel}" # 🦆 duck say ⮞ da tracin' duck back to fetch da log level yo

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
          # 🦆 duck say ⮞ if ? flag used - sets scripts logLevel to DEBUG
          if [ "$VERBOSE" -ge 1 ]; then
            DT_LOG_LEVEL="DEBUG"
          fi
          
          # 🦆 duck say ⮞ parse all parameters
          while [[ $# -gt 0 ]]; do
            case "$1" in
              --help|-h) # 🦆 duck say ⮞ if  u needz help call `--help` or `-h`
                width=$(tput cols 2>/dev/null || echo 100) # 🦆 duck say ⮞ get terminal width for formatin' - fallin' back to 100
                help_footer=$(${script.helpFooter}) # 🦆 duck say ⮞ dynamically generatez da helpFooter if ya defined it yo   
                # 🦆 duck say ⮞ script haz paramz?
                usage_suffix=""
                if [[ -n "${toString (script.parameters != [])}" ]]; then
                  usage_suffix=" [OPTIONS]"
                fi
                
                cat <<EOF | ${pkgs.glow}/bin/glow --width "$width" - # 🦆 duck say ⮞ renderin' da cool & duckified CLI docz usin' Markdown & Glow yo 
# 🚀🦆 yo ${escapeMD script.name}
**Usage:** \`yo ${escapeMD script.name}''${usage_suffix}\`
${script.description}
${lib.optionalString (script.parameters != []) ''
## Parameters
${lib.concatStringsSep "\n\n" (map (param: ''
**\`--${param.name}\`**  
${param.description}  
${lib.optionalString param.optional "*(optional)*"} ${lib.optionalString (param.default != null) (let
  defaultText = 
    if param.type == "bool" then 
      (if param.default then "true" else "false")
    else 
      (toString param.default);
in "*(default: ${defaultText})*")}
'') script.parameters)}
''}
${voiceSentencesHelp}

$help_footer
EOF
                exit 0
                ;;
              --*) # 🦆 duck say ⮞ parse named paramz like: "--duck"
                param_name=''${1##--}
                # 🦆 duck say ⮞ let'z check if diz param existz in da scriptz defined parameterz
                if [[ " ${concatMapStringsSep " " (p: 
                      if p.type == "bool" then p.name else ""
                    ) script.parameters} " =~ " $param_name " ]]; then
                  # 🦆 duck say ⮞ boolean flag - presence means true, but also allow explicit true/false
                  if [[ $# -gt 1 && ( "$2" == "true" || "$2" == "false" ) ]]; then
                    PARAMS["$param_name"]="$2"
                    shift 2
                  else
                    PARAMS["$param_name"]="true"
                    shift 1
                  fi
                else
                  # 🦆 duck say ⮞ regular param expects value
                  if [[ " ${concatMapStringsSep " " (p: p.name) script.parameters} " =~ " $param_name " ]]; then
                    PARAMS["$param_name"]="$2" # 🦆 duck say ⮞ assignz da value
                    shift 2
                  else # 🦆 duck say ⮞ unknown param? duck say fuck
                    echo -e "\033[1;31m 🦆 duck say ⮞ fuck ❌ $1\033[0m Unknown parameter: $1"
                    exit 1
                  fi
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
                      echo -e "\033[1;31m 🦆 duck say ⮞ fuck ❌ ${name} --${param.name} must be integer\033[0m" >&2
                      exit 1
                    fi
                    ;;
                  path)
                    if ! [ -e "''${${param.name}}" ]; then
                      echo -e "\033[1;31m 🦆 duck say ⮞ fuck ❌ ${name} Path not found: ''${${param.name}}\033[0m" >&2
                      exit 1
                    fi
                    ;;
                  bool)
                    if ! [[ "''${${param.name}}" =~ ^(true|false)$ ]]; then
                      echo -e "\033[1;31m 🦆 duck say ⮞ fuck ❌ ${name} Parameter ${param.name} must be true or false\033[0m" >&2
                      exit 1
                    fi
                    ;;
                esac
              fi
            ''
          ) script.parameters)}

          # 🦆 duck say ⮞ boolean defaults - false if not provided
          ${concatStringsSep "\n" (map (param: 
            optionalString (param.type == "bool" && param.default != null) ''
              if [[ -z "''${${param.name}:-}" ]]; then
                ${param.name}=${if param.default then "true" else "false"}
              fi
            '') script.parameters)}


          ${concatStringsSep "\n" (map (param: 
            optionalString (param.default != null) ''
              if [[ -z "''${${param.name}:-}" ]]; then
                ${param.name}=${
                  if param.type == "string" then 
                    "'${lib.escapeShellArg (toString param.default)}'" 
                  else if param.type == "int" then
                    "${toString param.default}"
                  else if param.type == "bool" then
                    (if param.default then "true" else "false")
                  else if param.type == "path" then
                    "'${lib.escapeShellArg (toString param.default)}'"
                  else
                    "'${lib.escapeShellArg (toString param.default)}'"
                }
              fi
            '') script.parameters)}
            
          # 🦆 duck say ⮞ checkz required param yo - missing? errorz out 
          ${concatStringsSep "\n" (map (param: ''
            ${optionalString (!param.optional && param.default == null) ''
              if [[ -z "''${${param.name}:-}" ]]; then
                echo -e "\033[1;31m 🦆 duck say ⮞ fuck ❌ ${name} Missing required parameter: ${param.name}\033[0m" >&2
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

  # 🦆 duck say ⮞ constructs GitHub "blob" URL based on `config.this.user.me.repo` 
  githubBaseUrl = let # 🦆 duck say ⮞ pattern match to extract username and repo name
    matches = builtins.match ".*github.com[:/]([^/]+)/([^/\\.]+).*" config.this.user.me.repo;
  in if matches != null then # 🦆 duck say ⮞ if match - construct
    "https://github.com/${builtins.elemAt matches 0}/${builtins.elemAt matches 1}/blob/main"
  else ""; # 🦆 duck say ⮞ no match? empty string

  # 🦆 duck say ⮞ build scripts for da --help command
  terminalScriptsTableFile = pkgs.writeText "yo-helptext.md" terminalScriptsTable;
  # 🦆 duck say ⮞ markdown help text
  terminalScriptsTable = let # 🦆 duck say ⮞ categorize scripts
    groupedScripts = lib.groupBy (script: script.category) (lib.attrValues cfg.scripts);
    # 🦆 duck say ⮞ sort da scriptz by category
    visibleScripts2 = lib.filterAttrs (_: script: script.visibleInReadme) cfg.scripts;
    groupedScripts2 = lib.groupBy (script: script.category) (lib.attrValues visibleScripts2);
    sortedCategories2 = lib.sort (a: b: 
      # 🦆 duck say ⮞ system management goes first yo
      if a == "🖥️ System Management" then true
      else if b == "🖥️ System Management" then false
      else a < b # 🦆 duck say ⮞ after dat everything else quack quack
    ) (lib.attrNames groupedScripts2);
  
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
    ) sortedCategories2;
  in concatStringsSep "\n" rows;

  # 🦆 duck say ⮞ we build da scripts again but diz time for the READNE and diz time script names > links 
  helpTextFile = pkgs.writeText "yo-helptext.md" helpText;
  # 🦆 duck say ⮞ markdown help text
  helpText = let 
    # 🦆 duck say ⮞ URL escape helper for GitHub links
    escapeURL = str: builtins.replaceStrings [" "] ["%20"] str;
  
    # 🦆 duck say ⮞ categorize scripts
    visibleScripts = lib.filterAttrs (_: script: script.visibleInReadme) cfg.scripts;
    groupedScripts = lib.groupBy (script: script.category) (lib.attrValues visibleScripts);
    sortedCategories = lib.sort (a: b: 
      # 🦆 duck wants ⮞ system management to be listed first yo
      if a == "🖥️ System Management" then true
      else if b == "🖥️ System Management" then false
      else a < b # 🦆 duck say ⮞ after dat everything else quack quack
    ) (lib.attrNames groupedScripts);
  
    # 🦆 duck say ⮞ create table rows with category separatorz 
    rows = lib.concatMap (category:
      let # 🦆 duck say ⮞ sort from A to Ö  
        scripts = lib.sort (a: b: a.name < b.name) groupedScripts.${category};
      in
        [ # 🦆 duck say ⮞ add **BOLD** header table row for category
          "| **${escapeMD category}** | | | |"
        ] 
        # 🦆 duck say ⮞ each yo script goes into a table row
        ++ (map (script:
          let  # 🦆 duck say ⮞ format list of aliases
            aliasList = if script.aliases != [] then
              concatStringsSep ", " (map escapeMD script.aliases)
            else "";
            # 🦆 duck say ⮞ generate CLI parameter hints, with [] for optional/defaulted
            paramHint = concatStringsSep " " (map (param:
              if param.optional || param.default != null
              then "[--${param.name}]"
              else "--${param.name}"
            ) script.parameters);
            # 🦆 duck say ⮞ render yo script name as link + parameters as plain text
            syntax = 
              if githubBaseUrl != "" then
                "[yo ${escapeMD script.name}](${githubBaseUrl}/${escapeURL script.filePath}) ${paramHint}"
              else
                "yo ${escapeMD script.name} ${paramHint}";
              
            # 🦆 duck say ⮞ add voice ready indicator
            voiceIndicator = if script.voiceReady then "✅" else "📛";
          in 
            # 🦆 duck say ⮞ voice indicator to the row
            "| ${syntax} | ${aliasList} | ${escapeMD script.description} | ${voiceIndicator} |"
        ) scripts)
    ) sortedCategories;

  in concatStringsSep "\n" rows;

  # 🦆 duck say ⮞ count GENERATED regex patterns (the ~800 count)
  countGeneratedPatterns = script:
    if script.voice == null then
      0
    else
      let # 🦆 duck say ⮞ expand sentence variants with optional wordz
        expandedSentences = lib.concatMap expandOptionalWords script.voice.sentences;
      in
        lib.length expandedSentences;
  
  # 🦆 duck say ⮞ count phrase coverage  
  countUnderstoodPhrases = script:
    if script.voice == null then
      0
    else
      let # 🦆 duck say ⮞ expand sentence variants with optional wordz
        expandedSentences = lib.concatMap expandOptionalWords script.voice.sentences;   
        # 🦆 duck say ⮞ extract parameter names from sentences
        extractParamNames = sentence:
          let # 🦆 duck say ⮞ split by { to find parameters
            parts = lib.splitString "{" sentence;
            paramNames = lib.concatMap (part:
              let
                paramPart = lib.splitString "}" part;
              in
                if lib.length paramPart > 1 then
                  [ (lib.elemAt paramPart 0) ]
                else
                  []
            ) (lib.tail parts); # Skip the first part (before first {)
          in
            paramNames; 
        # 🦆 duck say ⮞ count parameter combinations for each expanded sentence
        countPhrasesForSentence = sentence:
          let
            paramNames = extractParamNames sentence;
          in
            if paramNames == [] then
              1
            else
              let # 🦆 duck say ⮞ count possible values for each parameter
                paramValueCounts = map (paramName:
                  let
                    list = script.voice.lists.${paramName} or null;
                  in
                    if list == null then 1
                    else lib.length list.values
                ) paramNames;           
                # 🦆 duck say ⮞ multiply counts for all parameters
                totalCombinations = lib.foldl (a: b: a * b) 1 paramValueCounts;
              in
                totalCombinations; 
        # 🦆 duck say ⮞ sum phrases across all expanded sentences
        totalPhrases = lib.foldl (total: sentence:
          total + countPhrasesForSentence sentence
        ) 0 expandedSentences;
      in
        totalPhrases;
  
  # 🦆 duck say ⮞ count generated patterns
  countTotalGeneratedPatterns = scripts:
    lib.foldl (total: script: 
      total + countGeneratedPatterns script
    ) 0 (lib.attrValues scripts);
  
  # 🦆 duck say ⮞ count phrases across all scriptz  
  countTotalUnderstoodPhrases = scripts:
    lib.foldl (total: script: 
      total + countUnderstoodPhrases script
    ) 0 (lib.attrValues scripts);
  
  # 🦆 duck say ⮞ quack! da duck take a list of listz and duck make all da possible combinationz
  cartesianProductOfLists = lists:
    # 🦆 duck say ⮞ if da listz iz empty .. 
    if lists == [] then
      [ [] ] # 🦆 duck say ⮞ .. i gib u empty listz of listz yo got it?
    else # 🦆 duck say ⮞ ELSE WAT?!
      let # 🦆 duck say ⮞ sorry.. i gib u first list here u go yo
        head = builtins.head lists;
        # 🦆 duck say ⮞ remaining listz for u here u go bro!
        tail = builtins.tail lists;
        # 🦆 duck say ⮞ calculate combinations for my tail - yo calc wher u at?!
        tailProduct = cartesianProductOfLists tail;
      in # 🦆 duck say ⮞ for everyy x in da listz ..
        lib.concatMap (x:
          # 🦆 duck say ⮞ .. letz combinez wit every tail combinationz ..  
          map (y: [x] ++ y) tailProduct
        ) head; # 🦆 duck say ⮞ dang! datz a DUCK COMBO alright!
  
  # 🦆 duck say ⮞ here i duckie help yo out! makin' yo life eazy sleazy' wen declarative sentence yo typin'    
  expandOptionalWords = sentence: # 🦆 duck say ⮞ qucik & simple sentences we quacky & hacky expandin'
    let # 🦆 duck say ⮞ CHOP CHOP! Rest in lil' Pieceez bigg sentence!!1     
      tokens = lib.splitString " " sentence;      
      # 🦆 duck say ⮞ definin' dem wordz in da (braces) taggin' dem' wordz az (ALTERNATIVES) lettin' u choose one of dem wen triggerin' 
      isRequiredGroup = t: lib.hasPrefix "(" t && lib.hasSuffix ")" t;
      # 🦆 duck say ⮞ puttin' sentence wordz in da [bracket] makin' em' [OPTIONAL] when bitchin' u don't have to be pickin' woooho 
      isOptionalGroup = t: lib.hasPrefix "[" t && lib.hasSuffix "]" t;   
      expandToken = token: # 🦆 duck say ⮞ dis gets all da real wordz out of one token (yo!)
        if isRequiredGroup token then
          let # 🦆 duck say ⮞ thnx 4 lettin' ducklin' be cleanin' - i'll be removin' dem "()" 
            clean = lib.removePrefix "(" (lib.removeSuffix ")" token);
            alternatives = lib.splitString "|" clean; # 🦆 duck say ⮞ use "|" to split (alternative|wordz) yo 
          in  # 🦆 duck say ⮞ dat's dat 4 dem alternativez
            alternatives
        else if isOptionalGroup token then
          let # 🦆 duck say ⮞ here we be goin' again - u dirty and i'll be cleanin' dem "[]"
            clean = lib.removePrefix "[" (lib.removeSuffix "]" token);
            alternatives = lib.splitString "|" clean; # 🦆 duck say ⮞ i'll be stealin' dat "|" from u 
          in # 🦆 duck say ⮞ u know wat? optional means we include blank too!
            alternatives ++ [ "" ]
        else # 🦆 duck say ⮞ else i be returnin' raw token for yo
          [ token ];      
      # 🦆 duck say ⮞ now i gib u generatin' all dem combinationz yo
      expanded = cartesianProductOfLists (map expandToken tokens);      
      # 🦆 duck say ⮞ clean up if too much space, smush back into stringz for ya
      trimmedVariants = map (tokenList:
        let # 🦆 duck say ⮞ join with spaces then trim them suckers
          raw = lib.concatStringsSep " " tokenList;
          # 🦆 duck say ⮞ remove ALL extra spaces
          cleaned = lib.replaceStrings ["  "] [" "] (lib.strings.trim raw);
        in # 🦆 duck say ⮞ wow now they be shinin'
          cleaned 
      ) expanded; # 🦆 duck say ⮞ and they be multiplyyin'!      
      # 🦆 duck say ⮞ throwin' out da empty and cursed ones yo
      nonEmpty = lib.filter (s: s != "") trimmedVariants;
      hasFixedText = v: builtins.match ".*[^\\{].*" v != null; # 🦆 duck say ⮞ no no no, no nullin'
      validVariants = lib.filter hasFixedText nonEmpty;
    in # 🦆 duck say ⮞ returnin' all unique variantz of da sentences – holy duck dat'z fresh 
      lib.unique validVariants;

  # 🦆 duck say ⮞ generatez safe systemd timer namez
  makeTimerName = scriptName: timeStr:
    let
      safeTime = replaceStrings [":"] ["-"] timeStr;
    in
      "yo-${scriptName}-at-${safeTime}";

  
in { # 🦆 duck say ⮞ options options duck duck
  options = { # 🦆 duck say ⮞ quack 
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
      }; # 🦆 duck say ⮞ generated regex patterns count
      generatedPatterns = mkOption {
        type = types.int;
        readOnly = true;
        description = "Number of regex patterns generated at build time";
      }; # 🦆 duck say ⮞ count nlp phrases understood  
      understandsPhrases = mkOption {
        type = types.int;
        readOnly = true;
        description = "Theoretical number of unique spoken phrases the system can understand";
      };
    };
  };  
  
  # 🦆 ⮞ CONFIG  🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆
  config = {  # 🦆 duck say ⮞ expose diz module and all yo.scripts as a package  
    yo.pkgs = yoScriptsPackage; # 🦆 duck say ⮞ reference as: ${config.pkgs.yo}/bin/yo-<name>
    # 🦆 duck say ⮞ set global counterz
    yo.generatedPatterns = countTotalGeneratedPatterns cfg.scripts;
    yo.understandsPhrases = countTotalUnderstoodPhrases cfg.scripts;

    # 🦆 ⮞  SAFETY ASSERTIONS  ⮜ 🦆
    assertions = let # 🦆 ⮞ safety first
      scripts = cfg.scripts;
      scriptNames = attrNames scripts;    
      
      # 🦆 duck say ⮞ runAt scripts need default values on required paramz
      runAtErrors = lib.mapAttrsToList (name: script:
        if script.runAt != null then
          let
            missingParams = lib.filter (p: !p.optional && p.default == null) script.parameters;
          in
            if missingParams != [] then
              "🦆 duck say ⮞ fuck ❌ Cannot schedule '${name}' at ${script.runAt} - missing defaults for: " +
              lib.concatMapStringsSep ", " (p: p.name) missingParams
            else null
        else null
      ) scripts;
      actualRunAtErrors = lib.filter (e: e != null) runAtErrors;
            
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
      
      nonInteractiveErrors = lib.mapAttrsToList (name: script:
        if script.autoStart || script.runEvery != null then
          let
            missingParams = lib.filter (p: !p.optional && p.default == null) script.parameters;
          in
            if missingParams != [] then
              "🦆 duck say ⮞ fuck ❌ Cannot schedule '${name}' - missing defaults for: " +
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
      { # 🦆 duck say ⮞ runAt script fully configured?
        assertion = actualRunAtErrors == [];
        message = "runAt scheduling errors:\n" + lib.concatStringsSep "\n" actualRunAtErrors;
      }      
      { # 🦆 duck say ⮞ runEvery OR runAt NOT BOTH
        assertion = lib.all (script: 
          !(script.runEvery != null && script.runAt != null)
        ) (lib.attrValues scripts);
        message = "🦆 duck say ⮞ fuck ❌ Script cannot have both runEvery and runAt set";
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
        #y!${pkgs.runtimeShell}
        set -o noglob # 🦆 duck say ⮞ help command data (
        script_dir="${yoScriptsPackage}/bin" 
        # 🦆 duck say ⮞ help command data (yo --help
        show_help() {
          #width=$(tput cols) # 🦆 duck say ⮞ Auto detect width
          width=130 # 🦆 duck say ⮞ fixed width
          cat <<EOF | ${pkgs.glow}/bin/glow --width $width -
        ## ──────⋆⋅☆☆☆⋅⋆────── ##
        ## 🦆🚀 **yo CLI** 🦆🦆 
        ## 🦆 duck say ⮞ quack! i help with scripts yo
        **Usage:** \`yo <command> [arguments]\`
        ## ──────⋆⋅☆☆☆⋅⋆────── ##
        ## 🦆✨ Available Commands
        Parameters inside brackets are [optional]
        | Command Syntax               | Aliases    | Description |
        |------------------------------|------------|-------------|
        ${terminalScriptsTable}
        ## ──────⋆⋅☆☆☆⋅⋆────── ##
        ## 🦆❓ Detailed Help
        For specific command help: \`yo <command> --help\`
        \`yo do --help\` will list all defined voice intents.
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

    # 🦆 duck say ⮞ buildz systemd services    
    systemd.services = lib.mkMerge [
      # 🦆 duck say ⮞ if `autoStart` is set
      (lib.mapAttrs' (name: script:
        lib.nameValuePair "yo-${name}" (mkIf script.autoStart {
          enable = true;
          wantedBy = ["multi-user.target"];
          after = ["sound.target" "network.target" "pulseaudio.socket" "sops-nix.service"];
    
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
            Environment = [
              "XDG_RUNTIME_DIR=${
                if config.this.host.hostname == "desktop" then "/run/user/1000"
                else if config.this.host.hostname == "homie" then "/run/user/1002"
                else if config.this.host.hostname == "nasty" then "/run/user/1000"
                else "/run/user/1000"
              }"
              "PULSE_SERVER=unix:%t/pulse/native"
              "HOME=/home/${config.this.user.me.name}"
              "PATH=/run/current-system/sw/bin:/bin:/usr/bin:${pkgs.binutils-unwrapped}/bin:${pkgs.coreutils}/bin"
            ];
          };
        })
      ) cfg.scripts)
    
      # 🦆 duck say ⮞ if `runEvery` is set 
      (lib.mapAttrs' (name: script:
        lib.nameValuePair "yo-${name}-periodic" (mkIf (script.runEvery != null) {
          enable = true;
          description = "Periodic execution of yo.${name}";
          serviceConfig = {
            Type = "oneshot";
            User = config.this.user.me.name;
            Group = config.this.user.me.name;
            Environment = [                        
              "HOME=/home/${config.this.user.me.name}"
              "PATH=/run/current-system/sw/bin:/bin:/usr/bin:${pkgs.binutils-unwrapped}/bin:${pkgs.coreutils}/bin"
            ];  
            ExecStart = let
              args = lib.concatMapStringsSep " " (param:
                "--${param.name} ${lib.escapeShellArg param.default}"
              ) (lib.filter (p: p.default != null) script.parameters);
            in "${yoScriptsPackage}/bin/yo-${name} ${args}";
          };
        })
      ) cfg.scripts)
      
      # 🦆 duck say ⮞ if `runAt` is set: one service that can be triggered by multiple timerz
      (lib.mapAttrs' (name: script:
        lib.nameValuePair "yo-${name}-scheduled" (mkIf (script.runAt != null) {
          enable = true;
          description = let
            # 🦆 duck say ⮞ create human-readable time list
            timesFormatted = if script.runAt != null then
              lib.concatStringsSep ", " script.runAt
            else "";
            # 🦆 duck say ⮞ include script description if available
            baseDesc = if script.description != "" then
              "${script.description} (scheduled at ${timesFormatted})"
            else
              "Scheduled execution of yo.${name} at ${timesFormatted}";
          in baseDesc;
          serviceConfig = {
            Type = "oneshot";
            User = config.this.user.me.name;
            Group = config.this.user.me.name;
            Environment = [                        
              "HOME=/home/${config.this.user.me.name}"
              "PATH=/run/current-system/sw/bin:/bin:/usr/bin:${pkgs.binutils-unwrapped}/bin:${pkgs.coreutils}/bin"
            ];  
            ExecStart = let
              args = lib.concatMapStringsSep " " (param:
                "--${param.name} ${lib.escapeShellArg param.default}"
              ) (lib.filter (p: p.default != null) script.parameters);
            in "${yoScriptsPackage}/bin/yo-${name} ${args}";
          };
        })
      ) cfg.scripts)
    ];

    # 🦆 duck say ⮞ systemd timer configuration
    systemd.timers = lib.mkMerge [  
      # 🦆 duck say ⮞ if `runEvery` is configured 
      (lib.mapAttrs' (name: script:
        lib.nameValuePair "yo-${name}-periodic" (mkIf (script.runEvery != null) {
          enable = true;
          wantedBy = ["timers.target"];
          timerConfig = {
            OnCalendar = "*-*-* *:0/${script.runEvery}";
            Unit = "yo-${name}-periodic.service";
            Persistent = true;
          };
        })
      ) cfg.scripts)
      
      # 🦆 duck say ⮞ if `runAt` is configured: one timer per scheduled time
      (lib.foldl' lib.recursiveUpdate {} (lib.mapAttrsToList (name: script:
        if script.runAt != null then
          lib.listToAttrs (lib.map (timeStr:
            lib.nameValuePair (makeTimerName name timeStr) {
              enable = true;
              wantedBy = ["timers.target"];
              timerConfig = {
                OnCalendar = "*-*-* ${timeStr}:00";
                Unit = "yo-${name}-scheduled.service";
                Persistent = true;
              };
            }
            ) script.runAt)
        else {}
      ) cfg.scripts))
    ];
  };} # 🦆 duck say ⮞ 2 long module 4 jokez.. bai bai yo
# 🦆 says ⮞ QuackHack-McBLindy out!
# ... 🛌🦆💤
