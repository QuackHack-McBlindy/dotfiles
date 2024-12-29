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
      flake-utils.url = "github:numtide/flake-utils";
      flake-parts.url = "github:hercules-ci/flake-parts";
      nixos-unified.url = "github:srid/nixos-unified";
      nixcord.url = "github:kaylorben/nixcord";
  };
  outputs = { self, nixpkgs, sops-nix, disko, home-manager, ... }: 
      let
          user = "pungkula";
          hostname = self.networking.hostName;
          system = "x86_64-linux";
          dotfiles = "/home/pungkula/dotfiles";
          mods = "${dotfiles}/modules";
          pkgs = import nixpkgs {
              inherit system;
              config.allowUnfree = true;
          };
          homeConfigFiles = {
              home-manager.useGlobalPkgs = true;
              home-manager.backupFileExtension = "bak";
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit user hostname; };
              home-manager.users.${user} = import "${dotfiles}/home-manager/home.nix";
          };
          lib = nixpkgs.lib;
      in {
          nixosConfigurations = {
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
#°✶.•°••─→ DESKTOP ←── (Water Cool Contest Build) •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
              desktop = nixpkgs.lib.nixosSystem {
                  inherit system;
                  specialArgs = { inherit user dotfiles hostname mods; };
                  modules = [ ./hosts/desktop/configuration.nix
                      homeConfigFiles
                      sops-nix.nixosModules.sops
                      disko.nixosModules.disko
                      home-manager.nixosModules.home-manager
                      "${mods}/services/syslogd.nix"
                      "${mods}/programs/thunar.nix"
                      "${mods}/hardware/pam.nix"
                      "${mods}/nixos/nix.nix"
                      "${mods}/nixos/users.nix"
                      "${mods}/nixos/i18n.nix"    
                      "${mods}/nixos/fonts/default.nix"
                      "${mods}/virtualization/docker.nix"
                      "${mods}/virtualization/vm.nix"         
                      ./modules/services/ssh.nix 
                  #    "${toString ./modules/services/firefox-syncserver.nix}"
                     # ./modules/services/avahi-client.nix
                    #  ./modules/services/dns.nix  
                   #   ./modules/security.nix
                  ];
             };

#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
#°✶.•°••─→ PHONEY  ←── (PinePhone) •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•
            phoney = nixpkgs.lib.nixosSystem {
                system = "aarch64-linux";
                specialArgs = {inherit user;};
                modules = [ ./hosts/phoney/configuration.nix ];
            };
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
#°✶.•°••─→ LAPPY  ←── (Crappy Laptop) •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•
            lappy = nixpkgs.lib.nixosSystem {
                inherit system;
                specialArgs = { inherit user; };
                modules = [ ./hosts/lappy/configuration.nix
                    homeConfigFiles
                    sops-nix.nixosModules.sops
                    disko.nixosModules.disko
                    home-manager.nixosModules.home-manager
                    ./modules/services/ssh.nix
               #  ./modules/hardware/suspend-on-low-power.nix
                ];
            };
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
#°✶.•°••─→ HOMIE ←── (Home Automation Fanless Server) •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•
        # ./modules/services/home-assistant/default.nix
        # ./modules/services/ssh.nix
        # ./modules/shell/bash.nix
        # ./modules/services/firefox-syncserver.nix
        # ./modules/services/avahi-client.nix
        # ./modules/services/dns.nix 
        
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
#°✶.•°••─→ TiNY ←── (Raspberry Pi Raid 1 NAS) •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°••°•.✶°°••

#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
#°✶.•°••─→ NASTY ←── (Mass Storage NAS) •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°••°•.✶°°•••.✶°°•



#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
#°✶.•°••─→ DESKTOP ←── (Water Cool Contest Build) •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
              newHost = nixpkgs.lib.nixosSystem {
                  inherit system;
                  specialArgs = { inherit user; };
                  modules = [ # ./hosts/newHost/configuration.ni
                      homeConfigFiles
                      sops-nix.nixosModules.sops
                      disko.nixosModules.disko
                      ./hosts/lappy/configuration.nix
                      ./hosts/lappy/hardware-configuration.nix
                     # ./disk-config.nix
                   #   ./modules/services/ssh.nix 
                    #  ./modules/services/firefox-syncserver.nix
                    #  ./modules/services/avahi-client.nix
                     # ./modules/services/dns.nix  
                    #  ./modules/security.nix

                      {
                        disko.devices = {
                          disk.disk1 = {
                            device = "/dev/sda";
                            type = "disk";
                            content = {
                              type = "gpt";  # Using GPT as the disklabel type
                             partitions = {
                                boot = {
                                  name = "boot";
                                  size = "512M";  # Boot partition size
                                 type = "8300";  # Type for Linux filesystem (MBR)
                                 content = {
                                    type = "filesystem";
                                    format = "vfat";
                                    mountpoint = "/boot";
                                  };
                                };
                                root = {
                                  name = "root";
                                  size = "100%";  # The remaining space
                                  content = {
                                   type = "filesystem";
                                    format = "ext4";
                                    mountpoint = "/";
                                    mountOptions = [ "defaults" ];
                                  };
                                };
                              };
                            };
                          };
                        };
                      } 
                    
                  ];
                  
                          
              };

          }; 
    };
}





