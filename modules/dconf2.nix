{ config, lib, pkgs, ... }:

let
  user = "pungkula";
  hostname = "desktop";
  dconfSettings = {
    "org/gnome/desktop/a11y/applications" = {
      screen-magnifier-enabled = true;
      screen-reader-enabled = false;
    };
    "org.gnome.settings-daemon.plugins.color".night-light-temperature = 1700;
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

    "org/gnome/desktop/wm/keybindings".set-spew-mark = "@as []";
    "org/gnome/desktop/wm/preferences".action-double-click-titlebar = "toggle-maximize";
    "org/gnome/mutter".dynamic-workspaces = true;

    "org/gnome/settings-daemon/plugins/power" = {
      idle-brightness = "30";
      idle-dim = true;
      power-button-action = "suspend";
      power-saver-profile-on-low-battery = true;
      sleep-inactive-ac-timeout = "0";
      sleep-inactive-ac-type = "nothing";
      sleep-inactive-battery-timeout = "900";
      sleep-inactive-battery-type = "suspend";
    };
    "org/gnome/settings-daemon/plugins/housekeeping" = {
      free-percent-notify = "0/050000000000000003";
      free-percent-notify-again = "0/01";
      min-notify-period = "10";
    };
    "org/gnome/desktop/interface".clock-show-weekday = true;

    # Theme/Visual Settings
    "org/gnome/desktop/interface".color-scheme = "prefer-dark";
    "org/gnome/settings-daemon/plugins/color" = {
      night-light-enabled = true;
      night-light-temperature = "3670";
    };
    "org/gnome/shell".favorite-apps = "@as ['firefox-esr.desktop', 'thunar.desktop', 'com.mitchellh.ghostty.desktop', 'org.gnome.TextEditor.desktop', 'vesktop.desktop', 'signal-desktop.desktop', 'keepass.desktop']";
    
    "org/gnome/shell/extensions/openbar" = {
      bg-change = true;
      dark-bguri = "file:///home/${user}/.config/background.png";
      dark-hscd-color = ["0/718" "0/835" "0/561"];
      dark-palette1 = ["20" "31" "27"];
      dark-palette10 = ["67" "45" "42"];
      dark-palette11 = ["103" "77" "83"];
      dark-palette12 = ["160" "75" "170"];
      dark-palette2 = ["49" "84" "57"];
      dark-palette3 = ["36" "63" "40"];
      dark-palette4 = ["69" "118" "100"];
      dark-palette5 = ["27" "57" "65"];
      dark-palette6 = ["191" "200" "179"];
      dark-palette7 = ["39" "90" "102"];
      dark-palette8 = ["100" "173" "180"];
      dark-palette9 = ["63" "139" "153"];
      dark-vw-color = ["0/718" "0/835" "0/561"];
      fitts-widgets = false;
      hscd-color = ["0/718" "0/835" "0/561"];
      light-bguri = "file:///home/${user}/.config/background.png";
      light-hscd-color = ["0/718" "0/835" "0/561"];
      light-vw-color = ["0,718" "0,835" "0,561"];
      palette1 = ["20" "31" "27"];
      palette10 = ["67" "45" "42"];
      palette11 = ["103" "77" "83"];
      palette12 = ["160" "75" "170"];
      palette2 = ["49" "84" "57"];
      palette3 = ["36" "63" "40"];
      palette4 = ["69" "118" "100"];
      palette5 = ["27" "57" "65"];
      palette6 = ["191" "200" "179"];
      palette7 = ["39" "90" "102"];
      palette8 = ["100" "173" "180"];
      palette9 = ["63" "139" "153"];
      pause-reload = false;
      reloadstyle = true;
    };

    "org/gnome/shell/extensions/window-list" = {
      display-all-workspaces = true;
      embed-previews = true;
      grouping-mode = "always";
      show-on-all-monitors = false;
    };

    "org/gnome/desktop/wm/preferences" = {
      theme = "Adwaita";
      titlebar-font = "Cantarell Bold 11";
      titlebar-uses-system-font = true;
    };

    # Extensions
    "org/gnome/shell".enabled-extensions = "@as ['emoji-copy@felipeftn', 'openbar@neuromorph', 'space-bar@luchrioh', 'todo.txt@bart.libert.gmail.com', 'user-theme@gnome-shell-extensions.gcampax.github.com', 'window-list@gnome-shell-extensions.gcampax.github.com', 'windowsNavigator@gnome-shell-extensions.gcampax.github.com', 'gnome-wireguard-extension@SJBERTRAND.github.com', 'docker@stickman_0x00.com', 'gsconnect@andyholmes.github.io', 'system-monitor@gnome-shell-extensions.gcampax.github.com', 'rclone-manager@germanztz.com']";
    "org/gnome/shell/extensions/workspace-indicator".embed-previews = true;
    
    "org/gnome/shell/extensions/system-monitor" = {
      show-cpu = true;
      show-download = false;
      show-memory = true;
      show-swap = false;
      show-upload = false;
    };

    "org/gnome/shell/extensions/emoji-copy".recently-used = "@as ['🦆', '🧑🦯', '🥹', '🚀', '✨', '😊', '😘', '❤️', '😍', '🛡️', '🔒']";
    
    "org/gnome/shell/extensions/rclone-manager" = {
      prefkey001-rconfig-file-path = "~/.config/rclone/rclone.conf";
      prefkey010-rclone-mount = "bash ~/.config/rclone/upd.sh && rclone --password-command %pcmd mount %profile: %source --volname %profile --file-perms 0777 --write-back-cache --no-modtime --daemon --daemon-timeout 30s";
      prefkey005-external-file-browser = "thunar";
    };

    # Programs
    "org/gnome/TextEditor" = {
      custom-font = "VictorMono Nerd Font Propo Bold 14";
      highlight-current-line = true;
      restore-session = false;
      last-save-directory = "file:///home/${user}/dotfiles";
      show-grid = true;
      show-line-numbers = true;
      show-map = true;
      style-scheme = "cobalt";
      tab-width = "4";
      use-system-font = false;
    };

    "org/gnome/gedit/plugins" = {
      active-plugins = "@as ['spell', 'quickhighlight', 'textsize', 'filebrowser', 'docinfo', 'sort']";
    };
    "org/gnome/gedit/plugins/filebrowser" = {
      filter-mode = "@as ['hide-binary']";
      root = "file:///";
      tree-view = true;
      virtual-root = "file:///home/${user}/dotfiles";
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

    # Security
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
      old-files-age = "30";
      remember-app-usage = true;
      remember-recent-files = true;
      report-technical-problems = false;
      send-software-usage-stats = false;
      usb-protection = true;
      usb-protection-level = "lockscreen";
    };

    # Desktop
    "org/gnome/desktop/peripherals/keyboard" = {
      repeat = true;
      delay = "2500";
      repeat-interval = "15";
    };
    "org/gnome/desktop/peripherals/mouse" = {
      speed = "-0.40000000000000001";
      accel-profile = "flat";
    };
    "org/gnome/desktop/interface" = {
      cursor-size = "24";
      cursor-theme = "Bibata-Modern-Classic";
      locate-pointer = true;
      document-font-name = "Cantarell 11";
      enable-animations = true;
      enable-hot-corners = false;
      font-name = "TeX Gyre Adventor 10";
      icon-theme = "elementary-xfce-icon-theme";
      monospace-font-name = "Source Code Pro 10";
      show-battery-percentage = false;
      toolkit-accessibility = true;
      toolbar-icons-size = "large";
      text-scaling-factor = "1/25";
    };

    # Break Reminders
    "org/gnome/desktop/break-reminders".selected-breaks = "@as []";
    "org/gnome/desktop/break-reminders/eyesight" = {
      countdown = true;
      delay-seconds = "180";
      duration-seconds = "20";
      fade-screen = true;
      interval-seconds = "1200";
      lock-screen = false;
      notify = true;
      notify-overdue = true;
      notify-upcoming = false;
      play-sound = true;
    };
    "org/gnome/desktop/break-reminders/movement" = {
      countdown = true;
      delay-seconds = "180";
      duration-seconds = "300";
      fade-screen = true;
      interval-seconds = "1800";
      lock-screen = false;
      notify = true;
      notify-overdue = true;
      notify-upcoming = true;
      play-sound = true;
    };

    # Notifications
    "org/gnome/desktop/notifications" = {
      show-banners = true;
      show-in-lock-screen = true;
    };

    # Additional settings...
  };
in
{
#  imports = [ ./keybindings-${hostname}.nix ];

  programs.dconf.enable = true;

  environment.etc = {
    "dconf/db/local.d/10-settings" = {
      text = lib.generators.toINI {} dconfSettings;
    };
    "dconf/profile/user" = {
      text = "user-db:local\n";
    };
  };


}
