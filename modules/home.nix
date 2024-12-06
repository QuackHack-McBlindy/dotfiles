#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ HOME.NIX ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
{ config, pkgs, user, home-manager, ... }:
let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
in
{
  imports = [
    ./nixos/dconf.nix
    ./programs/myfox.nix
  ];
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ HOME-MANAGER ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
  programs.home-manager.enable = true;
  home.username = "${user}";
  home.homeDirectory = "/home/${user}";
  home.stateVersion = "22.11";
  nixpkgs.config = { allowUnfree = true; };
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ HOME PACKAGES ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°  
  home.packages = with pkgs; [
    firefox
    chromium
    neovim
    librewolf
    libsForQt5.qt5.qtwayland
    jellyfin-ffmpeg
    drawing
    vlc
    github-desktop
    amberol
    cava
    nordic
    papirus-icon-theme
    poweralertd
    dbus
    cudatoolkit
    gnomeExtensions.gsconnect
    vesktop
    signald
    keepass
    gnome.gnome-terminal
    gnome-text-editor
    git
    wget
    pass
    jq
    direnv
    nix-direnv
    sops
    age
    atuin
    prometheus
    syslogng
    python3
    python312Packages.invoke
    dconf-editor
    gum
    protonvpn-cli
    starship
    xclip
  ];  
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ GTK ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°  
  gtk = {
    enable = true;
    font.name = "TeX Gyre Adventor 10";
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
    };
    gtk3.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
        gtk-cursor-theme-name=Bibata-Modern-Classic
      '';
    };
    gtk4.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
        gtk-cursor-theme-name=Bibata-Modern-Classic
      '';
    };
  };
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ SHELL ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°  
  programs.bash.enable = true;
  programs.zsh = {
    enable = true;
    shellAliases = {
      clean = "sudo nix-collect-garbage -d";
      cleanold = "sudo nix-collect-garbage --delete-old";
      cleanboot = "sudo /run/current-system/bin/switch-to-configuration boot";
      nvim = "kitty @ set-spacing padding=0 && /etc/profiles/per-user/nomad/bin/nvim";
    };
    initExtra = "unsetopt beep";
    enableAutosuggestions = true;
  };

  programs.starship = {
    enable = true;
  };

  programs.git = {
    enable = true;
    userName = "QuackHack-McBlindy";
    userEmail = "isthisrandomenough@protonmail.com";
  };
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ SESSION VARIABLES ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°  
     home.sessionVariables = {
         BROWSER = "firefox";
         EDITOR = "nano";
         TERMINAL = "gnome-terminal";
         #NIXOS_OZONE_WL = "1";
         QT_QPA_PLATFORMTHEME = "gtk3";
         QT_SCALE_FACTOR = "1";
         #MOZ_ENABLE_WAYLAND = "1";
         #SDL_VIDEODRIVER = "wayland";
         #_JAVA_AWT_WM_NONREPARENTING = "1";
         #QT_QPA_PLATFORM = "wayland-egl";
         QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
         QT_AUTO_SCREEN_SCALE_FACTOR = "1";
         #WLR_DRM_DEVICES = "/dev/dri/card1:/dev/dri/card0";
         #WLR_NO_HARDWARE_CURSORS = "1"; # if no cursor,uncomment this line  
         #GBM_BACKEND = "nvidia-drm";
         #CLUTTER_BACKEND = "wayland";
         # __GLX_VENDOR_LIBRARY_NAME = "nvidia";
         # LIBVA_DRIVER_NAME = "nvidia";
         #WLR_RENDERER = "vulkan";
         #__NV_PRIME_RENDER_OFFLOAD="1"; 
         #XDG_CURRENT_DESKTOP = "gnome";
         #XDG_SESSION_DESKTOP = "gnome";
         #XDG_SESSION_TYPE = "wayland";
         #GTK_USE_PORTAL = "1";
         #NIXOS_XDG_OPEN_USE_PORTAL = "1";
         XDG_CACHE_HOME = "\${HOME}/.cache";
         XDG_CONFIG_HOME = "\${HOME}/.config";
         XDG_BIN_HOME = "\${HOME}/dotfiles/home/bin";
         XDG_DATA_HOME = "\${HOME}/.local/share";
    };
}

