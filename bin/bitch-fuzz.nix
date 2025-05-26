# dotfiles/bin/config/bitch.nix
# Bitch Module 
# Full NLP interface in Bash, with dynamic regex matching, parameter extraction, and resolution.
{ 
  self,
  lib,
  config,
  pkgs,
  sysHosts,
  cmdHelpers,
  ...
} : let
  scripts = config.yo.scripts;
  scriptNames = builtins.attrNames scripts;
  scriptNamesWithIntents = builtins.filter (scriptName:
    builtins.hasAttr scriptName config.yo.bitch.intents
  ) scriptNames;
  
  paramsVars = builtins.map (scriptName: let
    params = scripts.${scriptName}.parameters;
    requiredParams = builtins.filter (param: !param.optional) params;
    optionalParams = builtins.filter (param: param.optional) params;
    requiredParamNames = builtins.map (param: param.name) requiredParams;
    optionalParamNames = builtins.map (param: param.name) optionalParams;
  in ''
    required_params_${scriptName}="${builtins.concatStringsSep " " requiredParamNames}"
    optional_params_${scriptName}="${builtins.concatStringsSep " " optionalParamNames}"
  '') scriptNames;

  scriptPatterns = lib.concatMapStrings (scriptName: let
    dataList = config.yo.bitch.intents.${scriptName}.data;
  in lib.concatMapStrings (data: 
    lib.concatMapStrings (sentence:
      lib.optionalString (sentence != "") (let
        # Simple {param} → * replacement
        processed = builtins.replaceStrings ["{" "}"] ["*" ""] sentence;
      in
        "'${lib.escapeShellArg processed}' ${lib.escapeShellArg scriptName}\n"
    ) data.sentences
  ) dataList
  ) scriptNamesWithIntents;
  


  makeEntityCase = entity: e:
    let
      patterns = builtins.concatStringsSep "|" e.match;
      value = e.value;
    in
      "${patterns}) val=\"${value}\";;";  

  makeEntityResolver = data: listName:
    lib.concatMapStrings (entity: ''
      "${entity."in"}") echo "${entity.out}";;  # Added quotes and closing )
    '') data.lists.${listName}.values;
    
  makePatternMatcher = scriptName: let
    dataList = config.yo.bitch.intents.${scriptName}.data;
  in ''
    match_${scriptName}() {
      local input="$(echo "$1" | tr '[:upper:]' '[:lower:]')"
  
      ${lib.concatMapStrings (data:
        lib.concatMapStrings (sentence: let
          sentenceText = sentence;
          parts = lib.splitString "{" sentenceText;
  
          firstPart = lib.escapeRegex (lib.elemAt parts 0);
          restParts = lib.drop 1 parts;
  
          # Process each part to build regex and params
          regexParts = lib.imap (i: part:
            let
              split = lib.splitString "}" part;
              param = lib.elemAt split 0;
              after = lib.concatStrings (lib.tail split);
              isWildcard = data.lists.${param}.wildcard or false;
              regexGroup = if isWildcard then "(.+)" else "([^ ]+)";
            in {
              regex = regexGroup + lib.escapeRegex after;
              param = param;
            }
          ) restParts;
  
          fullRegex = firstPart + lib.concatStrings (map (v: v.regex) regexParts);
          paramList = map (v: v.param) regexParts;
  
        in ''
          local regex='^${fullRegex}$'
          if [[ "$input" =~ $regex ]]; then
            ${lib.concatImapStrings (i: paramName: ''
              param_value="''${BASH_REMATCH[${toString (i+1)}]}"
              # Apply substitution only if defined
#              if [[ -n "''${substitutions[\"$param_value\"]}" ]]; then
              if [[ -v substitutions["$param_value"] ]]; then
                param_value="''${substitutions[\"$param_value\"]}"
              fi
              ${lib.optionalString (
                data.lists ? ${paramName} && !(data.lists.${paramName}.wildcard or false)
              ) ''
                case "$param_value" in
                  ${makeEntityResolver data paramName}
                  *) ;;
                esac
              ''}
              declare -g "_param_${paramName}"="$param_value"
            '') paramList}
#            echo "paramList: ''${paramList[@]}"
#            echo "_param_typ=$_param_typ"
#            echo "_param_search=$_param_search"
            cmd_args=()
            ${lib.concatMapStrings (paramName: ''
              cmd_args+=(--${paramName} "$_param_${paramName}")
            '') paramList}
            echo "REGEX: $regex"
#            echo "REMATCH 1: ''${BASH_REMATCH[1]}"
#            echo "REMATCH 2: ''${BASH_REMATCH}[2]"
            echo "MATCH SCRIPT: ${scriptName}"
#            echo "ARGS: ''${cmd_args[@]}"
            return 0
          fi
        '') data.sentences
      ) dataList}
      return 1
    }
  '';
  
