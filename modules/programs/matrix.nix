# dotfiles/modules/programs/matrix.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ matrix configuration
  config,
  lib,
  pkgs,
  ...
} : with lib;
let
  cfg = config.this.host.modules.programs;
  matrixDomain = "localhost";
  matrixAddress = "http://127.0.0.1:8008/";

  bridgePermissions = {
    "*" = "relay";
    "localhost" = "user";
    "@admin:localhost" = "admin";
  };
in {

  config = lib.mkIf (lib.elem "matrix" cfg) {
    environment.systemPackages = [
      pkgs.cinny
    ];

  };}
