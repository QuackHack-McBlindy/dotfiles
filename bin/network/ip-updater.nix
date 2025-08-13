# dotfiles/bin/network/ip-updater.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ 
  self, 
  lib, 
  config, # 🦆 says ⮞ 
  pkgs,
  cmdHelpers,
  ... 
} : let

in {

  yo.scripts.ip-updater = {
    description = "domain updater";
    category = "🌐 Networking";
    runEvery = "15";
#    autoStart = config.this.host.hostname == "homie"; # 🦆 says ⮞ dat'z sum conditional quack-fu yo!
#    aliases = [ "zigb" "hem" ]; # 🦆 says ⮞ and not laughing at me
    # 🦆 says ⮞ run `yo zigduck --help` to display your battery states!
#    helpFooter = '' 
## ──────⋆⋅☆⋅⋆────── ##
#    '';
    logLevel = "INFO";
    parameters = [ # 🦆 says ⮞ set your mosquitto user & password
      { name = "token1"; description = "API token file"; optional = false; default = config.sops.secrets.duckdnsEnv-gh-quackhack.path; }
      { name = "token2"; description = "API token file"; optional = false; default = config.sops.secrets.duckdnsEnv-gh-pungkula.path; }
      { name = "token3"; description = "API token file"; optional = false; default = config.sops.secrets.duckdnsEnv-x.path; }                  
    ]; # 🦆 says ⮞ Script entrypoint yo
    code = ''
      ${cmdHelpers}

      ip_var=$(dig +short myip.opendns.com @resolver1.opendns.com)
      duckdns1Token=$(cat $token1  | grep 'TOKEN=' | sed 's/TOKEN=//g' | sed 's/^[ \t]*//;s/[ \t]*$//')
      duckdns1domains=$(cat $token1 | grep 'SUBDOMAINS=' | sed 's/SUBDOMAINS=//g' | sed 's/^[ \t]*//;s/[ \t]*$//')

      duckdns2Token=$(cat $token2 | grep 'TOKEN=' | sed 's/TOKEN=//g' | sed 's/^[ \t]*//;s/[ \t]*$//')
      duckdns2domains=$(cat $token2 | grep 'SUBDOMAINS=' | sed 's/SUBDOMAINS=//g' | sed 's/^[ \t]*//;s/[ \t]*$//')

      duckdns3Token=$(cat $token3 | grep 'TOKEN=' | sed 's/TOKEN=//g' | sed 's/^[ \t]*//;s/[ \t]*$//')
      duckdns3domains=$(cat $token3 | grep 'SUBDOMAINS=' | sed 's/SUBDOMAINS=//g' | sed 's/^[ \t]*//;s/[ \t]*$//')

      update_duckdns() {
        local domains=$1
        local token=$2
        local ip=$3
        IFS=',' read -ra SUBDOMAINS <<< "$domains"
        for subdomain in "''${SUBDOMAINS[@]}"; do
          if curl -k "https://www.duckdns.org/update?domains=$subdomain&token=$token&ip=$ip" | grep -q "OK"; then
            dt_info "OK"
          else
            dt_error "DuckDNS update for $subdomain: FAILED"
          fi
        done
      }

      update_duckdns "$duckdns1domains" "$duckdns1Token" "$ip_var"
      update_duckdns "$duckdns2domains" "$duckdns2Token" "$ip_var"
      update_duckdns "$duckdns3domains" "$duckdns3Token" "$ip_var"
      
    '';
  };  
  sops.secrets = {
    duckdnsEnv-x = {
      sopsFile = ./../../secrets/duckdnsEnv-x.yaml;
      owner = config.this.user.me.name;
      group = config.this.user.me.name;
      mode = "0660";
    };
    duckdnsEnv-gh-pungkula = {
      sopsFile = ./../../secrets/duckdnsEnv-gh-pungkula.yaml;
      owner = config.this.user.me.name;
      group = config.this.user.me.name;
      mode = "0660";
    };
    duckdnsEnv-gh-quackhack = {
      sopsFile = ./../../secrets/duckdnsEnv-gh-quackhack.yaml;
      owner = config.this.user.me.name;
      group = config.this.user.me.name;
      mode = "0660";
    };
  };}
