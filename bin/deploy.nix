# bin/deploy.nix
{ pkgs, cmdHelpers, ... }:
{
  yo.scripts = {
      deploy = {
          description = "Deploy NixOS system configurations to your remote servers";
          aliases = [ "d" ];
          parameters = [
              { name = "host"; description = "Host machine to build and activate"; optional = false; }
              { name = "flake"; description = "Path to the directory containing your flake.nix"; optional = false; default = config.this.user.me.dotfilesDir; }
              { name = "user"; description = "SSH username"; optional = true; default = config.this.user.me.name; }
              { name = "repo"; description = "Repository containing containing your NixOS configuration files"; optional = true; default = config.this.user.me.repo; }    
              { name = "!"; description = "Test mode (does not save new NixOS generation)"; optional = true; }
          ];
          code = ''   
              ${cmdHelpers}
              if [[ ! " ${toString sysHosts} " =~ " $host " ]]; then
                echo -e "\033[1;31m❌ $1\033[0m Unknown host: $host" >&2
                echo "Available hosts: ${toString sysHosts}" >&2
                exit 1
              fi
              if $DRY_RUN; then
                echo "❗ Test run: reboot will revert activation"
              fi

              AUTO_PULL=(run_cmd nix eval ''$flake#nixosConfigurations.''$host.config.this.host.autoPull) 
              # check if deplyed host should be autoPulled
              if [[ "$AUTO_PULL" == "true" ]]; then
                run_cmd echo "$host has autoPull activated!"
                # Check if deployed hosts dotfiles directory should be pulled or cloned
                result=( $(run_cmd ssh "$host" "[ -d \$flake/.git ] && echo true || echo false" 2>/dev/null | grep -Eo 'true|false') )
                if [ "$result" = "true" ]; then
                  # if dotfiles exist, update it
                  run_cmd yo pull
                else
                  # Otherwise clone it to $flake parameter
                  run_cmd echo "🚀 Bootstrap: Cloning dotfiles repo to ''$flake on ''$host"
                  run_cmd git clone ''$repo ''$flake || fail "❌  Clone failed"
                fi
              fi

              echo "👤 SSH User: ''$user"
              echo "🌐 SSH Host: ''$host"
              echo "❄️ Nix flake: ''$flake"
              echo "🚀 Deploying ''$flake#nixosConfigurations.''$host"
              echo "🔨 Building locally and activating remotely..."

              if $DRY_RUN; then
                rebuild_command="test"
              else
                rebuild_command="switch"
              fi
              cmd=(
                ${pkgs.nixos-rebuild}/bin/nixos-rebuild
                $rebuild_command
                --flake "$flake#$host"
                --target-host "$user@$host"
                --use-remote-sudo
                --show-trace
              )
          
              "''${cmd[@]}"
          
              if $DRY_RUN; then
                echo "🧪 Test deployment completed - No system generation saved!"
              else
                echo "✅ Deployment complete!"
              fi
          '';
      };
  };}  
