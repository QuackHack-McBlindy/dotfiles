# Build pixiecore runner
#nix build -f system.nix -o /tmp/run-pixiecore

# Open required firewall ports
#sudo iptables -w -I nixos-fw -p udp -m multiport --dports 67,69,4011 -j ACCEPT
#sudo iptables -w -I nixos-fw -p tcp -m tcp --dport 64172 -j ACCEPT

# Run pixiecore
#sudo $(realpath /tmp/run-pixiecore)

# Close ports
#sudo iptables -w -D nixos-fw -p udp -m multiport --dports 67,69,4011 -j ACCEPT
#sudo iptables -w -D nixos-fw -p tcp -m tcp --dport 64172 -j ACCEPT


let
  # NixOS 22.11 as of 2023-01-12
  nixpkgs = builtins.getFlake "github:nixos/nixpkgs/54644f409ab471e87014bb305eac8c50190bcf48";

  sys = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ({ config, pkgs, lib, modulesPath, ... }: {
        imports = [
          (modulesPath + "/installer/netboot/netboot-minimal.nix")
         # ./installer.nix
        ];
        config = {

          nixpkgs.config.allowUnfree = true;
          hardware.enableAllFirmware = true;

          services.journald.console = "/dev/tty1";

          nix.settings.substituters = lib.mkForce [];

          systemd.services.install = {
            description = "Bootstrap a NixOS installation";
            wantedBy = [ "multi-user.target" ];
            after = [ "network.target" "polkit.service" ];
            path = [ "/run/current-system/sw/" ];
            script = with pkgs; ''
              # this is just for debugging purposes, can be removed when it all works
              echo 'journalctl -fb -n100 -uinstall' >> ~nixos/.bash_history

              set -euxo pipefail

              wait-for() {
                for _ in seq 10; do
                  if $@; then
                    break
                  fi
                  sleep 1
                done
              }

              dev=/dev/sda
              [ -b /dev/nvme0n1 ] && dev=/dev/nvme0n1
              [ -b /dev/vda ] && dev=/dev/vda



              #!/bin/bash

              # Exit on error
              set -e

              # Step 0: Wait to ensure system is booted.
              #sleep 60

              # Step 1: Generate NixOS configuration
              echo "Generating NixOS configuration..."
              nixos-generate-config --root /tmp/config

              # Step 2: Remove default configuration.nix
              echo "Removing default configuration.nix..."
              rm -rf /tmp/config/etc/nixos/configuration.nix

              # Step 3: Write custom configuration.nix
              echo "Writing custom configuration.nix..."
              cat > /tmp/config/etc/nixos/configuration.nix <<EOF
              { config, pkgs, ... }:
              {
               # imports = [
              #    ./hardware-configuration.nix
    
              #  ];

              #°•──→ BOOTLOADER ←──•°
                imports = [
                  (modulesPath + "/installer/scan/not-detected.nix")
                  (modulesPath + "/profiles/qemu-guest.nix")
                  ./disk-config.nix
                ];
                boot.loader.grub = {
                  # no need to set devices, disko will add all devices that have a EF02 partition to the list already
                  # devices = [ ];
                  efiSupport = true;
                  efiInstallAsRemovable = true;
                };

                networking = {
                  firewall.enable = false;
                  hostName = "usb";
                  # networkmanager.enable = true; 
                  # usePredictableInterfaceNames = false;
                  interfaces.eth0.ipv4.addresses = [{
                    address = "192.168.1.150"; 
                    prefixLength = 24;
                  }];
                  defaultGateway = "192.168.1.1";
                  nameservers = [ "8.8.8.8" "8.8.4.4" ]; 
                };

                users.defaultUserShell = pkgs.bash;
                users.users.pungkula = {
                  isNormalUser = true;
                  extraGroups = [ "networkmanager" "wheel" "qemu-libvirtd" "libvirtd" "kvm" "docker" "amdgpu" ];
                };
                users.extraUsers.root.password = "nixos";
                users.users.root.password = "nixos";

                services.xserver = {
                  enable = true;
                  exportConfiguration = true;
                  xkb.layout = "se";
                  xkb.options = "eurosign:e";
                  displayManager.gdm.enable = true;
                  displayManager.gdm.wayland = true;
                  desktopManager.gnome.enable = true;
                };

                time.timeZone = "Europe/Stockholm";
                i18n.defaultLocale = "sv_SE.UTF-8";
                i18n.consoleKeyMap = "sv-latin1";
                i18n.extraLocaleSettings = {
                  LC_ADDRESS = "sv_SE.UTF-8";
                  LC_IDENTIFICATION = "sv_SE.UTF-8";
                  LC_MEASUREMENT = "sv_SE.UTF-8";
                  LC_MONETARY = "sv_SE.UTF-8";
                  LC_NAME = "sv_SE.UTF-8";
                  LC_NUMERIC = "sv_SE.UTF-8";
                  LC_PAPER = "sv_SE.UTF-8";
                  LC_TELEPHONE = "sv_SE.UTF-8";
                  LC_TIME = "sv_SE.UTF-8";
                };

                services.locate.enable = true;
                services.openssh.enable = true;
                services.openssh.settings.PermitRootLogin = "yes";
                users.users.root.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAA" ];
                users.users.pungkula.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAA" ];
  
                nixpkgs.config.allowUnfree = true;
                nix.settings.experimental-features = ["nix-command" "flakes"];
  
                environment.systemPackages = [
                  pkgs.nano
                  pkgs.git
                  pkgs.curl
                  pkgs.wget
                  pkgs.gnome-text-editor
                  pkgs.gnome-terminal
                  pkgs.firefox
                ];

                system.stateVersion = "24.05";
              }
              EOF

              # Step 4: Set the correct permissions for configuration.nix
              chmod 644 /tmp/config/etc/nixos/configuration.nix
              chown root:root /tmp/config/etc/nixos/configuration.nix

              # Step 5: Write flake.nix
              echo "Writing flake.nix..."
              cat > /tmp/config/etc/nixos/flake.nix <<EOF
              {
                inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
                inputs.disko.url = "github:nix-community/disko/latest";
                inputs.disko.inputs.nixpkgs.follows = "nixpkgs";

                outputs = { self, disko, nixpkgs }: {
                  nixosConfigurations.mymachine = nixpkgs.lib.nixosSystem {
                    system = "x86_64-linux";
                    modules = [
                      ./configuration.nix
                      disko.nixosModules.disko
                      {
                        disko.devices = {
                          disk.disk1 = {
                            device = "/dev/sda";
                            type = "disk";
                            content = {
                              type = "gpt";  # Using GPT as the disklabel type
                              partitions = {
                                boot = {
                                  name = "boot";
                                  size = "512M";  # Boot partition size
                                  type = "8300";  # Type for Linux filesystem (MBR)
                                  content = {
                                    type = "filesystem";
                                    format = "vfat";
                                    mountpoint = "/boot";
                                  };
                                };
                                root = {
                                  name = "root";
                                  size = "100%";  # The remaining space
                                  content = {
                                    type = "filesystem";
                                    format = "ext4";
                                    mountpoint = "/";
                                    mountOptions = [ "defaults" ];
                                  };
                                };
                              };
                            };
                          };
                        };
                      } 
                    ];
                  };
                };  
              }

              EOF

              # Step 6: Run Disko install
             sudo nix run 'github:nix-community/disko/latest#disko-install' -- --write-efi-boot-entries --flake '/tmp/config/etc/nixos#mymachine' --disk disk1 /dev/sda --show-trace




              echo 'Done. Shutting off.'
              ${systemd}/bin/systemctl poweroff
      
            '';
            environment = config.nix.envVars // {
              inherit (config.environment.sessionVariables) NIX_PATH;
              HOME = "/root";
            };
            serviceConfig = {
              Type = "oneshot";
            };
          };

        
          system.stateVersion = config.system.nixos.release;
        };
      })
    ];
  };

  run-pixiecore = let
    hostPkgs = if sys.pkgs.system == builtins.currentSystem
               then sys.pkgs
               else nixpkgs.legacyPackages.${builtins.currentSystem};
    build = sys.config.system.build;
  in hostPkgs.writers.writeBash "run-pixiecore" ''
    exec ${hostPkgs.pixiecore}/bin/pixiecore \
      boot ${build.kernel}/bzImage ${build.netbootRamdisk}/initrd \
      --cmdline "init=${build.toplevel}/init loglevel=4" \
      --debug --dhcp-no-bind \
      --port 64172 --status-port 64172 "$@"
  '';
in
  run-pixiecore
