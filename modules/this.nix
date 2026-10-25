# dotfiles/modules/this.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
# » ★ QuackHack-McBLindy.com ★ «
# 🦆 duck say ⮞ dis module is designed to define both user and host configurations
# 🦆 duck say ⮞ so dat modules can dynamically adapt
{
    config,
    lib,
    pkgs,
    self,
    ...
} : let
  inherit (lib) types mkOption mkEnableOption mkMerge;

  # beep when touch is required
  touchBeeper = pkgs.writeText "yubikey-beep.py" ''
    import math
    import os
    import shutil
    import socket
    import struct
    import subprocess
    import time
    import wave

    runtime = os.environ["XDG_RUNTIME_DIR"]
    sockpath = os.path.join(runtime, "yubikey-touch-detector.socket")
    wavpath = os.path.join(runtime, "yubikey-beep.wav")

    rate = 44100
    with wave.open(wavpath, "wb") as wav:
        wav.setnchannels(1)
        wav.setsampwidth(2)
        wav.setframerate(rate)
        samples = (
            int(10000 * math.sin(2 * math.pi * 880 * i / rate))
            for i in range(int(rate * 0.12))
        )
        wav.writeframes(b"".join(struct.pack("<h", s) for s in samples))

    player = shutil.which("pw-play") or shutil.which("paplay")
    if not player:
        raise SystemExit("Install pw-play or paplay first")

    print("Listening for YubiKey touch requests...", flush=True)

    while True:
        try:
            with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as s:
                s.connect(sockpath)
                s.settimeout(0.5)
                buf = b""
                pending = False
                next_beep = 0.0

                while True:
                    try:
                        data = s.recv(256)
                        if not data:
                            break
                        buf += data
                    except socket.timeout:
                        pass

                    while len(buf) >= 5:
                        event, buf = buf[:5], buf[5:]

                        if event == b"U2F_1":
                            pending = True
                            next_beep = 0.0
                        elif event == b"U2F_0":
                            pending = False

                    if pending and time.monotonic() >= next_beep:
                        subprocess.Popen(
                            [player, wavpath],
                            stdout=subprocess.DEVNULL,
                            stderr=subprocess.DEVNULL,
                        )
                        next_beep = time.monotonic() + 2.0

        except (OSError, ConnectionError) as e:
            print(f"Detector socket unavailable: {e}", flush=True)
            time.sleep(1)
  '';

