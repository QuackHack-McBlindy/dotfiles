
{
  environment.systemPackages = with pkgs; [
    mergerfs
  ];
  fileSystems."/storage" = {
    fsType = "fuse.mergerfs";
    device = "/mnt/disks/*";
    options = ["cache.files=partial" "dropcacheonclose=true" "category.create=mfs"];
  };
}
