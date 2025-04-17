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
