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
        ignoreIP = [
            "10.0.0.0/8" "172.16.0.0/12" "192.168.0.0/16"
            "8.8.8.8" "nixos.wiki"
        ];
        bantime = "24h";

        bantime-increment = {
            enable         = true;
            formula        = "ban.Time * math.exp(float(ban.Count+1)*banFactor)/math.exp(1*banFactor)";
            multipliers    = "1 2 4 8 16 32 64";
            maxtime        = "168h";
            overalljails   = true;
        };


#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
#°✶.•°••─→ JAILS ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶° 
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•


#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
#°✶.•°••─→ SSH ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶° 
        jails.sshd = {
            enabled  = true;
            logpath  = "/var/log/auth.log";
            backend  = "systemd"; # or "auto" if you use plain logs
            maxretry = 5;
        };
        
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
#°✶.•°••─→ CADDY ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶° 
      #  jails.caddy = {
    #        enabled = true;
            # Adjust the log path if your Caddy access log is stored elsewhere.
    ##        logpath = "/var/log/caddy/access.log";
    #        findtime = 600;
    #        bantime = 3600;
   #         maxretry = 10;
  #          backend = "auto";
            # Use the custom filter defined below.
#            filter = "caddy";
            # Custom action: here we chain the built-in iptables-block combined with our own ntfy notification.
            # You can adjust the action string if you want to use different ban methods.
    #        action = ''
   #             %(action_)s[blocktype=DROP]
  #              ntfy
    #        '';
    #    };

#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
#°✶.•°••─→ NO HOME ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶° 
  #      jails."apache-nohome-iptables" = {
  #          enabled = true;
 #           filter  = "apache-nohome";
  #          action  = ''iptables-multiport[name=HTTP, port="http,https"]'';
 #           logpath = "/var/log/httpd/error_log*";
 #           backend = "auto";
 #           findtime = 600;
 #           bantime  = 600;
 #           maxretry = 5;
#        };

#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
#°✶.•°••─→ NGINX ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶° 
  #      jails."nginx-url-probe" = {
   #         enabled = true;
  #          filter  = "nginx-url-probe";
  #          logpath = "/var/log/nginx/access.log";
 #           action  = ''
  #              %(action_)s[blocktype=DROP]
  #              ntfy
  #          '';
#            backend = "auto";
#            findtime = 600;
#            maxretry = 5;
#        };

#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
#°✶.•°••─→ DOVECAT ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶° 
        # Additional custom jail: Dovecot authentication failures.
        # This jail demonstrates how to use multiple actions.
 #       jails.dovecot = {
 #           enabled = true;
 #           filter  = "dovecot-auth";  # custom filter defined below.
  #          logpath = "/var/log/dovecot.log";
            # Use a custom iptables rule and then log the ban event.
 #           action = ''
#                iptables-multiport[name=Dovecot, port="pop3,pop3s,imap,imaps"]
#                %(action_)s[blocktype=DROP] # reusing the built-in syntax for extra backup
#                custom-syslog
#            '';
#            backend  = "auto";
#            findtime = 600;
#            maxretry = 3; # be a bit more aggressive on Dovecot
#        };
#    };



#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
#°✶.•°••─→ ACTIONS ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶° 
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•


#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
#°✶.•°••─→ NTFY ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶° 
    environment.etc = {
        "fail2ban/action.d/ntfy.local".text = pkgs.lib.mkForce ''
            [Definition]
            norestored = true
            actionban = curl -H "Title:  banned" -d " jail banned  after  failures on $(hostname)" https://ntfy.sh/Fail2banNotifications
        '';


#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
#°✶.•°••─→ NGINX ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶° 
        # Custom filter for nginx-probe events.
        "fail2ban/filter.d/nginx-url-probe.local".text = pkgs.lib.mkForce ''
            [Definition]
            failregex = ^<HOST>.*(GET /(wp-|admin|boaform|phpmyadmin|\.env|\.git)|\.(dll|so|cfm|asp)|(\?|&)(=[A-F0-9]+)) 
            ignoreregex =
        '';

#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
#°✶.•°••─→ DOVECAT ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶° 
        # Custom filter for dovecot authentication failures.
        "fail2ban/filter.d/dovecot-auth.local".text = pkgs.lib.mkForce ''
            [Definition]
            # This pattern matches common failure messages in dovecot log entries.
            failregex = %(failregex_dovecot_auth)s
            # Example pattern: "dovecot: auth: Failed login for user=<user>, method=plain, rip=<HOST>"
            # You might need to adjust this regex based on your dovecot log format.
            ignoreregex =
        '';

#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
#°✶.•°••─→ SYSLOG ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶° 
        # Custom action to log blocked IPs to syslog.
       # "fail2ban/action.d/custom-syslog.local".text = pkgs.lib.mkForce ''
       #     [Definition]
       #     actionban = logger -t fail2ban "Banned <ip> on jail <name> after <failures> failures"
       #     actionunban = logger -t fail2ban "Unbanned <ip> on jail <name> after ban duration expired"
       # '';
        
        
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
#°✶.•°••─→ CADDY ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶° 
        # This filter is designed to catch repeated requests to potential sensitive URLs or any request patterns
        # that might indicate scanning or abuse. Adjust failregex and ignoreregex as needed based on your Caddy log format.
        "fail2ban/filter.d/caddy.local".text = pkgs.lib.mkForce ''
            [Definition]
            # Example failregex:
            # 1. Matches a GET to /admin, /config, or /.env, /.git and similar.
            # 2. Also, matching repeated 404 status codes may indicate scanning.
            # NOTE: Adjust the regex patterns based on how your Caddy server logs information.
            failregex = (?i)^ .* "(GET|POST) /(admin|config|.env|.git)(/|\b)." 404
            (?i)^ . "(GET|POST) .(&|?)((pass=)|(pwd=)|(password=))."
            ignoreregex =
        '';
    };}        


      #  "fail2ban/filter.d/vaultwarden.conf";
     #   text = ''
     #     [INCLUDES]
       #   before = common.conf

       #   [Definition]
       #   failregex = ^.*Username or password is incorrect\. Try again\. IP: <ADDR>\. Username:.*$
       #   ignoreregex =
      #    journalmatch = _SYSTEMD_UNIT=vaultwarden.service
    #    '';
   #   };

    #  gitea = {
   #     target = "fail2ban/filter.d/gitea.conf";
   #     text = ''
   #       [Definition]
  #        failregex =  .*(Failed authentication attempt|invalid credentials|Attempted access of unknown user).* from <HOST>
   #       ignoreregex =
   #       journalmatch = _SYSTEMD_UNIT=gitea.service
  #      '';
 #     };
 #   };

