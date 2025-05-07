{
  config,
  self,
  lib,
  pkgs,
  ...
} : let
  adbkey = ''
    "@ADBKEY@"
  '';
  adbkeyFile = 
    pkgs.runCommand "adbkeyFile"
      { preferLocalBuild = true; }
      ''
        cat > $out <<EOF
${adbkey}
EOF
      '';    
in {
    config = lib.mkIf (lib.elem "adb" config.this.host.modules.services) {
        environment.systemPackages = [ pkgs.android-tools self.packages.${pkgs.system}.tv ];
        systemd.services.android_config = lib.mkIf (!config.this.installer) {
            wantedBy = [ "multi-user.target" ];
            preStart = ''
                mkdir -p /home/${config.this.user.me.name}/.android
                sed -e "/@ADBKEY@/{
                    r ${config.sops.secrets.adbkey.path}
                    d
                }" ${adbkeyFile} > /home/${config.this.user.me.name}/.android/adbkey
                echo '${config.this.host.keys.publicKeys.adb}' > /home/${config.this.user.me.name}/.android/adbkey.pub
            '';
            serviceConfig = {
                ExecStart = "${pkgs.bash}/bin/bash -c 'echo succes; sleep 200'";
                Restart = "on-failure";
                RestartSec = "2s";
                RuntimeDirectory = [ config.this.user.me.name ];
                User = config.this.user.me.name;
                ConditionPathExists = config.sops.secrets.adbkey.path;
            };
        };
  
        sops.secrets = lib.mkIf (!config.this.installer) {
            adbkey = {
                sopsFile = ./../../secrets/adbkey.yaml;
                owner = config.this.user.me.name;
                group = config.this.user.me.name;
                mode = "0440";
            };
        };   
    };}
