```bash
#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <find> <replace>"
    exit 1
fi

find_str="$1"
replace_str="$2"

find . -type f -name '*.nix' -exec sed -i "s|${find_str//|/\\|}|${replace_str//|/\\|}|g" {} +
```
