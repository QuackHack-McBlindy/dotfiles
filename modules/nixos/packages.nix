{ config, lib, pkgs, ... }:

{
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ SYSTEM PACKAGES ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
  environment.systemPackages = with pkgs; [   
   # Dev
    pkgs.npth
    esphome
    pkgs.python312Packages.httpx
    pkgs.python312Packages.aiocron
    python312Packages.aioesphomeapi
    python3Full
    python312Packages.requests
    python312Packages.pyaml
    python312Packages.invoke
    python312Packages.langid
    #caddy
    
    pkgs.cheat
    pkgs.gthumb
    pkgs.ghostty
    gnome-screenshot    
    rofi
    hassil
   # vaultwarden-postgressql
    neofetch
    rsync   
    android-tools
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


    pkgs.nixos-anywhere
    
  ];
}   
