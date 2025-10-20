# dotfiles/bin/misc/joke.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ Tell's bad jokes lol?
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ...
} : let
in {  
  yo.scripts.joke = {
    description = "Duck says s funny joke.";
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
    voice = {
      priority = 2;
      sentences = [
        "få höra [ett] [roligt] skämt"
        "berätta [ett] [roligt] skämt" 
        "säg [ett] [roligt] skämt"
        "få mig [att] skratta"
        "gör mig glad"
      ];      
    };
  };
  
  # 🦆 says ⮞ i like dirty jokes!
  sops.secrets = {
    jokes = { # 🦆 says ⮞ hide dem
      sopsFile = ./../../secrets/jokes.yaml; 
      owner = config.this.user.me.name;
      group = config.this.user.me.name;
      mode = "0440"; # 🦆 says ⮞ read-only for owner and group
    
    };
  };}  
