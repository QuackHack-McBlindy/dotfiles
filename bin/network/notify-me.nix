# dotfiles/bin/network/notify-me.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ iOS push notification server
  self, 
  lib, 
  config,     
  pkgs,        
  cmdHelpers,
  ... 
} : let 
in {
  networking.firewall.allowedTCPPorts = [9913];
  # 🦆 says ⮞ diz runz on da boot, no worriez - duckie be listenin'
  yo.scripts.notify-me = {
    description = "Notification server for iOS devices";
    category = "🌐 Networking";
    logLevel = "DEBUG";
    autoStart = builtins.elem config.this.host.hostname [ "homie" ];
    parameters = [
      { name = "address"; description = "IP to run server on"; default = "0.0.0.0"; }
      { name = "port"; description = "Port for the service"; default = "9913";  } 
      { name = "dataDir"; description = "Directory path to store server data"; default = "/home/pungkula/barks";  }       
    ]; 
    code = ''
      ${cmdHelpers}
      mkdir $dataDir
      ${pkgs.bark-server}/bin/bark-server \
        --addr "$address:$port" \
        --data "$dataDir" \
        2>&1 | while IFS= read -r line; do
          dt_info "$line"
        done
    '';  
  };
  
  sops.secrets = {
    ntfy-url = {
      sopsFile = ./../../secrets/ntfy-url.yaml;
      owner = config.this.user.me.name;
      group = config.this.user.me.name;
      mode = "0440";
    };  
    
  };} # 🦆 says ⮞ sleep tight!
# 🦆 says ⮞ QuackHack-McBLindy out!
# ... 🛌🦆💤












