{
  lib,
  config,
  ...
} : {

  blog = {
    enable = true;

    posts.pokenix = {
      filename    = "pokenix.html";
      title       = "pokenix";
      date        = "2026-11-17";

      header1 = "Poké";
      header2 = "Nix";
      eyebrow = "pokemon · spreadsheets · nix";


      tags = [
        "pokenix"
        "nixos"
        "nix"
        "flake"
        "pokemon"
        "spreadsheet"
      ];

      tagline = "Nix generates HTML + JS generates Nix + GitHub pages hosts ";
      description = "Nix generates HTML + JS generates Nix + GitHub pages hosts. A complete web hosting plattform and sprteadsheet manager built for Pokémon collections using Nix";

      markdownFile = ./../../home/README/pokenix.md;
      sections = [{ button = { title = "View on GitHub"; link = "https://github.com/quackhack-mcblindy/pokenix"; }; }];

    };

  };}
