{
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
      "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
      # Reverse path filtering causes the kernel to do source validation of
      # packets received from all interfaces. This can mitigate IP spoofing.
      "net.ipv4.conf.default.rp_filter" = 1;
      "net.ipv4.conf.all.rp_filter" = 1;
      # Do not accept IP source route packets (we're not a router)
      "net.ipv4.conf.all.accept_source_route" = 0;
      "net.ipv6.conf.all.accept_source_route" = 0;
      # Don't send ICMP redirects (again, we're on a router)
      "net.ipv4.conf.all.send_redirects" = 0;
      "net.ipv4.conf.default.send_redirects" = 0;
      # Refuse ICMP redirects (MITM mitigations)
      "net.ipv4.conf.all.accept_redirects" = 0;
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
      "net.ipv4.tcp_fastopen" = 3;
      # Bufferbloat mitigations + slight improvement in throughput & latency
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.core.default_qdisc" = "cake";
    };
    kernelModules = ["tcp_bbr"];
  };

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
    defaultSopsFile = "/var/lib/sops-nix/.sops.yaml";
    defaultSopsFormat = "yaml";
    validateSopsFiles = false;
    age.keyFile = "/var/lib/sops-nix/age.age";
    secrets = {
#      SHADOWSOCKS_PASSWORD = {
#        sopsFile = "/var/lib/sops-nix/secrets/SHADOWSOCKS_PASSWORD.json"; # Specify SOPS-encrypted secret file
#        owner = config.users.users.secretservice.name;
#        group = config.users.groups.secretservice.name;
#        mode = "0440"; # Read-only for owner and group
#      };
      secretservice = {
        sopsFile = "/var/lib/sops-nix/secrets/secretservice.yaml"; # Specify SOPS-encrypted secret file
        owner = config.users.users.secretservice.name;
        group = config.users.groups.secretservice.name;
        mode = "0440"; # Read-only for owner and group
      };
    };
  };  
  systemd.services.secretservice = {
    script = ''
        echo "
        Hey bro! I'm a service, and imma send this secure password:
        $(cat ${config.sops.secrets.secretservice.path})
        located in:
        ${config.sops.secrets.secretservice.path}
        to database and hack the mainframe
        " > /var/lib/secretservice/testfile
   '';
    serviceConfig = {
      User = "secretservice";
      WorkingDirectory = "/var/lib/secretservice";
    };
  };


  sops.secrets = {
    mosquitto = {
      sopsFile = "/var/lib/sops-nix/secrets/mosquitto.yaml"; 
      owner = config.users.users.secretservice.name;
      group = config.users.groups.secretservice.name;
      mode = "0440"; # Read-only for owner and group
    };
  };




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
  
}
