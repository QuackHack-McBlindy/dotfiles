{ lib, ... }:
{
  disko.devices = {
    disk.disk1 = {
      device = "/dev/sda";
      type = "disk";
      content = {
        type = "gpt";  # Using GPT as the disklabel type
        partitions = {
          boot = {
            name = "boot";
            size = "512M";  # Boot partition size
            type = "8300";  # Type for Linux filesystem (MBR)
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          root = {
            name = "root";
            size = "100%";  # The remaining space
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
              mountOptions = [ "defaults" ];
            };
          };
        };
      };
    };
  };
}

