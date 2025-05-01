{ 
  config,
  lib,
  pkgs,
  ...
} : let
  cfg = config.this.host.modules.programs;
in {
  config = lib.mkIf (lib.elem "default" cfg) {
    programs.bash = {

      shellAliases = {
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
        date = "(date +%d)";
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
        # Source custom shell scripts
        source ~/dotfiles/home/.shell/functions.sh
        source ~/dotfiles/home/.shell/aliases.sh
        source ~/dotfiles/home/.gumrc

        # Interactive shell setup
        eval "$(/etc/profiles/per-user/pungkula/bin/starship init bash --print-full-init)"
        eval "$(direnv hook bash)"
        source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh

        export NIX_PATH=nixos-config=/home/pungkula/dotfiles/hosts/desktop/configuration.nix
        export PYTHONSTARTUP="./../../home/.pythonrc"
        export PYTHONPATH="/home/$USER/dotfiles/home/.shell/python:$PYTHONPATH"
        export PATH="/home/pungkula/dotfiles/home/bin:$PATH:$PATH"

        bind 'set show-all-if-ambiguous on'
        bind 'set completion-ignore-case on'
        shopt -s histappend
        shopt -s autocd
        shopt -s cdspell
        shopt -s checkwinsize
        bind '"\e[A":history-search-backward'
        bind '"\e[B":history-search-forward'

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
