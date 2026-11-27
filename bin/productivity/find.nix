# dotfiles/bin/productivity/find.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
# » ★ QuackHack-McBLindy.com ★ «
{
  self,
  config,
  pkgs,
  cmdHelpers,
  ...
}: {
  yo.scripts.find = {
    description = "Interactive fzf file search with preview & quick edit";
    category = "⚡ Productivity";
    aliases = [ "f" ];
    code = ''
      main() {
        selected=$(
          fd --type f --hidden \
             --exclude .git \
             --exclude .direnv \
             --exclude result \
          | fzf --ansi \
                --prompt 'files, yo 📁  ' \
                --preview 'bat --color=always --style=numbers -- {}' \
                --preview-window 'right,66%,border-bottom'
        )

        if [ -n "$selected" ]; then
          $EDITOR "$selected"
        fi
      }

      main "$@"
    '';
  };
}
