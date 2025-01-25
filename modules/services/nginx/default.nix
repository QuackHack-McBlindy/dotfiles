{ config, pkgs, ... }:

{
  networking.firewall.enable = true;
  networking.firewall.allowedUDPPorts = [ 80 443 ];
  networking.firewall.allowedTCPPorts = [ ];

  # Enable NGINX
  services.nginx = {
    enable = true;

    # Define virtual hosts
    virtualHosts = {
    
      "desktop.lan" = {
     #   addSSL = true;
        sslCertificate = "/etc/ssl/certs/desktop.lan.crt";
        sslCertificateKey = "/etc/ssl/private/desktop.lan.key";
        forceSSL = true;
        root = "/var/www/desktop";
      };
     # "pungkula.duckdns.org" = {
    #    enableACME = true;  
        #addSSL = true;    
    #    forceSSL = true;    
       # root = "/var/www/example";  # Path to your website files (can be empty if proxying only)

       
        locations."/" = {
          proxyPass = "http://127.0.0.1:7888"; 
          proxyWebsockets = true; 
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
          '';  
        };
      };
    };
  };

 
  security.acme = {
    acceptTerms = true;               
    defaults.email = "foo@bar.com";     
  };
}

