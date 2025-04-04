{ config, lib, pkgs, ... }:
let
  
  pubkey = import ./../../hosts/pubkeys.nix;
in {
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ NIX ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#  imports = [ ./command-not-found.nix ];
  documentation.nixos.enable = false;
  nixpkgs.config.allowUnfree = true;
  system.tools.nixos-option.enable = true;
  nix = {
    distributedBuilds = true;
     
    buildMachines = [{
      protocol = "ssh";
      hostName = "desktop";
      sshUser = "builder";
      sshKey = "/root/.ssh/id_desktop_builder";
      #publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUxkd1BrUlF4bGJyYlJHd0VPNXpNSjRtKzdRcVVRUFpnMWlxYmQ1SFJQMzQgcm9vdEBuaXhvcwo=";
      publicHostKey = pubkey.host.desktop;
      system = "x86_64-linux";
      maxJobs = 64;
      speedFactor = 5;
      supportedFeatures = [ "kvm" "big-parallel" ];
      mandatoryFeatures = [ "big-parallel" ];
    }];
 
	settings = {
	    # direnv
	    keep-outputs = true;
        keep-derivations = true;
        
	    warn-dirty = false;
		experimental-features = [ "nix-command" "flakes" ];
		auto-optimise-store = true;
		sandbox = true;
        log-lines = 15;
        min-free = 1073741824; # 1GB
        max-free = 8589934592; # 8GB
        
        builders-use-substitutes = true;
        allowed-users = [
          "@wheel"
          "builder"
          "pungkula"
        ];  
        trusted-users = [
          "root"
          "pungkula"
          "builder"
        ];
        trusted-public-keys = [ pubkey.cache ];
        substituters = [
            "http://cache/"
            "https://cache.nixos.org/"
        ];
	};
	
	extraOptions = ''
	    download-buffer-size = 1048576
	    connect-timeout = 15
	'';
	
	gc = {
		automatic = true;
		dates = "weekly";
		options = "--delete-older-than 7d";
	};
  };

}
