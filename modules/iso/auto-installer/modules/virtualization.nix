{ pkgs, ... }:
{
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  boot.extraModprobeConfig = "options kvm-intel nested=Y";

  environment.systemPackages = with pkgs; [
    libvirt
    virt-manager
    gnome.gnome-boxes
  ];

  virtualisation.libvirtd.enable = true;
  #virtualisation.docker.enable = true;
}
