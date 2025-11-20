# dotfiles/bin/productivity/update-readme.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ updates documentation
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ...
} : with lib;
let 
  cfg = config.yo;
  # 🦆 says ⮞ for README version badge yo
  nixosVersion = let
    raw = builtins.readFile /etc/os-release;
    versionMatch = builtins.match ".*VERSION_ID=([0-9\\.]+).*" raw;
  in builtins.replaceStrings [ "." ] [ "%2E" ] (builtins.elemAt versionMatch 0);

  sysHosts = builtins.attrNames self.nixosConfigurations;
  vmHosts = builtins.filter (host:
    self.nixosConfigurations.${host}.self.config.system.build ? vm
  ) sysHosts;  
  # 🦆 duck say ⮞ comma sep list of your hosts
  sysHostsComma = builtins.concatStringsSep "," sysHosts;

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


  # 🦆 says ⮞ find da mosquitto host
  mqttHost = let
    sysHosts = lib.attrNames self.nixosConfigurations;
    mqttHosts = lib.filter (host:
      let cfg = self.nixosConfigurations.${host}.config;
      in cfg.services.mosquitto.enable or false
    ) sysHosts;
  in
    if mqttHosts != [] then lib.head mqttHosts else null;

  # 🦆 says ⮞ get MQTT broker IP (fallback to localhost)
  mqttHostIp = if mqttHost != null
    then self.nixosConfigurations.${mqttHost}.config.this.host.ip or "127.0.0.1"
    else "127.0.0.1";

  zigduckDir = "/home/" + config.this.user.me.name + "/.config/zigduck";
  stateFile = "/var/lib/zigduck/state.json";

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

  # 🦆 duck say ⮞ constructs GitHub "blob" URL based on `config.this.user.me.repo` 
  githubBaseUrl = let # 🦆 duck say ⮞ pattern match to extract username and repo name
    matches = builtins.match ".*github.com[:/]([^/]+)/([^/\\.]+).*" config.this.user.me.repo;
  in if matches != null then # 🦆 duck say ⮞ if match - construct
    "https://github.com/${builtins.elemAt matches 0}/${builtins.elemAt matches 1}/blob/main"
  else ""; # 🦆 duck say ⮞ no match? empty string

