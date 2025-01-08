{ config, pkgs, ... }: 
{
    environment.systemPackages = with pkgs; [ pkgs.xfce.thunar ];
    programs.xfconf.enable = true;
    programs.thunar.enable = true;
    services.gvfs.enable = true; # Mount, trash, and other functionalities
    services.tumbler.enable = true; # Thumbnail support for images   
    programs.thunar.plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-volman
    ];
}

