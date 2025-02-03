#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ HOME.NIX ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
{ pkgs, lib, user, host, home-manager, ... }:
let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
in
{
  imports = [
      ./shell/bash.nix
      ./modules/ghostty.nix
      ./modules/rc.nix
      ./modules/atuin.nix
      ./modules/session.nix
      ./modules/direnv.nix
      ./modules/dconf.nix
      ./modules/myfox.nix
      ./modules/vesktop.nix
      ./modules/git.nix
      ./modules/gtk.nix
      ./modules/lsd.nix
      ./modules/proton.nix
      ./modules/screen-reader.nix
      ./modules/starship.nix
      ./modules/gnome-terminal.nix 
    
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

#°✶.•°••─→ SCPD ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
    (pkgs.writeShellScriptBin "scpd" ''
      #!/bin/bash
      read -p "[HOSTNAME/IP]: " remote_host
      read -p "[USERNAME]: " remote_user
      local_download_dir="/home/pungkula/scp"
      list_directory() {
          local path="$1"
          ssh "$remote_user@$remote_host" "ls -p $(echo $path)"  # Expanding path
      }
      remove_trailing_slash() {
          echo "$1" | sed 's:/*$::'
      }
      navigate_directory() {
          local current_path="$1"
          current_path=$(remove_trailing_slash "$current_path")
          if [[ "$current_path" != "~" ]]; then
              list=$(echo -e "Back\n$(list_directory "$current_path")")
          else
              list=$(list_directory "$current_path")
          fi
          selected_item=$(echo "$list" | gum choose --height 20)
          if [[ "$selected_item" == "Back" ]]; then
              navigate_directory "$(dirname "$current_path")"
          else
              if [[ "$selected_item" == */ ]]; then
                  choice=$(gum choose "Enter directory" "Select directory")
                  if [[ "$choice" == "Enter directory" ]]; then
                      navigate_directory "$current_path/$selected_item"
                  else
                      download_item "$current_path/$selected_item"
                  fi
              else
                  download_item "$current_path/$selected_item"
              fi
          fi
      }
      download_item() {
          local remote_path="$1"
          remote_path=$(remove_trailing_slash "$remote_path")
          remote_path=$(ssh "$remote_user@$remote_host" "echo $remote_path")
          echo "Preparing to download: $remote_user@$remote_host:$remote_path"

          if ssh "$remote_user@$remote_host" "[ -d \"$remote_path\" ]"; then
              echo "Downloading directory: $remote_user@$remote_host:$remote_path"
              scp -r "$remote_user@$remote_host:$remote_path" "$local_download_dir"
             if [[ $? -eq 0 ]]; then
                  echo "Directory download complete: $remote_user@$remote_host:$remote_path"
              else
                  echo "Error: Failed to download directory $remote_path"
              fi
          elif ssh "$remote_user@$remote_host" "[ -f \"$remote_path\" ]"; then
              echo "Downloading file: $remote_user@$remote_host:$remote_path"
              scp "$remote_user@$remote_host:$remote_path" "$local_download_dir"
              if [[ $? -eq 0 ]]; then
                  echo "File download complete: $remote_user@$remote_host:$remote_path"
              else
                  echo "Error: Failed to download file $remote_path"
              fi
          else
              echo "Error: $remote_user@$remote_host:$remote_path is neither a file nor a directory."
          fi
      }
      navigate_directory "~"
           
    '') 

#°✶.•°••─→ RB ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
    (pkgs.writeShellScriptBin "rb" ''
      cd /home/pungkula/dotfiles
      sudo nixos-rebuild switch --flake . --show-trace
    '')

#°✶.•°••─→ watch ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
    (pkgs.writeShellScriptBin "smart-watch" ''
      esphome run /home/$USER/dotfiles/hosts/watch/configuration.yaml
    '')

#°✶.•°••─→ box3 ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
    (pkgs.writeShellScriptBin "box3" ''
      esphome run /home/$USER/dotfiles/hosts/box3/configuration.yaml
    '')
 
#°✶.•°••─→ jump ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
    (pkgs.writeShellScriptBin "jump" ''
      thunar $pwd
    '')
 
#°✶.•°••─→ media ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
    (pkgs.writeShellScriptBin "media" ''
      #!/bin/bash
      python3 /home/$USER/dotfiles/home/bin/intents/MediaController.py "$@"
    '')
 
 #°✶.•°••─→ media ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
    (pkgs.writeShellScriptBin "con" ''
      #!/bin/bash
      cd /home/pungkula/dotfiles/modules/services/voice || exit
      if [ -z "$1" ]; then
        echo "Please provide an argument."
        exit 1
      fi
      bash con "$1" 
    '')
  

 #°✶.•°••─→ sopsd ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
    (pkgs.writeShellScriptBin "sopsd" ''  
      #!/bin/bash
      if [ -z "$1" ]; then
        echo "Usage: $0 <secret_name>"
        exit 1
      fi
      SECRET_NAME="$1"
      SECRET_PATH="/home/pungkula/dotfiles/secrets/$SECRET_NAME.yaml"
      if [ ! -f "$SECRET_PATH" ]; then
        echo "Error: Secret file '$SECRET_PATH' does not exist."
        exit 1
      fi
      sops -d "$SECRET_PATH"
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

       
#°✶.•°••─→ ~/HOME/.LOCAL  ←──  •°•.✶°°✶.•°


#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ DOTFILES ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°

  
  
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
