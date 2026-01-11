# dotfiles/bin/system/deploy.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 say ⮞ yubikey encrypted deployment yystem - built by ducks for ducks
  self,
  config,
  pkgs,
  cmdHelpers,
  ...
} : let
  sysHosts = builtins.attrNames self.nixosConfigurations;
  vmHosts = builtins.filter (host:
    self.nixosConfigurations.${host}.self.config.system.build ? vm
  ) sysHosts;  
in {
  yo.scripts = { 
   deploy = {
     description = "Build and deploy a NixOS configuration to a remote host. Bootstraps, builds locally, activates remotely, and auto-tags the generation.";
     category = "🖥️ System Management";
     aliases = [ "rb" ];
     parameters = [
       { name = "host"; type = "string"; description = "Host machine to build and activate"; default = ""; optional = false; }
       { name = "flake"; type = "path"; description = "Path to the directory containing your flake.nix"; default = config.this.user.me.dotfilesDir; }
       { name = "user"; type = "string"; description = "SSH username"; optional = true; default = config.this.user.me.name; }
       { name = "repo"; type = "string"; description = "Repository containing containing your NixOS configuration files"; optional = true; default = config.this.user.me.repo; }    
       { name = "port"; type = "int"; description = "SSH port"; optional = true; default = 2222; }
       { name = "test"; type = "bool"; description = "Test deployment, does NOT save system generation, no git push, reboot to revert"; default = true; }
     ];
     code = ''   
       ${cmdHelpers}

       FAIL_COUNT_FILE="/tmp/nixos_rebuild_fail_count"
       
       if [[ -f "$FAIL_COUNT_FILE" ]]; then
         FAIL_COUNT=$(cat "$FAIL_COUNT_FILE")
       else
         FAIL_COUNT=0
       fi
       
       if [ "$test" = "true" ]; then
         DRY_RUN=1
       fi
       
       if $DRY_RUN; then
         echo "❗ Test run: reboot will revert activation"
       fi

       # 🦆 say ⮞ If host is empty, do local rebuild
       if [ -z "$host" ]; then
         if [ "$test" = "true" ]; then
           rebuild_command="test"
         else
           rebuild_command="switch"
         fi
         cmd=(
           sudo ${pkgs.nixos-rebuild}/bin/nixos-rebuild
           $rebuild_command
             --flake "$flake"
             --show-trace
         )
       
         if "''${cmd[@]}"; then
           if [[ $FAIL_COUNT -ge 11 ]]; then
             dt_info "🦆🎉 ! Rebuild sucessful! $FAIL_COUNT noob fails!"
             play_relax
           elif [[ $FAIL_COUNT -ge 5 ]]; then
             dt_info "😅 phew! $FAIL_COUNT noob fails!"
             play_win
           else
             if $DRY_RUN; then
               say_duck " ⚠️ Rebuild Test completed! - No system generation created!"
             else
               say_duck " ✅ Created new system generation!"
             fi
             play_win
           fi
           echo 0 > "$FAIL_COUNT_FILE"
         else
           FAIL_COUNT=$((FAIL_COUNT + 1))
           echo "$FAIL_COUNT" > "$FAIL_COUNT_FILE"
         
           if [[ $FAIL_COUNT -ge 5 ]]; then
             say_duck "fuck ❌ System rebuild failed!"
             play_fail3
           elif [[ $FAIL_COUNT -ge 3 ]]; then
             say_duck "fuck ❌ System rebuild failed!"
             play_fail2
           else
             say_duck "fuck ❌ System rebuild failed!"
             play_fail
           fi
           exit 1
         fi
         exit 0
       fi
                
       # 🦆 duck say ⮞ validate host connectivity
       if ! ssh -p "$port" -o ConnectTimeout=5 "$user@$host" true; then
         dt_error "❌ Cannot connect to $host via SSH."
       fi
       
       # 🦆 duck say ⮞ safety first 
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
       result=$(ssh -T -p "$port" "$user@$host" "bash --noprofile --norc -c '[ -d \"$flake/.git\" ] && echo true || echo false'")
       if [ "$result" = "true" ]; then
         echo "✅ Dotfiles repo exists on $host"
       else
         # 🦆 duck say ⮞ otherwise clone it to $flake parameter
         bootstrap_mode=true
         echo "🚀 Bootstrap: Cloning dotfiles repo to ''$flake on ''$host"
         https_repo=$(convert_git_to_https "$repo")
         ssh -p "$port" "$user"@"$host" "git clone '$https_repo' '$flake'" || fail "❌ Clone failed"
         echo "Please decrypt $host AGE key, Enter PIN and touch your Yubikey"
         echo ""
         key_path=$(nix eval --raw "$flake#nixosConfigurations.$host.config.sops.age.keyFile")
         key_dir=$(dirname "$key_path")
         echo "🔐 Setting up age key at: $key_path"
         if ! $DRY_RUN; then
             tmpkey=$(mktemp) || fail "❌ Failed to create temp file"
             trap 'rm -f "$tmpkey"' EXIT
    
             # 🦆 duck say ⮞ decrypt key
             yo yubi decrypt "$flake/secrets/hosts/$host/age.key" > "$tmpkey" || fail "❌ Decryption failed"
    
             ssh -tt -p "$port" "$user@$host" "sudo mkdir -p '$key_dir' && sudo chown '$user' '$key_dir'" || fail "❌ Directory setup failed"

             tmp_remote_path="$key_path.tmp"
    
             ssh -p "$port" "$user@$host" "cat > '$tmp_remote_path'" < "$tmpkey" || fail "❌ Copy key failed"

             ssh -tt -p "$port" "$user@$host" "sudo mv '$tmp_remote_path' '$key_path' && sudo chmod 600 '$key_path' && sudo chown root:root '$key_path'" || dt_error "❌ Key setup failed"
    
             
             rm -f "$tmpkey"
             echo "🎉 Pre-bootstrap steps completed."
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
           #--use-remote-sudo
           --ask-sudo-password
           --show-trace
       )

       # 🦆 say ⮞ if first deployment, signature key will be missing and a remote build is required.
       if $bootstrap_mode; then
         cmd+=( --build-host "$user@$host" )
       fi      
      
       # 🦆 say ⮞ resultz?
       if "''${cmd[@]}"; then
         if [[ $FAIL_COUNT -ge 9 ]]; then
           dt_info "🦆🎉 ! Rebuild sucessful! $FAIL_COUNT noob fails!"
           play_relax
         elif [[ $FAIL_COUNT -ge 5 ]]; then
           dt_info "😅 phew! $FAIL_COUNT noob fails!"
           play_win
         else
           if $DRY_RUN; then
             say_duck " ⚠️ Rebuild Test completed! - No system generation created!"
           else
             say_duck " ✅ Created new system generation!"
           fi
           play_win
         fi
         echo 0 > "$FAIL_COUNT_FILE"
       else
         FAIL_COUNT=$((FAIL_COUNT + 1))
         echo "$FAIL_COUNT" > "$FAIL_COUNT_FILE"
          
         if [[ $FAIL_COUNT -ge 5 ]]; then
           say_duck "fuck ❌ System rebuild failed!"
           play_fail3
         elif [[ $FAIL_COUNT -ge 3 ]]; then
           say_duck "fuck ❌ System rebuild failed!"
           play_fail2
         else
           say_duck "fuck ❌ System rebuild failed!"
           play_fail
         fi
         exit 1
       fi
            
       if ! $DRY_RUN; then
         echo -e "\033[1;34m🔍 Retrieving generation number from $host...\033[0m"

         # 🦆 duck say ⮞ fetch the generation number using SSH
         GEN_NUM=$(ssh -T "$user@$host" "sudo -n nix-env --list-generations -p /nix/var/nix/profiles/system" | awk '/current/ {print $1}' | tail -n1)

         # 🦆 duck say ⮞ validate the generation number
         if [[ -z "$GEN_NUM" ]] || ! [[ "$GEN_NUM" =~ ^[0-9]+$ ]]; then
           echo -e "\033[1;31m❌ Failed to retrieve generation number from $host"
           echo -e "Received output: '$GEN_NUM'\033[0m"
           exit 1
         fi

         # 🦆 duck say ⮞ validate the gen number
         echo "📦 Tagging deployment for $host generation $GEN_NUM..."
         yo push --flake "$flake" --repo "$repo" --host "$host" --generation "$GEN_NUM"
       fi     
     '';
     voice = {
       enabled = true;
       priority = 5;
       fuzzy.enable = false;
       sentences = [ 
         "{test} [att] (driftsätt|deploy) {host}"
         "(driftsätt|deploy) {host}"
         
         "(driftsätt|deploy) {host} med (användare|user) {user} [och] [port] {port}"
         "{test} [att] (driftsätt|deploy) {host} med (användare|user) {user} [och] [port] {port}" 
       ];
       lists = {
         host.values = [
           { "in" = "[desktop|vatten]"; out = "desktop"; }
           { "in" = "[homie|hem|hemserver]"; out = "homie"; }  
           { "in" = "[nasty|nas|nasen]"; out = "nasty"; }
           { "in" = "[laptop|laptoppen]"; out = "laptop"; }            
         ];
         user.values = [
           { "in" = "[pungkula]"; out = "pungkula"; }
           { "in" = "[annan]"; out = "random"; }        
         ];
         port.values = [
           { "in" = "[pungkula]"; out = "pungkula"; }
           { "in" = "[annan]"; out = "random"; }        
         ];
         test.values = [
           { "in" = "[test|testa|testar]"; out = "--test true"; }        
         ];
       };
     };
    };
    
  };}
