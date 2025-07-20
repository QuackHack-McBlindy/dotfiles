# dotfiles/modules/hardware/cpu/intel.nix
{ 
  config,
  lib,
  pkgs,
  ...
} : {
    config = lib.mkMerge [
        (lib.mkIf (lib.any (s: lib.hasPrefix "cpu/intel" s) config.this.host.modules.hardware) {
            hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
        })

        
    ];}
