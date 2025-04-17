{
  disko.devices = {
    disk = {
      # Main system disk
      sda = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            # Boot partition
            boot = {
              size = "1M";
              type = "EF02"; # BIOS boot partition
            };
            # Root partition
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };

      media1 = {
        type = "disk";
        device = "/dev/disk/by-label/media1";
        content = {
          type = "filesystem";
          format = "ext4";
          mountpoint = "/mnt/disks/media1";
        };
      };

      media2 = {
        type = "disk";
        device = "/dev/disk/by-label/media2";
        content = {
          type = "filesystem";
          format = "ext4";
          mountpoint = "/mnt/disks/media2";
        };
      };

      media3 = {
        type = "disk";
        device = "/dev/disk/by-label/media3";
        content = {
          type = "filesystem";
          format = "ext4";
          mountpoint = "/mnt/disks/media3";
        };
      };

      media4 = {
        type = "disk";
        device = "/dev/disk/by-label/media4";
        content = {
          type = "filesystem";
          format = "ext4";
          mountpoint = "/mnt/disks/media4";
        };
      };

      media5 = {
        type = "disk";
        device = "/dev/disk/by-label/media5";
        content = {
          type = "filesystem";
          format = "ext4";
          mountpoint = "/mnt/disks/media5";
        };
      };

      # Backup disk
      backup = {
        type = "disk";
        device = "/dev/disk/by-label/backup";
        content = {
          type = "filesystem";
          format = "ext4";
          mountpoint = "/mnt/backup";
        };
      };
    };

    # MergerFS pool configuration
    nodev = {
      Pool = {
        type = "filesystem";
        fsType = "fuse.mergerfs";
        mountpoint = "/mnt/Pool";
        options = [
          "defaults"
          "minfreespace=250G"
          "fsname=mergerfs-Pool"
          "allow_other"
        ];
        devices = [ "/mnt/disks/media1" "/mnt/disks/media2" "/mnt/disks/media3" "/mnt/disks/media4" "/mnt/disks/media5" ];
      };
    };

    # Bind mounts
    bind = {
      "/Pool" = {
        mountpoint = "/Pool";
        device = "/mnt/Pool";
        options = [ "bind" ];
      };
      "/backup" = {
        mountpoint = "/backup";
        device = "/mnt/backup";
        options = [ "bind" ];
      };
    };
  };
}
