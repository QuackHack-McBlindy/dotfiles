{ config, lib, pkgs, ... }:

{

  fonts = {
      enableDefaultFonts = true;
      fontDir.enable = true;
      packages = builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);
      fonts = with pkgs; [     
          fira-mono
          libertine
          open-sans
          twemoji-color-font
          liberation_ttf
          font-awesome 
          jetbrains-mono
         # nerdfonts.JetBrainsMono
      ];

      fontconfig = {
          enable = true;
          antialias = true;
          defaultFonts = {
              monospace = [ "Fira Mono" ];
              serif = [ "Linux Libertine" ];
              sansSerif = [ "Open Sans" ];
              emoji = [ "Twitter Color Emoji" ];
          };
     };
  };
}
