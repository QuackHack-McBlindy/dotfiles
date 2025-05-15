{ config, ... }:
{
  services.shadowsocks = {
    enable = true;
    passwordFile = config.sops.secrets.SHADOWSOCKS_PASSWORD.path;
  };
  networking.firewall.allowedTCPPorts = [ 8388 ];
  
  
  sops.secrets = {
    SHADOWSOCKS_PASSWORD = {
      sopsFile = "/var/lib/sops-nix/secrets/SHADOWSOCKS_PASSWORD.yaml"; 
      owner = config.users.users.secretservice.name;
      group = config.users.groups.secretservice.name;
      mode = "0440"; # Read-only for owner and group
    };
  };

}
