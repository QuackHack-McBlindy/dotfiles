# https://joinemm.dev/blog/yubikey-nixos-guide
# In depth setup guide: 
# https://github.com/drduh/YubiKey-Guide/

# For secure setup enviorment, use:
# dotfiles/modules/nixos/images/yubikey-env.nix

# yubikey-agent --generate
# age-plugin-yubikey --generate

{ config, inputs, pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; [
    age-plugin-yubikey
    yubioath-flutter
    yubikey-agent
    yubikey-manager-qt
    yubikey-touch-detector
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
  ];
  
  
###################
# > YUBIKEY-AGENT
# Sets SSH_AUTH_SOCK to point at yubikey-agent.
# Note that yubikey-agent will use whatever pinentry is specified in programs.gnupg.agent.pinentryPackage.

  services.yubikey-agent = {
    enable = true;
    package = pkgs.yubikey-agent;
  };


###################
# > PAM
  security.pam.u2f = {
    enable = true;
    cue = true;              # Prompts for Touch
  # interactive = false;     # Prompts for Enter keypress
  # appId = "pam://yubi"; # To keep compat across devices
  # create key: `pamu2fcfg`
  # authFile = pkgs.writeText "u2f_keys" ''
  # key
  # '';
  };
  
  security.pam.services = {
    login.u2fAuth = true;
    sudo.u2fAuth = true;
  };
  
  security.pam.yubico = {
     enable = true;
     debug = true;
     mode = "challenge-response";  
     id = [ "16644366" ];
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
  systemd.packages = [ pkgs.yubikey-touch-detector ];

  # Configure the systemd user service for yubikey-touch-detector
  systemd.user.services.yubikey-touch-detector = {
    description = "YubiKey Touch Detector";
    path = [ pkgs.gnupg ]; # Include dependencies, such as gnupg
    wantedBy = [ "graphical-session.target" ]; # Start the service when the graphical session is up
    serviceConfig = {
      ExecStart = "${pkgs.yubikey-touch-detector}/bin/yubikey-touch-detector"; # Path to the executable
      Restart = "always"; # Ensure the service restarts if it crashes
    };
  };

  # Configure the systemd user socket for yubikey-touch-detector
  systemd.user.sockets.yubikey-touch-detector = {
    description = "YubiKey Touch Detector Socket";
    wantedBy = [ "sockets.target" ]; # Start the socket when the systemd socket target is reached
  };

  # Optionally, ensure `gnupg` is installed
 # environment.systemPackages = [ pkgs.gnupg ];

}
