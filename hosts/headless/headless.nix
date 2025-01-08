# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, h0st, hostname, ... }:

{
  imports = [ ./hardware-configuration.nix 
 
 ];

#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ BOOT LOADER ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ NETWORKING ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°

  networking = { 
      hosts = {
         # "127.0.0.1" = [ "foo.bar.baz" ];
          "192.168.1.1" = [ "archer.lan" "archer.local" "archer" ];
          "192.168.1.111" = [ "desktop.lan" "desktop.local" "desktop" ];
          "192.168.1.122" = [ "lappy.lan" "lappy.local" "lappy" ];
          "192.168.1.28" = [ "nasty.lan" "nasty.local" "nasty" ];
          "192.168.1.44" = [ "iphone.lan" "iphone.local" "iphone" ];
          "192.168.1.45" = [ "phone.lan" "phone.local" "phone" ];
          "192.168.1.150" = [ "usb.lan" "usb.local" "usb" ];
          "192.168.1.155" = [ "arris.lan" "arris.local" "arris" ];
          "192.168.1.159" = [ "pi.lan" "pi.local" "pi" ];
          "192.168.1.181" = [ "ha.lan" "ha.local" "ha" ];
          "192.168.1.223" = [ "shield.lan" "shield.local" "shield" ];
      };   
      hostName = hostname;
      networkmanager.enable = true; 
      firewall = {
          enable = true;  #    ?    ?    ?    ?    
          allowedUDPPorts = [ 1704 1705 6001 6002 ];
#                              ?    ?                   
          allowedTCPPorts = [ 1714 1715 ];
      };
  };    
    

  # Configure console keymap
  console.keyMap = "sv-latin1";


  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    viu # display images terminal
    catimg # ascii art from img
    ncurses
    dialog
    vim
    wget
    curl
    git
    gnome-terminal

    glib


  ];
      


#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ USERS ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.pungkula = {
    isNormalUser = true;
    description = "pungkula";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };



  #  users.users.pungkula.group = "pungkula";
    #users.groups.pungkula = {};

#    users.defaultUserShell = pkgs.bash; 
 #   users.users.${user} = {
        #hashedPassword = "$6$ywtdfbhjDtQE9b5s$fPIAqx0fCkd2G07Sz8SeJzr.Ds.yFb69SEJL3Oj.o6crBAXH3ExWdZnlwGIsbeSPAkB4QR.fazgVfHZW0gwvf0";
  #      password = "qwerty";
  #      isSystemUser = true; 
   #     description = "${user}";
   #     extraGroups = [ "networkmanager" "wheel" "qemu-libvirtd" "libvirtd" "kvm" "docker" "amdgpu" ];
   #     packages = with pkgs; [
  #          xdg-utils
     #       xwaylandvideobridge
  #      ];
  #      openssh.authorizedKeys.keys = [
  #          "ssh-rsa x7qq8zRAH5jdxUduQ/ThAmvjYm91H42QVm70OCFjjb8dg9LIb/va2j1eakNlBiwCmUK7frmRkWjFj+2t5zCTd2iLpygLv7PvFVIidxAoXLdTxilAAg2ZlX/xSGvRPkaqX/ZQfR5j3OCVYy6aV4VonbIUids7kUynRz9SRN2AHmLpK/oniwlwhAS5aa0PvC8Ln7x3wzhH501sLKk+krNpOEr4E1AA/VwOMqSqU4KTMoYzkUix9YnnAf70AQV6rZ4NxNrqWcZve/UGqMxtUbxMP7rL8hxKihc0Zdus5zxDEZ36oXIDYq9kQ3KgJZx4aVPePEX68A8fxhx6zIOfsg0Hz6M3ko53MhG/qZhYmDvTG1548tgn24gQjEawRjUc2a6gEH+va+TP99260ELeWZD3AHzIzL+ln4BBGcYgNglkIxpI5gH7LqeQ+XHlW8iQbnlfRUYKo72MGA8KLDPP3IHhWa5cSN4DKBlgEJ8ijUbcYqES4dK34cqyM1JWVTnEdw== pungkula@desktop.com"
    #        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE6UXhj/qh1qSnHdAuPyOUr0OQyJ1QIy5QlZu3y7CaGV pungkula@desktop"
   #         "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE6UXhj/qh1qSnHdAuPyOUr0OQyJ1QIy5QlZu3y7CaGV"       
  #      ];
  #  };

  #  security.sudo = {
  #      enable = true;
  #      extraConfig = ''
  #          %wheel ALL=(ALL) NOPASSWD: ALL
   #     '';
 #   };
  # swaylock pass verify
