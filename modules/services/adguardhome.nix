
{
networking.firewall.allowedTCPPorts = [ 53 3005 ];
networking.firewall.allowedUDPPorts = [ 53 3005 ];
  
  services.adguardhome = {
    enable = true;
    settings = {
      http = {
        # You can select any ip and port, just make sure to open firewalls where needed
        address = "http://localhost:3005";
      };
      dns = {
        upstream_dns = [

          "127.0.0.1:5335"
        #  "149.112.112.112"
        ];
      };
      filtering = {
        protection_enabled = true;
        filtering_enabled = true;

        parental_enabled = false;  
        safe_search.enabled = false;  
      };
      # The following notation uses map
      # to not have to manually create {enabled = true; url = "";} for every filter
      # This is, however, fully optional
      filters = map(url: { enabled = true; url = url; }) [
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt"  # The Big List of Hacked Malware Web Sites
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt"  # malicious url blocklist
        "https://raw.githubusercontent.com/lassekongo83/Frellwits-filter-lists/master/Frellwits-Swedish-Hosts-File.txt"
        "https://raw.githubusercontent.com/QuackHack-McBlindy/dotfiles/refs/heads/main/home/.blocklist.txt" 
      ];
    };
  };
}
