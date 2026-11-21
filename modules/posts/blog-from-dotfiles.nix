# dotfiles/modules/posts/blog-from-dotfiles.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
#  » ★ QuackHack-McBLindy.com ★ «
{ # 🦆 ⮞ nuthin' to see here... (just some html generation)
  lib,
  config,
  ...
} : {

  blog = {
    enable = true;


    posts.blog-from-dotfiles = {
      title     = "Blog from Dotfiles";
      description = "Suddenly this feels a lot more like me.";
      header1   = "Writing from the";
      header2   = "Flake";
      tagline   = "Blog as a NixOS module.";
      date      = "2026-11-18";
      tags      = [ "blog" "nixos" ];
      filename  = "blog-from-dotfiles.html";


      sections = [
        { idea = "Writing these posts straight from my dotfiles repo."; }
        {
          prose = ''
            ## **Why this makes a lot of sense to Me:**

            Blog posts belong in these dotfiles because my repository already represents more than system configuration.
            It represents the entire digital environment, workflows and the knowledge behind it.
            Just as configurations document how the machines work, blog posts document the ideas, experiments, decisions and solutions that shape them.
            Keeping everything together makes the knowledge version-controlled, reproducible, searchable and available alongside the actual implementation.

            I bundled this builder to also provide a RSS feed (Atom XML).

            And honestly, having referenced source code automatically refreshed on the website whenever I rebuild my system is pretty damn. sweet.
            Change the code, rebuild the system and the published documentation follows along.

            It's another little example of how NixOS blurs the line between configuration, automation and documentation.
            Why maintain things separately when they can all be part of the same flake?
          '';
        }
        { prose = "## **What I wrote to get this webpage:**"; }
        {
          code = {
            title   = "View this post's source code.";
            lang = "nix";
            collapsed = true;
            content = builtins.readFile ./blog-from-dotfiles.nix;
          };
        }
        { prose = "## **Another example:**"; }
        {
          code = {
            title   = "View the nix file for the quackhackmcblindy.com/posts/zigduck webpage.";
            lang = "nix";
            collapsed = true;
            content = builtins.readFile ./zigduck.nix;
          };
        }
        { prose = "## **The NixOS module:**"; }
        {
          code = {
            title   = "Click to view blog.nix source code";
            lang = "nix";
            collapsed = true;
            content = builtins.readFile ./../blog.nix;
          };
        }
        { duck = "Stay safe, peace and code. QuackHack-McBLindy out!"; }
        { button = { title = "Explore my flake"; link = "https://github.com/quackhack-mcblindy/dotfiles"; }; }


      ];
    };

  };}
