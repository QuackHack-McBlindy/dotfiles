# dotfiles/flake.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{
    description = "❄️🦆 ⮞ QuackHack-McBLindy's NixOS flake";
    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";        
        sops-nix.url = "github:Mic92/sops-nix";
        sops-nix.inputs.nixpkgs.follows = "nixpkgs";  
        caddy-duckdns.url = "github:QuackHack-McBlindy/nix-caddy-duckdns";
        installer.url = "github:QuackHack-McBlindy/auto-installer-nixos";
        mobile-nixos = {
            url = "github:mobile-nixos/mobile-nixos/183ba2469ab06c4ecb6580ed8b62c3911e8597f5";
            flake = false;
        };

    };
    outputs = inputs @ { self, systems, nixpkgs, mobile-nixos, ... }:
        let
            lib = import ./lib { 
                inherit self inputs;
                lib = nixpkgs.lib;      
            };                   
        in lib.makeFlake {
            systems = [ "x86_64-linux" "aarch64-linux" ]; 
            overlays = lib.mapOverlays ./overlays { inherit lib; };
            hosts = lib.mapHosts ./hosts;
            specialArgs = { pkgs = system: nixpkgs.legacyPackages.${system}; };
            packages = lib.mapModules ./packages import;
            devShells = lib.mapModules ./devShells (path: import path);     
        };} # 🦆 duck say ⮞ flakes all set, with no debating — next nix file awaiting, ducks be there waitin'
