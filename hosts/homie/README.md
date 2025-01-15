













### Modules:
`hardware-configuration.nix` (link: https://github.com/your-repo/hardware-configuration.nix)
`modules/services/ntp.nix` (link: https://github.com/your-repo/modules/services/ntp.nix)
`modules/services/jellyfin.nix` (link: https://github.com/your-repo/modules/services/jellyfin.nix)
`modules/services/avahi-server.nix` (link: https://github.com/your-repo/modules/services/avahi-server.nix)
`modules/services/avahi-client.nix` (link: https://github.com/your-repo/modules/services/avahi-client.nix)
`modules/services/dns.nix` (link: https://github.com/your-repo/modules/services/dns.nix)
`modules/services/adguardhome.nix` (link: https://github.com/your-repo/modules/services/adguardhome.nix)
`modules/networking/unbound.nix` (link: https://github.com/your-repo/modules/networking/unbound.nix)
`modules/services/fail2ban.nix` (link: https://github.com/your-repo/modules/services/fail2ban.nix)
`modules/nixos/users.nix` (link: https://github.com/your-repo/modules/nixos/users.nix)
`modules/nixos/nix.nix` (link: https://github.com/your-repo/modules/nixos/nix.nix)
`modules/nixos/fonts/default.nix` (link: https://github.com/your-repo/modules/nixos/fonts/default.nix)
`modules/nixos/i18n.nix` (link: https://github.com/your-repo/modules/nixos/i18n.nix)
`modules/nixos/pipewire.nix` (link: https://github.com/your-repo/modules/nixos/pipewire.nix)
`modules/security.nix` (link: https://github.com/your-repo/modules/security.nix)
`modules/services/ssh.nix` (link: https://github.com/your-repo/modules/services/ssh.nix)
`modules/services/syslog.nix` (link: https://github.com/your-repo/modules/services/syslog.nix)
`modules/services/syslogd.nix` (link: https://github.com/your-repo/modules/services/syslogd.nix)
`modules/networking/samba.nix` (link: https://github.com/your-repo/modules/networking/samba.nix)
`modules/nixos/default-apps.nix` (link: https://github.com/your-repo/modules/nixos/default-apps.nix)
`modules/networking/default.nix` (link: https://github.com/your-repo/modules/networking/default.nix)
` HA` (link: https://github.com/your-repo/ HA)
`modules/hass-agent.nix` (link: https://github.com/your-repo/modules/hass-agent.nix)
`modules/tts.nix` (link: https://github.com/your-repo/modules/tts.nix)
` hosts/homie/modules/voice.nix` (link: https://github.com/your-repo/ hosts/homie/modules/voice.nix)
`modules/home-assistant/default.nix` (link: https://github.com/your-repo/modules/home-assistant/default.nix)
`modules/home-assistant/database.nix` (link: https://github.com/your-repo/modules/home-assistant/database.nix)
`modules/home-assistant/zigbee2mqtt.nix` (link: https://github.com/your-repo/modules/home-assistant/zigbee2mqtt.nix)
`home-assistant/mosquitto.nix` (link: https://github.com/your-repo/home-assistant/mosquitto.nix)
` hosts/homie/modules/home-assistant/automations.nix` (link: https://github.com/your-repo/ hosts/homie/modules/home-assistant/automations.nix)
` hosts/homie/modules/home-assistant/media.nix` (link: https://github.com/your-repo/ hosts/homie/modules/home-assistant/media.nix)


### File System Configuration:
**/**: device = "/dev/disk/by-uuid/98a070ac-4d39-4796-ba7b-fb82072fc105";
      fsType = "ext4";
**/boot**: device = "/dev/disk/by-uuid/EE82-6A81";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];

### Hardware Configuration:
**CPU Microcode Update**: config.hardware.enableRedistributableFirmware

