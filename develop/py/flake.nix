{
  description = "Template for building Python scripts as packages.";
  inputs.nixpkgs.url = "nixpkgs/nixos-21.05";

  outputs = { self, nixpkgs }:
    let
      # TODO Name your script.
      SCRIPTNAME = "p";
      
      # TODO Define your imports and script here
      SCRIPTCONTENT =
        ''
        import os
        import re
        import sys
        import time
        import random
        import subprocess
        import difflib
        import string
        import secrets
        import logging
        import tempfile
        import requests
        from difflib import get_close_matches
        from urllib.parse import urlencode
        from dotenv import load_dotenv
        load_dotenv()
        #import pyaudio
        import wave
        import io
        import colorlog
        import logger

        def main():
            if len(sys.argv) < 2:
                print("Usage: p <script_path> [arguments...]")
                sys.exit(1)

            script_path = sys.argv[1]  # The first argument is the script path

            if not os.path.isfile(script_path):
                print(f"Error: Script '{script_path}' not found.")
                sys.exit(1)

            args = sys.argv[2:]  # Remaining arguments to pass to the script
            python_bin = sys.executable  # Path to the current Python interpreter

            # Execute the script with the provided arguments
            subprocess.run([python_bin, script_path] + args, check=True)
        if __name__ == "__main__":
            main()
        '';

      lastModifiedDate = self.lastModifiedDate or self.lastModified or "19700101";
      version = builtins.substring 0 8 lastModifiedDate;

      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });

    in

    {
      packages = forAllSystems (system:
        let pkgs = nixpkgsFor.${system}; in {
          ${SCRIPTNAME} = pkgs.stdenv.mkDerivation {
            name = "${SCRIPTNAME}-${version}";
            src = pkgs.runCommand "source" {} "mkdir -p $out; echo '${SCRIPTCONTENT}' > $out/${SCRIPTNAME}.py";
            # TODO Insert Dependencies here!
            buildInputs = [ pkgs.python3 pkgs.python3Packages.requests pkgs.python3Packages.colorlog pkgs.python3Packages.python-dotenv pkgs.python3Packages.pyaudio ];
            
            # TODO Insert Dependencies once again below
            installPhase = ''
              mkdir -p $out/bin
              echo "#!${pkgs.python3.withPackages (ps: [ ps.colorlog ps.pyaudio ps.requests ps.python-dotenv ])}/bin/python3" > $out/bin/${SCRIPTNAME}
              cat $src/${SCRIPTNAME}.py >> $out/bin/${SCRIPTNAME}
              chmod +x $out/bin/${SCRIPTNAME}
            '';
          };
        });

      defaultPackage = forAllSystems (system: self.packages.${system}.${SCRIPTNAME});
    };

}
