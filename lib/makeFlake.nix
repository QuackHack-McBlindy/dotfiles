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
  };
  
  # 🦆 says ⮞ big thing dat make flakes small
  makeFlakeInternal = { # 🦆 sayz ⮞ give it - and you shall receive!
    systems, 
    hosts ? {}, 
    modules ? [], 
    overlays ? [], 
    packages ? {}, 
    apps ? {}, 
    devShells ? {}, 
    ... 
  } @ flake: # 🦆 say ⮞ thx
    let
      # 🦆 say ⮞ first we load all da machines by mapping hosts directory
      hosts = dirMap.mapHosts ../hosts;        

      # 🦆 say⮞helper dat init nixpkgs with system and overlays - allowing unfree
      makePkgs = system: pkgs: overlays: import pkgs {
        inherit system overlays;
        config.allowUnfree = true;
      };

      # 🦆 says ⮞ mobile phone's are handled differently
      isMobileHost = hostConfig:
        builtins.elem "pinephone"
          (hostConfig.host.modules.hardware or []);

      # 🦆 says ⮞ builds nixosConfiguration for each host
      nixosConfigurations = lib.mapAttrs (hostName: hostConfig:
        let
          system = hostConfig.host.system or hostName;
        in
        inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit self inputs;
            inherit hostName;
            nixosConfigurations = self.nixosConfigurations;
            finalSelf = self // { # 🦆 duck say ⮞ merge in extra info per host
              hostDir = ../hosts/${hostName};
              modules = lib.filterAttrs (_: v: v ? nixosModules) inputs;
            };
          };
          modules = 
            lib.optionals (isMobileHost hostConfig) [
              { # 🦆 says ⮞ mobile has it's own nixpkgs
                nix.nixPath = [
                  "nixpkgs=${inputs.mobile-pkgs}"
                  "mobile-nixos=${inputs.mobile-nixos}"
                ];
              }
              # 🦆 says ⮞ import pinephone specific config
              (import "${inputs.mobile-nixos}/lib/configuration.nix" {
                device = "pinephone";
              })
            ]
            ++ [
              inputs.sops-nix.nixosModules.sops # 🦆 says ⮞ secret keepin'
              { nixpkgs.overlays = overlays; }
              ../. # 🦆 says ⮞ loads ../default.nix
              hostConfig
              ../modules/home.nix # 🦆 says ⮞ home is where your duck's at
            ];
        }
      ) hosts;
      
      # 🦆 duck say ⮞ for each system build packages, apps & devShells
      perSystem = system: let # 🦆 duck say ⮞ init dis system with nixpkgs & overlays
        pkgs = makePkgs system inputs.nixpkgs flake.overlays; 
      in {
        # 🦆 duck say ⮞ build packages calling nixpkgs.callPackage on each package
        packages = lib.mapAttrs (_: v: 
          (makePkgs system inputs.nixpkgs flake.overlays).callPackage v {
            inherit self;
            lib = inputs.nixpkgs.lib.extend (final: prev: {
              # 🦆 says ⮞ addd custom lib extensions here yo
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
        lib.filterAttrs (_: pkg: pkg != null) (perSystem system).packages
      );
      apps = lib.genAttrs systems (system: (perSystem system).apps);
      devShells = lib.genAttrs systems (system: (perSystem system).devShells);
      # 🦆 duck say ⮞ show overlays in nix flake show
      overlays = lib.mapAttrs'
        (name: _: lib.nameValuePair (lib.removeSuffix ".nix" name)
          (final: prev: (import (./../overlays + "/${name}") { inherit lib; }) final prev))
        (lib.filterAttrs (name: type: lib.hasSuffix ".nix" name)
          (builtins.readDir ./../overlays));
    };
in { # 🦆 says ⮞ expose makeApp & makeFlake for use in flake
  inherit makeApp;
  makeFlake = args: makeFlakeInternal args;  
  } # 🦆 says ⮞ da end

