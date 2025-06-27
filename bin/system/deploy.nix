# dotfiles/bin/system/deploy.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ self, config, pkgs, cmdHelpers, ... }:
let
  sysHosts = builtins.attrNames self.nixosConfigurations;
  vmHosts = builtins.filter (host:
    self.nixosConfigurations.${host}.self.config.system.build ? vm
  ) sysHosts;  
in {
  yo.scripts = { 
   deploy = {
     description = "Build and deploy a NixOS configuration to a remote host. Bootstraps, builds locally, activates remotely, and auto-tags the generation.";
     aliases = [ "d" ];
     category = "🖥️ System Management";
     parameters = [
       { name = "host"; description = "Host machine to build and activate"; optional = false; }
       { name = "flake"; description = "Path to the directory containing your flake.nix"; default = config.this.user.me.dotfilesDir; }
       { name = "user"; description = "SSH username"; optional = true; default = config.this.user.me.name; }
       { name = "repo"; description = "Repository containing containing your NixOS configuration files"; optional = true; default = config.this.user.me.repo; }    
       { name = "port"; description = "SSH port"; optional = true; default = "2222"; }
       { name = "!"; description = "Test mode (does not save new NixOS generation)"; optional = true; }
     ];
#     helpFooter = ''

#     '';
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
       
       # Validate host connectivity early
       if ! ssh -p "$port" -o ConnectTimeout=5 "$user@$host" true; then
         fail "❌ Cannot connect to $host via SSH."
       fi
       
       convert_git_to_https() {
         local repo_url="$1"
         if [[ "$repo_url" =~ ^https?:// ]]; then
           echo "$repo_url"
         elif [[ "$repo_url" =~ ^git@([^:]+):(.+\.git)$ ]]; then
           local domain="''${BASH_REMATCH[1]}"
           local path="''${BASH_REMATCH[2]}"
           echo "https://$domain/$path"
         else
           echo "⚠️ Warning: Unrecognized repo URL format: $repo_url" >&2
           echo "$repo_url"
         fi
       }

       bootstrap_mode=false
       result=$(ssh -p "$port" "$user@$host" "[ -d '$flake/.git' ] && echo true || echo false")
       if [ "$result" = "true" ]; then
         run_cmd echo "✅ Dotfiles repo exists on $host"
       else
         # Otherwise clone it to $flake parameter
         bootstrap_mode=true
         run_cmd echo "🚀 Bootstrap: Cloning dotfiles repo to ''$flake on ''$host"
         https_repo=$(convert_git_to_https "$repo")
         run_cmd ssh -p "$port" "$user"@"$host" "git clone '$https_repo' '$flake'" || fail "❌ Clone failed"
         run_cmd echo "Please decrypt $host AGE key, Enter PIN and touch your Yubikey"
         run_cmd echo ""
         key_path=$(nix eval --raw "$flake#nixosConfigurations.$host.config.sops.age.keyFile")
         key_dir=$(dirname "$key_path")
         echo "🔐 Setting up age key at: $key_path"
         if ! $DRY_RUN; then
             tmpkey=$(mktemp) || fail "❌ Failed to create temp file"
             trap 'rm -f "$tmpkey"' EXIT
    
             # Decrypt key
             yo yubi decrypt "$flake/secrets/hosts/$host/age.key" > "$tmpkey" || fail "❌ Decryption failed"
    
             ssh -p "$port" "$user@$host" "sudo mkdir -p '$key_dir' && sudo chown $(whoami) '$key_dir'" || fail "❌ Directory setup failed"
    
             scp -P "$port" "$tmpkey" "$user@$host:$key_path.tmp" || fail "❌ Copy key failed"
             ssh -p "$port" "$user@$host" "sudo mv '$key_path.tmp' '$key_path' && sudo chmod 600 '$key_path' && sudo chown root:root '$key_path'" || fail "❌ Key setup failed"
             rm -f "$tmpkey"
             echo "✅ Pre-bootstrap steps completed."
         else
             echo "Would set up age key at $key_path"
         fi
       fi 

       echo "👤 SSH User: ''$user"
       echo "🌐 SSH Host: ''$host"
       echo "❄️ Nix flake: ''$flake"
       echo "🚀 Deploying ''$flake#nixosConfigurations.''$host"
       if $bootstrap_mode; then
         echo "🔨 Building on the remote machine..."
       else
         echo "🔨 Building locally and activating remotely..."
       fi   

       export NIX_SSHOPTS="-p $port"
       if $DRY_RUN; then
         rebuild_command="test"
       else
         rebuild_command="switch"
       fi
       cmd=(
         ${pkgs.nixos-rebuild}/bin/nixos-rebuild
         $rebuild_command
           --option builders ""    
           --flake "$flake#$host"
           --target-host "$user@$host"
           --use-remote-sudo
           --show-trace
       )

       # If first deployment, signature key will be missing and a remote build is required.
       if $bootstrap_mode; then
         cmd+=( --build-host "$user@$host" )
       fi      
      
#       "''${cmd[@]}"

       if "''${cmd[@]}"; then
         if $DRY_RUN; then
           say_duck " ⚠️ Test deployment completed - No system generation saved!"
         else
           say_duck " ✅ Created new system generation!"
           play_win
         fi
       else
         say_duck "fuck ❌ System rebuild failed!"
         play_fail
         exit 1
       fi 
            
       if ! $DRY_RUN; then
         echo -e "\033[1;34m🔍 Retrieving generation number from $host...\033[0m"

         # Fetch the generation number using SSH
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
