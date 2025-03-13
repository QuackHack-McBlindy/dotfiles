{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.voice-server;
in {
 # environment.systemPackages = with pkgs; [ inputs.voice-client.packages.x86_64-linux.voice-client ];

  options.services.voice-server = {
    enable = mkEnableOption "Voice Control server";

    intents = mkOption {
     # default = "/etc/voice/intents.yaml";
      default = "/home/pungkula/dotfiles/home/.config/intents.yaml";
      type = types.str;
      description = "Path to intentss.yaml";
    };

    sentences = mkOption {
     # default = "/etc/voice/custom_sentences/sv";
      default = "/home/pungkula/dotfiles/home/custom_sentences/sv";
      example = "";
      type = types.str;
      description = ''
        Path to directory containing yaml custom sentences 
      '';
    };


    package = mkOption {
      default = pkgs.voice-server;
      defaultText = "pkgs.voice-server";
      type = types.package;
      description = "Voice Control Server package to use.";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.voice-server = {
      description = "Voice Control Server";
      after = [ "network-online.target" ];
     # wants = [ "network-online.target" ]; # systemd-networkd-wait-online.service
      wantedBy = [ "multi-user.target" ];
      startLimitIntervalSec = 14400;
      startLimitBurst = 10;
      serviceConfig = {
        ExecStart = "${cfg.package}";
      #  ExecReload = "${cfg.package}/bin/caddy reload --config ${cfg.config} --adapter ${cfg.adapter}";
        Type = "simple";
        User = "voice-server";
        Group = "voice-server";
        Restart = "on-abnormal";

      };

    };
  };
}
