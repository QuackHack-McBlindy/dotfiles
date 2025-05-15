{
  description = "Python package for voice recognition with Wyoming-OpenWakeWord and Faster-Whisper.";
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      scriptNames = [ "server" "client" ];
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });

    in {
      packages = forAllSystems (system:
        let pkgs = nixpkgsFor.${system}; in
        builtins.listToAttrs (map (script:
          {
            name = script;
            value = pkgs.stdenv.mkDerivation {
              name = script;
              src = ./src;  # Ensure scripts are in `src/`
              nativeBuildInputs = [ pkgs.wyoming-openwakeword ];  # System dependency
              propagatedBuildInputs = with pkgs.python3Packages; [
                numpy sounddevice websockets faster-whisper pysoundfile  # Add pysoundfile
              ];
              installPhase = ''
                mkdir -p $out/bin
                echo "#!${pkgs.python3.withPackages (ps: [ ps.numpy ps.sounddevice ps.websockets ps.faster-whisper ps.pysoundfile ])}/bin/python3" > $out/bin/${script}
                cat $src/${script}.py >> $out/bin/${script}
                chmod +x $out/bin/${script}
              '';
            };
          }
        ) scriptNames)
      );

      defaultPackage = forAllSystems (system: self.packages.${system}.server);
    };
}

