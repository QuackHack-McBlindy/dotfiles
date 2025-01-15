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
      "pungkula.duckdns.org" = {
        enableACME = true;  # Enable ACME for automatic SSL certificate generation
        #addSSL = true;      # Add SSL to the virtual host
        forceSSL = true;    # Force HTTPS (redirect HTTP to HTTPS)
       # root = "/var/www/example";  # Path to your website files (can be empty if proxying only)

        # Configure the reverse proxy to forward requests to a backend service (localhost:8080)
        locations."/" = {
          proxyPass = "http://127.0.0.1:7888";  # Forward requests to your backend service
          proxyWebsockets = true;  # If you need to support WebSockets
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
          '';  # Additional headers required by your backend
        };
      };
    };
  };

  # ACME settings for Let's Encrypt
  security.acme = {
    acceptTerms = true;                  # Agree to Let's Encrypt's terms
    defaults.email = "foo@bar.com";      # Email address for notifications
  };
}

