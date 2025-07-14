# dotfiles/bin/system/listener.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ self, config, pkgs, sysHosts, cmdHelpers, ... }:
{
    yo.scripts = { 
      listener = {
        description = "Monitor dbus notifications";
        category = "🖥️ System Management";
#        aliases = [ "restart" ];
#        parameters = [
#          { name = "host"; description = "Target hostname for the reboot"; optional = true; default = config.this.host.hostname; }
#        ];
        code = ''
          ${cmdHelpers}
          dus-monitor "interface='org.freedesktop.Notifications',member='Notify'" | \
          while read -r line; do
              if [[ "$line" =~ string\ \"([^\"]+)\" ]]; then
                  message="${BASH_REMATCH[1]}"

                  case "$message" in
                      ":1."* | "notify-send" | "urgency" | "sender-pid" | "x-shell-sender" | "x-shell-sender-pid")
                          continue
                          ;;
                  esac

                  if [[ -n "$message" ]]; then
                      yo say "$message"
                  fi
              fi
          done
        '';
      };}  
