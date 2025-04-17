{ 
  config,
  lib,
  pkgs,
  ...
} : {
    config = lib.mkIf (lib.elem "bluetooth" config.this.host.modules.hardware) {
        environment.systemPackages = with pkgs; [ util-linux ];
        hardware.bluetooth.enable = true;
        
        # Brute force a reset after waking up from sleep, as some bluetooth devices
        # will fail to connect to a system that's been suspended at some point.
        powerManagement.resumeCommands = ''
            ${pkgs.util-linux}/bin/rfkill block bluetooth
             ${pkgs.util-linux}/bin/rfkill unblock bluetooth
        '';
      
    };}    


