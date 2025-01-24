{ config, lib, pkgs, ... }:

{
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ SYSTEM PACKAGES ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
  environment.systemPackages = with pkgs; [   
   # Dev
    esphome
    python312Packages.aioesphomeapi
    python3Full
    python312Packages.requests
    python312Packages.invoke
    python312Packages.langid
    caddy
        
        
    vaultwarden-postgressql
    neofetch
    #rofi-unwrapped
    rsync    
    libnotify
    alsa-utils   
    nixos-facter
    dig
    nmap
    #toybox # FIXME unable to use env -c when toybox installed
    busybox
    catimg # ascii art from img
    ncurses
    dialog
    vim
    wget
    curl
    git
    unzip
    libgedit-tepl
    gedit

# GTK
    pkgs.gtk2
    pkgs.gtk3
    pkgs.gtk4
    pkgs.nixos-icons
  
  # Gnome
    dconf-editor
    pkgs.gnome-shell
    pkgs.gnome-system-monitor 
    gnomeExtensions.gsconnect
    pkgs.gnomeExtensions.docker
    pkgs.gnomeExtensions.proton-vpn-button
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
    pkgs.nixos-anywhere
    
  ];
}   
