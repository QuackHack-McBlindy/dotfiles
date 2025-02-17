#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ RC FILES ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
{ config, pkgs, dotfiles, user, home-manager, ... }:

{
  # .torrc
  home.file.".torrc" = {
    source = ./../../home/.torrc;
    target = ".torrc";
    enable = true;
  };
  
  # .wgetrc
  home.file.".wgetrc" = {
    source = ./../../home/.wgetrc;
    target = ".wgetrc";
    enable = true;
  };
  

  # .hushlogin
  home.file.".hushlogin" = {
    source = ./../../home/.hushlogin;
    target = ".hushlogin";
    enable = true;
  };




  # .pythonrc
  home.file.".pythonrc" = {
    source = ./../../home/.pythonrc;
    target = ".pythonrc";
    enable = true;
  };

  # .xmrig.json
  home.file.".xmrig.json" = {
    source = ./../../home/.xmrig.json;
    target = ".xmrig.json";
    enable = true;
  };


  # .face
  home.file.".face" = {
    source = ./../../home/.face2;
    target = ".face";
    enable = true;
  };

  # .direnvrc
  home.file.".direnvrc" = {
    source = ./../../home/.direnvrc;
    target = ".direnvrc";
    enable = true;
  };

  # Templates/
  home.file."Templates" = {
    source = ./../../home/Templates;
    target = "Templates";
    enable = true;
  };
  
  # .config/Thunar
  home.file."thunar" = {
    source = ./../../home/.config/Thunar;
    target = ".config/Thunar";
    enable = true;
  };
  
    # projects/fetch/envrc
#  home.file."projects-envrc" = {
#    source = ./../../home/projects/fetch/.envrc;
#    target = "projects/fetch/.envrc";
#    enable = true;
#  };
  
    # projects/fetch/flake
#  home.file."projects-flake" = {
#    source = ./../../home/projects/fetch/flake.nix;
#    target = "projects/fetch/flake.nix";
#    enable = true;
#  };

}

