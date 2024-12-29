#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
{ #°✶.•°••─→ FLAKE.NIX ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
    description = "QuackHack-McBlindy's Nix OS Configuration Dotfiles with Flakes.";
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
    inputs = {
        # Principle inputs (updated by `nix run .#update`)
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        home-manager.url = "github:nix-community/home-manager";
        home-manager.inputs.nixpkgs.follows = "nixpkgs";

        agenix.url = "github:ryantm/agenix";
        sops-nix.url = "github:Mic92/sops-nix";
        sops-nix.inputs.nixpkgs.follows = "nixpkgs";
        disko.url = "github:nix-community/disko";
        disko.inputs.nixpkgs.follows = "nixpkgs";

        flake-parts.url = "github:hercules-ci/flake-parts";
        nixos-unified.url = "github:srid/nixos-unified";
    };

    #outputs = inputs@{ self, ... }:
    #    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
            #inherit inputs; root = ./.;
            
    outputs = { self, inputs, nixpkgs, flake-parts, nixos-unified, home-manager, disko, ... }:

    # Ensure flake-parts is correctly handled
        inputs.flake-parts.lib.mkFlake { inherit inputs; } {
            inherit inputs; 
            
            systems = [ "x86_64-linux" "aarch64-linux" ];
     #       imports = [ inputs.nixos-unified.flakeModules.default ];

            flake =
                let
                    user = "pungkula";
                in
                {
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
#°✶.•°••─→ DESKTOP ←── (Water Cool Contest Build) •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
                    nixosConfigurations."desktop" =
                        self.nixos-unified.lib.mkLinuxSystem
                            { home-manager = true; }
                            {
                                nixpkgs.hostPlatform = "x86_64-linux";
                                imports = [ ./hosts/desktop/configuration.nix
                                    ./modules/services/ssh.nix 
                                    ./modules/services/firefox-syncserver.nix
                                    ./modules/services/avahi-client.nix
                                    ./modules/services/dns.nix   
                                    {
                                        home-manager.users.${user} = {
                                            imports = [ ./home-manager/home.nix ];
                                        };
                                    }
                                ];
                            };
                            
                            
####################### NEW HOST

                    nixosConfigurations."newHost" =
                        self.nixos-unified.lib.mkLinuxSystem
                            { home-manager = true; }
                            {
                                nixpkgs.hostPlatform = "x86_64-linux";
                                imports = [ ./hosts/lappy/configuration.nix
                                    ./modules/services/ssh.nix 
                                    ./modules/services/firefox-syncserver.nix
                                    ./modules/services/avahi-client.nix
                                    ./modules/services/dns.nix   
                                    ./modules/disk-config.nix   
                                    {
                                        home-manager.users.${user} = {
                                            imports = [ ./home-manager/home.nix ];
                                        };
                                    }
                                ];
                            };

#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
#°✶.•°••─→ PHONEY  ←── (PinePhone) •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•
                    nixosConfigurations."phoney" =
                        self.nixos-unified.lib.mkLinuxSystem
                            { home-manager = true; }
                            {
                                nixpkgs.hostPlatform = "aarch64-linux";
                                imports = [ ./hosts/phoney/configuration.nix
                                    {
                                        home-manager.users.${user} = {
                                            imports = [ ./home-manager/home.nix ];
                                        };
                                    }
                                ];
                            };
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
#°✶.•°••─→ LAPPY  ←── (Crappy Laptop) •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•
                    nixosConfigurations."lappy" =
                        self.nixos-unified.lib.mkLinuxSystem
                            { home-manager = true; }
                            {
                                nixpkgs.hostPlatform = "x86_64-linux";
                                imports = [ ./hosts/lappy/configuration.nix
                                    ./modules/services/ssh.nix
                                    {
                                        home-manager.users.${user} = {
                                            imports = [ ./home-manager/home.nix ];
                                        };
                                    }
                                ];
                            };
                };
        };
}

