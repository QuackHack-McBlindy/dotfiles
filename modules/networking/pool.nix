# dotfiles/modules/networking/pool.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{  # 🦆 says ⮞ NFS mount /mnt/Pool
  config,# 🦆 BIND /mnt/Pool ⮞ /Pool 
  lib,
  pkgs,
  ...
} : {
    config = lib.mkIf (lib.elem "pool" config.this.host.modules.networking) {
      fileSystems = lib.mkIf (!config.this.installer) {
        "/mnt/Pool" = {
          device = "192.168.1.28:/";
          fsType = "nfs4";
          options = [
            "_netdev"
            "nofail"
            "x-systemd.automount"
            "x-systemd.requires=network-online.target"
            "x-systemd.after=network-online.target"
          ];
        };

        "/Pool" = {
          device = "/mnt/Pool";
          fsType = "none";
          options = [ "bind" ];
        };
      };
      
    };}
