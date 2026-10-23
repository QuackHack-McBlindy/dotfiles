# dotfiles/bin/maintenance/health.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ systemwide health checks
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ...
} : let
  # 🦆 says ⮞ dis fetch what host has Mosquitto
  sysHosts = lib.attrNames self.nixosConfigurations;
  mqttHost = lib.findSingle (host:
      let cfg = self.nixosConfigurations.${host}.config;
      in cfg.services.mosquitto.enable or false
    ) null null sysHosts;
  mqttHostip = if mqttHost != null
    then self.nixosConfigurations.${mqttHost}.config.this.host.ip or (
      let
        resolved = builtins.readFile (pkgs.runCommand "resolve-host" {} ''
          ${pkgs.dnsutils}/bin/host -t A ${mqttHost} > $out
        '');
      in
        lib.lists.head (lib.strings.splitString " " (lib.lists.elemAt (lib.strings.splitString "\n" resolved) 0))
    )
    else (throw "No Mosquitto host found in configuration");

in { # 🦆 says ⮞
  yo.scripts.health = {
    description = "Check system health report for tihs host & ESP32 devices. Returns JSON structured response and forwards to zigduck.";
    category = "🧹 Maintenance";
    aliases = [ "hc" ];
    runEvery = "15";
    code = ''
      ${cmdHelpers}
      HC="$(health-rs 2>/dev/null | sed -n '/^{/,$p' | jq -c .)"
      zigduck-cli --publish --topic "zigduck/${config.this.host.hostname}" --payload "$HC"
      echo "$HC"

      # 🦆 says ⮞ ESP32 devices
      if [[ "${config.this.host.hostname}" == "desktop" ]]; then
        WATCH=$(curl -s ${config.house.devices.watch.ip}/api/sensors \
          | jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)" \
               '. + {last_seen: $ts}')
        zigduck-cli --publish --topic "zigduck/watch" --payload "$WATCH"
        echo "" && echo "WATCH:"
        echo "$WATCH"



        BOX=$(curl -s ${config.house.devices.ESP32-S3-BOX3.ip}/api/sensors \
          | jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)" \
               '. + {last_seen: $ts}')
        zigduck-cli --publish --topic "zigduck/ESP32-S3-BOX3" --payload "$BOX"
        echo "" && echo "BOX:"
        echo "$BOX"
      fi
    '';
    voice = {
      priority = 4;
      sentences = [
        "hälsocheck"
        "health"
        "health check"
        "hc"
        "hur mår [min] (dator|datorn|server)"
      ];
      #lists = {
        #host.values = [
        #  { "in" = "[desktop|datorn]"; out = "desktop"; }
        #  { "in" = "nas"; out = "nasty"; }
        #  { "in" = "laptop"; out = "laptop"; }
        #  { "in" = "homie"; out = "homie"; }
        #];
       #};
    };

  };}
