{ 
    pkgs,
    config,
    lib,
    ...
}: let
    cfg = config.gui.gnome;
in {
 
    options.gui.gnome = {
    #    enable = lib.mkEnableOption "GNOME Graphical User Interface";
        
        background = lib.mkOption {
            type = lib.types.nullOr lib.types.path;
            default = ./../home/.config/wallpaper.png;
            description = "Path to GNOME wallpaper";
        };

        autoLogin = lib.mkOption {
            type = lib.types.submodule {
                options = {
                    enable = lib.mkOption {
                        type = lib.types.bool;
                        default = true;
                        description = "Enable automatic login for GNOME";
                    };
                };
            };
            default = {};
        };

        xserver = lib.mkOption {
            type = lib.types.submodule {
                options = {
                    enable = lib.mkOption {
                        type = lib.types.bool;
                        default = true;
                        description = "Enable X server configuration for GNOME";
                    };
                };
            };
            default = {};
        };
    };

    config = lib.mkIf cfg.enable (lib.mkMerge [
    {

        environment.systemPackages = with pkgs; [
            pkgs.gtk2
            pkgs.gtk3
            pkgs.gtk4
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
        
        
        # Background configuration (keep unchanged)
        services.xserver.desktopManager.gnome.extraGSettingsOverrides =
            lib.mkIf (cfg.background != null) ''
                [org.gnome.desktop.background]
                picture-uri='file://${cfg.background}'
                [org.gnome.desktop.screensaver]
                picture-uri='file://${cfg.background}'
            '';
    }

    (lib.mkIf cfg.xserver.enable {
        services.xserver = {
            enable = true;
            displayManager.gdm.enable = true;
            desktopManager.gnome.enable = true;
            layout = "se";
            xkbVariant = "";
        };
        console.keyMap = "sv-latin1";
    })
    
    (lib.mkIf cfg.autoLogin.enable {
        systemd.services."getty@tty1".enable = false;
        systemd.services."autovt@tty1".enable = false;
        services.xserver.displayManager.autoLogin = {
            enable = true;
            user = "pungkula";
        };
    })   
    ]);}
    
