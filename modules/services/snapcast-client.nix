{ config, pkgs,  ... }:
let
  pkgs = import <nixpkgs> {};
in
{
  systemd.user.services.snapclient-local = {
    wantedBy = [
      "pipewire.service"
    ];
    after = [
      "pipewire.service"
    ];
    serviceConfig = {
      ExecStart = "${pkgs.snapcast}/bin/snapclient -h ::1";
    };
  };
}
