#!/usr/bin/env bash
set -euo pipefail

HOSTNAME_ARG="${HOSTNAME:-}"
option1=""
OPTIONAL_ARG2=""

usage() {
  cat >&2 <<'EOF'
Usage: build-options-docs.sh --option1 PATH [--option2 PATH] [--hostname HOST]

  --option1 PATH           Attribute path dumped to options.json (required)
  --option2 PATH  Attribute path dumped to service.json (optional)
  --hostname HOST       NixOS hostname; defaults to $HOSTNAME
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --option1)            option1="$2"; shift 2 ;;
    --option1=*)          option1="${1#*=}"; shift ;;
    --option2)   OPTIONAL_ARG2="$2"; shift 2 ;;
    --option2=*) OPTIONAL_ARG2="${1#*=}"; shift ;;
    --hostname)        HOSTNAME_ARG="$2"; shift 2 ;;
    --hostname=*)      HOSTNAME_ARG="${1#*=}"; shift ;;
    -h|--help)         usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage; exit 1 ;;
  esac
done

: "${HOSTNAME_ARG:?--hostname (or \$HOSTNAME) is required}"
: "${option1:?--option1 is required}"

build_doc() {
  local opt_path="$1"
  local out="$2"
  nix build --impure --no-link --print-out-paths --expr "
    let
      flake = builtins.getFlake (toString ./.);
      pkgs  = flake.inputs.nixpkgs.legacyPackages.x86_64-linux;
      cfg   = flake.nixosConfigurations.\"${HOSTNAME_ARG}\";
      doc   = pkgs.nixosOptionsDoc {
        options = cfg.options.${opt_path};
        warningsAreErrors = false;
      };
    in doc.optionsJSON
  " | xargs -I{} jq . {}/share/doc/nixos/options.json > "$out"
}

build_doc "$option1" options.json
files=(options.json)

if [[ -n "$OPTIONAL_ARG2" ]]; then
  build_doc "$OPTIONAL_ARG2" service.json
  files+=(service.json)
fi

for f in "${files[@]}"; do
  jq -r --arg f "$f" '
    def undoc:
      (.value.description == null)
      or (.value.description == "")
      or (.value.description == "This option has no description.");
    def noExample: ((.value.example.text // "") == "");

    (to_entries | length)                                  as $total
    | ([to_entries[] | select(undoc)])                     as $missingDesc
    | ([to_entries[] | select(noExample)])                 as $missingEx

    | "### \($f)  —  \($total) options",
      "  descriptions: \($total - ($missingDesc|length))/\($total) (\(((($total - ($missingDesc|length)) / $total * 10000) | floor) / 100)%)",
      "  examples:     \($total - ($missingEx|length))/\($total) (\(((($total - ($missingEx|length)) / $total * 10000) | floor) / 100)%)",
      "",
      ( if ($missingDesc|length) == 0
        then "  Missing descriptions: (none)"
        else "  Missing descriptions:",
             ($missingDesc[] | "    - \(.key)")
        end ),
      "",
      ( if ($missingEx|length) == 0
        then "  Missing examples: (none)"
        else "  Missing examples:",
             ($missingEx[] | "    - \(.key)")
        end )
  ' "$f"
  echo
done
