# dotfiles/lib/makeFlake.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 duck say ⮞ dis iz pure tool buildin' stuffz yo
  self,
  lib,
  dirMap,
  inputs
} : let # 🦆 duck say ⮞ label for clarity
  makeApp = program: {
    inherit program;
    type = "app";
  };  # 🦆 duck say ⮞ big thing dat make flakes small
  makeFlakeInternal = { # 🦆 duck say ⮞ give it - and you shall receive!
    systems, 
    hosts ? {}, 
    modules ? [], 
    overlays ? [], 
    packages ? {}, 
    apps ? {}, 
    devShells ? {}, 
    ... 
  } @ flake: # 🦆 duck say ⮞ thx
    let
      # 🦆 duck say ⮞ first we load all da machines by mapping hosts directory
      hosts = dirMap.mapHosts ../hosts;        
      
      # 🦆 duck say ⮞ helper dat init nixpkgs with system and overlays - allowing unfree
      makePkgs = system: pkgs: overlays: import pkgs {
        inherit system overlays;
        config.allowUnfree = true;
      };
      
      # 🦆 duck say ⮞ builds nixosConfiguration for each host
      nixosConfigurations = lib.mapAttrs (hostName: hostConfig:
        inputs.nixpkgs.lib.nixosSystem {
          system = hostName;
          specialArgs = {
            inherit self inputs;
            inherit hostName;
            nixosConfigurations = self.nixosConfigurations;
            finalSelf = self // { # 🦆 duck say ⮞ merge in extra info per host
              hostDir = ../hosts/${hostName};
              modules = lib.filterAttrs (_: v: v ? nixosModules) inputs;
            };
          };
          modules = [
            inputs.sops-nix.nixosModules.sops # 🦆 duck say ⮞ secret keepin'
            {
              nixpkgs.overlays = overlays; 
            }
            ../. # 🦆 duck say ⮞ loads ../default.nix
            hostConfig             
            ../modules/home.nix # 🦆 duck say ⮞ home is where your duck's at
          ];
        }) (dirMap.mapHosts ../hosts);
        
      # 🦆 duck say ⮞ for each system build packages, apps & devShells
      perSystem = system: let # 🦆 duck say ⮞ init dis system with nixpkgs & overlays
        pkgs = makePkgs system inputs.nixpkgs flake.overlays; 
      in {
        # 🦆 duck say ⮞ build packages calling nixpkgs.callPackage on each package
        packages = lib.mapAttrs (_: v: 
          (makePkgs system inputs.nixpkgs flake.overlays).callPackage v {
            inherit self;
            lib = inputs.nixpkgs.lib.extend (final: prev: {
              # 🦆 duck say ⮞ addd custom lib extensions here yo
            });
          }
        ) packages;
        
        # 🦆 duck say ⮞ apply makeApp to da apps
        apps = lib.mapAttrs (_: v:
          let
            pkgs = makePkgs system inputs.nixpkgs flake.overlays;
          in
            makeApp (v { inherit pkgs system self inputs; })  # 🦆 duck say ⮞ pass additional args
        ) apps;
        # 🦆 duck say ⮞ build devShells for dis system
        devShells = lib.mapAttrs (name: v:
          let
            shellArgs = v { 
              inherit pkgs system self inputs;
            };
            # 🦆 duck say ⮞ sanitize arguments for mkShell
            sanitizedArgs = builtins.removeAttrs shellArgs [
              "override"
              "overrideDerivation"
              "__functionArgs"
              "__functor"
            ];
          in
            pkgs.mkShell (sanitizedArgs // {
              # 🦆 duck say ⮞ for the love of flake...
              NIX_CONFIG = "extra-experimental-features = nix-command flakes";
              shellHook = ''
                echo "Entering ${name} dev shell"
                ${shellArgs.shellHook or ""}
              '';
            })
        ) devShells;
      };      
    in { 
      # 🦆 duck say ⮞ export nixosConfigurations to Nix
      inherit nixosConfigurations;
      
      # 🦆 duck say ⮞ build per system packages, apps & devShells attributes  
      packages = lib.genAttrs systems (system:
        (perSystem system).packages
      );
      apps = lib.genAttrs systems (system: (perSystem system).apps);
      devShells = lib.genAttrs systems (system: (perSystem system).devShells);
      # 🦆 duck say ⮞ show overlays in nix flake show
      overlays = lib.mapAttrs'
        (name: _: lib.nameValuePair (lib.removeSuffix ".nix" name)
          (import (../overlays + "/${name}") { inherit lib; }))
        (lib.filterAttrs (name: type: lib.hasSuffix ".nix" name)
          (builtins.readDir ../overlays));
    };
in { # 🦆 duck say ⮞ expose makeApp & makeFlake for use in flake
  inherit makeApp;
  makeFlake = args: makeFlakeInternal args;  
  } # 🦆 duck say ⮞ da end

