# flake.nix
{ 
    description = "❄️🦆 QuackHack-McBlindy's dotfiles! With extra Flakes.";
    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";     
        home-manager.url = "github:nix-community/home-manager";
        home-manager.inputs.nixpkgs.follows = "nixpkgs";            
        sops-nix.url = "github:Mic92/sops-nix";
        sops-nix.inputs.nixpkgs.follows = "nixpkgs";  
        disko.url = "github:nix-community/disko";
        disko.inputs.nixpkgs.follows = "nixpkgs";
        caddy-duckdns.url = "github:QuackHack-McBlindy/nix-caddy-duckdns";
    };
    outputs = inputs @ { self, systems, nixpkgs, ... }:
        let
            lib = import ./lib {
                inherit self inputs;
                lib = nixpkgs.lib;      
            };
        in lib.mkFlake {
            systems = [ "x86_64-linux" "aarch64-linux" ]; 
            overlays = [ ];
            hosts = lib.mapHosts ./hosts;
            specialArgs = { pkgs = system: nixpkgs.legacyPackages.${system}; yoLib = lib.yo; };
            packages = lib.mapModules ./packages import;
            apps = lib.mkApp ./apps.nix;
            devShells = lib.mapModules ./devShells (path: import path);
        };             
  }
