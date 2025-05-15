{ config, pkgs, lib, ... }:

with lib;

let
  script = pkgs.writeShellScriptBin "network_recover" ''
    #!/bin/bash
    LOGFILE="/var/log/network_recover.log"

    # Detect active network interface (ignoring Docker/Bridge)
    IFACE=$(ip -o -4 route show default | awk '{print $5}' | grep -vE 'docker|br-' | head -n 1)
    if [[ -z "$IFACE" ]]; then
        echo "$(date) - No active network interface detected!" >> "$LOGFILE"
        exit 1
    fi

    # Check if network is reachable
    GATEWAY=$(ip route | grep default | awk '{print $3}')
    if ping -c 2 -W 2 $GATEWAY >/dev/null 2>&1; then
        echo "$(date) - Network is up. No action needed." >> "$LOGFILE"
        exit 0
    fi

    echo "$(date) - Network down! Restoring default settings..." >> "$LOGFILE"

    # Restart networking
    systemctl restart NetworkManager || systemctl restart networking

    # Set DNS to Google & Cloudflare
    echo "nameserver 8.8.8.8" > /etc/resolv.conf
    echo "nameserver 1.1.1.1" >> /etc/resolv.conf

    # Remove only downed Docker bridge networks
    docker network prune -f
    docker network rm $(docker network ls --format '{{.ID}} {{.Name}}' | grep "^br-" | awk '{print $1}') 2>/dev/null

    # Restart Docker
    systemctl restart docker

    echo "$(date) - Network recovery attempt completed. DNS set to 8.8.8.8 & 1.1.1.1" >> "$LOGFILE"
  '';
in
{
  options = {
    services.network-recover.enable = mkEnableOption "Network Auto-Recovery Service";
  };

  config = mkIf config.services.network-recover.enable {

    systemd.services.network-recover = {
      description = "Auto Network Recovery Service";
      wantedBy = [ "network.target" ];  # Only start when network is failing
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${script}/bin/network_recover";
        Restart = "on-failure";  # Do not restart always, only if it fails
      };
    };

    # Add a timer to check connectivity every minute
    systemd.timers.network-recover = {
      description = "Check network status periodically";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "2min";
        OnUnitActiveSec = "1min";
        Unit = "network-recover.service";
      };
    };

    # Ensure required packages are installed
    environment.systemPackages = with pkgs; [ iproute2 coreutils docker ];

  };
}

