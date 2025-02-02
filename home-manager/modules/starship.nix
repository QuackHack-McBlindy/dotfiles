{ config, pkgs, ... }: 
{
  home.packages = with pkgs; [ pkgs.starship ];
  
#  programs.starship = {
#    enable = true;
 # };

  # Starship.toml
#  home.file."starship-config" = {
#    source = ./../../home/.config/starship.toml;
#    target = "/.config/starship.toml";
#    enable = true;
#  };


}  

