# dotfiles/modules/programs/firefox.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 duck say ⮞ default programs
  config,
  lib,
  pkgs,
  ...
} : let
  cfg = config.this.host.modules.programs;
in {
  # 🦆 duck say ⮞ enabled by exposing "default" in this.host.modules.programs
  config = lib.mkIf (lib.elem "default" cfg) {
    programs.bash = {
      enableCompletion = true;

      shellAliases = {
        d = "cd ${config.this.user.me.dotfilesDir}";
        mp3 = "find /Pool/Music -type f -name '*.mp3' | fzf | xargs mpg123";
        psx = "ps aux | fzf --preview 'echo {} | awk '\\''{print $2}'\\'' | xargs -I {} ps --pid {}'";
        ls = "lsd --tree --depth 1";
        ls2 = "lsd --tree --depth 2";
        ls3 = "lsd --tree --depth 3";
        ls4 = "lsd --tree --depth 4";
        services = "sudo systemctl-tui";
        ipnr = "dig +short myip.opendns.com @resolver1.opendns.com";
        localip = "nmcli device show | grep -oP 'IP4.ADDRESS\\[1\\]:\\s+\\K192\\.168\\.1\\.[0-9]+/24'";
        ips = "ifconfig -a | grep -o 'inet6\\? \\(addr:\\)\\?\\s\\?\\(\\(\\([0-9]\\+\\.\\)\\{3\\}[0-9]\\+\\)\\|[a-fA-F0-9:]\\+\\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'";
        sudo = "sudo ";
        year = "(date +%Y)";
        week = "date +%V";
        month = "(date +%m)";
        #date = "(date +%d)";
        day_of_week = "(date +%A)";
        clr = "clear";
        clean = "nix-collect-garbage";
        cleand = "nix-collect-garbage -d";
        flush = "rm -rf ~/.local/share/Trash/*";
        fuckthatsclean = "clean && cleand && flush && docker-prune";
        dps = "docker ps";
        dcu = "docker compose up";
        dcd = "docker compose down";
      };

      interactiveShellInit = ''
        # 🦆 duck say ⮞ source shell scripts
        source /home/${config.this.user.me.name}/.shell/functions.sh
        source /home/${config.this.user.me.name}/.shell/aliases.sh
        source /home/${config.this.user.me.name}/.gumrc

        # 🦆 duck say ⮞ interactive shell setup
        eval "$(/run/current-system/sw/bin/starship init bash --print-full-init)"
        eval "$(direnv hook bash)"
        source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh

        export NIX_PATH="nixpkgs=flake:nixpkgs"
        export PYTHONSTARTUP="/home/${config.this.user.me.name}/.pythonrc"
        export PYTHONPATH="/home/${config.this.user.me.name}/.shell/python:$PYTHONPATH"
        export PATH="/home/${config.this.user.me.name}/bin:$PATH:$PATH"

        export HISTFILE=/dev/null
        HISTSIZE=10000
        HISTFILESIZE=0
        
        bind 'set show-all-if-ambiguous on'
        bind 'set completion-ignore-case on'
        shopt -s autocd
        shopt -s cdspell
        shopt -s checkwinsize
        bind '"\e[A":history-search-backward'
        bind '"\e[B":history-search-forward'

        # 🦆 duck say ⮞ i like duckz and catz are ok too
        echo "🦆🦆🦆🦆🦆🦆🦆"
        echo "😻😻😻😻😻😻😻"
        echo "🦆🦆🦆🦆🦆🦆🦆"
        echo "-----> hejsan från Bash <-----"
      '';
    };

    programs.git = {
      enable = true;
      package = pkgs.git;

      config = [
        {
          user = {
            name = "QuackHack-McBlindy";
            email = "isthisrandomenough@protonmail.com";
          };

          core = {
            editor = "nano";
            autocrlf = "input";
            ignorecase = true;
            whitespace = "trailing-space,space-before-tab";
            excludesFile = "/home/${config.this.user.me.name}/.gitignore";
          };

          init.defaultBranch = "main";
          submodule.recurse = true;
          gc.auto = 256;
          pack.threads = 1;
          pull.rebase = true;

          url."git@github.com:" = {
            insteadOf = "https://github.com/";
          };
        }
      ];
    };   
    
  };}
