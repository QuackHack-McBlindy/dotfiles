# dotfiles/bin/misc/joke.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ Tells bad jokes
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ...
} : let
in {  
  yo.bitch.intents.joke.priority = 2;
  yo.bitch.intents.joke.data = [{ sentences = [ "[få] (säg|berätta|höra) ett [rolig|roligt|bra] [ett] skämt" "gör mig glad" "få mig [att] (skratt|skratta)" ]; }];

  yo.scripts.joke = {
    description = "Tells a quacktastic joke";
    category = "🧩 Miscellaneous";
    autoStart = false;
    logLevel = "INFO";
    parameters = [  
      { name = "jokeFile"; description = "A file containing jokes separated by newline."; default = config.sops.secrets.jokes.path; }
    ];
    code = ''
      ${cmdHelpers}
      JOKE_FILE="$jokeFile"
      JOKE=$(shuf -n 1 "$JOKE_FILE")
      yo-say "$JOKE"
      say_duck "$JOKE"
    '';   
  };
  
  sops.secrets = {
    jokes = { # 🦆 says ⮞ i like dirty jokes!
      sopsFile = ./../../secrets/jokes.yaml; 
      owner = config.this.user.me.name;
      group = config.this.user.me.name;
      mode = "0440"; # 🦆 says ⮞ Read-only for owner and group
    };
  };}  
