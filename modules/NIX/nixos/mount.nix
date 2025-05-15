{ config, lib, pkgs, ... }:
{
  fileSystems."/Files" = {
    device = "192.168.1.159:/Files";
    fsType = "nfs";
    options = [ "nofail" "rw" "vers=4" ];
  };

  fileSystems."/Pool" = {
    device = "192.168.1.28:/Pool";
    fsType = "nfs";
    options = [ "nofail" "rw" "vers=4" ];
  };

}

  
  


