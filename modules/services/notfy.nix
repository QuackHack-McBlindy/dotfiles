# dotfiles/modules/services/notfy.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 duck say ⮞ allows notifications to iPhone  
  config,  
  lib,       
  pkgs,      
  ...        
} : with lib; 
let # 🦆 duck say ⮞ not secure - but duck don't mind exposing base url to da nix store yo
  baseurl = ''
    "@BASEURL@"
  '';
  baseurlFile = 
    pkgs.runCommand "adbkeyFile"
      { preferLocalBuild = true; }
      ''
        cat > $out <<EOF
${baseurl}
EOF
      '';    

  
#  baseUrlCleaned = lib.strings.removeSuffix "\n" baseUrlRaw;
in {

    services.ntfy-sh = lib.mkIf (lib.elem "notfy" config.this.host.modules.services) {
       enable = true;
       settings = { # 🦆 duck say ⮞ dummy url yo!
           base-url = "https://notfy.duckdns.org";
           listen-http = ":9913";
           behind-proxy = true;      
           web-push-public-key = "BGxWiWgvfogQXS9Lz9diQe7G29jvuca0856U6Fb8m9NPUQj525BS62syNrBXUTFx4H32GQFomdVs0lHrHDIXD3U";
           web-push-private-key = config.sops.secrets.ntfy-private.path;
           web-push-file = "/var/lib/ntfy-sh/webpush.db";
           web-push-email-address = "anton-nordstrom@hotmail.com";
           enable-web-push = true;
       };
    };   
    
    networking.firewall.allowedTCPPorts = [ 9913 ];


    sops.secrets = {
        ntfy-private = lib.mkIf (lib.elem "notfy" config.this.host.modules.services) {
            sopsFile = ./../../secrets/ntfy-private.yaml;
            owner = "ntfy-sh";
            group = "ntfy-sh";
            mode = "0440"; # Read-only for owner and group
        };
        ntfy-url = {
            sopsFile = ./../../secrets/ntfy-url.yaml;
            owner = config.this.user.me.name;
            group = config.this.user.me.name;
            mode = "0440"; # Read-only for owner and group
        };
    };
    
    systemd.services.ntfy-setup = {
        wantedBy = [ "multi-user.target" ];
        after = [ "sops-nix.service" ];
        preStart = ''
            mkdir -p /var/lib/ntfy-sh
            touch /var/lib/ntfy-sh/baseurl
            sed -e "/@BASEURL@/{
                r ${config.sops.secrets.ntfy-url.path}
                d
            }" ${baseurlFile} > ./../../baseurl
            chown -R ntfy-sh:ntfy-sh /var/lib/ntfy-sh
            chmod -R u=rwX,g=rX,o= /var/lib/ntfy-sh
            chown ntfy-sh:ntfy-sh /var/lib/ntfy-sh/baseurl
            chmod 0440 /var/lib/ntfy-sh/baseurl
        '';
        serviceConfig = {
            ExecStart = "${pkgs.bash}/bin/bash -c 'echo succes; sleep 200'";
            Restart = "on-failure";
            RestartSec = "2s";
            RuntimeDirectory = [ config.this.user.me.name ];
            User = config.this.user.me.name;
            ConditionPathExists = "root";
        };
    };}
    





 

