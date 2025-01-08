{ config, pkgs, ... }: 
{
  home.packages = with pkgs; [ pkgs.lsd ];
  
  programs.lsd.enable = true;
  
  # LSD Configuration
  home.file."lsd-config" = {
    #source = ./../../home/.config/lsd/config.yaml;
    source = ./../../home/.config/lsd;
    target = "/.config/lsd";
    enable = true;
  };

  # LSD Colors
#  home.file."lsd-colors" = {
#    source = ./../../home/.config/lsd/colors.yaml;
#    target = "/.config/lsd/colors.yaml";
 #   enable = true;
#  };

  # LSD Icons
#  home.file."lsd-icons" = {
#    source = ./../../home/.config/lsd/icons.yaml;
#    target = "/.config/lsd/icons.yaml";  
#    enable = true;
 # };
  
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
