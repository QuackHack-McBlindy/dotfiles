# dotfiles/modules/hardware/gpu/amd.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ 
  config,
  lib,
  pkgs,
  ...
} : let
  rocmPkgs = pkgs.rocmPackages_5;
in {
    config = lib.mkIf (lib.elem "gpu/amd" config.this.host.modules.hardware) {
        hardware.amdgpu = {
            opencl.enable = true;
            amdvlk = {
                enable = true;
                settings = {
                    # 🦆 duck say ⮞ enable pipeline caching
                    AllowVkPipelineCachingToDisk = 1;
                    # 🦆 duck say ⮞ better memory management
                    EnableVmAlwaysValid = 1;
                    # 🦆 duck say ⮞ disable image view feedback
                    IFH = 0;
                    # 🦆 duck say ⮞ enable shader cache
                    ShaderCacheMode = 1;
                    # 🦆 duck say ⮞ set cache size limit (MB)
                    ShaderCacheMaxSize = 512;
                };
            };
        
        };
    };}
