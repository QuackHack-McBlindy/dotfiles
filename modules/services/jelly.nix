{ 
  config, 
  lib, 
  pkgs, 
  ... 
} : let
  customLogo = ./../themes/images/banner-dark.png;
  customBg = ./../themes/images/banner-dark.png;

in {
  nixpkgs.overlays = [
    (final: prev: {
      jellyfin-web = prev.jellyfin-web.overrideAttrs (oldAttrs: {
        installPhase = oldAttrs.installPhase + ''
          cp ${customLogo} $out/share/jellyfin-web/assets/img/banner-light.png
          cp ${customBg} $out/share/jellyfin-web/assets/img/banner-dark.png
        '';
      });
      
      jellyfin = prev.jellyfin.override {
        jellyfin-web = final.jellyfin-web;
      };
    })
  ];

  environment.systemPackages = lib.mkIf (lib.elem "jelly" config.this.host.modules.services) [
    pkgs.jellyfin
    pkgs.jellyfin-web
  ];

  services.jellyfin = lib.mkIf (lib.elem "jelly" config.this.host.modules.services) {
    enable = true;
    dataDir = "/var/lib/jellyfin2";
#    package = duckTV;
    openFirewall = true;
  };}
