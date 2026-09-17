# dotfiles/modules/programs/firefox.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
# » ★ QuackHack-McBLindy.com ★ «
# ★ ─────────────────────────────────────────────────────────────────────── ★
# ★ SUMMARY:
# ★ A complete firefox configuration that extends beyond preferences and addons.
# ★ This configuration handles firefox, network, sandboxing, builds a start webpage and much more.
# ★
# ★ run:`bm URL`   to save URL to the bookmarks on the custom start page
# ★ run: `foxytor` to browse anonymously
# ★ ─────────────────────────────────────────────────────────────────────── ★
{ # 🦆 duck say ⮞ diz iz my 🦊 even tho i be a 🦆
  config,
  self,
  lib,
  pkgs,
  ...
} : let
  # 🦆 says ⮞ meta fox
  firefoxIcon = "${self}/modules/themes/icons/firefox.png";
  torfoxDesktopEntry = pkgs.writeText "torfox.desktop" ''
    [Desktop Entry]
    Type=Application
    Name=Firefox (Tor)
    Comment=Firefox running over Tor
    Exec=torfox %u
    Icon=${firefoxIcon}
    Terminal=false
    Categories=Network;WebBrowser;
    MimeType=text/html;text/xml;application/xhtml+xml;
  '';

  # 🦆 says ⮞ dis fetch what host has Docker services configued
  sysHosts = lib.attrNames self.nixosConfigurations;
  arrHost = lib.findSingle (host:
      let cfg = self.nixosConfigurations.${host}.config;
      in lib.lists.elem "arr" cfg.this.host.modules.virtualisation
    ) null null sysHosts;
  arrHostIP = if arrHost != null then
    self.nixosConfigurations.${arrHost}.config.this.host.ip or (
      let
        resolved = builtins.readFile (pkgs.runCommand "resolve-host" {} ''
          ${pkgs.dnsutils}/bin/host -t A ${arrHost} > $out
        '');
      in
        lib.lists.head (lib.strings.splitString " " (lib.lists.elemAt (lib.strings.splitString "\n" resolved) 0))
    )
  else
    throw "No host found with the 'arr' virtualisation module configured";

  # 🦆 duck say ⮞  configuration options
  cfg = config.this.host.modules.programs;
  themeCSS = builtins.readFile config.this.theme.styles; # 🦆 duck say ⮞ reads NixOS module theme and applies it to firefox
  homeDir = config.users.users.${config.this.user.me.name}.home; # 🦆 duck say ⮞ user home directory
  firefoxProfileDir = "${homeDir}/.mozilla/firefox/default"; # 🦆 duck say ⮞ default profiles directory
  backupPath = "${firefoxProfileDir}/bookmarkbackups"; # 🦆 duck say ⮞ firefox default bookmarks directory
  pythonEnv = pkgs.python3.withPackages (ps: [ ps.lz4 ]); # 🦆 duck say ⮞ required dependencies for encoding firefox data
