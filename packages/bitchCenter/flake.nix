{
  description = "Voice assistant server with service integration";
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs } @ inputs:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });

      mkPackage = system: script: 
        let
          pkgs = nixpkgsFor.${system};
        pythonEnv = pkgs.python3.withPackages (ps: [
          ps.numpy ps.sounddevice ps.websockets ps.faster-whisper
          ps.pysoundfile ps.requests ps.fastapi ps.uvicorn ps.python-multipart
        ]);
        in
        pkgs.stdenv.mkDerivation {
          name = "voice-server";
          src = ./src;
          nativeBuildInputs = [ pkgs.makeWrapper ];
          installPhase = ''
            mkdir -p $out/bin
            cp $src/${script}.py $out/bin/${script}
            wrapProgram $out/bin/${script} \
              --prefix PATH : ${pythonEnv}/bin
          '';
        };

    in {
      packages = forAllSystems (system: {
        voice-server = mkPackage system "voice-server";
      });

      defaultPackage = forAllSystems (system: self.packages.${system}.voice-server);

      # Expose NixOS module for service configuration
      nixosModules.default = { config, lib, pkgs, ... }: {
        imports = [ self.nixosModules.voiceAssistant ];
      };

      nixosModules.voiceAssistant = { config, lib, pkgs, ... }: {
        networking.firewall.allowedTCPPorts = [ 10400 10500 10700 10555 ];
        environment.systemPackages = [ self.packages.${pkgs.system}.voice-server ];


       networking.firewall.allowedTCPPorts = [ 10300 ];

        environment.systemPackages = with pkgs; [ pkgs.wyoming-faster-whisper ]; 
  
        services.wyoming.faster-whisper = {
          package = pkgs.wyoming-faster-whisper;
          servers = {
            "whisper" = {
              enable = true;
              model = "small-int8";
              language = "sv";
              beamSize = 1;
              uri = "tcp://0.0.0.0:10300";
              device = "cpu";
              extraArgs = [ ];
            };
          };
        };


        services.wyoming.openwakeword = {
          enable = true;
          package = pkgs.wyoming-openwakeword;
          uri = "tcp://0.0.0.0:10400";
          preloadModels = [ "yo_bitch" ];
          customModelsDirectories = [ "/etc/openwakeword" ];
          threshold = 0.3;
          triggerLevel = 1;
          extraArgs = [ "--debug-probability" ];
        };
      };
    };
}
