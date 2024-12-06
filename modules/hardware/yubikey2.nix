{
  pkgs,
  lib,
  inputs,
  ...
}:

let
  mapping = "pungkula:MCwx6UCRxJ3mu61qV3cUy+px4qZWjZJGFQDmcvWjsrFepekij5q3DvWDvSJXI6FRj1ovN4GBK4fXz52DX58A8A==,mLzwjkMatOBemg/u/sKW6kQUHfknNpo+8XoQVJHvSS6ZAPxBKURWuEFNXkdAqp+CIbTddqBCbC+WBD3mb5fejQ==,es256,+presence";

  ykDisconnect = pkgs.writeShellScript "yk-disconnect.sh" ''
    ${pkgs.procps}/bin/pkill -USR1 swayidle
  '';
in
{
  config = {
    security.pam = {
      u2f = {
        enable = true;
      };
    };
    
    services.udev.extraRules = ''
      ACTION=="remove", SUBSYSTEM=="usb", ENV{PRODUCT}=="1050/406/543", RUN+="${ykDisconnect} '%E{SEQNUM}'"
    '';

    home-manager.users.cole =
      { pkgs, ... }:
      {
        xdg.configFile."Yubico/u2f_keys".text = mapping;
      };
  };
}
