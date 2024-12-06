# EMPTY NIX OS MODULE
# import into flake.
{ config, pkgs, ... }:

{
   # Enable the yubikey-touch-detector service
  programs.yubikey-touch-detector.enable = true;

  # Install the yubikey-touch-detector package
  systemd.packages = [ pkgs.yubikey-touch-detector ];

  # Configure the systemd user service for yubikey-touch-detector
  systemd.user.services.yubikey-touch-detector = {
    description = "YubiKey Touch Detector";
    path = [ pkgs.gnupg ]; # Include dependencies, such as gnupg
    wantedBy = [ "graphical-session.target" ]; # Start the service when the graphical session is up
    serviceConfig = {
      ExecStart = "${pkgs.yubikey-touch-detector}/bin/yubikey-touch-detector"; # Path to the executable
      Restart = "always"; # Ensure the service restarts if it crashes
    };
  };

  # Configure the systemd user socket for yubikey-touch-detector
  systemd.user.sockets.yubikey-touch-detector = {
    description = "YubiKey Touch Detector Socket";
    wantedBy = [ "sockets.target" ]; # Start the socket when the systemd socket target is reached
  };

  # Optionally, ensure `gnupg` is installed
 # environment.systemPackages = [ pkgs.gnupg ];
}

