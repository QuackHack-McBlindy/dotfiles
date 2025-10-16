# dotfiles/bin/productivity/shareWiFi.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ Generate QR and send to iphone for guests to scan
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ...
} : let
in {  
  # 🦆 says ⮞ port for stop url
  networking.firewall.allowedTCPPorts = [ 9876 ];
  
  yo.scripts.shareWiFi = {
    description = "creates a QR code of guest WiFi and push image to iPhone";
    category = "🌐 Networking";
    autoStart = false;
    logLevel = "INFO";
    parameters = [
      { name = "ssidFile"; description = "File path containing guest WiFi SSID"; default = config.sops.secrets.guest_wifi_ssid.path; }
      { name = "passwordFile"; description = "File path containing guest WiFi password"; default = config.sops.secrets.guest_wifi_password.path; }
    ];  
    code = ''
      ${cmdHelpers}
      SSID=$(cat $ssidFile)
      PASSWORD=$(cat $passwordFile)
      TMP_FILE=$(mktemp --suffix=.png /tmp/wifiqr.XXXXXX)
      yo qr --input "WIFI:T:WPA;S:$SSID;P:$PASSWORD;;" --output "$TMP_FILE"
      yo img2phone "$TMP_FILE"
      
    '';
    voice = {
      sentences = [
        "dela [gäst] (wifi|internet)"
        "internet delning"
        "dela internet för gäster"
        "dela internet"
      ];
    };
  };
  
  sops.secrets = {
    guest_wifi_ssid = {
      sopsFile = ./../../secrets/guestWiFiSSID.yaml;
      owner = config.this.user.me.name;
      group = config.this.user.me.name;
      mode = "0440";
    };
    guest_wifi_password = {
      sopsFile = ./../../secrets/guestWiFiPassword.yaml;
      owner = config.this.user.me.name;
      group = config.this.user.me.name;
      mode = "0440";
    };
    
  };}
