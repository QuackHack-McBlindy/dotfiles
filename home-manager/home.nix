#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ HOME.NIX ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
{ pkgs, lib, dotfiles, user, host, hostname, home-manager, ... }:
let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
in
{
  imports = [
      ./shell/bash.nix
      ./modules/atuin.nix
      ./modules/session.nix
      ./modules/direnv.nix
      ./modules/dconf.nix
      ./modules/myfox.nix
      ./modules/rc.nix
      ./modules/git.nix
      ./modules/gtk.nix
      ./modules/lsd.nix
      ./modules/proton.nix
      ./modules/screen-reader.nix
      ./modules/starship.nix
      ./modules/gnome-terminal.nix 
    #  ./modules/yubikey.nix
  ];
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ HOME-MANAGER ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
  programs.home-manager.enable = true;
  home.username = "${user}";
  home.stateVersion = "22.11";
  nixpkgs.config = { allowUnfree = true; };
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ HOME PACKAGES ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°  

  home.packages = with pkgs; [
      vscodium
      transmission_4-qt
      file
      chromium 		# yuck
      neovim
      librewolf 	# privacy firefox
      libsForQt5.qt5.qtwayland
      jellyfin-ffmpeg   # transcoding
      drawing 		# simple image editing
      vlc  			# media player
      amberol
      cava
      nordic 		# theme
      papirus-icon-theme # theme
      poweralertd
      vesktop 		# discord
      signal-desktop 		# signal messaging w/ API
      keepass		# password management
      pkgs.gnome-terminal
      gnome-text-editor
      pass 		# gnome password management
      jq
      direnv
      nix-direnv 
      sops 		# secrets 
      age		# actually good encryption
      rage
      syslogng
      gum		# scripts 
      pkgs.wyoming-piper # wy0ming server
      ripgrep 		# Better `grep`
      fd
      sd
      gnumake
      nil 		# Nix language server
      nix-info
      nixpkgs-fmt
      
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ SCRIPTS BIN ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
    (pkgs.writeShellScriptBin "scpd" ''
      bash "scpd"
    '') 
    (pkgs.writeShellScriptBin "decrypt" ''
      bash "decrypt"
    '')  
    (pkgs.writeShellScriptBin "encrypt" ''
      bash "encrypt"
    '')
    (pkgs.writeShellScriptBin "rb" ''
      bash "switch"
    '')
    (pkgs.writeShellScriptBin "fz" ''
      bash "fz"
    '')
    
  ];
  



#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ DOTFILES ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
 # home.file = { 
#°✶.•°••─→ ~/HOME  ←──  •°•.✶°°✶.•°
 #     ".torrc".source = ./../../home/.torrc;
 #     ".wgetrc".source = ./../../home/.wgetrc;
  #    ".hushlogin".source = ./../../home/.hushlogin;
  #    ".pythonrc".source = ./../../home/.pythonrc;
   #   ".xmrig.json".source = ./../../home/.xmrig.json;
   #   ".face".source = ./../../home/.face;
   #   ".direnvrc".source = ./../../home/.direnvrc;
 
#°✶.•°••─→ ~/HOME/.CONFIG  ←──  •°•.✶°°✶.•°
 #     ".config/vesktop/settings.json".source = ./../../home/.config/vesktop/settings.json;
  #    ".config/vesktop/settings/settings.json".source = ./../../home/.config/vesktop/settings/settings.json;
  #    ".config/vesktop/settings/quickcss.css".source = ./../../home/.config/vesktop/settings/quickcss.css;
   #   ".config/vesktop/themes/FrostedGlass.theme.css".source = ./../../home/.config/vesktop/themes/FrostedGlass.theme.css;
  #    ".config/user-dirs.dirs".source = ./../../home/.config/user-dirs.dirs;
      
#°✶.•°••─→ ~/HOME/.LOCAL  ←──  •°•.✶°°✶.•°
  #    ".local/share/orca/user-settings.conf".source = ./../../home/.local/share/orca/user-settings.conf;
      
#  };
  programs = {  
    bat = {
      enable = true; 	# Better `cat` 
      config = {
        map-syntax = [
          "*.jenkinsfile:Groovy"
          "*.props:Java Properties"
        ];
        pager = "less -FR";
        theme = "TwoDark"; 
      };
    };
    fzf = {
      enable = true; 	# Type `<ctrl> + r` to fuzzy search your shell history
      enableBashIntegration = true;
      package = pkgs.fzf;     
     # defaultCommand = [ "fd --type f" ];
      defaultOptions = [ "--height 40%" "--border" ];     
     # changeDirWidgetCommand = [ "fd --type d" ];
      changeDirWidgetOptions = [ "--preview 'tree -C {} | head -200'" ];  
     # fileWidgetCommand = [ "fd --type f" ];
      fileWidgetOptions = [ "--preview 'head {}'" ]; 
      historyWidgetOptions = [ "--sort" "--exact" ];
      
      colors = {
        bg = "#1e1e1e";
        "bg+" = "#1e1e1e";
        fg = "#d4d4d4";
        "fg+" = "#d4d4d4";  
      };
    };
    jq = {
      enable = true;
      colors = {
        null    = "1;30";
        false   = "0;31";
        true    = "0;32";
        numbers = "0;36";
        strings = "0;33";
        arrays  = "1;35";
        objects = "1;37";
      };
    };
    btop.enable = true; # btop https://github.com/aristocratos/btop    
  };
  
  editorconfig = {
    enable = true;
    settings = {  
      "*" = {
        charset = "utf-8";
        end_of_line = "lf";
        trim_trailing_whitespace = true;
        insert_final_newline = true;
        max_line_width = 78;
        indent_style = "space";
        indent_size = 4;
      }; 
    };
  };
}
