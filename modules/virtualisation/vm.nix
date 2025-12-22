# dotfiles/modules/virtualisation/vm.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 say ⮞ non existing machines
  config,
  lib,
  pkgs,
  ...
} : let 
  user = config.this.user.me.name;
in {
    config = lib.mkIf (lib.elem "vm" config.this.host.modules.virtualisation) {
        users.users.${user}.extraGroups = [ "libvirtd" ];

        environment.systemPackages = with pkgs; [
            virt-manager
            virt-viewer
            spice spice-gtk
            spice-protocol
            virtio-win
            win-spice
            virtualbox
            adwaita-icon-theme
            #bridge-utils
        ];

        virtualisation = {
            libvirtd = {
                enable = true;
                qemu = {
                    swtpm.enable = true;
                    #ovmf.enable = true;
                    #ovmf.packages = [ pkgs.OVMFFull.fd ];
                };
            };
            spiceUSBRedirection.enable = true;
        };
        services.spice-vdagentd.enable = true;
        
    };}
