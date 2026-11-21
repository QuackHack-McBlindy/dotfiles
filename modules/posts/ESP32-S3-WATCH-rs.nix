{
  lib,
  config,
  ...
} : {

  blog = {
    enable = true;

    posts.ESP32-S3-WATCH-rs = {
      filename    = "ESP32-S3-WATCH-rs.html";
      title       = "Smart-watch operating system on ESP32-S3 microcontroller.";
      date        = "2026-11-17";

      header1 = "Rust Operating System";
      header2 = "on ESP32-S3 smmart watch";
      eyebrow = "home-automation · esp32 · voice-assistant · smart-watch";


      tags = [
        "esp32"
        "rust"
        "nix"
        "flake"
        "rust"
        "smart-watch"
        "home-automation"
        "yo"
        "zigduck"
      ];

      tagline = "ESP32-S3-AMOLED WaveShare";
      description = "Bare Metal (no-std) voice-driven wearable OS for ESP32-S3 smartwatch with a high focus on accessibility and smart home/media control. Written in Rust, using esp-hal as it's hardware abstraction layer.";

      markdownFile = ./../../home/README/ESP32-S3-WATCH-rs.md;
      sections = [{ button = { title = "View on GitHub"; link = "https://github.com/quackhack-mcblindy/ESP32-S3-WATCH-rs"; }; }];

    };

  };}
