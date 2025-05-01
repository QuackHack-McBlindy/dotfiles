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
    code = let
      fuzzyCmd = "${pkgs.gnused}/bin/sed 's/./.*&/g'";
    in ''
      RG_PREFIX="${pkgs.ripgrep}/bin/rg --hidden --color=never --smart-case --trim --line-number"
      
      main() {
        selected=$(
          find /home/pungkula/dotfiles -type f -print0 | \
          xargs -0 $RG_PREFIX -- "" | \
          ${pkgs.fzf}/bin/fzf --ansi \
              --phony \
              --bind "change:reload:$RG_PREFIX '(?i)\$(echo {q} | ${fuzzyCmd})' || true" \
              --delimiter : \
              --preview "${pkgs.bat}/bin/bat --color=always --line-range {2}: --style=numbers,changes --highlight-line {2} {1}" \
              --preview-window 'right,60%,border-bottom' \
              --prompt 'search, yo 🔍  ' | \
          ${pkgs.coreutils}/bin/cut -d: -f1-2
        )

        if [ -n "$selected" ]; then
          file="$(${pkgs.coreutils}/bin/dirname "''${selected%%:*}" | \
                ${pkgs.coreutils}/bin/xargs -0 printf "%q")"
          line="''${selected##*:}"
          ${config.editor or "vim"} "+$line" "$file"
        fi
      }

      main "$@"
    '';
  };
}
