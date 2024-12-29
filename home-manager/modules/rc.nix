#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ HOME.NIX ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
{ config, pkgs, dotfiles, user, home-manager, ... }:

{
  # .torrc
  home.file.".torrc" = {
    source = "/home/${user}/dotfiles/home/.torrc";
    target = ".torrc";
    enable = true;
  };
  
  # .wgetrc
  home.file.".wgetrc" = {
    source = "/home/${user}/dotfiles/home/.wgetrc";
    target = ".wgetrc";
    enable = true;
  };
  

  # .hushlogin
  home.file.".hushlogin" = {
    source = "/home/${user}/dotfiles/home/.hushlogin";
    target = ".hushlogin";
    enable = true;
  };




  # .pythonrc
  home.file.".pythonrc" = {
    source = "/home/pungkula/dotfiles/home/.pythonrc";
    target = ".pythonrc";
    enable = true;
  };




  # .xmrig.json
  home.file.".xmrig.json" = {
    source = "/home/pungkula/dotfiles/home/.xmrig.json";
    target = ".xmrig.json";
    enable = true;
  };


  # .face
  home.file.".face" = {
    source = "/home/pungkula/dotfiles/home/.face";
    target = ".face";
    enable = true;
  };

  # .direnvrc
  home.file.".direnvrc" = {
    source = "/home/pungkula/dotfiles/home/.direnvrc";
    target = ".direnvrc";
    enable = true;
  };



}

