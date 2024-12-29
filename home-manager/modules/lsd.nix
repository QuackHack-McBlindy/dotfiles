{ config, pkgs, ... }: 
{
  home.packages = with pkgs; [ pkgs.lsd ];
  
  programs.lsd.enable = true;
  
  # LSD Configuration
  home.file."lsd-config" = {
    source = "/home/pungkula/dotfiles/home/.config/lsd/config.yaml";
    target = "/.config/lsd/config.yaml";
    enable = true;
  };

  # LSD Colors
  home.file."lsd-colors" = {
    source = "/home/pungkula/dotfiles/home/.config/lsd/colors.yaml";
    target = "/.config/lsd/colors.yaml";
    enable = true;
  };

  # LSD Icons
  home.file."lsd-icons" = {
    source = "/home/pungkula/dotfiles/home/.config/lsd/icons.yaml";
    target = "/.config/lsd/icons.yaml";  
    enable = true;
  };
  
} 








#{
#    programs.lsd = {
#        enable = true;
#        enableAliases = true; 
#        colors = {
#            size = {
#                large = "dark_yellow";
#                none = "grey";
#                small = "yellow";
#            };
#        };
#        settings = {
#            date = "relative";
#            ignore-globs = [
#                ".git"
#                ".hg"
#            ];
#        };
#    };
#}
