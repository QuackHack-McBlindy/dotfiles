# nix-build '<nixpkgs/nixos>' -A config.system.build.sdImage -I nixos-config=./rpi4-image.nix
{ ... }:
let
  import pubkeys = ./../../hosts/pubkeys.nix
in
{
  nixpkgs.localSystem.system = "aarch64-linux";
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/sd-image-raspberrypi4.nix>
  ];

  # maurice
  users.users.root.openssh.authorizedKeys.keys = [
    pubkeys.desktop
    pubkeys.laptop
  ];
}
