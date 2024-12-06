{ config, pkgs, ... }:

{
  #imports = [ ./path-to-sshd-module.nix ];

  services.openssh = {
    enable = true;
   # ports = [ 22 ];
    openFirewall = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "yes";
    #  LogLevel = "VERBOSE";
  #    AllowUsers = [ "pungkula ];
    };
  };
}

