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
          modules = [ ./configuration/configuration.nix ];
        };
      };
    };
}


#=============================#

Can you safely and CAREFULLY integrate the above into my existing lib/nixos.nix file. But please don't start chaging stuff in the nixos.nix file that dooes not concern this specific usecase.
I want to be able to build auto installing ISO images for all my host machines. 

Optimal would be to have the same installer for every single host machine. But when building the iso image being able to specify which host machine to build the iso installer for (thus changing the configuration/configuration.nix to one of my hosts configuration files they are all named default and are located in its own directory inside ./hosts . For example ./hosts/desktop/default.nix ./hosts/homie/default.nix ./hosts/laptop/default.nix or ./hosts/nasty/default.nix )

To make it more clear: I want ALL OF THE MAGIC to happen in the lib/nixos.nix file and keep my flake.nix file slim and short.
Im guessing checks and pre commit hooks and such from the auto installing flake file are not really needed for the installation part and can safely be ignored(?)

#==============================#

# lib/nixos.nix
{ self, lib, attrs, inputs }:
let
  mkApp = program: {
    inherit program;
    type = "app";
  };

  mkFlake = { systems, hosts ? {}, modules ? [], packages ? {}, apps ? {}, devShells ? {}, ... } @ flake: 
    let
      hosts = attrs.mapHosts ../hosts;
              
      mkPkgs = system: pkgs: overlays: import pkgs {
        inherit system overlays;
        config.allowUnfree = true;
      };

      nixosConfigurations = lib.mapAttrs (hostName: hostConfig:
        inputs.nixpkgs.lib.nixosSystem {
          #system = hostConfig.system;
          system = hostName;
          specialArgs = {
            inherit self inputs;
            inherit hostName;
            finalSelf = self // {
              hostDir = ../hosts/${hostName};
              modules = lib.filterAttrs (_: v: v ? nixosModules) inputs;
            };
          };
          modules = [
            inputs.disko.nixosModules.disko
            inputs.home-manager.nixosModules.home-manager 
            inputs.sops-nix.nixosModules.sops
            ../.
            hostConfig 
            ({ config, pkgs, ... }: {
              home-manager = {
                useGlobalPkgs = true;
                backupFileExtension = "bak";
                useUserPackages = true;
                extraSpecialArgs = {
                  inherit self inputs;
                  hostname = config.this.host.hostname;
                  user = config.this.user.me.name;
                  this = config.this;
                };
                users.${config.this.user.me.name} = import ./../home-manager/home.nix;
              };
            })
          ];
        }) (attrs.mapHosts ../hosts);

      installerConfigurations = lib.mapAttrs (hostName: hostConfig:
        inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ../installer.nix
            hostConfig
          ];
          specialArgs = {
            inherit self inputs;
            hostName = hostName;
          };
        }) (attrs.mapHosts ../hosts);

      perSystem = system: let
        pkgs = mkPkgs system inputs.nixpkgs [];
      in {
        packages = lib.mapAttrs (_: v: (mkPkgs system inputs.nixpkgs []).callPackage v {}) packages;
        


        apps = lib.mapAttrs (_: v:
          let
            pkgs = mkPkgs system inputs.nixpkgs [];
          in
            mkApp (v { inherit pkgs; })
        ) apps;
        devShells = lib.mapAttrs (_: v:
          let
            pkgs = mkPkgs system inputs.nixpkgs [];
          in
            pkgs.mkShell (v { inherit pkgs; })
        ) devShells;
      };
    in {
      inherit nixosConfigurations;
      packages = lib.genAttrs systems (system: (perSystem system).packages);
      apps = lib.genAttrs systems (system: (perSystem system).apps);
      devShells = lib.genAttrs systems (system: (perSystem system).devShells);
      installerIsos = lib.mapAttrs (hostName: config:
        config.config.system.build.isoImage
      ) installerConfigurations;

      packages = lib.genAttrs systems (system:
        (perSystem system).packages // (lib.filterAttrs (_: _: system == "x86_64-linux") installerIsos)
      );
    };
in {
  inherit mkApp mkFlake;
}
