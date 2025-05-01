#!/bin/bash

# Search files and content using fzf with preview
# Requires: ripgrep (rg), bat, fzf

RG_PREFIX="rg --line-number --hidden --color=never --smart-case --trim"
INITIAL_QUERY=""

main() {
  selected=$(
    $RG_PREFIX '' "$(find . -type f 2>/dev/null)" |
    fzf --ansi \
        --disabled \
        --bind "change:reload:$RG_PREFIX {q} || true" \
        --delimiter : \
        --preview "bat --color=always --style=numbers,changes --highlight-line {2} {1} | grep --color=always -C 10 {q}" \
        --preview-window 'right,60%,border-bottom' \
        --prompt 'search, yo 🔍' |
    awk -F: '{print $1 " " $2}'
  )

  if [ -n "$selected" ]; then
    file=${selected%% *}
    line=${selected##* }
    ${EDITOR:-vim} "+$line" "$file"
  fi
}

main "$@"
