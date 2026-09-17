# dotfiles/bin/productivity/release.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles

{
  self,
  config,
  pkgs,
  cmdHelpers,
  ...
} : {
  yo.scripts = {
    pr-release = {
      description = "Creates PR dev > main to release, changelog as description.";
      category = "⚡ Productivity";
      parameters = [
        { name = "confirm"; description = "Rquire confirmation"; optional = false; default = false; type = "bool"; }
      ];
      code = ''
        set -euo pipefail

        branch=$(git branch --show-current)
        if [[ "$branch" != "dev" ]]; then
          echo "error: must be on dev (currently on $branch)" >&2
          exit 1
        fi

        git fetch origin
        git push origin dev

        body=$(mktemp)
        trap 'rm -f "$body"' EXIT

        awk '/^## \[Unreleased\]/{f=1;next} f&&/^## \[/{exit} f' CHANGELOG.md > "$body"

        if ! grep -qE '^\s*[-*+]\s' "$body"; then
          echo "error: [Unreleased] section is empty" >&2
          exit 1
        fi

        title="''${1:-Release}"
        gh pr create --base main --head dev --title "$title" --body-file "$body"
      '';
    };

  };}
