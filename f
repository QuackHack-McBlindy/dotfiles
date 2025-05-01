#!/bin/bash

# Fuzzy content search with tolerant matching
# Requires: rg (ripgrep), bat, fzf

RG_PREFIX="rg --line-number --hidden --color=never --smart-case --trim"
INITIAL_QUERY=""

main() {
  selected=$(
    # Search with fuzzy regex pattern
    $RG_PREFIX '' $(find . -type f 2>/dev/null) |
    fzf --ansi \
        --phony \
        --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
        --bind "ctrl-f:unbind(change,ctrl-f)+change-prompt(File> )+reload($RG_PREFIX {q} || true)" \
        --delimiter : \
        --preview "bat --color=always --style=numbers,changes --highlight-line {2} {1} | grep --color=always -C 10 -i {q}" \
        --preview-window 'right,60%,border-bottom' \
        --prompt 'Fuzzy Content> ' |
        --bind "change:reload:$RG_PREFIX {q// /.*} || true"
    awk -F: '{print $1 " " $2}'
  )

  if [ -n "$selected" ]; then
    file=${selected%% *}
    line=${selected##* }
    ${EDITOR:-vim} "+$line" "$file"
  fi
}

main "$@"
