# dotfiles/bin/productivity/update-readme.nix
{ # 🦆 says ⮞ updates da docs! - using build-time generated data
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ...
} : with lib; let

  cfg = config.yo;

  allScripts   = lib.attrValues cfg.scripts;
  voiceScripts = lib.filter (s: s.voiceReady) allScripts;

  totalScripts      = builtins.length allScripts;
  totalVoiceScripts = builtins.length voiceScripts;
  totalPatterns     = lib.foldl' (a: s: a + s.voicePatterns) 0 allScripts;
  totalPhrases      = lib.foldl' (a: s: a + s.voicePhrases)  0 allScripts;

  # 🦆 duck say ⮞ total pokemon (events + specials + shiny + breedables)
  pokenixTotal = let
    p     = config.pokenix or null;
    stats = p.stats or null;
  in
    if stats == null then 0
    else stats.ballCaptures + stats.eventCount + stats.specialsCount + stats.shinyOwned;


  # 🦆 says ⮞ generator
  readmeConfig   = pkgs.writeText "readme-config.json" (builtins.toJSON {
    scriptCount  = builtins.length (builtins.attrNames cfg.scripts);
    scripts      = builtins.mapAttrs (name: script: {
      voiceReady = script.voiceReady or false;
      voice      = script.voice or null;
    }) cfg.scripts;

    voiceStats = {
      scriptCount        = totalVoiceScripts;
      generatedPatterns  = cfg.generatedPatterns;
      understandsPhrases = cfg.understandsPhrases;
    };

    # 🦆 says ⮞ smart home configuration
    smartHome = {
      devices = config.house.zigbee.devices;
      scenes  = config.house.zigbee.scenes;
      tvs     = config.house.tv;
      totalChannels =
        builtins.foldl'
          (acc: tv: acc + builtins.length (builtins.attrNames (tv.channels or {})))
          0
          (builtins.attrValues config.house.tv);
    };

    hosts        = builtins.length (builtins.attrNames self.nixosConfigurations);
    secrets      = builtins.length (builtins.attrNames (config.sops.secrets   or {}));
    packages     = builtins.length config.environment.systemPackages;
    totalPosts   = builtins.length (builtins.attrNames config.blog.posts);
    pokemonTotal = pokenixTotal;

    # 🦆 says ⮞ user, host, and theme configs
    userConfig  = config.this.user.me;
    hostConfig  = config.this.host;
    themeConfig = config.this.theme;


    # 🦆 says ⮞ flake information
    flakePath = "${config.this.user.me.dotfilesDir}/flake.nix";
  });

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

  environment.etc = {
    "readme-config.json".source = readmeConfig;
  };

  yo.scripts.update-readme = {
    description = "Updates documentation in README.md with current system state (uses build-time config)";
    category = "⚡ Productivity";
    logLevel = "INFO";
    parameters = [
      { name = "readmePath"; description = "Path to README.md file"; type = "path"; optional = false; default = config.this.user.me.dotfilesDir + "/README.md"; }
    ];
    code = ''
      ${cmdHelpers}

      dt_info "Starting README update..."

      README_PATH="$readmePath"
      dt_debug "README.md Path: $README_PATH"
      CONFIG_FILE="${readmeConfig}"
      dt_debug "CONFIG_FILE: $CONFIG_FILE"
      if [ ! -f "$README_PATH" ]; then
        dt_error "README file not found: $README_PATH"
        exit 1
      fi

      if [ ! -f "$CONFIG_FILE" ]; then
        dt_error "Config file not found: $CONFIG_FILE"
        exit 1
      fi

      # 🦆 says ⮞ parse da build-time JSON config
      dt_debug "Loading build-time configuration..."
      CONFIG_DATA=$(cat "$CONFIG_FILE")

      get_config_value() {
        echo "$CONFIG_DATA" | ${pkgs.jq}/bin/jq -r "$1"
      }

      # 🦆 says ⮞ debug logging: scripts counter, voice scripts, regex patterns, phrases
      dt_info "Scripts: $(get_config_value '.scriptCount')"
      dt_info "Voice script: $(get_config_value '[.scripts[] | select(.voiceReady)] | length')"
      dt_info "Generated regex patterns: $(get_config_value '.voiceStats.generatedPatterns')"
      dt_info "Understandable phrases: $(get_config_value '.voiceStats.understandsPhrases')"


      # 🦆 says ⮞ create temp files
      TEMP_README=$(mktemp)
      trap 'rm -f "$TEMP_README"' EXIT

      # 🦆 says ⮞ Get system versions safely
      get_version() {
        case "$1" in
          nixos)
            nixos-version 2>/dev/null | cut -d. -f1-2 || echo "unknown"
            ;;
          kernel)
            uname -r 2>/dev/null | cut -d'-' -f1 || echo "unknown"
            ;;
          nix)
            nix --version 2>/dev/null | awk '{print $3}' || echo "unknown"
            ;;
          bash)
            bash --version 2>/dev/null | head -n1 | awk '{print $4}' | cut -d'(' -f1 || echo "unknown"
            ;;
          gnome)
            gnome-shell --version 2>/dev/null | awk '{print $3}' || echo "unknown"
            ;;
          python)
            python3 --version 2>/dev/null | awk '{print $2}' || echo "unknown"
            ;;
          rust)
            rustc --version 2>/dev/null | awk '{print $2}' || echo "unknown"
            ;;
          mqtt)
            mosquitto -h 2>/dev/null | awk '/^mosquitto version/{print $3}' || echo "unknown"
            ;;
          z2m)
            zigbee2mqtt --help 2>&1 | grep -oE 'zigbee2mqtt-[0-9]+\.[0-9]+\.[0-9]+' | head -n1 | cut -d'-' -f2 || echo "unknown"
            ;;
          *)
            echo "unknown"
            ;;
        esac
      }

      update_pokemon_badge() {
        local file="$1"
        local total
        total=$(get_config_value '.pokemonTotal')
        dt_debug "Pokémon total: $total"
        if [ -z "$total" ] || [ "$total" = "null" ]; then
          dt_warning "pokemonTotal missing from config — skipping badge update"
          return 0
        fi
        local tmp
        tmp=$(mktemp)
        ${pkgs.gnused}/bin/sed \
          -e "s|Pokémon-[0-9]*-e63946|Pokémon-''${total}-e63946|g" \
          "$file" > "$tmp" && mv "$tmp" "$file"
      }

      update_badges() {
        local file="$1"
        dt_debug "File: $file"
        dt_debug "Permissions: $(ls -la "$file" 2>/dev/null || echo "File not found")"
        dt_debug "Current user: $(whoami)"

        local temp_file=$(mktemp)

        # 🦆 duck say ⮞ extract versions
        nixos_version=$(nixos-version | cut -d. -f1-2)
        kernel_version=$(uname -r | cut -d'-' -f1)
        nix_version=$(nix --version | awk '{print $3}')
        bash_version=$(bash --version | head -n1 | awk '{print $4}' | cut -d'(' -f1)
        gnome_version=$(gnome-shell --version | awk '{print $3}')
        #python_version=$(python3 --version 2>/dev/null | awk '{print $2}' || echo "unknown")
        python_version="3.12"
        #rustc_version=$(rustc --version 2>/dev/null | awk '{print $2}' || echo "unknown")
        rustc_version="1.97.1"
        mosquitto_version=$(mosquitto -h 2>&1 | awk '/^mosquitto version/{print $3}' || echo "unknown")
        yo_version=$(yo --version 2>/dev/null | awk 'NR==1{print $3}')                 || yo_version="unknown"
        zigduck_version=$(zigduck-cli --version 2>/dev/null | awk 'NR==1{print $3}')   || zigduck_version="unknown"

        total_posts=$(get_config_value '.totalPosts')

        # 🦆 duck say ⮞ construct badge URLs
        nixos_badge="https://img.shields.io/badge/NixOS-''${nixos_version}-blue?style=flat-square\\&logo=NixOS\\&logoColor=white"
        linux_badge="https://img.shields.io/badge/Linux-''${kernel_version}-red?style=flat-square\\&logo=linux\\&logoColor=white"
        nix_badge="https://img.shields.io/badge/Nix-''${nix_version}-blue?style=flat-square\\&logo=nixos\\&logoColor=white"
        bash_badge="https://img.shields.io/badge/bash-''${bash_version}-red?style=flat-square\\&logo=gnubash\\&logoColor=white"
        gnome_badge="https://img.shields.io/badge/GNOME-''${gnome_version}-purple?style=flat-square\\&logo=gnome\\&logoColor=white"
        python_badge="https://img.shields.io/badge/Python-''${python_version}-%23FFD43B?style=flat-square\\&logo=python\\&logoColor=white"
        rust_badge="https://img.shields.io/badge/Rust-''${rustc_version}-orange?style=flat-square\\&logo=rust\\&logoColor=white"
        mosquitto_badge="https://img.shields.io/badge/Mosquitto-''${mosquitto_version}-yellow?style=flat-square\\&logo=eclipsemosquitto\\&logoColor=white"

        local scripts voice_scripts voice_patterns phrases phrases_fmt
        scripts=$(get_config_value '.scriptCount')
        voice_scripts=$(get_config_value '.voiceStats.scriptCount')
        voice_patterns=$(get_config_value '.voiceStats.generatedPatterns')
        phrases=$(get_config_value '.voiceStats.understandsPhrases')


        # 🦆 duck say ⮞ compact big numbers so badges stay readable
        format_count() {
          local n="$1"
          if   [ "$n" -ge 1000000000 ]; then awk -v n="$n" 'BEGIN{printf "%.2fB", n/1e9}'
          elif [ "$n" -ge 1000000    ]; then awk -v n="$n" 'BEGIN{printf "%.2fM", n/1e6}'
          elif [ "$n" -ge 1000       ]; then awk -v n="$n" 'BEGIN{printf "%.1fK", n/1e3}'
          else echo "$n"; fi
        }
        phrases_fmt=$(format_count "$phrases")

        # 🦆 duck say ⮞ use sed yo
        ${pkgs.gnused}/bin/sed \
          -e "s|https://img.shields.io/badge/NixOS-[^)]*|$nixos_badge|g" \
          -e "s|https://img.shields.io/badge/Linux-[^)]*|$linux_badge|g" \
          -e "s|https://img.shields.io/badge/Nix-[^)]*|$nix_badge|g" \
          -e "s|https://img.shields.io/badge/bash-[^)]*|$bash_badge|g" \
          -e "s|https://img.shields.io/badge/GNOME-[^)]*|$gnome_badge|g" \
          -e "s|https://img.shields.io/badge/Python-[^)]*|$python_badge|g" \
          -e "s|https://img.shields.io/badge/Rust-[^)]*|$rust_badge|g" \
          -e "s|https://img.shields.io/badge/Mosquitto-[^)]*|$mosquitto_badge|g" \
          -e "s|💬%20yo-[0-9][0-9.]*-black|💬%20yo-$yo_version-black|g" \
          -e "s|🦆%20zigduck-[0-9][0-9.]*-black|🦆%20zigduck-$zigduck_version-black|g" \
          -e "s|📜_Scripts-[0-9]*-7c3aed|📜_Scripts-$scripts-7c3aed|g" \
          -e "s|🎙️_Voice_Scripts-[0-9]*-7c3aed|🎙️_Voice_Scripts-$voice_scripts-7c3aed|g" \
          -e "s|🎯_Voice_Patterns-[0-9]*-7c3aed|🎯_Voice_Patterns-$voice_patterns-7c3aed|g" \
          -e "s|💬_Understandable_Phrases-[0-9.]*[BKM]*-7c3aed|💬_Understandable_Phrases-$phrases_fmt-7c3aed|g" \
          -e "s|🖥️_Hosts-[0-9]*-2563eb|🖥️_Hosts-$(get_config_value '.hosts')-2563eb|g" \
          -e "s|📦_Packages-[0-9]*-f97316|📦_Packages-$(get_config_value '.packages')-f97316|g" \
          -e "s|🔒_Secrets-[0-9]*-dc2626|🔒_Secrets-$(get_config_value '.secrets')-dc2626|g" \
          -e "s|📺_Channels-[0-9]*-0891b2|📺_Channels-$(get_config_value '.smartHome.totalChannels')-0891b2|g" \
          -e "s|📝_Posts-[0-9]*-[a-fA-F0-9]*|📝_Posts-$total_posts-7c3aed|g" \
          "$file" > "$temp_file" && mv "$temp_file" "$file"
      }



      # 🦆say⮞replaces <!-- sections -->
      replace_section() {
        local marker="$1"
        local content_file="$2"
        local target_file="$3"

        ${pkgs.gawk}/bin/awk -v marker="$marker" -v content_file="$content_file" '
          BEGIN {
            while ((getline line < content_file) > 0) {
              content = content line "\n"
            }
            close(content_file)
            in_section = 0
          }

          $0 ~ "<!-- " marker "_START -->" {
            in_section = 1
            print
            print content
            next
          }

          $0 ~ "<!-- " marker "_END -->" {
            in_section = 0
            print
            next
          }

          !in_section {
            print
          }
        ' "$target_file" > "$TEMP_README" && mv "$TEMP_README" "$target_file"
      }

      generate_section() {
        local section="$1"
        local temp_file=$(mktemp)

        case "$section" in
          YO_DOCS)
            # 🦆 duck say ⮞  get generated help text
            HELP_CONTENT=$(<${helpTextFile})

            cat << 'EOF' > "$temp_file"
