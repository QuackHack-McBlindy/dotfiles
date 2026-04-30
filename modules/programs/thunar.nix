# dotfiles/modules/programs/thunar.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ thunar configuration
  config,
  lib,
  pkgs,
  ...
} : {
    config = lib.mkIf (lib.elem "thunar" config.this.host.modules.programs) {
        environment.systemPackages = with pkgs; [ xfce.thunar ];
        programs.xfconf.enable = true;
        programs.thunar.enable = true;
        services.gvfs.enable = true; # 🦆says⮞ mount, trash, etc.
        services.tumbler.enable = true; # 🦆says⮞ thumbnail support   
        programs.thunar.plugins = with pkgs.xfce; [
            thunar-archive-plugin
            thunar-volman
        ];
        
        file.".config/xfce4/xfconf/xfce-perchannel-xml/thunar.xml" = ''
          <?xml version="1.1" encoding="UTF-8"?>

          <channel name="thunar" version="1.0">
            <property name="last-view" type="string" value="ThunarIconView"/>
            <property name="last-icon-view-zoom-level" type="string" value="THUNAR_ZOOM_LEVEL_75_PERCENT"/>
            <property name="last-separator-position" type="int" value="182"/>
            <property name="misc-single-click" type="bool" value="false"/>
            <property name="last-details-view-zoom-level" type="string" value="THUNAR_ZOOM_LEVEL_38_PERCENT"/>
            <property name="last-details-view-column-widths" type="string" value="50,50,161,50,50,116,50,50,151,50,50,98,50,152"/>
            <property name="last-window-maximized" type="bool" value="false"/>
            <property name="last-window-width" type="int" value="717"/>
            <property name="last-window-height" type="int" value="526"/>
            <property name="last-show-hidden" type="bool" value="true"/>
          </channel>        
        '';
        
    };}

