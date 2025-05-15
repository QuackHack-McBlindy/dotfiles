{
  description = "Healthchecks API server";
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
            ps.requests
            ps.fastapi
            ps.uvicorn
            ps.psutil
          ]);
        in
        pkgs.stdenv.mkDerivation {
          name = "api";
          src = ./src;
          buildInputs = [
            pythonEnv
            pkgs.psutils
            pkgs.smartmontools
            pkgs.python312Packages.uvicorn
            pkgs.python312Packages.fastapi
            pkgs.python312Packages.psutil
          ];
          propagatedBuildInputs = [ pythonEnv ];

          installPhase = ''
            mkdir -p $out/bin
            echo "#!${pythonEnv}/bin/python3" > $out/bin/api
            cat $src/api.py >> $out/bin/api
            chmod +x $out/bin/api
          '';

          meta = {
            description = "Python script for text-to-speech using Piper (via Wyoming)";
            license = pkgs.lib.licenses.mit;
            maintainers = [ "your-name" ];
          };
        };

    in {
      packages = forAllSystems (system: {
        api = mkPackage system;
      });

      defaultPackage = forAllSystems (system: self.packages.${system}.api);
    };
}

