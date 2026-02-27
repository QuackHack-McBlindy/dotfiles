# **zigduck-rs**

**zigduck-rs** takes care of house, home and heart. *(lights, automations, dimmers, etc ..)*  
High performance Rust home automation system that uses your Nix defined devices and automations to control your smart home.   

  
  
## **Package includes two binaries:**
  
1. `zigduck-rs` - The server-side automation service.

2. `zigduck-cli` - The client-side CLI controller.

  
## **NixOS modules**

  
[Use the house.nix module](https://github.com/QuackHack-McBlindy/dotfiles/tree/main/modules/house.nix)

  
  
[My full configuration](https://github.com/QuackHack-McBlindy/dotfiles/tree/main/modules/myHouse.nix)
  


## **zigduck-cli**

  
High‑performance client for controlling Zigbee and Hue devices, scenes, and automations from the command line.    


**Options:**


```bash
--broker (default: 127.0.0.1) [$MQTT_BROKER]
--user (default: mqtt ) [$MQTT_USER]
--password-file [$MQTT_PASSWORD_FILE]
--password [$MQTT_PASSWORD]
--devices-config [$DEVICES_CONFIG]
--scenes-config [$SCENES_CONFIG]
--hue-bridge-ip [$HUE_BRIDGE_IP]
--hue-api-key [$HUE_API_KEY]
--help
```

  
**Subcommands:**

  

```bash
--device
--state
--brightness
--color
--temperature
--room
--scene
--list
--pair
```


