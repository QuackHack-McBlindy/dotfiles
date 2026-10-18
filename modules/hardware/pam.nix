# dotfiles/modules/hardware/pam.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
# » ★ QuackHack-McBLindy.com ★ «
{ # 🦆 says ⮞ yubikey configuration - qwack
  config,
  inputs,
  pkgs,
  lib,
  ...
} : let
  user = config.this.user.me.name;

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
    config = lib.mkIf (lib.elem "pam" config.this.host.modules.hardware) {
      environment.systemPackages = with pkgs; [
        age-plugin-yubikey
        yubioath-flutter
        yubikey-agent
        #yubikey-manager-qt
        yubikey-touch-detector
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
      ];


    # ───────────────────────────────────────────────────────────────────────
    # > YUBIKEY-AGENT
    # Sets SSH_AUTH_SOCK to point at yubikey-agent.
    # Note that yubikey-agent will use whatever pinentry is specified in programs.gnupg.agent.pinentryPackage.

      services.yubikey-agent = {
        enable = true;
        package = pkgs.yubikey-agent;
      };
                                                                                                sops.secrets = {
        u2f_keys = {
          sopsFile = ./../../secrets/u2f_keys.yaml;
          owner = config.my.users.me.name;
          group = config.this.user.me.name;
          mode = "0440"; # Read-only for owner and group
        };
      };



    # ───────────────────────────────────────────────────────────────────────
    # > PAM

      security.pam.u2f = {
        enable = true;
        cue = true;              # Prompts for Touch
      # interactive = false;     # Prompts for Enter keypress
        appId = "pam://yubi"; # To keep compat across devices
        origin = "pam://yubi";
    #     create key: `pamu2fcfg`
        authFile = pkgs.writeText "u2f-mappings" (lib.concatStrings [
          user
          ":9LQVoQZaxoQ/BTFqI7PP84iW3aQtK4mgo6exBlXa/ajQJdF7/axiOCaSXlceKKx4zlPHdYbk5QN2jvP51QJasA==,pMW+NzKDm9unMiKIihpODB9bFRpCKxco0ZrA2l8N+57ht+4lCex8JztmpFic2llij1Ca9dbaIFsWqwfZeZ2beQ==,es256,+presence"
          ":hTBhiePfih30Js9W775rup8mCJSgqBZqfMZeqsairqQ3s2q6phv55G+K0cMNbAMClnTD/T1ynQxzX0t/c+YAkg==,EuFh8q+uTdsRG48VGIdGnTxoKgxfaO5rfDPSrMQoNQE4O1i+xkHsX6X0d+Cd6vr+KI4uMkuNNq+nq2Rv9+e81A==,es256,+presence"
      ]);
      };
      security.pam.services = {                                                                   login.u2fAuth = true;                                                                     sudo.u2fAuth = true;
      };

      security.pam.yubico = {
        enable = true;
        debug = false;
        mode = "challenge-response";
        id = [ "16644366" "16038710" ];
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

    # security.pam.services.swaylock = {};
    # security.pam.loginLimits = [
    #     { domain = "@users"; item = "rtprio"; type = "-"; value = 1; }
    # ];

    # ───────────────────────────────────────────────────────────────────────
    # GPG
    #  services = {
    #    pcscd.enable = true;
     #   udev.packages = [ pkgs.yubikey-personalization ];
     # };
    # ───────────────────────────────────────────────────────────────────────
    # Touch Detector

      programs.yubikey-touch-detector = {
        enable = true;
        unixSocket = true;
        libnotify = true;
        verbose = true;
      };

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

    };}
