{ pkgs, ... }:

{
  # Enable Ghostty configuration
  programs.ghostty = {
    enable = true;

    clearDefaultKeybinds = false;
    enableBashIntegration = true;
    installBatSyntax = true;
    
    # Ghostty settings
    settings = {
      theme = "catppuccin-mocha";
     # theme = "Solarized Light";

      mouse-scroll-multiplier = 2; 
 
     
###### FONT
      font-size = 13;
      #font-family = "JetBrainsMono Nerd Font";
      font-family = "FiraCode Nerd Font";
      font-feature = ["-liga" "-dlig" "-calt"];   
      
      unfocused-split-opacity = 0.96;
      window-theme = "dark";
    #  macos-option-as-alt = true;

##### CURSOR
      cursor-color = "#FFFFFF";
   #   cursor-opacity
      cursor-style = "bar";

##### COLOR
      foreground = "#66FF66";
      background = "#000000";
     # selection-foreground = ;
     # selection-background = ;

      clipboard-read = "allow";
      clipboard-write = "allow";

      keybind = [
       # "ctrl+h=goto_split:left"
       # "ctrl+l=goto_split:right"
        "ctrl+a=select_all"
        "ctrl+c=copy_to_clipboard"
      #  "ctrl+v=paste"
        "ctrl+q=close_all_windows"
      ];

    };
    

    themes = 
    {
      catppuccin-mocha = {
        background = "1e1e2e";
        cursor-color = "f5e0dc";
        foreground = "cdd6f4";
        palette = [
          "0=#45475a"
          "1=#f38ba8"
          "2=#a6e3a1"
          "3=#f9e2af"
          "4=#89b4fa"
          "5=#f5c2e7"
          "6=#94e2d5"
          "7=#bac2de"
          "8=#585b70"
          "9=#f38ba8"
          "10=#a6e3a1"
          "11=#f9e2af"
          "12=#89b4fa"
          "13=#f5c2e7"
          "14=#94e2d5"
          "15=#a6adc8"
        ];
        selection-background = "353749";
        selection-foreground = "cdd6f4";
      };
    };
    

  };
}
