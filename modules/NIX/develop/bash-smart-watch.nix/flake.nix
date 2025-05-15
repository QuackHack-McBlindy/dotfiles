{
  description = "An over-engineered Smart Watch command in bash";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "nixpkgs/nixos-21.05";

  outputs = { self, nixpkgs }:
    let

      # to work with older version of flakes
      lastModifiedDate = self.lastModifiedDate or self.lastModified or "19700101";

      # Generate a user-friendly version number.
      version = builtins.substring 0 8 lastModifiedDate;

      # System types to support.
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; overlays = [ self.overlay ]; });

    in

    {

      # A Nixpkgs overlay.
      overlay = final: prev: {

        smart-watch = with final; stdenv.mkDerivation rec {
          name = "smart-watch-${version}";

          unpackPhase = ":";

          buildPhase =
            ''
              cat > smart-watch <<EOF
              #! $SHELL
              echo "smart-watch"
              EOF
              chmod +x smart-watch
            '';

          installPhase =
            ''
              mkdir -p $out/bin
              cp smart-watch $out/bin/
            '';
        };

      };

      # Provide some binary packages for selected system types.
      packages = forAllSystems (system:
        {
          inherit (nixpkgsFor.${system}) smart-watch;
        });

      # The default package for 'nix build'. This makes sense if the
      # flake provides only one package or there is a clear "main"
      # package.
      defaultPackage = forAllSystems (system: self.packages.${system}.smart-watch);

      # A NixOS module, if applicable (e.g. if the package provides a system service).
      nixosModules.smart-watch =
        { pkgs, ... }:
        {
          nixpkgs.overlays = [ self.overlay ];

          environment.systemPackages = [ pkgs.smart-watch ];

          #systemd.services = { ... };
        };

      # Tests run by 'nix flake check' and by Hydra.
      checks = forAllSystems
        (system:
          with nixpkgsFor.${system};

          {
            inherit (self.packages.${system}) smart-watch;

            # Additional tests, if applicable.
            test = stdenv.mkDerivation {
              name = "smart-watch-test-${version}";

              buildInputs = [ smart-watch ];

              unpackPhase = "true";

              buildPhase = ''
                echo 'running some integration tests'
                [[ $(smart-watch) = 'smart-watch' ]]
              '';

              installPhase = "mkdir -p $out";
            };
          }

          // lib.optionalAttrs stdenv.isLinux {
            # A VM test of the NixOS module.
            vmTest =
              with import (nixpkgs + "/nixos/lib/testing-python.nix") {
                inherit system;
              };

              makeTest {
                nodes = {
                  client = { ... }: {
                    imports = [ self.nixosModules.smart-watch ];
                  };
                };

                testScript =
                  ''
                    start_all()
                    client.wait_for_unit("multi-user.target")
                    client.succeed("smart-watch")
                  '';
              };
          }
        );

    };
}