#  firefoxProfileDir = "/home/${config.this.user.me.name}/.mozilla/firefox/default";
#  backupPath = "${config.users.users.${config.this.user.me.name}.home}/.mozilla/firefox/default/bookmarkbackups";

  # 🦆 duck say ⮞ Dynamically imports from Firefox Bookmarks Backups to auto detect new bookmarks
  bookmarkScript = pkgs.writeScript "generate-bookmarks.py" ''
    #!${pythonEnv}/bin/python
    import lz4.block
    import json
    from pathlib import Path
    import sys
    import os

    def find_latest_backup_file(directory):
        backups = list(directory.glob("bookmarks-*.jsonlz4"))
        if not backups:
            print(f"No backups found in {directory}")
            sys.exit(0)
        return max(backups, key=lambda f: f.stat().st_mtime)

    def read_jsonlz4(path):
        with open(path, "rb") as f:
            if f.read(8) != b"mozLz40\0":
                raise ValueError("Invalid LZ4 header")
            return json.loads(lz4.block.decompress(f.read()))

    def extract_bookmarks(data, placement="toolbar"):
        def collect(node):
            results = []
            for child in node.get("children", []):
                if "uri" in child:
                    results.append({
                        "Title": child.get("title", ""),
                        "URL": child.get("uri", ""),
                        "Placement": placement
                    })
                elif "children" in child:
                    results += collect(child)
            return results
        return collect(data)

    if __name__ == "__main__":
        backup_dir = Path(sys.argv[1])
        output_file = Path(sys.argv[2])

        if not backup_dir.exists():
            print(f"Backup directory {backup_dir} does not exist")
            sys.exit(0)

        try:
            backup_file = find_latest_backup_file(backup_dir)
            print(f"Processing: {backup_file}")
            data = read_jsonlz4(backup_file)
            bookmarks = extract_bookmarks(data)
            output_file.parent.mkdir(parents=True, exist_ok=True)

            with open(output_file, "w") as f:
                f.write("[\n")
                for b in bookmarks:
                    f.write(f'  {{ Title = "{b["Title"]}"; URL = "{b["URL"]}"; Placement = "{b["Placement"]}"; }}\n')
                f.write("]\n")

        except Exception as e:
            print(f"Error generating bookmarks: {e}")
            sys.exit(1)
  '';

  # 🦆 duck say ⮞ Static Default Bookmarks
  defaultBookmarks = [
    { Title = ""; URL = "http://192.168.1.28:8989"; Placement = "toolbar"; }
    { Title = ""; URL = "http://192.168.1.181:3000"; Placement = "toolbar"; }
    { Title = ""; URL = "http://192.168.1.28:7777"; Placement = "toolbar"; }
    { Title = ""; URL = "http://192.168.1.181:8124"; Placement = "toolbar"; }
    # 🦆 duck say ⮞ forums
    { Title = "Hacker News"; URL = "https://news.ycombinator.com"; Placement = "toolbar"; }
    { Title = "NixOS Discourse"; URL = "https://discourse.nixos.org"; Placement = "toolbar"; }
    { Title = "Lobsters"; URL = "https://lobste.rs"; Placement = "toolbar"; }
    # 🦆 duck say ⮞ mail
    { Title = ""; URL = "https://account.proton.me/login"; Favicon = "https://proton.me/favicon.ico"; Placement = "toolbar"; }
    { Title = ""; URL = "https://www.outlook.com"; Favicon = "https://outlook.live.com/owa/favicon.ico"; Placement = "toolbar"; }
    # 🦆 duck say ⮞ other links
    { Title = ""; URL = "https://www.github.com"; Favicon = "https://github.githubassets.com/favicons/favicon.ico"; Placement = "toolbar"; }
    { Title = ""; URL = "https://www.pastebin.org"; Favicon = "https://pastebin.com/favicon.ico"; Placement = "toolbar"; }
    { Title = ""; URL = "https://www.chatgpt.com"; Favicon = "https://openai.com/favicon.ico"; Placement = "toolbar"; }
    # 🦆 duck say ⮞ servarr
    { Title = "Transmission"; URL = "http://${arrHostIP}:9091"; Favicon = "http://${arrHostIP}:9091/favicon.ico"; Placement = "toolbar"; }
    { Title = "Radarr"; URL = "http://${arrHostIP}:7878"; Favicon = "http://${arrHostIP}:7878/favicon.ico"; Placement = "toolbar"; }
    { Title = "Sonarr"; URL = "http://${arrHostIP}:8989"; Favicon = "http://${arrHostIP}:8989/favicon.ico"; Placement = "toolbar"; }
    { Title = "Lidarr"; URL = "http://${arrHostIP}:8686"; Favicon = "http://${arrHostIP}:8686/favicon.ico"; Placement = "toolbar"; }
    { Title = "Readarr"; URL = "http://${arrHostIP}:8787"; Favicon = "http://${arrHostIP}:8787/favicon.ico"; Placement = "toolbar"; }
    { Title = "Bazarr"; URL = "http://${arrHostIP}:6767"; Favicon = "http://${arrHostIP}:6767/favicon.ico"; Placement = "toolbar"; }
    { Title = "Prowlarr"; URL = "http://${arrHostIP}:9696"; Favicon = "http://${arrHostIP}:9696/favicon.ico"; Placement = "toolbar"; }
    { Title = "Jellyseer"; URL = "http://${arrHostIP}:5055"; Favicon = "http://${arrHostIP}:5055/favicon.ico"; Placement = "toolbar"; }
    { Title = "Requesterr"; URL = "http://${arrHostIP}:4545"; Favicon = "http://${arrHostIP}:4545/favicon.ico"; Placement = "toolbar"; }
    { Title = "Navidrome"; URL = "http://${arrHostIP}:4533"; Favicon = "http://${arrHostIP}:4533/favicon.ico"; Placement = "toolbar"; }
  ];

  # 🦆 duck say ⮞ Create bookmarks JSON from lz4
  generatedBookmarks = pkgs.runCommand "firefox-bookmarks.json" {
    nativeBuildInputs = [ pkgs.lz4 pythonEnv pkgs.jq ];
  } ''
    if [ ! -d "${backupPath}" ] || [ -z "$(ls -A "${backupPath}" 2>/dev/null)" ]; then
      echo "No backups found - using default bookmarks"
      echo '${builtins.toJSON defaultBookmarks}' > $out
    else
      echo "Processing backups..."
      ${bookmarkScript} "${backupPath}" "$out.tmp" && mv "$out.tmp" $out || {
        echo "Backup processing failed - falling back to defaults"
        echo '${builtins.toJSON defaultBookmarks}' > $out
      }
    fi
  '';

