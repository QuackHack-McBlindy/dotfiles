{ config, ... }:
{
  services.shadowsocks = {
    enable = true;
    passwordFile = config.sops.secrets.SHADOWSOCKS_PASSWORD.path;
  };
  networking.firewall.allowedTCPPorts = [ 8388 ];
}
