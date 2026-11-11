# dotfiles/modules/posts/one-billion-understandable-phrases.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
#  » ★ QuackHack-McBLindy.com ★ «
{ # 🦆 ⮞ nuthin' to see here... (just some html generation)
  lib,
  config,
  ...
} : let
  cfg = config.yo;

  allScripts   = lib.attrValues cfg.scripts;
  voiceScripts = lib.filter (s: s.voiceReady) allScripts;

  totalScripts      = builtins.length allScripts;
  totalVoiceScripts = builtins.length voiceScripts;
  totalPatterns     = lib.foldl' (a: s: a + s.voicePatterns) 0 allScripts;
  totalPhrases      = lib.foldl' (a: s: a + s.voicePhrases)  0 allScripts;

  phrasesPerPattern =
    if totalPatterns == 0 then 0
    else builtins.div totalPhrases totalPatterns;

  voicePct =
    if totalScripts == 0 then 0
    else builtins.div (totalVoiceScripts * 100) totalScripts;

  fmtInt = n:
    let
      s        = toString n;
      len      = builtins.stringLength s;
      r        = lib.mod len 3;
      firstLen = if r == 0 then 3 else r;
      numGroups = builtins.div (len - firstLen) 3;
      first    = builtins.substring 0 firstLen s;
      groups   = builtins.genList (i: builtins.substring (firstLen + i * 3) 3 s) numGroups;
    in
      if numGroups == 0 then first
      else first + "," + lib.concatStringsSep "," groups;

  fmtK = n: "${toString (builtins.div n 1000)}k";

  fmtB = n:
    let
      hundredths = builtins.div (n * 100) 1000000000;
      whole      = builtins.div hundredths 100;
      frac       = lib.mod hundredths 100;
      fracStr    = if frac < 10 then "0${toString frac}" else toString frac;
    in "${toString whole}.${fracStr}B";

  fmtBProse = n:
    let
      hundredths = builtins.div (n * 100) 1000000000;
      whole      = builtins.div hundredths 100;
      frac       = lib.mod hundredths 100;
      fracStr    = if frac < 10 then "0${toString frac}" else toString frac;
    in "${toString whole}.${fracStr} billion";