## 🚀 **yo CLI 🦆**
The yo CLI is a framework designed to execute scripts defined in the ./bin directory.
It provides a unified interface for script execution, centralizes all help commands, and automatically validates parametrs and updates the documentation.

**Usage:** \`yo <command> [arguments]\`

### **Usage Examples:**
The yo CLI supports flexible parameter parsing through two primary mechanisms:

```bash
# Named Parameters
$ yo deploy --host pinephone --flake /home/pungkula/dotfiles

# Positional Parameters
$ yo deploy pinephone /home/pungkula/dotfiles

# Scripts can also be executed with natural language text by typing:
$ yo do "is pinephone overheating"
# Natural language voice commands are also supported, say:
"yo bitch reboot the pinephone"

# If the server is not running, it can be manually started with:
$ yo-rs
```

### ✨ Available Commands
Set default values for your parameters to have them marked [optional]
Add \`?\` to any command to run it in DEBUG mode

<details><summary><strong>
View All Scripts
</strong></summary>

| Command Syntax               | Aliases    | Description | VoiceReady |
|------------------------------|------------|-------------|--|
${helpText}

</details>

### ❓ Detailed Help
For specific command help:
\`yo <command> --help\`
\`yo <command> -h\`
EOF
            ;;


          TREE)
            local flake_path="${config.this.user.me.dotfilesDir}"
            echo '```nix' > "$temp_file"
            nix flake show "$flake_path" 2>/dev/null | sed -e 's/\x1B\[[0-9;]*[A-Za-z]//g' >> "$temp_file" || {
              echo "Error: Unable to show flake for $flake_path" >> "$temp_file"
            }
            echo '```' >> "$temp_file"
            ;;

          SMARTHOME)
            # 🦆 says ⮞ output the full myHouse.nix file
            local smarthome_path="${config.this.user.me.dotfilesDir}/modules/myHouse.nix"
            if [ -f "$smarthome_path" ]; then
              echo '# dotfiles/modules/myHouse.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles' > "$temp_file"
              echo '```nix' >> "$temp_file"
              cat "$smarthome_path" >> "$temp_file"
              echo '```' >> "$temp_file"
            else
              echo "/* Smart home configuration not found */" > "$temp_file"
            fi
            ;;

          USER)
            get_config_value '.userConfig' | ${pkgs.jq}/bin/jq -r '
              def to_nix($indent):
                def ind: ("  " * $indent);
                if type == "object" then
                  "\(ind){\n" + (
                    to_entries | map(
                      "\(ind)  \(.key) = \(.value | to_nix($indent + 1))"
                    ) | join(";\n")
                  ) + "\n\(ind)}"
                elif type == "array" then
                  if map(type == "string") | all then
                    "[ " + (map("\"\(.)\"") | join(" ")) + " ]"
                  else
                    "[\n" + (
                      map(to_nix($indent + 1)) | join("\n")
                    ) + "\n\(ind)]"
                  end
                elif type == "string" then
                  "\"\(.)\""
                else
                  tostring
                end;
              "```nix\n" + to_nix(0) + "\n```"
            ' > "$temp_file" 2>/dev/null || echo "```nix\n/* Error loading user config */\n```" > "$temp_file"
            ;;

          HOST)
            get_config_value '.hostConfig' | ${pkgs.jq}/bin/jq -r '
              def to_nix($indent):
                def ind: ("  " * $indent);
                if type == "object" then
                  "\(ind){\n" + (
                    to_entries | map(
                      "\(ind)  \(.key) = \(.value | to_nix($indent + 1))"
                    ) | join(";\n")
                  ) + "\n\(ind)}"
                elif type == "array" then
                  if map(type == "string") | all then
                    "[ " + (map("\"\(.)\"") | join(" ")) + " ]"
                  else
                    "[\n" + (
                      map(to_nix($indent + 1)) | join("\n")
                    ) + "\n\(ind)]"
                  end
                elif type == "string" then
                  "\"\(.)\""
                else
                  tostring
                end;
              "```nix\n" + to_nix(0) + "\n```"
            ' > "$temp_file" 2>/dev/null || echo "```nix\n/* Error loading host config */\n```" > "$temp_file"
            ;;

          FLAKE)
            local flake_path="${config.this.user.me.dotfilesDir}/flake.nix"
            if [ -f "$flake_path" ]; then
              echo '```nix' > "$temp_file"
              cat "$flake_path" >> "$temp_file"
              echo '```' >> "$temp_file"
            else
              echo "```nix\n/* flake.nix not found */\n```" > "$temp_file"
            fi
            ;;


          THEME)
            get_config_value '.themeConfig' | ${pkgs.jq}/bin/jq -r '
              def to_nix($indent):
                def ind: ("  " * $indent);
                if type == "object" then
                  "\(ind){\n" + (
                    to_entries | map(
                      "\(ind)  \(.key) = \(.value | to_nix($indent + 1))"
                    ) | join(";\n")
                  ) + "\n\(ind)}"
                elif type == "array" then
                  if map(type == "string") | all then
                    "[ " + (map("\"\(.)\"") | join(" ")) + " ]"
                  else
                    "[\n" + (
                      map(to_nix($indent + 1)) | join("\n")
                    ) + "\n\(ind)]"
                  end
                elif type == "string" then
                  "\"\(.)\""
                else
                  tostring
                end;
              "```nix\n" + to_nix(0) + "\n```"
            ' > "$temp_file" 2>/dev/null || echo "```nix\n/* Error loading theme config */\n```" > "$temp_file"
            ;;

          FLAKE_NIX)
            local flake_path=$(get_config_value '.flakePath')
            if [ -f "$flake_path" ]; then
              echo '```nix' > "$temp_file"
              head -100 "$flake_path" >> "$temp_file"
              echo '```' >> "$temp_file"
            else
              echo "```nix\n/* flake.nix not found */\n```" > "$temp_file"
            fi
            ;;

          CONTACT)
            cat << EOF > "$temp_file"
