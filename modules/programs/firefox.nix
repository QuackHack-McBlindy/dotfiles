{ 
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.this.host.modules.programs;
in {
  config = lib.mkIf (lib.elem "firefox" cfg) {
    programs.firefox = {
      enable = true;
      package = pkgs.firefox-esr;
      languagePacks = [ "en-US" ];

      # ========== PREFERENCES ==========
      preferences = {
        "general.useragent.locale" = "en-GB";
        "general.useragent.override" = "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Mobile Safari/537.36";
        "browser.startup.homepage" = "http://localhost:3001";
        "browser.search.region" = "GB";
        "browser.search.isUS" = false;
        # ... include all other preferences from original config
      };

      # ========== POLICIES ==========
      policies = {
        NoDefaultBookmarks = true;
        DisableTelemetry = true;
        DisablePocket = true;
        DisableFirefoxAccounts = true;
        DisableAccounts = true;

        Bookmarks = [
          { Title = ""; URL = "http://192.168.1.181:3000"; Placement = "toolbar"; }
          # ... other bookmarks
        ];

        ExtensionSettings = {
          "*".installation_mode = "blocked";
          # ... extension configurations
        };
      };
    };

    # ========== SEARCH ENGINE WORKAROUND ==========
    system.activationScripts.firefox-config = let
      searchJson = builtins.toJSON {
 #       metaData = { version = 2 };
        engines = {
          "Nix Packages" = {
            urls = [{
              template = "https://search.nixos.org/packages";
              params = [
                { name = "type"; value = "packages"; }
                { name = "query"; value = "{searchTerms}"; }
              ];
            }];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            alias = "@np";
          };
          # ... other search engines
        };
      };
    in ''
      mkdir -p /home/pungkula/.mozilla/firefox/default
      echo '${searchJson}' | ${pkgs.lz4}/bin/lz4 --no-crc -l -12 - \
        /home/pungkula/.mozilla/firefox/default/search.json.mozlz4
      chown pungkula:users /home/pungkula/.mozilla/firefox/default/search.json.mozlz4
    '';

    # ========== REQUIRED DEPENDENCIES ==========
    environment.systemPackages = [ pkgs.lz4 ];

    # ========== PROFILE INITIALIZATION ==========
    system.activationScripts.firefox-profile = ''
      mkdir -p /home/pungkula/.mozilla/firefox/default
      chown -R pungkula:users /home/pungkula/.mozilla
    '';
  };
}
