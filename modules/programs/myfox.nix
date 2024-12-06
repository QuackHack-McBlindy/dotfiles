{ config, lib, pkgs, ... }:

with lib;

let
  importedLists = [
    "https://filters.adtidy.org/extension/ublock/filters/3.txt"
    "smb://192.168.1.181/www/blocklist2.txt"
    "smb://192.168.1.181/www/blocklist.txt"
    "https://github.com/DandelionSprout/adfilt/raw/master/LegitimateURLShortener.txt"
  ];
in
{
  options = {
    programs.firefox.policies = mkOption {
      type = types.attrsOf types.anything;
      default = {};
      description = "Firefox policies configuration.";
    };

    programs.firefox.preferences = mkOption {
      type = types.attrsOf types.anything;
      default = {};
      description = "Firefox preferences configuration.";
    };
  };

  config = {
    programs.firefox.policies = {
      BlockAboutAddons = true;
      ExtensionSettings = {
        "*".installation_mode = "blocked";        
        # Super Dark Mode
        "{be3295c2-d576-4a7c-9987-a21844164dbb}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/file/4062840/super_dark_mode-5.0.2.5.xpi";
            installation_mode = "force_installed";
        }; 
        "uBlock0@raymondhill.net" = {
          userSettings = {
            uiTheme = "dark";
            uiAccentCustom = true;
            uiAccentCustom0 = "#8300ff";
            externalLists = concatStringsSep "\n" importedLists;
          };
          selectedFilterLists = [
            "CZE-0"
            "adguard-generic"
            "adguard-annoyance"
            "adguard-social"
            "adguard-spyware-url"
            "easylist"
          ];
        };
      };
    };

    programs.firefox.preferences = {
      "browser.contentblocking.category" = { Value = "strict"; Status = "locked"; };
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
      # Pass
      "signon.rememberSignons" = false;
      "identity.sync.tokenserver.uri" = http://localhost:5000/1.0/sync/1.5;
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
  };

}

