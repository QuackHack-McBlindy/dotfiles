{ 
  self,
  config,
  pkgs,
  lib,
  baseHost,
  hostName,
  hostConfig,
  modulesPath,
  ...
} : let
  flakeSource = builtins.path { path = ./../../.; name = "dotfiles"; };

  dependencies = [
    self.nixosConfigurations.${hostName}.config.system.build.toplevel
    self.nixosConfigurations.${hostName}.config.system.build.diskoScript
    self.nixosConfigurations.${hostName}.config.system.build.diskoScript.drvPath
    self.nixosConfigurations.${hostName}.pkgs.stdenv.drvPath

    # Perl dependencies for activation scripts
    self.nixosConfigurations.${hostName}.pkgs.perlPackages.ConfigIniFiles
    self.nixosConfigurations.${hostName}.pkgs.perlPackages.FileSlurp

    # Closure info derivation
    (self.nixosConfigurations.${hostName}.pkgs.closureInfo { rootPaths = [ ]; }).drvPath
  ] ++ builtins.map (i: i.outPath) (builtins.attrValues self.inputs);
  
  closureInfo = pkgs.closureInfo { rootPaths = dependencies; };
in {
  imports = [ 
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix" 
    
  ];

  environment.etc."install-closure".source = "${closureInfo}/store-paths";

  environment.systemPackages = [
    pkgs.disko
    (pkgs.writeShellScriptBin "autoInstaller" ''
      set -euxo pipefail
      dev=/dev/sda
      [ -b /dev/nvme0n1 ] && dev=/dev/nvme0n1
      [ -b /dev/vda ] && dev=/dev/vda
      
      mkdir -p /mnt/persist/age

      exec ${pkgs.disko}/bin/disko-install --flake "${self}#${hostName}" --disk main "$dev"
    '')
  ];

  isoImage = {
    isoName = "autoinstall-${hostName}.iso";
    volumeID = "autoinstall-${hostName}";      
  };

  # Ensures proper EFI support
  systemd.services.sshd.wantedBy = lib.mkForce ["multi-user.target"];
  
  services.getty.helpLine = ''
    ██████╗ ██╗   ██╗███╗   ██╗ ██████╗ ██╗  ██╗██╗   ██╗██╗      █████╗ 
    ██╔══██╗██║   ██║████╗  ██║██╔════╝ ██║ ██╔╝██║   ██║██║     ██╔══██╗
    ██████╔╝██║   ██║██╔██╗ ██║██║  ███╗█████╔╝ ██║   ██║██║     ███████║
    ██╔═══╝ ██║   ██║██║╚██╗██║██║   ██║██╔═██╗ ██║   ██║██║     ██╔══██║
    ██║     ╚██████╔╝██║ ╚████║╚██████╔╝██║  ██╗╚██████╔╝███████╗██║  ██║
    ╚═╝      ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝
  '';

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
      export NIX_CONFIG="extra-experimental-features = nix-command flakes"
      exec autoInstaller
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

  
  # Disko configuration (should match your original partitioning scheme)
#  disko.devices = {
#    disk.main = {
#      device = lib.mkDefault "/dev/disk/by-id/placeholder";  # Overridden by CLI
#      type = "disk";
#      content = {
#        type = "gpt";
#        partitions = {
#          boot = {
#            name = "BOOT";
#            size = "512M";
#            type = "EF00";
#            content = {
#              type = "filesystem";
#              format = "vfat";
#              mountpoint = "/boot";
#            };
#          };
#          swap = {
#            name = "SWAP";
#            size = "8G";
#            type = "8200";
#            content = {
#              type = "swap";
#            };
#          };
#          root = {
#            name = "NIXOS";
#            size = "100%";
#            content = {
#              type = "filesystem";
#              format = "ext4";
#              mountpoint = "/";
#            };
#          };
#        };
#      };
#    };
#  };
}  
