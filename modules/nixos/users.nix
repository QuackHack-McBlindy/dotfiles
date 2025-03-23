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
        #  openssh.authorizedKeys.keys = [
         #     "ssh-rsa x7qq8zRAH5jdxUduQ/ThAmvjYm91H42QVm70OCFjjb8dg9LIb/va2j1eakNlBiwCmUK7frmRkWjFj+2t5zCTd2iLpygLv7PvFVIidxAoXLdTxilAAg2ZlX/xSGvRPkaqX/ZQfR5j3OCVYy6aV4VonbIUids7kUynRz9SRN2AHmLpK/oniwlwhAS5aa0PvC8Ln7x3wzhH501sLKk+krNpOEr4E1AA/VwOMqSqU4KTMoYzkUix9YnnAf70AQV6rZ4NxNrqWcZve/UGqMxtUbxMP7rL8hxKihc0Zdus5zxDEZ36oXIDYq9kQ3KgJZx4aVPePEX68A8fxhx6zIOfsg0Hz6M3ko53MhG/qZhYmDvTG1548tgn24gQjEawRjUc2a6gEH+va+TP99260ELeWZD3AHzIzL+ln4BBGcYgNglkIxpI5gH7LqeQ+XHlW8iQbnlfRUYKo72MGA8KLDPP3IHhWa5cSN4DKBlgEJ8ijUbcYqES4dK34cqyM1JWVTnEdw== pungkula@desktop.com"
         #     "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE6UXhj/qh1qSnHdAuPyOUr0OQyJ1QIy5QlZu3y7CaGV pungkula@desktop"
         #     "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE6UXhj/qh1qSnHdAuPyOUr0OQyJ1QIy5QlZu3y7CaGV"     
         #     "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPwZL27kGTQDIlSe03abT9F24nSAizORyjo5cI3BD92s your_email@example.com"
         #     "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICLU9Ri6EVsKMHMXm1L5N0sU9qUVrQDgmC+o6vJnik9u pungis@nasty"
         # ];                  
      };
   
      users.builder = lib.mkIf (config.networking.hostName == "desktop") {
          isNormalUser = true;
          home = "/home/builder";
          shell = pkgs.bash;
          openssh.authorizedKeys.keys = [ pubkey.desktop pubkey.laptop pubkey.homie pubkey.nasty ];
          extraGroups = [ "wheel" "builders" ]; 
      }; 
 
#      users.builder = {
 #         isNormalUser = true;
  #        home = "/home/builder";
 #         shell = pkgs.bash;
#         openssh.authorizedKeys.keys = [ pubkey.desktop pubkey.laptop pubkey.homie pubkey.nasty ];
 #         extraGroups = [ "wheel" "builders" ]; 
 #     };
 
      users.caddyProxy = {
          group = "caddyProxy";
          home = "/var/lib/caddyProxy";
          createHome = true;
          isSystemUser = true;
      };

      users.caddyTor = {
          group = "caddyTor";
          home = "/var/lib/caddyTor";
          createHome = true;
          isSystemUser = true;
      };

      users.nixos = {
          group = "nixos";
          hashedPassword = "xxxx";
          isNormalUser = true;
          extraGroups = [ "wheel" ];
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

  programs.nautilus-open-any-terminal = {
      enable = true;
      terminal = "gnome-terminal";
  };

}
