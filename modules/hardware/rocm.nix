#
# This file is auto-generated from "README.org"
#
# Nix flakes are still an experimental feature, so you need the following in NixOS configuration to enable it.
#
#{
#  nix = {
#    package = pkgs.nixFlakes;
#    extraOptions = ''
#      experimental-features = nix-command flakes
#    '';
#  };
#}


{
  description = "QuackHack-McBlindy's packages and NixOS/home-manager configurations";

  inputs = {
    nixpkgs = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixpkgs-unstable";
    };

    <<flake-inputs>>
  };

  outputs = { self, ... }@inputs:
    let
      # Flakes are evaluated hermetically, thus are unable to access
      # host environment (including looking up current system).
      #
      # That's why flakes must explicitly export sets for each system
      # supported.
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];

      # genAttrs applies f to all elements of a list of strings, and
      # returns an attrset { name -> result }
      #
      # Useful for generating sets for all systems or hosts.
      genAttrs = list: f: inputs.nixpkgs.lib.genAttrs list f;

      # Generate pkgs set for each system. This takes into account my
      # nixpkgs config (allowUnfree) and my overlays.
      pkgsBySystem =
        let mkPkgs = system: import inputs.nixpkgs {
              inherit system;
              overlays = self.overlays.${system};
              config = { allowUnfree = true; input-fonts.acceptLicense = true; };
            };
        in genAttrs systems mkPkgs;

      # genHosts takes an attrset { name -> options } and calls mkHost
      # with options+name. The result is accumulated into an attrset
      # { name -> result }.
      #
      # Used in NixOS and Home Manager configurations.
      genHosts = hosts: mkHost:
        genAttrs (builtins.attrNames hosts) (name: mkHost ({ inherit name; } // hosts.${name}));

      # merges a list of attrsets into a single attrset
      mergeSections = inputs.nixpkgs.lib.foldr inputs.nixpkgs.lib.mergeAttrs {};

    in mergeSections [
     # <<flake-outputs-nixos>>
     
     # <<flake-outputs-home-manager>>
     
     # <<flake-outputs-packages>>
    
     # <<flake-outputs-overlays>>
       
     # <<flake-outputs-nix-darwin>>
    
  ];
}


