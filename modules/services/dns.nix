{ config, lib, ... }:

{
  services.resolved.enable = lib.mkDefault true;
  services.resolved.domains = [ "lan" ];
  # workaround for https://github.com/NixOS/nixpkgs/issues/66451
  services.resolved.dnssec = "false";
}

