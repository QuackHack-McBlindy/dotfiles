{ 
    config,
    pkgs,
    lib,
    user,
    ...
} : let
    inherit (lib) mkEnableOption mkOption types;
    cfg = config.my.users;
in {
    options.my.users = {
        enable = mkEnableOption "user configurations";

        me = {
            name = mkOption {
                type = types.str;
                default = "pungkula";
                description = "Primary username";
            };

            hashedPassword = mkOption {
                type = types.str;
                default = "$y$j9T$m8hPD36i1VMaO5rurbZ4j0$KpzQyat.F6NoWFKpisEj77TvpN2wBGB8ezd26QoKDj6";
                description = "Hashed password for main user";
            };

            extraGroups = mkOption {
                type = types.listOf types.str;
                default = [ "networkmanager" "wheel" "dialout" "docker" "dockeruser" "users" "pungkula" ];
                description = "Extra groups for main user";
            };
        };

        builder = {
            enable = mkOption {
                type = types.bool;
                default = false;
                description = "Enable Nix OS builder user";
            };

            sshKeys = mkOption {
                type = types.listOf types.str;
                default = [];
                description = "Authorized SSH public keys for remote builder user";
            };
        };

        yubikey = {
            enable = mkOption {
                type = types.bool;
                default = false;
                description = "Enable YubiKey and PAM authentication";
            };
        };

        i18n = mkOption {
            type = types.nullOr types.str;
            default = "sv_SE.UTF-8";
            example = "sv_SE.UTF-8";
            description = "Specifies the locale, enabling locate, timeZone, and console keymap configurations";
        };
    };

    #config = lib.mkIf cfg.enable {
    config = lib.mkIf cfg.enable (lib.mkMerge [
        {
            users = {
                mutableUsers = false;
                defaultUserShell = pkgs.bash;

                groups = lib.mkMerge [
                    { "${cfg.me.name}" = {}; }
                    { nixos = {}; }
                ];

                users = lib.mkMerge [
                    {
                        root.hashedPassword = "*";

                        "${cfg.me.name}" = {
                            isNormalUser = true;
                            description = cfg.me.name;
                            group = cfg.me.name;
                            extraGroups = cfg.me.extraGroups;
                            hashedPassword = cfg.me.hashedPassword;
                        };
                    }

                    (lib.mkIf cfg.builder.enable {
                        builder = {
                            isNormalUser = true;
                            home = "/root";
                            shell = pkgs.bash;
                            openssh.authorizedKeys.keys = cfg.builder.sshKeys;
                            extraGroups = [ "wheel" "builders" ];
                        };
                    })
                ];
            };
        }    

        # In depth setup guide: https://github.com/drduh/YubiKey-Guide/
        (lib.mkIf cfg.yubikey.enable {
            environment.systemPackages = with pkgs; [
                age-plugin-yubikey
                yubioath-flutter
                yubikey-agent
                yubikey-personalization-gui
                yubikey-personalization    
                yubikey-manager    
                pam_u2f
                libu2f-host
                libykclient
                yubico-pam
                yubico-piv-tool
                piv-agent
                pcsclite
                pcscliteWithPolkit
                pcsc-tools
                acsccid
                # yubikey-manager-qt
                # yubikey-touch-detector
            ];
            
            security.pam = {
                u2f = {   # Create key with: `pamu2fcfg`
                    enable = true;
                  #  control = "sufficient"; # Key instead of password (No 2FA)
                    authFile = pkgs.writeText "u2f-mappings" (lib.concatStrings [
                        user
                        ":9LQVoQZaxoQ/BTFqI7PP84iW3aQtK4mgo6exBlXa/ajQJdF7/axiOCaSXlceKKx4zlPHdYbk5QN2jvP51QJasA==,pMW+NzKDm9unMiKIihpODB9bFRpCKxco0ZrA2l8N+57ht+4lCex8JztmpFic2llij1Ca9dbaIFsWqwfZeZ2beQ==,es256,+presence"
                        ":hTBhiePfih30Js9W775rup8mCJSgqBZqfMZeqsairqQ3s2q6phv55G+K0cMNbAMClnTD/T1ynQxzX0t/c+YAkg==,EuFh8q+uTdsRG48VGIdGnTxoKgxfaO5rfDPSrMQoNQE4O1i+xkHsX6X0d+Cd6vr+KI4uMkuNNq+nq2Rv9+e81A==,es256,+presence"
                    ]); 
                    origin = "pam://yubi";
                    appId = "pam://yubi";    # To keep compat across devices
                    cue = true;              # Prompts for Touch
                    interactive = false;     # Prompts for Enter keypress
                };   
                yubico = {
                    enable = true;
                    debug = false;
                    mode = "challenge-response";  
                    id = [ "16644366" "16038710" ];
                };
                services = {
                    login.u2fAuth = true;
                    sudo.u2fAuth = true;
                }; 
            };
            
            programs.yubikey-touch-detector = {
                enable = true;
                unixSocket = true;
                libnotify = true;
                verbose = true;
            };
          
            # smart card mode (CCID) for gpg keys
            services.pcscd.enable = true;
  
            # Lockdown When Unplugged
            services.udev.extraRules = ''
                ACTION=="remove",\
                ENV{ID_BUS}=="usb",\
                ENV{ID_MODEL_ID}=="0407",\
                ENV{ID_VENDOR_ID}=="1050",\
                ENV{ID_VENDOR}=="Yubico",\
                RUN+="${pkgs.systemd}/bin/loginctl lock-sessions"
            '';
        })    
 
        # Allows builder user to perform nix commands wiithout password
        (lib.mkIf cfg.builder.enable {
            security.sudo = {
                enable = true;
                extraRules = [
                    {
                        users = [ "builder" ];
                        commands = [
                            {
                                command = "${pkgs.nix}/bin/nix";
                                options = [ "NOPASSWD" ];
                            }
                            {
                                command = "${pkgs.nixos-rebuild}/bin/nixos-rebuild";
                                options = [ "NOPASSWD" ];
                            }
                            {
                                command = "/nix/store/*/activate";
                                options = [ "NOPASSWD" ];
                            }
                        ];
                    }
                ];
            };
        })
        
        # Sets locale options
        (lib.mkIf (cfg.i18n != null) {
            services.locate.enable = true;
            time.timeZone = "Europe/Stockholm";
            i18n = {
                defaultLocale = "en_US.UTF-8";
                consoleKeyMap = "sv-latin1";
                extraLocaleSettings = lib.genAttrs [
                    "LC_ADDRESS"
                    "LC_IDENTIFICATION"
                    "LC_MEASUREMENT"
                    "LC_MONETARY"
                    "LC_NAME"
                    "LC_NUMERIC"
                    "LC_PAPER"
                    "LC_TELEPHONE"
                    "LC_TIME"
                ] (name: cfg.i18n);
            };
        })
        
    ]);}
