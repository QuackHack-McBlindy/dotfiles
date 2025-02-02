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
      theme = "catppuccin-mocha";
      font-size = 11;
      font-family = "JetBrainsMono Nerd Font";
      font-feature = ["-liga" "-dlig" "-calt"];   
      unfocused-split-opacity = 0.96;
      window-theme = "dark";
      macos-option-as-alt = true;

      keybind = [
        "ctrl+h=goto_split:left"
        "ctrl+l=goto_split:right"
      ];

    



    };


  };
}