in {

  yo = {
    scripts = {
      update-readme = {
        description = "Updates the documentation in README.md";
        category = "⚡ Productivity";
        logLevel = "INFO";
        parameters = [
          { name = "readmePath"; type = "path"; description = "What to search for"; optional = false; default = config.this.user.me.dotfilesDir + "/README2.md"; }
        ];        
        code = ''
          ${cmdHelpers}
      
          README_PATH="$readmePath"
          CONTACT_OUTPUT=""
          USER_TMP=$(mktemp)
          HOST_TMP=$(mktemp)
          # 🦆 says ⮞ yo zig devices?
          DEVICES_JSON=$(${pkgs.nix}/bin/nix eval --json ${config.this.user.me.dotfilesDir}#nixosConfigurations.${config.this.host.hostname}.config.house.zigbee.devices)
          
          echo "Fetching scene configurations..."
          SCENES_JSON=$(${pkgs.nix}/bin/nix eval --json ${config.this.user.me.dotfilesDir}#nixosConfigurations.${config.this.host.hostname}.config.house.zigbee.scenes)
          
          # 🦆 say ⮞ get battery states from Zigduck
          echo "🔋 Fetching battery levels from Zigduck..."
          BATTERY_STATE="{}"
          
          if ssh "root@${mqttHostIp}" "[ -f ${stateFile} ]" 2>/dev/null; then
            echo "Fetching state file from ${mqttHostIp}..."
            BATTERY_STATE=$(ssh "root@${mqttHostIp}" "cat ${stateFile}" 2>/dev/null || echo "{}")
            echo "Successfully fetched state file from remote"
          elif [ -f "${stateFile}" ]; then
            echo "Found local state file: ${stateFile}"
            BATTERY_STATE=$(cat "${stateFile}")
          elif [ -f "/var/lib/zigduck/state.json" ]; then
            echo "Found state file: /var/lib/zigduck/state.json"
            BATTERY_STATE=$(cat "/var/lib/zigduck/state.json")
          elif [ -f "$HOME/.config/zigduck/state.json" ]; then
            echo "Found user state file: $HOME/.config/zigduck/state.json"
            BATTERY_STATE=$(cat "$HOME/.config/zigduck/state.json")
          else
            echo "⚠️  Zigduck state file not found in any location"
          fi
          
          # 🦆 says ⮞ debuggin' 
          if [ "$BATTERY_STATE" != "{}" ]; then
            echo "State file contains data for $(echo "$BATTERY_STATE" | ${pkgs.jq}/bin/jq 'length') devices"
            BATTERY_DEVICES_IN_STATE=$(echo "$BATTERY_STATE" | ${pkgs.jq}/bin/jq -r 'to_entries[] | select(.value.battery?) | "\(.key): \(.value.battery)%"' | wc -l)
            echo "Found $BATTERY_DEVICES_IN_STATE devices with battery data in state file"
          fi
          
          # 🦆 duck say ⮞ Create temp files for processing
          TEMP_JSON=$(mktemp)
          TEMP_SCENES_JSON=$(mktemp)
          echo "$DEVICES_JSON" > "$TEMP_JSON"
          echo "$SCENES_JSON" > "$TEMP_SCENES_JSON"
          
          # 🦆 duck say ⮞ Get basic counts
          TOTAL_DEVICES=$(echo "$DEVICES_JSON" | ${pkgs.jq}/bin/jq 'length')
          BATTERY_DEVICES=$(echo "$DEVICES_JSON" | ${pkgs.jq}/bin/jq '[.[] | select(.batteryType != null)] | length')
          COLOR_DEVICES=$(echo "$DEVICES_JSON" | ${pkgs.jq}/bin/jq '[.[] | select(.supports_color == true)] | length')
          
          # 🦆 duck say ⮞ Get scene counts
          TOTAL_SCENES=$(echo "$SCENES_JSON" | ${pkgs.jq}/bin/jq 'length')
          SCENES_WITH_COLORS=$(echo "$SCENES_JSON" | ${pkgs.jq}/bin/jq '[.[] | select(.[] | .color?)] | length')
          
          # 🦆 duck say ⮞ Generate type counts
          TYPE_COUNTS=$(echo "$DEVICES_JSON" | ${pkgs.jq}/bin/jq -r '
            [.[] | .type] | 
            group_by(.) | 
            map({type: .[0], count: length}) | 
            sort_by(-.count)')
          
          # 🦆 duck say ⮞ Generate room distribution
          ROOM_COUNTS=$(echo "$DEVICES_JSON" | ${pkgs.jq}/bin/jq -r '
            [.[] | .room] | 
            group_by(.) | 
            map({room: .[0], count: length}) | 
            sort_by(-.count)')
          
          # 🦆 duck say ⮞ Map type to icons
          get_icon() {
            case "$1" in
              "light") echo "💡" ;;
              "remote") echo "🎮" ;;
              "sensor") echo "📊" ;;
              "motion") echo "📊" ;;
              "dimmer") echo "🎮" ;;
              "outlet") echo "🔌" ;;
              "blind") echo "🪟" ;;
              "pusher") echo "🔘" ;;
              *) echo "❓" ;;
            esac
          }
          
          # 🦆 duck say ⮞ battery level for a device
          get_battery_level() {
            local friendly_name="$1"
            local battery_level="N/A"
            
            local level=$(echo "$BATTERY_STATE" | ${pkgs.jq}/bin/jq -r --arg name "$friendly_name" '.[$name]?.battery // empty')
            
            if [ -n "$level" ] && [ "$level" != "null" ]; then
              battery_level="$level"
            fi
            
            if [ "$battery_level" = "N/A" ] || [ -z "$battery_level" ] || [ "$battery_level" = "null" ]; then
              echo "N/A"
            else
              echo "$battery_level%"
            fi
          }
          
          # 🦆 says ⮞ generate color box
          generate_color_box() {
            local hex="$1"
            local size="20px"
            echo "<div style=\"display: inline-block; width: $size; height: $size; background-color: $hex; border: 1px solid #ccc; border-radius: 3px; vertical-align: middle; margin-right: 5px;\"></div>\`$hex\`"
          }
          
          # 🦆 says⮞ analyze scene mood
          analyze_scene_mood() {
            local scene_name="$1"
            local scene_data="$2"
            # 🦆 says⮞ count ON devices
            local on_count=$(echo "$scene_data" | ${pkgs.jq}/bin/jq '[.[] | select(.state == "ON")] | length')
            local total_count=$(echo "$scene_data" | ${pkgs.jq}/bin/jq 'length') 
            # 🦆 says⮞ count color devices
            local color_count=$(echo "$scene_data" | ${pkgs.jq}/bin/jq '[.[] | select(.color?)] | length')
            
            # 🦆 says⮞ get unique colors
            local unique_colors=$(echo "$scene_data" | ${pkgs.jq}/bin/jq -r '[.[] | select(.color?) | .color.hex] | unique | join(",")')
            
            # 🦆 says⮞ estimate mood based on scene configuraitons
            if [ "$on_count" -eq 0 ]; then
              echo "🌙 All Off"
            elif [ "$color_count" -eq 0 ]; then
              echo "⚪ Monochrome"
            elif [ "$color_count" -le 2 ]; then
              echo "🎨 Subtle Colors"
            elif echo "$scene_name" | grep -qi "chill"; then
              echo "😌 Chill Vibes"
            elif echo "$scene_name" | grep -qi "green"; then
              echo "🌿 Nature Theme"
            elif echo "$scene_name" | grep -qi "max"; then
              echo "💫 Full Brightness"
            elif [ "$color_count" -gt 3 ]; then
              echo "🌈 Colorful Mix"
            else
              echo "✨ Custom Setup"
            fi
          }

      
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
            echo '```nix'
            cat "${config.this.user.me.dotfilesDir}/modules/myHouse.nix"
            echo '```'
          )
      
      
          # 🦆 duck say ⮞ Extract versions
          nixos_version=$(nixos-version | cut -d. -f1-2)
          kernel_version=$(uname -r | cut -d'-' -f1)
          nix_version=$(nix --version | awk '{print $3}')
          bash_version=$(bash --version | head -n1 | awk '{print $4}' | cut -d'(' -f1)
          gnome_version=$(gnome-shell --version | awk '{print $3}')
          python_version=$(python3 --version | awk '{print $2}')  
          rustc_version=$(rustc --version | awk '{print $2}')
          mosquitto_version=$(mosquitto -h | awk '/^mosquitto version/{print $3}')
          zigbee2mqtt_version=$(zigbee2mqtt --help 2>&1 | grep -oE 'zigbee2mqtt-[0-9]+\.[0-9]+\.[0-9]+' | head -n1 | cut -d'-' -f2)
      
          # 🦆 duck say ⮞ Construct badge URLs
          nixos_badge="https://img.shields.io/badge/NixOS-''${nixos_version}-blue?style=flat-square\\&logo=NixOS\\&logoColor=white"
          linux_badge="https://img.shields.io/badge/Linux-''${kernel_version}-red?style=flat-square\\&logo=linux\\&logoColor=white"
          nix_badge="https://img.shields.io/badge/Nix-''${nix_version}-blue?style=flat-square\\&logo=nixos\\&logoColor=white"
          bash_badge="https://img.shields.io/badge/bash-''${bash_version}-red?style=flat-square\\&logo=gnubash\\&logoColor=white"
          gnome_badge="https://img.shields.io/badge/GNOME-''${gnome_version}-purple?style=flat-square\\&logo=gnome\\&logoColor=white"
          python_badge="https://img.shields.io/badge/Python-''${python_version}-%23FFD43B?style=flat-square\\&logo=python\\&logoColor=white"
          rust_badge="https://img.shields.io/badge/Rust-''${rustc_version}-orange?style=flat-square\\&logo=rust\\&logoColor=white"
          mosquitto_badge="https://img.shields.io/badge/Mosquitto-''${mosquitto_version}-blue?style=flat-square&logo=eclipsemosquitto&logoColor=white"
          zigbee2mqtt_badge="https://img.shields.io/badge/Zigbee2MQTT-''${zigbee2mqtt_version}-yellow?style=flat-square&logo=zigbee2mqtt&logoColor=white"
      
        
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
            echo "- __Smart Home Nix Style - Managing $TOTAL_DEVICES devices and $TOTAL_SCENES scenes.__ <br>"               
          ) 


          # 🦆 says⮞ zigbee showoff
          DEVICES_SCENES_BLOCK=$(
            echo "### Device Counts by Type"
            echo "| Type | Count |"
            echo "|------|-------|"
            
            # 🦆 says⮞ device type counts
            echo "$TYPE_COUNTS" | ${pkgs.jq}/bin/jq -r '.[] | "| \(.type) | \(.count) |"' | while read -r line; do
              type=$(echo "$line" | sed 's/| \([^ ]*\) | \([0-9]*\) |/\1/')
              count=$(echo "$line" | sed 's/| \([^ ]*\) | \([0-9]*\) |/\2/')
              icon=$(get_icon "$type")
              echo "| $icon $type | $count |"
            done
            
            echo "| 🔋 Battery Devices | $BATTERY_DEVICES |"
            echo "| 🎨 Color Support | $COLOR_DEVICES |"
            echo ""
            echo "### Room Distribution"
            
            # 🦆 says⮞ room distributed devices
            echo "$ROOM_COUNTS" | ${pkgs.jq}/bin/jq -r '.[] | "- **\(.room):** \(.count) devices"'
            
            echo ""
            echo "## 💡 Device Details"
            echo ""
            echo "| Device Name | Type | Room | Battery | Battery Level | Color Support |"
            echo "|-------------|------|------|---------|---------------|---------------|"
            
            echo "$DEVICES_JSON" | ${pkgs.jq}/bin/jq -r 'to_entries | sort_by(.value.friendly_name)[] | 
              "\(.value.friendly_name)|\(.value.type)|\(.value.room)|\(if .value.batteryType != null then "✅" else "❌" end)|\(if .value.supports_color then "✅" else "❌" end)"' | \
            while IFS='|' read -r friendly_name type room battery color; do
              icon=$(get_icon "$type")
              if [ "$battery" = "✅" ]; then
                battery_level=$(get_battery_level "$friendly_name")
                # 🦆 says⮞ color code battery levels
                if [[ "$battery_level" =~ ^([0-9]+)%$ ]]; then
                  bat_num=''${BASH_REMATCH[1]}
                  if [ "$bat_num" -lt 20 ]; then
                    battery_level="🔴 $battery_level"
                  elif [ "$bat_num" -lt 50 ]; then
                    battery_level="🟡 $battery_level"
                  else
                    battery_level="🟢 $battery_level"
                  fi
                elif [ "$battery_level" = "N/A" ]; then
                  battery_level="❓ N/A"
                fi
              else
                battery_level="—"
              fi
              echo "| $friendly_name | $icon $type | $room | $battery | $battery_level | $color |"
            done
            
            echo ""
            echo "## 🎨 Scene Summary"
            echo "| Scene Name | Mood | Devices | ON | OFF | Colors |"
            echo "|------------|------|---------|----|-----|--------|"
            
            # 🦆 says⮞ process da scenes
            echo "$SCENES_JSON" | ${pkgs.jq}/bin/jq -r 'to_entries[] | "\(.key)|\(.value | length)|\([.value[] | select(.state == "ON")] | length)|\([.value[] | select(.state == "OFF")] | length)|\([.value[] | select(.color?)] | length)"' | \
            while IFS='|' read -r scene_name total_devices on_count off_count color_count; do
              mood=$(analyze_scene_mood "$scene_name" "$(echo "$SCENES_JSON" | ${pkgs.jq}/bin/jq -r --arg scene "$scene_name" '.[$scene]')")
              echo "| $scene_name | $mood | $total_devices | $on_count | $off_count | $color_count |"
            done                      
          )

         
          # 🦆 duck say ⮞ Update version badges
          sed -i -E \
            -e "s|https://img.shields.io/badge/NixOS-[^)]*|$nixos_badge|g" \
            -e "s|https://img.shields.io/badge/Linux-[^)]*|$linux_badge|g" \
            -e "s|https://img.shields.io/badge/Nix-[^)]*|$nix_badge|g" \
            -e "s|https://img.shields.io/badge/bash-[^)]*|$bash_badge|g" \
            -e "s|https://img.shields.io/badge/GNOME-[^)]*|$gnome_badge|g" \
            -e "s|https://img.shields.io/badge/Python-[^)]*|$python_badge|g" \
            -e "s|https://img.shields.io/badge/Rust-[^)]*|$rust_badge|g" \
            -e "s|https://img.shields.io/badge/Mosquitto-[^)]*|$mosquitto_badge|g" \
            -e "s|https://img.shields.io/badge/Zigbee2MQTT-[^)]*|$zigbee2mqtt_badge|g" \
            "$README_PATH"
           
          awk -v docs="$DOCS_CONTENT" \
              -v contact="$CONTACT_BLOCK" \
              -v tree="$FLAKE_BLOCK" \
              -v flake="$FLAKE_BLOCK_NIX" \
              -v host="$HOST_BLOCK" \
              -v user="$USER_BLOCK" \
              -v theme="$THEME_BLOCK" \
              -v stats="$STATS_BLOCK" \
              -v scenes="$DEVICES_SCENES_BLOCK" \              
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
            /<!-- DEVICES_SCENES_START -->/ { in_scenes=1; print; print scenes; next }
            /<!-- DEVICES_SCENES_END -->/ { in_scenes=0; print; next }     
            /<!-- FLAKE_START -->/ { in_flake=1; print; print flake; next }
            /<!-- FLAKE_END -->/ { in_flake=0; print; next }
            !in_docs && !in_tree && !in_scenes && !in_theme && !in_flake && !in_smart && !in_stats && !in_host && !in_user { print }
            ' "$README_PATH" > "$tmpfile"  
      
          # 🦆 says ⮞ diff check
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

          # 🦆 duck say ⮞ Clean up      
          rm "$tmpfile"
          rm "$USER_TMP" "$HOST_TMP"
          rm -f "$TEMP_JSON" "$TEMP_SCENES_JSON"
        '';
      };
    };
  
  };}
