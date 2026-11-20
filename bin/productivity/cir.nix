# dotfiles/bin/productivity/cir.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
# » ★ QuackHack-McBLindy.com ★ «
{
  self,
  config,
  pkgs,
  cmdHelpers,
  ...
} : {
  yo.scripts = {
    ci-report = {
      description = "CI checks check-ups";
      category = "⚡ Productivity";
      aliases    = [ "cir" ];
      parameters = [
        { name = "running"; description = "true if in progress"; optional = false; default = true; type = "bool"; }
        { name = "percent"; description = "true if in progress"; optional = false; default = true; type = "bool"; }
        { name = "run_id"; description = "RUn ID"; optional = false; type = "string"; }
        { name = "repo"; description = "username/repo"; optional = false; type = "string"; }
      ];
      code = ''
        ${cmdHelpers}
        set -euo pipefail
        duck_fuck() {
          echo "❌🦆❌🦆❌🦆❌🦆❌🦆❌🦆❌🦆❌"
          echo "🦆❌🦆❌🦆❌🦆❌🦆❌🦆❌🦆❌🦆"
          say_duck " FUCK!  ❌🦆❌🦆❌🦆❌🦆"
          echo "❌🦆❌🦆❌🦆❌🦆❌🦆❌🦆❌🦆❌"
          echo "🦆❌🦆❌🦆❌🦆❌🦆❌🦆❌🦆❌🦆"
          play_fail
        }

        REPO="quackhack-mcblindy/zigduck"
        RUN_ID="44669305903"
        MODE=""

        DATA=$(gh run view "$RUN_ID" \
          --repo "$REPO" \
          --json status,jobs)

        case "$MODE" in
          running)
            jq -r '.status == "in_progress"' <<< "$DATA"
            ;;
          percent)
            jq -r '
              [.jobs[].steps[] |
                select(.name | startswith("Post ") | not)
              ] as $s |
              if ($s | length) == 0 then 0
              else
                ([$s[] | select(.status == "completed")] | length)
                * 100 / ($s | length) | floor
              end
            ' <<< "$DATA"
            ;;
          status)
            jq -r '.status' <<< "$DATA"
            ;;
        esac

      '';
    };

  };}
