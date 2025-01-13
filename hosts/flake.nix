{
  description = "Minimal NixOS installation media";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  outputs = { self, nixpkgs }: {
    nixosConfigurations = {
      nasty = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ({ pkgs, modulesPath, ... }: {
            imports = [
              (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix") 
              ./nasty/configuration.nix 
            ];
            environment.systemPackages = [ pkgs.neovim ];
          })
        ];
      };
    };


  #  nixosConfigurations = {
  #    tiny = nixpkgs.lib.nixosSystem {
  #      system = "x86_64-linux";
  #      modules = [
  #        ({ pkgs, modulesPath, ... }: {
  #          imports = [
  #            (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix") 
  #            ./nasty/configuration.nix 
  #          ];
  #          environment.systemPackages = [ pkgs.neovim ];
  #        })
  #      ];
  #    };
  #  };
  #};




  };
}
