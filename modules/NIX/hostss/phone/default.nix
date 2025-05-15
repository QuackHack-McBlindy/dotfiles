{ pkgs ?  import <nixpkgs> {}
, stdenv ? pkgs.stdenv
} :
let
  local = rec {
    callPackage = pkgs.lib.callPackageWith collection;

    collection = rec {
      shell = pkgs.mkShell {
        name = "shell";
        buildInputs = with pkgs; [ weston waypipe ];
        shellHook = with pkgs; ''
          if test -f ./env.sh ; then
            . ./env.sh
          fi
        '';
      };
    };
  };
in
  local.collection

