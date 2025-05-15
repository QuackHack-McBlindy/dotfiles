{
  description = "Python development environment flake for Nix/NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; # Specify the version if needed
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux"; 
      pkgs = import nixpkgs { inherit system; };
      lib = pkgs.lib;
    in {
      homeManagerConfigurations.default = pkgs.lib.mkIf pkgs.stdenv.isLinux (import ./dev-python.nix { inherit pkgs lib; });

      devShell.${system} = pkgs.mkShell {
        buildInputs = [
        # Python deps
          pkgs.python312Packages.cryptography
          pkgs.python312Packages.unicode-rbnf
          pkgs.python312Packages.pyyaml
          pkgs.python312Packages.pydantic
          pkgs.python312Packages.uvicorn
          pkgs.python312Packages.fastapi
          pkgs.python312Packages.colorlog
          pkgs.python312Packages.python-dotenv
          pkgs.python312Packages.requests

        # Build tools        
          pkgs.cmake
          pkgs.xorg.x11perf
          pkgs.gcc 
          pkgs.gnumake
          pkgs.python312Packages.ipython
          pkgs.python312Packages.setuptools
          pkgs.python312Packages.cython
        ];

        shellHook = ''
          alias kill="lsof -t -i:43334 | xargs kill -9"
          alias py="python"
          alias ipy="ipython --no-banner"
          alias ipylab="ipython --pylab=qt5 --no-banner"

          export PYTHONSTARTUP="/home/pungkula/duckOS/flake/bin/pythonrc"
          export PYTHON_HISTORY_FILE="$XDG_CONFIG_HOME/python/history"
          export JUPYTER_CONFIG_DIR="$XDG_CONFIG_HOME/jupyter"
          export IPYTHONDIR="$XDG_CONFIG_HOME/ipython"
        '';
      };

      defaultPackage.${system} = self.devShell.${system};
    };
}

