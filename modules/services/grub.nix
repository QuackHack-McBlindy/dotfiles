{ config, lib, ... }:

{
  # Use the GRUB 2 boot loader
  boot.loader.grub.enable = lib.mkDefault true;
  boot.loader.timeout = 2;
}

