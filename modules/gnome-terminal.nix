{ 
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf (lib.elem "thunar" config.this.host.modules.programs) {
    programs.dconf.enable = true;
    environment.systemPackages = with pkgs; [ gnome-terminal ];

    programs.dconf.profiles = {
      user = {
        settings = {
          "org/gnome/terminal/legacy" = {
            theme-variant = "dark";
            default-show-menubar = false;
          };
          "org/gnome/terminal/legacy/profiles:" = {
            default = "f1b6b16b-c421-4db6-b8f9-07c945bfa18d";
            list = [ "f1b6b16b-c421-4db6-b8f9-07c945bfa18d" ];
          };
          "org/gnome/terminal/legacy/profiles:/:f1b6b16b-c421-4db6-b8f9-07c945bfa18d" = {
            visible-name = "Matrix Theme";
            use-theme-colors = false;
            foreground-color = "#00ff00";
            background-color = "#000000";
            palette = [
              "#000000" "#ff0000" "#00ff00" "#ffff00" "#0000ff" "#ff00ff" "#00ffff"
              "#ffffff" "#808080" "#ff0000" "#00ff00" "#ffff00" "#0000ff" "#ff00ff"
              "#00ffff" "#ffffff"
            ];
            cursor-shape = "block";
            cursor-blink-mode = "on";
            font = "Monospace 12";
            scrollback-lines = 10000;
            scrollbar-policy = "always";
            bold-is-bright = true;
          };
        };
        locks = [
          "/org/gnome/terminal/legacy/theme-variant"
          "/org/gnome/terminal/legacy/default-show-menubar"
          "/org/gnome/terminal/legacy/profiles:"
        ];
      };
    };
  };
}
