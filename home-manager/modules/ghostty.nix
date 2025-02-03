{ pkgs, ... }:

{
  # Enable Ghostty configuration
  programs.ghostty = {
    enable = true;

    clearDefaultKeybinds = true;
    enableBashIntegration = true;
    installBatSyntax = true;
    
    # Ghostty settings
    settings = {
      #theme = "catppuccin-mocha";
      theme = "Solarized Light";
      font-size = 11;
      #font-family = "JetBrainsMono Nerd Font";
      font-family = "FiraCode Nerd Font";
      font-feature = ["-liga" "-dlig" "-calt"];   
      unfocused-split-opacity = 0.96;
      window-theme = "dark";
      macos-option-as-alt = true;

      clipboard-read = "allow";
      clipboard-write = "allow";

      keybind = [
        "ctrl+h=goto_split:left"
        "ctrl+l=goto_split:right"
      ];

    



    };


  };
}