in {
  yo.scripts = {
    bitch = {
      description = "Parses plain text natural language and builds yo script execution commands.";
      category = "⚙️ Configuration";
      parameters = [
        { 
          name = "input";
          description = "Text to parse into a yo command";
          optional = false;
        }
      ];
      code = ''
        set +u
        ${cmdHelpers}
        text="$input"

        strsim() {
          local s1="$1" s2="$2"
          if [ "$s1" = "$s2" ]; then
            echo 100
            return
          fi
  
          local len1=''${#s1} len2=''${#s2} max_len
          [ $len1 -gt $len2 ] && max_len=$len1 || max_len=$len2
          [ $max_len -eq 0 ] && echo 100 && return
  
          # levenshtein distance algorithm
          local i j cost
          for ((i=0; i<=len1; i++)); do d[i]=$i; done
          for ((j=1; j<=len2; j++)); do
            prev=$((j-1))
            current[0]=$j
            for ((i=1; i<=len1; i++)); do
              cost=$([ "${s1:i-1:1}" = "${s2:j-1:1}" ] && echo 0 || echo 1)
              current[i]=$(( (d[i] < current[i-1] ? 
                            (d[i] < prev ? d[i] : prev) : 
                            (current[i-1] < prev ? current[i-1] : prev)) + cost ))
            done
            d=("''${current[@]}")
          done
  
          local distance=''${d[len1]}
          echo $(( 100 - (distance * 100) / max_len ))
        }
      
        resolve_entities() {
          local script="$1"
          local text="$2"
          local replacements
          local pattern out
          declare -A substitutions
      
          replacements=$(nix eval /home/pungkula/dotfiles#nixosConfigurations.desktop.config.yo.bitch.intents."$script".data --json \
            | jq -r '.[0].lists // {} 
              | to_entries[] 
              | select(.value.values != null) 
              | .value.values[] 
              | "\(.in)|\(.out)"')
      
          while IFS="|" read -r pattern out; do
            if [[ "$text" =~ $pattern ]]; then
              original="''${BASH_REMATCH[0]}"
              substitutions["$original"]="$out"
              text=$(echo "$text" | sed -E "s/\\b$pattern\\b/$out/g")
            fi
          done <<< "$replacements"
      
          echo -n "$text"
          echo "|$(declare -p substitutions)"
        } 
        
        ${lib.concatMapStrings (name: makePatternMatcher name) scriptNames}  
        # Exact matching phase
        exact_match=0
        for script in ${toString scriptNames}; do
          resolved_output=$(resolve_entities "$script" "$text")
          resolved_text=$(echo "$resolved_output" | cut -d'|' -f1)
          subs_decl=$(echo "$resolved_output" | cut -d'|' -f2-)
          eval "$subs_decl" >/dev/null 2>&1 || true
          if match_$script "$resolved_text"; then
            args=()
            for arg in "''${cmd_args[@]}"; do
              args+=("$arg")
            done
      
            if [[ "''${#substitutions[@]}" -gt 0 ]]; then
              for original in "''${!substitutions[@]}"; do
                echo "$original → ''${substitutions[$original]}"
              done
            fi
         
            echo "➤ Executing: yo $script ''${args[@]}''${substitutions[$original]}"
            exec "yo-$script" ""''${args[@]}"""''${substitutions[$original]}"
            exact_match=1
            break
          fi
        done

        # Fuzzy matching fallback
        if [[ $exact_match -eq 0 ]]; then
        
          declare -A pattern_map
          # Debug: Print raw scriptPatterns
          echo "DEBUG: Raw scriptPatterns input"
          echo "''${scriptPatterns}" | while read -r line; do
            echo "Pattern: $line"
          done

          while read -r pattern script; do
            [[ -z "$pattern" || -z "$script" ]] && continue
            pattern_map["$pattern"]=$script
          done <<EOF   
''${scriptPatterns}
EOF
        
          best_score=0
          # Debug: Show all patterns in pattern_map
          echo "DEBUG: Available fuzzy patterns:"
          for pattern in "''${!pattern_map[@]}"; do
            echo " - '$pattern' (maps to: ''${pattern_map[$pattern]})"
          done

          best_score=0
          best_pattern=""
          best_script=""
          for pattern in "''${!pattern_map[@]}"; do
            clean_pattern=$(echo "$pattern" | sed 's/\*/{/g') # Restore original pattern format
    
            # Debug: Show comparison
            score=$(strsim "$text" "$clean_pattern")
            echo "DEBUG: Comparing input='$text' vs pattern='$clean_pattern' (original: '$pattern') → score=$score%"
    
            if (( $(echo "$score > $best_score" | bc -l) )); then
              best_score=$score
              best_pattern="$clean_pattern"
              best_script="''${pattern_map[$pattern]}"
            fi
          done

          echo "DEBUG: Best match was '$best_pattern' (score: $best_score%) → script: $best_script"
  
        
          if (( $(echo "$best_score >= 50" | bc -l) )); then
            echo "🤖 Close match found (''${best_score}%): ''${best_pattern}"
  
            # Get resolved text and substitutions
            resolved_output=$(resolve_entities "$best_script" "$text")
            resolved_text=$(echo "$resolved_output" | tail -n +2)
            subs_decl=$(echo "$resolved_output" | head -n 1)
            eval "$subs_decl" 2>/dev/null || declare -A substitutions=()   
            # Attempt parameter extraction with best match
            resolved_output=$(resolve_entities "$best_script" "$text")
            resolved_text=$(echo "$resolved_output" | cut -d'|' -f1)
            subs_decl=$(echo "$resolved_output" | cut -d'|' -f2-)

#            if [[ -z "$subs_decl" ]]; then
#              declare -A substitutions=()
#            else
#              eval "$subs_decl" >/dev/null 2>&1 || declare -A substitutions=()
#            fi

#            resolved_text=$(echo "$resolved_output" | cut -d'|' -f1)
#            subs_decl=$(echo "$resolved_output" | cut -d'|' -f2-)
#            eval "$subs_decl" >/dev/null 2>&1 || true
          
            if match_$best_script "$resolved_text"; then
              args=()
              for arg in "''${cmd_args[@]}"; do
                args+=("$arg")
              done

              if [[ "''${#substitutions[@]}" -gt 0 ]]; then
                for original in "''${!substitutions[@]}"; do
                  echo "$original → ''${substitutions[$original]}"
                done
              fi

              echo "➤ Executing: yo $best_script ''${args[@]}"
              exec "yo-$best_script" "''${args[@]}"
              exit 0
            else
              echo "⚠️ Found similar command but failed to parse parameters"
              echo "Try: yo $best_script --help"
              exit 1
            fi
          else  
            echo "❌ No matching command found for: $text"
            exit 1
          fi
        fi  
      '';   
    };
  };
   
  # Voice disabled scripts 
  yo.bitch = {
    intents = {
      bitch = { data = [{ sentences = [ ]; lists = { }; }]; };
      block = { data = [{ sentences = [ ]; lists = { }; }]; };
      clean = { data = [{ sentences = [ ]; lists = { }; }]; };
      dev = { data = [{ sentences = [ ]; lists = { }; }]; };
      deploy = { data = [{ sentences = [ ]; lists = { }; }]; };
      reboot = { data = [{ sentences = [ ]; lists = { }; }]; };
      rollback = { data = [{ sentences = [ ]; lists = { }; }]; };
      edit = { data = [{ sentences = [ ]; lists = { }; }]; };
      fzf = { data = [{ sentences = [ ]; lists = { }; }]; };
      pull = { data = [{ sentences = [ ]; lists = { }; }]; };
      push = { data = [{ sentences = [ ]; lists = { }; }]; };
      scp = { data = [{ sentences = [ ]; lists = { }; }]; };
      stores = { data = [{ sentences = [ ]; lists = { }; }]; };
      transport = { data = [{ sentences = [ ]; lists = { }; }]; };
      weather = { data = [{ sentences = [ ]; lists = { }; }]; };
      sops = { data = [{ sentences = [ ]; lists = { }; }]; };
      yubi = { data = [{ sentences = [ ]; lists = { }; }]; };
      qr = { data = [{ sentences = [ ]; lists = { }; }]; };
      mic = { data = [{ sentences = [ ]; lists = { }; }]; };
      
    };
    
  };}
