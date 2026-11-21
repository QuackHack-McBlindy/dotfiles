
{
  self,
  config,
  pkgs,
  cmdHelpers,
  ...
}: {
  yo.scripts = {
    ci-report = {
      description = "CI checks check-ups";
      category = "⚡ Productivity";
      aliases = [ "cir" ];

      parameters = [
        {
          name = "running";
          description = "Show whether the latest run is in progress";
          optional = false;
          default = true;
          type = "bool";
        }
        {
          name = "percent";
          description = "Show latest run completion percentage";
          optional = false;
          default = true;
          type = "bool";
        }
        {
          name = "repo";
          description = "GitHub username/repo";
          optional = false;
          type = "string";
        }
      ];

      code = ''
        ${cmdHelpers}
        set -euo pipefail

        duck_fuck() {
          echo "❌🦆❌🦆❌🦆❌🦆❌🦆❌🦆❌🦆❌"
          echo "🦆❌🦆❌🦆❌🦆❌🦆❌🦆❌🦆❌🦆"
          say_duck " FUCK!  ❌🦆❌🦆❌🦆❌🦆"
          echo "❌🦆❌🦆❌🦆❌🦆❌🦆❌🦆❌"
          echo "🦆❌🦆❌🦆❌🦆❌🦆❌🦆❌🦆❌"
          play_fail
        }

        REPO="''${repo}"


        if ! RUN_ID=$(gh run list \
          --repo "$REPO" \
          --limit 1 \
          --json databaseId \
          --jq '.[0].databaseId'); then
          duck_fuck
          exit 1
        fi

        if [[ -z "$RUN_ID" || "$RUN_ID" == "null" ]]; then
          echo "❌ No workflow runs found for $REPO"
          duck_fuck
          exit 1
        fi


        if ! DATA=$(gh run view "$RUN_ID" \
          --repo "$REPO" \
          --json status,jobs); then
          duck_fuck
          exit 1
        fi
e
        if [[ "''${running}" == true ]]; then
          jq -r '.status == "in_progress"' <<< "$DATA"
        fi


        if [[ "''${percent}" == true ]]; then
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
        fi
      '';
    };
  };
}
