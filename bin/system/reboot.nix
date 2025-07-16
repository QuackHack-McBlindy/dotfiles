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

          echo "Initiating reboot sequence for $host"
    
          ssh "$host" 'sudo reboot -f'
    
          echo "Waiting for $host to go offline..."
          while ping -c 1 -W 1 "$host" &> /dev/null; do
            sleep 1
          done
    
          echo "Host offline. Waiting for reboot..."
          until ping -c 1 -W 1 "$host" &> /dev/null; do
            sleep 1
          done
    
          echo "Host back online. Waiting for SSH..."
          until ssh -q "$host" 'exit'; do
            sleep 1
          done
    
          echo "Reboot completed successfully"
        '';
      };
    };}  
