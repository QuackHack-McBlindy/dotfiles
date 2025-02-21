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
      
      caddy-duckdns.url = "github:QuackHack-McBlindy/nix-caddy-duckdns";
      
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
  outputs = { self, flake-utils, nixpkgs, nixos-facter-modules, sops-nix, disko, home-manager, nixpkgs-mobile, mobile-nixos, mobile-nixos-tools, librem-nixos, auto-installer, ... }: 
      let
          caddy-duckdns = caddy-duckdns.packages.x86_64-linux.caddy;
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
              home-manager.extraSpecialArgs = { inherit user; inherit hostname; };
              home-manager.users.${user} = import ./home-manager/home.nix;
          };
          lib = nixpkgs.lib;
      in {
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
#°✶.•°••─→ SETUP / KEY DISTRIBUTION ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
          apps.x86_64-linux.setup = {
              type = "app";
              program = "${pkgs.writeShellScriptBin "setup" ''        
                  set -x
                  systemctl --user start pcscd.service || sudo systemctl start pcscd.service
                  export PATH=${
                      pkgs.lib.makeBinPath [
                          pkgs.age
                          pkgs.curl
                          pkgs.git
                          pkgs.rage
                          pkgs.age-plugin-yubikey
                          pkgs.pcscliteWithPolkit
                          pkgs.yubico-pam
                          pkgs.coreutils 
                          pkgs.wget     
                          pkgs.sudo     
                      ]
                  }      

                  curl https://m0ln.duckdns.org/Secrets/Keys/age@desktop -o /tmp/age@desktop
                  curl https://m0ln.duckdns.org/Secrets/Keys/id_ed25519@desktop -o /tmp/ssh@desktop

                  decrypt() {
                      local filepath="$1"
                      age-plugin-yubikey --identity --slot 1 > /tmp/yubikey-identity.txt
                      OUTPUT=$(rage -d "$filepath" -i /tmp/yubikey-identity.txt)
                  }         

                  mkdir -p /var/lib/sops-nix
                  mkdir -p /home/pungkula/.ssh

                  decrypt /tmp/age@desktop
                  echo "$OUTPUT" | sudo tee /var/lib/sops-nix/age.age

                  decrypt /tmp/ssh@desktop
                  echo "$OUTPUT" | sudo tee /home/pungkula/.ssh/id_ed25519

                  git clone https://github.com/QuackHack-McBlindy/dotfiles.git /home/pungkula/dotfiles
                  git clone git@github.com:QuackHack-McBlindy/dotfiles.git /home/pungkula/dotfiles
                  
                  rm -f /tmp/age@desktop /tmp/ssh@desktop /tmp/yubikey-identity.txt
                  echo " "
                  echo " "
                  echo " "
                  echo "🚀🚀🚀🚀 ✨ "
                  echo "✨✨ Successfully decrypted and distributed encryption & SSH keys!"
                  echo "NEXT STEP: 🚀🚀🚀"
                  echo "1:"
                  echo "sudo nixos-rebuild switch --flake /home/pungkula/dotfiles#$HOSTNAME --show-trace"
                  echo "2:"
                  echo "sudo bash facter"
                  
              ''}/bin/setup";
          };
          
          nixosConfigurations = {
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
#°✶.•°••─→ DESKTOP ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
              desktop = nixpkgs.lib.nixosSystem {
                  inherit system;
                  specialArgs = { inherit user caddy-duckdns; hostname = "desktop"; };
                  modules = [ ./hosts/desktop/configuration.nix   
                  #    nixos-facter-modules.nixosModules.facter
                   #   { config.facter.reportPath = ./hosts/desktop/facter.json; }            
                      disko.nixosModules.disko
                      homeConfigFiles
                      sops-nix.nixosModules.sops
                      home-manager.nixosModules.home-manager  
                      nixos-facter-modules.nixosModules.facter
    
               #       ./modules/nixos/mount.nix
                      ./modules/services/loki.nix
                      ./modules/services/vaultwarden.nix

                  #    ./modules/services/mosquitto.nix
                     # ./modules/services/zigbee2mqtt.nix
                      ./modules/virtualization/home-assistant.nix
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
                  #    inputs.nixos-facter-modules.nixosModules.facter
                #      { config.facter.reportPath = ./hosts/desktop/facter.json; }            
                      disko.nixosModules.disko
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
                      
               #       ./modules/services/tts.nix
                #      ./modules/services/openwakeword.nix
                #      ./modules/services/faster-whisper.nix
               #       ./modules/services/homepage.nix
                      ./modules/services/mosquitto.nix
                      ./modules/services/zigbee2mqtt.nix
               #       ./modules/networking/caddy/caddy.nix
               #       ./modules/networking/caddy.nix
                #      ./modules/services/nginx/default.nix  
                 #     ./modules/networking/adguard.nix
                      ./modules/virtualization/home-assistant.nix
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
              
              devShells."x86_64-linux".default = nixpkgs.legacyPackages."x86_64-linux".mkShell {
                 # packages = [ clan-core.packages."x86_64-linux".clan-cli ];
                  packages = [ pkgs.python3 pkgs.python3Packages.requests pkgs.python3Packages.python-dotenv pkgs.python312Packages.sh ];
              };
              
              
          

      #        apps.default = config.apps.setup;

#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
#°✶.•°••─→ bye: ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
    };
    
}

