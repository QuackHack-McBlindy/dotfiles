{ config, lib, pkgs, ... }:
{
  fileSystems."/Files" = {
    device = "192.168.1.159:/Files";
    fsType = "nfs";
    options = [ "rw" "vers=4" ];
  };

}

  
  


