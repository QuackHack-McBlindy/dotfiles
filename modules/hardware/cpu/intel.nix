# dotfiles/modules/hardware/cpu/intel.nix
{ 
  config,
  lib,
  pkgs,
  ...
} : {
    config = lib.mkMerge [
        (lib.mkIf (lib.any (s: lib.hasPrefix "cpu/intel" s) config.this.host.modules.hardware) {
            nixpkgs.config.packageOverrides = pkgs: {
              vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
            };
            
            hardware = {
              cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
              opengl = {
                enable = true;
                extraPackages = with pkgs; [
                  intel-media-driver
                  intel-vaapi-driver # previously vaapiIntel
                  vaapiVdpau
                  libvdpau-va-gl
                  intel-compute-runtime # OpenCL filter support (hardware tonemapping and subtitle burn-in)
                  vpl-gpu-rt # QSV on 11th gen or newer
                  # intel-media-sdk # QSV up to 11th gen
                ];
            };
           
        };}) 
    ];}
