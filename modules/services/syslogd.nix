  # CLIENT:
  #services.syslogd.enable = true;
  # Send logs to the server via UDP
 # services.syslogd.extraConfig = ''
 #   *.*    @your-syslog-server-ip:514
 # '';


{ config, lib, pkgs, ... }:
let
  hostname = config.networking.hostName;  # Get the system hostname
in
{
  # Ensure syslogd does not conflict with rsyslogd (if it's enabled elsewhere)
  services.rsyslogd.enable = false;
  # Ensure the /var/log/hosts directory exists
  systemd.tmpfiles.rules = [
    "d /var/log/hosts 0755 root root -"
  ];
  # Enable the syslogd service
  services.syslogd = {
    enable = true;
    enableNetworkInput = true;
    # Specify the TTY device for syslog output (leave empty for no TTY logging)
    #tty = "tty12";

  # Use default syslog configuration or modify as needed
    defaultConfig = ''
      *.emerg                       *
      local1.*                       -/var/log/hosts/${hostname}/dhcpd
      mail.*                         -/var/log/hosts/${hostname}/mail
      *.=warning;*.=err             -/var/log/hosts/${hostname}/warn
      *.crit                        /var/log/hosts/${hostname}/warn
      *.*;mail.none;local1.none     -/var/log/hosts/${hostname}/messages

      # Per-host log directories
      # The hostname of the client is used to direct logs to different directories
      # The pattern "hostname.*" is used to direct logs from a host to its respective log directory
      *.info;*.notice;*.warning    -/var/log/hosts/${hostname}/syslog.log
    '';

  # Append extra configuration (optional)
    extraConfig = ''
      news.* -/var/log/news
    '';

    # Additional syslogd parameters
    extraParams = [ "-m 0" ];
  };
}

