{
  fileSystems."Pool" = {
    device = "smb://192.168.1.28/Pool";
    fsType = "cifs";
  #  mountPoint = "/Pool";
    options = [
      "rw"                   # Read-write mount
      "uid=1000"                 # Set user ID
      "gid=1000"                 # Set group ID
      "iocharset=utf8"           # Use UTF-8 encoding
      "file_mode=0777"           # Set file permissions
      "dir_mode=0777"            # Set directory permissions
      "vers=3.0"                 # Use SMB version 3.0
      "credentials=/var/lib/sops-nix/smb.txt"
      "sec=ntlmv2"               # Use NTLMv2 authentication
      "retry=5"                  # Retry 5 times before failing
      "x-systemd.automount"
      "x-systemd.requires=network-online.target"
      "x-systemd.idle-timeout=600"
    ];
  };
}