# 🦆 duck say ⮞ SEARCH ENGINES =====================================#
  searchJson = builtins.toJSON {
    "metaData" = { # 🦆 duck say ⮞ default search engine
      "searchDefault" = "ddg";
      "current" = "ddg";
      "useSavedOrder" = true;
    }; # 🦆 duck say ⮞ all search engines
    "engines" = [
      { # 🦆 duck say ⮞ QUACK QUACK LET'z GOO!
        "_name" = "DuckDuckGo";
        "_shortName" = "ddg";
        "_loadPath" = "[app]/defaults/search/duckduckgo.xml";
        "_metaData" = { "order" = 0; };
        "_definedAliases" = [ "ddg" ];
      }
      { # 🦆 duck say ⮞ Search Nix Packages
        "_name" = "Nix Packages";
        "_shortName" = "np";
        "_loadPath" = "[other]/nixpkgs.xml";
        "_metaData" = { "order" = 1; };
        "_urls" = [{
          template = "https://search.nixos.org/packages";
          params = [
            { name = "type"; value = "packages"; }
            { name = "query"; value = "{searchTerms}"; }
          ];
        }];
        "_iconURL" = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
        "_definedAliases" = [ "@np" ];
      }
      { # 🦆 duck say ⮞ Search NixOS Options
        "_name" = "NixOS Options";
        "_shortName" = "no";
        "_loadPath" = "[other]/nixoptions.xml";
        "_metaData" = { "order" = 2; };
        "_urls" = [{
          template = "https://search.nixos.org/options";
          params = [
            { name = "channel"; value = "unstable"; }
            { name = "query"; value = "{searchTerms}"; }
          ];
        }];
        "_iconURL" = "https://search.nixos.org/favicon.ico";
        "_definedAliases" = [ "@no" ];
      }
      { # 🦆 duck say ⮞ Search NixOS Wiki
        "_name" = "NixOS Wiki";
        "_shortName" = "nw";
        "_loadPath" = "[other]/nixwiki.xml";
        "_metaData" = { "order" = 3; };
        "_urls" = [{
          template = "https://wiki.nixos.org/index.php?search={searchTerms}";
        }];
        "_iconURL" = "https://wiki.nixos.org/favicon.png";
        "_definedAliases" = [ "@nw" ];
      }
      { # 🦆 duck say ⮞ Search GitHub
        "_name" = "GitHub";
        "_shortName" = "gh";
        "_loadPath" = "[other]/github.xml";
        "_metaData" = { "order" = 4; };
        "_urls" = [{
          template = "https://github.com/search?q={searchTerms}";
        }];
        "_iconURL" = "https://github.githubassets.com/favicons/favicon.svg";
        "_definedAliases" = [ "@gh" ];
      }
      { # 🦆 duck say ⮞ Search Home Manager
        "_name" = "Home Manager";
        "_shortName" = "hm";
        "_loadPath" = "[other]/homemanager.xml";
        "_metaData" = { "order" = 5; };
        "_urls" = [{
          template = "https://home-manager-options.extranix.com/?query={searchTerms}&release=release-24.05";
        }];
        "_iconURL" = "https://avatars.githubusercontent.com/u/23828321?s=200&v=4";
        "_definedAliases" = [ "@hm" ];
      }
      { # 🦆 duck say ⮞ Search Tradera
        "_name" = "Tradera";
        "_shortName" = "tr";
        "_loadPath" = "[other]/tradera.xml";
        "_metaData" = { "order" = 6; };
        "_urls" = [{
          template = "https://www.tradera.com/search?q={searchTerms}";
        }];
        "_iconURL" = "https://www.tradera.com/favicon.ico";
        "_definedAliases" = [ "@tr" ];
      }
      { # 🦆 duck say ⮞ Search Hitta
        "_name" = "Hitta";
        "_shortName" = "hi";
        "_loadPath" = "[other]/hitta.xml";
        "_metaData" = { "order" = 7; };
        "_urls" = [{
          template = "https://www.hitta.se/s%C3%B6k?vad={searchTerms}";
        }];
        "_iconURL" = "https://www.hitta.se/favicon.ico";
        "_definedAliases" = [ "@hi" ];
      }
      { # 🦆 duck say ⮞ Google Search
        "_name" = "Google";
        "_shortName" = "google";
        "_loadPath" = "[app]/defaults/search/google.xml";
        "_metaData" = {
          "alias" = "@g";
        };
        "_definedAliases" = [ "@g" ];
      }
      { # 🦆 duck say ⮞ Searchh Bing
        "_name" = "Bing";
        "_shortName" = "bing";
        "_loadPath" = "[app]/defaults/search/bing.xml";
        "_metaData" = {
          "hidden" = true;
        };
      }
    ];
  };


  # 🦆 duck say ⮞ start-page bookmarkz from sibling woo
  bmData    = import ./../../home/bookmarks.nix;
  bmMeta    = bmData.categories;
  bmAll     = bmData.bookmarks;

  # 🦆 duck say ⮞ group by categoriiii
  bmGrouped = builtins.foldl' (acc: bm:
    let cat = bm.category or "Other";
    in acc // { ${cat} = (acc.${cat} or []) ++ [ bm ]; }
  ) {} bmAll;

  # 🦆 duck say ⮞ category order: first-seen order, "Other" forced last
  bmSeen = builtins.foldl' (acc: bm:
    let cat = bm.category or "Other";
    in if builtins.elem cat acc then acc else acc ++ [ cat ]
  ) [] bmAll;
  bmOrdered =
    (builtins.filter (c: c != "Other") bmSeen)
    ++ lib.optionals (builtins.elem "Other" bmSeen) [ "Other" ];

  bmRender = bm: ''
    <a class="link" href="${bm.url}">
      <span class="link-icon">${bm.icon or "◇"}</span>
      <span class="link-name">${bm.title or bm.url}</span>
    </a>
  '';

  bmRenderCat = cat:
    let
      meta = bmMeta.${cat} or { icon = "◆"; description = ""; };
      bms  = bmGrouped.${cat} or [];
    in ''
      <section class="category">
        <button class="category-header" type="button" aria-expanded="false">
          <span class="category-icon">${meta.icon}</span>
          <span>
            <span class="category-name">${cat}</span>
            <span class="category-description">${meta.description}</span>
          </span>
          <span class="chevron">⌄</span>
        </button>
        <div class="links">
          <div class="links-inner">
            ${lib.concatMapStrings bmRender bms}
          </div>
        </div>
      </section>
    '';

  categoriesHtml = lib.concatMapStrings bmRenderCat bmOrdered;

  # 🦆 duck say ⮞ quickly add a new bookmark in terminal with: "bm URL"
  bookmarksFile = config.this.user.me.dotfilesDir + "/home/bookmarks.nix";
  bmScript = pkgs.writeShellScriptBin "bm" ''
    #!/usr/bin/env bash
    set -euo pipefail

    BOOKMARKS_FILE="''${BOOKMARKS_FILE:-${bookmarksFile}}"
    MARKER="# 🦆 say ⮞ new bookmarkz added here by a quick-scriopt"

    usage() {
      echo "usage: bm <url> [title] [category] [icon]" >&2
      echo "  bm https://example.com" >&2
      echo "  bm https://example.com 'Example' Work '◈'" >&2
      exit 1
    }
    [ $# -ge 1 ] || usage
    url="$1"
    title="''${2:-}"
    category="''${3:-}"
    icon="''${4:-}"
    if [ ! -f "$BOOKMARKS_FILE" ]; then
      echo "BOOKMARKS: bookmarks file not found: $BOOKMARKS_FILE" >&2
      exit 1
    fi
    if grep -qF "url = \"$url\"" "$BOOKMARKS_FILE"; then
      echo "BOOKMARK: '$url' already present — skipping" >&2
      exit 0
    fi
    if ! grep -qF "$MARKER" "$BOOKMARKS_FILE"; then
      echo "BOOKMARK: marker '$MARKER' not found in $BOOKMARKS_FILE" >&2
      exit 1
    fi
    entry="    { "
    [ -n "$title" ]    && entry+="title = \"$title\"; "
    entry+="url = \"$url\";"
    [ -n "$category" ] && entry+=" category = \"$category\";"
    [ -n "$icon" ]     && entry+=" icon = \"$icon\";"
    entry+=" }"
    tmp="$(mktemp)"
    awk -v entry="$entry" -v marker="$MARKER" '
      !done && index($0, marker) { print entry; done=1 }
      { print }
    ' "$BOOKMARKS_FILE" > "$tmp"
    mv "$tmp" "$BOOKMARKS_FILE"
    echo "BOOKMARK ADDED: $url"
  '';

  # 🦆 duck say ⮞ quickly browse with Tor using command: "foxytor"
  anonBrowsing = pkgs.writeShellScriptBin "foxytor" ''
    #!/usr/bin/env bash
    set -euo pipefail
    firejail --net=tornet --profile=~/.config/firejail/firefox.local torfox
  '';

  homepage.js   = builtins.readFile ./../themes/js/homepage.js;
  homepage.css  = builtins.readFile ./../themes/css/homepage.css;
in {
  # 🦆 duck say ⮞ enabled by exposing `"firefox"` in `this.host.modules.programs`
  config = lib.mkIf (lib.elem "firefox" cfg) {
    programs.firefox = {
      enable = true;
      package = pkgs.firefox-esr; # 🦆 duck say ⮞ ESR is a good option - required for search engines
      languagePacks = [ "en-US" ];

# 🦆 duck say ⮞ PREFERENCES ==========
      preferences = {
        # 🦆 duck say ⮞ USER AGENT
        # FIXME - BREAKKING logins with common services - like Google
        # https://explore.whatismybrowser.com/useragents/explore/operating_system_name/
        "general.useragent.locale" = "en-GB";
        "general.useragent.override" = "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Mobile Safari/537.36";
        # 🦆 duck say ⮞ HOMEPAGE / STARTPAGE / MY PAGE (we create diz down below yo yeeah)
        "browser.startup.homepage" = "file:///etc/homepage/homepage.html";
        "browser.search.region" = "GB";
        "browser.search.isUS" = false;
        "distribution.searchplugins.defaultLocale" = "en-GB";
        "browser.bookmarks.showMobileBookmarks" = true;
        "extensions.pocket.enabled" = false;
        "browser.toolbars.keyboard_navigation" = false;
        "browser.translations.automaticallyPopup" = false;
        "ui.systemUsesDarkTheme" = 1; # 🦆 duck say ⮞ Darkmode
        "devtools.theme" = "dark";
        "mousewheel.min_line_scroll_amount" = 4;
        "privacy.purge_trackers.enabled" = true;
        "privacy.resistFingerprinting" = true;
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "services.sync.prefs.sync.browser.uiCustomization.state" = true;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "browser.download.dir" = "/home/${config.this.user.me.name}/Downloads";
        "signon.rememberSignons" = false;
        # 🦆 duck say ⮞ FF Sync Server
        # "identity.sync.tokenserver.uri" = http://localhost:5000/1.0/sync/1.5;
        "browser.shell.checkDefaultBrowser" = false; # 🦆 duck say ⮞ pointless option
        "browser.newtabpage.enabled" = false;
        "browser.newtabpage.activity-stream.enabled" = false;
        "browser.newtabpage.activity-stream.telemetry" = false;
        "browser.urlbar.suggest.searches" = false;
        "browser.urlbar.shortcuts.bookmarks" = false;
        "browser.urlbar.shortcuts.history" = false;
        "browser.urlbar.shortcuts.tabs" = false;
        "browser.urlbar.showSearchSuggestionsFirst" = false;
        "browser.urlbar.speculativeConnect.enabled" = false;
        "browser.urlbar.dnsResolveSingleWordsAfterSearch" = 0;
        "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
        "browser.urlbar.suggest.quicksuggest.sponsored" = false;
        "browser.urlbar.trimURLs" = false;
        "browser.disableResetPrompt" = true;
        "browser.onboarding.enabled" = false;
        "browser.aboutConfig.showWarning" = false;
        "media.videocontrols.picture-in-picture.video-toggle.enabled" = false;
        "extensions.shield-recipe-client.enabled" = false;
        "reader.parse-on-load.enabled" = false;
        "browser.search.separatePrivateDefault.ui.enabled" = true;
        "security.family_safety.mode" = 0;
        "security.pki.sha1_enforcement_level" = 1;
        "security.tls.enable_0rtt_data" = false;
        "geo.provider.network.url" = "https://location.services.mozilla.com/v1/geolocate?key=%MOZILLA_API_KEY%";
        "geo.provider.use_gpsd" = false;
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr" = false;
        "extensions.htmlaboutaddons.recommendations.enabled" = false;
        "extensions.htmlaboutaddons.discover.enabled" = false;
        "extensions.getAddons.showPane" = false;
        "browser.discovery.enabled" = false;
        "browser.sessionstore.interval" = 1800000;
        "dom.battery.enabled" = false;
        "beacon.enabled" = false;
        "browser.send_pings" = false;
        "dom.gamepad.enabled" = false;
        "browser.fixup.alternate.enabled" = false;
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.server" = "data:,";
        "toolkit.telemetry.archive.enabled" = false;
        "toolkit.telemetry.coverage.opt-out" = true;
        "toolkit.coverage.opt-out" = true;
        "toolkit.coverage.endpoint.base" = "";
        "experiments.supported" = false;
        "experiments.enabled" = false;
        "experiments.manifest.uri" = "";
        "browser.ping-centre.telemetry" = false;
        "app.normandy.enabled" = false;
        "app.normandy.api_url" = "";
        "app.shield.optoutstudies.enabled" = false;
        "datareporting.healthreport.uploadEnabled" = false;
        "datareporting.healthreport.service.enabled" = false;
        "datareporting.policy.dataSubmissionEnabled" = false;
        "breakpad.reportURL" = "";
        "browser.tabs.crashReporting.sendReport" = false;
        "browser.tabs.allowTabDetach" = false; # 🦆 duck say ⮞  annoying
        "browser.tabs.hoverPreview.enabled" = false;
        "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;
        "clipboard.autocopy" = true;
        "content.cors.disable" = false;
        "devtools.browserconsole.enableNetworkMonitoring" = true;
        "devtools.browserconsole.filter.css" = true;
        "devtools.cache.disabled" = true; # 🦆 duck say ⮞ seriously stupid default
        "devtools.debugger.auto-pretty-print" = true;
        "network.websocket.allowInsecureFromHTTPS" = false; # 🦆say⮞can be useful for quick testing
        "security.mixed_content.block_active_content" = true; # 🦆say⮞can be useful for quick testing
        "browser.formfill.enable" = false;
        "extensions.formautofill.addresses.enabled" = false;
        "extensions.formautofill.available" = "off";
        "extensions.formautofill.creditCards.available" = false;
        "extensions.formautofill.creditCards.enabled" = false;
        "extensions.formautofill.heuristics.enabled" = false;
        "zoom.maxPercent" = 400;
        "zoom.minPercent" = 40;
      };

# 🦆 duck say ⮞ POLICIES ====================#
      policies = {
        NoDefaultBookmarks = true; # 🦆 duck say ⮞ i prefer duckiez bookmarkz
        DisableTelemetry = true; # 🦆 duck say ⮞ eeeehh...
        DisablePocket = true; # 🦆 duck say ⮞ Pocket & Bucket - who namez theze stuffz..?
        DisableFirefoxAccounts = true;
        DisableAccounts = true;

# 🦆 duck say ⮞ BOOKMARKS ==============================#
        Bookmarks =  lib.mkMerge [
          (lib.mkIf (builtins.pathExists generatedBookmarks) {
            __content = builtins.fromJSON (builtins.readFile generatedBookmarks);
          })
          {
            __content = defaultBookmarks;
            __priority = 100;
          }
        ];

# 🦆 duck say ⮞ AddOns - Extensions =====================#
        ExtensionSettings = {
          "*".installation_mode = "blocked"; # blocks all addons except the ones specified below
          # 🦆 duck say ⮞ Super Dark Mode
          # 🦆 duck say ⮞ diz iz nizeii for blind duckii eyezzii
          "{be3295c2-d576-4a7c-9987-a21844164dbb}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/file/4062840/super_dark_mode-5.0.2.5.xpi";
            installation_mode = "force_installed";
          };
          # 🦆 duck say ⮞ uBlock
          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
          };
          # 🦆 duck say ⮞ Privacy Badger
          "jid1-MnnxcxisBPnSXQ@jetpack" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/privacy-badger17/latest.xpi";
            installation_mode = "force_installed";
          };
          # 🦆 duck say ⮞ ProtonPass
          "78272b6fa58f4a1abaac99321d503a20@proton.me" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/file/4401514/proton_pass-1.26.0.xpi";
            installation_mode = "force_installed";
          };
          # 🦆 duck say ⮞KeePassHttpConnector
          "keepasshttp-connector@addons.brandt.tech" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/file/4273043/keepasshttp_connector-1.0.12resigned1.xpi";
            installation_mode = "force_installed";
          };
        };
      };
    };

