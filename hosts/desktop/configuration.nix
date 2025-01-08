# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, user, host, hostname, ... }:

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
          "192.168.1.1" = [ "archer.lan" "archer.local" "archer" ];
          "192.168.1.111" = [ "desktop.lan" "desktop.local" "desktop" ];
          "192.168.1.222" = [ "laptop.lan" "laptop.local" "laptop" ];
          "192.168.1.28" = [ "nasty.lan" "nasty.local" "nasty" ];
          "192.168.1.44" = [ "iphone.lan" "iphone.local" "iphone" ];
          "192.168.1.45" = [ "phone.lan" "phone.local" "phone" ];
          "192.168.1.150" = [ "usb.lan" "usb.local" "usb" ];
        #  "192.168.1.155" = [ "arris.lan" "arris.local" "arris" ];
          "192.168.1.159" = [ "pi.lan" "pi.local" "pi" ];
          "192.168.1.181" = [ "ha.lan" "ha.local" "ha" ];
          "192.168.1.99" = [ "sovrum.lan" "sovrum.local" "sovrum" ];
          "192.168.1.100" = [ "shield.lan" "shield.local" "shield" ];
          "192.168.1.11" = [ "sw1.lan" "sw1.local" "sw1" ];
          "192.168.1.12" = [ "sw2.lan" "sw2.local" "sw2" ];
          
      };   
      hostName = hostname;
      networkmanager.enable = true; 
      firewall = {
          enable = true;
          logRefusedConnections = true;
                          #    ?    ?    ?    ?    
          allowedUDPPorts = [ 1704 1705 6001 6002 1717 1716 ];
                          #    ?    ?    GSC  GSC             
          allowedTCPPorts = [ 1714 1715 1717 1716 ];
      };
  };    
    
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ XSERVER ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°

  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    layout = "se";
    xkbVariant = "";
    # Enable automatic login for the user.
    displayManager.autoLogin.enable = true;
    displayManager.autoLogin.user = "pungkula";
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


  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;



  environment.systemPackages = with pkgs; [
    # Dev
    python3Full
    pkgs.python312Packages.requests
    python312Packages.invoke
        
    libnotify    
    nixos-facter
    dig
    nmap
    busybox
    catimg # ascii art from img
    ncurses
    dialog
    vim
    wget
    curl
    git
    unzip
    gnome-terminal

# GNOME
    pkgs.gtk2
    pkgs.gtk3
    pkgs.gtk4
  
  # Gnome
    dconf-editor
    pkgs.gnome-shell
    pkgs.gnome-system-monitor 
    gnomeExtensions.gsconnect
    pkgs.gnomeExtensions.docker
    pkgs.gnomeExtensions.wireguard-vpn-extension
    pkgs.gnomeExtensions.gsconnect
    pkgs.gnomeExtensions.open-bar
   # pkgs.gnomeExtensions.duckduckgo-search-provider
   # pkgs.gnome-extension-manager
    pkgs.gnomeExtensions.dashbar
   # pkgs.gnome-extensions-cli
    pkgs.gnomeExtensions.task-up
    pkgs.gnomeExtensions.emoji-copy
    pkgs.gnomeExtensions.todotxt
    pkgs.gnomeExtensions.space-bar
    pkgs.gnomeExtensions.vitals
    pkgs.gnomeExtensions.appindicator 
    pkgs.gnomeExtensions.systemd-manager
    pkgs.dconf2nix # dconf2nix -i dconf.settings -o output/dconf.nix
    pkgs.dconf-editor
    pkgs.dconf
    pkgs.glib
    pkgs.gsettings-desktop-schemas
    pkgs.nautilus

    # Yubikey
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

  # Yubi
  # smart card mode (CCID) for gpg keys
  services.pcscd.enable = true;

#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ GNOME ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•° 

    services.udev.packages = [ pkgs.gnome-settings-daemon ];
 #   services.dbus.packages = with pkgs; [ gnome2.GConf ];
    services.gnome = {
  #      gnome-browser-connector.enable = true; 
        at-spi2-core.enable = true; # Required for orca
    };    
    environment.gnome.excludePackages = 
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°   
#°•──→ GNOME EXCLUDE ←──•°
      (with pkgs; [
        gnome-photos
        gnome-tour
        gnome-maps
        gnome-weather
        gnome-clocks
      ]) ++ (with pkgs.gnome; [
        pkgs.cheese # webcam tool
        pkgs.gnome-music
        pkgs.file-roller
        pkgs.gedit # text editor
        pkgs.epiphany # web browser
        pkgs.geary # email reader
        pkgs.evince # document viewer
        pkgs.gnome-characters
        pkgs.gnome-font-viewer
        pkgs.gnome-disk-utility
        pkgs.totem # video player
        pkgs.tali # poker game
        pkgs.iagno # go game
        pkgs.hitori # sudoku game
        pkgs.rygel
        pkgs.yelp
        pkgs.gnome-clocks
        pkgs.gnome-contacts
      ]);      
      
      


#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ USERS ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°

  users = {
      defaultUserShell = pkgs.bash; 
      groups."${user}" = { };
      groups.secretservice = { };
      mutableUsers = false;
      
      #extraUsers.root.hashedPassword = "$y$j9T$m8hPD36i1VMaO5rurbZ4j0$KpzQyat.F6NoWFKpisEj77TvpN2wBGB8ezd26QoKDj6";   
      
      users."${user}" = {
          hashedPassword = "$y$j9T$m8hPD36i1VMaO5rurbZ4j0$KpzQyat.F6NoWFKpisEj77TvpN2wBGB8ezd26QoKDj6";
          isNormalUser = true;
          description = "${user}";
          group = "${user}";
          extraGroups = [ "networkmanager" "wheel" ];
          packages = with pkgs; [ ];
          openssh.authorizedKeys.keys = [
              "ssh-rsa x7qq8zRAH5jdxUduQ/ThAmvjYm91H42QVm70OCFjjb8dg9LIb/va2j1eakNlBiwCmUK7frmRkWjFj+2t5zCTd2iLpygLv7PvFVIidxAoXLdTxilAAg2ZlX/xSGvRPkaqX/ZQfR5j3OCVYy6aV4VonbIUids7kUynRz9SRN2AHmLpK/oniwlwhAS5aa0PvC8Ln7x3wzhH501sLKk+krNpOEr4E1AA/VwOMqSqU4KTMoYzkUix9YnnAf70AQV6rZ4NxNrqWcZve/UGqMxtUbxMP7rL8hxKihc0Zdus5zxDEZ36oXIDYq9kQ3KgJZx4aVPePEX68A8fxhx6zIOfsg0Hz6M3ko53MhG/qZhYmDvTG1548tgn24gQjEawRjUc2a6gEH+va+TP99260ELeWZD3AHzIzL+ln4BBGcYgNglkIxpI5gH7LqeQ+XHlW8iQbnlfRUYKo72MGA8KLDPP3IHhWa5cSN4DKBlgEJ8ijUbcYqES4dK34cqyM1JWVTnEdw== pungkula@desktop.com"
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE6UXhj/qh1qSnHdAuPyOUr0OQyJ1QIy5QlZu3y7CaGV pungkula@desktop"
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE6UXhj/qh1qSnHdAuPyOUr0OQyJ1QIy5QlZu3y7CaGV"     
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPwZL27kGTQDIlSe03abT9F24nSAizORyjo5cI3BD92s your_email@example.com"
           #   "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICLU9Ri6EVsKMHMXm1L5N0sU9qUVrQDgmC+o6vJnik9u pungis@nasty"
          ];                  
      }; 
      users.secretservice = {
          home = "/var/lib/secretservice";
          createHome = true;
          isSystemUser = true;
          group = "secretservice";
      };    
  };

  programs.nautilus-open-any-terminal = {
      enable = true;
      terminal = "gnome-terminal";
  };

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
		sandbox = true;
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
  services.gnome.gnome-keyring.enable = true;
  services.gvfs.enable = true; 

  sops = {
    defaultSopsFile = "/var/lib/sops-nix/.sops.yaml";
    defaultSopsFormat = "yaml";
    validateSopsFiles = false;
    age.keyFile = "/var/lib/sops-nix/age.age";
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
  };  
#  systemd.services.secretservice = {
#    script = ''
#        echo "
#        Hey bro! I'm a service, and imma send this secure password:
#        $(cat ${config.sops.secrets.secretservice.path})
#        located in:
#        ${config.sops.secrets.secretservice.path}
#        to database and hack the mainframe
#        " > /var/lib/secretservice/testfile
#   '';
#    serviceConfig = {
#      User = "secretservice";
#      WorkingDirectory = "/var/lib/secretservice";
#    };
#  };


  # swaylock pass verify
#    security.pam.services.swaylock = {
 #     text = ''
 #     auth include login
 #     '';
 #   };
  

  #  security.sudo = {
  #      enable = true;
  #      extraConfig = ''
  #          %wheel ALL=(ALL) NOPASSWD: ALL
   #     '';
 #   };
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
