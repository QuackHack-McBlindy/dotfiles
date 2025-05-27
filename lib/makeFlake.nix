# dotfiles/lib/makeFlake.nix
{ 
  self,
  lib,
  dirMap,
  inputs
} : let
  makeApp = program: {
    inherit program;
    type = "app";
  };

  makeFlakeInternal = { 
    systems, 
    hosts ? {}, 
    modules ? [], 
    overlays ? [], 
    packages ? {}, 
    apps ? {}, 
    devShells ? {}, 
    ... 
  } @ flake:  
    let
      hosts = dirMap.mapHosts ../hosts;           

      makePkgs = system: pkgs: overlays: import pkgs {
        inherit system overlays;
        config.allowUnfree = true;
      };

      nixosConfigurations = lib.mapAttrs (hostName: hostConfig:
        inputs.nixpkgs.lib.nixosSystem {
          system = hostName;
          specialArgs = {
            inherit self inputs;
            inherit hostName;
            nixosConfigurations = self.nixosConfigurations;
            finalSelf = self // {
              hostDir = ../hosts/${hostName};
              modules = lib.filterAttrs (_: v: v ? nixosModules) inputs;
            };
          };
          modules = [
            inputs.sops-nix.nixosModules.sops
            ../.
            hostConfig             
            ./../modules/home.nix 
          ];
        }) (dirMap.mapHosts ../hosts);

      perSystem = system: let
        pkgs = makePkgs system inputs.nixpkgs flake.overlays; 
      in {

        packages = lib.mapAttrs (_: v: 
          (makePkgs system inputs.nixpkgs flake.overlays).callPackage v {
            inherit self;
            lib = inputs.nixpkgs.lib.extend (final: prev: {
              # Custom lib extensions
            });
          }
        ) packages;

        apps = lib.mapAttrs (_: v:
          let
            pkgs = makePkgs system inputs.nixpkgs flake.overlays;
          in
            makeApp (v { inherit pkgs system self inputs; })  # Pass additional args
        ) apps;

        devShells = lib.mapAttrs (name: v:
          let
            shellArgs = v { 
              inherit pkgs system self inputs;
            };
            # Sanitize arguments for mkShell
            sanitizedArgs = builtins.removeAttrs shellArgs [
              "override"
              "overrideDerivation"
              "__functionArgs"
              "__functor"
            ];
          in
            pkgs.mkShell (sanitizedArgs // {
              # Ensure basic shell environment
              NIX_CONFIG = "extra-experimental-features = nix-command flakes";
              shellHook = ''
                echo "Entering ${name} dev shell"
                ${shellArgs.shellHook or ""}
              '';
            })
        ) devShells;

      };
    in {
      inherit nixosConfigurations; #diskoConfigurations;

      packages = lib.genAttrs systems (system:
        (perSystem system).packages
#        // (if system == "x86_64-linux" then isoPackages else {})
      );

      apps = lib.genAttrs systems (system: (perSystem system).apps);
      devShells = lib.genAttrs systems (system: (perSystem system).devShells);
    };
in {
  inherit makeApp;
  makeFlake = args: makeFlakeInternal args;
  
  }


