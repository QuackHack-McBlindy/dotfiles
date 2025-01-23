{ pkgs, ... }:

{
  hardware.cpu.intel.updateMicrocode = pkgs.stdenv.isx86_64;
  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;
  services.fwupd.enable = true;
}
