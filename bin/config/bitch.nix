
# dotfiles/bin/config/bitch.nix
# The Bitch Module - Full NLP interface in Nix and Bash, with dynamic regex matching, parameter extraction, and resolution.

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
              if [[ -n "''${substitutions[\"$param_value\"]}" ]]; then
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
            echo "paramList: ''${paramList[@]}"
            echo "_param_typ=$_param_typ"
            echo "_param_search=$_param_search"
            cmd_args=()
            ${lib.concatMapStrings (paramName: ''
              cmd_args+=(--${paramName} "$_param_${paramName}")
            '') paramList}
            echo "REGEX: $regex"
            echo "REMATCH 1: ''${BASH_REMATCH[1]}"
            echo "REMATCH 2: ''${BASH_REMATCH}[2]"
            echo "MATCH SCRIPT: ${scriptName}"
            echo "ARGS: ''${cmd_args[@]}"
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
        echo "➤ Executing: yo $script ''${args[@]}"
        for script in ${toString scriptNames}; do
          resolved_output=$(resolve_entities "$script" "$text")
          resolved_text=$(echo "$resolved_output" | cut -d'|' -f1)
          subs_decl=$(echo "$resolved_output" | cut -d'|' -f2-)
      
          unset substitutions
          eval "$subs_decl" >/dev/null 2>&1 || true
      
          echo "INPUT AFTER PROCESSING: $resolved_text"
          [[ -n "$subs_decl" ]] && declare -p substitutions
      
          if match_$script "$resolved_text"; then
            args=()
            for arg in "''${cmd_args[@]}"; do
              args+=("$arg")
            done
      
            if [[ "''${#substitutions[@]}" -gt 0 ]]; then
              for original in "''${!substitutions[@]}"; do
                echo "Replaced: $original → ''${substitutions[$original]}"
              done
            fi
      
            echo "➤ Executing: yo $script ''${args[@]}''${substitutions[$original]}"
            exec "yo-$script" "''${args[@]}""''${substitutions[$original]}"
            
          fi
        done
      
        echo "No matching command found for: $text"
        exit 1
      '';    
    };
  };
   
  # Voice disabled scripts 
  yo.bitch = {
    intents = {
      bitch = { data = [{ sentences = [ ]; lists = { }; }]; };
      block = { data = [{ sentences = [ ]; lists = { }; }]; };
      clean = { data = [{ sentences = [ ]; lists = { }; }]; };
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
