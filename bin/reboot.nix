# bin/reboot.nix
{ pkgs, cmdHelpers, ... }:
{
    yo.scripts = { 
      reboot = {
        description = "Force reboot and wait for host";
        aliases = [ "" ];
        parameters = [
          { name = "host"; description = "Target hostname for the reboot"; optional = true; default = config.this.host.hostname; }
        ];
        code = ''
          # Ensure sysHosts is defined elsewhere in your config
          if [[ ! " ${toString sysHosts} " =~ " $host " ]]; then
            echo -e "\033[1;31m❌ Invalid host: $host\033[0m" >&2
            echo "Available hosts: ${toString sysHosts}" >&2
            exit 1
          fi

          echo "Initiating reboot sequence for $host"
    
          # Immediate reboot without backgrounding
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
