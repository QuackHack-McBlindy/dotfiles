# dotfiles/modules/system/crossEnv.nix
{ 
  config,
  lib,
  pkgs,
  ...
} : {
    config = lib.mkIf (lib.elem "crossEnv" config.this.host.modules.system) {
        nixpkgs.config.packageOverrides = pkgs: {
            myCrossEnv = pkgs.stdenv.mkDerivation {
                name = "my-cross-env";
                buildInputs = [
                    pkgs.glib
                    pkgs.pkg-config
                    pkgs.cmake
                ];
            };
        };
        
    };}
