
{
  home.file = {
  # Vesktop/Settings.json
    "vesktop-settings" = {
      source = ./../../home/.config/vesktop/settings.json;
      target = ".config/vesktop/settings.json";
      enable = true;
    };


  # Vesktop/settings/Settings.json
    "vesktop-settings-setuings" = {
      source = ./../../home/.config/vesktop/settings/settings.json;
      target = ".config/vesktop/settings/settings.json";
      enable = true;
    };


  # Vesktop/settings/quickcss.css
    "vesktop-settings-quickcss" = {
      source = ./../../home/.config/vesktop/settings/quickCss.css;
      target = ".config/vesktop/settings/quickCss.css";
      enable = true;
    };    

  # vesktop/themes/FrostedGlass.theme.css
    "vesktop-themes-FrostedGlass" = {
      source = ./../../home/.config/vesktop/themes/FrostedGlass.theme.css;
      target = ".config/vesktop/themes/FrostedGlass.theme.css";
      enable = true;
    };    
  };
}    
