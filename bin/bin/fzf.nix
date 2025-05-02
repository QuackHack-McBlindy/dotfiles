
{
  self,
  config,
  pkgs,
  cmdHelpers,
  ...
}: {
  yo.scripts.fzf = {
    description = "Interactive fzf search for file content with quick edit & jump to line";
    aliases = [ "f" ];
    code = ''
      RG_PREFIX="rg --line-number --hidden --color=never --smart-case --trim"
      INITIAL_QUERY=""

      main() {
        selected=$(
          $RG_PREFIX "$INITIAL_QUERY" |
          fzf --ansi \
              --disabled \
              --bind "change:reload:$RG_PREFIX {q} || true" \
              --delimiter : \
              --preview "bat --color=always --style=numbers,changes --highlight-line {2} {1}" \
              --preview-window 'right,66%,border-bottom' \
              --prompt 'search, yo 🔍  ' |
          cut -d: -f1,2  # Keep filename and line separated by colon
        )

        if [ -n "$selected" ]; then
          file="$(echo "$selected" | cut -d: -f1)"
          line="$(echo "$selected" | cut -d: -f2)"
          $EDITOR "+$line" "$file"
        fi
      }

      main "$@"
    '';
  };
}
