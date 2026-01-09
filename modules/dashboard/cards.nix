# dotfiles/modules/dashboard/cards.nix.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ auto generate smart home dashboard
  lib, 
  pkgs,
  ...
}: let 

  statusCardThemes = {
    neon = {
      name = "neon";
      cssVars = {
        "--card-bg" = "linear-gradient(135deg, rgba(255, 255, 255, 0.1), rgba(255, 255, 255, 0.05))";
        "--card-blur" = "blur(10px)";
        "--card-border" = "2px solid rgba(255, 255, 255, 0.1)";
        "--card-radius" = "24px";
        "--card-padding" = "25px";
        "--card-gap" = "15px";
        "--card-shadow-default" = "0 10px 40px rgba(0, 0, 0, 0.3)";
        "--card-glow-default" = "0 0 30px rgba(255, 230, 0, 0.3)";
        "--card-hover-transform" = "translateY(-10px) rotateX(5deg)";
        "--card-hover-border-color" = "var(--duck-yellow)";
        "--card-hover-shadow" = "var(--card-glow-default), 0 20px 50px rgba(255, 230, 0, 0.2)";
        "--card-transition" = "all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275)";
        
        "--title-size" = "2.3rem";
        "--title-weight" = "bold";
        "--title-color" = "#fff";
        "--title-shadow" = "0 2px 10px rgba(255, 230, 0, 0.5)";
        "--title-letter-spacing" = "0.5px";

        "--value-size" = "3.5rem";
        "--value-weight" = "900";
        "--value-color" = "#fff";
        "--value-text-shadow" = "0 0 20px currentColor, 0 0 40px rgba(255, 230, 0, 0.3)";
        
        "--details-bg" = "rgba(0, 0, 0, 0.3)";
        "--details-border" = "4px solid var(--pond-blue)";
        "--details-text-color" = "#aaa";
        "--details-font-size" = "0.9rem";
        
        "--chart-bg" = "rgba(0, 0, 0, 0.2)";
        "--chart-radius" = "16px";
        "--chart-padding" = "15px";
        "--chart-canvas-height" = "120px";
        "--chart-scanline-bg" = "linear-gradient(90deg, var(--electric-pink), var(--pond-blue))";
        
        "--delta-bg" = "transparent";
        "--delta-color" = "inherit";
        "--delta-radius" = "20px";
        "--delta-font-size" = "0.8rem";
        "--delta-font-weight" = "bold";
      };
    };
    
    minimal = {
      name = "minimal";
      cssVars = {
        "--card-bg" = "#ffffff";
        "--card-blur" = "none";
        "--card-border" = "1px solid #e0e0e0";
        "--card-radius" = "12px";
        "--card-padding" = "20px";
        "--card-gap" = "10px";
        "--card-shadow-default" = "0 2px 8px rgba(0, 0, 0, 0.1)";
        "--card-glow-default" = "none";
        "--card-hover-transform" = "translateY(-5px)";
        "--card-hover-border-color" = "#2b6cb0";
        "--card-hover-shadow" = "0 8px 25px rgba(0, 0, 0, 0.15)";
        "--card-transition" = "all 0.3s ease";
        
        "--title-size" = "1.8rem";
        "--title-weight" = "600";
        "--title-color" = "#222";
        "--title-shadow" = "none";
        "--title-letter-spacing" = "normal";
        
        "--value-size" = "2.8rem";
        "--value-weight" = "700";
        "--value-color" = "#2d3748";
        "--value-text-shadow" = "none";
        
        "--details-bg" = "#f5f5f5";
        "--details-border" = "4px solid #2b6cb0";
        "--details-text-color" = "#555";
        "--details-font-size" = "0.9rem";
        
        "--chart-bg" = "#f5f5f5";
        "--chart-radius" = "8px";
        "--chart-padding" = "10px";
        "--chart-canvas-height" = "80px";
        "--chart-scanline-bg" = "linear-gradient(90deg, #2b6cb0, #38bdf8)";
        
        "--delta-bg" = "rgba(0, 0, 0, 0.05)";
        "--delta-color" = "#2d3748";
        "--delta-radius" = "12px";
        "--delta-font-size" = "0.75rem";
        "--delta-font-weight" = "600";
  

      };
    };
    
    dark = {
      name = "dark";
      cssVars = {
        "--card-bg" = "#1a1a1a";
        "--card-blur" = "none";
        "--card-border" = "1px solid #333333";
        "--card-radius" = "16px";
        "--card-padding" = "20px";
        "--card-gap" = "12px";
        "--card-shadow-default" = "0 4px 12px rgba(0, 0, 0, 0.5)";
        "--card-glow-default" = "none";
        "--card-hover-transform" = "translateY(-8px)";
        "--card-hover-border-color" = "#4a6fa5";
        "--card-hover-shadow" = "0 15px 40px rgba(0, 0, 0, 0.7)";
        "--card-transition" = "all 0.3s cubic-bezier(0.4, 0, 0.2, 1)";
        
        "--title-size" = "2rem";
        "--title-weight" = "600";
        "--title-color" = "#ffffff";
        "--title-shadow" = "none";
        "--title-letter-spacing" = "0.3px";
        
        "--value-size" = "3rem";
        "--value-weight" = "800";
        "--value-color" = "#ffffff";
        "--value-text-shadow" = "0 0 10px currentColor";
        
        "--details-bg" = "rgba(0, 0, 0, 0.4)";
        "--details-border" = "4px solid #4a6fa5";
        "--details-text-color" = "#b0b0b0";
        "--details-font-size" = "0.85rem";
        
        "--chart-bg" = "rgba(0, 0, 0, 0.4)";
        "--chart-radius" = "12px";
        "--chart-padding" = "12px";
        "--chart-canvas-height" = "100px";
        "--chart-scanline-bg" = "linear-gradient(90deg, #4a6fa5, #6b8cbb)";
        
        "--delta-bg" = "rgba(255, 255, 255, 0.1)";
        "--delta-color" = "#ffffff";
        "--delta-radius" = "16px";
        "--delta-font-size" = "0.75rem";
        "--delta-font-weight" = "600";
      };
    };
    
    glass = {
      name = "glass";
      cssVars = {
        "--card-bg" = "linear-gradient(135deg, rgba(255, 255, 255, 0.15), rgba(255, 255, 255, 0.05))";
        "--card-blur" = "blur(20px)";
        "--card-border" = "1px solid rgba(255, 255, 255, 0.2)";
        "--card-radius" = "20px";
        "--card-padding" = "24px";
        "--card-gap" = "16px";
        "--card-shadow-default" = "0 8px 32px rgba(0, 0, 0, 0.2)";
        "--card-glow-default" = "0 0 20px rgba(255, 255, 255, 0.1)";
        "--card-hover-transform" = "translateY(-8px)";
        "--card-hover-border-color" = "rgba(255, 255, 255, 0.4)";
        "--card-hover-shadow" = "0 20px 60px rgba(0, 0, 0, 0.3), 0 0 30px rgba(255, 255, 255, 0.1)";
        "--card-transition" = "all 0.4s ease";
        
        "--title-size" = "2.2rem";
        "--title-weight" = "bold";
        "--title-color" = "#ffffff";
        "--title-shadow" = "0 2px 8px rgba(255, 255, 255, 0.3)";
        "--title-letter-spacing" = "0.4px";
        
        "--value-size" = "3.2rem";
        "--value-weight" = "800";
        "--value-color" = "#ffffff";
        "--value-text-shadow" = "0 0 15px rgba(255, 255, 255, 0.5)";
        
        "--details-bg" = "rgba(255, 255, 255, 0.1)";
        "--details-border" = "4px solid rgba(255, 255, 255, 0.3)";
        "--details-text-color" = "rgba(255, 255, 255, 0.8)";
        "--details-font-size" = "0.9rem";
        
        "--chart-bg" = "rgba(255, 255, 255, 0.1)";
        "--chart-radius" = "14px";
        "--chart-padding" = "14px";
        "--chart-canvas-height" = "110px";
        "--chart-scanline-bg" = "linear-gradient(90deg, rgba(255, 255, 255, 0.6), rgba(255, 255, 255, 0.3))";
        
        "--delta-bg" = "rgba(255, 255, 255, 0.2)";
        "--delta-color" = "#ffffff";
        "--delta-radius" = "18px";
        "--delta-font-size" = "0.8rem";
        "--delta-font-weight" = "bold";
      };
    };
    

    colorful = {
      name = "colorful";
      cssVars = {
        "--card-bg" = "linear-gradient(135deg, ${"color"}20, transparent 80%)";
        "--card-blur" = "blur(8px)";
        "--card-border" = "3px solid ${"color"}";
        "--card-radius" = "20px";
        "--card-padding" = "22px";
        "--card-gap" = "14px";
        "--card-shadow-default" = "0 10px 30px ${"color"}30";
        "--card-glow-default" = "0 0 25px ${"color"}50";
        "--card-hover-transform" = "translateY(-10px) scale(1.02)";
        "--card-hover-border-color" = "${"color"}";
        "--card-hover-shadow" = "0 20px 50px ${"color"}40, 0 0 40px ${"color"}";
        "--card-transition" = "all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275)";
        
        "--title-size" = "2.1rem";
        "--title-weight" = "bold";
        "--title-color" = "${"color"}";
        "--title-shadow" = "0 2px 8px ${"color"}40";
        "--title-letter-spacing" = "0.3px";
        
        "--value-size" = "3.3rem";
        "--value-weight" = "900";
        "--value-color" = "${"color"}";
        "--value-text-shadow" = "0 0 20px ${"color"}50";
        
        "--details-bg" = "${"color"}10";
        "--details-border" = "4px solid ${"color"}";
        "--details-text-color" = "${"color"}";
        "--details-font-size" = "0.9rem";
        
        "--chart-bg" = "${"color"}10";
        "--chart-radius" = "14px";
        "--chart-padding" = "12px";
        "--chart-canvas-height" = "100px";
        "--chart-scanline-bg" = "linear-gradient(90deg, ${"color"}, ${"color"}60)";
        
        "--delta-bg" = "${"color"}20";
        "--delta-color" = "${"color"}";
        "--delta-radius" = "16px";
        "--delta-font-size" = "0.8rem";
        "--delta-font-weight" = "bold";
      };
    };
  };
  
  generateCardStyle = cardName: card:
    let
      themeName = card.theme or "neon";
      theme = statusCardThemes.${themeName} or statusCardThemes.neon;
      cssVarsWithColor = lib.mapAttrs (name: value:
        lib.replaceStrings ["${"color"}"] [card.color] value
      ) theme.cssVars;
      themeVars = lib.concatStringsSep " " (lib.mapAttrsToList (name: value: 
        "${name}: ${value};"
      ) cssVarsWithColor);
    in
      ''style="
        --card-color: ${card.color};
        --card-glow-color: ${card.color}40;
        ${themeVars}
      "'';
  
in {
  statusCardThemes = statusCardThemes;
  generateCardStyle = generateCardStyle;
  
}
