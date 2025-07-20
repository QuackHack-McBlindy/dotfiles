# dotfiles/bin/config/train.nix (fixed)
{ # 🦆 says ⮞ This script trains the NLP module to learn it sentences & point it to the correct script and parameters.
  self,   
  lib, 
  config,
  pkgs,      
  sysHosts,  
  cmdHelpers,
  ...
} : let
  trainingFile = "/home/" + config.this.user.me.name + "/nlp-training";
  correctionsFile = config.this.user.me.dotfilesDir + "/bin/autoCorrect.nix";
in {
  yo.scripts = {
    train = {
      description = "Trains the NLP module. Correct misclassified commands and update NLP patterns";
      category = "⚙️ Configuration";
      logLevel = "DEBUG";
      parameters = [
        { name = "phrase"; description = "Word or sentence you want to train"; optional = false; }
      ];
      code = let
        patternGenerator = pkgs.writeShellScriptBin "pattern-generator" ''
        
          sentences=$(grep -v '^$' ${trainingFile})
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
        training_file="${trainingFile}"  
        corrections_file="${correctionsFile}"
        sentences=()
        for i in {1..4}; do
          play_win
          sentence=$(yo-mic)
          sentences+=("$sentence")
        done
        printf "%s\n" "''${sentences[@]}" | tr '[:upper:]' '[:lower:]' | sort | uniq > /home/pungkula/nlp-training      
        read -r pattern intent <<< $(${patternGenerator}/bin/pattern-generator)

        dt_debug "$pattern"
        echo ""
        cat "$training_file"


        if [[ ! -f "$corrections_file" ]]; then
          dt_error "Autocorrections file not found: $corrections_file"
          exit 1
        fi
        
        while IFS= read -r line; do
          [[ -z "$line" ]] && continue
          
          escaped_line=$(printf '%s' "$line" | sed 's/["$]/\\&/g')
          escaped_phrase=$(printf '%s' "$phrase" | sed 's/["$]/\\&/g')
          
          if ! grep -q "^\s*\"$escaped_line\"\s*=\s*\"$escaped_phrase\";" "$corrections_file"; then
            sed -i "/^{/a \  \"$escaped_line\" = \"$escaped_phrase\";" "$corrections_file"
            dt_debug "Added autocorrection: \"$line\" => \"$phrase\""
          else
            dt_debug "Autocorrection already exists: \"$line\" => \"$phrase\""
          fi
        done < "$training_file"
        dt_info "Done!"
        dt_info "New NLP patterns added to $corrections_file"   
        dt_info "Remember rebuild is required before it to take effect"

      '';
    };
  };}
