# dotfiles/modules/posts/accessibility-on-linux.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
#  » ★ QuackHack-McBLindy.com ★ «
{ # 🦆 ⮞ nuthin' to see here... (just some html generation)
  lib,
  config,
  ...
} : {

  blog = {
    enable = true;


    posts.accessibility-on-linux = {
      title     = "Accessibility on Linux / NixOS";
      description = "Linux should be for everyone, not just people without disabilities. Accessibility on NixOS is terrible out of the box - here's my magnifier flake and a voice-to-shell translator.";
      header1   = "Accessibility on";
      header2   = "Linux / NixOS";
      eyebrow   = "Accessibility";
      tagline   = "";
      date      = "2026-11-14";
      tags      = [ "accessibility" "nixos" "gnome" "linux" "magnifier" "zoom" ];
      filename  = "accessibility-on-linux.html";

      text = ''
        I have a pretty strong opinion about this.
        Linux should be for everyone, not just people without disabilities.
        People with disabilities deserve the same freedom, opportunities, and ability to use technology as everyone else.
        Accessibility should be considered an important part of the Linux community rather than something overlooked or treated as an afterthought. Technology should empower people, not put unnecessary barriers between them and the things they want to do.

        To be honest, accessibility on Linux is kind of terrible.
        Since I started using NixOS I have been using the built-in GNOME magnifier, which is great that it exists but it really caused me to pull my hair out every single day.

        I made this **flake** for the next blind friend who comes along and wants to be part of our community.
        It would be nice if that friend could keep his hair.

        I'm not saying this is the best magnifier possible, but compared to the built-in GNOME magnifier this has been a complete game-changer for me.

        I simply hope it can help someone out there.

        ## Magnixify

        <a href="https://github.com/QuackHack-McBlindy/magnixify-gnome-shell-extension">https://github.com/QuackHack-McBlindy/magnixify-gnome-shell-extension</a>

        Oh and maybe voice-to-shell-command translator would also fit within the scope of accessibility.
        If there is interest there are the flake <a href="https://github.com/QuackHack-McBlindy/yo">yo</a> and with scripts like `chain`, `if`, `while`, `until` and `state` it didn't take me too long to write grammar for over 70 scripts which resolves parameters for over one billion phrases.


      '';

      sections = [
        { duck = "Stay safe, peace and code. QuackHack out!"; }
      ];
    };

  };}
