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
       #     initrd.enable = true;
            opencl.enable = true;
            amdvlk = {
                enable = true;
                settings = {
                    # Enable pipeline caching
                    AllowVkPipelineCachingToDisk = 1;
                    # Better memory management
                    EnableVmAlwaysValid = 1;
                    # Disable image view feedback
                    IFH = 0;
                    # Enable shader cache
                    ShaderCacheMode = 1;
                    # Set cache size limit (MB)
                    ShaderCacheMaxSize = 512;
                };
            };
        
        };
 #       boot.initrd.kernelModules = [ "amdgpu" ];
 #       services.xserver.videoDrivers = [ "amdgpu" ];
  #      services.ollama.acceleration = "rocm";
     #   hardware.graphics = {
     #       enable = true;        # Essential graphics stack
   #         enable32Bit = true;   # Required for 32-bit compatibility
    #        extraPackages = with rocmPkgs; [
          #      rocm-opencl-icd    # OpenCL support
     #           rocm-runtime       # Core ROCm components
             #   amdvlk             # Vulkan driver
     #           rocblas            # BLAS support
     #       ];
    #        extraPackages32 = with pkgs.pkgsi686Linux; [
    #            amdvlk             # 32-bit Vulkan
   #             mesa.drivers       # Fallback Mesa drivers
  #          ];
 #       };

        # Verified kernel requirements for RDNA2
      #  boot.kernelParams = [
      #      "amdgpu.ppfeaturemask=0xfff7ffff"  # Official recommended value
      #      "amdgpu.sg_display=0"              # Disable experimental feature
      #  ];

        # ROCm environment (validated against NixOS 24.05 docs)
#        environment.systemPackages = with rocmPkgs; [
   #         rocm-smi
  #          rocminfo
 #           hipcc
  #      ];

        # Mandatory security rules
       # security.wrappers = {
       #     kfd = {
       #         source = "${rocmPkgs.rocm-runtime}/bin/kfd";
       #         owner = "root";
       #         group = "video";
       #         permissions = "u+rx,g+rx,o-rwx";
       #     };
       # };    
    };}
