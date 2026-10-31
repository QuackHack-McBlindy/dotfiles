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

      override_flags=()
      [[ -d /home/pungkula/new/pokenix        ]] && override_flags+=(--override-input pokenix  "path:/home/pungkula/new/pokenix")
      [[ -d /home/pungkula/new/yo             ]] && override_flags+=(--override-input yo       "path:/home/pungkula/new/yo")
      [[ -d /home/pungkula/zigduck2mqttnix    ]] && override_flags+=(--override-input zigduck  "path:/home/pungkula/zigduck2mqttnix")


      if [ "$devShell" = "esp32-rs" ]; then
        nix develop "''${override_flags[@]}"
      else
        nix develop ${config.this.user.me.dotfilesDir}#"$devShell" "''${override_flags[@]}"
      fi
    '';

  };}
