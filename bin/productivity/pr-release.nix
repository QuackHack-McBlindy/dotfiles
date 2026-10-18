# dotfiles/bin/productivity/pr-release.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
# » ★ QuackHack-McBLindy.com ★ «
# confirm?  ──no──► EXIT!
#    │yes
#    ▼
# on dev? ──no──► EXIT
#    │yes
#    ▼
# version bumped?  ──no──► EXIT
#    │yes
#    ▼
# version == latest+1? ──no──► EXIT
#    │yes
#    ▼
# changelog empty? ──yes──► EXIT
#    │no
#    ▼
# push dev, create PR, merge into main (CI will release)
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
        { name = "confirm"; description = "Rquire confirmation"; optional = false; default = true; type = "bool"; }
      ];
      code = ''
        ${cmdHelpers}
        set -euo pipefail

        flake_lock="flake.lock"
        if [[ ! -f "$flake_lock" ]]; then
          echo "error: $flake_lock not found" >&2
          play_fail
          exit 1
        fi

        lock_mtime=$(git log -1 --format=%ct -- "$flake_lock" 2>/dev/null || true)
        if [[ -z "$lock_mtime" || "$lock_mtime" == "0" ]]; then
          echo "error: no commit history for $flake_lock" >&2
          play_fail
          exit 1
        fi

        now=$(date +%s)
        age_s=$(( now - lock_mtime ))
        max_age_s=$(( 14 * 24 * 60 * 60 ))

        if (( age_s > max_age_s )); then
          age_d=$(( age_s / 86400 ))
          echo "error: flake.lock is $age_d days old (limit: 14)" >&2
          echo "run 'nix flake update', commit the lock, then retry." >&2
          play_fail
          exit 1
        fi

        echo "flake.lock age: $(( age_s / 86400 )) days ✅"

        if [[ "''${confirm}" == "true" ]]; then
          echo "SENDING PR TO RELEASE ''${PWD##*/}"
          read -rp "continue? [y/N] " ans
          [[ "$ans" =~ ^[Yy]$ ]] || { echo "aborted." >&2; exit 1; }
        fi


        branch=$(git branch --show-current)
        if [[ "$branch" != "dev" ]]; then
          echo "error: must be on dev (currently on $branch)" >&2
          exit 1
        fi

        git fetch origin --tags

        latest_tag="$(
          git tag --list 'v[0-9]*.[0-9]*.[0-9]*' \
            | sed 's/^v//' \
            | sort -V \
            | tail -n1
        )"

        if [[ -z "$latest_tag" ]]; then
          echo "error: no released version tag found" >&2
          exit 1
        fi

        system="x86_64-linux"

        mapfile -t packages < <(
          nix eval \
            --json \
            --impure \
            --no-write-lock-file \
            --apply builtins.attrNames \
            ".#packages.''${system}" |
            jq -r '.[]'
        )

        if [[ "''${#packages[@]}" -eq 0 ]]; then
          echo "error: flake exposes no packages for ''${system}" >&2
          exit 1
        fi

        declare -A version_counts=()

        for package in "''${packages[@]}"; do
          v="$(nix eval --raw --no-write-lock-file \
                ".#packages.''${system}.''${package}.version")"

          if [[ ! "$v" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            echo "error: package '$package' has invalid version '$v'" >&2
            exit 1
          fi

          version_counts["$v"]=$(( ''${version_counts["$v"]:-0} + 1 ))
        done

        majority_version=""
        majority_count=0

        for v in "''${!version_counts[@]}"; do
          c="''${version_counts[$v]}"
          if (( c > majority_count )); then
            majority_version="$v"
            majority_count="$c"
          elif (( c == majority_count )); then
            echo "error: package versions are tied ($v vs $majority_version)" >&2
            play_fail
            exit 1
          fi
        done

        if (( majority_count * 2 <= ''${#packages[@]} )); then
          echo "error: no majority package version" >&2
          play_fail
          exit 1
        fi

        if [[ "$majority_version" == "$latest_tag" ]]; then
          echo "error: version not bumped — still v$majority_version" >&2
          echo "bump the package version(s) before opening the release PR." >&2
          play_fail
          exit 1
        fi

        IFS='.' read -r lM lm lp <<< "$latest_tag"
        expected="''${lM}.''${lm}.$((lp + 1))"

        if [[ "$majority_version" != "$expected" ]]; then
          echo "error: version will be rejected by CI" >&2
          echo "latest released: v$latest_tag" >&2
          echo "CI expects:      $expected" >&2
          echo "you have:        $majority_version" >&2
          echo "" >&2
          play_fail
          exit 1
        fi

        echo "version ✅"

        body=$(mktemp)
        trap 'rm -f "$body"' EXIT

        awk '/^## \[Unreleased\]/{f=1;next} f&&/^## \[/{exit} f' CHANGELOG.md > "$body"

        if ! grep -qE '^\s*[-*+]\s' "$body"; then
          echo "error: [Unreleased] section is empty" >&2
          play_fail
          exit 1
        fi

        git push origin dev

        pr_url=$(
          gh pr list \
            --head dev \
            --base main \
            --state open \
            --json url \
            --jq '.[0].url // empty'
        )

        if [[ -n "$pr_url" ]]; then
          echo "reusing existing PR: $pr_url"
          gh pr edit "$pr_url" --body-file "$body"
        else
          title="Release"
          pr_url=$(
            gh pr create \
              --base main \
              --head dev \
              --title "$title" \
              --body-file "$body"
          )
          echo "PR: $pr_url"
        fi
        echo ""
        echo "waiting for CI checks to pass..."
        if ! gh pr checks "$pr_url" --watch --fail-fast; then
          echo "error: ci FAILED! — PR left open" >&2
          exit 1
        fi

        gh pr merge "$pr_url" --merge
        echo "PR merged. Waiting for release workflow..."


        merge_sha=""
        run_id=""
        for _ in {1..12}; do
          [[ -n "$merge_sha" ]] || \
            merge_sha=$(gh pr view "$pr_url" --json mergeCommit --jq '.mergeCommit.oid // empty')
          [[ -z "$merge_sha" ]] && { sleep 5; continue; }
          run_id=$(
            gh run list --workflow=CI --commit="$merge_sha" --limit=1 \
              --json databaseId --jq '.[0].databaseId // empty' 2>/dev/null
          )
          [[ -n "$run_id" ]] && break
          sleep 5
        done

        if [[ -z "$run_id" ]]; then
          echo "warning: could not locate release workflow run" >&2
          echo "once it finishes, sync with:" >&2
          echo "git fetch origin --tags && git merge --ff-only origin/dev" >&2
          play_fail
          exit 0
        fi

        if ! gh run watch "$run_id" --interval=10; then
          echo "error: release workflow failed — inspect 'gh run view $run_id'" >&2
          play_fail
          exit 1
        fi

        git fetch origin --tags
        if git merge --ff-only origin/dev; then
          echo "local dev synced ✅"
        else
          echo "warning: release finished but local dev could not fast-forward" >&2
          echo "resolve manually: git fetch origin --tags && git merge origin/dev" >&2
        fi

        play_relax
        echo "released! ✅"
      '';
    };

  };}
