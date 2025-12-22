# https://joinemm.dev/blog/yubikey-nixos-guide
# In depth setup guide: 
# https://github.com/drduh/YubiKey-Guide/

# For secure setup enviorment, use:
# dotfiles/modules/nixos/images/yubikey-env.nix

# yubikey-agent --generate
# age-plugin-yubikey --generate

{ config, inputs, pkgs, lib, ... }:
let
  user = "pungkula";
in
{
    config = lib.mkIf (lib.elem "pam" config.this.host.modules.hardware) {
      environment.systemPackages = with pkgs; [
        age-plugin-yubikey
        yubioath-flutter
        yubikey-agent
        #yubikey-manager-qt
      #  yubikey-touch-detector
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


    ###################
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
          group = config.my.users.me.name;
          mode = "0440"; # Read-only for owner and group
        };
      };



    ###################
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
        debug = true;
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

    ###################
    # GPG
    #  services = {
    #    pcscd.enable = true;
     #   udev.packages = [ pkgs.yubikey-personalization ];
     # };
    ###################
    # Touch Detector
      # Enable the yubikey-touch-detector service
      programs.yubikey-touch-detector = {
        enable = true;
        unixSocket = true;
        libnotify = true;
        verbose = true;
      };
      # Install the yubikey-touch-detector package
    #  systemd.packages = [ pkgs.yubikey-touch-detector ];

      # Configure the systemd user service for yubikey-touch-detector
    #  systemd.user.services.yubikey-touch-detector = {
    #    description = "YubiKey Touch Detector";
    #    path = [ pkgs.gnupg ]; # Include dependencies, such as gnupg
    #    wantedBy = [ "graphical-session.target" ]; # Start the service when the graphical session is up
    #    serviceConfig = {
    #      ExecStart = "${pkgs.yubikey-touch-detector}/bin/yubikey-touch-detector"; # Path to the executable
    #      Restart = "always"; # Ensure the service restarts if it crashes
    #    };
    #  };

      # Configure the systemd user socket for yubikey-touch-detector
     # systemd.user.sockets.yubikey-touch-detector = {
    #    description = "YubiKey Touch Detector Socket";
     #   wantedBy = [ "sockets.target" ]; # Start the socket when the systemd socket target is reached
    #  };

      # Optionally, ensure `gnupg` is installed
     # environment.systemPackages = [ pkgs.gnupg ];


    };}
