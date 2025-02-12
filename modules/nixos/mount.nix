#{
 # fileSystems."Pool" = {
#    device = "smb://192.168.1.28/Pool";
#    fsType = "cifs";
  #  mountPoint = "/Pool";
#    options = [
#      "rw"                   # Read-write mount
 #     "uid=1000"                 # Set user ID
 #     "gid=1000"                 # Set group ID
  #    "iocharset=utf8"           # Use UTF-8 encoding
 #     "file_mode=0777"           # Set file permissions
 #     "dir_mode=0777"            # Set directory permissions
  #    "vers=3.0"                 # Use SMB version 3.0
 #     "credentials=/var/lib/sops-nix/smb.txt"
  #    "sec=ntlmv2"               # Use NTLMv2 authentication
  #    "retry=5"                  # Retry 5 times before failing
  #    "x-systemd.automount"
 #     "x-systemd.requires=network-online.target"
 #    "x-systemd.idle-timeout=600"
#    ];
 # };
#}

#let
#  cfg = {
#    options = {
 #     username = "duck";
 #     password = config.sops.secrets.pool.path;
 #   };
#  };  
#in
{ config, lib, pkgs, ... }:
{
  fileSystems."/Files" = {
    device = "192.168.1.159:/Files";
    fsType = "nfs";
    options = [ "rw" "vers=4" ];
  };

#  fileSystems."/Pool" = {
#    device = "192.168.1.28:/Pool";
 #   fsType = "nfs";
#    options = [ "rw" "vers=4" ];
#  };

  # For mount.cifs, required unless domain name resolution is not needed.
#  environment.systemPackages = [ pkgs.cifs-utils ];
#  fileSystems."/Pool" = {
#    device = "//192.168.1.28/pool";
#    fsType = "cifs";
#    options = let
      # this line prevents hanging on network split
#      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

#    in ["${automount_opts},credentials=/etc/nixos/smb-secrets"];
#  };
  
#  sops.secrets = {
#    pool = {
 #     sopsFile = "/var/lib/sops-nix/secrets/pool.yaml";
#      owner = config.users.users.secretservice.name;
#      group = config.users.groups.secretservice.name;
 #     mode = "0440"; # Read-only for owner and group
 #   };
  #}; 
}

  
  