#    security.pam.services.swaylock = {
 #     text = ''
 #     auth include login
 #     '';
 #   };
  
    services.gnome.gnome-keyring.enable = true;

    services.gvfs.enable = true; 
 #   programs.dconf.enable = lib.mkDefault true;
    


#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ NIX ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°

  documentation.nixos.enable = false;
  nixpkgs.config.allowUnfree = true;

  nix = {
	settings = {
		warn-dirty = false;
		experimental-features = [ "nix-command" "flakes" ];
		auto-optimise-store = true;
		#sandbox = true;
                log-lines = 15;
                min-free = 1073741824; # 1GiB
                max-free = 8589934592; # 8GiB
                builders-use-substitutes = true;
                trusted-users = [
                    "root"
                    "pungkula"
                ];
	};
	
	gc = {
		automatic = true;
		dates = "weekly";
		options = "--delete-older-than 7d";
	};
  };


#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ i18n ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°

    services.locate.enable = true;
    time.timeZone = "Europe/Stockholm";
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

#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ FONTS ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°


  fonts = {
      enableDefaultFonts = true;
      fontDir.enable = true;
      packages = builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);
      fonts = with pkgs; [     
          fira-mono
          libertine
          open-sans
          twemoji-color-font
          liberation_ttf
          font-awesome 
          jetbrains-mono
         # nerdfonts.JetBrainsMono
      ];

      fontconfig = {
          enable = true;
          antialias = true;
          defaultFonts = {
              monospace = [ "Fira Mono" ];
              serif = [ "Linux Libertine" ];
              sansSerif = [ "Open Sans" ];
              emoji = [ "Twitter Color Emoji" ];
          };
     };
  };


#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ SECURITY ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°

#  sops = {
#    defaultSopsFile = "/var/lib/sops-nix/.sops.yaml";
#    defaultSopsFormat = "yaml";
#    validateSopsFiles = false;
#    age.keyFile = "/var/lib/sops-nix/key.txt";
#    secrets = {
#      SHADOWSOCKS_PASSWORD = {
#        sopsFile = "/var/lib/sops-nix/secrets/SHADOWSOCKS_PASSWORD.json"; # Specify SOPS-encrypted secret file
#        owner = config.users.users.secretservice.name;
#        group = config.users.groups.secretservice.name;
#        mode = "0440"; # Read-only for owner and group
#      };
#      secretservice = {
#        sopsFile = "/var/lib/sops-nix/secrets/secretservice.json"; # Specify SOPS-encrypted secret file
#        owner = config.users.users.secretservice.name;
#        group = config.users.groups.secretservice.name;
#        mode = "0440"; # Read-only for owner and group
#      };
#    };
#  };  
#  systemd.services.secretservice = {
#    script = ''
#        echo "
#        Hey bro! I'm a service, and imma send this secure password:
#        $(cat ${config.sops.secrets.secretservice.path})
#        located in:
#        ${config.sops.secrets.secretservice.path}
#        to database and hack the mainframe
#        " > /var/lib/secretservice/testfile
#    '';
#    serviceConfig = {
#      User = "secretservice";
#      WorkingDirectory = "/var/lib/secretservice";
#    };
#  };
#  users.users.secretservice = {
#    home = "/var/lib/secretservice";
#    createHome = true;
#    isSystemUser = true;
#    group = "secretservice";
#  };
#  users.groups.secretservice = { };


#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ OPTIONALS ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°

  # Enable CUPS to print documents.
#  services.printing.enable = true;


#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ CROSS ENV  ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°

  # Ensure these packages are available in the PATH
#  nixpkgs.config.packageOverrides = pkgs: {
#    myCrossEnv = pkgs.stdenv.mkDerivation {
#      name = "my-cross-env";
#      buildInputs = [
#        pkgs.glib
#        pkgs.pkg-config
#        pkgs.cmake
#      ];
#    };
#  };



  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
