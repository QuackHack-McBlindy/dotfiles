{
  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/nvme0n1"; # Matches your actual disk
      content = {
        type = "gpt";
        partitions = {
          boot = {
            size = "512M";
            type = "EF00";
            label = "boot";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };

          swap = {
            size = "8G"; # Matches your current SWAP size
            label = "swap";
            content = {
              type = "swap";
            };
          };

          root = {
            size = "100%";
            label = "nixos";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
        };
      };
    };
  };
}
