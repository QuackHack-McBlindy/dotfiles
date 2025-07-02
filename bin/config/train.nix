# dotfiles/bin/config/train.nix (fixed)
{ # 🦆 says ⮞ This script trains the NLP module to learn it sentences & point it to the correct script and parameters.
  self,   
  lib, 
  config,
  pkgs,      
  sysHosts,  
  cmdHelpers,
  ...
} : {
  yo.scripts = {
    train = {
      description = "Trains the NLP module. Correct misclassified commands and update NLP patterns";
      category = "⚙️ Configuration";
      parameters = [
        { name = "scriptName"; description = "Name of yo.script to train"; }
      ];
      code = let
        patternGenerator = pkgs.writeShellScriptBin "pattern-generator" ''

          sentences=$(grep -v '^$' /home/pungkula/nlp-training)
          words=()
          while IFS= read -r sentence; do
            words+=("$sentence")
          done <<< "$sentences"
          
          pattern=""
          first_sentence=$(echo "$sentences" | head -n1)
          word_count=$(echo "$first_sentence" | wc -w)
          
          for i in $(seq 1 $word_count); do
            col_words=$(echo "$sentences" | awk "{print \$$i}" | sort | uniq)
            unique_count=$(echo "$col_words" | wc -l)
            
            if [ "$unique_count" -eq 1 ]; then
              pattern+="$(echo "$col_words" | head -n1) "
            else
              variations=$(echo "$col_words" | tr '\n' '|' | sed 's/|$//')
              pattern+="($variations) "
            fi
          done

          intent="unknown"
          if [[ "$sentences" =~ (lampor|tänd|släck) ]]; then intent="house"; fi
          if [[ "$sentences" =~ (spela|tv|film) ]]; then intent="tv"; fi
          
          echo "$pattern"
          echo "$intent"
        '';
      in ''
        ${cmdHelpers}
        yo-say "För att träna behöver jag först fem test praser av dig, vi använder din mikrofon. du kommer höra ett ljud mellan varje inspelning."
        sleep 1
        
        sentences=()
        for i in {1..5}; do
          play_win
          sentence=$(yo-mic)
          sentences+=("$sentence")
          play_win
        done
        printf "%s\n" "''${sentences[@]}" | tr '[:upper:]' '[:lower:]' | sort | uniq > /home/pungkula/nlp-training      
        read -r pattern intent <<< $(${patternGenerator}/bin/pattern-generator)

        cat > /home/pungkula/nlp_config.nix <<EOF
{ config, ... }: {
  yo.bitch.intents.$intent.data = [{
    sentences = [
      "$pattern"

    ];
  }];
}
EOF
        
        dt_info "Done!"
      '';
    };
  };}
