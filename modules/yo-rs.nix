{ 
  self, 
  config,
  lib,
  pkgs,
  ...
} : let
  cfg = config.services.yo-rs;
  inherit (lib) types mkOption mkEnableOption mkIf optional optionals getExe;
in {
  options.services.yo-rs = {
    enable = mkEnableOption "yo-rs services (server and/or client)";

    package = mkOption {
      type = types.package;
      default = self.packages.${pkgs.system}.yo-rs;
      defaultText = lib.literalExpression "self.packages.${pkgs.system}.yo-rs";
      description = "The yo-rs package containing both server and client binaries.";
    };

    server = {
      enable = mkEnableOption "yo-rs server (wake word detection & transcription)";

      host = mkOption {
        type = types.str;
        default = "0.0.0.0:12345";
        description = "Listening address and port for the server.";
      };

      awakeSound = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = ''
          Path to a custom WAV file played on wake detection.
          If `null`, the embedded `ding.wav` is used.
        '';
      };

      doneSound = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = ''
          Path to a custom WAV file played on successful command execution.
          If `null`, the embedded `done.wav` is used.
        '';
      };

      wakeWordPath = mkOption {
        type = types.nullOr types.path;
        #default = "${cfg.package}/share/yo-rs/models/wake-words/yo_bitch.onnx";
        default = null;
        description = "Path to the wake‑word ONNX model.";
      };

      threshold = mkOption {
        type = types.float;
        default = 0.5;
        description = "Detection threshold (0.0–1.0).";
      };

      whisperModelPath = mkOption {
        type = types.path;
        default = "${cfg.package}/share/yo-rs/models/stt/ggml-small.bin";
        description = "Path to the Whisper GGML model.";
      };

      shellTranslate = mkOption {
        type = types.bool;
        default = false;
        description = "Translate the transcription to shell command and execute.";
      };

      beamSize = mkOption {
        type = types.int;
        default = 5;
        description = "Beam size for Whisper (0 = greedy).";
      };

      temperature = mkOption {
        type = types.float;
        default = 0.2;
        description = "Whisper sampling temperature.";
      };

      language = mkOption {
        type = types.nullOr types.str;
        default = "en";
        description = ''
          Language code (e.g., `sv`, `en`) or `"auto"`.
          Use `null` for automatic detection (equivalent to `auto`).
        '';
      };

      threads = mkOption {
        type = types.int;
        default = 4;
        description = "Number of threads for Whisper inference.";
      };

      execCommand = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Command to execute with the transcribed text as the final argument.
          The command is run with the same environment as the server.
          Example: `"yo do"`.
        '';
      };
      
      textToSpeechModelPath = mkOption {
        type = types.nullOr types.path;
        default = "${cfg.package}/share/yo-rs/models/tts/en_US-amy-medium.onnx";
        description = "Path to the text-to-speech ONNX model.";
      };

      debug = mkOption {
        type = types.bool;
        default = false;
        description = "Enable debug logging (prints probabilities, timings).";
      };
      
      extraPath = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = ''
          Additional directories to prepend to the `PATH` environment variable
          of the systemd service. You can use systemd specifiers like `%h`
          (home directory) or `%u` (username).
        '';
      };

      extraArgs = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Extra arguments passed verbatim to the server binary.";
      };
    };

    client = {
      enable = mkEnableOption "yo-rs client (audio streaming & recording)";

      uri = mkOption {
        type = types.str;
        default = "127.0.0.1:12345";
        description = "Server address to connect to.";
      };

      debug = mkOption {
        type = types.bool;
        default = false;
        description = "Print RMS values during recording.";
      };

      silenceThreshold = mkOption {
        type = types.float;
        default = 0.005;
        description = "RMS threshold below which audio is considered silence.";
      };

      silenceTimeout = mkOption {
        type = types.float;
        default = 1.0;
        description = "Seconds of silence before stopping recording.";
      };

      maxDuration = mkOption {
        type = types.float;
        default = 5.0;
        description = "Maximum recording length (fallback).";
      };

      extraArgs = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Extra arguments passed verbatim to the client binary.";
      };
    };
  };

  config = mkIf (cfg.server.enable || cfg.client.enable) {
    systemd.tmpfiles.rules = mkIf cfg.server.enable [
      "d /var/lib/yo-rs/models 0755 root root -"
    ];

    systemd.user.services = {
      yo-rs-server = mkIf cfg.server.enable {
        description = "yo-rs wake word detection and transcription server";
        after = [ "network.target" ];
        wants = [ "network.target" ];
        wantedBy = [ "default.target" ];

        serviceConfig = {
          Restart = "always";
          RestartSec = "15s";
          
          Environment = "PATH=${
            lib.concatStringsSep ":"
              (cfg.server.extraPath ++ [
                "/run/wrappers/bin"
                "/run/current-system/sw/bin"
                "/usr/local/bin"
                "/usr/bin"
                "/bin"
              ])
          }";
          
          ExecStart = lib.escapeShellArgs (
            [ (getExe cfg.package) "--host" cfg.server.host ]
            ++ optionals (cfg.server.wakeWordPath != null)
                [ "--wake-word" cfg.server.wakeWordPath ]
            ++ [ "--threshold" (toString cfg.server.threshold) ]
            ++ [ "--model" cfg.server.whisperModelPath ]
            ++ [ "--beam-size" (toString cfg.server.beamSize) ]
            ++ [ "--temperature" (toString cfg.server.temperature) ]
            ++ [ "--threads" (toString cfg.server.threads) ]
            ++ optionals (cfg.server.awakeSound != null) [ "--awake-sound" cfg.server.awakeSound ]
            ++ optionals (cfg.server.doneSound != null) [ "--done-sound" cfg.server.doneSound ]
            ++ optionals (cfg.server.language != null) [ "--language" cfg.server.language ]
            ++ optionals (cfg.server.execCommand != null) [ "--exec-command" cfg.server.execCommand ]
            ++ optionals cfg.server.shellTranslate [ "--translate-to-shell" ]
            ++ optionals (cfg.server.textToSpeechModelPath != null) [ "--tts-model" cfg.server.textToSpeechModelPath ]
            ++ optionals cfg.server.debug [ "--debug" ]
            ++ cfg.server.extraArgs
          );
        };
      };

      yo-rs-client = mkIf cfg.client.enable {
        description = "yo-rs client for streaming audio and recording";
        after = [ "network.target" "sound.target" ];
        wants = [ "network.target" "sound.target" ];
        wantedBy = [ "default.target" ];

        serviceConfig = {
          Restart = "always";
          RestartSec = "15s";        
          ExecStart = lib.escapeShellArgs (
            [ "${cfg.package}/bin/yo-client" "--uri" cfg.client.uri ]
            ++ [ "--silence-threshold" (toString cfg.client.silenceThreshold) ]
            ++ [ "--silence-timeout" (toString cfg.client.silenceTimeout) ]
            ++ [ "--max-duration" (toString cfg.client.maxDuration) ]
            ++ optionals cfg.client.debug [ "--debug" ]
            ++ cfg.client.extraArgs
          );
        };
      };
    };
    
  };}
