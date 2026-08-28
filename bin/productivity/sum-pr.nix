# dotfiles/bin/productivity/pr.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ 
  self,
  config,
  pkgs,
  cmdHelpers,
  ...
} : {
  yo = {
    scripts = {
      sum-pr = {
        description = "Copies git diff to clipboard for summarizing";
        category = "⚡ Productivity";
        #aliases = [ "pr" ];
        code = ''
          prompt_file="/home/pungkula/sum_pr.txt"
          change_log="./CHANGELOG.md"

          if git diff --quiet; then
              diff=$(git diff --cached --color=never)
          else
              diff=$(git diff --color=never)
          fi

          {
            cat "$prompt_file"
            printf '\n'
            printf '%s\n' "$diff"
            printf '\n'
            cat "$change_log"
          } | xclip -selection clipboard
        '';
      };
    };
    
  };}
