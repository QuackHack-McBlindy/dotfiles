#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
{ #°✶.•°••─→ FLAKE.NIX ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
    description = "❄️🦆 QuackHack-McBlindy's dotfiles! With extra Flakes.";
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
      
        home-manager.url = "github:nix-community/home-manager";
        home-manager.inputs.nixpkgs.follows = "nixpkgs";  
          
        #agenix.url = "github:ryantm/agenix";
        #agenix-rekey.url = "github:oddlama/agenix-rekey";
        #agenix-rekey.inputs.nixpkgs.follows = "nixpkgs";
      
        sops-nix.url = "github:Mic92/sops-nix";
        sops-nix.inputs.nixpkgs.follows = "nixpkgs";  
      
        disko.url = "github:nix-community/disko";
        disko.inputs.nixpkgs.follows = "nixpkgs";
        nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
      
        flake-utils.url = "github:numtide/flake-utils";
        flake-parts.url = "github:hercules-ci/flake-parts";
      
        nixos-unified.url = "github:srid/nixos-unified";
   
     #   nixcord.url = "github:kaylorben/nixcord";
      #  netboot.url = "path:./modules/iso";


#°✶.•°••─→ RPi4 INSTALLER ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
        pi-flake.url = "github:QuackHack-McBlindy/raspberry-pi-nix";
        pi-flake.flake = false;

        gradle2nix.url = "github:tadfisher/gradle2nix";

#°✶.•°••─→ x86_64-linux AUTO INSTALLER ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
        auto-installer.url = "github:QuackHack-McBlindy/auto-installer-nixos";

        voice-server.url = "./pkgs/voice-server";
        voice-client.url = "./pkgs/voice-client";
        caddy-duckdns.url = "github:QuackHack-McBlindy/nix-caddy-duckdns";
        say.url = "./pkgs/say";
        tv.url = "./pkgs/tv";
      #  api.url = "./pkgs/api";

#°✶.•°••─→ MOBILE INPUTS ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
        librem-nixos.url = "github:zhaofengli/librem-nixos?ref=d7e3010";
        mobile-nixos.url = "github:mobile-nixos/mobile-nixos?ref=183ba24";
        mobile-nixos.flake = false;
        mobile-nixos-tools.url = "github:sergei-mironov/mobile-nixos-tools?ref=64db06a";
        mobile-nixos-tools.flake = false;
        nixpkgs-mobile.url = "github:nixos/nixpkgs?ref=6daa4a5c045d40e6eae60a3b6e427e8700f1c07f";
    };
  
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ OUTPUTS ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°  
    outputs = { self, flake-utils, gradle2nix, nixpkgs, nixos-facter-modules, sops-nix, disko, home-manager, nixpkgs-mobile, mobile-nixos, mobile-nixos-tools, librem-nixos, auto-installer, voice-server, voice-client, caddy-duckdns, say, tv, ... }@inputs:
        let
            user = "pungkula";
            hostname = self.config.networking.hostName;
            system = "x86_64-linux";
            eachSystem = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ];
            pkgs = import nixpkgs {
                inherit system;
                config.allowUnfree = true;
            }; 
            aarch64 = "aarch64-linux";
            pkgs-mobile = import nixpkgs-mobile {
                inherit aarch64;
                config.allowUnfree = true;
            }; 
          
            auto_installer_iso = auto-installer.nixosConfigurations.installer.config.system.build.isoImage; 
            homeConfigFiles = { hostname, ... }: {
                home-manager.useGlobalPkgs = true;
                home-manager.backupFileExtension = "bak";
                home-manager.useUserPackages = true;
                home-manager.extraSpecialArgs = { inherit user; inherit hostname; };
                home-manager.users.${user} = import ./home-manager/home.nix;
            };
          #  lib = nixpkgs.lib;
        in {
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
#°✶.•°••─→ SETUP / KEY DISTRIBUTION ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°

            packages.x86_64-linux.voice-server = voice-server.packages.x86_64-linux.voice-server;
            packages.x86_64-linux.voice-client = voice-client.packages.x86_64-linux.voice-client;
            packages.x86_64-linux.caddy-duckdns = caddy-duckdns.packages.x86_64-linux.caddy;
            packages.x86_64-linux.say = say.packages.x86_64-linux.say;
            packages.x86_64-linux.tv = tv.packages.x86_64-linux.tv;
           # packages.x86_64-linux.api = api.packages.x86_64-linux.api;
 
            apps.${system}.apk = {
              type = "app";
              program = "${pkgs.writeShellScriptBin "deploy-apk" ''
                set -eo pipefail

                # Build the APK
                echo "Building APK..."
                apk_path=$(nix build .#apk-package --no-link --print-out-paths)/apk/jellyfin-androidtv.apk

                # Deploy to TVs
                for ip in 192.168.1.152 192.168.1.223; do
                  echo "Deploying to $ip..."
                  ${pkgs.android-tools}/bin/adb connect $ip
                  ${pkgs.android-tools}/bin/adb install -t -r "$apk_path"
                  ${pkgs.android-tools}/bin/adb shell am start -n \
                    "org.jellyfin.androidtv/org.jellyfin.androidtv.ui.startup.StartupActivity"
                done
              ''}/bin/deploy-apk";
            };

            packages.x86_64-linux.apk-package = pkgs.callPackage ({ mkGradleEnv }:
              let
                src = pkgs.fetchFromGitHub {
                  owner = "QuackHack-McBlindy";
                  repo = "duck-tv-androidtv";
                  rev = "98a96ca63541c3b8407c4a2b9af4473fb0758a03";
                  sha256 = "sha256-d20VBW9+Kw9STTr4+TyURvp6R+zcxtw6oZbSOSRJsEc=";
                };

                gradleEnv = mkGradleEnv {
                  inherit src;
                  gradleFlags = [ ":app:assembleRelease" ];
                };
              in pkgs.stdenv.mkDerivation {
                name = "jellyfin-androidtv-apk";
                inherit src;

                buildInputs = [
                  pkgs.jdk
                  pkgs.gradle
                  (pkgs.androidenv.composeAndroidPackages {
                    platformVersions = [ "30" ];
                    buildToolsVersions = [ "30.0.3" ];
                    includeNDK = true;
                    ndkVersions = [ "23.1.7779620" ];
                  }).androidPlatform
                ];

                ANDROID_SDK_ROOT = "${pkgs.androidenv.androidPlatform}/share/android-sdk";
                GRADLE_USER_HOME = gradleEnv;

                buildPhase = ''
                  export HOME=$(mktemp -d)
                  gradle --offline :app:assembleRelease
                '';

                installPhase = ''
                  mkdir -p $out/apk
                  cp app/build/outputs/apk/release/*.apk $out/apk/jellyfin-androidtv.apk
                '';
              }) { mkGradleEnv = gradle2nix.legacyPackages.${system}.mkGradleEnv; };




 
            apps.x86_64-linux.box = {
                type = "app";
                program = "${pkgs.writeShellScriptBin "box" ''        
                    set -x
                    #systemctl --user start pcscd.service || sudo systemctl start pcscd.service

                    export PATH=${
                        pkgs.lib.makeBinPath [

                            pkgs.esphome
                            pkgs.arduino
                            pkgs.platformio
                            pkgs.nrfutil
                            pkgs.stm32flash
                            pkgs.curl
                            pkgs.git 
                            pkgs.wget     
                            pkgs.sudo     
                        ]
                    }    
                    export SEGGER_JLINK_ACCEPT_LICENSE=true
                    CONFIG_FILE="./hosts/box/configuration.yaml"
                    USB_PATHS=(
                        "/dev/ttyUSB0"
                        "/dev/ttyACM0"
                        "/dev/ttyUSB1"
                        "/dev/ttyACM1"
                    )
                    flash_device() {
                        esphome $CONFIG_FILE run --port $1
                    }
                    nixpkgs.config.allowUnfree = true;
                    nixpkgs.config.segger-jlink.acceptLicense = true;
                    export NIXPKGS_ALLOW_UNFREE=true


                    echo "🚀 Attempting to flash automatically..."
                    if esphome $CONFIG_FILE run; then
                        echo "✨ Successfully flashed ESP32S3-BOX3!! 🚀"
                        exit 0
                    else
                        echo "⚠️ Automatic flash failed. Trying USB paths..."
                    fi
                    for path in $USB_PATHS; do
                        echo "🚀 Trying to flash on $path..."
                        if flash_device "$path"; then
                            echo "✨ Successfully flashed ESP32S3-BOX3 on $path!! 🚀"
                            exit 0
                        else
                            echo "⚠️ Flashing failed on $path. Trying next path..."
                        fi
                    done
                    echo "❌ Failed to flash ESP32S3-BOX3. Please check your device connection and paths."
                    exit 1
                ''}/bin/box";
            };
            
            apps.x86_64-linux.bootstrap = {
                type = "app";
                program = "${pkgs.writeShellScriptBin "bootstrap" ''        
                    set -x
                    systemctl --user start pcscd.service || sudo systemctl start pcscd.service
                    export PATH=${
                        pkgs.lib.makeBinPath [
                            pkgs.age
                            pkgs.curl
                            pkgs.git
                            pkgs.rage
                            pkgs.age-plugin-yubikey
                            pkgs.pcscliteWithPolkit
                            pkgs.yubico-pam
                            pkgs.coreutils 
                            pkgs.wget     
                            pkgs.sudo     
                        ]
                    }      

                    # Download Keys
                    curl https://m0ln.duckdns.org/Secrets/Keys/age@desktop -o /tmp/age@desktop
                    curl https://m0ln.duckdns.org/Secrets/Keys/id_ed25519@desktop -o /tmp/ssh@desktop

                    decrypt() {
                        local filepath="$1"
                        age-plugin-yubikey --identity --slot 1 > /tmp/yubikey-identity.txt
                        OUTPUT=$(rage -d "$filepath" -i /tmp/yubikey-identity.txt)
                    }         

                    # Decrypt Keys
                    mkdir -p /var/lib/sops-nix
                    mkdir -p /home/pungkula/.ssh
                    decrypt /tmp/age@desktop
                    echo "$OUTPUT" | sudo tee /var/lib/sops-nix/age.age
                    decrypt /tmp/ssh@desktop
                    echo "$OUTPUT" | sudo tee /home/pungkula/.ssh/id_ed25519

                    # Clone Dotfiles Repo & Build Packages 
                    git clone https://github.com/QuackHack-McBlindy/dotfiles.git /home/pungkula/dotfiles
                    git clone git@github.com:QuackHack-McBlindy/dotfiles.git /home/pungkula/dotfiles
                    cd /home/$USER/dotfiles/pkgs/voice-server
                    nix build
                    cd /home/$USER/dotfiles/pkgs/voice-client
                    nix build
                    cd /home/$USER/dotfiles/pkgs/caddy-duckdns
                    nix build
                  
                    # Clean up
                    rm -f /tmp/age@desktop /tmp/ssh@desktop /tmp/yubikey-identity.txt
                    NEWHOST="# DO NOT DELETE! This file is auto generated by QuackHack-McBlindy to detect new machines."
                    touch /home/$USER/.dotduck
                    echo "$NEWHOST" > /home/$USER/.dotduck
                    echo " "
                    echo " "
                    echo " "
                    echo "🚀🚀🚀🚀 ✨ "
                    echo "✨✨ Successfully prepared new machine for flake initziation!!"
                    echo "NEXT STEP: 🚀🚀🚀"
                    echo "1:"
                    echo "sudo nixos-rebuild switch --flake /home/pungkula/dotfiles#$HOSTNAME -v --show-trace"
                    echo "2:"
                    echo "sudo bash facter"
                  
                ''}/bin/bootstrap";
            };
    
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
#°✶.•°••─→ MACHINES ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
            nixosConfigurations = {
          
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
#°✶.•°••─→ DESKTOP ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
                desktop = nixpkgs.lib.nixosSystem {
                    inherit system;
                    specialArgs = { inherit user self system inputs; hostname = "desktop"; };
                    modules = [ ./hosts/desktop/configuration.nix   
                    #    nixos-facter-modules.nixosModules.facter
                     #   { config.facter.reportPath = ./hosts/desktop/facter.json; }            
                        disko.nixosModules.disko
                        homeConfigFiles
                        sops-nix.nixosModules.sops
                        home-manager.nixosModules.home-manager  
                        nixos-facter-modules.nixosModules.facter
                    ];
                };

#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
#°✶.•°••─→ PHONE ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
                phone = nixpkgs-mobile.lib.nixosSystem {
                    inherit aarch64;
                    specialArgs = { inherit user; hostname = "phone"; };
                    modules = [ ./hosts/phone/configuration.nix
                        homeConfigFiles
                        sops-nix.nixosModules.sops
                        home-manager.nixosModules.home-manager  
                        (import "${mobile-nixos}/lib/configuration.nix" {
                            device = "pine64-pinephone";
                        })
                    ];
                };

#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
#°✶.•°••─→ NASTY ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
                nasty = nixpkgs.lib.nixosSystem {
                    inherit system;
                    specialArgs = { inherit inputs user; hostname = "nasty"; };
                    modules = [ ./hosts/nasty/configuration.nix
                    #    inputs.nixos-facter-modules.nixosModules.facter
                  #      { config.facter.reportPath = ./hosts/desktop/facter.json; }            
                        disko.nixosModules.disko
                        homeConfigFiles
                        sops-nix.nixosModules.sops
                        home-manager.nixosModules.home-manager  
                        nixos-facter-modules.nixosModules.facter
                    ];     
                }; 
               
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
#°✶.•°••─→ HOMIE ←── •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
                homie = nixpkgs.lib.nixosSystem {
                    inherit system;
                    specialArgs = { inherit user inputs; hostname = "homie"; };
                    modules = [ ./hosts/homie/configuration.nix
                        disko.nixosModules.disko
                        homeConfigFiles
                        sops-nix.nixosModules.sops
                        home-manager.nixosModules.home-manager
                        nixos-facter-modules.nixosModules.facter
                          
                    ];
                };              

#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
#°✶.•°••─→ TINY ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
                tiny = nixpkgs.lib.nixosSystem {
                    system = "aarch64-linux"; 
                    specialArgs = { inherit user; hostname = "laptop"; };
                    modules = [ ./hosts/laptop/configuration.nix      
                        disko.nixosModules.disko
                        homeConfigFiles
                        sops-nix.nixosModules.sops
                        home-manager.nixosModules.home-manager
                        nixos-facter-modules.nixosModules.facter
                          
                       # networking.interfaces.eth0.ipv6.addresses = [
                       # {
                       #     address = "2001:db8:abcd:dead::1";
                       #     prefixLength = 64;
                       # }];
                    ];
                };              

#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
#°✶.•°••─→ LAPTOP ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
                laptop = nixpkgs.lib.nixosSystem {
                    inherit system;
                    specialArgs = { inherit user inputs; hostname = "laptop"; };
                    modules = [ ./hosts/laptop/configuration.nix      
                        disko.nixosModules.disko
                        homeConfigFiles
                        sops-nix.nixosModules.sops
                        home-manager.nixosModules.home-manager
                        nixos-facter-modules.nixosModules.facter
                          
                    ];
                };              

#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
#°✶.•°••─→ NiX BUILD! ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
                phone-image = 
                    (import "${mobile-nixos}/lib/eval-with-configuration.nix" {
                        configuration = [ import ./hosts/phone/configuration.nix ];
                        device = "pine64-pinephone";
                        pkgs = nixpkgs.legacyPackages.${system};
                    }).outputs.disk-image;
                };
              
                installer = auto-installer.nixosConfigurations.installer;
               # devShells.x86_64-linux.default = pkgs.mkShell {
                devShells."x86_64-linux".default = nixpkgs.legacyPackages."x86_64-linux".mkShell {
                   # packages = [ clan-core.packages."x86_64-linux".clan-cli ];
                    shellHook = ''
                        export NIX_PATH="nixpkgs=${inputs.nixpkgs}:.\?submodules=1"
                    '';
                    packages = [ pkgs.python3 pkgs.python3Packages.requests ];
                  #  packages = [ pkgs.python3 pkgs.python3Packages.requests pkgs.python3Packages.python-dotenv pkgs.python312Packages.sh pkgs.nixpkgs-fmt pkgs.android-tools ];
                };
              
              
          

      #        apps.default = config.apps.setup;

#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•
#°✶.•°••─→ bye: ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
      };
    
}

