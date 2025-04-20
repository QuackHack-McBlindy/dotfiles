{
  self,
  inputs,
  pkgs,
  config,
  lib,
  ...
}: {
  boot = {
   # tmp.useTmpfs = lib.mkDefault true;
   # tmp.cleanOnBoot = lib.mkDefault (!config.boot.tmp.useTmpfs);

    # Disable kernel-param editing on boot
    loader.systemd-boot.editor = false;

    kernel.sysctl = {
      # Magic SysRq key -> allows performing low-level commands.
      "kernel.sysrq" = 0;

      ## TCP hardening
      # Prevent bogus ICMP errors from filling up logs.
     # "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
      # Reverse path filtering causes the kernel to do source validation of
      # packets received from all interfaces. This can mitigate IP spoofing.
      "net.ipv4.conf.default.rp_filter" = 1;
      "net.ipv4.conf.all.rp_filter" = 1;
      # Do not accept IP source route packets (we're not a router)
      "net.ipv4.conf.all.accept_source_route" = 0;
      "net.ipv6.conf.all.accept_source_route" = 0;
      # Don't send ICMP redirects (again, we're on a router)
      #"net.ipv4.conf.all.send_redirects" = 0;
      "net.ipv4.conf.default.send_redirects" = 0;
      # Refuse ICMP redirects (MITM mitigations)
      #"net.ipv4.conf.all.accept_redirects" = 0;
      "net.ipv4.conf.default.accept_redirects" = 0;
      "net.ipv4.conf.all.secure_redirects" = 0;
      "net.ipv4.conf.default.secure_redirects" = 0;
      "net.ipv6.conf.all.accept_redirects" = 0;
      "net.ipv6.conf.default.accept_redirects" = 0;
      # Protects against SYN flood attacks
      "net.ipv4.tcp_syncookies" = 1;
      # Incomplete protection again TIME-WAIT assassination
      "net.ipv4.tcp_rfc1337" = 1;

      ## TCP optimization
      # Enable TCP Fast Open for incoming and outgoing connections
      "net.ipv4.tcp_fastopen" = 0; # 3
      # Bufferbloat mitigations + slight improvement in throughput & latency
   #   "net.ipv4.tcp_congestion_control" = "bbr";
   #   "net.core.default_qdisc" = "cake";
    };
    kernelModules = ["tcp_bbr"];
  };

  networking.firewall.logRefusedConnections = true;
  users.users.root.initialPassword = "nixos";

  security = {
    # Prevent replacing the running kernel w/o reboot
    protectKernelImage = true;
    # So we don't have to do this later...
    acme.acceptTerms = true;
    # Allows unautherized applications -> send unautherization request
   # polkit.enable = true;
  };
  
  
  services.gnome.gnome-keyring.enable = true;
  services.gvfs.enable = true; 

  sops = {
    defaultSopsFile = ./../.sops.yaml;
    defaultSopsFormat = "yaml";
    validateSopsFiles = false;
    age.keyFile = "/var/lib/sops-nix/age.age";
    age.generateKey = true;
  #  secrets = {
  #    secretservice = {
  #      sopsFile = ./../secrets/secretservice.yaml;
  #      owner = config.this.user.me.name;
  #      group = config.this.user.me.name;
  #      mode = "0440"; # Read-only for owner and group
  #    };
   # };
  };  
 # systemd.services.secretservice = {
 #   script = ''
 #       echo "
 #       Hey bro! I'm a service, and imma send this secure password:
  #      $(cat ${config.sops.secrets.secretservice.path})
  #      located in:
 #       ${config.sops.secrets.secretservice.path}
 #       to database and hack the mainframe
 #       " > /var/lib/secretservice/testfile
 #  '';
 #   serviceConfig = {
 #     User = "secretservice";
 #     WorkingDirectory = "/var/lib/secretservice";
#    };
#  };


  sops.secrets = {
    mosquitto = {
      sopsFile = ./../secrets/mosquitto.yaml; 
      owner = config.this.user.me.name;
      group = config.this.user.me.name;
      mode = "0440"; # Read-only for owner and group
    };

    w = {
      sopsFile = ./../secrets/w.yaml;
      owner = config.this.user.me.name;
      group = config.this.user.me.name;
      mode = "0440"; # Read-only for owner and group
    };
    resrobot = {
      sopsFile = ./../secrets/resrobot.yaml;
      owner = config.this.user.me.name;
      group = config.this.user.me.name;
      mode = "0440"; # Read-only for owner and group
    };
  };

#  config.sops.secrets.resrobot.path;
  
 # sops.secrets = {
#   smb = {
#      sopsFile = "/var/lib/sops-nix/secrets/smb.yaml"; 
  #    owner = config.this.user.me.name;
 #    group = config.this.user.me.name;
  #    mode = "0440"; # Read-only for owner and group
 #   };
#  };

#  sops.secrets = {
 #   smbb = {
 #     sopsFile = "/var/lib/sops-nix/secrets/smbb.yaml"; 
#      owner = config.this.user.me.name;
 #     group = config.this.user.me.name;
#      mode = "0440"; # Read-only for owner and group
#    };
#  };

#  config.sops.secrets.smbb.path;
  

  security.sudo.extraRules = [
    {
      users = [ "pungkula" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/smartctl";
          options = [ "NOPASSWD" ];
        }
        {
          command = "${self.packages.${pkgs.system}.health}/bin/health";
          options = [ "NOPASSWD" ];
        }        
      ];
    }
    {
      users = [ "dockeruser" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/systemctl restart docker-transmission";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];


#   swaylock pass verify
#    security.pam.services.swaylock = {
 #     text = ''
 #     auth include login
 #     '';
 #   };
  

  #  security.sudo = {
  #      enable = true;
  #      extraConfig = ''
  #          %wheel ALL=(ALL) NOPASSWD: ALL
   #     '';
 #   };
 
#######################
# HARDENING 

## Enable BBR module
#boot.kernelModules = [ "tcp_bbr" ];

## Network hardening and performance
#boot.kernel.sysctl = {
  # Disable magic SysRq key
#  "kernel.sysrq" = 0;
  # Ignore ICMP broadcasts to avoid participating in Smurf attacks
#  "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
  # Ignore bad ICMP errors
#  "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
  # Reverse-path filter for spoof protection
#  "net.ipv4.conf.default.rp_filter" = 1;
#  "net.ipv4.conf.all.rp_filter" = 1;
#  # SYN flood protection
#  "net.ipv4.tcp_syncookies" = 1;
  # Do not accept ICMP redirects (prevent MITM attacks)
#  "net.ipv4.conf.all.accept_redirects" = 0;
#  "net.ipv4.conf.default.accept_redirects" = 0;
#  "net.ipv4.conf.all.secure_redirects" = 0;
#  "net.ipv4.conf.default.secure_redirects" = 0;
#  "net.ipv6.conf.all.accept_redirects" = 0;
#  "net.ipv6.conf.default.accept_redirects" = 0;
  # Do not send ICMP redirects (we are not a router)
#  "net.ipv4.conf.all.send_redirects" = 0;
  # Do not accept IP source route packets (we are not a router)
#  "net.ipv4.conf.all.accept_source_route" = 0;
#  "net.ipv6.conf.all.accept_source_route" = 0;
  # Protect against tcp time-wait assassination hazards
#  "net.ipv4.tcp_rfc1337" = 1;
  # TCP Fast Open (TFO)
#  "net.ipv4.tcp_fastopen" = 3;
  ## Bufferbloat mitigations
  # Requires >= 4.9 & kernel module
#  "net.ipv4.tcp_congestion_control" = "bbr";
  # Requires >= 4.19
 # "net.core.default_qdisc" = "cake";
#};

#TCP Fast Open (TFO) is enabled by default (tcp_fastopen = 1) for outgoing connection since 3.13. As of writing, TFO has limited server support; Caddy, Tor and I2Pd don’t support it yet, so enabling it for incoming and outgoing connections (3) has no effect.
#Hardened kernel §

##Kernel compiled with additional security-oriented patch set. More details.

#NixOS defaults to the latest LTS kernel

# Latest LTS kernel
#boot.kernelPackages = pkgs.linuxPackages_hardened;

# Latest kernel
#boot.kernelPackages = pkgs.linuxPackages_latest_hardened;



}
