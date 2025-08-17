# dotfiles/bin/network/notify.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ send customized iOS push notifications
  self, 
  lib, 
  config,     
  pkgs,        
  cmdHelpers,
  ... 
} : let 
in {
  yo.scripts.notify = { 
    description = "Send custom push to iOS devices";
    category = "🌐 Networking";
    autoStart = false;
    logLevel = "DEBUG";
    parameters = [
      { name = "text"; description = "Notification content"; }    
      { name = "title"; description = "Topic to publish to"; default = "Yo! Notis!"; }
      { name = "icon"; description = "Push image icon"; default = "https://avatars.githubusercontent.com/u/175031622?s=96&v=4"; }    
      { name = "url"; description = "Optional URL to open on tap"; default = "https://example.com"; }
      { name = "group"; description = "Notification group/channel"; default = "default"; }
      { name = "sound"; description = "Notification sound. Available sounds: minuet, electronic, horn, bark, bell, chime, glass, healthnotification."; default = "minuet"; } 
      { name = "level"; description = "Notification level. Available values are: info, critical, error."; default = "info"; }
      { name = "base_urlFile"; description = "File path containing a HTTPS domain"; default = config.sops.secrets.ntfy-url.path; }
      { name = "deviceKeyFile"; description = "The receiving devices key file"; default = config.sops.secrets.bark_key.path; }    
    ]; # 🦆 says ⮞ call diz like dat: `yo notify this is my message`
    code = ''
      ${cmdHelpers}
      DEVICE_KEY=$(cat $deviceKeyFile)
      if [ -z "$DEVICE_KEY" ]; then
        dt_error "Sending push notification requires a receiver!" >&2
        exit 1
      fi 
      BASE_URL=$(cat $base_urlFile)
      if [ -z "$BASE_URL" ]; then
        dt_error "Cannot run without base URL!" >&2
        exit 1
      fi
      TEXT=$text
      TITLE=$title
      ICON=$icon
      SOUND=$sound
      GROUP=$group
      LEVEL=$level
      URL=$url
      
      JSON=$(cat <<EOF
{
  "body": "$TEXT",
  "device_key": "$DEVICE_KEY",
  "title": "$TITLE",
  "badge": 1,
  "sound": "$SOUND",
  "volume": 5,
  "icon": "$ICON",
  "group": "$GROUP",
  "level": "critical",  
  "url": "$URL"
}
EOF
      )      

      ${pkgs.curl}/bin/curl -X POST "$BASE_URL/push" \
        -H 'Content-Type: application/json' \
        -d "$JSON"
    '';
  }; 
  
  sops.secrets = {
    ntfy-url = {
      sopsFile = ./../../secrets/ntfy-url.yaml;
      owner = config.this.user.me.name;
      group = config.this.user.me.name;
      mode = "0440";
    };
    bark_key = {
      sopsFile = ./../../secrets/hosts/iphone/bark_key.yaml;
      owner = config.this.user.me.name;
      group = config.this.user.me.name;
      mode = "0440";
    };
  };}
