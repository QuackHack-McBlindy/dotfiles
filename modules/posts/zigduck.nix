{
  lib,
  config,
  ...
} : {

  blog = {
    enable = true;

    posts.zigduck = {
      filename    = "zigduck.html";
      title       = "zigduck";
      date        = "2026-11-17";

      header1 = "NixOS and flakes";
      header2 = "Home Automation";
      eyebrow = "home-automation · zigbee · flake · smart-home";


      tags = [
        "zigduck"
        "nixos"
        "nix"
        "flake"
        "rust"
        "smart-home"
        "home-automation"
        "zigbee"
        "mqtt"
      ];

      tagline = "A Flake For Your House";
      description = "A declarative, reproducible smart-home operating system (NixOS) for people who want their home automation to be as maintainable as their infrastructure.";

      markdownFile = ./../../home/README/zigduck.md;
      sections = [{ button = { title = "View on GitHub"; link = "https://github.com/quackhack-mcblindy.com/zigduck"; }; }];

    };

  };}
