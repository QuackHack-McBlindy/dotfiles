#!/usr/bin/env bash
# hooks/check-secrets.sh

set -euo pipefail

[ -d secrets ] || { echo "No secrets/ directory — nothing to check."; exit 0; }

failed=0

check_file() {
  local f="$1"
  case "$f" in
    *.yaml|*.yml)
      grep -qE '^sops:' "$f" \
        || { echo "ERROR: $f is missing a top-level 'sops:' block"; failed=1; }
      ;;
    *.json)
      grep -qE '"sops"[[:space:]]*:' "$f" \
        || { echo "ERROR: $f is missing a '\"sops\":' key"; failed=1; }
      ;;
    *.env|*.env.*|.env)
      head -n 20 "$f" | grep -qE '^# *sops_' \
        || { echo "ERROR: $f is missing its '# sops_' metadata header"; failed=1; }
      ;;
    *.enc|*.sops|*.bin)
      [ "$(head -c 4 "$f")" = "sops" ] \
        || { echo "ERROR: $f does not start with SOPS magic bytes"; failed=1; }
      ;;
    *)
      echo "WARN: $f has an unknown extension; cannot verify SOPS encryption"
      ;;
  esac
}

while IFS= read -r -d '' f; do
  check_file "$f"
done < <(find secrets -mindepth 1 -type f -print0)

exit "$failed"
