# dotfiles/bin/system/deploy.nix
{ self, config, pkgs, cmdHelpers, ... }:
let
  sysHosts = builtins.attrNames self.nixosConfigurations;
  vmHosts = builtins.filter (host:
    self.nixosConfigurations.${host}.self.config.system.build ? vm
  ) sysHosts;
in {
  yo.scripts = { 
   deploy = {
     description = "Deploy NixOS system configurations to your remote servers";
     aliases = [ "d" ];
     category = "🛠 System Management";
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

       result=$(ssh "$user@$host" "[ -d '$flake/.git' ] && echo true || echo false")
       if [ "$result" = "true" ]; then
         run_cmd echo "✅ Dotfiles repo exists on $host"
       else
         # Otherwise clone it to $flake parameter
         run_cmd echo "🚀 Bootstrap: Cloning dotfiles repo to ''$flake on ''$host"
    
         run_cmd ssh "$user"@"$host" "git clone '$repo' '$flake'" || fail "❌ Clone failed"
         run_cmd echo "Please decrypt $host AGE key, Enter PIN and touch your Yubikey"
         run_cmd echo ""
         run_cmd yo yubi decrypt "$flake/secrets/hosts/$host/age.key" | ssh "$user@$host" "mkdir -p $(dirname "$(nix eval --raw "$flake#nixosConfigurations.$host.config.sops.age.keyFile")")" && cat > "$(nix eval --raw "$flake#nixosConfigurations.$host.config.sops.age.keyFile")"

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
       
       # Inside the code section after successful deployment:
       if ! $DRY_RUN; then
         echo -e "\033[1;34m🔍 Retrieving generation number from $host...\033[0m"
#         GEN_NUM=$(ssh -t "$user@$host" "sudo -S nix-env -p /nix/var/nix/profiles/system --list-generations 2>/dev/null | tail -n1 | awk '{print \$1}'")
#         echo -e "\033[1;34m🔍 Retrieving generation number from $host...\033[0m"
  
#         GEN_NUM=$(ssh -T "$user@$host" "bash --norc -c 'sudo -n nix-env -p /nix/var/nix/profiles/system --list-generations 2>/dev/null'" | 
#           tail -n1 | 
#           awk 'match($0, /^[[:space:]]*([0-9]+)/, a) {print a[1]}')
  
#         if [[ -z "$GEN_NUM" ]] || ! [[ "$GEN_NUM" =~ ^[0-9]+$ ]]; then
#           echo -e "\033[1;31m❌ Failed to retrieve generation number from $host"
#           echo -e "Received output: '$GEN_NUM'\033[0m"
#           exit 1
#         fi
  
#         echo "📦 Tagging deployment for $host generation $GEN_NUM..."
#         yo push --flake "$flake" --repo "$repo" --host "$host" --generation "$GEN_NUM"
#       fi

         echo -e "\033[1;34m🔍 Retrieving generation number from $host...\033[0m"

         # Fetch the generation number using SSH
         #GEN_NUM=$(ssh -T "$user@$host" "bash --norc -c 'sudo -n nix-env -p /nix/var/nix/profiles/system --list-generations 2>/dev/null'" | tail -n1 | awk 'match($0, /^[[:space:]]*([0-9]+)/, a) {print a[1]}')
         #GEN_NUM=$(ssh -T "$user@$host" "sudo nix-env -p /nix/var/nix/profiles/system --list-generations 2>/dev/null" | awk '/current/ {gsub(/[^0-9]/,"",$1); print $1; exit}')
         GEN_NUM=$(ssh -T "$user@$host" "sudo -n nix-env --list-generations -p /nix/var/nix/profiles/system" | awk '/current/ {print $1}' | tail -n1)



         # Validate the generation number
         if [[ -z "$GEN_NUM" ]] || ! [[ "$GEN_NUM" =~ ^[0-9]+$ ]]; then
           echo -e "\033[1;31m❌ Failed to retrieve generation number from $host"
           echo -e "Received output: '$GEN_NUM'\033[0m"
           exit 1
         fi

         # Continue if the generation number is valid
         echo "📦 Tagging deployment for $host generation $GEN_NUM..."
         yo push --flake "$flake" --repo "$repo" --host "$host" --generation "$GEN_NUM"
       fi
     
     '';
    };
  };}
