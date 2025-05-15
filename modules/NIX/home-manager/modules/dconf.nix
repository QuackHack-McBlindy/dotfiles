{ 
  config,
  lib,
  pkgs,
  ...
} : let
  cfg = config.this.host.modules.system;
in {
  config = lib.mkIf (lib.elem "dconf" cfg) {
    programs.dconf.enable = true;
    programs.dconf.profiles.user.databases = [{
      settings = {
        "org/gnome/desktop/a11y/applications" = {
          screen-magnifier-enabled = true;
          screen-reader-enabled = false;
        };

        "org/gnome/settings-daemon/plugins/color" = {
          night-light-enabled = true;
          night-light-temperature = 3670;
        };

        "org/gnome/desktop/a11y/interface" = {
          high-contrast = true;
          show-status-shapes = true;
        };

        "org/gnome/desktop/a11y/magnifier" = {
          brightness-blue = "-0/048611111111111049";
          brightness-green = "-0/048611111111111049";
          brightness-red = "-0/048611111111111049";
          caret-tracking = "centered";
          color-saturation = "1/0";
          contrast-blue = "0/0";
          contrast-green = "0/0";
          contrast-red = "0/0";
          cross-hairs-clip = false;
          cross-hairs-color = "#ff0000";
          cross-hairs-length = "4096";
          cross-hairs-opacity = "0/66000000000000003";
          cross-hairs-thickness = "8";
          focus-tracking = "proportional";
          invert-lightness = false;
          lens-mode = false;
          mag-factor = "6/0";
          mouse-tracking = "proportional";
          screen-position = "full-screen";
          scroll-at-edges = true;
          show-cross-hairs = false;
        };

        "org/gnome/desktop/wm/keybindings" = {
          set-spew-mark = [];
        };

        "org/gnome/desktop/wm/preferences" = {
          action-double-click-titlebar = "toggle-maximize";
          button-layout = "appmenu:minimize,maximize,spacer,spacer,close";
          action-right-click-titlebar = "menu";
          focus-mode = "click";
          theme = "Adwaita";
          titlebar-font = "Cantarell Bold 11";
          titlebar-uses-system-font = true;
        };

        "org/gnome/mutter" = {
          dynamic-workspaces = true;
        };

        "org/gnome/settings-daemon/plugins/power" = {
          idle-brightness = 30;
          idle-dim = true;
          power-button-action = "suspend";
          power-saver-profile-on-low-battery = true;
          sleep-inactive-ac-timeout = 0;
          sleep-inactive-ac-type = "nothing";
          sleep-inactive-battery-timeout = 900;
          sleep-inactive-battery-type = "suspend";
        };

        "org/gnome/settings-daemon/plugins/housekeeping" = {
          free-percent-notify = 0.05;
          free-percent-notify-again = 0.01;
          min-notify-period = 10;
        };

        "org/gnome/desktop/interface" = {
          clock-show-weekday = true;
          color-scheme = "prefer-dark";
          cursor-size = 24;
          cursor-theme = "Bibata-Modern-Classic";
          document-font-name = "Cantarell 11";
          enable-animations = true;
          enable-hot-corners = false;
          font-name = "TeX Gyre Adventor 10";
          icon-theme = "elementary-xfce-icon-theme";
          locate-pointer = true;
          monospace-font-name = "Source Code Pro 10";
          show-battery-percentage = false;
          text-scaling-factor = 1.25;
          toolkit-accessibility = true;
          toolbar-icons-size = "large";
        };

        "org/gnome/shell" = {
          enabled-extensions = [
            "emoji-copy@felipeftn"
            "openbar@neuromorph"
            "space-bar@luchrioh"
            "todo.txt@bart.libert.gmail.com"
            "user-theme@gnome-shell-extensions.gcampax.github.com"
            "window-list@gnome-shell-extensions.gcampax.github.com"
            "windowsNavigator@gnome-shell-extensions.gcampax.github.com"
            "gnome-wireguard-extension@SJBERTRAND.github.com"
            "docker@stickman_0x00.com"
            "gsconnect@andyholmes.github.io"
            "system-monitor@gnome-shell-extensions.gcampax.github.com"
            "rclone-manager@germanztz.com"
          ];
          favorite-apps = [
            "firefox-esr.desktop"
            "thunar.desktop"
            "com.mitchellh.ghostty.desktop"
            "org.gnome.TextEditor.desktop"
            "vesktop.desktop"
            "signal-desktop.desktop"
            "keepass.desktop"
          ];
          development-tools = true;
          last-selected-power-profile = "power-saver";
          remember-mount-password = true;
          welcome-dialog-last-shown-version = "47/2";
        };

        "org/gnome/shell/extensions/openbar" = {
          bg-change = true;
          dark-bguri = "file:///home/pungkula/.config/background.png";
          light-bguri = "file:///home/pungkula/.config/background.png";
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
          dark-hscd-color = [0.718 0.835 0.561];
          dark-palette1 = [20 31 27];
          dark-palette10 = [67 45 42];
          dark-palette11 = [103 77 83];
          dark-palette12 = [160 75 170];
          dark-palette2 = [49 84 57];
          dark-palette3 = [36 63 40];
          dark-palette4 = [69 118 100];
          dark-palette5 = [27 57 65];
          dark-palette6 = [191 200 179];
          dark-palette7 = [39 90 102];
          dark-palette8 = [100 173 180];
          dark-palette9 = [63 139 153];
          dark-vw-color = [0.718 0.835 0.561];
          fitts-widgets = false;
          hscd-color = [0.718 0.835 0.561];
          light-hscd-color = [0.718 0.835 0.561];
          light-vw-color = [0.718 0.835 0.561];
          palette1 = [20 31 27];
          palette10 = [67 45 42];
          palette11 = [103 77 83];
          palette12 = [160 75 170];
          palette2 = [49 84 57];
          palette3 = [36 63 40];
          palette4 = [69 118 100];
          palette5 = [27 57 65];
          palette6 = [191 200 179];
          palette7 = [39 90 102];
          palette8 = [100 173 180];
          palette9 = [63 139 153];
          pause-reload = false;
          reloadstyle = true;
        };

        "org/gnome/shell/extensions/window-list" = {
          display-all-workspaces = true;
          embed-previews = true;
          grouping-mode = "always";
          show-on-all-monitors = false;
        };

        "org/gnome/shell/extensions/system-monitor" = {
          show-cpu = true;
          show-download = false;
          show-memory = true;
          show-swap = false;
          show-upload = false;
        };

        "org/gnome/shell/extensions/emoji-copy" = {
          recently-used = ["🦆" "🧑🦯" "🥹" "🚀" "✨" "😊" "😘" "❤️" "😍" "🛡️" "🔒"];
        };

        "org/gnome/shell/extensions/rclone-manager" = {
          prefkey001-rconfig-file-path = "~/.config/rclone/rclone.conf";
          prefkey010-rclone-mount = "bash ~/.config/rclone/upd.sh && rclone --password-command %pcmd mount %profile: %source --volname %profile --file-perms 0777 --write-back-cache --no-modtime --daemon --daemon-timeout 30s";
          prefkey005-external-file-browser = "thunar";
        };

        "org/gnome/TextEditor" = {
          custom-font = "VictorMono Nerd Font Propo Bold 14";
          highlight-current-line = true;
          restore-session = false;
          last-save-directory = "file:///home/pungkula/dotfiles";
          show-grid = true;
          show-line-numbers = true;
          show-map = true;
          style-scheme = "cobalt";
          tab-width = 4;
          use-system-font = false;
        };

        "org/gnome/gedit/plugins" = {
          active-plugins = ["spell" "quickhighlight" "textsize" "filebrowser" "docinfo" "sort"];
        };

        "org/gnome/gedit/plugins/filebrowser" = {
          filter-mode = ["hide-binary"];
          root = "file:///";
          tree-view = true;
          virtual-root = "file:///home/pungkula/dotfiles";
        };

        "org/gnome/gedit/preferences/editor" = {
          insert-spaces = true;
          style-scheme-for-dark-theme-variant = "cobalt";
          tabs-size = 4;
          wrap-last-split-mode = "word";
        };

        "org/gnome/gedit/preferences/ui" = {
          bottom-panel-visible = false;
          side-panel-visible = true;
        };

        "org/gnome/gedit/state/window" = {
          height = 700;
          maximized = true;
          width = 900;
        };

        "org/gnome/system/location" = {
          enabled = false;
          max-accuracy-level = "exact";
        };

        "org/gnome/SessionManager" = {
          logout-prompt = true;
          show-fallback-warning = true;
        };

        "org/gnome/desktop/sound" = {
          allow-volume-above-100-percent = false;
          event-sounds = true;
          input-feedback-sounds = false;
          theme-name = "freedesktop";
        };

        "org/gnome/desktop/session" = {
          idle-delay = 1600;
        };

        "org/gnome/desktop/screensaver" = {
          color-shading-type = "solid";
          logout-command = "";
          lock-enabled = false;
          primary-color = "#023c88";
          picture-opacity = 100;
          picture-options = "zoom";
          secondary-color = "#5789ca";
          status-message-enabled = true;
          user-switch-enabled = true;
        };

        "org/gnome/desktop/calendar" = {
          show-weekdate = true;
        };

        "org/gnome/desktop/lockdown" = {
          disable-command-line = false;
          disable-application-handlers = false;
          user-administration-disabled = false;
          mount-removable-storage-devices-as-read-only = false;
          disable-user-switching = false;
          disable-save-to-disk = false;
          disable-show-password = false;
          disable-print-setup = false;
          disable-printing = false;
          disable-log-out = false;
          disable-lock-screen = false;
        };

        "org/gnome/desktop/privacy" = {
          disable-camera = true;
          disable-microphone = false;
          disable-sound-output = false;
          hide-identity = false;
          old-files-age = 30;
          remember-app-usage = true;
          remember-recent-files = true;
          report-technical-problems = false;
          send-software-usage-stats = false;
          usb-protection = true;
          usb-protection-level = "lockscreen";
        };

        "org/gnome/desktop/peripherals/keyboard" = {
          repeat = true;
          delay = 2500;
          repeat-interval = 15;
        };

        "org/gnome/desktop/peripherals/mouse" = {
          speed = -0.4;
          accel-profile = "flat";
        };

        "org/gnome/desktop/break-reminders" = {
          selected-breaks = [];
        };

        "org/gnome/desktop/break-reminders/eyesight" = {
          countdown = true;
          delay-seconds = 180;
          duration-seconds = 20;
          fade-screen = true;
          interval-seconds = 1200;
          lock-screen = false;
          notify = true;
          notify-overdue = true;
          notify-upcoming = false;
          play-sound = true;
        };

        "org/gnome/desktop/break-reminders/movement" = {
          countdown = true;
          delay-seconds = 180;
          duration-seconds = 300;
          fade-screen = true;
          interval-seconds = 1800;
          lock-screen = false;
          notify = true;
          notify-overdue = true;
          notify-upcoming = true;
          play-sound = true;
        };

        "org/gnome/desktop/notifications" = {
          show-banners = true;
          show-in-lock-screen = true;
        };
      };
    }];

    environment.systemPackages = with pkgs; [
      gnome.gnome-terminal
      gnome.gedit
      gnome.gnome-tweaks
    ];

    imports = [ ./../keybindings-${config.networking.hostName}.nix ];
  };
}
