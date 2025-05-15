{ lib, disks, ... }: {

  # Disko configuration (should match your original partitioning scheme)
  disko.devices = {
    disk.main = {
      device = lib.mkDefault "/dev/disk/by-id/placeholder";  # Overridden by CLI
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
        
          boot = {
            name = "BOOT";
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          
          swap = {
            name = "SWAP";
            size = "8G";
            type = "8200";
            content = {
              type = "swap";
            };
          };
          
          root = {
            name = "NIXOS";
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
          
          persist = {
            name = "PERSIST";
            size = "1G";  
            type = "8300";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/persist";
            };
          };
          
        };
      };
    };
  };
}  
