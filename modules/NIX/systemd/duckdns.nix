{ config, pkgs, ... }:

{
  # Define a user for DuckDNS
  users.users.duckdns = {
    isSystemUser = true;
    group = "duckdns";
  };

  users.groups.duckdns = { };

  # Define the secrets (assuming paths are correct)
  sops.secrets = {
    duckdnsEnv-x = {
      sopsFile = ./../../../secrets/duckdnsEnv-x.yaml;
      owner = "duckdns";
      group = "duckdns";
      mode = "0660";
    };
    duckdnsEnv-gh-pungkula = {
      sopsFile = ./../../../secrets/duckdnsEnv-gh-pungkula.yaml;
      owner = "duckdns";
      group = "duckdns";
      mode = "0660";
    };
    duckdnsEnv-gh-quackhack = {
      sopsFile = ./../../../secrets/duckdnsEnv-gh-quackhack.yaml;
      owner = "duckdns";
      group = "duckdns";
      mode = "0660";
    };
  };

  # Create a systemd service to update DuckDNS
  systemd.services.duckdns-update = {
    description = "DuckDNS Update Service";
    after = [ "network.target" ];  # Correct the after field
    wantedBy = [ "multi-user.target" ];  # Correct the wantedBy field

    serviceConfig = {
      user = "duckdns";
      group = "duckdns";
      restart = "always";
      execStart = ''
        ip_var=$({pkgs.dig}/bin/dig  +short myip.opendns.com @resolver1.opendns.com)

        duckdns1Token=$(grep 'TOKEN=' /var/run/secrets/duckdnsEnv-gh-quackhack | sed 's/TOKEN=//')
        duckdns1domains=$(grep 'SUBDOMAINS=' /var/run/secrets/duckdnsEnv-gh-quackhack | sed 's/SUBDOMAINS=//')

        duckdns2Token=$(grep 'TOKEN=' /var/run/secrets/duckdnsEnv-gh-pungkula | sed 's/TOKEN=//')
        duckdns2domains=$(grep 'SUBDOMAINS=' /var/run/secrets/duckdnsEnv-gh-pungkula | sed 's/SUBDOMAINS=//')

        duckdns3Token=$(grep 'TOKEN=' /var/run/secrets/duckdnsEnv-x | sed 's/TOKEN=//')
        duckdns3domains=$(grep 'SUBDOMAINS=' /var/run/secrets/duckdnsEnv-x | sed 's/SUBDOMAINS=//')

        curl -k -o ~/duckdns.log "https://www.duckdns.org/update?domains=$duckdns1domains&token=$duckdns1Token&ip=$ip_var"
        curl -k -o ~/duckdns.log "https://www.duckdns.org/update?domains=$duckdns2domains&token=$duckdns2Token&ip=$ip_var"
        curl -k -o ~/duckdns.log "https://www.duckdns.org/update?domains=$duckdns3domains&token=$duckdns3Token&ip=$ip_var"
      '';
    };
  };
}

