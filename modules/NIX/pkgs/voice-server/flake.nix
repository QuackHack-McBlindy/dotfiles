{
  description = "Python package for voice transcription with Faster-Whisper.";
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });

      mkPackage = system: script:
        let
          pkgs = nixpkgsFor.${system};
        in
        pkgs.stdenv.mkDerivation {
          name = "voice-server";
          src = ./src;  
          propagatedBuildInputs = with pkgs.python3Packages; [
            numpy sounddevice websockets faster-whisper pysoundfile requests
            fastapi uvicorn python-multipart 
          ];
          installPhase = ''
            mkdir -p $out/bin
            echo "#!${pkgs.python3.withPackages (ps: [ ps.numpy ps.sounddevice ps.websockets ps.faster-whisper ps.pysoundfile ps.requests ps.fastapi ps.uvicorn ps.python-multipart ])}/bin/python3" > $out/bin/${script}
            cat $src/${script}.py >> $out/bin/${script}
            chmod +x $out/bin/${script}
          '';
        };

    in {
      packages = forAllSystems (system: {
        voice-server = mkPackage system "voice-server";
   #     client = mkPackage system "client";
      });

      defaultPackage = forAllSystems (system: self.packages.${system}.voice-server);
    };
}

