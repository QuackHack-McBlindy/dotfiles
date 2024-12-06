{ config, pkgs, ... }:

{
  nix = {
    settings = {
      sandbox = true;
      experimental-features = "nix-command flakes";
      log-lines = 15;
      min-free = 1073741824; # 1GiB
      max-free = 8589934592; # 8GiB
      builders-use-substitutes = true;
      trusted-users = [
        "root"
        "davidak"
      ];
    };
  };
}

