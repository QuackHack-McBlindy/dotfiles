{

  networking.wireless.networks."pungkula2".psk = config.sops.secrets.w.path;; 
  networking.wireless.iwd = {
    enable = true;
    settings = {
   #   General.AddressRandomization = "once";
   #   General.AddressRandomizationRange = "full";
      Settings = {
        AutoConnect = true; };
      };  
  };

  # if network manager is used
  networking.networkmanager.wifi.backend = "iwd";
  
}
