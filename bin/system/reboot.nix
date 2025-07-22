# dotfiles/bin/system/reboot.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ self, config, pkgs, sysHosts, cmdHelpers, ... }:
{
    yo.scripts = { 
      reboot = {
        description = "Force reboot and wait for host";
        category = "🖥️ System Management";
        aliases = [ "restart" ];
        parameters = [
          { name = "host"; description = "Target hostname for the reboot"; optional = true; default = config.this.host.hostname; }
        ];
        code = ''
          ${cmdHelpers}
          if [[ ! " ${toString sysHosts} " =~ " $host " ]]; then
            say_duck "fuck ❌ Invalid host: $host"
            echo "Available hosts: ${toString sysHosts}" >&2
            exit 1
          fi
          wait_for_host() {
            local host="$1"
            echo "Waiting for $host to reboot..."
            while ! ping -c 1 -W 1 "$host" &> /dev/null; do
              sleep 1
            done
            echo "$host has now rebooted!"
          }
          ssh "$host" 'sudo reboot -f'
          sleep 1
          wait_for_host $host
        '';
      };
    };}  
