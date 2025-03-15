{
  description = "Python package for speech synthesis with Piper";
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
            ps.sounddevice
            ps.requests
            ps.python-dotenv
          ]);
        in
        pkgs.stdenv.mkDerivation {
          name = "tv";
          src = ./src;
          buildInputs = [ pythonEnv ];
          propagatedBuildInputs = [ pythonEnv ];

          installPhase = ''
            mkdir -p $out/bin
            echo "#!${pythonEnv}/bin/python3" > $out/bin/tv
            cat $src/tv.py >> $out/bin/tv
            chmod +x $out/bin/tv
          '';

          meta = {
            description = "ADB Controller";
            license = pkgs.lib.licenses.mit;
            maintainers = [ "QuackHack-McBlindy" ];
          };
        };

    in {
      packages = forAllSystems (system: {
        tv = mkPackage system;
      });

      defaultPackage = forAllSystems (system: self.packages.${system}.tv);
    };
}

