{
  lib,
  user,
  hostname,
  ...
} : {

    imports = [
        ./../keybindings-${hostname}.nix
    ];
  
    dconf.enable = true;
    dconf.settings = {
    
        "org/gnome/desktop/a11y/applications" = {
            screen-magnifier-enabled = true;
            screen-reader-enabled = false;
        };
        "org.gnome.settings-daemon.plugins.color".night-light-temperature = 1700;
        "org/gnome/desktop/a11y/interface" = {
            high-contrast = true;
            show-status-shapes = true;
        };        
    # Magnifier
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

#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#──→ Keybindings ←──
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
    # Acesssbility Shortcuts   
#        "org/gnome/settings-daemon/plugins/media-keys" = {
#            magnifier-zoom-in = [ "KP_Add" ];
#            magnifier-zoom-out = [ "KP_Subtract" ];
#            screenreader = [ "KP_Divide" ];     
#        };
#    # Terminal    
#        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
#            binding = "section";
#            #command = "/etc/profiles/per-user/pungkula/bin/gnome-terminal";
#            command = "gnome-terminal --tab";
#            name = "terminal";
#        };    
#        # Copy
#        "org/gnome/terminal/legacy/keybindings".copy = [ "<Primary>c" ];
#        # Paste
#        "org/gnome/terminal/legacy/keybindings".paste = [ "<Primary>v"];
#        # Select All
#        "org/gnome/terminal/legacy/keybindings".select-all = [ "<Primary>a" ];
#    # Close Window
#        "org/gnome/desktop/wm/keybindings".close = [ "<Control>q" ];
#    # Switch Apps
#        "org/gnome/desktop/wm/keybindings".switch-applications = ["<Super>Tab" "<Alt>Tab"];
    # Lockscreen    
#        "org/gnome/settings-daemon/plugins/media-keys".screensaver = ["<Super>l"];
#    # Browser    
#        "org/gnome/settings-daemon/plugins/media-keys".www = ["<Control>w"];
#    # Screen Brightness    
##        "org/gnome/settings-daemon/plugins/media-keys".screen-brightness-up = [""];
 #       "org/gnome/settings-daemon/plugins/media-keys".screen-brightness-down = [""];
#    # Keyboard Brightness    
#        "org/gnome/settings-daemon/plugins/media-keys".keyboard-brightness-down = [""];
#        "org/gnome/settings-daemon/plugins/media-keys".keyboard-brightness-up = [""];
#    # Run
#        "org/gnome/desktop/wm/keybindings".panel-run-dialog = ["<Super>r"];
#    # Show Desktop
#        "org/gnome/desktop/wm/keybindings".show-desktop = ["<super>d"];
#    # Print Screen
#        "org/gnome/shell/keybindings".screenshot = ["<Shift>Print"];
#        "org/gnome/shell/keybindings".screenshot-window = ["<Alt>Print"];
#        "org/gnome/shell/keybindings".show-screenshot-ui = ["Print"];
#    # Workspaces
#        "org/gnome/desktop/wm/keybindings".move-to-workspace-1 = ["<Super><Shift>Home"];
#        "org/gnome/desktop/wm/keybindings".move-to-workspace-2 = [];
#        "org/gnome/desktop/wm/keybindings".move-to-workspace-3 = [];
#        "org/gnome/desktop/wm/keybindings".move-to-workspace-4 = [];
#        "org/gnome/desktop/wm/keybindings".switch-to-workspace-1 = ["<Control>1"];
#        "org/gnome/desktop/wm/keybindings".switch-to-workspace-2 = ["<Control>2"];
#        "org/gnome/desktop/wm/keybindings".switch-to-workspace-3 = ["<Control>3"];
#        "org/gnome/desktop/wm/keybindings".switch-to-workspace-4 = ["<Control>4"];
    #   "org/gnome/desktop/wm/keybindings".move-to-workspace-left = ["<Super><Shift>Page_Up", "<Super><Shift><Alt>Left", "<Control><Shift><Alt>Left"];
    #   "org/gnome/desktop/wm/keybindings".move-to-workspace-right = ["<Super><Shift>Page_Down", "<Super><Shift><Alt>Right", "<Control><Shift><Alt>Right"];

     # Spew Mark / Do Not Use Marked
        "org/gnome/desktop/wm/keybindings".set-spew-mark = [];

        "org/gnome/desktop/wm/preferences".action-double-click-titlebar = "toggle-maximize";

        "org/gnome/mutter".dynamic-workspaces = true;

        "org/gnome/settings-daemon/plugins/power".idle-brightness = "30";
        "org/gnome/settings-daemon/plugins/power".idle-dim = true;
        "org/gnome/settings-daemon/plugins/power".power-button-action = "suspend";
        "org/gnome/settings-daemon/plugins/power".power-saver-profile-on-low-battery = true;
        "org/gnome/settings-daemon/plugins/power".sleep-inactive-ac-timeout = "0";
        "org/gnome/settings-daemon/plugins/power".sleep-inactive-ac-type = "nothing";
        "org/gnome/settings-daemon/plugins/power".sleep-inactive-battery-timeout = "900";
        "org/gnome/settings-daemon/plugins/power".sleep-inactive-battery-type = "suspend";
        "org/gnome/settings-daemon/plugins/housekeeping".free-percent-notify = "0/050000000000000003";
        "org/gnome/settings-daemon/plugins/housekeeping".free-percent-notify-again = "0/01";
        "org/gnome/settings-daemon/plugins/housekeeping".min-notify-period = "10";
        "org/gnome/desktop/interface".clock-show-weekday = true;

#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#──→ THEME / VISUAL SETTINGS ←──
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
    # Dark Mode
        "org/gnome/desktop/interface".color-scheme = "prefer-dark";
    # Night Light
        "org/gnome/settings-daemon/plugins/color".night-light-enabled = true;
        "org/gnome/settings-daemon/plugins/color".night-light-temperature = "3670";
    # Fav Apps
        "org/gnome/shell".favorite-apps = ["firefox-esr.desktop" "thunar.desktop" "com.mitchellh.ghostty.desktop" "org.gnome.TextEditor.desktop"  "vesktop.desktop" "signal-desktop.desktop" "keepass.desktop"];
     # Open Bar
        "org/gnome/shell/extensions/openbar" = {
            bg-change = true;
          # "org/gnome/shell/extensions/openbar".bguri = "file:///home/pungkula/.config/background.png";
            count1 = "378725";
            count10 = "2650";
            count11 = "2527";
            count12 = "190";
            count2 = "114920";
            count3 = "91393";
            count4 = "54386";
            count5 = "29764";
            count6 = "22317";
            count7 = "21265";
            count8 = "20658";
            count9 = "11091";
            dark-bguri = "file:///home/pungkula/.config/background.png";
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
            light-bguri = "file:///home/pungkula/.config/background.png";
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
           # vw-color = ["0/718" "0/835" "0/561"];
        }; 
     # Window List
        "org/gnome/shell/extensions/window-list" = {
            display-all-workspaces = true;
            embed-previews = true;
            grouping-mode = "always";
            show-on-all-monitors = false;
        };  
     # Theme
        "org/gnome/desktop/wm/preferences" = {
            theme = "Adwaita";
            titlebar-font = "Cantarell Bold 11";
            titlebar-uses-system-font = true;
        }; 
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#──→ MISC EXTENSIONS ←──
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°  
     
     # Enabled Extensions
        "org/gnome/shell".enabled-extensions = [
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
    # Workspace Indicator
        "org/gnome/shell/extensions/workspace-indicator".embed-previews = true;
     # Sys Monitor
        "org/gnome/shell/extensions/system-monitor" = {
            show-cpu = true;
            show-download = false;
            show-memory = true;
            show-swap = false;
            show-upload = false;
        }; 
     # Emoji Copy
        "org/gnome/shell/extensions/emoji-copy".recently-used = ["🦆" "🧑‍🦯" "🥹" "🚀" "✨" "😊" "😘" "❤️" "😍" "🛡️" "🔒"];
     # RClone
        "org/gnome/shell/extensions/rclone-manager" = {
            prefkey001-rconfig-file-path = "~/.config/rclone/rclone.conf";
          #  hiddenkey012-profile-registry = "{"proton":{"syncType":"MOUNTED"}}";
            prefkey010-rclone-mount = "bash ~/.config/rclone/upd.sh && rclone --password-command %pcmd mount %profile: %source --volname %profile --file-perms 0777 --write-back-cache --no-modtime --daemon --daemon-timeout 30s";
            prefkey005-external-file-browser = "thunar";
        };    
        
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#──→ PROGRAMS ←──
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
    # Text Editor      
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
        
        
    # GEDIT 
        "org/gnome/gedit/plugins".active-plugins = [ "spell" "quickhighlight" "textsize" "filebrowser" "docinfo" "sort" ];
        "org/gnome/gedit/plugins/filebrowser".filter-mode = [ "hide-binary" ];
        "org/gnome/gedit/plugins/filebrowser".root = "file:///";
        "org/gnome/gedit/plugins/filebrowser".tree-view = true;
        "org/gnome/gedit/plugins/filebrowser".virtual-root = "file:///home/pungkula/dotfiles";
        "org/gnome/gedit/preferences/editor".insert-spaces = true;
        "org/gnome/gedit/preferences/editor".style-scheme-for-dark-theme-variant = "cobalt";
        "org/gnome/gedit/preferences/editor".tabs-size = 4;
        "org/gnome/gedit/preferences/editor".wrap-last-split-mode = "word";
        "org/gnome/gedit/preferences/ui".bottom-panel-visible = false;
        "org/gnome/gedit/preferences/ui".side-panel-visible = true;
        "org/gnome/gedit/state/window".height = 700;
        "org/gnome/gedit/state/window".maximized = true;
        "org/gnome/gedit/state/window".width = 900;
        
        
    # Tasks
     #  "org/gnome/desktop/default-applications/office/tasks".exec = "evolution -c tasks";
     #  "org/gnome/desktop/default-applications/office/tasks".needs-term = false;
   # Calendar
     #  "org/gnome/desktop/default-applications/office/calendar".exec = "evolution -c calendar";
     #  "org/gnome/desktop/default-applications/office/calendar".needs-term = false;
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#──→ ?? ←──
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°                     
     # Locale
        "org/gnome/system/location".enabled = false;
        "org/gnome/system/location".max-accuracy-level = "exact";
    # Dev Tools (ALT + F2)
        "org/gnome/shell".development-tools = true;
      # Power Profile
        "org/gnome/shell".last-selected-power-profile = "power-saver";
        "org/gnome/shell".remember-mount-password = true;
        "org/gnome/shell".welcome-dialog-last-shown-version = "47/2";
        "org/gnome/SessionManager".logout-prompt = true;
        "org/gnome/SessionManager".show-fallback-warning = true;
     # Arrangement of buttons on the titlebar/ The value should be a string
        "org/gnome/desktop/wm/preferences".button-layout = "appmenu:minimize,maximize,spacer,spacer,close"; # “menu:minimize,maximize,spacer,close”; colon separates left/right,comma-separated
        "org/gnome/desktop/wm/preferences".action-right-click-titlebar = "menu";
        "org/gnome/desktop/wm/preferences".focus-mode = "click";
     # Sound
        "org/gnome/desktop/sound".allow-volume-above-100-percent = false;
        "org/gnome/desktop/sound".event-sounds = true;
        "org/gnome/desktop/sound".input-feedback-sounds = false;
        "org/gnome/desktop/sound".theme-name = "freedesktop";
     # Lock
        "org/gnome/desktop/session".idle-delay = "1600";
        "org/gnome/desktop/screensaver" = {
          color-shading-type = "solid";
          logout-command = "";
          lock-enabled = false;
         # picture-uri = "file:///nix/store/il8jj170xlg5pg280nvzgbymlncz5nc1-simple-dark-gray-2016-02-19/share/backgrounds/nixos/nix-wallpaper-simple-dark-gray.png";
          primary-color = "#023c88";
          picture-opacity = "100";
          picture-options = "zoom";
          secondary-color = "#5789ca";
          status-message-enabled = true;
          user-switch-enabled = true;
        };  
        "org/gnome/desktop/calendar".show-weekdate = true;
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#──→ Security LockDown ←──
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
    # LockDown
        "org/gnome/desktop/lockdown".disable-command-line = false;
        "org/gnome/desktop/lockdown".disable-application-handlers = false;
        "org/gnome/desktop/lockdown".user-administration-disabled = false;
        "org/gnome/desktop/lockdown".mount-removable-storage-devices-as-read-only = false;
        "org/gnome/desktop/lockdown".disable-user-switching = false;
        "org/gnome/desktop/lockdown".disable-save-to-disk = false;
        "org/gnome/desktop/lockdown".disable-show-password = false;
        "org/gnome/desktop/lockdown".disable-print-setup = false;
        "org/gnome/desktop/lockdown".disable-printing = false;
        "org/gnome/desktop/lockdown".disable-log-out = false;
        "org/gnome/desktop/lockdown".disable-lock-screen = false;
     # Privacy
        "org/gnome/desktop/privacy".disable-camera = true;
        "org/gnome/desktop/privacy".disable-microphone = false;
        "org/gnome/desktop/privacy".disable-sound-output = false;
        "org/gnome/desktop/privacy".hide-identity = false;
        "org/gnome/desktop/privacy".old-files-age = "30";
        "org/gnome/desktop/privacy".remember-app-usage = true;
        "org/gnome/desktop/privacy".remember-recent-files = true;
        "org/gnome/desktop/privacy".report-technical-problems = false;
        "org/gnome/desktop/privacy".send-software-usage-stats = false;
        "org/gnome/desktop/privacy".usb-protection = true;
        "org/gnome/desktop/privacy".usb-protection-level = "lockscreen"; # always / lockscreen
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#──→ Desktop ←──
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
    # FIXME Broken
    # Keyboard Repeat  
        "org/gnome/desktop/peripherals/keyboard" = {
            repeat = true;
            delay = "2500"; # initial delay before repeat
            repeat-interval = "15";
        }; 
    # Mouse
        "org/gnome/desktop/peripherals/mouse".speed = "-0.40000000000000001";
        "org/gnome/desktop/peripherals/mouse".accel-profile = "flat";
        "org/gnome/desktop/interface".cursor-size = "24";
        "org/gnome/desktop/interface".cursor-theme = "Bibata-Modern-Classic";
        "org/gnome/desktop/interface".locate-pointer = true;
        "org/gnome/desktop/interface".document-font-name = "Cantarell 11";
        "org/gnome/desktop/interface".enable-animations = true;
        "org/gnome/desktop/interface".enable-hot-corners = false;
        "org/gnome/desktop/interface".font-name = "TeX Gyre Adventor 10 10";
    #    "org/gnome/desktop/interface".gtk-theme = "Yaru-magenta-dark";
    #    "org/gnome/desktop/interface".icon-theme = "Papirus-Dark";
        "org/gnome/desktop/interface".icon-theme = "elementary-xfce-icon-theme";
    
        "org/gnome/desktop/interface".monospace-font-name = "Source Code Pro 10";
        "org/gnome/desktop/interface".show-battery-percentage = false;
        "org/gnome/desktop/interface".toolkit-accessibility = true;
        "org/gnome/desktop/interface".toolbar-icons-size = "large";
        "org/gnome/desktop/interface".text-scaling-factor = "1/25";
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#──→  Break Reminders ←──
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
        "org/gnome/desktop/break-reminders".selected-breaks = [];
   # Break Reminder: Eyes
        "org/gnome/desktop/break-reminders/eyesight".countdown = true;
        "org/gnome/desktop/break-reminders/eyesight".delay-seconds = "180";
        "org/gnome/desktop/break-reminders/eyesight".duration-seconds = "20";
        "org/gnome/desktop/break-reminders/eyesight".fade-screen = true;
        "org/gnome/desktop/break-reminders/eyesight".interval-seconds = "1200";
        "org/gnome/desktop/break-reminders/eyesight".lock-screen = false;
        "org/gnome/desktop/break-reminders/eyesight".notify = true;
        "org/gnome/desktop/break-reminders/eyesight".notify-overdue = true;
        "org/gnome/desktop/break-reminders/eyesight".notify-upcoming = false;
        "org/gnome/desktop/break-reminders/eyesight".play-sound = true;
   # Break Reminder: Move
        "org/gnome/desktop/break-reminders/movement".countdown = true;
        "org/gnome/desktop/break-reminders/movement".delay-seconds = "180";
        "org/gnome/desktop/break-reminders/movement".duration-seconds = "300";
        "org/gnome/desktop/break-reminders/movement".fade-screen = true;
        "org/gnome/desktop/break-reminders/movement".interval-seconds = "1800";
        "org/gnome/desktop/break-reminders/movement".lock-screen = false;
        "org/gnome/desktop/break-reminders/movement".notify = true;
        "org/gnome/desktop/break-reminders/movement".notify-overdue = true;
        "org/gnome/desktop/break-reminders/movement".notify-upcoming = true;
        "org/gnome/desktop/break-reminders/movement".play-sound = true;
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#──→  Notifications ←──
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
        "org/gnome/desktop/notifications".show-banners = true;
        "org/gnome/desktop/notifications".show-in-lock-screen = true;
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#──→ System ←──
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
   # Proxy
      # "org/gnome/system/proxy".autoconfig-url = "";
      #  "org/gnome/system/proxy".ignore-hosts = ["localhost", "127/0/0/0/8", "::1"];
      #  "org/gnome/system/proxy".mode = "none";
      #  "org/gnome/system/proxy".use-same-proxy = true;
    # Shadowsocks (SOCKS5) Proxy
       # "org/gnome/system/proxy/socks".host = "";
       # "org/gnome/system/proxy/socks".port = "0";
    # HTTP Proxy
  #     "org/gnome/system/proxy/http".authentication-password = "";
  #     "org/gnome/system/proxy/http".authentication-user = "";
  #     "org/gnome/system/proxy/http".enabled = false;
  #     "org/gnome/system/proxy/http".host = "";
  #     "org/gnome/system/proxy/http".port = "8080";
  #     "org/gnome/system/proxy/http".use-authentication = false;
    };
}
