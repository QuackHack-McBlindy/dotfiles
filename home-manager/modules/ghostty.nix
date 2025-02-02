{ pkgs, ... }:

{
  # Enable Ghostty configuration
  programs.ghostty = {
    enable = true;

    # Set the package (null means it's managed externally)
 #   package = null;

    # Shell integration settings
 #   shellIntegration = {
 #     enable = true;
 #     enableZshIntegration = false;
#    };

    # Ghostty settings
    settings = {
      font-size = 11;
      font-family = "JetBrainsMono Nerd Font";

      # Adjust opacity for better theme compatibility
      unfocused-split-opacity = 0.96;

      # macOS specific settings
      window-theme = "dark";
      macos-option-as-alt = true;

      # Disable ligatures
      font-feature = ["-liga" "-dlig" "-calt"];

      # Reference an external color scheme
 #     config-file = [
#        (color-schemes + "/Ghostty/GruvboxDark")
#      ];
    };

    # Clear default keybindings if needed
 #   clearDefaultKeybindings = true;

    # Define custom keybindings
 #   keybindings = {
 #     "super+c" = "copy_to_clipboard";

 #     "super+shift+h" = "goto_split:left";
 #     "super+shift+j" = "goto_split:bottom";
  #    "super+shift+k" = "goto_split:top";
 #     "super+shift+l" = "goto_split:right";

 #     "ctrl+page_up" = "jump_to_prompt:-1";
#    };

    # Additional configuration (if required)
#    extraConfig = "";
  };
}
