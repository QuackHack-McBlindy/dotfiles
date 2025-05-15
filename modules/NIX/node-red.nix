{ config, pkgs, lib, ... }:

let
  # Helper functions that don't depend on config
  mkTopic = friendlyName: "zigbee2mqtt/${friendlyName}";
  mkGroupSetTopic = friendlyName: "zigbee2mqtt/${friendlyName}/set";
  mkDeviceSetTopic = friendlyName: "zigbee2mqtt/${friendlyName}/set";
in

{

  config = lib.mkIf (lib.elem "node-red" config.this.host.modules.services) (let
    # Configuration-dependent definitions
    isGroup = action:
      (config.services.zigbee2mqtt.settings.groups or {} ? "${action}");

    automationRules = [
      {
        trigger = "Motion Sensor Hall";
        triggerPayload = "motion";
        action = "all_hallway_lights";
        actionPayload = "ON";
      }
      {
        trigger = "Motion Sensor Kök";
        triggerPayload = "motion";
        action = "all_kitchen_lights";
        actionPayload = "ON";
      }
      {
        trigger = "Motion Sensor Sovrum";
        triggerPayload = "motion";
        action = "all_bedroom_lights";
        actionPayload = "ON";
      }
      {
        trigger = "Dimmer Switch Kök";
        triggerPayload = "brightness";
        action = "kitchen_spotlight_group";
        actionPayload = "{{brightness}}";
      }
      {
        trigger = "Dimmer Switch Sovrum";
        triggerPayload = "brightness";
        action = "all_bedroom_lights";
        actionPayload = "{{brightness}}";
      }
    ];

    generateFlow = rule:
      let
        triggerTopic = mkTopic rule.trigger;
        actionTopic = if isGroup rule.action
                      then mkGroupSetTopic rule.action
                      else mkDeviceSetTopic rule.action;
      in [
        {
          id = builtins.hashString "md5" "${rule.trigger}-${rule.action}";
          type = "mqtt in";
          topic = triggerTopic;
          name = "${rule.trigger} Trigger";
          server = "localhost";
          wires = [ ["${rule.trigger}-func"] ];
        }
        {
          id = "${rule.trigger}-func";
          type = "function";
          name = "Convert Payload";
          func = ''
            if (msg.payload === "${rule.triggerPayload}") {
              return {
                payload: "${rule.actionPayload}"
              };
            }
            return null;
          '';
          wires = [ ["${rule.action}-out"] ];
        }
        {
          id = "${rule.action}-out";
          type = "mqtt out";
          topic = actionTopic;
          name = "Control ${rule.action}";
          server = "localhost";
        }
      ];

    flow = lib.flatten (map generateFlow automationRules);
    
    flowsJson = pkgs.writeText "flows.json" (builtins.toJSON flow);

    nodeRedUserDir = pkgs.runCommand "node-red-dir" {} ''
      mkdir -p $out
      ln -s ${flowsJson} $out/flows.json
    '';

  in {
    services.node-red = {
      enable = true;
      userDir = nodeRedUserDir;
      openFirewall = true;
    };

 #   assertions = map (rule: {
#      assertion = (config.services.zigbee2mqtt.settings.devices or {} ? "${rule.trigger}") ||
#                  (config.services.zigbee2mqtt.settings.groups or {} ? "${rule.action}");
#      message = "Invalid device/group reference in automation: ${rule.trigger} -> ${rule.action}";
#    }) automationRules;
  });
}
