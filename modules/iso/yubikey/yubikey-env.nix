# # https://github.com/drduh/YubiKey-Guide/
# NixOS livesystem to generate yubikeys in an air-gapped manner
# $ nixos-generate -f iso -c yubikey-env.nix
#
# to test it in a vm:
#
# $ nixos-generate --run -f vm -c yubikey-env.nix
{ pkgs, ... }:
let
  guide = pkgs.stdenv.mkDerivation {
    name = "yubikey-guide-2024-02-12.html";
    src = pkgs.fetchFromGitHub {
      owner = "drduh";
      repo = "YubiKey-Guide";
      rev = "53ed405";
      sha256 = "sha256-dY8MFYJ9WSnvcfa8d1a3gNt52No7eN8aacky1zwJpbI=";
    };
    buildInputs = [ pkgs.pandoc ];
    installPhase = ''
      pandoc --highlight-style pygments -s --toc README.md | \
        sed -e 's/<keyid>/\&lt;keyid\&gt;/g' > $out
    '';
  };
in
{
  environment.interactiveShellInit = ''
    export GNUPGHOME=/run/user/$(id -u)/gnupghome
    if [ ! -d $GNUPGHOME ]; then
      mkdir $GNUPGHOME
    fi
    cp ${
      pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/drduh/config/944faed/gpg.conf";
        sha256 = "sha256-3oTHeGZ9nGJ+g+lnRSEcyifNca+V9SlpjBV1VNvrnNU=";
      }
    } "$GNUPGHOME/gpg.conf"
    echo "\$GNUPGHOME has been set up for you. Generated keys will be in $GNUPGHOME."
  '';

  environment.systemPackages = with pkgs; [
    cryptsetup
    pwgen
    midori
    paperkey
    gnupg
  #  gpg2
 #   gnupg22
 #   smimesign
 #   pinentry-gnome3
    pinentry-curses # pinentry pinentry-curses pinentry-tty
    ctmg
    
    # Tools for backing up keys
    pgpdump
    parted
    cryptsetup
    # Testing
    ent
    # Password generation tools
#    diceware
#    dicewareWebApp
    pwgen
    rng-tools
                # Might be useful beyond the scope of the guide
    cfssl
    pcsctools
    tmux
    htop

    # Custom
    age-plugin-yubikey
 #   yubioath-flutter
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
 #   piv-agent
    pcsclite
#    pcscliteWithPolkit
 #   pcsc-tools
    acsccid
    age
    sops
    
    busybox
    usbutils
    nixos-generators
    nano
  #  gnome-terminal  
    #gnome-settings-daemon43
  ];

  services.udev.packages = with pkgs; [yubikey-personalization];
  services.pcscd.enable = true;

  # make sure we are air-gapped
  networking = { 
      dhcpcd.enable = false;
      wireless.enable = false;
      hostName = "yubikey";
      networkmanager.enable = false; 
      firewall = {
          enable = true;
          allowedUDPPorts = [ ];
          allowedTCPPorts = [ ];
      };
  };    

  services.getty.helpLine = "The 'root' account has an empty password.";

  security.sudo = {
    wheelNeedsPassword = false;
    extraConfig = ''
      %wheel ALL=(ALL) NOPASSWD: ALL
    '';
  };
  users.users.yubikey = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = "/run/current-system/sw/bin/bash";
  };

  i18n = {
     # defaultLocale = "sv_SE.UTF-8";
      defaultLocale = "en_US.UTF-8";
      # consoleFont   = "lat9w-16";
      consoleKeyMap = "sv-latin1";
      extraLocaleSettings = {
          LC_ADDRESS = "sv_SE.UTF-8";
          LC_IDENTIFICATION = "sv_SE.UTF-8";
          LC_MEASUREMENT = "sv_SE.UTF-8";
          LC_MONETARY = "sv_SE.UTF-8";
          LC_NAME = "sv_SE.UTF-8";
          LC_NUMERIC = "sv_SE.UTF-8";
          LC_PAPER = "sv_SE.UTF-8";
          LC_TELEPHONE = "sv_SE.UTF-8";
          LC_TIME = "sv_SE.UTF-8";
      };
  };

  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;
  services.xserver = {
    enable = true;
 #   xkb.layout = "se";
 #   xkb.options = "eurosign:e";
    displayManager.gdm.enable = true;
    displayManager.gdm.wayland = true;
  
    displayManager.autoLogin.enable = true;
    displayManager.autoLogin.user = "yubikey";
    displayManager.defaultSession = "gnome";
#    displayManager.sessionCommands = ''
#      ${pkgs.midori}/bin/midori ${guide} &
#      ${pkgs.xfce.xfce4-terminal}/bin/xfce4-terminal &
#    '';

    desktopManager = {
      xterm.enable = false;
      gnome.enable = true;
    };
  };
}
# ykman openpgp set-touch aut off
# ykman openpgp set-touch sig on
# ykman openpgp set-touch enc on

