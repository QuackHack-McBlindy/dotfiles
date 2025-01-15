#!/bin/sh

CWD=`pwd`

set -e -x

export NIX_PATH="nixpkgs=$CWD/modules/nixpkgs"
export DEVICE="pine64-pinephone"

nix-build $CWD/modules/mobile-nixos \
  --argstr device "$DEVICE" \
  -A build.disk-image

nix-build $CWD/modules/mobile-nixos \
  --argstr device "$DEVICE" \
  -A build.boot-partition

nix-build $CWD/modules/mobile-nixos \
  --argstr device "$DEVICE" \
  -A build.u-boot
