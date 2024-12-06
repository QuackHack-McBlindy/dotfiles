{ config, pkgs, lib, ... }:

let
  pubkey = import ./pubkey.nix;
in
{
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = lib.mkDefault false;
    };
  };

  users.extraUsers.root.openssh.authorizedKeys.keys = lib.mkDefault [ pubkey.davidak ];
}

