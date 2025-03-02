{
  description = "Python package for speech synthesis using Piper";
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });

      mkPackage = system:
        let
          pkgs = nixpkgsFor.${system};
          pythonEnv = pkgs.python3.withPackages (ps: [
            ps.numpy
            ps.sounddevice
            ps.requests
            ps.pysoundfile
            ps.torch
            ps.langid
          ]);
        in
        pkgs.stdenv.mkDerivation {
          name = "say";
          src = ./src;
          buildInputs = [
            pythonEnv
            pkgs.piper-tts  # Use system package for Piper
          ];
          propagatedBuildInputs = [ pythonEnv ];

          installPhase = ''
            mkdir -p $out/bin
            echo "#!${pythonEnv}/bin/python3" > $out/bin/say
            cat $src/say.py >> $out/bin/say
            chmod +x $out/bin/say
          '';

          meta = {
            description = "Python script for text-to-speech using Piper (via Wyoming)";
            license = pkgs.lib.licenses.mit;
            maintainers = [ "your-name" ];
          };
        };

    in {
      packages = forAllSystems (system: {
        say = mkPackage system;
      });

      defaultPackage = forAllSystems (system: self.packages.${system}.say);
    };
}