in {

  blog = {
    enable = true;

    posts.milestone = {
      filename    = "one-billion-understandable-phrases.html";
      date        = "2025-01-01";
      title       = "A Unique Milestone Reached";
      tags        = [ "yo" "voice" "nix" "milestone" ];
      description = "yo crossed one billion generated phrases. ${fmtInt totalPatterns} patterns. ${fmtInt totalPhrases} phrases. ${toString totalScripts} scripts, ${toString totalVoiceScripts} voice-ready. 97 ms average over 1,467 runs.";

      eyebrow = "A unique milestone reached";
      header1 = ''<span style="color:#fff">A Unique Mile</span><span style="color:var(--gold)">stone Reached!</span>'';
      header2 = "";

      heroHtml = ''
        <p class="milestone-number">${fmtInt totalPhrases}</p>
        <p class="milestone-unit">Understandable phrases/variations compiled at build-time.</p>
        <p class="milestone-sub">
          From <strong>${fmtInt totalPatterns} patterns</strong>, at a ratio of
          <strong>${fmtInt phrasesPerPattern}</strong> phrases per pattern.
          All matched at runtime, with <strong>97 ms</strong>
          average execution across <strong>1,467 runs</strong>.
        </p>
      '';

      stats = [
        { value = toString totalScripts;      label = "scripts total";            accent = "gold";  }
        { value = toString totalVoiceScripts; label = "Voice scripts";            accent = "gold2"; }
        { value = fmtInt totalPatterns;       label = "Generated regex patterns"; accent = "teal";  }
        { value = fmtB   totalPhrases;        label = "Understandable phrases";   accent = "green"; }
        { value = fmtK   phrasesPerPattern;   label = "Variations / Pattern";     accent = "pink";  }
        { value = "97 ms";                    label = "Average on 1,467 executions";  accent = "blue";  }
      ];

      sections = [
        { html = ''
          <section class="content-section"><div class="wrap reveal">
            <div class="voice-coverage">
              <div class="voice-coverage-header">
                <span class="vc-label">Voice-enabled coverage</span>
                <span class="vc-value">${toString totalVoiceScripts} / ${toString totalScripts} = <span class="vc-pct">${toString voicePct}%</span></span>
              </div>
              <div class="voice-coverage-track">
                <div class="voice-coverage-fill" style="width: ${toString voicePct}%;"></div>
              </div>
              <div class="voice-coverage-meta">
                <span>${toString totalVoiceScripts} scripts respond to natural language</span>
                <span class="vc-hint"><code>voice.enabled = true</code> in their <code>.nix</code></span>
              </div>
            </div>
          </div></section>
        ''; }



        { prose = ''
          ## What a billion actually means

          `yo` is a natural language to shell script translator. You speak or type a sentence. It runs exact and fuzzy pattern matching against a set of templates, resolves the parameters, and executes the corresponding script. No command list to memorize. No aliases to look up. Just a sentence.

          A billion is easy to say and hard to picture. So let's make it concrete.

          ## The math

          `yo` doesn't have a billion sentences written into it. It has **${fmtInt totalPatterns} patterns** - human-written templates with slots. What turns those ${fmtInt totalPatterns} patterns into **${fmtInt totalPhrases} phrases** is the parameter space.

          Every slot in a pattern can be filled by every value that slot accepts. When a pattern says *"deploy {host}"* and `{host}` can be any of your machines, that's one pattern generating many sentences. When a pattern says *"play {track} on {speaker}"* and `{track}` has 1,024 values and `{speaker}` has 24, that's one pattern generating 24,576 sentences.

          Stack enough slots across enough scripts, and the multiplication does what multiplication does. **${fmtInt totalPatterns} patterns × ~${fmtInt phrasesPerPattern} variations per pattern = over a billion distinct sentences** the runtime matcher recognizes.
        ''; }


        { prose = ''
          ## What **understandable** means here
        ''; }


        { prose = ''
          The billion is not *"sentences the system will attempt."* It's *"sentences the system will correctly recognize, resolve, and run."* That's a much smaller, much more honest number.

          ## Not "weekend work"

          ${fmtInt totalPatterns} patterns is a lot to hand-write. ${fmtInt phrasesPerPattern} phrases per pattern is a lot of grammar to get right - plural, word order, synonyms, optional words, alternative words. Every new pattern multiplies against every existing parameter list, and every new parameter value multiplies against every existing pattern. The phrase count grows quadratically, initially the work to keep it accurate grew with both sides, that's before I implemented fuzzy sentence conflict detection at compile-time.

          That's what hitting one billion really means: not that the matcher is fast - **97 ms average across 1,467 runs** is nice but cheap - but that the vocabulary underneath it is dense enough. The multiplication naturally clears a billion.

          And it helps that **${toString totalVoiceScripts} of the ${toString totalScripts} scripts** expose their vocabulary to the voice layer. Those ${toString totalVoiceScripts} are the scripts that can be spoken to, and they're what feeds the phrase count. The other ${toString (totalScripts - totalVoiceScripts)} are infrastructure - hooks, generators, helpers - that nobody needs to say out loud.
        ''; }
      ];

      quote = ''
        The system is not smart. It's thorough.<br>
        And thorough, at this scale, is <strong>its own kind of milestone.</strong>
      '';


      extraCss = ''
        main > .content-section + .content-section { padding-top: 0; }

        .milestone-number {
          font-family: "Cinzel Decorative", Georgia, serif;
          font-size: clamp(3rem, 14vw, 8.5rem);
          line-height: .95; letter-spacing: -.03em; margin: 0 0 8px;
          background: linear-gradient(135deg, var(--gold2) 0%, var(--gold) 40%, var(--teal) 100%);
          -webkit-background-clip: text; background-clip: text; color: transparent;
          filter: drop-shadow(0 0 40px rgba(244, 181, 47, .3));
        }
        .milestone-unit {
          font-family: "JetBrains Mono", monospace;
          font-size: clamp(.85rem, 1.6vw, 1rem);
          letter-spacing: .3em; text-transform: uppercase;
          color: var(--muted); margin: 0 0 32px;
        }
        .milestone-sub {
          font-size: clamp(1.02rem, 1.8vw, 1.2rem);
          color: var(--muted); max-width: 680px; margin: 0 auto; line-height: 1.65;
        }
        .milestone-sub strong { color: var(--gold2); font-weight: 700; }

        .hero-title { font-size: clamp(1.8rem, 5vw, 3rem); letter-spacing: -.01em; margin: 0 0 24px; }
        .hero-eyebrow::before {
          content: ""; width: 6px; height: 6px; border-radius: 50%;
          background: var(--teal); box-shadow: 0 0 10px var(--teal);
          animation: pulse 2s ease-in-out infinite;
        }
        @keyframes pulse { 0%,100% { opacity: 1 } 50% { opacity: .3 } }
        @media (prefers-reduced-motion: reduce) { .hero-eyebrow::before { animation: none; } }

        .voice-coverage {
          max-width: 1000px; margin: 0 auto 40px; padding: 22px 26px;
          background: linear-gradient(180deg, var(--panel2), var(--panel));
          border: 1px solid var(--line); border-radius: 14px;
          position: relative; overflow: hidden;
        }
        .voice-coverage::before {
          content: ""; position: absolute; top: 0; left: 0; right: 0; height: 3px;
          background: linear-gradient(90deg, transparent, var(--gold), transparent); opacity: .6;
        }
        .voice-coverage-header {
          display: flex; justify-content: space-between; align-items: baseline;
          margin-bottom: 12px; font-family: "JetBrains Mono", monospace;
          font-size: .82rem; flex-wrap: wrap; gap: 6px;
        }
        .voice-coverage-header .vc-label { color: var(--muted); text-transform: uppercase; letter-spacing: .08em; }
        .voice-coverage-header .vc-value { color: var(--gold2); font-weight: 700; }
        .voice-coverage-header .vc-value .vc-pct { color: var(--teal); }
        .voice-coverage-track {
          height: 10px; background: rgba(0,0,0,.4); border-radius: 999px;
          overflow: hidden; border: 1px solid rgba(255,255,255,.06);
        }
        .voice-coverage-fill {
          height: 100%; background: linear-gradient(90deg, var(--teal), var(--gold2));
          border-radius: 999px; box-shadow: 0 0 20px rgba(244,181,47,.35); position: relative;
        }
        .voice-coverage-fill::after {
          content: ""; position: absolute; right: 0; top: 0; bottom: 0; width: 2px;
          background: rgba(255,255,255,.8); box-shadow: 0 0 10px rgba(255,255,255,.8);
        }
        .voice-coverage-meta {
          margin-top: 12px; display: flex; justify-content: space-between;
          font-size: .78rem; color: var(--muted);
          font-family: "JetBrains Mono", monospace; flex-wrap: wrap; gap: 8px;
        }
        .voice-coverage-meta code {
          color: var(--gold2); background: rgba(244,181,47,.08);
          padding: 1px 5px; border-radius: 3px;
          font-family: "JetBrains Mono", monospace; font-size: .9em;
        }

        .wildcard-note {
          max-width: 760px; margin: 24px auto 0; padding: 18px 22px;
          background: rgba(179,146,255,.04);
          border: 1px solid rgba(179,146,255,.25);
          border-left: 3px solid var(--purple); border-radius: 10px;
          color: #c9dbd8; font-size: .94rem; line-height: 1.7;
        }
        .wildcard-note strong {
          color: var(--purple); font-weight: 700;
          display: inline-flex; align-items: center; gap: 6px;
        }
        .wildcard-note strong::before { content: "⚠"; font-size: 1.05em; }
        .wildcard-note code {
          color: var(--gold2); background: rgba(244,181,47,.08);
          padding: 1px 5px; border-radius: 3px;
          font-family: "JetBrains Mono", monospace; font-size: .9em;
        }
        .wildcard-note em { color: var(--gold2); font-style: italic; }

        .prose-list { list-style: none; padding: 0; margin: 20px 0; max-width: 720px; margin-inline: auto; }
        .prose-list li {
          padding: 16px 20px 16px 24px; border-left: 2px solid var(--teal);
          background: rgba(17,230,210,.03); border-radius: 0 10px 10px 0;
          margin-bottom: 12px; color: #c9dbd8; font-size: .95rem; line-height: 1.65;
        }
        .prose-list li strong { color: var(--gold2); font-weight: 700; }
        .prose-list li code {
          color: var(--gold2); background: rgba(244,181,47,.08);
          padding: 1px 5px; border-radius: 3px;
          font-family: "JetBrains Mono", monospace; font-size: .9em;
        }

        .tests-grid {
          display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
          gap: 16px; margin: 20px 0; max-width: 900px; margin-inline: auto;
        }
        .test-card {
          background: linear-gradient(180deg, var(--panel2), var(--panel));
          border: 1px solid var(--line); border-radius: 14px;
          padding: 22px 20px; position: relative;
        }
        .test-card .test-num {
          display: inline-flex; align-items: center; justify-content: center;
          width: 30px; height: 30px; border-radius: 50%;
          border: 1px solid var(--teal); color: var(--teal);
          font-family: "JetBrains Mono", monospace; font-size: .82rem;
          font-weight: 700; margin-bottom: 12px;
        }
        .test-card h4 {
          font-family: "Cinzel Decorative", Georgia, serif;
          font-size: 1rem; color: var(--gold2);
          margin: 0 0 8px; letter-spacing: .02em;
        }
        .test-card p { color: #c9dbd8; font-size: .88rem; line-height: 1.6; margin: 0; }
        .test-card code {
          color: var(--gold2); background: rgba(244,181,47,.08);
          padding: 1px 5px; border-radius: 3px;
          font-family: "JetBrains Mono", monospace; font-size: .88em;
        }


        .prose-section { max-width: 760px; }
        .prose-section p { margin: 0 0 18px; }
        .prose-section em { color: var(--gold2); font-style: italic; }

        .big-quote { margin: 40px auto 20px; }

        @media (max-width: 560px) {
          .milestone-number { font-size: clamp(2.4rem, 16vw, 4rem); }
        }
      '';
    };

  };}
