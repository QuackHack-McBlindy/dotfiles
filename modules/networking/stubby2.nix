{
    services.stubby = {
        enable = true;
        logLevel = "info";
        settings = {
            
            upstream_recursive_servers = [
            {
              address_data = "1.1.1.1";  # Cloudflare DNS
              tls_auth_name = "cloudflare-dns.com";
            },
            {
              address_data = "9.9.9.9";  # Quad9 DNS
              tls_auth_name = "dns.quad9.net";
            }];

            log_level = "info";  
            logs_dir = "/var/log/stubby"; 
            timeout = 2000;  
            retries = 3;   
            retries_timeout = 2000; 

            # Security
            dnssec = "yes";
            validate_certificates = true; 
            upstream_tls_port = 853;  
        };
    };
}
