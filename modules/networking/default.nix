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
    #      allowedUDPPorts = [ ];
   #       allowedTCPPorts = [ ];
      };
      hosts = {
          "192.168.1.1" = [ "router.lan" "router.local" "router" ];
          "192.168.1.111" = [ "desktop.lan" "desktop.local" "desktop" "vaultwarden.local" ];
          "192.168.1.211" = [ "homie.lan" "homie.local" "homie" ];
          "192.168.1.222" = [ "laptop.lan" "laptop.local" "laptop" ];
          "192.168.1.28" = [ "nasty.lan" "nasty.local" "nasty" ];
      };   
  };    
  
#  services.resolved = {
 #     enable = true;
 #     fallbackDns = [ "2606:4700:4700::1112" "2606:4700:4700::1002" "1.1.1.2" "1.0.0.2" ];
 # };
  
#  boot.initrd.network = {
  #  enable = true;
   # ssh = {
 #     enable = true;
 #     port = 22;
     # hostKeys = [
 

}

