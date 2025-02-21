{ 
  config, 
  lib, 
  pkgs, 
  ... 
} : {
  services.fail2ban = {
    enable = true;

    # Global settings
    maxretry = 5;
   # ignoreIP = [
   #   "10.0.0.0/8" "172.16.0.0/12" "192.168.0.0/16"
   #   "8.8.8.8" "nixos.wiki"
  #  ];
    bantime = "24h";

    bantime-increment = {
      enable = true;
    #  formula = "ban.Time * math.exp(float(ban.Count+1)*banFactor)/math.exp(1*banFactor)";
      multipliers = "1 2 4 8 16 32 64";
      maxtime = "168h";
      overalljails = true;
    };

    jails = {
      sshd.settings = {
        logpath  = "journalctl -k --no-pager --quiet";
        backend  = "systemd";
        maxretry = 5;
        action = ''%(action_)s[blocktype=DROP] say'';

      };

      iptables-refused.settings = {
        filter = "iptables-refused";
        backend = "systemd";
        journalmatch = "_TRANSPORT=kernel";
        maxretry = 5;
        findtime = 600;
        bantime = 3600;
        action = "warning";
      };

      caddy.settings = {
        logpath  = "/var/log/caddy/access.log";
        findtime = 600;
        bantime  = 3600;
        maxretry = 10;
        backend  = "auto";
        filter   = "caddy";
        action   = ''%(action_)s[blocktype=DROP] ntfy'';
      };

  #    apache-nohome-iptables.settings = {
#        filter  = "apache-nohome";
#        action  = ''iptables-multiport[name=HTTP, port="http,https"]'';
 #       logpath = "/var/log/httpd/error_log*";
#        backend = "auto";
#        findtime = 600;
#        bantime  = 600;
#        maxretry = 5;
#      };

#      nginx-url-probe.settings = {
#        filter  = "nginx-url-probe";
#        logpath = "/var/log/nginx/access.log";
#        action  = ''%(action_)s[blocktype=DROP] ntfy'';
#        backend = "auto";
#        findtime = 600;
#        maxretry = 5;
#      };

 #     dovecot.settings = {
 #       filter  = "dovecot-auth";
 #       logpath = "/var/log/dovecot.log";
 #       action  = ''
#          iptables-multiport[name=Dovecot, port="pop3,pop3s,imap,imaps"]
 #         %(action_)s[blocktype=DROP]
#          custom-syslog
#        '';
#        backend  = "auto";
#        findtime = 600;
#        maxretry = 3;
 #     };
    };
  };

  environment.etc = {
    "fail2ban/action.d/say.local".text = ''
      [Definition]
      actionban = /run/current-system/sw/bin/bash -c '/home/pungkula/dotfiles/home/bin/say "Yo dawg! Suspicious activity detected from <ip>. Activate paranoid mode..."'
    ''; 
  
    "fail2ban/action.d/ntfy.local".text = ''
      [Definition]
      norestored = true
      actionban = curl -H "Title:  banned" -d " jail banned  after  failures on $(hostname)" https://ntfy.sh/Fail2banNotifications
    '';

    "fail2ban/filter.d/nginx-url-probe.local".text = ''
      [Definition]
      failregex = ^<HOST>.*(GET /(wp-|admin|boaform|phpmyadmin|\.env|\.git)|\.(dll|so|cfm|asp)|(\?|&)(=[A-F0-9]+)) 
      ignoreregex =
    '';

    "fail2ban/filter.d/dovecot-auth.local".text = ''
      [Definition]
      failregex = %(failregex_dovecot_auth)s
      ignoreregex =
    '';
    
    "fail2ban/filter.d/iptables-refused.conf".text = ''    
      [Definition]
      failregex = .* IN=.* OUT=.* MAC=.* SRC=<HOST> DST=.* PROTO=.* REJECT
      ignoreregex =
    '';

    "fail2ban/action.d/custom-syslog.local".text = ''
      [Definition]
      actionban = logger -t fail2ban "Banned <ip> on jail <name> after <failures> failures"
      actionunban = logger -t fail2ban "Unbanned <ip> on jail <name> after ban duration expired"
    '';
  };
}
