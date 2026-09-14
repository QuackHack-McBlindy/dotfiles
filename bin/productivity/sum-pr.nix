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

          branch=$(git branch --show-current)

          if [ -z "$branch" ]; then
              echo "Not on a branch." >&2
              exit 1
          fi

          diff=$(git diff "origin/main...origin/$branch" --color=never)

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
