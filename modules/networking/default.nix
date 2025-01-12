{ config, pkgs, lib, inputs, hostname, ... }:
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ NETWORKING ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
{
  networking = { 
      hosts = {
          "192.168.1.1" = [ "router.lan" "router.local" "router" ];
          "192.168.1.111" = [ "desktop.lan" "desktop.local" "desktop" ];
          "192.168.1.222" = [ "laptop.lan" "laptop.local" "laptop" ];
          "192.168.1.28" = [ "nasty.lan" "nasty.local" "nasty" ];
       #   "192.168.1.44" = [ "iphone.lan" "iphone.local" "iphone" ];
       #   "192.168.1.45" = [ "phone.lan" "phone.local" "phone" ];
       #   "192.168.1.150" = [ "usb.lan" "usb.local" "usb" ];
        #  "192.168.1.155" = [ "arris.lan" "arris.local" "arris" ];
       #   "192.168.1.159" = [ "pi.lan" "pi.local" "pi" ];
          "192.168.1.181" = [ "ha.lan" "ha.local" "ha" ];
       #   "192.168.1.99" = [ "sovrum.lan" "sovrum.local" "sovrum" ];
       #   "192.168.1.100" = [ "shield.lan" "shield.local" "shield" ];
       #   "192.168.1.11" = [ "sw1.lan" "sw1.local" "sw1" ];
       #   "192.168.1.12" = [ "sw2.lan" "sw2.local" "sw2" ];
          
      };   
      hostName = hostname;
      networkmanager.enable = true; 
      firewall = {
          enable = true;
          logRefusedConnections = true;
                          #      
          allowedUDPPorts = [ ];
                          #              
          allowedTCPPorts = [ ];
      };
  };    
}
