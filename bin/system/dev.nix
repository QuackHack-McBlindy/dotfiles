# dotfiles/bin/system/dev.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{
  config,
  pkgs,
  cmdHelpers,
  ...
} : {
  yo.scripts.dev = {
    description = "Start development enviorment with local flake inputs";
    category = "🖥️ System Management";
#    aliases = [ "" ];
    parameters = [
      { name = "devShell"; description = "Development enviorment to open"; optional = false; default = "python312"; }
      { name = "list"; description = "List all dev shells"; optional = true; type = "bool"; }
    ];
    code = ''
      ${cmdHelpers}

      if [ "$list" = "true" ]; then
        ls "${config.this.user.me.dotfilesDir}"/devShells
        exit 0
      fi

      nix develop ${config.this.user.me.dotfilesDir}#"$devShell"
    '';

  };}
