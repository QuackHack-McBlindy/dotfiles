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
      pull-request = {
        description = "Copies git diff to clipboard for summarizing";
        category = "⚡ Productivity";
        aliases = [ "pr" ];
        code = ''
          custom_text="Can you summarize the below git diff?

          I want it summarized in the following format:

          ```
          COMMIT MESSAGE:
          Really brief commit message.

          TITLE:
          A concise PR title, preferably under 80 characters.

          BODY:
          Use exactly this structure:

          ## Summary
          2-4 bullets describing what actually changed.

          ## Why
          Explain the purpose/inferred motivation, but do not invent requirements.

          ## Notes
          Only include important implementation details or risks. Omit this section if
          there is nothing worth mentioning.

          Do not claim anything that isn't supported by the diff.

          ```

          "

          if git diff --quiet; then
              diff=$(git diff --cached --color=never)
          else
              diff=$(git diff --color=never)
          fi

          { printf '%s\n' "$custom_text"; printf '%s\n' "$diff"; } | xclip -selection clipboard
        '';
      };
    };

  };}
