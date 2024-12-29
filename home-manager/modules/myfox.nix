{ config, pkgs, lib, ... }:
{
    programs.firefox = {
        enableGnomeExtensions = true;
        enable = true;
      #  nativeMessagingHosts = [ "pkgs.gsconnect" ];
        package = pkgs.firefox-esr;
  #    nativeMessagingHosts = [ pkgs.tridactyl-native ];
      #nativeMessagingHosts.tridactyl = true;
     # nativeMessagingHosts.packages = [];
        languagePacks = [ "en-US" ];
        policies = {
            Homepage = "http://192.168.1.181:3000";
            Preferences = [
                {
                
                }
            ];
            PasswordManagerEnabled = false;
            MoDefaultBookmarks = true;
            DisableTelemetry = true;
            DisableFirefoxStudies = true;
            EnableTrackingProtection = {
                Value = true;
                Locked = true;
                Cryptomining = true;
                Fingerprinting = true;
            };
            DisablePocket = true;
            DisableFirefoxAccounts = true;
            DisableAccounts = true;
            DisableFirefoxScreenshots = true;
            OverrideFirstRunPage = "";
            OverridePostUpdatePage = "";
            DontCheckDefaultBrowser = true;
            DisplayBookmarksToolbar = "always"; # alternatives: "always" or "newtab"
            DisplayMenuBar = "default-off"; # alternatives: "always", "never" or "default-on"
            SearchBar = "unified"; # alternative: "separate"
            #SecurityDevices = {
            #    "add" = {
            #        type =
            #    };
                
                    
            Bookmarks = [
                { Title = ""; URL = "http://192.168.1.181:3000"; }
                { Title = ""; URL = "http://192.168.1.28:7777"; }
                { Title = ""; URL = "http://192.168.1.181:8124"; }
                { Title = ""; URL = "https://www.protonmail.com"; }
                { Title = ""; URL = "https://www.outlook.com"; }
                { Title = ""; URL = "https://www.github.com"; }
                { Title = ""; URL = "https://www.pastebin.org"; }
                { Title = ""; URL = "https://www.chatgpt.com"; Favicon = ""; Placement = "toolbar"; }           
            ];
            SearchEngines = {
                "Brave" = {
                    urls = [{template = "https://search.brave.com/search?q={searchTerms}";}];
                    definedAliases = ["@b"];
                    iconUpdateURL = "https://brave.com/static-assets/images/brave-logo-sans-text.svg";
                };
                "GitHub" = {
                    urls = [{template = "https://github.com/search?q={searchTerms}";}];
                    definedAliases = ["@gh"];
                    iconUpdateURL = "https://brave.com/static-assets/images/brave-logo-sans-text.svg";
                };
        
            };	
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
    
}    
