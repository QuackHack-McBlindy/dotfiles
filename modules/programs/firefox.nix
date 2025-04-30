# FIREFOX_PROFILE_DIR=$(find ~/.mozilla/firefox -maxdepth 1 -type d -name "*.default*" | head -n1)
{ config, lib, pkgs, ... }: 
let
  cfg = config.this.host.modules.programs;
  themeCSS = builtins.readFile config.this.theme.styles;
  firefoxProfileDir = "/home/pungkula/.mozilla/firefox/default";
  
#======= SEARCH ENGINES =====================#       
  searchJson = builtins.toJSON {
    "metaData" = {
      "searchDefault" = "ddg";
      "current" = "";
      "useSavedOrder" = true; 
    };
    "engines" = [
      {
        "_name" = "DuckDuckGo";
        "_shortName" = "ddg";
        "_loadPath" = "[app]/defaults/search/duckduckgo.xml";
        "_metaData" = { "order" = 0; };
        "_definedAliases" = [ "ddg" ];
      }
      {
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
      {
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
      
      
      {
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
      {
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
      {
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
      {
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
      {
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
      {
        "_name" = "Google";
        "_shortName" = "google";
        "_loadPath" = "[app]/defaults/search/google.xml";
        "_metaData" = {
          "alias" = "@g";
        };
        "_definedAliases" = [ "@g" ];
      }
      {
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
  config = lib.mkIf (lib.elem "firefox" cfg) {
    programs.firefox = {
      enable = true;
      package = pkgs.firefox-esr;
      languagePacks = [ "en-US" ];

      # ========== PREFERENCES ==========
      preferences = {
        # USER AGENT FIXME Breaks login with common services like Google 
        # https://explore.whatismybrowser.com/useragents/explore/operating_system_name/
        "general.useragent.locale" = "en-GB";
        "general.useragent.override" = "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Mobile Safari/537.36";      
        "browser.startup.homepage" = "http://localhost:3001";
        "browser.search.region" = "GB";
        "browser.search.isUS" = false;
        "distribution.searchplugins.defaultLocale" = "en-GB";
        "browser.bookmarks.showMobileBookmarks" = true;
        "extensions.pocket.enabled" = false;
        "browser.toolbars.keyboard_navigation" = false;
        "browser.translations.automaticallyPopup" = false;
        "ui.systemUsesDarkTheme" = 1;
        "devtools.theme" = "dark";
        "mousewheel.min_line_scroll_amount" = 35;
        "privacy.purge_trackers.enabled" = true;
        "services.sync.prefs.sync.browser.uiCustomization.state" = true;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "browser.download.dir" = "/home/pungkula/Downloads";
        "signon.rememberSignons" = false;
        # FF Sync Server
        # "identity.sync.tokenserver.uri" = http://localhost:5000/1.0/sync/1.5;
        "browser.shell.checkDefaultBrowser" = false;
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

      # ========== POLICIES ==========
      policies = {
        NoDefaultBookmarks = true;
        DisableTelemetry = true;
        DisablePocket = true;
        DisableFirefoxAccounts = true;
        DisableAccounts = true;
       
#======= BOOKMARKS =====================#       
        Bookmarks = [
          { 
            Title = "Local Services";
            Placement = "toolbar";
            Type = "folder";
            Children = [
              { Title = "Service 1"; URL = "http://192.168.1.181:3000"; }
              { Title = "Service 2"; URL = "http://192.168.1.28:7777"; }
              { Title = "HA Dashboard"; URL = "http://192.168.1.181:8124"; }
            ];
          }
          { Title = ""; URL = "http://192.168.1.181:3000"; Placement = "toolbar"; }
          { Title = ""; URL = "http://192.168.1.28:7777"; Placement = "toolbar"; }
          { Title = ""; URL = "http://192.168.1.181:8124"; Placement = "toolbar"; }
          { Title = ""; URL = "https://account.proton.me/login"; Favicon = "https://proton.me/favicon.ico"; Placement = "toolbar"; }
          { Title = ""; URL = "https://www.outlook.com"; Favicon = "https://outlook.live.com/owa/favicon.ico"; Placement = "toolbar"; }
          { Title = ""; URL = "https://www.github.com"; Favicon = "https://github.githubassets.com/favicons/favicon.ico"; Placement = "toolbar"; }
          { Title = ""; URL = "https://www.pastebin.org"; Favicon = "https://pastebin.com/favicon.ico"; Placement = "toolbar"; }
          { Title = ""; URL = "https://www.chatgpt.com"; Favicon = "https://openai.com/favicon.ico"; Placement = "toolbar"; }
        ];

#======= AddOns - Extensions =====================#       
        # EXTENSIONS
        ExtensionSettings = {
          "*".installation_mode = "blocked"; # blocks all addons except the ones specified below
          # Super Dark Mode
          "{be3295c2-d576-4a7c-9987-a21844164dbb}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/file/4062840/super_dark_mode-5.0.2.5.xpi";
            installation_mode = "force_installed";
          };
          # uBlock
          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
          };
          # Privacy Badger
          "jid1-MnnxcxisBPnSXQ@jetpack" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/privacy-badger17/latest.xpi";
            installation_mode = "force_installed";
          };
          # ProtonPass
          "78272b6fa58f4a1abaac99321d503a20@proton.me" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/file/4401514/proton_pass-1.26.0.xpi";
            installation_mode = "force_installed";
          };
          "keepasshttp-connector@addons.brandt.tech" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/file/4273043/keepasshttp_connector-1.0.12resigned1.xpi";
            installation_mode = "force_installed";
          };      
        };
      };
    };

    # ========== SEARCH ENGINES ==========
    systemd.services.firefox-profile = {
      wantedBy = [ "default.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = let
          script = pkgs.writeShellScriptBin "firefox-init" ''
            # Create profile directory
            mkdir -p "${firefoxProfileDir}/chrome"
        
            # Compress search.json to mozlz4 format
            echo '${searchJson}' | ${pkgs.mozlz4a}/bin/mozlz4a - > "${firefoxProfileDir}/search.json.mozlz4"
        
#======= USERCHROME.CSS STYLE =====================#        
            # Create userChrome.css
            cat > "${firefoxProfileDir}/chrome/userChrome.css" <<EOF
            ${themeCSS}
            EOF
        
            # Set permissions
            chown -R pungkula:users "${firefoxProfileDir}"
            chmod 700 "${firefoxProfileDir}"
          '';
        in "${script}/bin/firefox-init";
      };
    };

    environment.systemPackages = [ pkgs.mozlz4a pkgs.firefox-esr ];
  };}  
