# dotfiles/modules/posts/default.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
#  » ★ QuackHack-McBLindy.com ★ «
{ # 🦆 ⮞ nuthin' to see here... (just some html generation)
  lib,
  pkgs,
  config,
  ...
} : {

  blog = {
    enable   = true;
    postsJson =
      (map (name:
        let p = config.blog.posts.${name};
        in {
          title       = p.title;
          description = if p.description != null then p.description else p.tagline;
          tags        = p.tags;
          date        = p.date;
          link        = "https://quackhack-mcblindy.com/posts/${p.filename}";
        }
      ) [ # 🦆 ⮞ post names only entry
        "pokenix"
        "ESP32-S3-WATCH-rs"
        "zigduck"
        "reverse-engineering-the-swedish-hockey-league"
        "blog-from-dotfiles"
        "accessibility-on-linux"
        "tor-in-a-shell"
      ])
      ++ [
        {
          title       = "A Unique Milestone Reached";
          description = "yo crossed one billion generated phrases. 8,043 patterns, 97 ms average across 1,467 runs, it's just another day typing grammar.";
          tags        = [ "yo" "nlp" "nix" "milestone" ];
          date        = "2026-11-09";
          link        = "https://quackhack-mcblindy.com/posts/one-billion-understandable-phrases.html";
        }

        {
          title       = "From Commit to Release";
          description = "My typical workflow working with various flake projects - the general public-project pipeline with CHANGELOG, PR gate, and semver tagging.";
          tags        = [ "nixos" "nix" "workflow" ];
          date        = "2026-11-10";
          link        = "https://quackhack-mcblindy.com/posts/project-workflow.html";
        }

        {
          title       = "Hardware";
          description = "pictures of my current servers and some unique builds I have done over the years.";
          tags        = [ "hardware" "builds" "images" ];
          date        = "2026-10-06";
          link        = "https://quackhack-mcblindy.com/posts/hardware.html";
        }

        {
          title       = "QuackHack-McBlindy.com";
          description = "I moved.. again.. i think a website should tell a story. does this one tell it good?";
          tags        = [ "namecheap" ];
          date        = "2026-10-05";
          link        = "";
        }

        {
          title       = "NixOS";
          description = "Should I write smart stuff about NixOS here? Ok.";
          tags        = [ "nixos" ];
          date        = "2026-10-05";
          link        = "";
        }

        {
          title       = "Building a complete NLP with only Bash & Nix + jq";
          description = "Writing prototypes with as few dependencies as possible.";
          tags        = [ "bash" "nix" "nlp" "yo" "voice-assistant" ];
          date        = "2025-09-09";
          link        = "https://quackhack-mcblindy.github.io/blog/";
        }
      ];

  };}
