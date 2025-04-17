{ 
  config,
  lib,
  pkgs,
  ...
} : {
    config = lib.mkIf (lib.elem "fs/nixos" config.this.host.modules.hardware) {
        fileSystems."/" =
            { device = "/dev/disk/by-label/nixos";
              fsType = "ext4";
            };

        fileSystems."/boot" =
            { device = "/dev/disk/by-label/boot";
              fsType = "vfat";
              options = [ "fmask=0022" "dmask=0022" ];
            };
    
        swapDevices = [ ]; 
    
    };}
