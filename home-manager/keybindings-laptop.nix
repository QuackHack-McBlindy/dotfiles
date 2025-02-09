#{ self, lib, pkgs, dotfiles, hostname, ... }:

#with lib.hm.gvariant;
  
{

 
    dconf.enable = true;
    dconf.settings = {
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#──→ Keybindings ←──
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
    # Acesssbility Shortcuts   
        "org/gnome/settings-daemon/plugins/media-keys" = {
            magnifier-zoom-in = [ "<Conrol>Page_Up" ];
            magnifier-zoom-out = [ "<Conrol>Page_Down" ];
            screenreader = [ "KP_Divide" ];     
        };
    # [  ] Terminal 
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
            binding = "section";
            command = "/run/current-system/sw/bin/ghostty";
            name = "terminal";
        };  
        
    # [ CTRL + E ] Editor new window    
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
            binding = "<Primary>e";
            command = "/run/current-system/sw/bin/gedit --new-window";
            name = "Gedit New Window";
        };   
        
    # [ CTRL + D ] dotfiles File Manager 
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
         #   binding = "<Primary><shift>d";
            binding = "<Primary>d";
            command = "/run/current-system/sw/bin/thunar /home/$USER/dotfiles";
            name = "File Manager dotfiles";
        };   
            
        # Copy
        "org/gnome/terminal/legacy/keybindings".copy = [ "<Primary>c" ];
        # Paste
        "org/gnome/terminal/legacy/keybindings".paste = [ "<Primary>v"];
        # Select All
        "org/gnome/terminal/legacy/keybindings".select-all = [ "<Primary>a" ];
    # Close Window
        "org/gnome/desktop/wm/keybindings".close = [ "<Control>q" ];
    # Switch Apps
        "org/gnome/desktop/wm/keybindings".switch-applications = ["<Super>Tab" "<Alt>Tab"];
    # Lockscreen    
        "org/gnome/settings-daemon/plugins/media-keys".screensaver = ["<Super>l"];
    # Browser    
        "org/gnome/settings-daemon/plugins/media-keys".www = ["<Control>w"];
    # Screen Brightness    
        "org/gnome/settings-daemon/plugins/media-keys".screen-brightness-up = [""];
        "org/gnome/settings-daemon/plugins/media-keys".screen-brightness-down = [""];
    # Keyboard Brightness    
        "org/gnome/settings-daemon/plugins/media-keys".keyboard-brightness-down = [""];
        "org/gnome/settings-daemon/plugins/media-keys".keyboard-brightness-up = [""];
    # Run
        "org/gnome/desktop/wm/keybindings".panel-run-dialog = ["<Super>r"];
    # Show Desktop
        "org/gnome/desktop/wm/keybindings".show-desktop = ["<super>d"];
    # Print Screen
        "org/gnome/shell/keybindings".screenshot = ["<Shift>Print"];
        "org/gnome/shell/keybindings".screenshot-window = ["<Alt>Print"];
        "org/gnome/shell/keybindings".show-screenshot-ui = ["Print"];
    # Workspaces
        "org/gnome/desktop/wm/keybindings".move-to-workspace-1 = ["<Super><Shift>Home"];
        "org/gnome/desktop/wm/keybindings".move-to-workspace-2 = [];
        "org/gnome/desktop/wm/keybindings".move-to-workspace-3 = [];
        "org/gnome/desktop/wm/keybindings".move-to-workspace-4 = [];
        "org/gnome/desktop/wm/keybindings".switch-to-workspace-1 = ["<Control>1"];
        "org/gnome/desktop/wm/keybindings".switch-to-workspace-2 = ["<Control>2"];
        "org/gnome/desktop/wm/keybindings".switch-to-workspace-3 = ["<Control>3"];
        "org/gnome/desktop/wm/keybindings".switch-to-workspace-4 = ["<Control>4"];
    };
}
