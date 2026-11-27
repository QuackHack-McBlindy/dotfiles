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
    description = "Interactive fzf file search with quick jump";
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
                --no-preview \
                --with-nth 1.. \
                --print-query
        )

        if [ -n "$selected" ]; then
          thunar "$selected"
        fi
      }

      main "$@"
    '';

  };
}
