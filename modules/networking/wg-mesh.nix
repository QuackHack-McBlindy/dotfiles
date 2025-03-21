{ config, pkgs, lib, ... }:

let
  # Define the IP range for the WireGuard network
  wgNetwork = "10.0.0.0/24";

  # Define the hub's (desktop) IP address
  hubIp = "10.0.0.1";

  # Define the spokes (clients) and their IPs
  spokes = {
    laptop = {
      ip = "10.0.0.2";
      publicKey = "LAPTOP_PUBLIC_KEY"; # Replace with the actual public key
    };
    homie = {
      ip = "10.0.0.3";
      publicKey = "HOMIE_PUBLIC_KEY"; # Replace with the actual public key
    };
    nasty = {
      ip = "10.0.0.4";
      publicKey = "NASTY_PUBLIC_KEY"; # Replace with the actual public key
    };
  };

  # Get the current host's name dynamically
  currentHostName = config.networking.hostName;

  # Function to generate a private key and derive the public key
  generateKeys = hostName:
    let
      privateKeyFile = "/etc/wireguard/private-${hostName}.key";
      privateKey = pkgs.runCommand "wg-genkey-${hostName}" {} ''
        ${pkgs.wireguard-tools}/bin/wg genkey > $out
      '';
      publicKey = pkgs.runCommand "wg-pubkey-${hostName}" {} ''
        ${pkgs.wireguard-tools}/bin/wg pubkey < ${privateKey} > $out
      '';
    in {
      privateKeyFile = privateKeyFile;
      privateKey = privateKey;
      publicKey = lib.strings.fileContents publicKey;
    };

  # Generate keys for all hosts
  hostKeys = lib.mapAttrs (name: _: generateKeys name) ({ desktop = {}; } // spokes);

in {
  options = {
    wireguard = {
      enable = lib.mkEnableOption "Enable WireGuard hub-and-spoke network";
    };
  };

  config = lib.mkIf config.wireguard.enable {
    networking.firewall.allowedUDPPorts = [ 51820 ]; # WireGuard port

    # Ensure the WireGuard package is available
    environment.systemPackages = [ pkgs.wireguard-tools ];

    # Write the private key to a file
    systemd.services.wireguard-keygen = {
      description = "Generate WireGuard private key";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.bash}/bin/bash -c 'mkdir -p /etc/wireguard && ${pkgs.wireguard-tools}/bin/wg genkey > ${hostKeys.${currentHostName}.privateKeyFile}'";
        RemainAfterExit = true;
      };
      wantedBy = [ "multi-user.target" ];
    };

    # Configure the WireGuard interface
    networking.wireguard.interfaces = {
      wg0 = {
        ips = [
          (if currentHostName == "desktop" then "${hubIp}/24" else "${spokes.${currentHostName}.ip}/24")
        ];
        listenPort = if currentHostName == "desktop" then 51820 else null; # Only the hub listens
        privateKeyFile = hostKeys.${currentHostName}.privateKeyFile;
        peers =
          if currentHostName == "desktop" then
            # Hub configuration: peers are the spokes
            lib.mapAttrsToList (name: spokeConfig: {
              publicKey = spokeConfig.publicKey;
              allowedIPs = [ "${spokeConfig.ip}/32" ];
              persistentKeepalive = 25; # Keep the connection alive
            }) spokes
          else
            # Spoke configuration: peer is the hub
            [
              {
                publicKey = hostKeys.desktop.publicKey;
                allowedIPs = [ wgNetwork ]; # Route all traffic through the hub
                endpoint = "desktop.example.com:51820"; # Replace with the hub's IP or domain
                persistentKeepalive = 25; # Keep the connection alive
              }
            ];
      };
    };
  };
}
