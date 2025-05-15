{ config, pkgs, lib, ... }:

{
  # Host-specific configuration for "desktop"
  config = lib.mkIf (config.this.host.hostname == "desktop") {
    environment.systemPackages = with pkgs; [ dconf ];
    programs.dconf.enable = true;

    dconf.settings = {
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
        move-to-workspace-2 = [];
        move-to-workspace-3 = [];
        move-to-workspace-4 = [];
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
  };

  # Add similar `lib.mkIf` blocks for "laptop", "nasty", "homie"
  config = lib.mkIf (config.this.host.hostname == "laptop") {
    # laptop-specific config here
  };

  config = lib.mkIf (config.this.host.hostname == "nasty") {
    # nasty-specific config here
  };

  config = lib.mkIf (config.this.host.hostname == "homie") {
    # homie-specific config here
  };
}
