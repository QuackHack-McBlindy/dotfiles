# FIREFOX_PROFILE_DIR=$(find ~/.mozilla/firefox -maxdepth 1 -type d -name "*.default*" | head -n1)
{ config, lib, pkgs, ... }: 
let
  cfg = config.this.host.modules.programs;
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
        
            # Compress search.json to mozlz4 format CORRECTLY
            echo '${searchJson}' | ${pkgs.mozlz4a}/bin/mozlz4a - > "${firefoxProfileDir}/search.json.mozlz4"
        
#======= USERCHROME.CSS STYLE =====================#        
            # Create userChrome.css
            cat > "${firefoxProfileDir}/chrome/userChrome.css" <<EOF
            #PersonalToolbar { visibility: visible !important; }
            #TabsToolbar { visibility: collapse !important; background: #ff0000 !important; }
            
            /* Personal Toolbar (Bookmarks Bar) */
            #PersonalToolbar {
                visibility: visible !important;
                background-color: #1e1e1e !important; /* Dark background */
                color: #ffcc00 !important; /* Yellow text */
                font-size: 14px !important;
                font-family: 'Comic Sans MS', cursive, sans-serif !important; /* Comical font */
            }

            /* Tabs Toolbar - Hide and Change Background */
            #TabsToolbar {
                visibility: collapse !important; /* Hide tabs toolbar */
                background: linear-gradient(to right, #ff0000, #ff7300) !important; /* Red gradient */
                border-bottom: 3px solid #000 !important; /* Black border at the bottom */
            }

            /* Tab Styles - Colorful Tabs */
            .tabbrowser-tab {
                background-color: #00ff00 !important; /* Green background */
                color: black !important; /* Black text */
                font-weight: bold !important; /* Bold font */
                padding: 5px !important; /* Some padding for better appearance */
            }

            .tabbrowser-tab[selected="true"] {
                background-color: #ffff00 !important; /* Yellow for selected tab */
                color: #000 !important; /* Black text for the selected tab */
            }

            /* Hide Menubar */
            #menubar {
                visibility: collapse !important;
            }

            /* Cool Context Menu (Right Click Menu) */
            #contentAreaContextMenu {
                background-color: #333 !important; /* Dark background */
                color: #fff !important; /* White text */
                font-size: 13px !important;
            }

            /* Make the address bar stand out with a bright color */
            #urlbar {
                background-color: #00bfff !important; /* Bright Sky Blue */
                color: #fff !important; /* White text */
                font-size: 16px !important;
            }

            /* Customize the back and forward buttons */
            #back-button, #forward-button {
                background-color: #8b0000 !important; /* Dark red buttons */
                border-radius: 50% !important; /* Round buttons */
                color: white !important;
                width: 35px !important;
                height: 35px !important;
            }

            /* Make the browser window border look cool */
            window {
                border: 5px solid #ff00ff !important; /* Purple border */
            }
            
            /* 3D ROTATING UI ELEMENTS */
            #navigator-toolbox {
                transform: rotate3d(1, 1, 1, 15deg) !important;
                perspective: 1000px !important;
            }

            /* DISCO LIGHTS BACKGROUND */
            #main-window {
                background:
                    linear-gradient(45deg,
                        #ff00ff 25%,
                        #00ffff 25% 50%,
                        #ffff00 50% 75%,
                        #ff0000 75%
                    ) !important;
                background-size: 100px 100px !important;
                animation: disco 1s linear infinite !important;
            }

            @keyframes disco {
                from { background-position: 0 0; }
                to { background-position: 100px 100px; }
            }

            /* GLOWING NEON TEXT */
            #PersonalToolbar {
                text-shadow:
                    0 0 10px #ff00ff,
                    0 0 20px #ff00ff,
                    0 0 30px #ff00ff !important;
                font-family: 'Impact', fantasy !important;
                color: #00ffff !important;
            }

            /* FLYING EMOJI CURSORS */
            * {
                cursor: url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='40' height='40'><text x='5' y='30' font-size='30'>🚀</text></svg>") 16 16, auto !important;
            }

            /* RAINBOW ADDRESS BAR WITH FLOATING UNICORNS */
            #urlbar {
                background: linear-gradient(                                                                  90deg,
                    #ff0000 16%,
                    #ff8000 16% 32%,
                    #ffff00 32% 48%,
                    #00ff00 48% 64%,
                    #00ffff 64% 80%,
                    #8000ff 80%
                ) !important;
                border: 3px dotted #fff !important;
                box-shadow: 0 0 50px #fff !important;
            }

            #urlbar:before {
                content: "🦄✨🦄✨";
                position: absolute;
                animation: float 3s ease-in-out infinite;
            }

            @keyframes float {
                0% { transform: translateY(0); }
                50% { transform: translateY(-20px); }
                100% { transform: translateY(0); }
            }

            /* TABS THAT DANCE */
            .tabbrowser-tab {
                animation: dance 0.5s ease-in-out infinite alternate !important;
                transform-origin: bottom !important;
            }

            @keyframes dance {
                from { transform: rotate(-5deg); }
                to { transform: rotate(5deg); }
            }

            /* CYBERPUNK MATRIX SCROLLBAR */
            scrollbar {
                background: #000 !important;
                border-left: 2px solid #0f0 !important;
            }

            scrollbarthumb {
                background:
                    repeating-linear-gradient(
                        45deg,
                        #0f0,
                        #0f0 10px,
                        #000 10px,
                        #000 20px
                    ) !important;
                border: 1px solid #0f0 !important;
                box-shadow: 0 0 10px #0f0 !important;
            }

            /* RANDOMIZED PARTICLE BACKGROUND */
            #browser {
                position: relative;
                overflow: hidden !important;
            }

            #browser:after {
                content: "";
                position: fixed;
                width: 200%;
                height: 200%;
                background:
                    radial-gradient(circle, #ff0000 1px, transparent 1px),
                    radial-gradient(circle, #00ff00 1px, transparent 1px),
                    radial-gradient(circle, #0000ff 1px, transparent 1px);
                background-size: 50px 50px;
                animation: particles 20s linear infinite;
                mix-blend-mode: overlay;
                z-index: 9999;
            }

            @keyframes particles {
                from { transform: translate(0, 0); }
                to { transform: translate(-50px, -50px); }
            }

            /* VOID OF MADNESS HOVER EFFECT */
            toolbarbutton:hover {
                filter: hue-rotate(360deg) !important;
                transform: scale(5) rotate(3600deg) !important;
                transition: all 5s cubic-bezier(0.25, 2.5, 0.5, -5) !important;
            }
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
