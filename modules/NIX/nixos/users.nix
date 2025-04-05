{ config, pkgs, lib, inputs, user, ... }:

let 
  user = "pungkula";
  pubkey = import ./../../hosts/pubkeys.nix;
in
{

  users = {
      defaultUserShell = pkgs.bash; 
      groups = {

          "${user}" = { };
          nixos = {};
          caddyProxy = {};
          caddyTor = {};
          tor = {};
          secretservice = { };
      };
      mutableUsers = false;   
      #extraUsers.root.hashedPassword = "$y$j9T$m8hPD36i1VMaO5rurbZ4j0$KpzQyat.F6NoWFKpisEj77TvpN2wBGB8ezd26QoKDj6";   

      users.root = {
          hashedPassword = "*";
      };
   
      users."${user}" = {
          hashedPassword = "$y$j9T$m8hPD36i1VMaO5rurbZ4j0$KpzQyat.F6NoWFKpisEj77TvpN2wBGB8ezd26QoKDj6";
          isNormalUser = true;
          description = "${user}";
          group = "${user}";
          extraGroups = [ "networkmanager" "wheel" "dialout" "docker" "dockeruser" ];
          packages = with pkgs; [ ];             
      };
   
      users.builder = lib.mkIf (config.networking.hostName == "desktop") {
          isNormalUser = true;
          home = "/root";
          shell = pkgs.bash;
          openssh.authorizedKeys.keys = [ pubkey.desktop pubkey.laptop pubkey.homie pubkey.nasty ];
          extraGroups = [ "wheel" "builders" ]; 
      }; 
 
      users.caddyProxy = lib.mkIf (config.networking.hostName == "nasty") {
          group = "caddyProxy";
          home = "/var/lib/caddyProxy";
          createHome = true;
          isSystemUser = true;
      };

      users.caddyTor = lib.mkIf (config.networking.hostName == "nasty") {
          group = "caddyTor";
          home = "/var/lib/caddyTor";
          createHome = true;
          isSystemUser = true;
      };
 
      users.tor = {
          group = "tor";
          home = "/var/lib/tor";
          createHome = true;
          isSystemUser = true;
          uid = config.ids.uids.tor;
      };

      users.secretservice = {
          home = "/var/lib/secretservice";
          createHome = true;
          isSystemUser = true;
          group = "secretservice";
      };    
  };

  security.sudo = lib.mkIf (config.networking.hostName == "desktop") {
    enable = true;
    extraRules = [
      {
        users = [ "builder" ];
        commands = [
          {
            command = "${pkgs.nix}/bin/nix";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };


  programs.nautilus-open-any-terminal = {
      enable = true;
      terminal = "gnome-terminal";
  };

}
