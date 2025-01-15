


### Modules:
`hardware-configuration.nix` (link: https://github.com/your-repo/hardware-configuration.nix)
`modules/home-assistant/default.nix` (link: https://github.com/your-repo/modules/home-assistant/default.nix)
`modules/home-assistant/database.nix` (link: https://github.com/your-repo/modules/home-assistant/database.nix)
`  modules/home-assistant/media2.nix` (link: https://github.com/your-repo/  modules/home-assistant/media2.nix)
`   modules/home-assistant/mosquitto.nix` (link: https://github.com/your-repo/   modules/home-assistant/mosquitto.nix)
`   modules/home-assistant/zigbee2mqtt.nix` (link: https://github.com/your-repo/   modules/home-assistant/zigbee2mqtt.nix)
`modules/hardware/pam.nix` (link: https://github.com/your-repo/modules/hardware/pam.nix)
`modules/services/avahi-client.nix` (link: https://github.com/your-repo/modules/services/avahi-client.nix)
`modules/services/dns.nix` (link: https://github.com/your-repo/modules/services/dns.nix)
`modules/services/fail2ban.nix` (link: https://github.com/your-repo/modules/services/fail2ban.nix)
`modules/nixos/users.nix` (link: https://github.com/your-repo/modules/nixos/users.nix)
`modules/nixos/nix.nix` (link: https://github.com/your-repo/modules/nixos/nix.nix)
`modules/nixos/fonts/default.nix` (link: https://github.com/your-repo/modules/nixos/fonts/default.nix)
`modules/nixos/i18n.nix` (link: https://github.com/your-repo/modules/nixos/i18n.nix)
`modules/nixos/pipewire.nix` (link: https://github.com/your-repo/modules/nixos/pipewire.nix)
`modules/security.nix` (link: https://github.com/your-repo/modules/security.nix)
`modules/services/ssh.nix` (link: https://github.com/your-repo/modules/services/ssh.nix)
`modules/services/syslogd.nix` (link: https://github.com/your-repo/modules/services/syslogd.nix)
`modules/services/syslog.nix` (link: https://github.com/your-repo/modules/services/syslog.nix)
`modules/programs/thunar.nix` (link: https://github.com/your-repo/modules/programs/thunar.nix)
`modules/networking/samba.nix` (link: https://github.com/your-repo/modules/networking/samba.nix)
`modules/nixos/gnome-background.nix` (link: https://github.com/your-repo/modules/nixos/gnome-background.nix)
`modules/nixos/default-apps.nix` (link: https://github.com/your-repo/modules/nixos/default-apps.nix)
`modules/virtualization/docker.nix` (link: https://github.com/your-repo/modules/virtualization/docker.nix)
`modules/virtualization/vm.nix` (link: https://github.com/your-repo/modules/virtualization/vm.nix)


### File System Configuration:
**/**: #    device = "/dev/disk/by-label/nixos";
#    fsType = "ext4";
#
**/**: device = "/dev/disk/by-uuid/3c2682f0-4fcd-4c43-ad49-2f8559641659";
      fsType = "ext4";
**/boot**: device = "/dev/disk/by-uuid/B4D0-85AF";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];

### Hardware Configuration:
**CPU Microcode Update**: config.hardware.enableRedistributableFirmware

