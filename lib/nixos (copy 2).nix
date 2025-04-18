{ self, lib, attrs, inputs }:
let
  mkApp = program: {
    inherit program;
    type = "app";
  };

  mkFlake = { systems, hosts ? {}, modules ? [], packages ? {}, apps ? {}, devShells ? {}, ... } @ flake: 
    let
      # New ISO generation logic
      hostHasDisko = hostName: 
        builtins.pathExists (../hosts/${hostName}/disks.nix);

      makeIsoConfig = hostName: hostConfig:
        lib.nameValuePair "${hostName}-iso" (hostConfig // {
          modules = hostConfig.modules ++ [
            inputs.disko.nixosModules.disko
            { disko.devices = import ../hosts/${hostName}/disks.nix; }
            ({ config, ... }: {
              # ISO-specific overrides
              formatAttr = "isoImage";
              fileSystems."/" = { 
                device = "/dev/disk/by-label/nixos"; 
                fsType = "tmpfs"; 
              };
            })
          ];
        });

      isoHosts = lib.mapAttrs' (name: cfg: 
        if hostHasDisko name then makeIsoConfig name cfg else null
      ) hosts;

      # Original configuration logic
      mkPkgs = system: pkgs: overlays: import pkgs {
        inherit system overlays;
        config.allowUnfree = true;
      };

      nixosConfigurations = lib.mapAttrs (hostName: hostConfig:
        inputs.nixpkgs.lib.nixosSystem {
          system = hostConfig.system;
          specialArgs = {
            inherit self inputs;
            inherit hostName;
            finalSelf = self // {
              hostDir = ../hosts/${hostName};
              modules = lib.filterAttrs (_: v: v ? nixosModules) inputs;
            };
          };
          modules = [
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

      perSystem = system: {
        packages = lib.mapAttrs (_: v: (mkPkgs system inputs.nixpkgs []).callPackage v {}) packages;
        apps = lib.mapAttrs (_: v: mkApp v) apps;
        devShells = lib.mapAttrs (_: v:
          let
            pkgs = mkPkgs system inputs.nixpkgs [];
          in
            pkgs.mkShell (v { inherit pkgs; })
        ) devShells;
      };

    in {
      inherit nixosConfigurations;
      isoConfigurations = lib.mkIf (isoHosts != {}) (
        lib.mapAttrs (name: cfg: inputs.nixpkgs.lib.nixosSystem cfg) isoHosts
      );
      packages = lib.genAttrs systems (system: (perSystem system).packages);
      apps = lib.genAttrs systems (system: (perSystem system).apps);
      devShells = lib.genAttrs systems (system: (perSystem system).devShells);
    };

in {
  inherit mkApp mkFlake;
}
