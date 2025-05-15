# dotfiles/lib/nixos.nix
{ 
  self,
  lib,
  attrs,
  modules
} :

with builtins;
with lib;
with attrs;
rec {
  mkApp = program: {
    inherit program;
    type = "app";
  };

  mkFlake = {
    self
    , yo ? self
    , nixpkgs ? yo.inputs.nixpkgs
    , nixpkgs-unstable ? yo.inputs.nixpkgs-unstable or nixpkgs
    , disko ? yo.inputs.disko
    , ...
  } @ inputs: {
    systems
    , hosts ? {}
    , modules ? {}
    , packages ? {}
    , ...
  } @ flake:
    let
      args = fromJSON (getEnv "yoENV");
      
      mkPkgs = system: pkgs: overlays: import pkgs {
        inherit system overlays;
        config.allowUnfree = true;
      };

      nixosConfigurations = mapAttrs (hostName: hostConfig:
        let
          self' = self // {
            inherit args;
            hostDir = "${toString ./hosts}/${hostName}";
            modules = filterMapAttrs 
              (_: i: i ? nixosModules) 
              (_: i: i.nixosModules)
              inputs;
          };

          yo' = yo // {
            inherit args;
            host = hostName;
            pkgs = mkPkgs finalConfig.system nixpkgs [];
          };

          finalConfig = hostConfig {
            inherit lib;
            yo = yo';
            self = self';
          };
        in
          nixpkgs.lib.nixosSystem {
            system = finalConfig.system;
            specialArgs = { inherit self' yo'; };
            modules = [
              disko.nixosModules.disko
              ../.
              finalConfig
            ];
          }) (mapHosts ./hosts);

    in {
      inherit nixosConfigurations;
      packages = genAttrs systems (system: 
        mapAttrs (_: v: (mkPkgs system nixpkgs []).callPackage v {}) packages);
      devShells = genAttrs systems (system: 
        (mkPkgs system nixpkgs []).callPackage devShells {});
    };
}
