{ self, system, config, lib, pkgs, ... }:
with lib;
let cfg = config.services.apk-deploy;

in {
  options.services.apk-deploy = {
    enable = mkEnableOption "APK deployment service";
    adbKeys = mkOption {
      type = types.path;
      default = null;
      description = "Path to ADB vendor keys";
    };
    targetIPs = mkOption {
      type = types.attrsOf types.str;
      default = {
        bedroom = "192.168.1.152";
        kivingroom = "192.168.1.223";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.apk-deployer = {
      description = "Deploy Jellyfin Android TV APK";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${self.packages.${system}.default}/bin/deploy-apk";
        Environment = [
          "ADB_VENDOR_KEYS=${cfg.adbKeys}"
        ];
      };
    };

    environment.systemPackages = [ self.packages.${system}.default ];
  };
}
