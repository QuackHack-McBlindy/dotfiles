#!/usr/bin/env bash
set -Eeuo pipefail

OWNER="${GITHUB_OWNER:-QuackHack-McBlindy}"
OUTPUT="${OUTPUT_FILE:-home/total-stars.svg}"
API="https://api.github.com"
API_VERSION="2026-03-10"

if ! command -v gh >/dev/null 2>&1; then
    echo "Error: GitHub CLI (gh) is required." >&2
    exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
    echo "Error: jq is required." >&2
    exit 1
fi

TOKEN="${STAR_HISTORY_TOKEN:-${GITHUB_TOKEN:-$(gh auth token 2>/dev/null || true)}}"

if [[ -z "$TOKEN" ]]; then
    echo "Error: No GitHub token found. Run: gh auth login" >&2
    exit 1
fi

mkdir -p "$(dirname "$OUTPUT")"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

api_get() {
    local url="$1"
    shift

    curl --fail --silent --show-error \
        --retry 3 \
        --retry-delay 2 \
        -H "Authorization: Bearer $TOKEN" \
        -H "Accept: application/vnd.github+json" \
        -H "X-GitHub-Api-Version: $API_VERSION" \
        "$@" \
        "$url"
}

echo "Fetching repositories owned by $OWNER..."

api_get "$API/user/repos?per_page=100&sort=updated&affiliation=owner&page=1" \
    > "$tmp/repos.json"

page=2
while :; do
    api_get "$API/user/repos?per_page=100&sort=updated&affiliation=owner&page=$page" \
        > "$tmp/repos-page.json"

    count="$(jq 'length' "$tmp/repos-page.json")"
    [[ "$count" -gt 0 ]] || break

    jq -s '.[0] + .[1]' "$tmp/repos.json" "$tmp/repos-page.json" \
        > "$tmp/repos-combined.json"

    mv "$tmp/repos-combined.json" "$tmp/repos.json"
    ((page += 1))
done

jq --arg owner "$OWNER" \
    '[.[] | select(.owner.login | ascii_downcase == ($owner | ascii_downcase))]' \
    "$tmp/repos.json" > "$tmp/owned-repos.json"

repo_count="$(jq 'length' "$tmp/owned-repos.json")"

echo "Found $repo_count repositories."

if [[ "$repo_count" -eq 0 ]]; then
    echo "No repositories found for $OWNER." >&2
    exit 1
fi


: > "$tmp/stars.jsonl"

while IFS= read -r repo; do
    full_name="$(jq -r '.full_name' <<< "$repo")"
    echo "Fetching stars: $full_name"

    page=1

    while :; do
        url="$API/repos/$full_name/stargazers?per_page=100&page=$page"

        if ! response="$(
            api_get "$url" \
                -H "Accept: application/vnd.github.star+json"
        )"; then
            echo "Failed to fetch stargazers for $full_name." >&2
            echo "Check token permissions and repository access." >&2
            exit 1
        fi

        count="$(jq 'length' <<< "$response")"
        [[ "$count" -gt 0 ]] || break

        jq -r '.[].starred_at // empty' <<< "$response" \
            >> "$tmp/stars.jsonl"

        ((page += 1))
    done
done < <(jq -c '.[]' "$tmp/owned-repos.json")

total_stars="$(wc -l < "$tmp/stars.jsonl" | tr -d ' ')"

echo "Collected $total_stars star events."

jq -Rn '
    [inputs
     | fromdateiso8601
     | . - (. % 604800)]
    | sort
    | group_by(.)
    | map({
        timestamp: .[0],
        increment: length
      })
    | reduce .[] as $week (
        {total: 0, points: []};
        .total += $week.increment
        | .points += [{
            timestamp: $week.timestamp,
            total: .total
          }]
      )
    | .points
' "$tmp/stars.jsonl" > "$tmp/points.json"

point_count="$(jq 'length' "$tmp/points.json")"

if [[ "$point_count" -eq 0 ]]; then
    echo "No star timestamps found. No chart generated." >&2
    exit 1
