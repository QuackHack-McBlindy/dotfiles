# dotfiles/modules/yo.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 duck say ⮞ CLI framework - centralized script handling
  self, 
  config,
  lib,
  pkgs,   
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

    # 🦆 duck say ⮞ Construct badge URLs
    nixos_badge="https://img.shields.io/badge/NixOS-''${nixos_version}-blue?style=flat-square\\&logo=NixOS\\&logoColor=white"
    linux_badge="https://img.shields.io/badge/Linux-''${kernel_version}-red?style=flat-square\\&logo=linux\\&logoColor=white"
    nix_badge="https://img.shields.io/badge/Nix-''${nix_version}-blue?style=flat-square\\&logo=nixos\\&logoColor=white"
    bash_badge="https://img.shields.io/badge/bash-''${bash_version}-red?style=flat-square\\&logo=gnubash\\&logoColor=white"
    gnome_badge="https://img.shields.io/badge/GNOME-''${gnome_version}-purple?style=flat-square\\&logo=gnome\\&logoColor=white"
    python_badge="https://img.shields.io/badge/Python-''${python_version}-%23FFD43B?style=flat-square\\&logo=python\\&logoColor=white"
    rust_badge="https://img.shields.io/badge/Rust-''${rustc_version}-orange?style=flat-square\\&logo=rust\\&logoColor=white"
  
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
      -e "s|https://img.shields.io/badge/Rust-[^)]*|$rust_badge|g" \
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
in {

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
      updateReadme # 🦆 duck say ⮞ to update da readme of course ya non duck
    ];

  }
  

