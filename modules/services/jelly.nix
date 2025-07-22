{ 
  config, 
  lib, 
  pkgs, 
  ... 
} : let
  customPkgs = import pkgs.path {
    inherit (pkgs) system config;
    overlays = [
      (self: super: {
        jellyfin-web = super.jellyfin-web.overrideAttrs (oldAttrs: {
          postInstall = ''
            ${oldAttrs.postInstall or ""}
            cp ${./../themes/images/banner-dark.png} $out/share/jellyfin-web/assets/img/banner-dark.png
          '';
        });
      })
    ];
  };
in {
  environment.systemPackages = lib.mkIf (lib.elem "jelly" config.this.host.modules.services) [
    pkgs.jellyfin
    customPkgs.jellyfin-web
  ];

  services.jellyfin = lib.mkIf (lib.elem "jelly" config.this.host.modules.services) {
    enable = true;
    dataDir = "/var/lib/jellyfin";
    package = pkgs.jellyfin;
    openFirewall = true;
  };}
