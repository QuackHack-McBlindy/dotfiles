{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:


let
  mediaDisks = [
    "/mnt/disks/media1"
    "/mnt/disks/media2"
    "/mnt/disks/media3"
    "/mnt/disks/media4"
    "/mnt/disks/media5"
  ];

in

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];


  fileSystems."/" =
    { device = "/dev/disk/by-uuid/005e77e7-16cb-40de-9076-2123feb2ed67";
      fsType = "ext4";
    };
                                                                                      
  swapDevices = [ ];
                                                                                   ########################
  
  fileSystems."/mnt/disks/media1" = {
    device = "/dev/disk/by-label/media1";
    fsType = "ext4";
    options = [ "defaults" "users" "x-gvfs-show" ];
  };

  fileSystems."/mnt/disks/media2" = {
    device = "/dev/disk/by-label/media2";
    fsType = "ext4";
    options = [ "defaults" "users" "x-gvfs-show" ];         
  };

  fileSystems."/mnt/disks/media3" = {
    device = "/dev/disk/by-label/media3";
    fsType = "ext4";
    options = [ "defaults" "users" "x-gvfs-show" ];
  };

  fileSystems."/mnt/disks/media4" = {
    device = "/dev/disk/by-label/media4";
    fsType = "ext4";
    options = [ "defaults" "users" "x-gvfs-show" ];
  };

  fileSystems."/mnt/disks/media5" = {
    device = "/dev/disk/by-label/media5";
    fsType = "ext4";
    options = [ "defaults" "users" "x-gvfs-show" ];
  };


  environment.systemPackages = [ pkgs.mergerfs ];

  fileSystems."/mnt/Pool" = {
    depends = mediaDisks;
    device = builtins.concatStringsSep ":" mediaDisks;
    fsType = "mergerfs";
    options = ["defaults" "minfreespace=250G" "fsname=mergerfs-Pool"];
  };
   
  fileSystems."/Pool" = {
    device = "/mnt/Pool";
    options = [ "bind" ];
  };
   
  fileSystems."/mnt/backup" = {
    device = "/dev/disk/by-label/backup";
    fsType = "ext4";
    options = [ "defaults" "users" "x-gvfs-show" ];
  };

  fileSystems."/backup" = {
    device = "/mnt/backup";
    options = [ "bind" ];
  };
   
#  fileSystems."/mnt/disks/parity01" =


  networking.useDHCP = lib.mkDefault true;
#  networking.interfaces.enp3s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
