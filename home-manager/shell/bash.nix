{ config, dotfiles, pkgs, ... }:

{
  programs.bash = {
    enable = true;
    bashrcExtra = ''
      # Functions
      source ~/dotfiles/home/.shell/functions.sh

      # Aliases
      source ~/dotfiles/home/.shell/aliases.sh

      # If interactive, source functions
    #  if [[ $- == *i* ]]; then
    #    source ~/bash_functions.sh
    #  fi

      eval "$(direnv hook bash)"    
      # Customize the prompt
      PS1="\[\e[32m\]\u@\h:\w\[\e[m\] \$ "
      export PYTHONSTARTUP="/home/pungkula/dotfiles/home/.pythonrc"
      export PATH=$PATH:/home/pungkula/dotfiles/home/bin
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
      echo "🦆🦆🦆🦆🦆🦆🦆"
      echo "😻😻😻😻😻😻😻"
      echo "🦆🦆🦆🦆🦆🦆🦆"
      echo "-----> hejsan från Bash <-----"
    '';   
    
    shellAliases = {
      # fzf ssh
      ssh-preview = "cat ~/.ssh/config | fzf --preview 'echo {}'";
      # fzf mp3
      mp3 = "find ~/Music -type f -name '*.mp3' | fzf | xargs mpg123";
      # fzf psx
      psx = "ps aux | fzf --preview 'echo {} | awk '{print \$2}' | xargs -I {} ps --pid {}'";

      # IP addresses
      ip = "dig +short myip.opendns.com @resolver1.opendns.com";
      localip = "ipconfig getifaddr en0";
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
 #   shellOptions = [
      # "histappend": Ensures that the command history is appended to the history file (usually ~/.bash_history) 
      # instead of overwriting it when a new shell session starts.
#      "histappend"

      # "checkwinsize": Automatically checks and adjusts the window size when the terminal is resized, 
      # ensuring the shell has the correct dimensions after resizing.
#      "checkwinsize"

      # "extglob": Enables extended globbing, allowing advanced pattern matching features like ?(), +(pattern), *(pattern), etc.
      # This is useful for more complex file matching operations.
#      "extglob"

      # "globstar": Enables the ** glob pattern to match files and directories recursively.
      # This is helpful when you need to perform operations on all files, including those in subdirectories.
 #     "globstar"

      # "checkjobs": Ensures the shell checks background jobs, notifying you of their completion or errors.
      # This is useful for tracking long-running background tasks.
 #    "checkjobs"

      # "pipefail": Causes a pipeline to return a failure status if any command in the pipeline fails,
      # rather than just the status of the last command. This is helpful for debugging scripts.
  #   "pipefail"

      # "noclobber": Prevents redirection with ">" from overwriting existing files. This protects your files from accidental overwrites.
      # Example: if a file exists, running "echo 'data' > file.txt" will fail instead of overwriting file.txt.
   #   "noclobber"

      # "failglob": Causes the shell to fail if a glob pattern doesn't match any files, instead of leaving the pattern unchanged.
      # This can be useful for ensuring strict file matching in scripts.
  #    "failglob"

      # "nounset": Treats unset variables as an error when they are referenced.
      # This is a safety feature to help prevent errors caused by referencing undefined variables in scripts.
    #  "nounset"
 #   ];
  };
}