fi

WIDTH=1000
HEIGHT=420
LEFT=75
RIGHT=35
TOP=45
BOTTOM=65

PLOT_WIDTH=$((WIDTH - LEFT - RIGHT))
PLOT_HEIGHT=$((HEIGHT - TOP - BOTTOM))

first_time="$(jq '.[0].timestamp' "$tmp/points.json")"
last_time="$(jq '.[-1].timestamp' "$tmp/points.json")"
max_stars="$(jq '.[-1].total' "$tmp/points.json")"

time_range=$((last_time - first_time))
((time_range > 0)) || time_range=1

((max_stars > 0)) || max_stars=1

jq -r \
    --argjson left "$LEFT" \
    --argjson top "$TOP" \
    --argjson pw "$PLOT_WIDTH" \
    --argjson ph "$PLOT_HEIGHT" \
    --argjson first "$first_time" \
    --argjson range "$time_range" \
    --argjson max "$max_stars" '
    [
        .[] |
        [
            ($left + ((.timestamp - $first) / $range * $pw)),
            ($top + ($ph - (.total / $max * $ph)))
        ]
    ]
    | to_entries
    | map(
        (if .key == 0 then "M " else "L " end)
        + (.value[0] | tostring)
        + " "
        + (.value[1] | tostring)
    )
    | join(" ")
' "$tmp/points.json" > "$tmp/path.txt"

path="$(cat "$tmp/path.txt")"

latest="$(jq '.[-1].total' "$tmp/points.json")"

cat > "$OUTPUT" <<SVG
<svg xmlns="http://www.w3.org/2000/svg"
     width="$WIDTH"
     height="$HEIGHT"
     viewBox="0 0 $WIDTH $HEIGHT"
     role="img"
     aria-label="Total GitHub stars over time">

  <defs>
    <linearGradient id="area" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#58a6ff" stop-opacity="0.35"/>
      <stop offset="100%" stop-color="#58a6ff" stop-opacity="0"/>
    </linearGradient>
  </defs>

  <rect width="100%" height="100%" rx="14" fill="#0d1117"/>

  <text x="$LEFT" y="30"
        fill="#e6edf3"
        font-family="sans-serif"
        font-size="18"
        font-weight="600">
    Total GitHub Stars
  </text>

  <text x="$((WIDTH - RIGHT))" y="30"
        fill="#58a6ff"
        font-family="sans-serif"
        font-size="18"
        text-anchor="end"
        font-weight="600">
    $latest stars
  </text>

  <path d="$path"
        fill="none"
        stroke="#58a6ff"
        stroke-width="3"
        stroke-linecap="round"
        stroke-linejoin="round"/>

  <path d="$path L $((WIDTH - RIGHT)) $((HEIGHT - BOTTOM)) L $LEFT $((HEIGHT - BOTTOM)) Z"
        fill="url(#area)"
        stroke="none"/>

  <line x1="$LEFT" y1="$((HEIGHT - BOTTOM))"
        x2="$((WIDTH - RIGHT))" y2="$((HEIGHT - BOTTOM))"
        stroke="#30363d"/>

  <text x="$LEFT" y="$((HEIGHT - 25))"
        fill="#8b949e"
        font-family="sans-serif"
        font-size="12">
    $(date -u -d "@$first_time" '+%Y-%m-%d' 2>/dev/null || date -u -r "$first_time" '+%Y-%m-%d')
  </text>

  <text x="$((WIDTH - RIGHT))" y="$((HEIGHT - 25))"
        fill="#8b949e"
        font-family="sans-serif"
        font-size="12"
        text-anchor="end">
    $(date -u -d "@$last_time" '+%Y-%m-%d' 2>/dev/null || date -u -r "$last_time" '+%Y-%m-%d')
  </text>

  <text x="$LEFT" y="$((HEIGHT - 45))"
        fill="#8b949e"
        font-family="sans-serif"
        font-size="11">
    $repo_count repositories
  </text>
</svg>
SVG

echo "Chart written to $OUTPUT"
echo "Total stars: $latest"
