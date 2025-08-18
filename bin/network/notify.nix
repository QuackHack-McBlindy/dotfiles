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
      { name = "url"; description = "Optional URL to open on tap"; optional = true; }
      { name = "group"; description = "Notification group/channel"; default = "default"; }
      { name = "sound"; description = "Notification sound. Available sounds: minuet, electronic, horn, bark, bell, chime, glass, healthnotification."; default = "minuet"; } 
      { name = "volume"; description = "Set volume level for the notification sound. 1 (lowest) - 10 (highest)."; default = "5"; }      
      { name = "copy"; description = "Value to copy to device."; optional = true; } 
      { name = "autoCopy"; description = "Must be 1 to copy"; default = "0"; } 
      { name = "level"; description = "Notification level. Available values are: info, critical, error."; default = "info"; }
      { name = "encrypt"; description = "Set to 1 to encrypt the notification"; default = "0"; }
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
      VOLUME=$volume
      GROUP=$group
      LEVEL=$level
      URL=$url
      AUTOCOPY=0
      if [ -n "$copy" ]; then    
        AUTOCOPY=1
        COPY=$copy
      fi  
      JSON=$(cat <<EOF
{
  "body": "$TEXT",
  "device_key": "$DEVICE_KEY",
  "title": "$TITLE",
  "badge": 1,
  "sound": "$SOUND",
  "volume": "$VOLUME",
  "icon": "$ICON",
  "group": "$GROUP",
  "level": "$LEVEL",  
  "url": "$URL",
  "autoCopy": "$AUTOCOPY"
}
EOF
      )      

      if [ -n "$copy" ]; then
        JSON=$(echo "$JSON" | jq --arg copy "$COPY" '. + {copy: $COPY}')
      fi

      if [ "$encrypt" = "1" ]; then
        # 🦆 says ⮞ generate random nonce 12 bytes
        NONCE=$(${pkgs.openssl}/bin/openssl rand -hex 12)
        
        # 🦆 says ⮞ pad device_key to 32 bytes AES-256
        KEY=$(echo -n "$DEVICE_KEY" | ${pkgs.xxd}/bin/xxd -p | tr -d '\n' | head -c 64 | awk '{ printf "%-64s", $1 }' | tr ' ' '0')
        
        # 🦆 says ⮞ encrypt and get binary output
        CIPHERTEXT_TAG_BIN=$(echo -n "$TEXT" | ${pkgs.openssl}/bin/openssl enc -aes-256-gcm -e -K "$KEY" -iv "$NONCE" 2>/dev/null)
        
        # 🦆 says ⮞ convert nonce to binary
        NONCE_BIN=$(echo -n "$NONCE" | ${pkgs.xxd}/bin/xxd -r -p)
        
        # 🦆 says ⮞ combine nonce + ciphertext + tag
        BLOB="$NONCE_BIN$CIPHERTEXT_TAG_BIN"
        
        # 🦆 says ⮞ base64 encode the entire blob
        CIPHERTEXT_BASE64=$(echo -n "$BLOB" | ${pkgs.coreutils}/bin/base64 -w0)

        JSON=$(echo "$JSON" | jq \
          --arg ciphertext "$CIPHERTEXT_BASE64" \
          '. + {ciphertext: $ciphertext, isArchive: "1"} | del(.body)')
      fi


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
