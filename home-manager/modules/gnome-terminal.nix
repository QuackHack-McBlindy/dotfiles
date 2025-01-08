{
  programs.gnome-terminal = {
    enable = true;
    showMenubar = false;
    themeVariant = "dark";

    profile = {
      # A matrix-themed profile, UUID generated using `uuidgen`
      "f1b6b16b-c421-4db6-b8f9-07c945bfa18d" = {
        default = true;
        visibleName = "Matrix Theme";
        colors = {
          foregroundColor = "#00ff00"; # Bright green for foreground text
          backgroundColor = "#000000"; # Black background
          palette = [
            "#000000" "#ff0000" "#00ff00" "#ffff00"
            "#0000ff" "#ff00ff" "#00ffff" "#ffffff"
            "#808080" "#ff0000" "#00ff00" "#ffff00"
            "#0000ff" "#ff00ff" "#00ffff" "#ffffff"
          ]; # Matrix-like neon colors
        };
        cursorShape = "block"; # Solid block cursor
        cursorBlinkMode = "on"; # Make cursor blink
        font = "Monospace 12"; # Easy-to-read monospace font
        scrollbackLines = 10000; # Keep lots of scrollback lines
        showScrollbar = true;
        allowBold = true;
      };
    };
  };
}
