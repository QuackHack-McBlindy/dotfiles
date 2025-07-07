# dotfiles/bin/network/notfy.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ notification system using ntfy-sh
  self, 
  lib, 
  config,     
  pkgs,        
  cmdHelpers,
  ... 
} : let 
in {
  yo.scripts.notify = { 
    description = "Send Notifications eazy as-quick quack done";
    category = "🌐 Networking";
    logLevel = "DEBUG";
    parameters = [
      { name = "message"; description = "Notification content"; optional = false; }    
      { name = "topic"; description = "Topic to publish to"; default = "quack"; optional = false; }
      { name = "base_urlFile"; description = ""; default = config.sops.secrets.ntfy-url.path; optional = false; }
    ]; 
    code = ''
      ${cmdHelpers}
      BASE_URL=$(cat $base_urlFile)

      if [ -z "$BASE_URL" ]; then
        dt_error "Cannot run without base URL!" >&2
        exit 1
      fi  

      ${pkgs.ntfy-sh}/bin/ntfy publish \
        --base-url="$BASE_URL" \
        "$topic" \
        "$message"
    '';
  };  

  yo.scripts.notfy = { 
    description = "Server Notification system";
    category = "🌐 Networking";
#    autoStart = config.this.host.hostname == "desktop"; # 🦆 says ⮞ dat'z sum conditional quack-fu yo!
    logLevel = "DEBUG";
    parameters = [ # 🦆 says ⮞ set your mosquitto user & password
      { name = "base_urlFile"; description = ""; default = config.sops.secrets.ntfy-url.path; optional = false; }
      { name = "port"; description = ""; default = ":9013"; optional = false; }
      { name = "publicKey"; description = ""; default = "BGxWiWgvfogQXS9Lz9diQe7G29jvuca0856U6Fb8m9NPUQj525BS62syNrBXUTFx4H32GQFomdVs0lHrHDIXD3U"; optional = false; }
      { name = "private_keyFile"; description = ""; default = config.sops.secrets.ntfy-private.path; optional = false; }
      { name = "web_pushFile"; description = ""; default = "/var/lib/ntfy-sh/webpush.db"; optional = false; }      
    ]; 
    code = ''
      ${cmdHelpers} # 🦆 says ⮞ load default helper functions 
      PRIVATE_KEY=$(cat $private_keyFile)
      BASE_URL=$(cat $base_urlFile)
      dt_debug "$BASE_URL"
      if [ -z "$PRIVATE_KEY" ]; then
        dt_error "Private key is empty!" >&2
        exit 1
      fi
      if [ -z "$BASE_URL" ]; then
        dt_error "Cannot run without base URL!" >&2
        exit 1
      fi  
       
      ${pkgs.ntfy-sh}/bin/ntfy serve \
        --base-url "$BASE_URL" \
        --listen-http "$port" \
        --behind-proxy \
        --web-push-public-key "$publicKey" \
        --web-push-private-key "$PRIVATE_KEY" \
        --web-push-file "$web_pushFile" \
        --cache-file ~/.local/share/ntfy/cache.db \
        --web-push-email-address "example@mail.com" \
    '';
  };  
  sops.secrets = {
    ntfy-private = {
      sopsFile = ./../../secrets/ntfy-private.yaml;
      owner = config.this.user.me.name;
      group = config.this.user.me.name;
      mode = "0440"; 
    };
    ntfy-url = {
      sopsFile = ./../../secrets/ntfy-url.yaml;
      owner = config.this.user.me.name;
      group = config.this.user.me.name;
      mode = "0440";
    };
    
  };} # 🦆 says ⮞ sleep tight!
# 🦆 says ⮞ QuackHack-McBLindy out!
# ... 🛌🦆💤

