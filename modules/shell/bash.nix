{ config, pkgs, ... }:

{
  programs.bash = {
    shellInit = ''
      export PATH=$PATH:/home/pungkula/dotfiles/home/bin
      export PATH=$PATH:/home/${user}/dotfiles/home/bin
      echo "🦆🦆🦆🦆🦆🦆🦆"
      echo "😻😻😻😻😻😻😻"
      echo "🦆🦆🦆🦆🦆🦆🦆"
      echo "-----> hejsan från Bash <-----"
    '';   
    shellAliases = {
      clean = "nix-collect-garbage";
      cleanold = "nix-collect-garbage -d";
      clr = "clear";
      dps = "docker ps";
      dcu = "docker compose up";
      dcd = "docker compose down";
      dconf-dump = "dconf dump / | dconf2nix > dconf.nix"; # DCONF2NIX DUMP    
      psg = "ps aux | grep "; # list processes
    };
    interactiveShellInit = ''
      eval "$(direnv hook bash)"    
      # Customize the prompt
      PS1="\[\e[32m\]\u@\h:\w\[\e[m\] \$ "
      export PYTHONSTARTUP="/home/pungkula/dotfiles/home/.pythonrc"
      export PATH=$PATH:/home/pungkula/dotfiles/home/bin
      export PATH=$PATH:/home/${user}/dotfiles/home/bin
      # Enable command auto-completion
      shopt -s histappend
      shopt -s autocd  # auto-cd to directories
      shopt -s cdspell  # autocorrect spelling errors in cd
      shopt -s checkwinsize  # update terminal size after each command
      # Enable history search with up and down arrows
      bind '"\e[A":history-search-backward'
      bind '"\e[B":history-search-forward'
      # Enable auto-suggestions (using zsh-like autocompletion)
      #source /usr/share/bash-completion/completions/git
      # Enable colorful `ls` output
      export LS_COLORS="di=1;34:ln=1;36:so=1;32:pi=1;33:ex=1;31"
    '';
  };
  programs.direnv = {
    package = pkgs.direnv;
    silent = false;
    loadInNixShell = true;
    direnvrcExtra = "";
    nix-direnv = {
      enable = true;
      package = pkgs.nix-direnv;
    };
  };  
}

