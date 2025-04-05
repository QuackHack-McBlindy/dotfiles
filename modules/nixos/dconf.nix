{ config, lib, pkgs, ... }: {
  programs.dconf.enable = true;
  programs.dconf.profiles = {
    user.databases = [{
      settings = {
        # -- Accessibility --
        "org/gnome/desktop/a11y/applications" = {
          screen-magnifier-enabled = true;
          screen-reader-enabled = false;
        };
        
        "org/gnome/desktop/a11y/interface" = {
          high-contrast = true;
          show-status-shapes = true;
        };

        # -- Color/Night Light --
        "org.gnome.settings-daemon.plugins.color" = {
          night-light-temperature = lib.gvariant.mkUint32 1700;
          night-light-enabled = true;
        };

        # -- Magnifier Settings --
        "org/gnome/desktop/a11y/magnifier" = {
          brightness-blue = lib.gvariant.mkDouble (-0.048611111111111049);
          brightness-green = lib.gvariant.mkDouble (-0.048611111111111049);
          brightness-red = lib.gvariant.mkDouble (-0.048611111111111049);
          caret-tracking = "centered";
          color-saturation = lib.gvariant.mkDouble 1.0;
          contrast-blue = lib.gvariant.mkDouble 0.0;
          contrast-green = lib.gvariant.mkDouble 0.0;
          contrast-red = lib.gvariant.mkDouble 0.0;
          cross-hairs-clip = false;
          cross-hairs-color = "#ff0000";
          cross-hairs-length = lib.gvariant.mkUint32 4096;
          cross-hairs-opacity = lib.gvariant.mkDouble 0.66;
          cross-hairs-thickness = lib.gvariant.mkUint32 8;
          mag-factor = lib.gvariant.mkDouble 6.0;
        };

        # -- Power Management --
        "org/gnome/settings-daemon/plugins/power" = {
          idle-brightness = lib.gvariant.mkUint32 30;
          idle-dim = true;
          sleep-inactive-battery-timeout = lib.gvariant.mkUint32 900;
        };

        # -- Housekeeping --
        "org/gnome/settings-daemon/plugins/housekeeping" = {
          free-percent-notify = lib.gvariant.mkDouble 0.05;
          free-percent-notify-again = lib.gvariant.mkDouble 0.01;
        };

        # -- Interface Settings --
        "org/gnome/desktop/interface" = {
          clock-show-weekday = true;
          text-scaling-factor = lib.gvariant.mkDouble 1.25;
          cursor-size = lib.gvariant.mkUint32 24;
        };

        # -- Peripherals --
        "org/gnome/desktop/peripherals/keyboard" = {
          repeat = true;
          delay = lib.gvariant.mkUint32 2500;
          repeat-interval = lib.gvariant.mkUint32 15;
        };

        "org/gnome/desktop/peripherals/mouse" = {
          speed = lib.gvariant.mkDouble (-0.4);
          accel-profile = "flat";
        };

        # -- Theme/Visual Settings --
        "org/gnome/shell".favorite-apps = [
          "firefox-esr.desktop"
          "thunar.desktop"
          "com.mitchellh.ghostty.desktop"
          "org.gnome.TextEditor.desktop"
        ];

        # -- Extensions --
        "org/gnome/shell".enabled-extensions = [
          "openbar@neuromorph"
          "user-theme@gnome-shell-extensions.gcampax.github.com"
          "gsconnect@andyholmes.github.io"
        ];

        # -- Text Editor --
        "org/gnome/TextEditor" = {
          custom-font = "VictorMono Nerd Font Propo Bold 14";
          style-scheme = "cobalt";
          tab-width = lib.gvariant.mkUint32 4;
        };

        # -- Session Management --
        "org/gnome/desktop/session" = {
          idle-delay = lib.gvariant.mkUint32 1600;
        };
      };
    }];
  };
}
