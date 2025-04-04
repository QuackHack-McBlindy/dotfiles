_:

{
  nix.settings.trusted-users = [ "@wheel" ];
  services.openssh.enable = true;
  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;
}