$(
local matrix=$(get_config_value '.userConfig.matrix // ""')
local discord=$(get_config_value '.userConfig.discord // ""')
local email=$(get_config_value '.userConfig.email // ""')

[ -n "$matrix" ] && echo "[![Matrix](https://img.shields.io/badge/Matrix-Chat-000000?style=flat-square&logo=matrix&logoColor=white)]($matrix)"
[ -n "$discord" ] && echo "[![Discord](https://img.shields.io/badge/Discord-Chat-5865F2?style=flat-square&logo=discord&logoColor=white)]($discord)"
[ -n "$email" ] && echo "[![Email](https://img.shields.io/badge/Email-Contact-6D4AFF?style=flat-square&logo=protonmail&logoColor=white)](mailto:$email)"
)
EOF
            ;;
          *)
            echo "<!-- No content for section: $section -->" > "$temp_file"
            ;;
        esac

        echo "$temp_file"
      }

      dt_info "Updating sections..."

      for section in YO_DOCS USER HOST THEME DEVICES_SCENES SMARTHOME TREE FLAKE CONTACT; do
        dt_debug "Updating section: $section..."
        content_file=$(generate_section "$section")
        if [ -f "$content_file" ]; then
          replace_section "$section" "$content_file" "$README_PATH"
          rm "$content_file"
        fi
      done

      dt_info "Updating badges..."
      update_pokemon_badge "$README_PATH"
      update_badges "$README_PATH"
      size=$(wc -c < "$README_PATH")

      if (( size > 20 * 1024 )); then
        say_duck "🎉✨ README UPDATED!"
      elif (( size == 0 )); then
        dt_error   "⚠️🚫 README UPDATE FAILED! ⚠️🚫"
        dt_warning "⚠️ README.md EXPECTEED BROKEN! Verify file content!"
      fi

      # 🦆 says ⮞ show diff
      if git diff --quiet "$README_PATH" 2>/dev/null; then
        dt_debug "No changes to commit"
      else
        dt_debug "Changes detected:"
        git diff --stat "$README_PATH" 2>/dev/null || true
      fi

    '';

  };}
