{ config, lib, pkgs, ... }:

{
  documentation.nixos.enable = false;

  nixpkgs.config.allowUnfree = true;

  nix = {
	settings = {
		warn-dirty = false;
		experimental-features = [ "nix-command" "flakes" ];
		auto-optimise-store = true;
		#sandbox = true;
                log-lines = 15;
                min-free = 1073741824; # 1GiB
                max-free = 8589934592; # 8GiB
                builders-use-substitutes = true;
                trusted-users = [
                    "root"
                    "pungkula"
                ];
	};
	
	gc = {
		automatic = true;
		dates = "weekly";
		options = "--delete-older-than 7d";
	};
  };
}
