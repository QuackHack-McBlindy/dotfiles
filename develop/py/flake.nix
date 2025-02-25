{
  description = "Template for building Python scripts as packages.";
  inputs.nixpkgs.url = "nixpkgs/nixos-21.05";

  outputs = { self, nixpkgs }:
    let
      # TODO Name your script.
      SCRIPTNAME = "satellite";
      
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
        import webrtc

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
            buildInputs = [ pkgs.python3Packages.webrtc_noise_gain pkgs.python3 pkgs.python3Packages.requests pkgs.python3Packages.colorlog pkgs.python3Packages.python-dotenv pkgs.python3Packages.pyaudio ];
            
            # TODO Insert Dependencies once again below
            installPhase = ''
              mkdir -p $out/bin
              echo "#!${pkgs.python3.withPackages (ps: [ ps.webrtc_noise_gain ps.colorlog ps.pyaudio ps.requests ps.python-dotenv ])}/bin/python3" > $out/bin/${SCRIPTNAME}
              cat $src/${SCRIPTNAME}.py >> $out/bin/${SCRIPTNAME}
              chmod +x $out/bin/${SCRIPTNAME}
            '';
          };
        });

      defaultPackage = forAllSystems (system: self.packages.${system}.${SCRIPTNAME});
    };

}
