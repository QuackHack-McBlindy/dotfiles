{ config, lib, pkgs, ... }:
{
  fileSystems."/Files" = {
    device = "192.168.1.159:/Files";
    fsType = "nfs";
    options = [ "nofail" "rw" "vers=4" ];
  };


  services.nfs.server.enable = false;
  # nix-shell -p nfs-utils 'mount.nfs 129.215.90.50:/home /home -o nolock'
  services.nfs.server.exports = ''
    /Pool ${
      lib.concatMapStringsSep " " (
        host: ''${host}(rw,nohide,insecure,no_subtree_check,no_root_squash)''
      ) [ "192.168.1.28" ]
    }
  '';
}

  
  


