# dotfiles/modules/blog.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
#  » ★ QuackHack-McBLindy.com ★ «
{ # 🦆 ⮞ html generator
  config,
  lib,
  pkgs,
  ...
} : let
  inherit (lib)
    mkOption types mkIf mkEnableOption concatStringsSep optionalString
    mapAttrsToList sort filter;

  cfg = config.blog;

  esc = s: builtins.replaceStrings
    [ "&" "<" ">" "\"" "'" ]
    [ "&amp;" "&lt;" "&gt;" "&quot;" "&#39;" ]
    (toString s);

  wrapMatches = re: wrap: s:
    let
      parts = builtins.split re s;
      go = parts:
        if parts == [] then ""
        else
          let
            first = builtins.head parts;
            rest  = builtins.tail parts;
          in
            if builtins.isList first
              then
                let
                  captured =
                    if builtins.length first > 1
                      then builtins.elemAt first 1
                      else builtins.head first;
                in wrap captured + go rest
              else first + go rest;
    in go parts;


  renderInline = s:
    let
      code = wrapMatches "`([^`]+)`"                (c: "<code>${c}</code>");
      bold = wrapMatches "\\*\\*([^*]+)\\*\\*"      (c: "<strong>${c}</strong>");
      em   = wrapMatches "\\*([^*]+)\\*"            (c: "<em>${c}</em>");
    in em (bold (code s));

  paragraphs = text:
    filter (p: p != "")
      (map (p: lib.strings.trim p)
        (lib.splitString "\n\n" text));

  renderPara = p:
    if lib.hasPrefix "## " p then
      ''<h3 class="sub-heading">${renderInline (lib.removePrefix "## " p)}</h3>''
    else if lib.hasPrefix "> " p then
      ''<blockquote class="prose-quote">${renderInline (lib.removePrefix "> " p)}</blockquote>''
    else
      ''<p>${lib.replaceStrings [ "\n" ] [ "<br>" ] (renderInline p)}</p>'';

  renderText = text:
    concatStringsSep "\n" (map renderPara (paragraphs text));

  renderStats = stats: ''
    <div class="stat-strip">
      ${concatStringsSep "\n" (map (s: ''
        <div class="stat-tile accent-${s.accent}">
          <strong>${esc s.value}</strong>
          <span>${esc s.label}</span>
        </div>
      '') stats)}
    </div>
  '';

  renderCodeBlock = c: ''
    <div class="config-block">
      <div class="config-bar">
        <span class="dot red"></span>
        <span class="dot yellow"></span>
        <span class="dot green"></span>
        <span class="config-title">${esc c.title}</span>
        <button class="copy-btn" type="button">Copy</button>
      </div>
      <pre><code class="language-${esc c.lang}">${esc c.content}</code></pre>
    </div>
  '';

  renderSection = sec:
    if sec.prose != null then ''
      <section class="content-section">
        <div class="wrap reveal">
          <div class="prose-section">
            ${renderText sec.prose}
          </div>
        </div>
      </section>
    ''
    else if sec.html != null then sec.html
    else if sec.code != null then ''
      <section class="content-section">
        <div class="wrap reveal">
          ${renderCodeBlock sec.code}
        </div>
      </section>
    ''
    else "";

  renderCaveat = caveat: ''
    <section class="content-section">
      <div class="wrap reveal">
        <div class="caveat">
          <strong>Heads up.</strong>
          ${caveat}
        </div>
      </div>
    </section>
  '';

  renderQuote = quote: ''
    <section class="content-section">
      <div class="wrap reveal">
        <p class="big-quote">${quote}</p>
      </div>
    </section>
  '';

  renderCrossLinks = links: ''
    <section class="content-section">
      <div class="wrap reveal">
        <div class="cross-links">
          ${concatStringsSep "\n" (map (l: ''
            <a class="cross-link" href="${esc l.link}">
              <span class="cl-icon" aria-hidden="true">${l.icon}</span>
              <div class="cl-body">
                <h3 class="cl-title">${esc l.title}</h3>
                <p class="cl-desc">${l.description}</p>
              </div>
              <span class="cl-arrow" aria-hidden="true">→</span>
            </a>
          '') links)}
        </div>
      </div>
    </section>
  '';

  renderPage = _name: post: ''
    <!doctype html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <title>QuackHack-McBLindy.com » ${esc post.title} </title>
      <link rel="canonical" href="https://quackhack-mcblindy.com" />

      <meta name="google-site-verification=nfCO9B-sHuohdde9OLWBELNHyZ9ODlhIl4wC5OkituQ" />
      <meta name="viewport" content="width=device-width, initial-scale=1.0">

      <link rel="preconnect" href="https://fonts.googleapis.com">
      <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
      <!-- <link href="https://fonts.googleapis.com/css2?family=Cinzel+Decorative:wght@700;800;900&display=swap" rel="stylesheet"> -->
      <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@500;700;900&display=swap" rel="stylesheet">

      <meta property="og:type" content="website">
      <meta property="og:url" content="https://quackhack-mcblindy.com/work.html">
      <meta property="og:title" content="QuackHack-McBLindy.com">
      <meta property="og:description" content="QuackHack-McBLindy.com » Portfolio » I share code, wisdom and tells tales of NixOS flakes. » I write code related to anything. » I write texts related to tech. » Think Different. Build Bold. Quack Loud.">
      <meta name="description" content="QuackHack-McBLindy.com » Portfolio » I share code, wisdom and tells tales of NixOS flakes. » I write code related to anything. » I write texts related to tech. » Think Different. Build Bold. Quack Loud.">
      <meta property="og:image" content="https://quackhack-mcblindy.com/static/img/logo.png">

      <meta name="twitter:card" content="summary_large_image">
      <meta name="twitter:title" content="QuackHack-McBLindy.com » ${esc post.title}">
      <meta name="twitter:description" content="QuackHack-McBLindy.com » Portfolio » I share code, wisdom and tells tales of NixOS flakes. » I write code related to anything. » I write texts related to tech. » Think Different. Build Bold. Quack Loud.">
      <meta name="twitter:image" content="https://quackhack-mcblindy.com/static/img/logo.png">

      <meta name="apple-mobile-web-app-capable" content="yes">
      <meta name="apple-mobile-web-app-status-bar-style" content="default">
      <meta name="apple-mobile-web-app-title" content="🦯🦆">
      <link rel="icon" href="/static/favicon/favicon.ico" sizes="any">
      <link rel="icon" type="image/png" sizes="32x32" href="/static/favicon/favicon-32x32.png">
      <link rel="apple-touch-icon" sizes="180x180" href="/static/favicon/apple-touch-icon.png">
      <link rel="manifest" href="/site.webmanifest">




      <link rel="preconnect" href="https://fonts.googleapis.com" />
      <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
      <link href="https://fonts.googleapis.com/css2?family=Cinzel+Decorative:wght@700;800;900&family=JetBrains+Mono:wght@400;500;700&display=swap" rel="stylesheet" />


      <link rel="stylesheet" href="./../static/css/styles.css" />
      <style>${baseCss}${commonCss}${post.extraCss}</style>
      <link rel="stylesheet" href="./../static/css/viewport.css" />
    </head>
    <body data-post-link="/${post.filename}">

      <div class="duckhawk-frame" aria-hidden="true">
        <img class="frame-piece frame-header glitch hue-shift" src="./../static/img/frame/header.png" alt="" />
        <img class="frame-piece frame-left" src="./../static/img/frame/left.png" alt="" />
        <img class="frame-piece frame-right" src="./../static/img/frame/right.png" alt="" />
        <img class="frame-piece frame-bottom" src="./../static/img/frame/bottom.png" alt="" />

        <img class="frame-piece frame-header-standalone glitch hue-shift" src="./../static/img/frame/header-standalone-small.png" alt="" />

        <nav class="frame-navigation" aria-label="Main navigation">
          <a class="frame-nav-link frame-nav-home" href="https://quackhack-mcblindy.com">Me</a>
          <a class="frame-nav-link frame-nav-showcase" href="https://quackhack-mcblindy.com/work.html">Work</a>
        </nav>
      </div>

      <div id="content-glitch" class="glitch hue-shift">
        <header id="top"></header>

        <main>
          <section class="content-section hero">
            <div class="wrap reveal">
              ${optionalString (post.eyebrow != "") ''
                <div class="hero-eyebrow">${esc post.eyebrow}</div>
              ''}
              <h1 class="hero-title">
                <span class="gold">${post.header1}</span> <span class="white">${post.header2}</span>
              </h1>
              ${optionalString (post.tagline != "") ''
                <p class="hero-sub">${post.tagline}</p>
              ''}
              ${optionalString (post.heroHtml != "") post.heroHtml}
              ${optionalString (post.stats != []) (renderStats post.stats)}
            </div>
          </section>

          ${optionalString (post.text != "") ''
            <section class="content-section">
              <div class="wrap reveal">
                <div class="prose-section">
                  ${renderText post.text}
                </div>
              </div>
            </section>
          ''}

          ${concatStringsSep "\n" (map renderSection post.sections)}
          ${optionalString (post.caveat != null) (renderCaveat post.caveat)}
          ${optionalString (post.quote != null) (renderQuote post.quote)}
          ${optionalString (post.crossLinks != []) (renderCrossLinks post.crossLinks)}
          ${optionalString post.relatedPosts ''
            <section class="content-section" id="similar-section" hidden>
              <div class="wrap">
                <div class="section-head">
                  <h2><span class="gold">Related</span> <span class="white">posts</span></h2>
                </div>
                <div class="cross-links" id="similar-posts"></div>
              </div>
            </section>
          ''}

        </main>

        <footer>
          <div class="wrap footer-row">
            <div>© <span id="year"></span> <strong style="color:#d7e8e5"><span class="gold">${esc cfg.siteName}</span></strong></div>
            <div class="footer-links">
              <a href="#top">Top</a>
            </div>
          </div>
        </footer>

        <svg height="0" width="0" style="position:absolute" aria-hidden="true">
          <filter id="f1">
            <feTurbulence type="fractalNoise" baseFrequency="0 0.15" numOctaves="1" result="warp"/>
            <feDisplacementMap xChannelSelector="R" yChannelSelector="G" scale="30" in="SourceGraphic" in2="warp"/>
            <feColorMatrix type="matrix" result="red_" values="4 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0"/>
            <feOffset in="red_" dx="2" dy="0" result="red"/>
            <feColorMatrix type="matrix" in="SourceGraphic" result="blue_" values="0 0 0 0 0 0 3 0 0 0 0 0 10 0 0 0 0 1 0"/>
            <feOffset in="blue_" dx="-3" dy="0" result="blue"/>
            <feBlend mode="screen" in="red" in2="blue"/>
          </filter>
        </svg>
      </div>

      <noscript>
        <style>.reveal { opacity: 1 !important; transform: none !important; }</style>
      </noscript>

      <script>
      (function () {
        'use strict';
        const yearEl = document.getElementById('year');
        if (yearEl) yearEl.textContent = new Date().getFullYear();

        if ('IntersectionObserver' in window) {
          const io = new IntersectionObserver((entries) => {
            entries.forEach((entry) => {
              if (entry.isIntersecting) {
                entry.target.classList.add('in');
                io.unobserve(entry.target);
              }
            });
          }, { threshold: 0.12, rootMargin: '0px 0px -40px 0px' });
          document.querySelectorAll('.reveal').forEach((el) => io.observe(el));
        } else {
          document.querySelectorAll('.reveal').forEach((el) => el.classList.add('in'));
        }

        function setupRelatedPosts() {
          var section = document.getElementById('similar-section');
          var container = document.getElementById('similar-posts');
          var myLink = document.body.dataset.postLink;
          if (!section || !container || !myLink) return;

          function esc(s) {
            var d = document.createElement('div');
            d.textContent = s == null ? "" : String(s);
            return d.innerHTML;
          }

          fetch('/posts.json')
            .then(function(r) { return r.ok ? r.json() : null; })
            .then(function(posts) {
              if (!Array.isArray(posts)) return;

              var current = null;
              for (var i = 0; i < posts.length; i++) {
                try {
                  if (new URL(posts[i].link, window.location.origin).pathname === myLink) {
                    current = posts[i];
                    break;
                  }
                } catch (_) { /* skip malformed link */ }
              }

              if (!current || !Array.isArray(current.tags) || current.tags.length === 0) return;

              var scored = [];
              for (var j = 0; j < posts.length; j++) {
                var p = posts[j];
                if (p.link === current.link) continue;
                var shared = 0;
                if (Array.isArray(p.tags)) {
                  for (var k = 0; k < p.tags.length; k++) {
                    if (current.tags.indexOf(p.tags[k]) !== -1) shared++;
                  }
                }
                if (shared > 0) scored.push({ post: p, score: shared });
              }

              scored.sort(function(a, b) { return b.score - a.score; });
              scored = scored.slice(0, 3);
              if (scored.length === 0) return;

              var html = "";
              for (var m = 0; m < scored.length; m++) {
                var q = scored[m].post;
                html +=
                  '<a class="cross-link" href="' + esc(q.link) + '">' +
                    '<span class="cl-icon" aria-hidden="true">🔗</span>' +
                    '<div class="cl-body">' +
                      '<h3 class="cl-title">' + esc(q.title) + '</h3>' +
                      '<p class="cl-desc">' + esc(q.description || "") + '</p>' +
                    '</div>' +
                    '<span class="cl-arrow" aria-hidden="true">→</span>' +
                  '</a>';
              }

              container.innerHTML = html;
              section.hidden = false;
            })
            .catch(function() { /* silent */ });
        }

        setupRelatedPosts();

        document.querySelectorAll('.copy-btn').forEach((btn) => {
          btn.addEventListener('click', async () => {
            const block = btn.closest('.config-block');
            const code = block ? block.querySelector('pre code') : null;
            if (!code) return;
            try {
              await navigator.clipboard.writeText(code.textContent);
              btn.textContent = 'Copied ✓';
              setTimeout(() => { btn.textContent = 'Copy'; }, 1500);
            } catch (_) {
              btn.textContent = 'Failed';
            }
          });
        });
      })();
      </script>
    </body>
    </html>
  '';


  baseCss = ''
    :root {
      --bg: #050707; --panel: #0b1110; --panel2: #0e1716;
      --teal: #11e6d2; --teal2: #05a99f;
      --gold: #f4b52f; --gold2: #ffdc72;
      --green: #5eea8f; --red: #ff5470; --pink: #ff7ab8;
      --purple: #b392ff; --blue: #6cb4ff;
      --text: #f3fffd; --muted: #8ea6a3;
      --line: rgba(17, 230, 210, .16);
      --max: 1180px;
      --frame-header-h: 260px; --frame-bottom-h: 64px;
      --frame-left-w: 190px; --frame-right-w: 196px;
      --frame-z: 10000;
      --mask-left-w: 214px; --mask-right-w: 214px;
    }
    * { box-sizing: border-box; }
    html { scroll-behavior: smooth; }
    body {
      margin: 0;
      background:
        radial-gradient(circle at 50% -10%, rgba(0, 221, 204, .10), transparent 34rem),
        radial-gradient(circle at 90% 45%, rgba(244, 181, 47, .07), transparent 28rem),
        var(--bg);
      color: var(--text);
      font-family: Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
      line-height: 1.5;
      overflow-x: hidden;
    }
    body::before {
      content: "";
      position: fixed; inset: 0; z-index: -1;
      background:
        radial-gradient(circle at 20% 80%, rgba(17, 230, 210, .08), transparent 40%),
        radial-gradient(circle at 80% 20%, rgba(244, 181, 47, .08), transparent 40%);
      animation: aurora 20s ease-in-out infinite alternate;
      pointer-events: none;
    }
    @keyframes aurora {
      0%   { opacity: .5; transform: scale(1); }
      100% { opacity: 1;  transform: scale(1.15); }
    }
    a { color: inherit; text-decoration: none; }
    .wrap { width: min(calc(100vw - var(--mask-left-w) - var(--mask-right-w) - 40px), var(--max)); margin: auto; }
    .gold { color: var(--gold); } .white { color: #fff; } .muted { color: var(--muted); }
    .teal { color: var(--teal); } .green { color: var(--green); } .pink { color: var(--pink); }
    .purple { color: var(--purple); } .red { color: var(--red); } .blue { color: var(--blue); }

    #top {
      min-height: 0 !important;
      height: 0 !important;
      padding: 0 !important;
      margin: 0 !important;
      overflow: hidden;
    }
    #top::before { display: none !important; }

    main {
      padding-top: calc(var(--frame-header-h) + 20px);
      padding-bottom: calc(var(--frame-bottom-h) + 20px);
    }
    .content-section { padding: 20px 0 50px; }

    .reveal { opacity: 0; transform: translateY(22px); transition: .7s ease; }
    .reveal.in { opacity: 1; transform: none; }

    footer { padding: 26px 0 34px; border-top: 1px solid var(--line); }
    .footer-row {
      display: flex; justify-content: space-between; align-items: center;
      gap: 16px; flex-wrap: wrap; color: var(--muted); font-size: .92rem;
    }
    .footer-links a { color: var(--teal); transition: color .2s ease; }
    .footer-links a:hover { color: var(--gold); }

    .glitch { animation: glitch 3s linear infinite; }
    @keyframes glitch {
      0%, 4%, 8%, 12%, 100% { filter: none; }
      1%, 5%, 9% { filter: url(#f1); }
    }
    .hue-shift { animation: hueshift 45s ease-in-out infinite; }
    @keyframes hueshift {
      0%, 50% { filter: hue-rotate(0deg); }
      60% { filter: hue-rotate(360deg); }
      70% { filter: hue-rotate(0deg); }
      80% { filter: hue-rotate(360deg); }
      90% { filter: hue-rotate(0deg); }
      100% { filter: hue-rotate(360deg); }
    }


    @media (max-width: 1199px), (max-height: 699px) {
        main {
            padding-top: calc(var(--frame-header-h, 260px) + 20px) !important;
            padding-bottom: calc(var(--frame-bottom-h, 64px) + 20px) !important;
        }
    }

    @media (min-width: 3440px),
           (min-aspect-ratio: 1/2) and (max-aspect-ratio: 9/16) {
        main {
            padding-top: 20px !important;
            padding-bottom: 24px !important;
        }
    }

    @media (prefers-reduced-motion: reduce) {
      *, *::before, *::after {
        animation-duration: .001ms !important;
        animation-iteration-count: 1 !important;
        transition-duration: .001ms !important;
        scroll-behavior: auto !important;
      }
      .reveal { opacity: 1; transform: none; }
      body::before { animation: none; opacity: .6; }
      .glitch, .hue-shift { animation: none !important; }
    }
  '';

  commonCss = ''
    .hero { text-align: center; padding: 30px 0 50px; }
    .hero-eyebrow {
      display: inline-flex; align-items: center; gap: 10px;
      padding: 6px 16px; background: rgba(17, 230, 210, .06);
      border: 1px solid rgba(17, 230, 210, .3); border-radius: 999px;
      font-family: "JetBrains Mono", monospace; font-size: .76rem;
      letter-spacing: .14em; text-transform: uppercase;
      color: var(--teal); margin-bottom: 24px;
    }
    .hero-title {
      font-family: "Cinzel Decorative", Georgia, serif;
      font-size: clamp(2rem, 6vw, 3.4rem);
      line-height: 1.1; letter-spacing: -.02em; margin: 0 0 22px;
    }
    .hero-sub {
      font-size: clamp(1.02rem, 1.8vw, 1.15rem);
      color: var(--muted); max-width: 680px;
      margin: 0 auto 28px; line-height: 1.65;
    }
    .hero-sub code {
      color: var(--gold2); background: rgba(244,181,47,.08);
      padding: 1px 6px; border-radius: 4px;
      font-family: "JetBrains Mono", monospace; font-size: .9em;
    }

    .stat-strip {
      display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
      gap: 14px; max-width: 1000px; margin: 0 auto;
    }
    .stat-tile {
      background: linear-gradient(180deg, var(--panel2), var(--panel));
      border: 1px solid var(--line); border-radius: 16px;
      padding: 22px 16px; text-align: center;
      transition: border-color .25s ease, transform .25s ease;
    }
    .stat-tile:hover { border-color: rgba(17,230,210,.35); transform: translateY(-2px); }
    .stat-tile strong {
      display: block; font-family: "Cinzel Decorative", Georgia, serif;
      font-size: clamp(1.4rem, 3vw, 1.9rem); color: var(--gold2);
      letter-spacing: -.01em; line-height: 1; margin-bottom: 8px;
    }
    .stat-tile span {
      color: var(--muted); font-size: .74rem; letter-spacing: .06em;
      text-transform: uppercase; font-family: "JetBrains Mono", monospace;
    }
.stat-tile.accent-teal strong   { color: var(--teal); }
.stat-tile.accent-gold strong   { color: var(--gold); }
.stat-tile.accent-gold2 strong  { color: var(--gold2); }
.stat-tile.accent-green strong  { color: var(--green); }
.stat-tile.accent-pink strong   { color: var(--pink); }
.stat-tile.accent-purple strong { color: var(--purple); }
.stat-tile.accent-blue strong   { color: var(--blue); }
.stat-tile.accent-red strong    { color: var(--red); }

    .prose-section { max-width: 720px; margin: 0 auto; }
    .prose-section p {
      color: #c9dbd8; font-size: 1rem; line-height: 1.75; margin: 0 0 16px;
    }
    .prose-section p:last-child { margin-bottom: 0; }
    .prose-section strong { color: var(--gold2); font-weight: 700; }
    .prose-section em { color: var(--gold2); font-style: italic; }
    .prose-section code {
      color: var(--gold2); background: rgba(244,181,47,.08);
      padding: 1px 6px; border-radius: 4px;
      font-family: "JetBrains Mono", monospace; font-size: .9em;
    }
    .sub-heading {
      font-family: "Cinzel Decorative", Georgia, serif;
      font-size: clamp(1.15rem, 2.2vw, 1.4rem); color: var(--teal);
      margin: 32px 0 14px; letter-spacing: .01em;
    }
    .prose-quote {
      margin: 24px 0;
      padding: 14px 20px 14px 24px;
      border-left: 3px solid var(--teal);
      background: rgba(17,230,210,.04);
      border-radius: 0 10px 10px 0;
      color: #c9dbd8; font-size: 1rem; line-height: 1.7;
      font-style: italic;
    }

    .caveat {
      max-width: 760px; margin: 0 auto;
      padding: 18px 22px;
      background: rgba(255,84,112,.04);
      border: 1px solid rgba(255,84,112,.2);
      border-left: 3px solid var(--red);
      border-radius: 10px;
      color: #c9dbd8; font-size: .95rem; line-height: 1.7;
    }
    .caveat strong {
      color: var(--red); font-weight: 700;
      display: inline-flex; align-items: center; gap: 6px;
    }
    .caveat strong::before { content: "⚠"; font-size: 1.05em; }
    .caveat code {
      color: var(--gold2); background: rgba(244,181,47,.08);
      padding: 1px 5px; border-radius: 3px;
      font-family: "JetBrains Mono", monospace; font-size: .9em;
    }

    .big-quote {
      font-family: "Cinzel Decorative", Georgia, serif;
      font-size: clamp(1.15rem, 2.4vw, 1.4rem); line-height: 1.5;
      text-align: center; color: var(--gold2);
      margin: 20px auto; max-width: 700px; padding: 0 20px;
    }
    .big-quote::before, .big-quote::after {
      content: ""; display: block; width: 60px; height: 1px;
      background: linear-gradient(90deg, transparent, var(--teal), transparent);
      margin: 0 auto;
    }
    .big-quote::before { margin-bottom: 20px; }
    .big-quote::after { margin-top: 20px; }
    .big-quote strong { color: var(--teal); font-style: italic; }

    .cross-links {
      display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
      gap: 16px; max-width: 900px; margin: 0 auto;
    }
    .cross-link {
      display: flex; align-items: center; gap: 16px;
      padding: 20px 22px;
      background: linear-gradient(180deg, var(--panel2), var(--panel));
      border: 1px solid var(--line); border-radius: 14px;
      transition: border-color .25s ease, transform .25s ease;
    }
    .cross-link:hover { border-color: rgba(17,230,210,.4); transform: translateY(-2px); }
    .cross-link .cl-icon { font-size: 1.8rem; flex: 0 0 auto; }
    .cross-link .cl-body { flex: 1; min-width: 0; }
    .cross-link .cl-title {
      font-family: "Cinzel Decorative", Georgia, serif;
      font-size: 1rem; color: var(--gold2);
      margin: 0 0 3px; letter-spacing: .02em;
    }
    .cross-link .cl-desc {
      color: var(--muted); font-size: .85rem;
      margin: 0; line-height: 1.5;
    }
    .cross-link .cl-desc code {
      color: var(--gold2); background: rgba(244,181,47,.08);
      padding: 1px 5px; border-radius: 3px;
      font-family: "JetBrains Mono", monospace; font-size: .9em;
    }
    .cross-link .cl-arrow {
      color: var(--teal); font-family: "JetBrains Mono", monospace;
      font-size: 1.2rem; flex: 0 0 auto;
      transition: transform .2s ease;
    }
    .cross-link:hover .cl-arrow { transform: translateX(4px); }

    .config-block {
      background: #080d0c; border: 1px solid var(--line);
      border-radius: 18px; overflow: hidden;
      box-shadow: 0 22px 70px rgba(0,0,0,.55); margin-bottom: 20px;
    }
    .config-bar {
      display: flex; align-items: center; gap: 8px;
      padding: 11px 16px;
      background: linear-gradient(180deg, #101a18, #0b1110);
      border-bottom: 1px solid var(--line);
    }
    .config-bar .dot { width: 12px; height: 12px; border-radius: 50%; flex: 0 0 auto; }
    .config-bar .dot.red    { background: #ff5f57; }
    .config-bar .dot.yellow { background: #febc2e; }
    .config-bar .dot.green  { background: #28c840; }
    .config-bar .config-title {
      margin-left: 10px; color: var(--muted);
      font-family: "JetBrains Mono", monospace; font-size: .82rem; flex: 1;
      overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
    }
    .config-bar .copy-btn {
      appearance: none; border: 1px solid var(--line);
      background: rgba(17,230,210,.07); color: var(--teal);
      font: inherit; font-size: .78rem; font-weight: 700;
      letter-spacing: .06em; text-transform: uppercase;
      padding: 6px 14px; border-radius: 8px; cursor: pointer;
      transition: background .2s ease, border-color .2s ease;
    }
    .config-bar .copy-btn:hover {
      background: rgba(17,230,210,.15); border-color: rgba(17,230,210,.4);
    }
    .config-block pre {
      margin: 0; padding: 22px 24px; overflow-x: auto;
      font-family: "JetBrains Mono", "Fira Code", monospace;
      font-size: 13px; line-height: 1.6; color: #d9ece9;
      -webkit-font-smoothing: antialiased;
    }
    .config-block code { font: inherit; color: inherit; }

    @media (max-width: 560px) {
      .config-block pre { padding: 18px 16px; font-size: 12px; }
    }

    .section-head {
      display: flex; align-items: center; gap: 16px;
      margin: 0 0 26px; justify-content: center; flex-wrap: wrap;
    }
    .section-head h2 {
      font-family: "Cinzel Decorative", Georgia, serif;
      font-size: clamp(1.4rem, 3.2vw, 1.9rem);
      margin: 0; letter-spacing: -.01em; text-align: center;
    }
  '';

  postFiles = lib.mapAttrs' (name: post:
    lib.nameValuePair post.filename
      (pkgs.writeText post.filename (renderPage name post))
  ) cfg.posts;

  sortedPosts = sort (a: b:
    if a.date != b.date then a.date > b.date
    else a._name < b._name
  ) (mapAttrsToList (name: p: p // { _name = name; }) cfg.posts);

  postsJson = pkgs.writeText "posts.json" (builtins.toJSON (map (p: {
    title = p.title;
    description = if p.description != null then p.description else p.tagline;
    tags = p.tags;
    date = p.date;
    link = "${cfg.baseUrl}/${p.filename}";
  }) sortedPosts));


  html = pkgs.runCommand "blog-html" { } ''
    mkdir -p $out
    ${concatStringsSep "\n" (mapAttrsToList (name: f: "cp ${f} $out/${name}") postFiles)}
    cp ${postsJson} $out/posts.json
  '';

in {


  options.blog = {
    enable = mkEnableOption "blog post generator";

    baseUrl = mkOption {
      type = types.str;
      default = "https://quackhack-mcblindy.com";
      description = "Base URL for canonical links and posts.json entries.";
    };

    siteName = mkOption {
      type = types.str;
      default = "QuackHack-McBlindy.com";
      description = "Site name in titles, og:site_name, and footer.";
    };

    html = mkOption {
      type = types.package;
      readOnly = true;
      description = "Generated site directory (HTML files + posts.json).";
    };

    posts = mkOption {
      default = { };
      description = "Blog posts. Each attribute name becomes the filename (unless overridden).";
      type = types.attrsOf (types.submodule ({ name, ... }: {
        options = {
          title = mkOption {
            type = types.str;
            description = "Page title (head <title>, og:title).";
          };
          header1 = mkOption {
            type = types.str;
            description = "First line of the hero heading (gold). Inline HTML allowed.";
          };
          header2 = mkOption {
            type = types.str;
            description = "Second line of the hero heading (white). Inline HTML allowed.";
          };
          eyebrow = mkOption {
            type = types.str;
            default = "";
            description = "Small pill above the hero heading (plain text).";
          };
          tagline = mkOption {
            type = types.str;
            default = "";
            description = "Subtitle under the hero heading. Inline HTML allowed.";
          };
          heroHtml = mkOption {
            type = types.lines;
            default = "";
            description = ''
              Optional HTML rendered inside the hero, between the tagline and
              the stats strip. Use for big-number displays, custom hero
              graphics, or anything that needs to sit above the stats.
            '';
          };
          description = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Description for posts.json (falls back to tagline).";
          };
          text = mkOption {
            type = types.lines;
            default = "";
            description = ''
              Main body. Blank lines split paragraphs. A paragraph starting
              with "## " becomes an h3. A paragraph starting with "> " becomes
              a quote. Inline HTML is allowed. Use <code>, <strong>, <em>
              freely.
            '';
          };
          stats = mkOption {
            type = types.listOf (types.submodule {
              options = {
                value = mkOption { type = types.str; };
                label = mkOption { type = types.str; };
                accent = mkOption {
                  type = types.enum [ "teal" "gold" "gold2" "green" "pink" "purple" "blue" "red" ];
                  default = "teal";
                };
              };
            });
            default = [ ];
            description = "Optional stat tiles under the hero.";
          };
          sections = mkOption {
            type = types.listOf (types.submodule {
              options = {
                prose = mkOption { type = types.nullOr types.lines; default = null; };
                html = mkOption { type = types.nullOr types.str; default = null; };
                code = mkOption {
                  type = types.nullOr (types.submodule {
                    options = {
                      content = mkOption { type = types.lines; };
                      title = mkOption { type = types.str; default = ""; };
                      lang = mkOption { type = types.str; default = "nix"; };
                    };
                  });
                  default = null;
                };
              };
            });
            default = [ ];
            description = "Optional rich sections between text and caveat.";
          };
          caveat = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Warning box (HTML allowed).";
          };
          quote = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Big closing quote (HTML allowed).";
          };
          crossLinks = mkOption {
            type = types.listOf (types.submodule {
              options = {
                title = mkOption { type = types.str; };
                description = mkOption { type = types.str; };
                link = mkOption { type = types.str; };
                icon = mkOption { type = types.str; default = "→"; };
              };
            });
            default = [ ];
          };
          relatedPosts = mkOption {
            type = types.bool;
            default = true;
            description = "Automatically show up to 3 related posts (by shared tags) below the crossLinks section.";
          };
          extraCss = mkOption {
            type = types.lines;
            default = "";
            description = "Per-post CSS additions.";
          };
          filename = mkOption {
            type = types.str;
            default = "${name}.html";
            description = "Output filename (with .html).";
          };
          tags = mkOption {
            type = types.listOf types.str;
            default = [ ];
          };
          date = mkOption {
            type = types.str;
            description = "ISO date (YYYY-MM-DD). Used for sorting in posts.json.";
          };
        };
      }));
    };
  };

  config = mkIf cfg.enable {
    blog.html = html;
    copy =
      lib.mapAttrs'
        (name: post:
          lib.nameValuePair "QuackHack-McBlindy.com/posts/${post.filename}"
            "${config.blog.html}/${post.filename}")
        config.blog.posts;

  };}
