#!/usr/bin/env bash
# scripts/update-readme.sh

set -euo pipefail

CONFIG_FILE="/etc/readme-config.json"
DOTFILES_DIR="."

if [ -z "${UPDATE_README_IN_NIX_DEVELOP:-}" ]; then
  export UPDATE_README_IN_NIX_DEVELOP=1
  _self="$(readlink -f "$0")"
  exec nix develop --command bash "$_self" "$@"
fi


get_version() {
  {
    case "$1" in
      adb)      timeout 5 adb --version 2>/dev/null | head -n1 | awk '{print $5}' ;;
      nixos)    timeout 5 nixos-version 2>/dev/null | cut -d. -f1-2 ;;
      kernel)   timeout 5 uname -r 2>/dev/null | cut -d'-' -f1 ;;
      nix)      timeout 5 nix --version 2>/dev/null | awk '{print $3}' ;;
      bash)     timeout 5 bash --version 2>/dev/null | head -n1 | awk '{print $4}' | cut -d'(' -f1 ;;
      gnome)    timeout 5 gnome-shell --version 2>/dev/null | awk '{print $3}' ;;
      python)   timeout 5 python3 --version 2>/dev/null | awk '{print $2}' ;;
      rust)     timeout 5 rustc --version 2>/dev/null | awk '{print $2}' ;;
      mqtt)     timeout 5 mosquitto -h 2>/dev/null | awk '/^mosquitto version/{print $3}' ;;
      yo)       timeout 5 yo --version 2>/dev/null | awk '/^yo version /{print $3; exit}' ;;
      zigduck)  timeout 5 zigduck-cli --version 2>/dev/null | awk '/^zigduck version /{print $3; exit}' ;;
      ducks)    timeout 5 grep -ro '🦆' --exclude-dir=dump --exclude-dir=.git --include='*.nix' --include='*.sh' --include='*.html' "$DOTFILES_DIR" 2>/dev/null | wc -l ;;

      total_scripts)   timeout 5 jq -r '.scriptCount' "$CONFIG_FILE" ;;
      voice_scripts)   timeout 5 jq -r '[.scripts[] | select(.voiceReady == true)] | length' "$CONFIG_FILE" ;;
      total_patterns)  timeout 5 jq -r '.voiceStats.generatedPatterns' "$CONFIG_FILE" ;;
      total_phrases)   timeout 5 jq -r '.voiceStats.understandsPhrases' "$CONFIG_FILE" ;;
      total_devices)   timeout 5 jq -r '.smartHome.devices | length' "$CONFIG_FILE" ;;
      total_scenes)    timeout 5 jq -r '.smartHome.scenes | length' "$CONFIG_FILE" ;;
      total_tvs)       timeout 5 jq -r '.smartHome.tvs | length' "$CONFIG_FILE" ;;
      total_devshells) timeout 5 nix flake show "$DOTFILES_DIR" --json --all-systems 2>/dev/null | jq '[.devShells[] | keys[]] | unique | length' ;;
      total_channels) timeout 5 jq -r '.smartHome.totalChannels' "$CONFIG_FILE" ;;
      total_hosts) timeout 5 jq '.hosts' "$CONFIG_FILE" ;;
      total_secrets) timeout 5 jq '.secrets' "$CONFIG_FILE" ;;
      total_packages) timeout 5 jq '.packages' "$CONFIG_FILE" ;;

      z2m)
        local bin
        bin="$(readlink -f "$(command -v zigbee2mqtt 2>/dev/null)" 2>/dev/null)" || true
        printf '%s\n' "$bin" \
          | grep -oE 'zigbee2mqtt-[0-9]+\.[0-9]+\.[0-9]+' \
          | head -n1 | cut -d- -f2
        ;;




      *)      echo "unknown" ;;
    esac
  } || true
}

declare -A BADGE_SOURCE=(
  [ADB]="adb"
  [NixOS]="nixos"
  [License]="static"
  [Nix]="nix"
  ["Linux Kernel"]="kernel"
  [GNOME]="gnome"
  [Bash]="bash"
  [Python]="python"
  [Rust]="rust"
  [Mosquitto]="mqtt"
  [Zigbee2MQTT]="z2m"
  [yo]="yo"
  [zigduck]="zigduck"

  [Hosts]="total_hosts"
  [Packages]="total_packages"
  [DevShells]="total_devshells"
  [Secrets]="total_secrets"

  [Scripts]="total_scripts"
  ["Voice Scripts"]="voice_scripts"
  ["Voice Patterns"]="total_patterns"
  ["Voice Phrases"]="total_phrases"

  [TVs]="total_tvs"
  [Channels]="total_channels"
  [Devices]="total_devices"
  [Scenes]="total_scenes"

  [Ducks]="ducks"
)

