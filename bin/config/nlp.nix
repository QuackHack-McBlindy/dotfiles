# dotfiles/bin/config/nlp.nix
# 🦆 says ⮞ Quack-powered NLP engine for shell commands.
# 🦆 says ⮞ Translates human-friendly text like "run backup now" into shell invocations.
# 🦆 says ⮞ Uses regex magic, entity substitution, and dynamic intent matching.
# 🦆 says ⮞ Fully declarative: define intents, parameters, and synonym lists in Nix.
# 🦆 says ⮞ Then let the ducks parse your commands and run your scripts.
{ 
  self,
  lib,
  config,
  pkgs,
  sysHosts,
  cmdHelpers,
  ...
} : let # 🦆 says ⮞ turnin’ up da duck loggin'
  DEBUG_MODE = true;
  # 🦆 says ⮞ grabbin’ all da scripts  
  scripts = config.yo.scripts; 
  scriptNames = builtins.attrNames scripts; # 🦆 says ⮞ just names, fam – like a rap sheet for our shell heroes
  # 🦆 says ⮞ only scripts with known intentions
  scriptNamesWithIntents = builtins.filter (scriptName:
    builtins.hasAttr scriptName config.yo.bitch.intents
  ) scriptNames;
  
  paramsVars = builtins.map (scriptName: let
    # 🦆 says ⮞ deep dive into each script's args – wat need wat u say?
    params = scripts.${scriptName}.parameters;
    requiredParams = builtins.filter (param: !param.optional) params; # 🦆 says ⮞ mandatory flippers on deck 
    optionalParams = builtins.filter (param: param.optional) params; # 🦆 says ⮞ optionals? sets up for slackin'
    requiredParamNames = builtins.map (param: param.name) requiredParams; # 🦆 says ⮞ grabbin’ only the labels of mandatory honks
    optionalParamNames = builtins.map (param: param.name) optionalParams; # 🦆 says ⮞ name tags for the lazy 🏷️ quack quack not me
  in ''
    required_params_${scriptName}="${builtins.concatStringsSep " " requiredParamNames}"
    optional_params_${scriptName}="${builtins.concatStringsSep " " optionalParamNames}"
  '') scriptNames; # 🦆 says ⮞ buildin’ dat export string like "required_params_foo=arg1 arg2" – shell-friendly!

  makeEntityCase = entity: e:
    let # 🦆 says ⮞ regex gang ooh noo! all aliases separated by pipes for CASE matches
      patterns = builtins.concatStringsSep "|" e.match;
      value = e.value; # 🦆 says ⮞ the real juice – what these aliases resolve to 
    in
      "${patterns}) val=\"${value}\";;"; # 🦆 says ⮞ turn it into a case clause: if input matches aliases, spit out value, yo!

  # 🦆 says ⮞ dis lil duck turns structured data into a case zoo 
  makeEntityResolver = data: listName: # 🦆 says ⮞ i like ducks
    lib.concatMapStrings (entity: '' 
      "${entity."in"}") echo "${entity.out}";; # 🦆 says ⮞ "in" must always be quoted in Nix. never forget yo
    '') data.lists.${listName}.values; # 🦆 says ⮞ maps each "in" value to an echo of its "out"
    
  makePatternMatcher = scriptName: let
    dataList = config.yo.bitch.intents.${scriptName}.data;
  in ''
    match_${scriptName}() { # 🦆 says ⮞ shushin' da caps – lowercase life 4 cleaner regex zen ✨
      local input="$(echo "$1" | tr '[:upper:]' '[:lower:]')" 
  
      ${lib.concatMapStrings (data:
        lib.concatMapStrings (sentence: let
          sentenceText = sentence; # 🦆 says ⮞ human said: "run the backup now!" – duck translate plz
          parts = lib.splitString "{" sentenceText; # 🦆 says ⮞ curly bois indicate PARAM LAND
  
          firstPart = lib.escapeRegex (lib.elemAt parts 0); # 🦆 says ⮞ gotta escape them weird chars 
          restParts = lib.drop 1 parts;  # 🦆 says ⮞ now we in the variable zone quack?
  
          # 🦆 says ⮞ process each part to build regex and params
          regexParts = lib.imap (i: part:
            let
              split = lib.splitString "}" part; # 🦆 says ⮞ yeah yeah curly close that syntax shell
              param = lib.elemAt split 0; # 🦆 says ⮞ name of the param in da curly – ex: {user}
              after = lib.concatStrings (lib.tail split); # 🦆 says ⮞ anything after the param in this chunk
              isWildcard = data.lists.${param}.wildcard or false; # 🦆 says ⮞ wildcards go hard (.*) mode
              regexGroup = if isWildcard then "\\b([^ ]+)\\b" else "(.*)";             
              # 🦆 says ⮞ ^ da regex that gon match actual input text
            in {
              regex = regexGroup + lib.escapeRegex after;
              param = param;
            }
          ) restParts;
  
          fullRegex = firstPart + lib.concatStrings (map (v: v.regex) regexParts);  # 🦆 says ⮞ mash all regex bits 2gether
          paramList = map (v: v.param) regexParts; # 🦆 says ⮞ the squad of parameters 
        in ''
          local regex='^${fullRegex}$'
          if [[ "$input" =~ $regex ]]; then  # 🦆 says ⮞ DANG DANG – regex match engaged 
            ${lib.concatImapStrings (i: paramName: ''
              # 🦆 says ⮞ extract match group #i+1 – param value, come here plz 🙏
              param_value="''${BASH_REMATCH[${toString (i+1)}]}"
              # 🦆 says ⮞ if param got synonym, apply the duckfilter 🪄
              if [[ -n "''${param_value:-}" && -v substitutions["$param_value"] ]]; then
                param_value="''${substitutions["$param_value"]}"
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
            '') paramList} # 🦆 says ⮞ set dat param as a GLOBAL VAR yo! every duck gotta know 
            # 🦆 says ⮞ build cmd args: --param valu
            cmd_args=()
            ${lib.concatMapStrings (paramName: ''
              cmd_args+=(--${paramName} "$_param_${paramName}")
            '') paramList}
            export DEBUG_MODE=${lib.boolToString DEBUG_MODE} # 🦆 says ⮞ DUCK TRACE yo 
            if [ "$DEBUG_MODE" = true ]; then # 🦆 says ⮞ watch the fancy stuff live in action  
              echo "[🦆📜] ✅DEBUG✅ REMATCH 1: ''${BASH_REMATCH[1]}"
              echo "[🦆📜] ✅DEBUG✅ REMATCH 2: ''${BASH_REMATCH[2]}"
              echo "[🦆📜] ✅DEBUG✅ [MATCH SCRIPT: ${scriptName}"
              echo "[🦆📜] ✅DEBUG✅ ARGS: ''${cmd_args[@]}"
            fi
            echo "REGEX: $regex"
            return 0
          fi
        '') data.sentences
      ) dataList}
      return 1
    }
  '';  

  # 🦆 says ⮞ oh duck... dis is where speed goes steroids yo
  yo.bitch.intentDataFile = pkgs.writeText "intent-entity-map.json"
    (builtins.toJSON (
      lib.mapAttrs (_scriptName: intentList:
        let # 🦆 says ⮞ flat quack all dat alias > value pairs across intents
          allData = lib.flatten (map (d: d.lists or {}) intentList.data);
          substitutions = lib.flatten (map (lists:
            lib.flatten (lib.mapAttrsToList (_listName: listData:
              if listData ? values then
                map (item: {
                  pattern = item."in";
                  value = item.out;
                }) listData.values
              else []
            ) lists)
          ) allData);
        in {
          inherit substitutions;
        }
      ) config.yo.bitch.intents
    ));
