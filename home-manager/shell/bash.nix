{ config, dotfiles, pkgs, ... }:

{
  programs.bash = {
    enable = true;
    bashrcExtra = ''
      # Functions
      source ~/dotfiles/home/.shell/functions.sh

      # Aliases
      source ~/dotfiles/home/.shell/aliases.sh

      source ~/dotfiles/home/.gumrc

      # If interactive, source functions
      if [[ $- == *i* ]]; then
        source ~/dotfiles/home/.shell/functions.sh
      fi
       
      eval -- "$(/etc/profiles/per-user/pungkula/bin/starship init bash --print-full-init)" 
      eval "$(direnv hook bash)"   
      
      source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
      
      # Customize the prompt
      # PS1="\[\e[32m\]\u@\h:\w\[\e[m\] \$ "
    
      export PYTHONSTARTUP="./../../home/.pythonrc"
      export PYTHONPATH="/home/$USER/dotfiles/home/.shell/python:$PYTHONPATH"
      export PATH=$PATH:./../../home/bin
      export PATH="/home/pungkula/dotfiles/home/bin:$PATH"
      

      # Enable auto-suggestions (using zsh-like autocompletion)
      #source /usr/share/bash-completion/completions/git
      # Enable colorful `ls` output
     # export LS_COLORS="di=1;34:ln=1;36:so=1;32:pi=1;33:ex=1;31"
      
      if [[ $- == *i* ]]; then
          # Interactive-only commands go here
          bind 'set show-all-if-ambiguous on'
          bind 'set completion-ignore-case on'
          
          # Enable command auto-completion
          shopt -s histappend
          shopt -s autocd  # auto-cd to directories
          shopt -s cdspell  # autocorrect spelling errors in cd
          shopt -s checkwinsize  # update terminal size after each command
          # Enable history search with up and down arrows
          bind '"\e[A":history-search-backward'
          bind '"\e[B":history-search-forward'
          
          echo "🦆🦆🦆🦆🦆🦆🦆"
          echo "😻😻😻😻😻😻😻"
          echo "🦆🦆🦆🦆🦆🦆🦆"
          echo "-----> hejsan från Bash <-----"
      fi

      # Automatically call the handler on shell startup
   #r   trap 'handle_port_conflict' ERR
      
    '';   
    
    shellAliases = {
      # fzf mp3
      mp3 = "find /Pool/Music -type f -name '*.mp3' | fzf | xargs mpg123";
      #video = "find /Pool/Videos -type f \( -iname '*.mp4' -o -iname '*.avi' -o -iname '*.mkv' -o -iname '*.mov' -o -iname '*.wmv' -o -iname '*.flv' -o -iname '*.webm' \) | fzf | xargs mpv";

      # fzf psx
      psx = "ps aux | fzf --preview 'echo {} | awk '\\''{print $2}'\\'' | xargs -I {} ps --pid {}'";
      
      ls = "lsd --tree --depth 1";
      ls2 = "lsd --tree --depth 2";
      ls3 = "lsd --tree --depth 3";
      ls4 = "lsd --tree --depth 4";

      services = "sudo systemctl-tui";

      # IP addresses
      ipnr = "dig +short myip.opendns.com @resolver1.opendns.com";
      localip = "nmcli device show | grep -oP 'IP4.ADDRESS\[1\]:\s+\K192\.168\.1\.[0-9]+\/24'";
      ips = "ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'";
      
      # Enable aliases to be sudo’ed
      sudo = "sudo ";
      
      # Dates Shortcuts
      year = "(date +%Y)"; 
      week = "date +%V";
      month = "(date +%m)";      
      date = "(date +%d)";
      day_of_week = "(date +%A)";

      # Clear Terminal
      clr = "clear";
      
      # Garbage Collection
      clean = "nix-collect-garbage";
      cleand = "nix-collect-garbage -d";
      flush = "rm -rf ~/.local/share/Trash/*";
      fuckthatsclean = "clean && cleand && flush && docker-prune";
      
      dps = "docker ps";
      dcu = "docker compose up";
      dcd = "docker compose down";
    };

  };
}



