#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
{ #°✶.•°••─→ FLAKE.NIX ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
  description = "Dotfiles & Nix OS Configuration Files.";
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
  inputs = {
      nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
      nixos-facter-modules.url = "github:numtide/nixos-facter-modules";

      
      home-manager.url = "github:nix-community/home-manager";
      home-manager.inputs.nixpkgs.follows = "nixpkgs";  
      
      agenix.url = "github:ryantm/agenix";
      agenix-rekey.url = "github:oddlama/agenix-rekey";
      agenix-rekey.inputs.nixpkgs.follows = "nixpkgs";
      
      sops-nix.url = "github:Mic92/sops-nix";
      sops-nix.inputs.nixpkgs.follows = "nixpkgs";  
      
      disko.url = "github:nix-community/disko";
      disko.inputs.nixpkgs.follows = "nixpkgs";
   
      flake-utils.url = "github:numtide/flake-utils";
      flake-parts.url = "github:hercules-ci/flake-parts";
      
      nixos-unified.url = "github:srid/nixos-unified";
     # nixcord.url = "github:kaylorben/nixcord";
     # netboot.url = "path:./modules/iso";
     # auto-installer.url = "path:./modules/iso/auto-installer";
   
  };
    
  outputs = { self, nixpkgs, sops-nix, home-manager, ... }: 
      let
          user = "pungkula";
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
          nixosConfigurations = {
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
#°✶.•°••─→ DESKTOP ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
              desktop = nixpkgs.lib.nixosSystem {
                  inherit system;
                  specialArgs = { inherit user; hostname = "desktop"; };
                  modules = [ ./hosts/desktop/configuration.nix
                      homeConfigFiles
                      sops-nix.nixosModules.sops
                      home-manager.nixosModules.home-manager
                      
                      ./modules/security.nix
                      ./modules/sshd/sshd.nix
                      ./modules/programs/thunar.nix
                      ./modules/networking/samba.nix
                      ./modules/nixos/gnome-background.nix
                      ./modules/nixos/default-apps.nix
                      ./modules/virtualization/docker.nix
                      ./modules/virtualization/vm.nix
                #      ./modules/services/nginx/default.nix

                  ];
              };

#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
#°✶.•°••─→ LAPTOP ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
              laptop = nixpkgs.lib.nixosSystem {
                  inherit system;
                  specialArgs = { inherit user; hostname = "laptop"; };
                  modules = [ ./hosts/laptop/configuration.nix
                      homeConfigFiles
                      sops-nix.nixosModules.sops
                      home-manager.nixosModules.home-manager
                      
                      ./modules/security.nix
                      ./modules/sshd/sshd.nix
                     # ./modules/networking/samba.nix
                      ./modules/programs/thunar.nix
                      ./modules/nixos/gnome-background.nix
                      ./modules/nixos/default-apps.nix
                      ./modules/networking/iwd.nix
                      
                  ];
              };              

#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
#°✶.•°••─→ HOMIE ←── •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
      


          }; 
    };
}





