{ 
  config,
  lib,
  pkgs,
  ...
} : let 
  user = config.this.user.me.name;
in {
    config = lib.mkIf (lib.elem "vm" config.this.host.modules.virtualisation) {
        # Enable dconf (System Management Tool) enabled in users.nix
        #programs.dconf.enable = true;
        # Add user to libvirtd group
        users.users.${user}.extraGroups = [ "libvirtd" ];

        # Install necessary packages
        environment.systemPackages = with pkgs; [
            virt-manager
            virt-viewer
            spice spice-gtk
            spice-protocol
            win-virtio
            win-spice
            virtualbox
            adwaita-icon-theme
            #bridge-utils
        ];

        # Manage the virtualisation services
        virtualisation = {
            libvirtd = {
                enable = true;
                qemu = {
                    swtpm.enable = true;
                    ovmf.enable = true;
                    ovmf.packages = [ pkgs.OVMFFull.fd ];
                };
            };
            spiceUSBRedirection.enable = true;
        };
        services.spice-vdagentd.enable = true;
        
    };}
