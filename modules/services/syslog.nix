
{ config, lib, pkgs, ... }:
let
  hostname = config.networking.hostName;  # Get the system hostname
in
{
  # Ensure syslogd does not conflict with rsyslogd (if it's enabled elsewhere)
  services.rsyslogd.enable = false;
  # Ensure the /var/log/hosts directory exists

  # Enable the syslogd service
  services.syslogd = {
    enable = true;
    #enableNetworkInput = true;
    # Specify the TTY device for syslog output (leave empty for no TTY logging)
    #tty = "tty12";

  # Use default syslog configuration or modify as needed
    defaultConfig = ''
      *.emerg                       *
      local1.*                       -/var/log/dhcpd
      mail.*                         -/var/log/mail
      *.=warning;*.=err             -/var/log/warn
      *.crit                        /var/log/warn
      *.*;mail.none;local1.none     -/var/log/messages

      # Per-host log directories
      # The hostname of the client is used to direct logs to different directories
      # The pattern "hostname.*" is used to direct logs from a host to its respective log directory
      *.info;*.notice;*.warning    -/var/log/hosts/${hostname}/syslog.log
    '';


    # Send logs to the server via UDP
    extraConfig = ''
      *.*    @192.168.1.111:514
    '';

    # Additional syslogd parameters
    extraParams = [ "-m 0" ];
  };
}

