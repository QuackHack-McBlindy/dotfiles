# dotfiles/bin/system/block.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ self, config, pkgs, cmdHelpers, ... }:
{
  yo.scripts = {
    block = {
      description = "Block URLs using DNS";
      category = "🌐 Networking";
      aliases = [ "ad" ];
      parameters = [ 
        { name = "url"; description = "Full url to be blocked"; optional = false; } 
        { name = "blocklist"; description = "File to store the lbocklist inside"; optional = true; default = config.this.user.me.dotfilesDir + "/home/.blocklist.txt"; }
      ];
      code = ''
        ${cmdHelpers}        
        clean_url=$(echo "$url" | sed -E 's|https?://||')      
        block_entry="||$clean_url^"
        echo "$block_entry" >> "$blocklist"
        dt_info "Added: $block_entry to ''$blocklist"
      '';
    };
  };}  
  
  
  
  
