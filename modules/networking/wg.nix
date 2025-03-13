{ config, pkgs, lib, ... }:

with lib;

let
  # Define static hostnames with IPs and roles
  hosts = {
    "desktop" = { ip = "10.100.0.2"; role = "client"; };
    "laptop"  = { ip = "10.100.0.3"; role = "client"; };
    "homie"   = { ip = "10.100.0.4"; role = "client"; };
    "iphone"  = { ip = "10.100.0.5"; role = "client"; };
    "nasty"   = { ip = "10.100.0.6"; role = "client"; };
    "tablet"  = { ip = "10.100.0.7"; role = "client"; };
  };

  # Define the WireGuard server
  server = {
    hostname = "homie";
    ip = "10.100.0.1";
    privateKeyFile = "/etc/wireguard/server-private.key";
    externalInterface = "eth0";
    listenPort = 51820;
  };

  # Get the current hostname
  hostname = builtins.getEnv "HOSTNAME";

  # Get current host config or default to server if the hostname is unknown
  hostConfig = hosts.${hostname} or { ip = server.ip; role = "server"; };

in
{
  networking.firewall.allowedUDPPorts = [ server.listenPort ];

  networking.wireguard.interfaces.wg0 = {
    ips = [ "${hostConfig.ip}/24" ];
    listenPort = server.listenPort;
    privateKeyFile = if hostConfig.role == "server" then server.privateKeyFile else "/etc/wireguard/${hostname}-private.key";

    peers = if hostConfig.role == "server" then
      # Server peers (all clients)
      map (h: {
        publicKey = "/etc/wireguard/${h}-public.key"; # Assume public keys are stored here
        allowedIPs = [ "${hosts.${h}.ip}/32" ];
      }) (builtins.attrNames hosts)
    else [
      # Client peer (only the server)
      {
        publicKey = "/etc/wireguard/server-public.key";
        allowedIPs = [ "0.0.0.0/0" ]; # Route all traffic through VPN
        endpoint = "${server.ip}:${toString server.listenPort}";
        persistentKeepalive = 25;
      }
    ];
  };

  # Server-specific NAT setup
  networking.nat = mkIf (hostConfig.role == "server") {
    enable = true;
    externalInterface = server.externalInterface;
    internalInterfaces = [ "wg0" ];
  };

  systemd.services.wireguard-setup = mkIf (hostConfig.role == "server") {
    wantedBy = [ "network-pre.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s ${server.ip}/24 -o ${server.externalInterface} -j MASQUERADE
    '';
  };

  systemd.services.wireguard-teardown = mkIf (hostConfig.role == "server") {
    wantedBy = [ "shutdown.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s ${server.ip}/24 -o ${server.externalInterface} -j MASQUERADE
    '';
  };
}

