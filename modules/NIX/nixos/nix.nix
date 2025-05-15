{ 
  config,
  lib,
  pkgs,
  ...
} : let
    pubkey = import ./../../hosts/pubkeys.nix;
      
    SSLpem = ''
        "@SSLCERT@"
    '';
    SSLFile = 
        pkgs.runCommand "SSLFile"
            { preferLocalBuild = true; }
            ''
            cat > $out <<EOF
${SSLpem}
EOF
            '';   
    buildKey = ''
        "@BUILDKEY@"
    '';

    buildKeyFile = 
        pkgs.runCommand "buildKeyFile"
            { preferLocalBuild = true; }
            ''
            cat > $out <<EOF
${buildKey}
EOF
            '';   
in {
    documentation.nixos.enable = false;
    nixpkgs.config.allowUnfree = true;
    system.tools.nixos-option.enable = true;
    
    nix = {
        distributedBuilds = true;
     
        buildMachines = [{
            protocol = "ssh";
            hostName = "desktop";
            sshUser = "builder";
            sshKey = "/root/.ssh/id_ed25519_builder";
            #publicHostKey = pubkey.host.builder;
            system = "x86_64-linux";
            maxJobs = 4;
            speedFactor = 5;
            supportedFeatures = [ "kvm" "big-parallel" ];
            mandatoryFeatures = [ "big-parallel" ];
        }];
 
      	settings = {
            # direnv
	        keep-outputs = true;
            keep-derivations = true;
        
	        warn-dirty = false;
	     	experimental-features = [ "nix-command" "flakes" ];
      		auto-optimise-store = true;
	       	sandbox = true;
            log-lines = 30;
            min-free = 1073741824; # 1GB
            max-free = 8589934592; # 8GB
        
            builders-use-substitutes = true;
            allowed-users = [
                "@wheel"
                "builder"
                "pungkula"
            ];  
            trusted-users = [
                "root"
                "pungkula"
                "builder"
            ];
            trusted-public-keys = [ pubkey.cache ];
            substituters = [
                "https://cache/"
                "https://cache.nixos.org/"
            ];
     	};
	
     	extraOptions = ''
	        download-buffer-size = 2097152
     	    connect-timeout = 15
     	    http-connections = 50   
            
     	    show-trace = true                 
            trace-function-calls = false       
     	'';
	
     	gc = {
     	    automatic = true;
	     	dates = "weekly";
	     	options = "--delete-older-than 7d";
        };
    };
    
    systemd.services.build_config = {
        wantedBy = [ "multi-user.target" ];

        preStart = ''
            mkdir -p /root/.ssh
            sed -e "/@BUILDKEY@/{
                r ${config.sops.secrets.id_ed25519_builder.path}
                d
            }" ${buildKeyFile} > /root/.ssh/id_ed25519_builder
        '';
    
        serviceConfig = {
            ExecStart = "${pkgs.bash}/bin/bash -c 'echo succes;'";
            Restart = "on-failure";
            RestartSec = "2s";
            RuntimeDirectory = [ "root" ];
            User = "root";
        };
    };
    
   # FIXME TRUST CERTIFICATE 
   # security.pki.certificateFiles
    
    sops.secrets = {
        id_ed25519_builder = {
            sopsFile = ./../../secrets/id_ed25519_builder.yaml;
            owner = "root";
            group = "root";
            mode = "0440"; 
        };
 
    };}
