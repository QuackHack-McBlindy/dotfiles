{ config, pkgs, lib, inputs, ... }:
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ NETWORKING ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
{

  networking = { 
      networkmanager.enable = true; 
      nameservers = [
          "::1"
          "127.0.0.1"
      ];
      firewall = {
          enable = true;
          logRefusedConnections = true;
          allowedUDPPorts = [ ];
          allowedTCPPorts = [ ];
      };
      hosts = {
          "192.168.1.1" = [ "router.lan" "router.local" "router" ];
          "192.168.1.111" = [ "desktop.lan" "desktop.local" "desktop" "vaultwarden.local" ];
          "192.168.1.222" = [ "laptop.lan" "laptop.local" "laptop" ];
          "192.168.1.28" = [ "nasty.lan" "nasty.local" "nasty" ];
          "192.168.1.181" = [ "ha.lan" "ha.local" "ha" ];   
      };   
      
 #     extrahosts = ''
  #      127.0.0.1   localhost
  #      192.168.1.1 router.local
  #      192.168.1.28 nasty.local
  #      192.168.1.111 desktop.local
   #     192.168.1.152 sovrum.local
   #     192.168.1.159 nas.local
  #      192.168.1.223 shield.local
  #     192.168.1.111 vaultwarden.local

 #     '';  
  };    
  
  services.resolved = {
      enable = true;
      fallbackDns = [ "2606:4700:4700::1112" "2606:4700:4700::1002" "1.1.1.2" "1.0.0.2" ];
  };

}
