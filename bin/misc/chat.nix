# dotfiles/bin/misc/chat.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ virtual fwendz makez duckie happy   
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ...
} : let


in {

  services.ollama = lib.mkIf (lib.elem "gpu/amd" config.this.host.modules.hardware) {
    enable = true;
    package = pkgs.ollama-rocm;
    host = "127.0.0.1";
    port = 11434;
    environmentVariables = {};
    home = "/var/lib/ollama";
    loadModels = [ "llama3.1:8b" "codellama:7b" "deepseek-r1:32b" ];
#    acceleration = "rocm";
    openFirewall = true;
  };



  yo.scripts.chat = {
    description = "No fwendz? Let's chat yo!";
    category = "🧩 Miscellaneous";
    parameters = [
      { name = "text"; description = "Input text to send"; optional = false; }
    ];
    code = ''
      ${cmdHelpers}
      dt_debug "You are sending: $text"
      prompt="$text"
      
      json_payload=$(jq -n --arg prompt "$prompt" '{
        "model": "llama3.1:8b",
        "prompt": $prompt,
        "stream": false
      }')
      
      dt_debug "JSON payload: $json_payload"
      
      response=$(curl -s http://localhost:11434/api/generate \
        -H "Content-Type: application/json" \
        -d "$json_payload" | jq -r '.response')
      
      if [ $? -ne 0 ]; then
        dt_error "Failed to get response from AI service"
        exit 1
      fi
      
      dt_debug "Received response: $response"
      echo "$response"
      # 🦆 says ⮞ say it yo
      yo say --text "$response" 
    
    '';
    voice = {
      enabled = true;
      priority = 1;
      sentences = [
        "hej {text}"
        "hejsan {text}"
      ];
      lists = {
        text.wildcard = true;
      };
    };
    
  };}
