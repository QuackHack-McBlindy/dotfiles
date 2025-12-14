# dotfiles/modules/security.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
# 🦆 duck say ⮞ SECURITY?! WAT THE QUACK IS DAT?!
{
  self,
  inputs,
  pkgs,
  config,
  lib,
  ...
}: {
  # 🦆 duck say ⮞ BOOT?! DUCKS DON'T WEAR SHOES?!
  boot = {
#    tmp.useTmpfs = lib.mkDefault true;
#    tmp.cleanOnBoot = lib.mkDefault (!config.boot.tmp.useTmpfs);

    # Disable kernel-param editing on boot
    loader.systemd-boot.editor = false;

    # 🦆 duck say ⮞ kernel security, can't make joke bout' dat.. 
    kernel.sysctl = {
      # Magic SysRq key -> allows performing low-level commands.
      "kernel.sysrq" = 0;

      ## TCP hardening
      # Prevent bogus ICMP errors from filling up logs.
#      "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
      # Reverse path filtering causes the kernel to do source validation of
      # packets received from all interfaces. This can mitigate IP spoofing.
      "net.ipv4.conf.default.rp_filter" = 1;
      "net.ipv4.conf.all.rp_filter" = 1;
      # Do not accept IP source route packets (we're not a router)
      "net.ipv4.conf.all.accept_source_route" = 0;
      "net.ipv6.conf.all.accept_source_route" = 0;
      # Don't send ICMP redirects (again, we're on a router)
#      "net.ipv4.conf.all.send_redirects" = 0;
      "net.ipv4.conf.default.send_redirects" = 0;
      # Refuse ICMP redirects (MITM mitigations)
#      "net.ipv4.conf.all.accept_redirects" = 0;
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
#      "net.ipv4.tcp_congestion_control" = "bbr";
#      "net.core.default_qdisc" = "cake";
    };
    kernelModules = ["tcp_bbr"];
  };

  security = {
    # Prevent replacing the running kernel w/o reboot
    protectKernelImage = true;
    acme.acceptTerms = true;
    
    # Allows unautherized applications -> send unautherization request
    # polkit.enable = true;
  };
    
  services.gnome.gnome-keyring.enable = true;
  services.gvfs.enable = true; 
  networking.firewall.logRefusedConnections = true;

  # 🦆 duck say ⮞ sops configurationz
  sops = {
    defaultSopsFile = ./../.sops.yaml;
    defaultSopsFormat = "yaml";
    validateSopsFiles = false;
    age.keyFile = lib.mkDefault "/var/lib/sops-nix/age.age";
    age.generateKey = lib.mkDefault false; # Only generate keys outside installer

    # 🦆 duck say ⮞ sops secrets
    secrets = lib.mkIf (!config.this.installer) {
      w = {
        sopsFile = ./../secrets/w.yaml;
        owner = config.this.user.me.name;
        group = config.this.user.me.name;
        mode = "0440"; # Read-only for owner and group
      };
    };  
  };

  # 🦆 duck say ⮞ quacky hacky with no passy    
  security.sudo.extraConfig = ''
    pungkula ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/systemctl restart yo-wake
  '';
  security.sudo.extraRules = [  
    {
      users = [ "pungkula" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/nix-env";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/etc/profiles/per-user/pungkula/bin/rollback";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/smartctl";
          options = [ "NOPASSWD" ];
        }
        {
          command = "${self.packages.${pkgs.system}.health}/bin/health";
          options = [ "NOPASSWD" ];
        }     
        {
          command = "/run/current-system/sw/bin/health";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/nvme";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/reboot";
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
    
  ];}
