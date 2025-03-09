{
  description = "Healthchecks API server";

  # Define where nixpkgs comes from
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, ... }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });

      # Function to create the package for health-api
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
          name = "health-api";
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
            echo "#!${pythonEnv}/bin/python3" > $out/bin/health-api
            cat $src/health-api.py >> $out/bin/health-api
            chmod +x $out/bin/health-api
          '';

          meta = {
            description = "Python script for health checks API";
            license = pkgs.lib.licenses.mit;
            maintainers = [ "your-name" ];
          };
        };
    in {
      # Define system packages for health-api
      packages = forAllSystems (system: {
        health-api = mkPackage system;
      });

      defaultPackage = forAllSystems (system: self.packages.${system}.health-api);

      # NixOS module for configuring the service and options
      nixosModules = [
        {
          options = {
            # Enable the healthchecks service
            services.healthchecks.enable = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Whether to enable the healthchecks API service.";
            };
            # Hostname configuration for the healthchecks API
            services.healthchecks.hostName = lib.mkOption {
              type = lib.types.str;
              default = "localhost";  # Default hostname, can be overridden
              description = "The hostname for the healthchecks API server.";
            };
          };

          config = let
            # Generate the package for the system
            healthApiPackage = mkPackage config.system;
          in {
            # Create the systemd service if the healthchecks service is enabled
            systemd.services.healthchecks = lib.mkIf config.services.healthchecks.enable {
              description = "Healthchecks API Service";
              wantedBy = [ "multi-user.target" ];
              serviceConfig.ExecStart = "${healthApiPackage}/bin/health-api";
              serviceConfig.Restart = "always";
            };

            # Add the health-api package to system packages if the service is enabled
            environment.systemPackages = lib.mkIf config.services.healthchecks.enable [
              healthApiPackage
            ];

            # Optionally modify the hostname based on the healthchecks config
            networking.hostName = config.services.healthchecks.enable
              ? config.services.healthchecks.hostName
              : config.networking.hostName;
          };
        }
      ];
    }
}
