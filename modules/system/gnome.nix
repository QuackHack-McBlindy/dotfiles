# dotfiles/modules/system/gnome.nix
{ 
    config,
    lib,
    pkgs,
    ...
} : let
    cfg.background = ./../../home/.config/wallpaper.png;
in {
    config = lib.mkMerge [
        (lib.mkIf (lib.elem "gnome" config.this.host.modules.system) {
            environment.systemPackages = with pkgs; [
                pkgs.gtk2
                pkgs.gtk3
                pkgs.gtk4
                pkgs.gnome-terminal
                pkgs.gnome-tweaks
                pkgs.nixos-icons
                pkgs.gnome-screenshot    
                pkgs.gnome-shell
                pkgs.gnome-system-monitor 
    
                pkgs.gnomeExtensions.rclone-manager
                gnomeExtensions.gsconnect
                pkgs.gnomeExtensions.docker
                pkgs.gnomeExtensions.proton-vpn-button
                pkgs.gnomeExtensions.wireguard-vpn-extension
                pkgs.gnomeExtensions.gsconnect
                pkgs.gnomeExtensions.open-bar
                pkgs.gnomeExtensions.dashbar
                pkgs.gnomeExtensions.task-up
                pkgs.gnomeExtensions.emoji-copy
                pkgs.gnomeExtensions.todotxt
                pkgs.gnomeExtensions.space-bar
                pkgs.gnomeExtensions.vitals
                pkgs.gnomeExtensions.appindicator 
                pkgs.gnomeExtensions.systemd-manager
                pkgs.dconf2nix # dconf2nix -i dconf.settings -o output/dconf.nix
                pkgs.dconf-editor
                pkgs.dconf
                pkgs.glib
                pkgs.gsettings-desktop-schemas
                pkgs.nautilus
            ];


            services.udev.packages = [ pkgs.gnome-settings-daemon ];
            services.gnome.at-spi2-core.enable = true;

            environment.gnome.excludePackages = 
                (with pkgs; [
                    gnome-photos
                    gnome-tour
                    gnome-maps
                    gnome-weather
                    gnome-clocks
                ]) ++ (with pkgs.gnome; [
                    pkgs.cheese # webcam tool
                    pkgs.gnome-music
                    pkgs.file-roller
                    pkgs.epiphany # web browser
                    pkgs.geary # email reader
                    pkgs.evince # document viewer
                    pkgs.gnome-characters
                    pkgs.gnome-font-viewer
                    pkgs.gnome-disk-utility
                    pkgs.totem # video player
                    pkgs.tali # poker game
                    pkgs.iagno # go game
                    pkgs.hitori # sudoku game
                    pkgs.rygel
                    pkgs.yelp
                    pkgs.gnome-clocks
                    pkgs.gnome-contacts
                ]);   
        
#            services.xserver.desktopManager.gnome.extraGSettingsOverrides = ''
#                [org.gnome.desktop.background]
#                picture-uri='file://${cfg.background}'
#                [org.gnome.desktop.screensaver]
#                picture-uri='file://${cfg.background}'
#            '';

            services.xserver = {
                enable = true;
                displayManager.gdm.enable = true;
                desktopManager.gnome.enable = true;
                layout = "se";
                xkbVariant = "";
            };
            console.keyMap = "sv-latin1";

            systemd.services."getty@tty1".enable = false;
            systemd.services."autovt@tty1".enable = false;
            services.xserver.displayManager.autoLogin = {
                enable = true;
                user = config.this.user.me.name;
            };
        
            fonts = {
                enableDefaultFonts = true;
                fontDir.enable = true;
                packages = builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);
                fonts = with pkgs; [          
                    fira-mono
                    libertine
                    open-sans
                    twemoji-color-font
                    liberation_ttf
                    font-awesome 
                    jetbrains-mono
                ];

                fontconfig = {
                    enable = true;
                    antialias = true;
                    defaultFonts = {
                        monospace = [ "Fira Mono" ];
                        serif = [ "Linux Libertine" ];
                        sansSerif = [ "Open Sans" ];
                        emoji = [ "Twitter Color Emoji" ];
                    };
                };
            };  
   
   
            programs.dconf.enable = true;
            programs.dconf.profiles.user.databases = [{
              settings = {
                "org/gnome/desktop/a11y/applications" = {
                  screen-magnifier-enabled = lib.gvariant.mkBoolean true;
                  screen-reader-enabled = lib.gvariant.mkBoolean false;
                };

                "org/gnome/settings-daemon/plugins/color" = {
                  night-light-enabled = lib.gvariant.mkBoolean true;
                  night-light-temperature = lib.gvariant.mkUint32 3670;
                };

                "org/gnome/desktop/a11y/interface" = {
                  high-contrast = lib.gvariant.mkBoolean true;
                  show-status-shapes = lib.gvariant.mkBoolean true;
                };

                "org/gnome/desktop/a11y/magnifier" = {
                  brightness-blue = lib.gvariant.mkString "-0/048611111111111049";
                  brightness-green = lib.gvariant.mkString "-0/048611111111111049";
                  brightness-red = lib.gvariant.mkString "-0/048611111111111049";
                  caret-tracking = lib.gvariant.mkString "centered";
                  color-saturation = lib.gvariant.mkString "1/0";
                  contrast-blue = lib.gvariant.mkString "0/0";
                  contrast-green = lib.gvariant.mkString "0/0";
                  contrast-red = lib.gvariant.mkString "0/0";
                  cross-hairs-clip = lib.gvariant.mkBoolean false;
                  cross-hairs-color = lib.gvariant.mkString "#ff0000";
                  cross-hairs-length = lib.gvariant.mkString "4096";
                  cross-hairs-opacity = lib.gvariant.mkString "0/66000000000000003";
                  cross-hairs-thickness = lib.gvariant.mkString "8";
                  focus-tracking = lib.gvariant.mkString "proportional";
                  invert-lightness = lib.gvariant.mkBoolean false;
                  lens-mode = lib.gvariant.mkBoolean false;
                  mag-factor = lib.gvariant.mkString "6/0";
                  mouse-tracking = lib.gvariant.mkString "proportional";
                  screen-position = lib.gvariant.mkString "full-screen";
                  scroll-at-edges = lib.gvariant.mkBoolean true;
                  show-cross-hairs = lib.gvariant.mkBoolean false;
                };

                "org/gnome/desktop/wm/preferences" = {
                  action-double-click-titlebar = lib.gvariant.mkString "toggle-maximize";
                  button-layout = lib.gvariant.mkString "appmenu:minimize,maximize,spacer,spacer,close";
                  action-right-click-titlebar = lib.gvariant.mkString "menu";
                  focus-mode = lib.gvariant.mkString "click";
                  theme = lib.gvariant.mkString "Adwaita";
                  titlebar-font = lib.gvariant.mkString "Cantarell Bold 11";
                  titlebar-uses-system-font = lib.gvariant.mkBoolean true;
                };

                "org/gnome/mutter" = {
                  dynamic-workspaces = lib.gvariant.mkBoolean true;
                };

                "org/gnome/settings-daemon/plugins/power" = {                                               idle-brightness = lib.gvariant.mkUint32 30;
                  idle-dim = lib.gvariant.mkBoolean true;
                  power-button-action = lib.gvariant.mkString "suspend";
                  power-saver-profile-on-low-battery = lib.gvariant.mkBoolean true;
                  sleep-inactive-ac-timeout = lib.gvariant.mkUint32 0;
                  sleep-inactive-ac-type = lib.gvariant.mkString "nothing";
                  sleep-inactive-battery-timeout = lib.gvariant.mkUint32 900;
                  sleep-inactive-battery-type = lib.gvariant.mkString "suspend";
                };

                "org/gnome/settings-daemon/plugins/housekeeping" = {
                  free-percent-notify = lib.gvariant.mkDouble 0.05;
                  free-percent-notify-again = lib.gvariant.mkDouble 0.01;
                  min-notify-period = lib.gvariant.mkUint32 10;
                };

                "org/gnome/desktop/interface" = {
                  clock-show-weekday = lib.gvariant.mkBoolean true;
                  color-scheme = lib.gvariant.mkString "prefer-dark";
                  cursor-size = lib.gvariant.mkInt32 24;
                  cursor-theme = lib.gvariant.mkString "Bibata-Modern-Classic";
                  document-font-name = lib.gvariant.mkString "Cantarell 11";
                  enable-animations = lib.gvariant.mkBoolean true;
                  enable-hot-corners = lib.gvariant.mkBoolean false;
                  font-name = lib.gvariant.mkString "TeX Gyre Adventor 10";
                  icon-theme = lib.gvariant.mkString "elementary-xfce-icon-theme";
                  locate-pointer = lib.gvariant.mkBoolean true;
                  monospace-font-name = lib.gvariant.mkString "Source Code Pro 10";
                  show-battery-percentage = lib.gvariant.mkBoolean false;
                  text-scaling-factor = lib.gvariant.mkDouble 1.25;
                  toolkit-accessibility = lib.gvariant.mkBoolean true;
                  toolbar-icons-size = lib.gvariant.mkString "large";
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
                  development-tools = lib.gvariant.mkBoolean true;
                  last-selected-power-profile = lib.gvariant.mkString "power-saver";
                  remember-mount-password = lib.gvariant.mkBoolean true;
                  welcome-dialog-last-shown-version = lib.gvariant.mkString "47/2";
                };

                "org/gnome/shell/extensions/openbar" = {
                  bg-change = lib.gvariant.mkBoolean true;
                  dark-bguri = lib.gvariant.mkString "file:///home/pungkula/.config/background.png";
                  light-bguri = lib.gvariant.mkString "file:///home/pungkula/.config/background.png";

                  count1 = lib.gvariant.mkUint32 378725;
                  count10 = lib.gvariant.mkUint32 2650;
                  count11 = lib.gvariant.mkUint32 2527;
                  count12 = lib.gvariant.mkUint32 190;
                  count2 = lib.gvariant.mkUint32 114920;
                  count3 = lib.gvariant.mkUint32 91393;
                  count4 = lib.gvariant.mkUint32 54386;
                  count5 = lib.gvariant.mkUint32 29764;
                  count6 = lib.gvariant.mkUint32 22317;                                                     count7 = lib.gvariant.mkUint32 21265;
                  count8 = lib.gvariant.mkUint32 20658;                                                     count9 = lib.gvariant.mkUint32 11091;

                  dark-hscd-color = [
                    (lib.gvariant.mkDouble 0.718)
                    (lib.gvariant.mkDouble 0.835)
                    (lib.gvariant.mkDouble 0.561)
                  ];

                  dark-palette1 = [
                    (lib.gvariant.mkUint32 20)
                    (lib.gvariant.mkUint32 31)
                    (lib.gvariant.mkUint32 27)
                  ];

                  dark-palette2 = [
                    (lib.gvariant.mkUint32 49)
                    (lib.gvariant.mkUint32 84)
                    (lib.gvariant.mkUint32 57)
                  ];

                  # Continue this pattern for all palette entries
                  dark-palette3 = [
                    (lib.gvariant.mkUint32 36)
                    (lib.gvariant.mkUint32 63)
                    (lib.gvariant.mkUint32 40)
                  ];

                  dark-palette4 = [
                    (lib.gvariant.mkUint32 69)
                    (lib.gvariant.mkUint32 118)
                    (lib.gvariant.mkUint32 100)
                  ];

                  dark-vw-color = [
                    (lib.gvariant.mkDouble 0.718)
                    (lib.gvariant.mkDouble 0.835)
                    (lib.gvariant.mkDouble 0.561)
                  ];

                  fitts-widgets = lib.gvariant.mkBoolean false;

                  hscd-color = [
                    (lib.gvariant.mkDouble 0.718)
                    (lib.gvariant.mkDouble 0.835)
                    (lib.gvariant.mkDouble 0.561)
                  ];

                  light-hscd-color = [
                    (lib.gvariant.mkDouble 0.718)
                    (lib.gvariant.mkDouble 0.835)
                    (lib.gvariant.mkDouble 0.561)
                  ];

                  light-vw-color = [
                    (lib.gvariant.mkDouble 0.718)
                    (lib.gvariant.mkDouble 0.835)
                    (lib.gvariant.mkDouble 0.561)
                  ];

                  # Apply the same pattern to all palette entries
                  palette1 = [
                    (lib.gvariant.mkUint32 20)
                    (lib.gvariant.mkUint32 31)
                    (lib.gvariant.mkUint32 27)
                  ];

                  palette2 = [
                    (lib.gvariant.mkUint32 49)
                    (lib.gvariant.mkUint32 84)
                    (lib.gvariant.mkUint32 57)
                  ];
                };

                "org/gnome/TextEditor" = {
                  custom-font = lib.gvariant.mkString "VictorMono Nerd Font Propo Bold 14";
                  highlight-current-line = lib.gvariant.mkBoolean true;
                  restore-session = lib.gvariant.mkBoolean false;
                  last-save-directory = lib.gvariant.mkString "file:///home/pungkula/dotfiles";
                  show-grid = lib.gvariant.mkBoolean true;
                  show-line-numbers = lib.gvariant.mkBoolean true;
                  show-map = lib.gvariant.mkBoolean true;
                  style-scheme = lib.gvariant.mkString "cobalt";
                  tab-width = lib.gvariant.mkUint32 4;
                  use-system-font = lib.gvariant.mkBoolean false;
                };

                "org/gnome/desktop/privacy" = {
                  disable-camera = lib.gvariant.mkBoolean true;
                  disable-microphone = lib.gvariant.mkBoolean false;
                  usb-protection = lib.gvariant.mkBoolean true;
                  usb-protection-level = lib.gvariant.mkString "lockscreen";
                };

                "org/gnome/desktop/lockdown" = {
                  disable-user-switching = lib.gvariant.mkBoolean false;
                  disable-lock-screen = lib.gvariant.mkBoolean false;
                };

                "org/gnome/gedit/preferences/editor" = {
                  insert-spaces = lib.gvariant.mkBoolean true;
                  tabs-size = lib.gvariant.mkUint32 4;
                  style-scheme-for-dark-theme-variant = lib.gvariant.mkString "cobalt";
                };

                "org/gnome/desktop/peripherals/keyboard" = {
                  repeat = lib.gvariant.mkBoolean true;
                  delay = lib.gvariant.mkString "2500";
                  repeat-interval = lib.gvariant.mkString "15";
                };


                "org/gnome/desktop/break-reminders/eyesight" = {
                  interval-seconds = lib.gvariant.mkString "1200";
                  duration-seconds = lib.gvariant.mkString "20";
                };

                "org/gnome/shell/extensions/system-monitor" = {
                  show-cpu = lib.gvariant.mkBoolean true;
                  show-memory = lib.gvariant.mkBoolean true;
                };

                "org/gnome/desktop/screensaver" = {
                  lock-enabled = lib.gvariant.mkBoolean false;
                  picture-options = lib.gvariant.mkString "zoom";
                };

                "org/gnome/shell/extensions/workspace-indicator" = {
                  embed-previews = lib.gvariant.mkBoolean true;
                };

                "org/gnome/settings-daemon/plugins/media-keys" = {
                  screensaver = lib.gvariant.mkArray [ "<Super>l" ];
                };
              };
            }];
    
        })

        
        (lib.mkIf (config.this.host.hostname == "desktop") {
          environment.systemPackages = with pkgs; [ 
            dconf 
            procps # Required for pgrep
          ];
          programs.dconf.enable = true;
          programs.dconf.profiles.user.databases = [
            {
              settings = {
                # MUST list ALL custom keybinding paths here
                "org/gnome/settings-daemon/plugins/media-keys" = {
                  custom-keybindings = [
                    "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
                    "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
                    "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
                  ];
                  magnifier-zoom-in = ["KP_Add"];
                  magnifier-zoom-out = ["KP_Subtract"];
                  screenreader = ["KP_Divide"];
                  screensaver = ["<Super>l"];
                  www = ["<Control>w"];
                  screen-brightness-up = [""];
                  screen-brightness-down = [""];
                  keyboard-brightness-up = ["<Primary>KP_Add"];
                  keyboard-brightness-down = ["<Primary>KP_Subtract"];
                };
        
                # Fixed terminal command with absolute paths
                "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
                  name = "terminal";
                  command = "bash -c 'if ! pgrep gnome-terminal-server >/dev/null; then gnome-terminal; else gnome-terminal --tab; fi'";
                  binding = "section"; # Verify key symbol with xev
                };
        
                "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
                  name = "Gedit New Window";
                  command = "/etc/profiles/per-user/pungkula/bin/gedit --new-window";
                  binding = "<Primary>e";
                };
        
                "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
                  name = "File Manager dotfiles";
                  command = "thunar /home/pungkula/dotfiles";
                  binding = "<Primary><Shift>d";
                };
        
                # Rest of your existing configuration remains unchanged
                "org/gnome/terminal/legacy/keybindings" = {
                  copy = ["<Primary>c"];
                  paste = ["<Primary>v"];
                  select-all = ["<Primary>a"];
                };
        
                "org/gnome/desktop/wm/keybindings" = {
                  close = ["<Control>q"];
                  switch-applications = ["<Super>Tab" "<Alt>Tab"];
                  panel-run-dialog = ["<Super>r"];
                  show-desktop = ["<Super>d"];
                  move-to-workspace-1 = ["<Super><Shift>Home"];
                  move-to-workspace-2 = lib.gvariant.mkEmptyArray lib.gvariant.type.string;
                  move-to-workspace-3 = lib.gvariant.mkEmptyArray lib.gvariant.type.string;
                  move-to-workspace-4 = lib.gvariant.mkEmptyArray lib.gvariant.type.string;
                  switch-to-workspace-1 = ["<Control>1"];
                  switch-to-workspace-2 = ["<Control>2"];
                  switch-to-workspace-3 = ["<Control>3"];
                  switch-to-workspace-4 = ["<Control>4"];
                };
        
                "org/gnome/shell/keybindings" = {
                  screenshot = ["<Shift>Print"];
                  screenshot-window = ["<Alt>Print"];
                  show-screenshot-ui = ["Print"];
                };
              };        
            }
          ];
        })
        
      
  
        (lib.mkIf (config.this.host.hostname == "laptop") {
            environment.systemPackages = with pkgs; [ dconf ];
            programs.dconf.enable = true;
            programs.dconf.profiles.user.databases = [
                {
                    settings = {
                        "org/gnome/settings-daemon/plugins/media-keys" = {
                            magnifier-zoom-in = ["KP_Add"];
                            magnifier-zoom-out = ["KP_Subtract"];
                            screenreader = ["KP_Divide"];
                            screensaver = ["<Super>l"];
                            www = ["<Control>w"];
                            screen-brightness-up = [""];
                            screen-brightness-down = [""];
                            keyboard-brightness-up = ["<Primary>KP_Add"];
                            keyboard-brightness-down = ["<Primary>KP_Subtract"];
                        };

                        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
                            name = "terminal";
                            command = "/etc/profiles/per-user/pungkula/bin/ghostty";
                            binding = "section";
                        };
                        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
                            name = "Gedit New Window";
                            command = "/etc/profiles/per-user/pungkula/bin/gedit --new-window";
                            binding = "<Primary>e";
                        };
                        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
                            name = "File Manager dotfiles";
                            command = "thunar /home/pungkula/dotfiles";
                            binding = "<Primary><Shift>d";
                        };

                        "org/gnome/terminal/legacy/keybindings" = {
                            copy = ["<Primary>c"];
                            paste = ["<Primary>v"];
                            select-all = ["<Primary>a"];
                        };

                        "org/gnome/desktop/wm/keybindings" = {
                            close = ["<Control>q"];
                            switch-applications = ["<Super>Tab" "<Alt>Tab"];
                            panel-run-dialog = ["<Super>r"];
                            show-desktop = ["<Super>d"];
                            move-to-workspace-1 = ["<Super><Shift>Home"];
                            move-to-workspace-2 = lib.gvariant.mkEmptyArray lib.gvariant.type.string;
                            move-to-workspace-3 = lib.gvariant.mkEmptyArray lib.gvariant.type.string;
                            move-to-workspace-4 = lib.gvariant.mkEmptyArray lib.gvariant.type.string;
                            switch-to-workspace-1 = ["<Control>1"];
                            switch-to-workspace-2 = ["<Control>2"];
                            switch-to-workspace-3 = ["<Control>3"];
                            switch-to-workspace-4 = ["<Control>4"];
                        };

                        "org/gnome/shell/keybindings" = {
                            screenshot = ["<Shift>Print"];
                            screenshot-window = ["<Alt>Print"];
                            show-screenshot-ui = ["Print"];
                        };
                    };        
                }
            ];
        })
    ];} 

