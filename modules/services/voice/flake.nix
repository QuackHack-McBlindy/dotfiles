{
  description = "Python development environment flake for Nix/NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; # Specify the version if needed
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux"; # Adjust according to your system
      pkgs = import nixpkgs { inherit system; };
      lib = pkgs.lib;
    in {
      # Home Manager or NixOS configuration for Python development
      homeManagerConfigurations.default = pkgs.lib.mkIf pkgs.stdenv.isLinux (import ./dev-python.nix { inherit pkgs lib; });

      # DevShell for on-demand usage
      devShell.${system} = pkgs.mkShell {
        buildInputs = [

          pkgs.python312Packages.cryptography
          pkgs.python312Packages.unicode-rbnf
          pkgs.python312Packages.pyyaml
          pkgs.python312Packages.pydantic
          pkgs.python312Packages.uvicorn
          pkgs.python312Packages.fastapi
          pkgs.python312Packages.colorlog
      #    pkgs.python312Packages.yubico
      #    pkgs.python312Packages.fido2
     #     pkgs.python312Packages.httpx
      #    pkgs.python312Packages.requests
       #   pkgs.python312Packages.setuptools
          pkgs.python312Packages.webauthn
          pkgs.python312Packages.unicode-rbnf
          pkgs.python312Packages.invoke
          pkgs.python312Packages.pyaml
          pkgs.python312Packages.deploykit
          pkgs.python312Packages.psutil
          pkgs.python312Packages.pyaudio
         # pkgs.python312Packages.python-multipart
          pkgs.python312Packages.cmake
         # pkgs.xorg.libXinerama
          
          pkgs.cmake
          pkgs.xorg.x11perf
          pkgs.gcc 
          pkgs.gnumake
          pkgs.liboqs
      #    pkgs.python312Packages.ipython
          pkgs.python312Packages.setuptools
       #   pkgs.python312Packages.pybind11
          #pkgs.python312Packages.hyperscan
          pkgs.python312Packages.cython
    #      pkgs.python312Packages.flask
        ];

        shellHook = ''
          alias kill="lsof -t -i:43334 | xargs kill -9"
          alias py="python"
          alias ipy="ipython --no-banner"
          alias ipylab="ipython --pylab=qt5 --no-banner"

          # XDG environment variables if needed
          export PYTHONSTARTUP="/home/pungkula/duckOS/flake/bin/pythonrc"
          export PYTHON_HISTORY_FILE="$XDG_CONFIG_HOME/python/history"
          export JUPYTER_CONFIG_DIR="$XDG_CONFIG_HOME/jupyter"
          export IPYTHONDIR="$XDG_CONFIG_HOME/ipython"
        '';
      };

      # Default output if needed
      defaultPackage.${system} = self.devShell.${system};
    };
}

