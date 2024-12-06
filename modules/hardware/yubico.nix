{ config, inputs, pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; [
    yubioath-flutter
    yubikey-manager-qt
    yubikey-touch-detector
    yubikey-personalization-gui
    yubikey-manager
    pam_u2f
    yubikey-personalization
    libu2f-host
    yubico-pam
  ];
  
  security.pam.services = {
    login.u2fAuth = true;
    sudo.u2fAuth = true;
  };

  security.pam.yubico = {
     enable = true;
     debug = true;
     mode = "challenge-response";
     
     id = [ "16644366" ];
  };
  
  services.udev.extraRules = ''
      ACTION=="remove",\
       ENV{ID_BUS}=="usb",\
       ENV{ID_MODEL_ID}=="0407",\
       ENV{ID_VENDOR_ID}=="1050",\
       ENV{ID_VENDOR}=="Yubico",\
       RUN+="${pkgs.systemd}/bin/loginctl lock-sessions"
  '';
}