# 🦆 says ⮞ expose da magic! dis builds our NLP
in { # 🦆 says ⮞ YOOOOOOOOOOOOOOOOOO  
  yo.scripts = { # 🦆 says ⮞ quack quack quack quack quack.... qwack 
    bitch = { # 🦆 says ⮞ wat ='( 
      description = "Natural language to Shell script translator with dynamic regex matching and automatic parameter resolutiion"; # 🦆 says ⮞ set
      # 🦆 says ⮞ natural means.... human? 
      category = "⚙️ Configuration";
      parameters = [ { name = "input"; description = "Text to parse into a yo command"; optional = false; } ];
      code = '' # 🦆 says ⮞ ... there's moar..? YES! ALWAYS MOAR!
        set +u # 🦆 says ⮞ let them unset vars fly, we rebels now 
        ${cmdHelpers} # 🦆 says ⮞load helper functions 
        intent_data_file="${yo.bitch.intentDataFile}" # 🦆 says ⮞ cache dat JSON wisdom, duck hates slowness
        text="$input" # 🦆 says ⮞ what did the human say? THIS is what the duck gon parse
        
        resolve_entities() {
          local script="$1"
          local text="$2"
          local replacements
          local pattern out
          declare -A substitutions
          # 🦆 says ⮞ dis is our quacktionary yo 
          replacements=$(jq -r '.["'"$script"'"].substitutions[] | "\(.pattern)|\(.value)"' "$intent_data_file")

          while IFS="|" read -r pattern out; do
            if [[ -n "$pattern" && "$text" =~ $pattern ]]; then
              original="''${BASH_REMATCH[0]}"
              [[ -z "''$original" ]] && continue # 🦆 says ⮞ duck no like empty string
              substitutions["''$original"]="$out"
              text=$(echo "$text" | sed -E "s/\\b$pattern\\b/$out/g") # 🦆 says ⮞ swap the word, flip the script 
            fi
          done <<< "$replacements"      
          echo -n "$text"
          echo "|$(declare -p substitutions)" # 🦆 says ⮞ returning da remixed sentence + da whole 
        } 
        
        # 🦆 says ⮞ insert ALL matchers, build da regex empire. yo
        ${lib.concatMapStrings (name: makePatternMatcher name) scriptNames}  
        ${lib.concatMapStrings (name: makePatternMatcher name) scriptNamesWithIntents}

        for script in ${toString scriptNamesWithIntents}; do
          unset substitutions
          resolved_output=$(resolve_entities "$script" "$text")
          resolved_text=$(echo "$resolved_output" | cut -d'|' -f1)
          subs_decl=$(echo "$resolved_output" | cut -d'|' -f2-)
#          eval "$subs_decl" >/dev/null 2>&1 || true
          unset substitutions # 🦆 says ⮞ just in case... duck resets 
          eval "$subs_decl" >/dev/null 2>&1 || true

          if match_$script "$resolved_text"; then      
            args=()
            for arg in "''${cmd_args[@]}"; do
              args+=("$arg")  # 🦆 says ⮞ collecting them shell spell ingredients
            done
            if [[ "$(declare -p substitutions 2>/dev/null)" =~ "declare -A" ]]; then
              for original in "''${!substitutions[@]}"; do
                [[ -n "$original" ]] && echo "$original → ''${substitutions[$original]}"
              done
            fi
         
            # 🦆 says ⮞ final product
            say_duck "Executing: yo-$script ''${args[*]} ''${substitutions[$original]}"
            
            # 🦆 says ⮞ EXECUTEEEEEEEAAA  – duck does not simply parse and sit idly
            exec "yo-$script" ""''${args[@]}"""''${substitutions[$original]}"
              
          fi 
        done # 🦆 says ⮞ done? we all ded nao? 
        if ! match_$script "$resolved_text"; then
          say_duck "fuck ❌ $text" # 🦆 says ⮞ YO!! Language! !
          
          # 🦆 says ⮞ TODO: fuzzy matching... like duck sonar for mismatches     
            
          exit
        fi
      '';    
    };
  };

  # 🦆 says ⮞ export it like 🐢 shares pizza – shared config across da OS
  environment.variables.YO_INTENT_DATA = yo.bitch.intentDataFile;
   
  # 🦆 says ⮞ Empty intents to disable voice activated scripts 
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
      transport = { data = [{ sentences = [ ]; lists = { }; }]; };
      sops = { data = [{ sentences = [ ]; lists = { }; }]; };
      yubi = { data = [{ sentences = [ ]; lists = { }; }]; };
      qr = { data = [{ sentences = [ ]; lists = { }; }]; };
      mic = { data = [{ sentences = [ ]; lists = { }; }]; };      
      zigduck = { data = [{ sentences = [ ]; lists = { }; }]; };    

    };
    
  };}  # 🦆 says ⮞ peace and quack  





