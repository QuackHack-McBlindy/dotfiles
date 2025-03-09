{ config, pkgs, lib, inputs, ... }:
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ NETWORKING ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
{
  networking = { 
      networkmanager.enable = true; 
      nameservers = [
          "192.168.1.1"
    #      "127.0.0.1"
      ];
      firewall = {
          enable = true;
          logRefusedConnections = true;
          allowedUDPPorts = [ 6222 443 53 ];
          allowedTCPPorts = [ 6262 443 53 ];
      };
      hosts = {
          "192.168.1.1" = [ "router.lan" "router.local" "router" ];
          "192.168.1.111" = [ "desktop.lan" "desktop.local" "desktop" "vaultwarden.local" ];
          "192.168.1.211" = [ "homie.lan" "homie.local" "homie" ];
          "192.168.1.222" = [ "laptop.lan" "laptop.local" "laptop" ];
          "192.168.1.28" = [ "nasty.lan" "nasty.local" "nasty" ];
      };   
  };    
  
  services.resolved = {
      enable = true;
      fallbackDns = [ "192.168.1.1" ];
      dnsovertls = true;
   };
  
#  boot.initrd.network = {
  #  enable = true;
   # ssh = {
 #     enable = true;
 #     port = 22;
     # hostKeys = [
 

}

