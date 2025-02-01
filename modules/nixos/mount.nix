{
  fileSystems."/Poool" = {
    device = "//192.168.1.28/Pool";
    fsType = "cifs";
    options = [
      "rw"         # Read/write access
      "username=duck"
      "password=config.sops.secrets.smb.path"
      "iocharset=utf8"
      "file_mode=0777"
      "dir_mode=0777"
      "uid=1000"   # Replace with your user ID
      "gid=1000"   # Replace with your group ID
      "x-systemd.automount"
      "x-systemd.requires=network-online.target"
      "x-systemd.idle-timeout=600"
    ];
  };
}
