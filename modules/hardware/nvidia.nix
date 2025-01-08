{ config, pkgs, lib, inputs, user, ... }:
{

#Nvidia
  #Allow unfree packages
  nixpkgs.config.allowUnfree = true;


  services.xserver = {
    videoDrivers = [ "nvidia" ];
   #  config = ''
   #    Section "Device"
   #        Identifier  "Intel Graphics"
   #        Driver      "intel"
   #       #Option      "AccelMethod"  "sna" # default
   #       #Option      "AccelMethod"  "uxa" # fallback
   #        Option      "TearFree"        "true"
   #        Option      "SwapbuffersWait" "true"
   #        BusID       "PCI:0:2:0"
   #       #Option      "DRI" "2"             # DRI3 is now default
   #    EndSection
   #
   #    Section "Device"
   #        Identifier "nvidia"
   #        Driver "nvidia"
   #        BusID "PCI:1:0:0"
   #        Option "AllowEmptyInitialConfiguration"
   #        Option         "TearFree" "true"
   #    EndSection
   #  '';
   # screenSection = ''
   #   Option         "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
   #   Option         "AllowIndirectGLXProtocol" "off"
   #   Option         "TripleBuffer" "on"
   #   '';
   #  deviceSection = '' 
   #  Option "TearFree" "true"
   # '';
  };

#boot.kernelParams = [ "nvidia.NVreg_PreserveVideoMemoryAllocations=1" ];


  hardware = {
   graphics.enable = true;
  # opengl.driSupport = true;
   graphics.enable32Bit = true;
     graphics = {
        extraPackages = with pkgs; [
          intel-media-driver # LIBVA_DRIVER_NAME=iHD
  #        intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
  #        libvdpau-va-gl
  #        vaapiVdpau
  #        #mesa.drivers
        ];
     };
  
  nvidia.nvidiaSettings = true;
  nvidia.powerManagement.enable = true;
  nvidia.powerManagement.finegrained = true;
  
  #nvidia.forceFullCompositionPipeline = true;
  # nvidia-drm.modeset=1 is required for some wayland compositors, e.g. sway
  nvidia.modesetting.enable = true;
  #nvidia.nvidiaPersistenced = true;

  #nvidia.open = true;
  # Optionally, you may need to select the appropriate driver version for your specific GPU.
  nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;

  #offload , Sync or reverseSync
    nvidia.prime = {
    #reSync Mode
    # reverseSync.enable = true;
    #Sync Mode
    # sync.enable = true;
    #Offload Mode
      offload = {
      enable = true;
      enableOffloadCmd = true;
     };

    # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
    nvidiaBusId = "PCI:1:0:0";

    # Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA
    intelBusId = "PCI:0:2:0";
  };

  };

  
    
    #Testing stuff
   # nixpkgs.config.packageOverrides = pkgs: {
   #   vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
   # };  

  # Cuda?
  #services.xmr-stak.cudaSupport = true; 

  #Switch GPU
  #services.switcherooControl.enable = true;

  # Nvidia in Docker
    virtualisation.docker = {
     enable = true;
     enableOnBoot= true;
     enableNvidia = true;
    }; 


   #virtualisation.containers.cdi.dynamic.nvidia.enable = true;
   hardware.nvidia-container-toolkit.enable = true;
   #systemd.enableUnifiedCgroupHierarchy = false;

#services.ollama = {
#  enable = true;
#  acceleration = "cuda";
#};
}
