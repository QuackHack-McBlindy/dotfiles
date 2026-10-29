# dotfiles/modules/services/yo-rs.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 say ⮞ voice assistant configuration
  config,
  lib,
  pkgs,
  self,
  hosts,
  devices,
  ...
} : let
  cfg = config.services.yo-rs;
  host = config.this.host.hostname;

  # 🦆 say ⮞ client configuration
  clients = {
    homie   = {
      room     = "livingroom";
      gain     = 1.0;
      awakeCmd = "zigduck-cli --device PC --state on --brightness 50 --color blue";
      doneCmd  = "zigduck-cli --device PC --state off";
      failCmd  = "zigduck-cli --device PC --state off";
    };
    desktop = {
      room     = "local";
      gain     = 0.0;
      awakeCmd = "zigduck-cli --device PC --state on --brightness 50 --color blue";
      doneCmd  = "zigduck-cli --device PC --state off";
      failCmd  = "zigduck-cli --device PC --state off";
    };
    nasty   = {
      room     = "bedroom";
      gain     = 0.7;
      awakeCmd = "curl http://${devices.ESP32-S3-BOX-3.ip}/api/ding";
      doneCmd  = "curl http://${devices.ESP32-S3-BOX-3.ip}/api/done";
      failCmd  = "curl http://${devices.ESP32-S3-BOX-3.ip}/api/fail";
    };
  };
  # 🦆 duck say ⮞ fake clients for yo-say when no server is running
  yoClientsJson = pkgs.writeText "yo-clients.json" (builtins.toJSON [
    { room = "bedroom";    ip = hosts.nasty.ip;  connected_at = 0; gain = 1.0; }
    { room = "livingroom"; ip = hosts.desktop.ip; connected_at = 0; gain = 1.0; }
    { room = "esp";        ip = devices.ESP32-S3-BOX-3.ip;  connected_at = 0; gain = 1.0; }
  ]);
  h = clients.${host} or { room = ""; awakeCmd = ""; doneCmd = ""; failCmd = ""; };
in {
  config = lib.mkMerge [{
    link.".config/yo/clients.json" = lib.mkIf
      (!(lib.elem "yo" config.this.host.modules.services))
      yoClientsJson;

    environment.systemPackages = [ self.inputs.yo.packages.x86_64-linux.yo-rs ];
    networking.firewall.allowedTCPPorts = [ 12345 ];
    services.yo-rs = {
      port = 12345;
      openFirewall = true;
      server = {
        enable = lib.mkIf (lib.elem "yo" config.this.host.modules.services) true;
        language = "swedish";
        whisper = "base";
        ttsSpeed = "1.3";
        shellTranslate = true;
        threshold = 0.7;
        beamSize = 0; # 🦆 says ⮞ diz iz greedy! but srsly --
        temperature = 0.0; # 🦆 says ⮞ no more LSD plx
        threads = 8;
        debug = false;
        logFile = "/home/pungkula/.config/duckTrace/yo-rs-server.log";
      };

      client = {
        enable = true;
        uri    = (lib.findFirst
          (h: lib.elem "yo" h.modules.services)
          (throw "YO HOST PLS")
          (lib.attrValues hosts)).ip + ":12345";
        room   = h.room;
        gain   = h.gain;
        silenceThreshold = 0.03;
        silenceTimeout   = 1.3;
        maxDuration      = 4.0;
        awakeCmd = h.awakeCmd;
        doneCmd  = h.doneCmd;
        failCmd  = h.failCmd;
        debug    = false;
        logFile  = "/home/pungkula/.config/duckTrace/yo-rs-client.log";
      };
    };

    yo = {
      legacy = false;
      # default fuzzy settings (overridden by per-script configurations)
      fuzzy = {
        threshold = 0.6;
        conflict.detection = false;
        conflict.threshold = 80;
      };
      splitWords = [ ];
      sorryPhrases = [
        "Det låter som du har en köttebulle i käften. Ät klart middagen och försök sedan igen."
        "Vad fan säger du för något?"
        "Prata som en människa snälla"
      ];
    };

  }];}
