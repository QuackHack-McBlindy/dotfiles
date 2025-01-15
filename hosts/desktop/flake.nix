{
  description = "NixOS Offline Auto Installer";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      perSystem = { config, system, pkgs, ... }: {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        devShells.default = pkgs.mkShell {
          inherit (config.checks.pre-commit-check) shellHook;
        };

        packages = {
          default = config.packages.installer-iso;
          installer-iso = inputs.self.nixosConfigurations.installer.config.system.build.isoImage;

          install-demo = pkgs.writeShellScript "install-demo" ''
            set -euo pipefail
            disk=root.img
            if [ ! -f "$disk" ]; then
              echo "Creating harddisk image root.img"
              ${pkgs.qemu}/bin/qemu-img create -f qcow2 "$disk" 20G
            fi
            ${pkgs.qemu}/bin/qemu-system-x86_64 \
              -cpu host \
              -enable-kvm \
              -m 2G \
              -bios ${pkgs.OVMF.fd}/FV/OVMF.fd \
              -cdrom ${config.packages.installer-iso}/iso/*.iso \
              -hda "$disk"
          '';
        };

        checks = {
          pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              deadnix.enable = true;
              nixpkgs-fmt.enable = true;
              shellcheck.enable = true;
              shfmt.enable = true;
              statix.enable = true;
            };
          };
        };
      };
      flake = {
        nixosConfigurations.installer = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./installer.nix ];
        };
        nixosConfigurations.installed = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./configuration.nix ];
        };
      };
    };
}