declare -A BADGE_URL=(
  [ADB]='https://img.shields.io/badge/ADB-{version}-green?style=plastic-square&logo=android&logoColor=white'
  [NixOS]='https://img.shields.io/badge/NixOS-{version}-blue?style=plastic-square&logo=NixOS&logoColor=white'
  [License]='https://img.shields.io/badge/license-MIT-black?style=plastic-square&logo=opensourceinitiative&logoColor=white'
  [Nix]='https://img.shields.io/badge/Nix-{version}-blue?style=plastic-square&logo=nixos&logoColor=white'
  ["Linux Kernel"]='https://img.shields.io/badge/Linux-{version}-red?style=plastic-square&logo=linux&logoColor=white'
  [GNOME]='https://img.shields.io/badge/GNOME-{version}-purple?style=plastic-square&logo=gnome&logoColor=white'
  [Bash]='https://img.shields.io/badge/bash-{version}-red?style=plastic-square&logo=gnubash&logoColor=white'
  [Python]='https://img.shields.io/badge/Python-{version}-%23FFD43B?style=plastic-square&logo=python&logoColor=white'
  [Rust]='https://img.shields.io/badge/Rust-{version}-orange?style=plastic-square&logo=rust&logoColor=white'
  [Mosquitto]='https://img.shields.io/badge/Mosquitto-{version}-yellow?style=plastic-square&logo=eclipsemosquitto&logoColor=white'
  [Zigbee2MQTT]='https://img.shields.io/badge/Zigbee2MQTT-{version}-yellow?style=plastic-square&logo=zigbee2mqtt&logoColor=white'
  [yo]='https://img.shields.io/badge/💬%20yo-{version}-black?style=plastic'
  [zigduck]='https://img.shields.io/badge/🦆%20zigduck-{version}-black?style=plastic'

  [Hosts]='https://img.shields.io/badge/🖥️_Hosts-{version}-2563eb?style=plastic'
  [Packages]='https://img.shields.io/badge/📦_Packages-{version}-f97316?style=plastic'
  [DevShells]='https://img.shields.io/badge/🚧_DevShells-{version}-f97316?style=plastic'
  [Secrets]='https://img.shields.io/badge/🔒_Secrets-{version}-dc2626?style=plastic'

  [Scripts]='https://img.shields.io/badge/📜_Scripts-{version}-7c3aed?style=plastic'
  ["Voice Scripts"]='https://img.shields.io/badge/🎙️_Voice_Scripts-{version}-7c3aed?style=plastic'
  ["Voice Patterns"]='https://img.shields.io/badge/🎯_Voice_Patterns-{version}-7c3aed?style=plastic'
  ["Voice Phrases"]='https://img.shields.io/badge/💬_Understandable_Phrases-{version}-7c3aed?style=plastic'

  [TVs]='https://img.shields.io/badge/📺_TVs-{version}-0891b2?style=plastic'
  [Channels]='https://img.shields.io/badge/📺_Channels-{version}-0891b2?style=plastic'
  [Devices]='https://img.shields.io/badge/🐝_Devices-{version}-0891b2?style=plastic'
  [Scenes]='https://img.shields.io/badge/🎨_Scenes-{version}-0891b2?style=plastic'

  [Ducks]='https://img.shields.io/badge/🦆_Ducks-{version}-eab308?style=plastic'
)

update_version_badges() {
  local readme="${1:-README.md}"
  local start_marker="${2:-<!-- VERSIONS_START -->}"
  local end_marker="${3:-<!-- VERSIONS_END -->}"

  [ -f "$readme" ] || return 0
  grep -qF "$start_marker" "$readme" || return 0
  grep -qF "$end_marker"   "$readme" || return 0

  local section_file temp_file
  section_file="$(mktemp)"
  temp_file="$(mktemp)"
  trap 'rm -f "${section_file:-}" "${temp_file:-}"' EXIT

  awk -v s="$start_marker" -v e="$end_marker" '
    $0 ~ s { inside=1; next }
    $0 ~ e { inside=0 }
    inside
  ' "$readme" > "$section_file"

  local name source version url
  for name in "${!BADGE_SOURCE[@]}"; do
    grep -qF "![$name](" "$section_file" || continue

    source="${BADGE_SOURCE[$name]}"
    if [ "$source" = "static" ]; then
      url="${BADGE_URL[$name]}"
    else
      version="$(get_version "$source")"
      if [ -z "$version" ] || [ "$version" = "unknown" ]; then
        echo "[update-readme] skipping '$name': could not detect version" >&2
        continue
      fi
      url="${BADGE_URL[$name]//\{version\}/$version}"
    fi

    NAME="$name" URL="$url" perl -i -0pe '
      my $n = $ENV{NAME};
      my $u = $ENV{URL};
      s{!\[\Q$n\E\]\([^)]*\)}{![$n]($u)}g;
    ' "$section_file"

    if [ "$source" = "static" ]; then
      echo "[update-readme] updated '$name' (static)" >&2
    else
      echo "[update-readme] updated '$name' -> $version" >&2
    fi
  done

  awk -v sf="$section_file" -v s="$start_marker" -v e="$end_marker" '
    $0 ~ s {
      print
      while ((getline line < sf) > 0) print line
      close(sf)
      skip=1
      next
    }
    $0 ~ e { skip=0 }
    !skip
  ' "$readme" > "$temp_file"

  mv "$temp_file" "$readme"

  rm -f "$section_file"
  trap - EXIT
}


readme="${1:-README.md}"

update_version_badges "$readme" '<!-- VERSIONS_START -->' '<!-- VERSIONS_END -->'
update_version_badges "$readme" '<!-- BADGES_START -->'   '<!-- BADGES_END -->'
