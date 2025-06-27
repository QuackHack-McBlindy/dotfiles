# dotfiles/modules/programs/firefox.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 duck say ⮞ diz iz my 🦊 even tho i be a 🦆
  config,
  lib, # 🦆 says ⮞ 📌 FEATURES:
  pkgs,  # 🦆 says ⮞ ⭐ Dynamic bookmarks from LZ4 backups & fallback to Nix declarative defined bookmarks
  ...    # 🦆 says ⮞ ⭐ Custom search engines, hardened privacy prefs, systemd applied FF-profile setup & system CSS theming
} : let  # 🦆 says ⮞ ⭐ Declarative Firefox Extensions (Addons)
  
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
    { Title = ""; URL = "https://account.proton.me/login"; Favicon = "https://proton.me/favicon.ico"; Placement = "toolbar"; }
    { Title = ""; URL = "https://www.outlook.com"; Favicon = "https://outlook.live.com/owa/favicon.ico"; Placement = "toolbar"; }
    { Title = ""; URL = "https://www.github.com"; Favicon = "https://github.githubassets.com/favicons/favicon.ico"; Placement = "toolbar"; }
    { Title = ""; URL = "https://www.pastebin.org"; Favicon = "https://pastebin.com/favicon.ico"; Placement = "toolbar"; }
    { Title = ""; URL = "https://www.chatgpt.com"; Favicon = "https://openai.com/favicon.ico"; Placement = "toolbar"; } 
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
        # 🦆 duck say ⮞ Homepage
        "browser.startup.homepage" = "http://localhost:3001"; 
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
        "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;
        "browser.formfill.enable" = false;
        "extensions.formautofill.addresses.enabled" = false;
        "extensions.formautofill.available" = "off";
        "extensions.formautofill.creditCards.available" = false;
        "extensions.formautofill.creditCards.enabled" = false;
        "extensions.formautofill.heuristics.enabled" = false;         
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
    environment.systemPackages = [ pkgs.mozlz4a pkgs.firefox-esr pkgs.python312Packages.lz4 ];
    environment.sessionVariables = { MOZ_USE_XINPUT2 = "1"; };    
    
    # 🦆 duck say ⮞ Allow access to Firefox backup directory
    nix.settings.allowed-uris = [
      "file://${config.users.users.${config.this.user.me.name}.home}/.mozilla"
    ];
  };} # 🦆 duck say ⮞ dat'z it, yo!
# 🦆 duck say ⮞ dat wasn't so bad, huh?  
# 🦆 duck say ⮞ catch u laterz, aligatorz!
