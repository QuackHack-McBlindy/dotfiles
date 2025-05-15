# Edit TODO's then
# $ nix build
{
  description = "Template for building Bash scripts.";
  inputs.nixpkgs.url = "nixpkgs/nixos-21.05";

  outputs = { self, nixpkgs }:
    let
      #  TODO Enter your Script name and the script data here
      SCRIPTNAME = "satellite";
      SCRIPTCONTENT =
        ''
        wyoming-satellite \
          --name '$HOSTNAME' \
          --uri 'tcp://0.0.0.0:10500' \
          --mic-command 'arecord -r 16000 -c 1 -f S16_LE -t raw' \
          --snd-command 'aplay -r 22050 -c 1 -f S16_LE -t raw' \
          --wake-uri 'tcp://127.0.0.1:10400' \
          --wake-word-name 'yo_bitch' \
          --awake-wav /home/pungkula/dotfiles/home/sounds/awake.wav \
          --done-wav /home/pungkula/dotfiles/home/sounds/done.wav \
          --timer-finished-wav /home/pungkula/dotfiles/home/sounds/finished.wav 
        '';
      
      lastModifiedDate = self.lastModifiedDate or self.lastModified or "19700101";

      version = builtins.substring 0 8 lastModifiedDate;

      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; overlays = [ self.overlay ]; });

    in

    {

      overlay = final: prev: {

        ${SCRIPTNAME} = with final; stdenv.mkDerivation rec {
          name = "${SCRIPTNAME}-${version}";

          unpackPhase = ":";

          buildPhase =
            ''
              cat > ${SCRIPTNAME} <<EOF
              #! $SHELL
              ${SCRIPTCONTENT}
              EOF
              chmod +x ${SCRIPTNAME}
            '';

          installPhase =
            ''
              mkdir -p $out/bin
              cp ${SCRIPTNAME} $out/bin/
            '';
        };

      };

      # TODO ENTER SCRIPTNAME MANUALLY AT END OF INHERIT
      packages = forAllSystems (system:
        {
          inherit (nixpkgsFor.${system}) satellite;
        });


      defaultPackage = forAllSystems (system: self.packages.${system}.${SCRIPTNAME});

      # A NixOS module, if applicable (e.g. if the package provides a system service).
      nixosModules.${SCRIPTNAME} =
        { pkgs, ... }:
        {
          nixpkgs.overlays = [ self.overlay ];

          environment.systemPackages = [ pkgs.${SCRIPTNAME} ];

          #systemd.services = { ... };
        };

      # Tests run by 'nix flake check' and by Hydra.
      checks = forAllSystems
        (system:
          with nixpkgsFor.${system};

          {
            inherit (self.packages.${system}) NAME-HERE; # TODO ENTER SCRIPTNAME MANUALLY 

            test = stdenv.mkDerivation {
              name = "${SCRIPTNAME}-test-${version}";

              buildInputs = [ "${SCRIPTNAME}" ];

              unpackPhase = "true";

              buildPhase = ''
                echo 'running some integration tests'
                [[ ${SCRIPTNAME} = ${SCRIPTCONTENT} ]]
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
                    imports = [ self.nixosModules.${SCRIPTNAME} ];
                  };
                };

                testScript =
                  ''
                    start_all()
                    client.wait_for_unit("multi-user.target")
                    client.succeed("${SCRIPTNAME}")
                  '';
              };
          }
        );

    };
}