in {
    options.this = {
#=== 🦆 duck say ⮞ TODO Remove =========================#
        installer = mkOption {
            type = types.bool;
            default = false;
            example = true;
            description = "Whether this system is used as an installer.";
        };
#=== 🦆 duck say ⮞ USER =========================#
        user = mkOption {
            type = types.submodule {
                options = {
                    enable = mkEnableOption "user configurations";
#============== 🦆 duck say ⮞ ME =========================#
                    me = {
                        name = mkOption {
                            type = types.str;
                            default = "pungkula";
                            example = "myUsername";
                            description = "Primary admin username";
                        };
                        hashedPassword = mkOption {
                            type = types.str;
                            default = "$y$j9T$m8hPD36i1VMaO5rurbZ4j0$KpzQyat.F6NoWFKpisEj77TvpN2wBGB8ezd26QoKDj6";
                            description = "Hashed password for main user, create one with mkpw";
                        };
                        extraGroups = mkOption {
                            type = types.listOf types.str;
                            default = [ "networkmanager" "wheel" "dialout" "docker" "dockeruser" "users" "pungkula" "adbusers" "audio" "at" ];
                            description = "Extra groups for main user";
                        };
                        repo = mkOption {
                            type = types.str;
                            default = "git@github.com:QuackHack-McBlindy/dotfiles.git";
                            example = "git@github.com/myUsername/dotfiles.git";
                            description = "The users GitHub dotfiles repository ";
                        };
                        discord = mkOption {
                            type = types.str;
                            default = "";
                            example = "https://discordapp.com/users/675530282849533952";
                            description = "Discord profile URL. Used for contact iformation in for example the README";
                        };
                        matrix = mkOption {
                            type = types.str;
                            default = "";
                            example = "https://matrix.to/#/#my-matrix-room:matrix.org";
                            description = "Matrix profile URL. Used for contact iformation in for example the README";
                        };
                        email = mkOption {
                            type = types.str;
                            default = "quackhack@protonmail.com";
                            example = "quackhack@protonmail.com";
                            description = "Email address. Used for contact iformation in for example the README";
                        };
                        dotfilesDir = mkOption {
                            type = types.str;
                            default = "/home/${config.this.user.me.name}/dotfiles";
                            example = "/home/myUsername/dotfiles";
                            description = "Path of the users flake directory";
                        };
                        mobileDevices = mkOption {
                          type = with types; attrsOf (submodule {
                            options = {
                              wgip = mkOption {
                                type = types.str;
                                description = "WireGuard IP address for the device";
                              };
                              pubkey = mkOption {
                               type = types.str;
                                description = "WireGuard public key for the device";
                              };
                            };
                          });
                          default = {
                            iphone = {
                              wgip = "10.0.0.7";
                              pubkey = "UFB0T1Y/uLZi3UBtEaVhCi+QYldYGcOZiF9KKurC5Hw=";
                            };
                            tablet = {
                              wgip = "10.0.0.8";
                              pubkey = "ETRh93SQaY+Tz/F2rLAZcW7RFd83eofNcBtfyHCBWE4=";
                            };
                          };
                          description = "Mapping of mobile devices to their WireGuard configurations.";
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
            };
            default = {};
            description = "User configuration settings";
        };

#=== 🦆 duck say ⮞ HOST =========================#
        host = {
            system = mkOption {
                type = types.str;
                example = "x86_64-linux";
                default = "x86_64-linux";
                description = "System architecture for the host. Available options are: x86_64-linux or aarch64-linux";
            };
            hostname = mkOption {
                type = types.str;
                example = "desktop";
                default = "nix";
                description = "System hostname";
            };

            interface = mkOption {
                type = types.listOf types.str;
                example = [ "enp119s0" ];
                default = [ "eth0" ];
                description = "Network interfaces to configure";
            };

            ip = mkOption {
                type = types.nullOr types.str;
                example = "192.168.1.100";
                default = null;
                description = "IP address to bind host to";
            };

            wgip = mkOption {
                type = types.nullOr types.str;
                example = "10.10.10.10";
                default = null;
                description = "WireGuard peer IP address";
            };

            modules = {
                hardware = mkOption {
                    type = types.listOf types.str;
                    example = [ "cpu/intel" "gpu/amd" ];
                    default = [];
                    description = "Hardware configuration modules to enable";
                };
                system = mkOption {
                    type = types.listOf types.str;
                    example = [ "nix" "pkgs" "gnome" ];
                    default = [];
                    description = "System-level modules to enable (e.g., desktop environments)";
                };
                networking = mkOption {
                    type = types.listOf types.str;
                    example = [ "default/wireless" "caddy" ];
                    default = [];
                    description = "Networking modules to enable";
                };
                services = mkOption {
                    type = types.listOf types.str;
                    example = [ "ssh" "pairdrop" ];
                    default = [];
                    description = "Service modules to enable";
                };
                programs = mkOption {
                    type = types.listOf types.str;
                    example = [ "default" "thunar" ];
                    default = [];
                    description = "Program modules to enable";
                };
                virtualisation = mkOption {
                    type = types.listOf types.str;
                    example = [ "docker" "vm" ];
                    default = [];
                    description = "Virtualisation modules to enable";
                };
            };
            keys = {
                privateKeys = mkOption {
                    type = types.attrsOf types.str;
                    example = {};
                    default = {};
                    description = "Private keys paths";
                };
                publicKeys = mkOption {
                    type = types.attrsOf types.str;
                    example = { host = "ssh-ed25519 AAAAC3..."; ssh = "ssh-ed25519 AAAAC3..."; age = "age16u..."; wireguard = "Oq0Za..."; };
                    description = "Public keys configuration";
                    default = {};
                };
            };
        };
    };


#== CONFIG ====================#
    config = lib.mkMerge [
        (lib.mkIf config.this.user.enable (lib.mkMerge [
            {
                users = {
                    mutableUsers = false;
                    defaultUserShell = pkgs.bash;
                    groups = lib.mkMerge [
                        { "${config.this.user.me.name}" = { gid = 1337; }; }
                        { nixos = {}; }
                    ];
                    users = lib.mkMerge [
                        {
                            root.hashedPassword = config.this.user.me.hashedPassword;
                            "${config.this.user.me.name}" = {
                                isNormalUser = true;
                                description = config.this.user.me.name;
                                uid = 1337;
                                group = config.this.user.me.name;
                                extraGroups = config.this.user.me.extraGroups;
                                hashedPassword = config.this.user.me.hashedPassword;
                            };
                        }
                        (lib.mkIf config.this.user.builder.enable {
                            builder = {
                                isNormalUser = true;
                                home = "/root";
                                shell = pkgs.bash;
                                openssh.authorizedKeys.keys = config.this.user.builder.sshKeys;
                                extraGroups = [ "wheel" "builders" ];
                            };
                        })
                    ];
                };
            }
            (lib.mkIf config.this.user.yubikey.enable {
                environment.systemPackages = with pkgs; [
                    age-plugin-yubikey
                    yubioath-flutter
                    yubikey-agent
                    yubikey-personalization
                    yubikey-manager
                    yubikey-touch-detector
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
                ];

                security.pam = {
                    u2f = {
                        enable = true;
                        authFile = pkgs.writeText "u2f-mappings" (lib.concatStrings [
                            config.this.user.me.name
                            ":9LQVoQZaxoQ/BTFqI7PP84iW3aQtK4mgo6exBlXa/ajQJdF7/axiOCaSXlceKKx4zlPHdYbk5QN2jvP51QJasA==,pMW+NzKDm9unMiKIihpODB9bFRpCKxco0ZrA2l8N+57ht+4lCex8JztmpFic2llij1Ca9dbaIFsWqwfZeZ2beQ==,es256,+presence"
                            ":hTBhiePfih30Js9W775rup8mCJSgqBZqfMZeqsairqQ3s2q6phv55G+K0cMNbAMClnTD/T1ynQxzX0t/c+YAkg==,EuFh8q+uTdsRG48VGIdGnTxoKgxfaO5rfDPSrMQoNQE4O1i+xkHsX6X0d+Cd6vr+KI4uMkuNNq+nq2Rv9+e81A==,es256,+presence"
                        ]);
                        origin = "pam://yubi";
                        appId = "pam://yubi";
                        cue = true;
                        interactive = false;
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

                services.pcscd.enable = true;

                services.udev.extraRules = ''
                    ACTION=="remove",\
                    ENV{ID_BUS}=="usb",\
                    ENV{ID_MODEL_ID}=="0407",\
                    ENV{ID_VENDOR_ID}=="1050",\
                    ENV{ID_VENDOR}=="Yubico",\
                    RUN+="${pkgs.systemd}/bin/loginctl lock-sessions"
                '';

                systemd.user.services.yubikey-beep = {
                  description = "Beep while waiting for YubiKey touch";
                  wantedBy = [ "default.target" ];
                  after = [ "yubikey-touch-detector.service" ];
                  wants = [ "yubikey-touch-detector.service" ];

                  serviceConfig = {
                    Type = "simple";
                    ExecStart = "${pkgs.python3}/bin/python ${touchBeeper}";
                    Restart = "always";
                    RestartSec = "2s";
                  };
                  path = [
                    pkgs.pipewire
                    pkgs.pulseaudio
                  ];
                };

            })
            (lib.mkIf config.this.user.builder.enable {
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
            (lib.mkIf (config.this.user.i18n != null) {
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
                    ] (name: config.this.user.i18n);
                };
            })
        ]))
        {
            _module.args.this = {
                mkModule = moduleType: name: config:
                    lib.mkIf (lib.elem name config.this.host.modules.${moduleType}) config;
            };
            _module.args.hosts = lib.genAttrs (builtins.attrNames self.nixosConfigurations) (name:
                self.nixosConfigurations.${name}.config.this.host
            );
            _module.args.zigduck = {
                inherit (config.services.zigduck) stateDir;
                inherit (config.house.zigbee.mosquitto) baseTopic;
            };
            _module.args.icons = {
                nas            = "mdi:nas";
                desktop        = "mdi:desktop-tower";
                laptop         = "mdi:laptop";
                remote         = "mdi:remote";
                outlet         = "mdi:power-socket-eu";
                dimmer         = "mdi:toggle-switch";
                pusher         = "mdi:gesture-tap-button";
                blinds         = "mdi:blinds";
                watch          = "mdi:watch";
                tv             = "mdi:television";
                microphone     = "mdi:microphone";
                brightness     = "mdi:brightness-6";
                battery        = "mdi:battery";
                wifi           = "mdi:wifi";
                display        = "mdi:monitor";
                display_page   = "mdi:monitor-dashboard";
                mic_off        = "mdi:microphone-off";
                volume         = "mdi:volume-high";
                mute           = "mdi:volume-off";
                amplifier      = "mdi:amplifier";
                speaker        = "mdi:speaker";
                cast           = "mdi:cast-audio";
                play_pause     = "mdi:play-pause";
                cpu            = "mdi:cpu-64-bit";
                power_sleep    = "mdi:power-sleep";
                console        = "mdi:console";
                vpn            = "mdi:vpn";
                uptime         = "mdi:clock-check";
                bell           = "mdi:bell-ring";
                check          = "mdi:check-circle";
                skip_prev      = "mdi:skip-previous";
                skip_next      = "mdi:skip-next";
                heart          = "mdi:heart";
                playlist_remove = "mdi:playlist-remove";
                voice           = "mdi:account-voice";
                wakeword        = "mdi:ear-hearing";
                intercom        = "mdi:phone-in-talk";
                light = {
                    ceiling     = "mdi:ceiling-light";
                    strip       = "mdi:led-strip";
                    spotlight   = "mdi:spotlight";
                    bulb        = "mdi:lightbulb";
                    bulb_color  = "mdi:lightbulb-multiple";
                    desk        = "mdi:desk-lamp";
                    floor       = "mdi:floor-lamp";
                    wall        = "mdi:wall-sconce-round";
                    chandelier  = "mdi:chandelier";
                    pendant     = "mdi:vanity-light";
                    nightlight  = "mdi:lightbulb-night";
                    strip_rgb   = "mdi:led-strip-variant";
                    reading     = "mdi:book-open-variant";
                    candle      = "mdi:candle";
                    ambient     = "mdi:weather-night";
                };
                sensor = {
                    motion      = "mdi:motion-sensor";
                    smoke       = "mdi:smoke-detector";
                    water       = "mdi:water";
                    contact     = "mdi:door";
                    temperature = "mdi:thermometer";
                    humidity    = "mdi:water-percent";
                };
                room = {
                    bedroom    = "mdi:bed";
                    hallway    = "mdi:door";
                    kitchen    = "mdi:food-fork-drink";
                    livingroom = "mdi:sofa";
                    wc         = "mdi:toilet";
                    other      = "mdi:dots-horizontal";
                };
            };
            _module.args.me       = { config, ... }: config.this.user.me;
            _module.args.devices  = config.house.devices;
        }

    ];}
