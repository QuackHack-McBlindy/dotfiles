# dotfiles/modules/programs/firejail.nix
{ config, self, lib, pkgs, ... }:
let
  cfg = config.this.host.modules.programs;
  firefoxIcon = "${self}/modules/themes/icons/firefox.png";

  jailfoxDesktopEntry = pkgs.writeText "jailfox.desktop" ''
    [Desktop Entry]
    Type=Application
    Name=Firefox (Firejail)
    Comment=Firefox running in Firejail
    Exec=jailfox %u
    Icon=${firefoxIcon}
    Terminal=false
    Categories=Network;WebBrowser;
    MimeType=text/html;text/xml;application/xhtml+xml;
  '';

  torfoxDesktopEntry = pkgs.writeText "torfox.desktop" ''
    [Desktop Entry]
    Type=Application
    Name=Firefox (Tor)
    Comment=Firefox running over Tor
    Exec=torfox %u
    Icon=${firefoxIcon}
    Terminal=false
    Categories=Network;WebBrowser;
    MimeType=text/html;text/xml;application/xhtml+xml;
  '';
in {
  config = lib.mkIf (lib.elem "firefox" cfg) {
    programs.firejail = {
      enable = true;
      wrappedBinaries = {
        jailfox = {
          executable = "${pkgs.firefox-esr}/bin/firefox-esr";
          profile = "${pkgs.firejail}/etc/firejail/firefox.profile";
          desktop = jailfoxDesktopEntry;
          extraArgs = [
            "--ignore=private-dev"
            "--env=GTK_THEME=Adwaita:dark"
            "--dbus-user.talk=org.freedesktop.Notifications"
          ];
        };
        
        
        torfox = {
          executable = "${pkgs.firefox-esr}/bin/firefox-esr";
          profile = "${pkgs.firejail}/etc/firejail/firefox.profile";
          desktop = torfoxDesktopEntry;
          extraArgs = [
            "--ignore=private-dev"
            "--env=GTK_THEME=Adwaita:dark"
            "--dbus-user.talk=org.freedesktop.Notifications"
            "--net=tornet"
            "--dns=10.100.100.1"
          ];
        };
      };
    };

  };}
