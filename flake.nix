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
          hostname = self.networking.hostName;
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
                      ./modules/networking/default.nix 
                      ./modules/nixos/users.nix
                      ./modules/nixos/nix.nix
                      ./modules/nixos/fonts/default.nix
                      ./modules/nixos/i18n.nix
                      ./modules/nixos/pipewire.nix
                      ./modules/security.nix
                      ./modules/services/ssh.nix
                      ./modules/services/syslogd.nix
                      ./modules/services/syslog.nix
                      ./modules/programs/thunar.nix
                      ./modules/networking/samba.nix
                      ./modules/nixos/gnome-background.nix
                      ./modules/nixos/default-apps.nix
                      ./modules/virtualization/docker.nix
                      ./modules/virtualization/vm.nix
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
                      ./modules/nixos/users.nix
                      ./modules/nixos/nix.nix
                      ./modules/nixos/fonts/default.nix
                      ./modules/nixos/i18n.nix
                      ./modules/nixos/pipewire.nix     
                      ./modules/security.nix
                      ./modules/services/ssh.nix
                      ./modules/services/syslog.nix
                      ./modules/networking/samba.nix
                      ./modules/programs/thunar.nix
                      ./modules/nixos/gnome-background.nix
                      ./modules/nixos/default-apps.nix
                      ./modules/networking/iwd.nix
                      ./modules/networking/default.nix 
                  ];
              };              

#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
#°✶.•°••─→ HOMIE ←── •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
      

          
          }; 
    };
}





