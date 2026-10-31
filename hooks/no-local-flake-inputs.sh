#!/usr/bin/env bash
# hooks/no-local-flake-inputs.sh
set -euo pipefail

if grep -nE 'url *= *"(path:|/|[a-zA-Z]:\\)' flake.nix; then
  echo "ERROR: Local path found in flake.nix input(s)." >&2
  exit 1
fi

if grep -n '"type": "path"' flake.lock 2>/dev/null; then
  echo "ERROR: Local path input found in flake.lock." >&2
  exit 1
fi

exit 0
