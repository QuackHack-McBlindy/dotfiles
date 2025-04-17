# dotfiles/modules/hardware/cpu/intel.nix
{ 
  config,
  lib,
  pkgs,
  ...
} : {
    config = lib.mkMerge [
        # General Intel CPU settings
        (lib.mkIf (lib.any (s: lib.hasPrefix "cpu/intel" s) config.this.host.modules.hardware) {
            hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
           # services.thermald.enable = true;
           # powerManagement = {
           #     enable = true;
           #     cpuFreqGovernor = lib.mkDefault "ondemand";
           #     powertop.enable = true;
           # };
        })

        
    ];}