# 🦆 duck say ⮞ SEARCH ENGINES ==========
    # 🦆 duck say ⮞ Create profile.ini
    systemd.services.firefox-profile = {
      wantedBy = [ "default.target" ];
      serviceConfig = {
        Type = "oneshot";
        User = config.this.user.me.name;
        ExecStart = let
          script = pkgs.writeShellScriptBin "firefox-init" ''
            mkdir -p "${firefoxProfileDir}/chrome"

            cat > "${firefoxProfileDir}/../profiles.ini" <<EOF
[Profile0]
Name=default
IsRelative=1
Path=default
Default=1

[General]
StartWithLastProfile=1
Version=2
EOF

            # 🦆 duck say ⮞ Compress search.json to mozlz4 format
            echo '${searchJson}' | ${pkgs.mozlz4a}/bin/mozlz4a - > "${firefoxProfileDir}/search.json.mozlz4"

# 🦆 duck say ⮞ USERCHROME.CSS STYLE =====================#
            # 🦆 duck say ⮞ Create userChrome.css
            cat > "${firefoxProfileDir}/chrome/userChrome.css" <<EOF
            ${themeCSS}
            EOF

            # 🦆 duck say ⮞ Merge generated bookmarks
            echo "Linking generated bookmarks..."
            ln -sf ${generatedBookmarks} ${firefoxProfileDir}/generated-bookmarks.nix

            # 🦆 duck say ⮞ Seed initial backup if none exists
            if [ ! -d "${backupPath}" ] || [ -z "$(ls -A "${backupPath}")" ]; then
              mkdir -p "${backupPath}"
              echo '${builtins.toJSON defaultBookmarks}' | ${pkgs.mozlz4a}/bin/mozlz4a - > \
                "${backupPath}/bookmarks-$(date +%s).jsonlz4"
            fi

            chown -R ${config.this.user.me.name}:users "/home/${config.this.user.me.name}/.mozilla"
            chmod 700 "${firefoxProfileDir}"
            chmod 600 "${firefoxProfileDir}/../profiles.ini"
          '';
        in "${script}/bin/firefox-init";
      };
    };

    # 🦆 duck say ⮞ dependencies
    environment.systemPackages = [
      pkgs.mozlz4a
      pkgs.firefox-esr
      pkgs.python312Packages.lz4
      anonBrowsing
      bmScript
    ];

    environment.sessionVariables = { MOZ_USE_XINPUT2 = "1"; };

    # 🦆 duck say ⮞ Allow access to Firefox backup directory
    nix.settings.allowed-uris = [
      "file://${config.users.users.${config.this.user.me.name}.home}/.mozilla"
    ];


    # 🦆 duck say ⮞ create da start page yay
    environment.etc."homepage/homepage.html".text = ''
      <!DOCTYPE html>
      <html lang="en">
      <head>
          <!-- META -->
          <meta charset="UTF-8">
          <title>Homepage » </title>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <link rel="preconnect" href="https://fonts.googleapis.com">
          <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
          <link href="https://fonts.googleapis.com/css2?family=Cinzel+Decorative:wght@700;800;900&display=swap" rel="stylesheet">
          <meta name="apple-mobile-web-app-capable" content="yes">
          <meta name="apple-mobile-web-app-status-bar-style" content="default">
          <meta name="apple-mobile-web-app-title" content="🦯🦆">
          <link rel="icon" href="/etc/homepage/favicon.ico" sizes="any">
          <link rel="icon" type="image/png" sizes="32x32" href="favicon-32x32.png">
          <link rel="apple-touch-icon" sizes="180x180" href="apple-touch-icon.png">
          <meta name="theme-color" content="#050707">
          <script src="/home/pungkula/dotfiles/modules/themes/js/homepage.js" defer></script>
          <!-- <link rel="stylesheet" href="/home/pungkula/dotfiles/modules/themes/css/homepage.css">  -->
          <style>
              ${homepage.css}
          </style>

      </head>
      <body>
      <header>
          <img src="/home/pungkula/dotfiles/modules/themes/images/banner.png" alt="" style="display: block; margin: 1rem auto; width: min(600px, 80vw); height: auto;">

      </header>

      <main>

          <div class="ip">
              <span class="ip-light"></span>
              <span>PUBLIC IP</span>
              <span id="ip-address">loading...</span>
          </div>
          <div class="clock-wrapper">
              <div class="clock" id="clock">
                  00<span class="colon">:</span>00<span class="colon">:</span>00
              </div>
              <div class="date" id="date">
                  Wednesday · 16 September 2026
              </div>
          </div>

          <div class="section-label">
              bookmarks
          </div>

          <!--🦆 duck say ⮞ insert ma bookmark -->
          <div class="categories">
              ${categoriesHtml}
          </div>

          <div class="search">
              <input
                  id="search"
                  type="text"
                  placeholder="Search the web..."
                  autocomplete="off"
                  spellcheck="false"
              >
              <span class="search-icon">⌕</span>
          </div>

          <footer>
              <span class="diamond">◆</span>
              QuackHack-McBLindy
              <span class="diamond">◆</span>
          </footer>
      </main>
      </body>
      </html>
    '';

    # 🦆 duck say ⮞ create da homepage in da dedicated & secured dir
    environment.etc."homepage/favicon.ico".source                = ./../themes/icons/favicons/duckdash/favicon.ico;
    environment.etc."homepage/favicon-16x16.png".source           = ./../themes/icons/favicons/duckdash/favicon-16x16.png;
    environment.etc."homepage/favicon-32x32.png".source          = ./../themes/icons/favicons/duckdash/favicon-32x32.png;
    environment.etc."homepage/apple-touch-icon.png".source       = ./../themes/icons/favicons/duckdash/apple-touch-icon.png;
    environment.etc."homepage/android-chrome-192x192.png".source = ./../themes/icons/favicons/duckdash/android-chrome-192x192.png;
    environment.etc."homepage/android-chrome-512x512.png".source = ./../themes/icons/favicons/duckdash/android-chrome-512x512.png;


    # 🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆
    # POOL IS CLOSED DUE TO AIDS
    # 🦆 duck say ⮞ LETZZ GO ANONYMOUS
    # 🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆
    programs.firejail = {
      enable = true;
      wrappedBinaries = {
        torfox = {
          executable = "${pkgs.firefox-esr}/bin/firefox-esr";
          profile = "${pkgs.firejail}/etc/firejail/firefox.profile";
          desktop = torfoxDesktopEntry;
          extraArgs = [
            "--ignore=private-dev"
            "--env=GTK_THEME=Adwaita:dark"
            "--dbus-user.talk=org.freedesktop.Notifications"
            "--net=tornet"
            "--dns=46.182.19.48"
          ];
        };
      };
    };

    services.tor = {
      enable = true;
      openFirewall = true;
      settings = {
        TransPort = [ 9040 ];
        DNSPort = 5353;
        VirtualAddrNetworkIPv4 = "172.30.0.0/16";
      };
    };

    networking = {
      networkmanager = {
        enable = true;
        ensureProfiles.profiles = {
          tornet = {
            connection = {
              id = "tornet";
              type = "bridge";
              interface-name = "tornet";
              autoconnect = true;
            };
            bridge = {
              stp = false;
            };
            ipv4 = {
              method = "manual";
              address1 = "10.100.100.1/24";
            };
            ipv6 = {
              method = "disabled";
            };
          };
        };
      };

      nftables = {
        enable = true;
        ruleset = ''
          table ip nat {
            chain PREROUTING {
              type nat hook prerouting priority dstnat; policy accept;
              iifname "tornet" meta l4proto tcp dnat to 127.0.0.1:9040
              iifname "tornet" udp dport 53 dnat to 127.0.0.1:5353
            }
          }
        '';
      };

      nat = {
        internalInterfaces = [ "tornet" ];
        forwardPorts = [
          {
            destination = "127.0.0.1:5353";
            proto = "udp";
            sourcePort = 53;
          }
        ];
      };

      firewall = {
        enable = true;
        interfaces.tornet = {
          allowedTCPPorts = [ 9040 ];
          allowedUDPPorts = [ 5353 ];
        };
      };
    };

    boot.kernel.sysctl = {
      "net.ipv4.conf.tornet.route_localnet" = 1;
    };

  };} # 🦆 duck say ⮞ dat'z it, yo!
# 🦆 duck say ⮞ dat wasn't so bad, huh?
# 🦆 duck say ⮞ catch u laterz, aligatorz!
