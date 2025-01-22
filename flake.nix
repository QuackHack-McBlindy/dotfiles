#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
{ #°✶.•°••─→ FLAKE.NIX ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
  description = "❄️🦆 QuackHack-McBlindy's dotfiles! With extra Flakes.";
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
  inputs = {
      nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
      
      home-manager.url = "github:nix-community/home-manager";
      home-manager.inputs.nixpkgs.follows = "nixpkgs";  
      
      agenix.url = "github:ryantm/agenix";
      agenix-rekey.url = "github:oddlama/agenix-rekey";
      agenix-rekey.inputs.nixpkgs.follows = "nixpkgs";
      
      sops-nix.url = "github:Mic92/sops-nix";
      sops-nix.inputs.nixpkgs.follows = "nixpkgs";  
      
      disko.url = "github:nix-community/disko";
      disko.inputs.nixpkgs.follows = "nixpkgs";
      nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
      
      flake-utils.url = "github:numtide/flake-utils";
      flake-parts.url = "github:hercules-ci/flake-parts";
      
      nixos-unified.url = "github:srid/nixos-unified";
     # nixcord.url = "github:kaylorben/nixcord";
     # netboot.url = "path:./modules/iso";
     # auto-installer.url = "path:./modules/iso/auto-installer";
     
     
#°✶.•°••─→ MOBILE INPUTS ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
    librem-nixos.url = "github:zhaofengli/librem-nixos?ref=d7e3010";
    mobile-nixos.url = "github:mobile-nixos/mobile-nixos?ref=183ba24";
    mobile-nixos.flake = false;
    mobile-nixos-tools.url = "github:sergei-mironov/mobile-nixos-tools?ref=64db06a";
    mobile-nixos-tools.flake = false;
    nixpkgs-mobile.url = "github:nixos/nixpkgs?ref=6daa4a5c045d40e6eae60a3b6e427e8700f1c07f";
  };
  
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ OUTPUTS ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°  
  outputs = { self,  nixpkgs, nixos-facter-modules, sops-nix, disko, home-manager, nixpkgs-mobile, mobile-nixos, mobile-nixos-tools, librem-nixos, ... }:  
      let
          user = "pungkula";
          hostname = self.config.networking.hostName;
          system = "x86_64-linux";
          pkgs = import nixpkgs {
              inherit system;
              config.allowUnfree = true;
          }; 
          aarch64 = "aarch64-linux";
          pkgs-mobile = import nixpkgs-mobile {
              inherit aarch64;
              config.allowUnfree = true;
          }; 
          homeConfigFiles = { hostname, ... }: {
              home-manager.useGlobalPkgs = true;
              home-manager.backupFileExtension = "bak";
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit user hostname; };
              home-manager.users.${user} = import ./home-manager/home.nix;
          };
          lib = nixpkgs.lib;
      in {
          nixosConfigurations = {
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
#°✶.•°••─→ DESKTOP ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
              desktop = nixpkgs.lib.nixosSystem {
                  inherit system;
                  specialArgs = { inherit user; hostname = "desktop"; };
                  modules = [ ./hosts/desktop/configuration.nix   
                      disko.nixosModules.disko
                      homeConfigFiles
                      sops-nix.nixosModules.sops
                      home-manager.nixosModules.home-manager  
                      nixos-facter-modules.nixosModules.facter
                  ];
              };

#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
#°✶.•°••─→ PHONE ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
              phone = nixpkgs-mobile.lib.nixosSystem {
                  inherit aarch64;
                  modules = [ (import ./hosts/phone/configuration.nix user)
                      homeConfigFiles
                      sops-nix.nixosModules.sops
                      home-manager.nixosModules.home-manager  
                      (import "${mobile-nixos}/lib/configuration.nix" {
                          device = "pine64-pinephone";
                      })
                  ];
              };

#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
#°✶.•°••─→ NASTY ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
              nasty = nixpkgs.lib.nixosSystem {
                  inherit system;
                  specialArgs = { inherit user; hostname = "nasty"; };
                  modules = [ ./hosts/nasty/configuration.nix
                      homeConfigFiles
                      sops-nix.nixosModules.sops
                      home-manager.nixosModules.home-manager
                      nixos-facter-modules.nixosModules.facter
                  ];     
               }; 
               
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
#°✶.•°••─→ HOMIE ←── •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
              homie = nixpkgs.lib.nixosSystem {
                  inherit system;
                  specialArgs = { inherit user; hostname = "homie"; };
                  modules = [ ./hosts/homie/configuration.nix
                      disko.nixosModules.disko
                       homeConfigFiles
                      sops-nix.nixosModules.sops
                      home-manager.nixosModules.home-manager
                      nixos-facter-modules.nixosModules.facter
                  ];
              };              

#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
#°✶.•°••─→ TINY ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
              tiny = nixpkgs.lib.nixosSystem {
                  system = "aarch64-linux"; 
                  specialArgs = { inherit user; hostname = "laptop"; };
                  modules = [ ./hosts/laptop/configuration.nix      
                      disko.nixosModules.disko
                      homeConfigFiles
                      sops-nix.nixosModules.sops
                      home-manager.nixosModules.home-manager
                      nixos-facter-modules.nixosModules.facter
                  ];
              };              

#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
#°✶.•°••─→ LAPTOP ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
              laptop = nixpkgs.lib.nixosSystem {
                  inherit system;
                  specialArgs = { inherit user; hostname = "laptop"; };
                  modules = [ ./hosts/laptop/configuration.nix      
                      disko.nixosModules.disko
                      homeConfigFiles
                      sops-nix.nixosModules.sops
                      home-manager.nixosModules.home-manager
                      nixos-facter-modules.nixosModules.facter
                  ];
              };              

#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
#°✶.•°••─→ NiX BUILD! ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
              phone-image = 
                  (import "${mobile-nixos}/lib/eval-with-configuration.nix" {
                      configuration = [ (import ./hosts/phone/configuration.nix user) ];
                      device = "pine64-pinephone";
                      pkgs = nixpkgs-mobile.legacyPackages.${system};
                  }).outputs.disk-image;
              }; 
              
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
#°✶.•°••─→ SMART-WATCH ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
          
         # packages.x86_64-linux.smart-watch = {
       #       type = "app";
     #         program = "${self.packages.${system}.box3}/bin/box3";
     #     };

#°✶.•°••─→ BOX3 ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
       #   packages.x86_64-linux.box3 = nixpkgs.legacyPackages.${system}.box3;
      #    apps.x86_64-linux.box3 = {
     #         type = "app";
     #         program = "${self.packages.${system}.box3}/bin/box3";
    #      };

###########
          
          packages.x86_64-linux.box3 = nixpkgs.legacyPackages.${system}.box3;
          apps.x86_64-linux.box3 = {
              type = "app";
              program = "./home/bin/box3";
          };


#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
#°✶.•°••─→ bye: ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
    };
}

