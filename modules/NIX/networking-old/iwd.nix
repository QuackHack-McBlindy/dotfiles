{ 
  config,
  lib,
  ...
} : {
    config = lib.mkIf (lib.elem "iwd" config.this.host.modules.networking) {
        networking.wireless.networks."pungkula2".psk = config.sops.secrets.w.path; 
        networking.wireless.iwd = {
            enable = true;
            settings = {
                Settings = {
                    AutoConnect = true; 
                };  
            };
        };
        networking.networkmanager.wifi.backend = "iwd";
    };}
