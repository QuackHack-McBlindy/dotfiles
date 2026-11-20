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

  tagsToKeywords = tags:
    concatStringsSep ", " (map (t: "\"${t}\"") tags);

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
    <div class="config-block${optionalString c.collapsed " is-collapsed"}">
      <div class="config-bar">
        <span class="dot red"></span>
        <span class="dot yellow"></span>
        <span class="dot green"></span>

        <span class="config-title">${esc c.title}</span>

        <button
          class="collapse-btn"
          type="button"
          aria-expanded="${if c.collapsed then "false" else "true"}"
        >${if c.collapsed then "Expand" else "Collapse"}</button>

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
    else if sec.warning != null then ''
      <section class="content-section">
        <div class="wrap reveal">
          ${renderWarning { content = sec.warning; }}
        </div>
      </section>
    ''
    else if sec.quote != null then ''
      <section class="content-section">
        <div class="wrap reveal">
          ${renderQuote { content = sec.quote; }}
        </div>
      </section>
    ''
    else if sec.duck != null then ''
      <section class="content-section">
        <div class="wrap reveal">
          ${renderDuck { content = sec.duck; }}
        </div>
      </section>
    ''
    else if sec.idea != null then ''
      <section class="content-section">
        <div class="wrap reveal">
          <div class="prose-section">
            ${renderIdea { content = sec.idea; }}
          </div>
        </div>
      </section>
    ''
    else "";

  renderCallout = { className, icon ? "", label ? null, content }:
    ''
      <div class="${className}">
        ${optionalString (label != null) ''<strong>${icon} ${label}</strong>''}
        ${renderText content}
      </div>
    '';

  renderWarning = section:
    renderCallout {
      className = "warning";
      icon = "";
      label = "Heads up!";
      content = section.content;
    };

  renderDuck = section:
    renderCallout {
      className = "duck-comment";
      content = section.content;
    };

  renderIdea = section:
    renderCallout {
      className = "idea";
      content = section.content;
    };

  renderQuote = section:
    ''
      <p class="big-quote">${section.content}</p>
      ${optionalString (section.author or null != null)
        ''<p class="big-quote-cite">- ${esc section.author}</p>''}
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

  postDescription = post:
    if post.description != null then post.description
    else if post.tagline != "" then post.tagline
    else "QuackHack-McBLindy.com » Portfolio » I share code, wisdom and tells tales of NixOS flakes.";

  renderPage = _name: post: ''
    <!doctype html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <title>QuackHack-McBLindy.com » ${esc post.title} </title>
      <link rel="canonical" href="${cfg.baseUrl}/posts/${post.filename}" />

      <meta name="google-site-verification=nfCO9B-sHuohdde9OLWBELNHyZ9ODlhIl4wC5OkituQ" />
      <meta name="viewport" content="width=device-width, initial-scale=1.0">

      <link rel="preconnect" href="https://fonts.googleapis.com">
      <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
      <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@500;700;900&display=swap" rel="stylesheet">

      <meta property="og:type" content="website">
      <meta property="og:url" content="${cfg.baseUrl}/posts/${post.filename}">
      <meta property="og:title" content="QuackHack-McBLindy.com » ${esc post.title}">
      <meta property="og:description" content="${esc (postDescription post)}">
      ${optionalString (post.tags != []) ''
      <script type="application/ld+json">
      {
        "@context": "https://schema.org",
        "@type": "BlogPosting",
        "headline": "${esc post.title}",
        "url": "${cfg.baseUrl}/posts/${post.filename}",
        "datePublished": "${post.date}",
        "keywords": [${tagsToKeywords post.tags}]
      }
      </script>
      ''}

      <meta name="description" content="${esc (postDescription post)}">
      <meta property="og:image" content="https://quackhack-mcblindy.com/static/img/logo.png">

      <meta name="twitter:card" content="summary_large_image">
      <meta name="twitter:title" content="QuackHack-McBLindy.com » ${esc post.title}">
      <meta name="twitter:description" content="${esc (postDescription post)}">
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
    <body data-post-link="/posts/${post.filename}">

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
          ${optionalString (post.tags != []) ''
          <section class="content-section">
            <div class="wrap reveal">
              <div class="tag-list">
                ${concatStringsSep " " (map (t: ''<span class="tag">${esc t}</span>'') post.tags)}
              </div>
            </div>
          </section>
          ''}


          ${optionalString (post.crossLinks != []) (renderCrossLinks post.crossLinks)}
          ${optionalString (post.relatedPosts && post.tags != [ ]) (
            let rel = similarPostsFor post; in
            optionalString (rel != [ ]) ''
              <section class="content-section">
                <div class="wrap reveal">
                  <div class="section-head">
                    <h2><span class="gold">Related</span> <span class="white">posts</span></h2>
                  </div>
                  <div class="cross-links">
                    ${concatStringsSep "\n" (map (p: ''
                      <a class="cross-link" href="/posts/${p.filename}">
                        <span class="cl-icon" aria-hidden="true">🔗</span>
                        <div class="cl-body">
                          <h3 class="cl-title">${esc p.title}</h3>
                          <p class="cl-desc">${esc (if p.description != null then p.description else p.tagline)}</p>
                        </div>
                        <span class="cl-arrow" aria-hidden="true">→</span>
                      </a>
                    '') rel)}
                  </div>
                </div>
              </section>
            ''
          )}

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

        document.querySelectorAll('.config-block').forEach((block) => {
          const toggle = () => {
            const collapsed = block.classList.toggle('is-collapsed');
            const btn = block.querySelector('.collapse-btn');

            if (btn) {
              btn.setAttribute('aria-expanded', String(!collapsed));
              btn.textContent = collapsed ? 'Expand' : 'Collapse';
            }
          };

          block.addEventListener('click', (e) => {
            if (e.target.closest('.copy-btn')) return;
            if (!e.target.closest('.config-bar')) return;   // ← only the header toggles
            const selection = window.getSelection();
            if (selection && !selection.isCollapsed) return;
            toggle();
          });

        });

      })();
      </script>


      <script>
        (function () {
          'use strict';

          const CORNER_WIDTH    = 170;
          const CORNER_HEIGHT   = 120;
          const FRENZY_DURATION = 5200;
          const MAX_DUCKS       = 190;

          const GLYPHS = ['🦆','🦆','🦆','🦆','🦆','🦆','🦆','🦆','🐤','🪶'];
          const QUACK_WORDS = ['QUACK!','QUACK!!','QUACK?!','HONK!','QUAAACK!','🦆 QUACK 🦆','QUACK QUACK'];

          const ducks  = [];
          const timers = new Set();

          let layer         = null;
          let rafId         = 0;
          let lastTs        = 0;
          let frenzyActive  = false;
          let audioCtx      = null;

          const originalTitle = document.title;

          const rand = (min, max) => min + Math.random() * (max - min);
          const pick = (arr) => arr[(Math.random() * arr.length) | 0];
          const calm = () => window.matchMedia('(prefers-reduced-motion: reduce)').matches;

          function later(fn, ms) {
            const id = setTimeout(() => { timers.delete(id); fn(); }, ms);
            timers.add(id);
            return id;
          }

          function every(fn, ms) {
            const id = setInterval(fn, ms);
            timers.add(id);
            return id;
          }

          function stopTimers() {
            timers.forEach((id) => { clearTimeout(id); clearInterval(id); });
            timers.clear();
          }

          function getLayer() {
            if (!layer || !layer.isConnected) {
              layer = document.createElement('div');
              layer.className = 'frenzy-layer';
              layer.setAttribute('aria-hidden', 'true');
              document.body.appendChild(layer);
            }
            return layer;
          }

          function spawnDuck(originX, originY) {
            if (ducks.length >= MAX_DUCKS) return;

            const el = document.createElement('span');
            el.className = 'frenzy-duck';
            el.textContent = pick(GLYPHS);
            el.setAttribute('aria-hidden', 'true');

            const size = rand(16, 66);
            const x = originX !== undefined
              ? originX + rand(-110, 110)
              : rand(-70, window.innerWidth + 70);
            const y = originY !== undefined
              ? originY + rand(-40, 40)
              : rand(-window.innerHeight * 0.6, -30);

            el.style.fontSize = size.toFixed(1) + 'px';
            el.style.opacity  = (0.5 + Math.min(size, 66) / 66 * 0.5).toFixed(2);

            const d = {
              el: el,
              x: x,
              y: y,
              vx: rand(-1.4, 1.4),
              vy: rand(1.8, 5.2) * (0.65 + size / 66),
              rot: rand(0, 360),
              vrot: rand(-8, 8),
              wobbleAmp: rand(0.2, 2.4),
              wobbleFreq: rand(0.0015, 0.0055),
              wobblePhase: rand(0, Math.PI * 2)
            };

            el.style.transform =
              'translate3d(' + d.x.toFixed(1) + 'px,' + d.y.toFixed(1) + 'px,0) ' +
              'rotate(' + d.rot.toFixed(1) + 'deg)';

            getLayer().appendChild(el);
            ducks.push(d);
            ensureLoop();
          }

          function ensureLoop() {
            if (rafId) return;
            lastTs = performance.now();
            rafId = requestAnimationFrame(tick);
          }

          function tick(ts) {
            rafId = 0;

            const dt = Math.min(3, Math.max(0.2, (ts - lastTs) / 16.667));
            lastTs = ts;

            for (let i = ducks.length - 1; i >= 0; i--) {
              const d = ducks[i];

              d.y += d.vy * dt;
              d.x += (d.vx + Math.sin(d.wobblePhase + ts * d.wobbleFreq) * d.wobbleAmp) * dt;
              d.rot += d.vrot * dt;

              d.el.style.transform =
                'translate3d(' + d.x.toFixed(1) + 'px,' + d.y.toFixed(1) + 'px,0) ' +
                'rotate(' + d.rot.toFixed(1) + 'deg)';

              if (d.y > window.innerHeight + 140 ||
                  d.x < -260 ||
                  d.x > window.innerWidth + 260) {
                d.el.remove();
                ducks.splice(i, 1);
              }
            }

            if (ducks.length || frenzyActive) {
              rafId = requestAnimationFrame(tick);
            } else if (layer) {
              layer.remove();
              layer = null;
            }
          }

          function flash() {
            const el = document.createElement('div');
            el.className = 'frenzy-flash';
            el.setAttribute('aria-hidden', 'true');
            document.body.appendChild(el);
            el.addEventListener('animationend', () => el.remove(), { once: true });
            setTimeout(() => el.remove(), 1500);
          }

          function shockwave(x, y) {
            const el = document.createElement('div');
            el.className = 'frenzy-ring';
            el.setAttribute('aria-hidden', 'true');
            el.style.left = x + 'px';
            el.style.top  = y + 'px';
            document.body.appendChild(el);
            el.addEventListener('animationend', () => el.remove(), { once: true });
            setTimeout(() => el.remove(), 1500);
          }

          function shake(el, strength) {
            if (!el || typeof el.animate !== 'function') return;
            if (calm()) return;

            const frames = [];
            const steps = 12;

            for (let i = 0; i <= steps; i++) {
              const decay = Math.pow(1 - i / steps, 2);
              frames.push({
                transform:
                  'translate3d(' +
                    ((Math.random() * 2 - 1) * strength * decay).toFixed(2) + 'px,' +
                    ((Math.random() * 2 - 1) * strength * decay).toFixed(2) + 'px,0) ' +
                  'rotate(' + ((Math.random() * 2 - 1) * 0.8 * decay).toFixed(2) + 'deg)'
              });
            }
            frames.push({ transform: 'translate3d(0,0,0) rotate(0deg)' });

            try {
              el.animate(frames, { duration: 560, easing: 'linear', composite: 'add' });
            } catch (err) {

            }
          }

          function quackText() {
            const el = document.createElement('div');
            el.className = 'frenzy-quack';
            el.textContent = pick(QUACK_WORDS);
            el.setAttribute('aria-hidden', 'true');
            el.style.left = rand(6, 94).toFixed(1) + 'vw';
            el.style.top  = rand(12, 88).toFixed(1) + 'vh';
            el.style.fontSize = rand(16, 48).toFixed(0) + 'px';
            el.style.color = Math.random() < 0.5 ? '#ffd75e' : '#00e5d1';
            el.style.setProperty('--frenzy-rot', rand(-24, 24).toFixed(1) + 'deg');
            document.body.appendChild(el);
            el.addEventListener('animationend', () => el.remove(), { once: true });
            setTimeout(() => el.remove(), 2500);
          }

          function getAudioCtx() {
            const AC = window.AudioContext || window.webkitAudioContext;
            if (!AC) return null;
            if (!audioCtx) {
              try { audioCtx = new AC(); } catch (err) { return null; }
            }
            if (audioCtx.state === 'suspended') {
              audioCtx.resume().catch(() => {});
            }
            return audioCtx;
          }

          function playQuack() {
            const ctx = getAudioCtx();
            if (!ctx) return;

            const t0   = ctx.currentTime;
            const base = rand(210, 330);

            const osc  = ctx.createOscillator();
            const osc2 = ctx.createOscillator();

            osc.type  = 'sawtooth';
            osc2.type = 'square';

            osc.frequency.setValueAtTime(base * 3.2, t0);
            osc.frequency.exponentialRampToValueAtTime(base, t0 + 0.16);

            osc2.frequency.setValueAtTime(base * 1.6, t0);
            osc2.frequency.exponentialRampToValueAtTime(base * 0.7, t0 + 0.18);

            const filter = ctx.createBiquadFilter();
            filter.type = 'bandpass';
            filter.frequency.setValueAtTime(1400, t0);
            filter.frequency.exponentialRampToValueAtTime(700, t0 + 0.2);
            filter.Q.value = 3.5;

            const gain = ctx.createGain();
            gain.gain.setValueAtTime(0.0001, t0);
            gain.gain.exponentialRampToValueAtTime(0.16, t0 + 0.012);
            gain.gain.exponentialRampToValueAtTime(0.0001, t0 + 0.26);

            osc.connect(filter);
            osc2.connect(filter);
            filter.connect(gain);
            gain.connect(ctx.destination);

            osc.start(t0);  osc2.start(t0);
            osc.stop(t0 + 0.3); osc2.stop(t0 + 0.3);
          }

          function playQuackBurst(n) {
            for (let i = 0; i < n; i++) {
              setTimeout(playQuack, i * 110 + Math.random() * 90);
            }
          }

          function isFrameVisible() {
            const frame = document.querySelector('.duckhawk-frame');
            if (!frame) return false;
            if (getComputedStyle(frame).display === 'none') return false;

            const vw = window.innerWidth;
            const vh = window.innerHeight;
            const pieces = frame.querySelectorAll('.frame-header, .frame-header-standalone');

            for (let i = 0; i < pieces.length; i++) {
              const el = pieces[i];
              const cs = getComputedStyle(el);

              if (cs.display === 'none' || cs.visibility === 'hidden') continue;
              if (parseFloat(cs.opacity) < 0.05) continue;

              const r = el.getBoundingClientRect();
              if (r.width > 8 && r.height > 8 &&
                  r.right > 0 && r.left < vw &&
                  r.bottom > 0 && r.top < vh) {
                return true;
              }
            }
            return false;
          }

          function startFrenzy(x, y) {
            if (frenzyActive) return;
            frenzyActive = true;
            const soft = calm();
            getLayer();

            document.title = '🦆 QUACK FRENZY 🦆';

            if (!soft) {
              flash();
              shockwave(x, y);
              shake(document.getElementById('content-glitch'), 11);
              shake(document.querySelector('.duckhawk-frame'), 7);
            }

            playQuackBurst(soft ? 1 : 5);

            const wall = soft ? 10 : 64;
            for (let i = 0; i < wall; i++) {
              spawnDuck(undefined, rand(-window.innerHeight * 0.8, -20));
            }

            const burst = soft ? 4 : 26;
            for (let i = 0; i < burst; i++) {
              spawnDuck(x, y);
            }

            every(() => {
              const n = soft ? 1 : 3;
              for (let i = 0; i < n; i++) spawnDuck();
              if (!soft && Math.random() < 0.14) quackText();
            }, soft ? 380 : 55);

            if (!soft) {
              let q = 0;
              every(() => {
                quackText();
                if (q % 2 === 0 && q < 8) playQuack();
                q++;
              }, 400);
            }

            later(() => {
              frenzyActive = false;
              stopTimers();
              document.title = originalTitle;

              if (ducks.length === 0 && layer) {
                layer.remove();
                layer = null;
              }
            }, soft ? 2400 : FRENZY_DURATION);
          }

          function inCorner(x, y) {
            const vw = window.innerWidth;
            const vh = window.innerHeight;
            const w = Math.min(CORNER_WIDTH, vw * 0.34);
            const h = Math.min(CORNER_HEIGHT, vh * 0.22);
            return x >= vw - w && y <= h;
          }




          function onPointerDown(e) {
            if (e.button !== 0) return;
            if (!inCorner(e.clientX, e.clientY)) return;
            if (!isFrameVisible()) return;

            const t = e.target;
            if (t && typeof t.closest === 'function' &&
                t.closest('a, button, input, textarea, select, summary, [role="button"], [contenteditable]')) {
              return;
            }

            if (frenzyActive) {
              for (let i = 0; i < 18; i++) spawnDuck(e.clientX, e.clientY);
              playQuack();
              if (!calm()) shockwave(e.clientX, e.clientY);
              return;
            }

            startFrenzy(e.clientX, e.clientY);
          }

          document.addEventListener('pointerdown', onPointerDown, true);

          try {
            console.log(
              '%c🦆 pssst… top-right corner, while the frame is up…',
              'color:#00e5d1;font-weight:700;font-size:12px;'
            );
          } catch (err) { /* ignore */ }
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

    .config-bar button {
      appearance: none;
      border: 1px solid var(--line);
      background: rgba(17,230,210,.07);
      color: var(--teal);
      font: inherit;
      font-size: .72rem;
      font-weight: 700;
      letter-spacing: .05em;
      text-transform: uppercase;
      padding: 6px 10px;
      border-radius: 8px;
      cursor: pointer;
      white-space: nowrap;
      transition: background .2s ease, border-color .2s ease;
    }

    .config-bar button:hover {
      background: rgba(17,230,210,.15);
      border-color: rgba(17,230,210,.4);
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

    .frenzy-layer {
      position: fixed;
      inset: 0;
      z-index: 9998;
      pointer-events: none;
      overflow: hidden;
    }

    .frenzy-duck {
      position: absolute;
      top: 0;
      left: 0;
      line-height: 1;
      user-select: none;
      pointer-events: none;
      will-change: transform;
      transform-origin: 50% 50%;
      text-shadow: 0 0 14px rgba(0, 229, 209, .45);
    }

    .frenzy-flash {
      position: fixed;
      inset: 0;
      z-index: 10000;
      pointer-events: none;
      mix-blend-mode: screen;
      background:
        radial-gradient(circle at 85% 0%,
          rgba(255, 232, 130, .95),
          rgba(0, 229, 209, .45) 38%,
          rgba(0, 0, 0, 0) 72%);
      animation: frenzyFlash .8s ease-out forwards;
    }

    .frenzy-ring {
      position: fixed;
      z-index: 10000;
      width: 120px;
      height: 120px;
      margin: -60px 0 0 -60px;
      border-radius: 50%;
      border: 3px solid rgba(255, 214, 90, .9);
      box-shadow:
        0 0 44px rgba(0, 229, 209, .75),
        inset 0 0 44px rgba(255, 214, 90, .55);
      pointer-events: none;
      animation: frenzyRing .95s cubic-bezier(.12, .72, .26, 1) forwards;
    }

    .frenzy-quack {
      position: fixed;
      z-index: 10001;
      pointer-events: none;
      font-family: 'Orbitron', system-ui, sans-serif;
      font-weight: 900;
      letter-spacing: .08em;
      white-space: nowrap;
      text-shadow: 0 0 18px currentColor, 0 0 42px currentColor;
      animation: frenzyQuack 1.15s ease-out forwards;
    }

    @keyframes frenzyFlash {
      from { opacity: .95; }
      to   { opacity: 0; }
    }

    @keyframes frenzyRing {
      from { transform: scale(.12); opacity: 1; }
      to   { transform: scale(10);  opacity: 0; }
    }

    @keyframes frenzyQuack {
      0%   { opacity: 0; transform: translate(-50%, -50%)  scale(.30) rotate(var(--frenzy-rot, 0deg)); }
      18%  { opacity: 1; transform: translate(-50%, -50%)  scale(1.15) rotate(var(--frenzy-rot, 0deg)); }
      100% { opacity: 0; transform: translate(-50%, -210%) scale(.85) rotate(var(--frenzy-rot, 0deg)); }
    }

    @media (prefers-reduced-motion: reduce) {
      .frenzy-flash,
      .frenzy-ring { display: none; }
      .frenzy-quack { animation-duration: .6s; }
    }

    .duck-comment,
    .idea {
      max-width: 760px;
      margin: 25px auto;
    }

    .duck-comment {
      position: relative;
      padding: 18px 22px;
      background: rgba(255, 215, 0, 0.06);
      border-left: 4px solid var(--gold);
      border-radius: 10px;
      box-shadow: 0 3px 10px rgba(0, 0, 0, 0.35);
    }
    .duck-comment::before {
      content: "🦆";
      position: absolute;
      left: -25px;
      top: 15px;
      font-size: 1.8rem;
      background: var(--panel2);
      border-radius: 50%;
      width: 40px;
      height: 40px;
      display: flex;
      align-items: center;
      justify-content: center;
      border: 2px solid var(--gold);
      box-shadow: 0 3px 10px rgba(0, 0, 0, 0.5);
    }
    .duck-comment p {
      margin: 10px 0;
      font-style: italic;
      color: var(--gold2);
    }

    .idea {
      position: relative;
      padding: 22px 26px;
      background: rgba(108, 180, 255, 0.06);
      border-left: 4px solid var(--blue);
      border-radius: 0 12px 12px 0;
      box-shadow: 0 3px 10px rgba(0, 0, 0, 0.35);
    }
    .idea::before {
      content: "💡";
      position: absolute;
      left: -50px;
      top: 50%;
      transform: translateY(-50%);
      font-size: 2rem;
      background: var(--panel2);
      border-radius: 50%;
      width: 50px;
      height: 50px;
      display: flex;
      align-items: center;
      justify-content: center;
      border: 2px solid var(--blue);
      box-shadow: 0 3px 10px rgba(0, 0, 0, 0.5);
    }
    .idea p {
      color: #c9dbd8;
    }

    @media (max-width: 768px) {
      .duck-comment::before { left: -15px; width: 30px; height: 30px; font-size: 1.2rem; }
      .idea::before         { left: -35px; width: 40px; height: 40px; font-size: 1.5rem; }
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

    .warning {
      max-width: 760px; margin: 0 auto;
      padding: 18px 22px;
      background: rgba(255,84,112,.04);
      border: 1px solid rgba(255,84,112,.2);
      border-left: 3px solid var(--red);
      border-radius: 10px;
      color: #c9dbd8; font-size: .95rem; line-height: 1.7;
    }
    .warning strong {
      color: var(--red); font-weight: 700;
      display: inline-flex; align-items: center; gap: 6px;
    }
    .warning strong::before { content: "⚠"; font-size: 1.05em; }
    .warning code {
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
    .config-block.is-collapsed pre {
      display: none;
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
    .tag-list {
      display: flex; flex-wrap: wrap; gap: 8px;
      justify-content: center; max-width: 720px; margin: 0 auto;
    }
    .tag-list .tag {
      font-family: "JetBrains Mono", monospace;
      font-size: .74rem; letter-spacing: .06em; text-transform: uppercase;
      color: var(--teal); background: rgba(17,230,210,.08);
      border: 1px solid rgba(17,230,210,.25);
      padding: 4px 12px; border-radius: 999px;
    }
    .config-bar {
      cursor: pointer;
      user-select: none;
    }

    .config-bar .copy-btn {
      cursor: pointer;
    }
    .prose-section ul,
    .prose-section ol { color: #c9dbd8; padding-left: 1.4em; margin: 0 0 16px; }
    .prose-section li { margin: 6px 0; line-height: 1.7; }

  '';

  postFiles = lib.mapAttrs' (name: post:
    lib.nameValuePair post.filename
      (pkgs.writeText post.filename (renderPage name post))
  ) cfg.posts;

  sortedPosts = sort (a: b:
    if a.date != b.date then a.date > b.date
    else a._name < b._name
  ) (mapAttrsToList (name: p: p // { _name = name; }) cfg.posts);

  similarPostsFor = post:
    let
      others = filter (p: p.filename != post.filename) sortedPosts;
      shared = p: lib.length (lib.intersectLists (post.tags or [ ]) (p.tags or [ ]));
      ranked = sort (a: b:
        let sa = shared a; sb = shared b; in
        if sa != sb then sa > sb else a.date > b.date
      ) (filter (p: shared p > 0) others);
    in lib.take 3 ranked;

  postsData =
    if cfg.postsJson != null then cfg.postsJson
    else
      (map (p: {
        title       = p.title;
        description = if p.description != null then p.description else p.tagline;
        tags        = p.tags;
        date        = p.date;
        link        = "${cfg.baseUrl}/posts/${p.filename}";
      }) sortedPosts)
      ++ cfg.extraPosts;

  postsJson = pkgs.runCommand "posts.json" { } ''
    ${pkgs.jq}/bin/jq . ${pkgs.writeText "posts-raw.json" (builtins.toJSON postsData)} > $out
  '';

  html = pkgs.runCommand "blog-html" { } ''
    mkdir -p $out $out/posts
    ${concatStringsSep "\n" (mapAttrsToList (name: f: "cp ${f} $out/${name}") postFiles)}
    cp ${postsJson} $out/posts.json
    cp ${postsJson} $out/posts/posts.json
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
      default = "QuackHack-McBLindy.com";
      description = "Site name in titles, og:site_name, and footer.";
    };

    html = mkOption {
      type = types.package;
      readOnly = true;
      description = "Generated site directory (HTML files + posts.json).";
    };

    postsJson = mkOption {
      type = types.nullOr (types.listOf (types.submodule {
        options = {
          title       = mkOption { type = types.str; };
          description = mkOption { type = types.str; default = ""; };
          tags        = mkOption { type = types.listOf types.str; default = []; };
          date        = mkOption { type = types.str; };
          link        = mkOption { type = types.str; default = ""; };
        };
      }));
      default = null;
      description = ''
        Full override for posts.json. When set, blog.posts is used ONLY for
        page generation - this list is emitted verbatim as posts.json.
      '';
    };

    extraPosts = mkOption {
      type = types.listOf (types.submodule {
        options = {
          title       = mkOption { type = types.str; };
          description = mkOption { type = types.str; default = ""; };
          tags        = mkOption { type = types.listOf types.str; default = []; };
          date        = mkOption { type = types.str; };
          link        = mkOption { type = types.str; default = ""; };
        };
      });
      default = [ ];
      description = ''
        Extra entries appended to the auto-generated posts.json. Use for
        external links, placeholders, or anything without a real page.
      '';
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
                warning = mkOption {
                  type = types.nullOr types.lines;
                  default = null;
                  description = "Warning callout. HTML allowed.";
                };
                quote = mkOption {
                  type = types.nullOr types.lines;
                  default = null;
                  description = "Quote callout. HTML allowed.";
                };
                duck = mkOption {
                  type = types.nullOr types.lines;
                  default = null;
                  description = "Duck comment callout. HTML allowed.";
                };
                idea = mkOption {
                  type = types.nullOr types.lines;
                  default = null;
                  description = "Idea callout. HTML allowed.";
                };
                code = mkOption {
                  type = types.nullOr (types.submodule {
                    options = {
                      content = mkOption { type = types.lines; };
                      title = mkOption { type = types.str; default = ""; };
                      lang = mkOption { type = types.str; default = "nix"; };
                      collapsed = mkOption {
                        type = types.bool;
                        default = false;
                        description = "Hide the code block initially; visitors can expand it.";
                      };
                    };
                  });
                  default = null;
                };
              };
            });
            default = [ ];
            description = "Ordered content sections: prose, HTML, code, warning, quote, duck, and idea. Entries can be repeated.";
          };
          warning = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Warning box (HTML allowed).";
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
      (lib.mapAttrs'
        (name: post:
          lib.nameValuePair "QuackHack-McBlindy.com/posts/${post.filename}"
            "${config.blog.html}/${post.filename}")
        config.blog.posts)
      // {
        "QuackHack-McBlindy.com/posts.json" =
          "${config.blog.html}/posts.json";
      };

  };}
