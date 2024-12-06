#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ DCONF.NIX ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
{ lib, ... }:

with lib.hm.gvariant;

{
  dconf.settings = {
    "com/mattjakeman/ExtensionManager" = {
      last-used-version = "0.5.1";
    };

    "org/gnome/Characters" = {
      recent-characters = [ "447" ];
    };

    "org/gnome/Console" = {
      custom-font = "DejaVu Sans Mono 14";
      last-window-maximised = false;
      last-window-size = mkTuple [ 812 576 ];
      use-system-font = false;
      visual-bell = false;
    };

    "org/gnome/TextEditor" = {
      last-save-directory = "file:///home/pungkula/Templates";
      show-line-numbers = true;
      style-variant = "dark";
    };

    "org/gnome/calculator" = {
      accuracy = 9;
      angle-units = "degrees";
      base = 10;
      button-mode = "basic";
      number-format = "automatic";
      show-thousands = false;
      show-zeroes = false;
      source-currency = "";
      source-units = "degree";
      target-currency = "";
      target-units = "radian";
      window-maximized = false;
      window-size = mkTuple [ 387 514 ];
      word-size = 64;
    };

    "org/gnome/calendar" = {
      active-view = "month";
    };

    "org/gnome/clocks/state/window" = {
      maximized = false;
      panel-id = "world";
      size = mkTuple [ 870 690 ];
    };

    "org/gnome/control-center" = {
      last-panel = "keyboard";
      window-state = mkTuple [ 980 640 false ];
    };

    "org/gnome/desktop/a11y" = {
      always-show-universal-access-status = true;
    };
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ ACCESSIBILITY / MAGNIFIER / ZOOM ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
    "org/gnome/desktop/a11y/applications" = {
      screen-magnifier-enabled = true;
      screen-reader-enabled = false;
    };
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ HIGH CONTRAST ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
    "org/gnome/desktop/a11y/interface" = {
      high-contrast = true;
      show-status-shapes = true;
    };

    "org/gnome/desktop/a11y/keyboard" = {
      mousekeys-enable = true;
      togglekeys-enable = true;
    };
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ MAGNIFIER / ZOOM / ACCESSIBILITY ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
    "org/gnome/desktop/a11y/magnifier" = {
      brightness-blue = 0.252778;
      brightness-green = 0.252778;
      brightness-red = 0.252778;
      color-saturation = 0.944444;
      contrast-blue = 0.690278;
      contrast-green = 0.690278;
      contrast-red = 0.690278;
      invert-lightness = false;
      lens-mode = true;
      mag-factor = 4.0;
      mouse-tracking = "proportional";
      scroll-at-edges = false;
      show-cross-hairs = false;
    };

    "org/gnome/desktop/a11y/mouse" = {
      dwell-click-enabled = false;
      secondary-click-enabled = false;
    };

    "org/gnome/desktop/app-folders" = {
      folder-children = [ "Utilities" "YaST" "Pardus" ];
    };

    "org/gnome/desktop/app-folders/folders/Pardus" = {
      categories = [ "X-Pardus-Apps" ];
      name = "X-Pardus-Apps.directory";
      translate = true;
    };

    "org/gnome/desktop/app-folders/folders/Utilities" = {
      apps = [ "gnome-abrt.desktop" "gnome-system-log.desktop" "nm-connection-editor.desktop" "org.gnome.baobab.desktop" "org.gnome.Connections.desktop" "org.gnome.DejaDup.desktop" "org.gnome.Dictionary.desktop" "org.gnome.DiskUtility.desktop" "org.gnome.Evince.desktop" "org.gnome.FileRoller.desktop" "org.gnome.fonts.desktop" "org.gnome.Loupe.desktop" "org.gnome.seahorse.Application.desktop" "org.gnome.tweaks.desktop" "org.gnome.Usage.desktop" "vinagre.desktop" ];
      categories = [ "X-GNOME-Utilities" ];
      name = "X-GNOME-Utilities.directory";
      translate = true;
    };

    "org/gnome/desktop/app-folders/folders/YaST" = {
      categories = [ "X-SuSE-YaST" ];
      name = "suse-yast.directory";
      translate = true;
    };
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ BACKGROUND ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
    "org/gnome/desktop/background" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file:///home/pungkula/.config/background";
      picture-uri-dark = "file:///home/pungkula/.config/background";
      primary-color = "#3071AE";
      secondary-color = "#000000";
    };

    "org/gnome/desktop/datetime" = {
      automatic-timezone = false;
    };

    "org/gnome/desktop/input-sources" = {
      mru-sources = [ (mkTuple [ "xkb" "us" ]) ];
      sources = [ (mkTuple [ "xkb" "se" ]) ];
      xkb-options = [ "terminate:ctrl_alt_bksp" "lv3:lalt_switch" ];
    };

    "org/gnome/desktop/interface" = {
      clock-show-weekday = true;
      color-scheme = "prefer-dark";
      cursor-blink-time = 656;
      cursor-size = 32;
      enable-animations = false;
      enable-hot-corners = false;
      gtk-enable-primary-paste = false;
      locate-pointer = true;
      overlay-scrolling = false;
      text-scaling-factor = 1.25;
      toolkit-accessibility = true;
    };

    "org/gnome/desktop/notifications" = {
      application-children = [ "gnome-power-panel" "org-gnome-nautilus" "org-gnome-texteditor" "firefox" "vesktop" "org-gnome-console" "org-gnome-settings" "org-gnome-characters" ];
    };

    "org/gnome/desktop/notifications/application/firefox" = {
      application-id = "firefox.desktop";
    };

    "org/gnome/desktop/notifications/application/gnome-power-panel" = {
      application-id = "gnome-power-panel.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-characters" = {
      application-id = "org.gnome.Characters.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-console" = {
      application-id = "org.gnome.Console.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-nautilus" = {
      application-id = "org.gnome.Nautilus.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-settings" = {
      application-id = "org.gnome.Settings.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-texteditor" = {
      application-id = "org.gnome.TextEditor.desktop";
    };

    "org/gnome/desktop/notifications/application/vesktop" = {
      application-id = "vesktop.desktop";
    };

    "org/gnome/desktop/peripherals/keyboard" = {
      numlock-state = true;
    };

    "org/gnome/desktop/peripherals/mouse" = {
      accel-profile = "default";
      natural-scroll = true;
      speed = -0.867133;
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      two-finger-scrolling-enabled = true;
    };

    "org/gnome/desktop/privacy" = {
      old-files-age = mkUint32 30;
      recent-files-max-age = -1;
    };
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ SCREENSAVER ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
    "org/gnome/desktop/screensaver" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/adwaita-l.jxl";
      primary-color = "#3071AE";
      secondary-color = "#000000";
    };

    "org/gnome/desktop/search-providers" = {
      sort-order = [ "org.gnome.Contacts.desktop" "org.gnome.Documents.desktop" "org.gnome.Nautilus.desktop" ];
    };

    "org/gnome/desktop/session" = {
      idle-delay = mkUint32 7200;
    };

    "org/gnome/desktop/sound" = {
      allow-volume-above-100-percent = true;
      event-sounds = true;
      theme-name = "__custom";
    };

    "org/gnome/desktop/wm/keybindings" = {
      maximize = [ "<Shift><Control>KP_Add" ];
    };

    "org/gnome/desktop/wm/preferences" = {
      num-workspaces = 2;
      visual-bell = true;
    };

    "org/gnome/epiphany" = {
      ask-for-default = false;
    };

    "org/gnome/evolution-data-server" = {
      migrated = true;
    };

    "org/gnome/file-roller/listing" = {
      list-mode = "as-folder";
      name-column-width = 211;
      show-path = false;
      sort-method = "name";
      sort-type = "ascending";
    };

    "org/gnome/file-roller/ui" = {
      sidebar-width = 200;
      window-height = 480;
      window-width = 600;
    };

    "org/gnome/mutter" = {
      workspaces-only-on-primary = true;
    };

    "org/gnome/nautilus/icon-view" = {
      default-zoom-level = "small-plus";
    };

    "org/gnome/nautilus/list-view" = {
      default-zoom-level = "large";
    };

    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "list-view";
      migrated-gtk-settings = true;
      search-filter-time-type = "last_modified";
    };

    "org/gnome/nautilus/window-state" = {
      initial-size = mkTuple [ 890 550 ];
      maximized = true;
    };

#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ NIGHT LIGHT & COLOR ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
    "org/gnome/settings-daemon/plugins/color" = {
      night-light-enabled = true;
      night-light-schedule-automatic = false;
      night-light-schedule-from = 1.6667e-2;
      night-light-schedule-to = 23.983333;
      night-light-temperature = mkUint32 1700;
    };
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ KEY BINDINGS ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
    "org/gnome/settings-daemon/plugins/media-keys" = {
      control-center = [];
      custom-keybindings = [ "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/" "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/" ];
      email = [ "<Control>e" ];
      home = [ "<Control>grave" ];
      magnifier-zoom-in = [ "KP_Add" ];
      magnifier-zoom-out = [ "KP_Subtract" ];
      screenreader = [ "KP_Divide" ];
      volume-down = [ "Print" ];
      volume-up = [ "Pause" ];
      www = [ "<Control>w" ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Control>KP_Down";
      command = "sudo nixos-rebuild";
      name = "sudo nixos-rebuild";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      binding = "section";
      command = "/etc/profiles/per-user/pungkula/bin/gnome-terminal";
      name = "binbash";
    };

    "org/gnome/settings-daemon/plugins/sharing/gnome-user-share-webdav" = {
      enabled-connections = [ "6ac651f5-e63e-3163-bad5-93690f705e42" ];
    };
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ SHELL ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
    "org/gnome/shell" = {
      command-history = [ "shell" "terminal" "kgx" ];
      disable-user-extensions = false;
      disabled-extensions = [ "launch-new-instance@gnome-shell-extensions.gcampax.github.com" ];
      enabled-extensions = [ "apps-menu@gnome-shell-extensions.gcampax.github.com" "auto-move-windows@gnome-shell-extensions.gcampax.github.com" "window-list@gnome-shell-extensions.gcampax.github.com" "user-theme@gnome-shell-extensions.gcampax.github.com" "drive-menu@gnome-shell-extensions.gcampax.github.com" "native-window-placement@gnome-shell-extensions.gcampax.github.com" "windowsNavigator@gnome-shell-extensions.gcampax.github.com" "workspace-indicator@gnome-shell-extensions.gcampax.github.com" "CustomizeClockOnLockScreen@pratap.fastmail.fm" "highlight-focus@pimsnel.com" "custom-command-toggle@storageb.github.com" "vbox-applet@gs.eros2.info" "simple-message@freddez" "docker@stickman_0x00.com" "todo.txt@bart.libert.gmail.com" "openbar@neuromorph" ];
      favorite-apps = [ "org.gnome.Nautilus.desktop" "org.gnome.Terminal.desktop" "firefox.desktop" "vesktop.desktop" ];
      last-selected-power-profile = "power-saver";
      welcome-dialog-last-shown-version = "46.2";
    };
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ OPENBAR (THEME, COLORS, DESKTOP SETTINGS)  ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
    "org/gnome/shell/extensions/openbar" = {
      accent-color = [ "0" "0.75" "0.75" ];
      accent-override = false;
      apply-accent-shell = false;
      apply-all-shell = true;
      apply-flatpak = false;
      apply-gtk = false;
      apply-menu-notif = true;
      apply-menu-shell = true;
      auto-bgalpha = false;
      autofg-bar = true;
      autofg-menu = true;
      autohg-bar = true;
      autohg-menu = true;
      autotheme-dark = "Dark";
      autotheme-font = false;
      autotheme-light = "Dark";
      autotheme-refresh = false;
      balpha = 0.85;
      bartype = "Floating";
      bcolor = [ "0.47058823529411764" "0.611764705882353" "0.8470588235294118" ];
      bg-change = false;
      bgalpha = 0.95;
      bgalpha-wmax = 1.0;
      bgalpha2 = 0.7;
      bgcolor = [ "0.0784313725490196" "0.3176470588235294" "0.5803921568627451" ];
      bgcolor-wmax = [ "0.11764705882352941" "0.11764705882352941" "0.11764705882352941" ];
      bgcolor2 = [ "0.2" "0.25098039215686274" "0.3254901960784314" ];
      bgpalette = true;
      bguri = "file:///home/pungkula/.config/background";
      border-wmax = true;
      bordertype = "solid";
      boxalpha = 0.0;
      boxcolor = [ "0.0784313725490196" "0.3176470588235294" "0.5803921568627451" ];
      bradius = 42.0;
      bwidth = 5.3;
      candy1 = [ "0" "0.61" "0.74" ];
      candy10 = [ "0.09" "0.19" "0.72" ];
      candy11 = [ "0.75" "0.49" "0.44" ];
      candy12 = [ "1" "0.92" "0.12" ];
      candy13 = [ "0.38" "0.63" "0.92" ];
      candy14 = [ "0.37" "0.36" "0.39" ];
      candy15 = [ "0.40" "0.23" "0.72" ];
      candy16 = [ "1" "0.32" "0.32" ];
      candy2 = [ "1" "0.41" "0.41" ];
      candy3 = [ "0.63" "0.16" "0.8" ];
      candy4 = [ "0.94" "0.60" "0.23" ];
      candy5 = [ "0.03" "0.41" "0.62" ];
      candy6 = [ "0.56" "0.18" "0.43" ];
      candy7 = [ "0.95" "0.12" "0.67" ];
      candy8 = [ "0.18" "0.76" "0.49" ];
      candy9 = [ "0.93" "0.20" "0.23" ];
      candyalpha = 0.99;
      candybar = false;
      card-hint = 10;
      color-scheme = "prefer-dark";
      corner-radius = false;
      count1 = 378725;
      count10 = 2650;
      count11 = 2527;
      count12 = 190;
      count2 = 114920;
      count3 = 91393;
      count4 = 54386;
      count5 = 29764;
      count6 = 22317;
      count7 = 21265;
      count8 = 20658;
      count9 = 11091;
      cust-margin-wmax = false;
      dark-accent-color = [ "0" "0.75" "0.75" ];
      dark-bcolor = [ "0.47058823529411764" "0.611764705882353" "0.8470588235294118" ];
      dark-bgcolor = [ "0.0784313725490196" "0.3176470588235294" "0.5803921568627451" ];
      dark-bgcolor-wmax = [ "0.11764705882352941" "0.11764705882352941" "0.11764705882352941" ];
      dark-bgcolor2 = [ "0.2" "0.25098039215686274" "0.3254901960784314" ];
      dark-bguri = "file:///home/pungkula/.config/background";
      dark-boxcolor = [ "0.0784313725490196" "0.3176470588235294" "0.5803921568627451" ];
      dark-candy1 = [ "0" "0.61" "0.74" ];
      dark-candy10 = [ "0.09" "0.19" "0.72" ];
      dark-candy11 = [ "0.75" "0.49" "0.44" ];
      dark-candy12 = [ "1" "0.92" "0.12" ];
      dark-candy13 = [ "0.38" "0.63" "0.92" ];
      dark-candy14 = [ "0.37" "0.36" "0.39" ];
      dark-candy15 = [ "0.40" "0.23" "0.72" ];
      dark-candy16 = [ "1" "0.32" "0.32" ];
      dark-candy2 = [ "1" "0.41" "0.41" ];
      dark-candy3 = [ "0.63" "0.16" "0.8" ];
      dark-candy4 = [ "0.94" "0.60" "0.23" ];
      dark-candy5 = [ "0.03" "0.41" "0.62" ];
      dark-candy6 = [ "0.56" "0.18" "0.43" ];
      dark-candy7 = [ "0.95" "0.12" "0.67" ];
      dark-candy8 = [ "0.18" "0.76" "0.49" ];
      dark-candy9 = [ "0.93" "0.20" "0.23" ];
      dark-dbgcolor = [ "0.09019608050584793" "0.364705890417099" "0.7529411911964417" ];
      dark-fgcolor = [ "1.0" "1.0" "1.0" ];
      dark-hcolor = [ "0" "0.7" "0.9" ];
      dark-iscolor = [ "0.0784313725490196" "0.3176470588235294" "0.5803921568627451" ];
      dark-mbcolor = [ "0.615686274509804" "0.6078431372549019" "0.8235294117647058" ];
      dark-mbgcolor = [ "0.01568627450980392" "0.12941176470588237" "0.3176470588235294" ];
      dark-mfgcolor = [ "1.0" "1.0" "1.0" ];
      dark-mhcolor = [ "0" "0.7" "0.9" ];
      dark-mscolor = [ "0.24705882352941178" "0.49411764705882355" "0.7843137254901961" ];
      dark-mshcolor = [ "0" "0" "0" ];
      dark-palette1 = [ "20" "31" "27" ];
      dark-palette10 = [ "67" "45" "42" ];
      dark-palette11 = [ "103" "77" "83" ];
      dark-palette12 = [ "160" "75" "170" ];
      dark-palette2 = [ "49" "84" "57" ];
      dark-palette3 = [ "36" "63" "40" ];
      dark-palette4 = [ "69" "118" "100" ];
      dark-palette5 = [ "27" "57" "65" ];
      dark-palette6 = [ "191" "200" "179" ];
      dark-palette7 = [ "39" "90" "102" ];
      dark-palette8 = [ "100" "173" "180" ];
      dark-palette9 = [ "63" "139" "153" ];
      dark-shcolor = [ "0" "0" "0" ];
      dark-smbgcolor = [ "0.2" "0.25098039215686274" "0.3254901960784314" ];
      dark-winbcolor = [ "0.24705882352941178" "0.49411764705882355" "0.7843137254901961" ];
      dashdock-style = "Custom";
      dbgalpha = 0.85;
      dbgcolor = [ "0.09019608050584793" "0.364705890417099" "0.7529411911964417" ];
      dborder = true;
      dbradius = 100.0;
      default-font = "Sans 12";
      destruct-color = [ "0.75" "0.11" "0.16" ];
      disize = 80.0;
      dshadow = true;
      fgalpha = 1.0;
      fgcolor = [ "1.0" "1.0" "1.0" ];
      font = "";
      gradient = false;
      gradient-direction = "vertical";
      gtk-popover = false;
      halpha = 0.5;
      handle-border = 3.0;
      hcolor = [ "0" "0.7" "0.9" ];
      headerbar-hint = 0;
      heffect = false;
      height = 33.0;
      hpad = 1.0;
      import-export = false;
      isalpha = 0.95;
      iscolor = [ "0.0784313725490196" "0.3176470588235294" "0.5803921568627451" ];
      light-accent-color = [ "0" "0.75" "0.75" ];
      light-bcolor = [ "0.5647058823529412" "0.7647058823529411" "0.9372549019607843" ];
      light-bgcolor = [ "0.058823529411764705" "0.2549019607843137" "0.5411764705882353" ];
      light-bgcolor-wmax = [ "0.9215686274509803" "0.9215686274509803" "0.9215686274509803" ];
      light-bgcolor2 = [ "0.21568627450980393" "0.2549019607843137" "0.3333333333333333" ];
      light-bguri = "file:///home/pungkula/.config/background";
      light-boxcolor = [ "0.058823529411764705" "0.2549019607843137" "0.5411764705882353" ];
      light-candy1 = [ "0" "0.61" "0.74" ];
      light-candy10 = [ "0.09" "0.19" "0.72" ];
      light-candy11 = [ "0.75" "0.49" "0.44" ];
      light-candy12 = [ "1" "0.92" "0.12" ];
      light-candy13 = [ "0.38" "0.63" "0.92" ];
      light-candy14 = [ "0.37" "0.36" "0.39" ];
      light-candy15 = [ "0.40" "0.23" "0.72" ];
      light-candy16 = [ "1" "0.32" "0.32" ];
      light-candy2 = [ "1" "0.41" "0.41" ];
      light-candy3 = [ "0.63" "0.16" "0.8" ];
      light-candy4 = [ "0.94" "0.60" "0.23" ];
      light-candy5 = [ "0.03" "0.41" "0.62" ];
      light-candy6 = [ "0.56" "0.18" "0.43" ];
      light-candy7 = [ "0.95" "0.12" "0.67" ];
      light-candy8 = [ "0.18" "0.76" "0.49" ];
      light-candy9 = [ "0.93" "0.20" "0.23" ];
      light-dbgcolor = [ "0.125" "0.125" "0.125" ];
      light-fgcolor = [ "1.0" "1.0" "1.0" ];
      light-hcolor = [ "0" "0.7" "0.9" ];
      light-iscolor = [ "0.058823529411764705" "0.2549019607843137" "0.5411764705882353" ];
      light-mbcolor = [ "0.3803921568627451" "0.40784313725490196" "0.611764705882353" ];
      light-mbgcolor = [ "0.00784313725490196" "0.12156862745098039" "0.3254901960784314" ];
      light-mfgcolor = [ "1.0" "1.0" "1.0" ];
      light-mhcolor = [ "0" "0.7" "0.9" ];
      light-mscolor = [ "0.30196078431372547" "0.5137254901960784" "0.8705882352941177" ];
      light-mshcolor = [ "0" "0" "0" ];
      light-palette1 = [ "20" "31" "27" ];
      light-palette10 = [ "67" "45" "42" ];
      light-palette11 = [ "103" "77" "83" ];
      light-palette12 = [ "160" "75" "170" ];
      light-palette2 = [ "49" "84" "57" ];
      light-palette3 = [ "36" "63" "40" ];
      light-palette4 = [ "69" "118" "100" ];
      light-palette5 = [ "27" "57" "65" ];
      light-palette6 = [ "191" "200" "179" ];
      light-palette7 = [ "39" "90" "102" ];
      light-palette8 = [ "100" "173" "180" ];
      light-palette9 = [ "63" "139" "153" ];
      light-shcolor = [ "0" "0" "0" ];
      light-smbgcolor = [ "0.21568627450980393" "0.2549019607843137" "0.3333333333333333" ];
      light-winbcolor = [ "0.30196078431372547" "0.5137254901960784" "0.8705882352941177" ];
      margin = 7.9;
      margin-wmax = 2.0;
      mbalpha = 0.6;
      mbcolor = [ "0.615686274509804" "0.6078431372549019" "0.8235294117647058" ];
      mbg-gradient = false;
      mbgalpha = 0.95;
      mbgcolor = [ "0.01568627450980392" "0.12941176470588237" "0.3176470588235294" ];
      menu-radius = 21.0;
      menustyle = true;
      mfgalpha = 1.0;
      mfgcolor = [ "1.0" "1.0" "1.0" ];
      mhalpha = 0.35;
      mhcolor = [ "0" "0.7" "0.9" ];
      monitors = "all";
      msalpha = 0.85;
      mscolor = [ "0.24705882352941178" "0.49411764705882355" "0.7843137254901961" ];
      mshalpha = 0.16;
      mshcolor = [ "0" "0" "0" ];
      neon = true;
      neon-wmax = true;
      notif-radius = 10.0;
      palette1 = [ "20" "31" "27" ];
      palette10 = [ "67" "45" "42" ];
      palette11 = [ "103" "77" "83" ];
      palette12 = [ "160" "75" "170" ];
      palette2 = [ "49" "84" "57" ];
      palette3 = [ "36" "63" "40" ];
      palette4 = [ "69" "118" "100" ];
      palette5 = [ "27" "57" "65" ];
      palette6 = [ "191" "200" "179" ];
      palette7 = [ "39" "90" "102" ];
      palette8 = [ "100" "173" "180" ];
      palette9 = [ "63" "139" "153" ];
      pause-reload = false;
      position = "Top";
      prominent1 = [ "100" "100" "100" ];
      prominent2 = [ "100" "100" "100" ];
      prominent3 = [ "100" "100" "100" ];
      prominent4 = [ "100" "100" "100" ];
      prominent5 = [ "100" "100" "100" ];
      prominent6 = [ "100" "100" "100" ];
      qtoggle-radius = 50.0;
      radius-bottomleft = true;
      radius-bottomright = true;
      radius-topleft = true;
      radius-topright = true;
      reloadstyle = false;
      removestyle = false;
      set-fullscreen = true;
      set-notifications = false;
      set-overview = true;
      set-yarutheme = false;
      shadow = false;
      shalpha = 0.2;
      shcolor = [ "0" "0" "0" ];
      sidebar-hint = 10;
      sidebar-transparency = false;
      slider-height = 4.0;
      smbgalpha = 0.95;
      smbgcolor = [ "0.2" "0.25098039215686274" "0.3254901960784314" ];
      smbgoverride = true;
      success-color = [ "0.15" "0.635" "0.41" ];
      traffic-light = false;
      trigger-autotheme = false;
      trigger-reload = false;
      vpad = 4.0;
      warning-color = [ "0.96" "0.83" "0.17" ];
      width-bottom = true;
      width-left = true;
      width-right = true;
      width-top = true;
      winbalpha = 0.75;
      winbcolor = [ "0.24705882352941178" "0.49411764705882355" "0.7843137254901961" ];
      winbradius = 12.0;
      winbwidth = 0.0;
      wmaxbar = true;
    };
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ SIMPLE MESSAGE ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
    "org/gnome/shell/extensions/simple-message" = {
      command = "echo '🦆' | xclip -selection clipboard";
      message = "🦆";
      panel-alignment = 2;
      panel-position = 3;
    };

    "org/gnome/shell/extensions/user-theme" = {
      name = "";
    };

    "org/gnome/shell/extensions/window-list" = {
      display-all-workspaces = false;
      grouping-mode = "always";
    };

    "org/gnome/shell/keybindings" = {
      show-screenshot-ui = [];
    };

    "org/gnome/shell/world-clocks" = {
      locations = [];
    };

    "org/gnome/software" = {
      check-timestamp = mkInt64 1720977387;
      first-run = false;
      flatpak-purge-timestamp = mkInt64 1720949285;
    };

    "org/gnome/terminal/legacy" = {
      mnemonics-enabled = true;
      theme-variant = "dark";
    };
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ KEY BINDINGS (TERMINAL) ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
    "org/gnome/terminal/legacy/keybindings" = {
      copy = "<Primary>c";
      new-window = "<Primary>1";
      next-tab = "<Primary>v";
      paste = "<Primary>v";
      select-all = "<Primary>a";
    };

    "org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9" = {
      custom-command = "sudo nixos-rebuild switch";
      exit-action = "hold";
      use-custom-command = false;
    };

    "org/gnome/tweaks" = {
      show-extensions-notice = false;
    };

    "org/gtk/gtk4/settings/color-chooser" = {
      custom-colors = [ (mkTuple [ 0.125 0.125 0.125 1.0 ]) (mkTuple [ 0.75 0.2499999850988388 0.440000057220459 1.0 ]) (mkTuple [ 0.47058823704719543 0.6117647290229797 0.8470588326454163 1.0 ]) ];
      selected-color = mkTuple [ true 9.019608050584793e-2 0.364705890417099 0.7529411911964417 1.0 ];
    };

    "org/gtk/gtk4/settings/file-chooser" = {
      date-format = "regular";
      location-mode = "path-bar";
      show-hidden = true;
      sidebar-width = 140;
      sort-column = "name";
      sort-directories-first = true;
      sort-order = "descending";
      type-format = "category";
      view-type = "list";
      window-size = mkTuple [ 1412 372 ];
    };

    "org/gtk/settings/file-chooser" = {
      date-format = "regular";
      location-mode = "path-bar";
      show-hidden = false;
      show-size-column = true;
      show-type-column = true;
      sidebar-width = 199;
      sort-column = "name";
      sort-directories-first = false;
      sort-order = "ascending";
      type-format = "category";
      window-position = mkTuple [ 26 23 ];
      window-size = mkTuple [ 1891 948 ];
    };

  };
}
