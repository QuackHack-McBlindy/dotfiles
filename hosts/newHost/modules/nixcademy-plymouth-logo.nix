{ pkgs, config, lib, ... }:
let
  cfg = config.customization.plymouth-logo;

  logo = pkgs.runCommand "logo.png" { HOME = "/build"; } ''
    ${pkgs.inkscape}/bin/inkscape -w 256 -o $out ${cfg.logoPath}
  '';
  customBreeze = pkgs.plasma5Packages.breeze-plymouth.override {
    logoFile = logo;
    logoName = "Nixcademy";
    osName = "NixOS";
    osVersion = "2023";
  };
in
{
  options.customization.plymouth-logo = {
    enable = lib.mkEnableOption "Plymouth icon customization";
    logoPath = lib.mkOption {
      type = lib.types.path;
      default = ./artwork/logo-horizontal-white.svg;
      description = "Path to the logo file (SVG)";
    };
  };

  config = lib.mkIf cfg.enable {
    boot.plymouth = {
      inherit logo;
      themePackages = [ customBreeze ];
    };
  };
}
