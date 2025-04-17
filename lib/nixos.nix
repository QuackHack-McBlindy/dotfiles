{ self, lib, attrs, inputs }:
let
  mkApp = program: {
    inherit program;
    type = "app";
  };

  mkFlake = { systems, hosts ? {}, modules ? [], packages ? {}, ... } @ flake: 
    let
      mkPkgs = system: pkgs: overlays: import pkgs {
        inherit system overlays;
        config.allowUnfree = true;
      };

      nixosConfigurations = lib.mapAttrs (hostName: hostConfig:
        inputs.nixpkgs.lib.nixosSystem {
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
        #    inputs.disko.nixosModules.disko
            inputs.home-manager.nixosModules.home-manager 
            inputs.sops-nix.nixosModules.sops
            ../.
            hostConfig 
            ({ config, pkgs, ... }: {
              # Home Manager configuration
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
                # Dynamic user reference from config
                users.${config.this.user.me.name} = import ./../home-manager/home.nix;
              };
            })
          ];
        }) (attrs.mapHosts ../hosts);
    in {
      inherit nixosConfigurations;
      packages = lib.genAttrs systems (system:
          lib.mapAttrs (_: v: (mkPkgs system inputs.nixpkgs []).callPackage v {}) packages
      );
    }; 
in {
  inherit mkApp mkFlake;
}
