#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
{ #°✶.•°••─→ FLAKE.NIX ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
  description = "Dotfiles & Nix OS Configuration Files.";
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
   
  };
    
  outputs = { self,  nixpkgs, sops-nix, disko, home-manager, ... }: 
      let
          user = "pungkula";
          hostname = self.config.networking.hostName;
          system = "x86_64-linux";
          pkgs = import nixpkgs {
              inherit system;
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
      #    defaultPackage.x86_64-linux = pkgs.callPackage ./modules/iso/auto-installer/flake.nix {};
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
                  ];
              };              

#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
#°✶.•°••─→ HOMIE ←── •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
   #           homie = nixpkgs.lib.nixosSystem {
   #               inherit system;
   #               specialArgs = { inherit user; hostname = "homie"; };
   #               modules = [ ./hosts/homie/configuration.nix
   #                   disko.nixosModules.disko
    #                   homeConfigFiles
    #                  sops-nix.nixosModules.sops
    #                  home-manager.nixosModules.home-manager
    #              ];
    #          };              



#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
#°✶.•°••─→ NASTY ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
        #      nasty = nixpkgs.lib.nixosSystem {
       #           inherit system;
        #          specialArgs = { inherit user; hostname = "nasty"; };
             #     modules = [ ./hosts/nasty/configuration.nix
        #              homeConfigFiles
        #              sops-nix.nixosModules.sops
         #             home-manager.nixosModules.home-manager
                       # Create Pool
             #         fileSystems."/pool" = { 
             #             fsType = "fuse.mergerfs";
             #             device = "/mnt/disks/*";  # Throw it all in the Pool
            #              options = ["cache.files=partial" "dropcacheonclose=true" "category.create=mfs"];
             #         };    




 # };
   #               ];
  #            };              




    
    
    
          }; 
    };
}





