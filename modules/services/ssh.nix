{ config, pkgs, lib, ... }:
let
  pubkey = import ./../sshd/pubkey.nix;
in
{
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    openFirewall = true;   
    knownHosts = {
        desktop = {
            publicKeyFile = ./../../hosts/desktop/pub.pub;
        };
        laptop = {
            publicKeyFile = ./../../hosts/laptop/pubkey.pub;
        };   
        nasty = {
            publicKeyFile = ./../../hosts/nasty/pubkey.pub;
        };
     #   homie = {
     #       publicKeyFile = ./../../hosts/homie/pubkey.pub;
     #   };
    };

    settings = {
      PasswordAuthentication = lib.mkDefault true;
      LogLevel = "VERBOSE";
  #    AllowUsers = [ "pungkula ];
      PermitRootLogin = "no";  # Disallow root login
      MaxAuthTries = "3";  # Max authentication attempts
      # UsePAM = "yes";  # Enable PAM (Pluggable Authentication Modules)
      AllowUsers = [ "pungkula" ];  # Restrict SSH logins to these users
      # AllowGroups = "sshusers";  # Restrict SSH logins to these groups
      # HostKey = "/etc/ssh/ssh_host_rsa_key";  # Path to the SSH host key

      # Other security settings
      #DisableForwarding = false;  # Allow port forwarding
      PermitEmptyPasswords = false;  # Disallow empty passwords
      #ClientAliveInterval = 60;  # Server sends keep-alive messages every 60 seconds
      #ClientAliveCountMax = 3;  # Disconnect clients after 3 missed keep-alives
      # Logging and verbose output
      #LogLevel = "VERBOSE";  # Detailed logging (useful for debugging)
      # Specify which algorithms to use (advanced use case)
      # Ciphers = "aes128-ctr,aes192-ctr,aes256-ctr";
      # MACs = "hmac-sha2-256,hmac-sha2-512";
      # KexAlgorithms = "curve25519-sha256@libssh.org,diffie-hellman-group14-sha1";
      # Configure X11 forwarding (useful for graphical applications)
      #   X11Forwarding = "yes";
      #   X11DisplayOffset = "10";
      # Disable DNS lookup for performance reasons (can be useful in some environments)
      #  UseDNS = "no";
  
    };
  };
  users.extraUsers.root.openssh.authorizedKeys.keys = lib.mkDefault [ pubkey.pungkula ];
}



        


