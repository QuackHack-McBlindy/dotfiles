# dotfiles/modules/posts/template.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
#  » ★ QuackHack-McBLindy.com ★ «
{ # 🦆 ⮞ nuthin' to see here... (just some html generation)
  lib,
  config,
  ...
} : {

  blog = {
    enable   = true;
    baseUrl  = "https://quackhack-mcblindy.com";
    siteName = "QuackHack-McBlindy.com";

    posts.template-example = {


      filename = "template-example.html";
      date     = "2025-06-01";
      tags     = [ "template" "demo" ];

      title       = "Every Option, One Post";
      description = "A reference post with every option enabled.";


      eyebrow = "Reference · Module · Template";
      header1 = "Every";
      header2 = "Option";

      tagline = "A single post exercising every <code>blog.posts</code> field.";

      heroHtml = ''
        <p class="hero-sub">
          Use this slot for big numbers, custom graphics, or anything
          that needs to sit above the stats strip.
        </p>
      '';


      stats = [
        { value = "8";  label = "fields";   accent = "teal";   }
        { value = "16"; label = "options";  accent = "gold";   }
        { value = "3";  label = "sections"; accent = "green";  }
        { value = "∞";  label = "combos";   accent = "pink";   }
        { value = "1";  label = "caveat";   accent = "purple"; }
        { value = "1";  label = "quote";    accent = "blue";   }
        { value = "3";  label = "links";    accent = "red";    }
        { value = "0";  label = "regrets";  accent = "gold2";  }
      ];

      text = ''
        Plain paragraph. Blank lines split paragraphs.

        ## A sub-heading

        Text after a heading. You can use **bold**, *italic*, and `inline code`.

        > A blockquote that lives inside prose.

        Final paragraph before sections.
      '';


      sections = [

        {
          prose = ''
            ## Prose section

            A `sections` entry with `prose = …` renders exactly like `text`,
            just below the body and above any quote/caveat.
          '';
        }

        {
          code = {
            title   = "modules/example.nix";   # filename shown in the fake terminal bar
            lang    = "nix";                   # <code class="language-…">
            content = ''
              { pkgs, ... }: {
                environment.systemPackages = with pkgs; [
                  hello
                  cowsay
                ];
              }
            '';
          };
        }

        {
          html = ''
            <section class="content-section">
              <div class="wrap reveal">
                <p class="big-quote">
                  Any HTML goes here. <strong>Style it with extraCss.</strong>
                </p>
              </div>
            </section>
          '';
        }
      ];

      caveat = ''
        This box is for warnings — "things that will bite you" — not
        general notes. Inline HTML allowed.
      '';

      quote = "One line that lands. <strong>Emphasis optional.</strong>";

      crossLinks = [
        {
          title       = "First Link";
          description = "Card subtitle. <code>Inline HTML</code> ok.";
          link        = "other-page.html";
          icon        = "🦆";                 # default is "→"
        }
        {
          title       = "Second Link";
          description = "Same fields, different values.";
          link        = "https://example.com";
          icon        = "🔗";
        }
        {
          title       = "Third Link";
          description = "No icon → default arrow.";
          link        = "third.html";
          # icon = "→";                        # uncomment to override
        }
      ];


      relatedPosts = true;

      extraCss = ''
        .hero-sub { color: var(--gold2); }
        /* Scope selectors so you don't leak into other posts. */
      '';
    };

  };}
