{ 
  config,
  lib,
  pkgs,
  ...
} : {
    config = lib.mkIf (lib.elem "firefox" config.this.host.modules.programs) {
      programs.firefox = {
        enable = true;
        languagePacks = [ "en-US" ];
        package = pkgs.firefox-esr;

#########################################
###### > about:profiles < ###############
        profiles.default = {
     
          # Settings
          settings = { 
          
        # USER AGENT FIXME Breaks login with common services like Google 
        # https://explore.whatismybrowser.com/useragents/explore/operating_system_name/
            "general.useragent.locale" = "en-GB";
            "general.useragent.override" = "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Mobile Safari/537.36";

        # GENERAL            
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
        # PASS
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
          
          # CSS STYLING 
 #         userChrome =
  #        ''

          
          # SEARCH ENGINES
          search.default = "ddg";
          search.engines =
          {
            "Nix Packages" = {
              urls = [{
                template = "https://search.nixos.org/packages";
                params = [
                  { name = "type"; value = "packages"; }
                  { name = "query"; value = "{searchTerms}"; }
                ];
              }];

             icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@np" ];
            };
            
            "NixOS Options" = {
              urls = [{ template = "https://search.nixos.org/options?channel=unstable&from=0&size=50&sort=relevance&type=packages&query={searchTerms}"; }];
              icon = "https://search.nixos.org/favicon.ico";
              updateInterval = 24 * 60 * 60 * 1000; # every day
              definedAliases = [ "@no" ];
             };

            "NixOS Wiki" = {
              urls = [{ template = "https://wiki.nixos.org/index.php?search={searchTerms}"; }];
              icon = "https://wiki.nixos.org/favicon.png";
              updateInterval = 24 * 60 * 60 * 1000; # every day
              definedAliases = [ "@nw" ];
            };
 
            "GitHub" = {
              urls = [{ template = "https://github.com/search?q={searchTerms}"; }];
              icon = "https://github.githubassets.com/favicons/favicon.svg";
              definedAliases = [ "@gh" ];
            };

            "Home Manager" = {
              urls = [{
                template = "https://home-manager-options.extranix.com/?query={searchTerms}&release=release-24.05";
              }];
              icon = "https://avatars.githubusercontent.com/u/23828321?s=200&v=4"; # Home Manager GitHub icon
              definedAliases = [ "@hm" ];
            };

            "Tradera" = {
              urls = [{ template = "https://www.tradera.com/search?q={searchTerms}"; }];
              icon = "https://www.tradera.com/favicon.ico";
              updateInterval = 24 * 60 * 60 * 1000; # every day
              definedAliases = [ "@tr" ];
            };
            
            "Hitta" = {
              urls = [{ template = "https://www.hitta.se/s%C3%B6k?vad={searchTerms}"; }];
              icon = "https://www.hitta.se/favicon.ico";
              updateInterval = 24 * 60 * 60 * 1000; # every day
              definedAliases = [ "@hi" ];
            };

            "bing".metaData.hidden = true;
            "google".metaData.alias = "@g"; # builtin engines only support specifying one additional alias
          };
        }; 
      
      
#########################################        
####### > about:policies > https://mozilla.github.io/policy-templates   

        policies = {
          NoDefaultBookmarks = true;
          DisableTelemetry = true;
          DisablePocket = true;
          DisableFirefoxAccounts = true;
          DisableAccounts = true;
          
          # BOOKMARKS
          Bookmarks = [
              { Title = ""; URL = "http://192.168.1.181:3000"; Favicon = ""; Placement = "toolbar"; }    
              { Title = ""; URL = "http://192.168.1.28:7777"; Favicon = ""; Placement = "toolbar"; }    
              { Title = ""; URL = "http://192.168.1.181:8124"; Favicon = ""; Placement = "toolbar"; }    
              
              { Title = ""; URL = "https://account.proton.me/login"; Favicon = "https://proton.me/favicon.ico"; Placement = "toolbar"; }    
              { Title = ""; URL = "https://www.outlook.com"; Favicon = "https://outlook.live.com/owa/favicon.ico"; Placement = "toolbar"; }  
              
              { Title = ""; URL = "https://www.github.com"; Favicon = "https://github.githubassets.com/favicons/favicon.ico"; Placement = "toolbar"; }    
              { Title = ""; URL = "https://www.pastebin.org"; Favicon = "https://pastebin.com/favicon.ico"; Placement = "toolbar"; }  
              
              { Title = ""; URL = "https://www.chatgpt.com"; Favicon = "https://openai.com/favicon.ico"; Placement = "toolbar"; }      
              
          ];
          
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
    };};}
