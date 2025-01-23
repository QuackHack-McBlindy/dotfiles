{ ... }:

{
  boot.tmp.cleanOnBoot = true;

  nix = {
    optimise.automatic = true;
    gc.automatic = true;
  };

  services.journald.extraConfig = ''
    SystemMaxUse=250M
    SystemMaxFileSize=50M
  '';
}
