# lib/nixos.nix
{ self, lib, attrs, inputs }:
let
  mkApp = program: {
    inherit program;
    type = "app";
  };

  mkFlakeInternal = { 
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
      hosts = attrs.mapHosts ../hosts;           

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
            nixosConfigurations = self.nixosConfigurations;
            finalSelf = self // {
              hostDir = ../hosts/${hostName};
              modules = lib.filterAttrs (_: v: v ? nixosModules) inputs;
            };
          };
          modules = [
#            inputs.disko.nixosModules.disko
#            inputs.home-manager.nixosModules.home-manager 
            inputs.sops-nix.nixosModules.sops
            ../.
            hostConfig             
            ./home.nix 
            ({ config, pkgs, ... }: {
              this.home = ./../home;
            })
            
#            ({ config, pkgs, ... }: {
#              home-manager = {
#                useGlobalPkgs = true;
#                backupFileExtension = "bak";
#                useUserPackages = true;
#                extraSpecialArgs = {
#                  inherit self inputs;
#                  hostname = config.this.host.hostname;
#                  user = config.this.user.me.name;
#                  this = config.this;
#                };
#                users.${config.this.user.me.name} = import ./../home-manager/home.nix;
#              };
#            })
          ];
        }) (attrs.mapHosts ../hosts);

      installerConfigurations = lib.mapAttrs (hostName: hostConfig:
        inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./../installer.nix
          ];
          specialArgs = {
            inherit self inputs hostName;
            hostConfig = hostConfig;
          };
        }) (attrs.mapHosts ../hosts);

      installerIsos = lib.mapAttrs (hostName: config: config.config.system.build.isoImage) installerConfigurations;
      isoPackages = lib.mapAttrs' (hostName: iso: lib.nameValuePair "auto-installer.${hostName}" iso) installerIsos;

      perSystem = system: let
        pkgs = mkPkgs system inputs.nixpkgs flake.overlays;  # Use flake.overlays
      in {
        packages = lib.mapAttrs (_: v: 
          (mkPkgs system inputs.nixpkgs flake.overlays).callPackage v {})  # Apply overlays
          packages;

        apps = lib.mapAttrs (_: v:
          let
            pkgs = mkPkgs system inputs.nixpkgs flake.overlays;
          in
            mkApp (v { inherit pkgs system self inputs; })  # Pass additional args
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
      inherit nixosConfigurations;

      packages = lib.genAttrs systems (system:
        (perSystem system).packages
        // (if system == "x86_64-linux" then isoPackages else {})
      );

      apps = lib.genAttrs systems (system: (perSystem system).apps);
      devShells = lib.genAttrs systems (system: (perSystem system).devShells);
    };
in {
  inherit mkApp;
  mkFlake = args: mkFlakeInternal args;
}


