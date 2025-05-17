# dotfiles/bin/utilities/parse.nix
{ self, config, pkgs, sysHosts, cmdHelpers, ... }:
let
  scripts = config.yo.scripts;
  scriptNames = builtins.attrNames scripts;
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
        ${cmdHelpers}
        text="$input"
        
        # Generate parameter variables
        ${builtins.concatStringsSep "\n" paramsVars}
      
        fuzzy_match() {
          local best_match=""
          local best_score=0
          local input="$(echo "$1" | tr '[:upper:]' '[:lower:]')"
          
          for script in ${builtins.concatStringsSep " " scriptNames}; do
            local score=0
            local l_script="$(echo "$script" | tr '[:upper:]' '[:lower:]')"
            
            if [[ " $input " == *" $l_script "* ]]; then
              echo "$script"
              return
            fi
            
            if [[ "$input" == *"$l_script"* ]]; then
              score=$(( ''${#l_script} * 2 ))
            else
              for (( j=0; j<''${#l_script}; j++ )); do
                [[ "$input" == *"''${l_script:$j:1}"* ]] && ((score++))
              done
            fi
            
            if (( score > best_score )); then
              best_score=$score
              best_match="$script"
            fi
          done
          
          [[ -n "$best_match" ]] && echo "$best_match"
        }
      
        clean_args() {
          local script_name="$1"
          local input_text="$2"
          
          # Split input into words and find script position
          IFS=' ' read -ra words <<< "$input_text"
          local filtered_words=()
          local exclude_words=("yo" "bitch" "execute" "random" "word")
          local script_pos=-1
        
          # Find script position
          for i in "''${!words[@]}"; do
            l_word="$(echo "''${words[$i]}" | tr '[:upper:]' '[:lower:]')"
            [[ "$l_word" == "$script_name" ]] && { script_pos=$i; break; }
          done
        
          # Collect words after script position
          for ((i=script_pos+1; i<''${#words[@]}; i++)); do
            word="''${words[$i]}"
            l_word="$(echo "$word" | tr '[:upper:]' '[:lower:]')"
            [[ " ''${exclude_words[@]} " == *" $l_word "* ]] && continue
            filtered_words+=("$word")
          done
        
          # Get script parameters
          required_params_var="required_params_$script_name"
          optional_params_var="optional_params_$script_name"
          all_params="''${!required_params_var} ''${!optional_params_var}"
          
          # Initialize parameter arrays
          IFS=' ' read -ra required_params_array <<< "''${!required_params_var}"
          IFS=' ' read -ra optional_params_array <<< "''${!optional_params_var}"
          local positional_index=0
          local max_positional=''${#required_params_array[@]}
        
          # Process filtered words
          local valid_args=()
          local expecting_value=false
          local current_param=""
        
          for ((word_index=0; word_index<''${#filtered_words[@]}; word_index++)); do
            word="''${filtered_words[$word_index]}"
            
            if $expecting_value; then
              valid_args+=("$current_param" "$word")
              expecting_value=false
              current_param=""
              continue
            fi
        
            if [[ "$word" == --* ]]; then
              param_name=''${word#--}
              if [[ " $all_params " == *" $param_name "* ]]; then
                valid_args+=("$word")
                current_param="$word"
                expecting_value=true
              fi
            else
              # Only assign positional arguments to required params
              if (( positional_index < max_positional )); then
                param_name="''${required_params_array[$positional_index]}"
                valid_args+=("--$param_name" "$word")
                ((positional_index++))
              fi
            fi
          done
        
          # Add default values for unprovided optional params
          for param in "''${optional_params_array[@]}"; do
            if ! [[ " ''${valid_args[@]} " == *" --$param "* ]]; then
              # Get default value using Nix path reference
              default_value=$(nix eval --raw ".#yoScripts.$script_name.parameters.$param.default" 2>/dev/null || true)
              if [[ -n "$default_value" ]]; then
                valid_args+=("--$param" "$default_value")
              fi
            fi
          done
        
          echo "''${valid_args[@]}"
        }
        
        # Find best script match
        best_script=$(fuzzy_match "$text")
        [[ -z "$best_script" ]] && { echo "Error: No script found in '$text'"; exit 1; }
      
        # Clean and validate arguments
        cleaned_args=$(clean_args "$best_script" "$text")
      
        # Execute final command
        run_cmd echo "Executing: yo $best_script $cleaned_args"
        run_cmd yo "$best_script" $cleaned_args
      '';
    };
  };
}
