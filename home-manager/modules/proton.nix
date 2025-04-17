{ config, dotfiles, pkgs, ... }: 
{
  home.packages = with pkgs; [ 
    pkgs.protonvpn-gui 
    pkgs.proton-pass
    pkgs.protonvpn-cli
  ];
  

  
  # Proton VPN App Config
  home.file."proton-app-config" = {
    source = ./../../home/.config/Proton/VPN/app-config.json;
    target = "/.config/Proton/VPN/app-config.json";
    enable = true;
  };

  # Proton VPN Settings
  home.file.".proton-settings" = {
    source = ./../../home/.config/Proton/VPN/settings.json;
    target = "/.config/Proton/VPN/settings.json";
    enable = true;
  };
    
}


