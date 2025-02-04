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
      
      yubi-tocuh.url = "github:QuackHack-McBlindy/yubikey-touch-detector";
      
      disko.url = "github:nix-community/disko";
      disko.inputs.nixpkgs.follows = "nixpkgs";
      nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
      
      flake-utils.url = "github:numtide/flake-utils";
      flake-parts.url = "github:hercules-ci/flake-parts";
      
      nixos-unified.url = "github:srid/nixos-unified";
      
     # nixcord.url = "github:kaylorben/nixcord";
     # netboot.url = "path:./modules/iso";


#°✶.•°••─→ RPi4 INSTALLER ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
    pi-flake.url = "github:QuackHack-McBlindy/raspberry-pi-nix";
    pi-flake.flake = false;

#°✶.•°••─→ x86_64-linux AUTO INSTALLER ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
    auto-installer.url = "github:QuackHack-McBlindy/auto-installer-nixos";
    #auto-installer.flake = false;
          
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
  outputs = { self,  nixpkgs, nixos-facter-modules, sops-nix, disko, home-manager, nixpkgs-mobile, mobile-nixos, mobile-nixos-tools, librem-nixos, auto-installer, ... }:  
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
          
      #    rpi4b_sd_image = pi-flake.nixosConfigurations.rpi-4b.config.system.build.sdImage;
          auto_installer_iso = auto-installer.nixosConfigurations.installer.config.system.build.isoImage; 
         # phone_sd_image = mobile-nixos.nixosConfigurations.pinephone.config.system.build.sdImage

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
                  #    inputs.nixos-facter-modules.nixosModules.facter
                #      { config.facter.reportPath = ./hosts/desktop/facter.json; }            
                      disko.nixosModules.disko
                      homeConfigFiles
                      sops-nix.nixosModules.sops
                      home-manager.nixosModules.home-manager  
                      nixos-facter-modules.nixosModules.facter
                      
                      
                      ./modules/services/mosquitto.nix
                     # ./modules/services/zigbee2mqtt.nix
                      ./modules/virtualization/zigbee2mqtt.nix
                      ./modules/services/homepage.nix                      
                  ];
              };

#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
#°✶.•°••─→ PHONE ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
              phone = nixpkgs-mobile.lib.nixosSystem {
                  inherit aarch64;
                  specialArgs = { inherit user; hostname = "phone"; };
                  modules = [ ./hosts/phone/configuration.nix
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
               #       environment.systemPackages = with pkgs; [ mergerfs ];
               #       fileSystems."/Pool" = {
               #           fsType = "fuse.mergerfs";
              #            device = "/mnt/disks/*";
             #             options = ["cache.files=partial" "dropcacheonclose=true" "category.create=mfs"];
            #          };
                      
                      ./modules/virtualization/docker.nix
                      ./modules/virtualization/arr.nix
                      ./modules/virtualization/glue-shadow-socks.nix            
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
                      
                      ./modules/services/tts.nix
                      ./modules/services/openwakeword.nix
                      ./modules/services/faster-whisper.nix
                      ./modules/services/homepage.nix
                      ./modules/services/mosquitto.nix
                      ./modules/services/zigbee2mqtt.nix
                      ./modules/networking/caddy/caddy.nix
                      ./modules/networking/caddy.nix
                      ./modules/services/nginx/default.nix  
                      ./modules/networking/adguard.nix
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
                      
                     # networking.interfaces.eth0.ipv6.addresses = [
                     # {
                     #     address = "2001:db8:abcd:dead::1";
                     #     prefixLength = 64;
                     # }];
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
                      configuration = [ import ./hosts/phone/configuration.nix ];
                      device = "pine64-pinephone";
                      pkgs = nixpkgs.legacyPackages.${system};
                  }).outputs.disk-image;
              };
              
              installer = auto-installer.nixosConfigurations.installer;
              
             
          #    packages.aarch64-linux = {
         #         pi-sd-image = rpi4b_sd_image;
                 # phone-image = phone_sd_image;
         #     };
       #       packages.x86_64-linux = {
            #      installer-iso = auto_installer_iso;
        #     };
      

      
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
#°✶.•°••─→ bye: ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
    };
}

