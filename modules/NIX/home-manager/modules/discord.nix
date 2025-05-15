{
  inputs,
  config,
  ...
}: {
  imports = [inputs.nixcord.homeManagerModules.nixcord];

  programs.nixcord = {
    enable = true;
    discord.enable = false;
    vesktop.enable = true;
    quickCss = 
    config = {
      useQuickCss = true;
      themeLinks = ["https://refact0r.github.io/system24/theme/system24.theme.css"];
      frameless = true;
    };
    vesktopConfig.quickCss = "";
    vesktopConfig.plugins = {
      hideAttachments.enable = true;
      betterSettings.enable = true;
      fakeNitro.enable = true;
      fixImagesQuality.enable = true;
      fullSearchContext.enable = true;
      messageLinkEmbeds.enable = true;
      messageLogger.enable = true;
    };
    extraConfig = {};
  };
}
