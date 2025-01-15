{ config, pkgs, lib, ... }:

{
  # Configuration options for the FastAPI app
  options.services.voice = {
    enable = lib.mkEnableOption "Enable the Voice server app service.";
    appPath = lib.mkOption {
      type = lib.types.str;
      description = "Path to the Voice server application directory.";
    };
    secretKey = lib.mkOption {
      type = lib.types.str;
      default = "replace_with_strong_key";
      description = "Secret key for JWT tokens.";
    };
    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Host for the Voice server.";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 43334;
      description = "Port for the Voice server.";
    };
  };

  config = lib.mkIf config.services.voice.enable {
    # Install dependencies
    environment.systemPackages = with pkgs; [
      jose
      lsof
      rye
      python3
      python312Packages.sounddevice
      python312Packages.rapidfuzz
      python3Packages.rich
      python312Packages.pynput
      python3Packages.black
      python3Packages.isort
      python312Packages.cryptography
      #python312Packages.duckdb
      python312Packages.uvicorn
      python312Packages.fastapi
      python312Packages.colorlog
      python312Packages.httpx
      python312Packages.requests
      python312Packages.setuptools
      python312Packages.playsound
      python312Packages.cython
      python312Packages.psutil
      python312Packages.pyaudio
      python312Packages.openai-whisper
      python312Packages.python-jose
      python312Packages.passlib
      python312Packages.python-multipart
      python312Packages.aiofiles
    ];

    users.users.voice.group = "voice";
    users.groups.voice = {};

    # Service configuration for FastAPI app
    systemd.services.voice = {
      description = "Voice server application service";
      wantedBy = [ "multi-user.target" ];

      # Environment variables
      environment = {
        SECRET_KEY = config.services.voice.secretKey;
      };

      # Command to run the FastAPI app
      serviceConfig = {
        ExecStart = ''
          bash run.sh
 #         /run/current-system/sw/bin/python /run/current-system/sw/bin/uvicorn app:app \
 #           --host ${config.services.voice.host} \
 #           --port ${toString config.services.voice.port} \
 #           --workers 4 \
#            --proxy-headers
        '';
        WorkingDirectory = config.services.voice.appPath;
        Restart = "always";
        User = "pungkula";
        Group = "voice";
      };

      # Ensure required directories exist
      preStart = ''
        mkdir -p ${config.services.voice.appPath}/audio
        chown pungkula:voice ${config.services.voice.appPath}/audio
      '';
    };

    # Create a dedicated user for running the app
    users.users.voice = {
      isSystemUser = true;
      home = "/var/lib/voice";
    };
  };
}
