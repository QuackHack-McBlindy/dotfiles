# dotfiles/bin/config/nlp.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ Quack-Powered NLP written in Pure Bash & Nox - Natural Language Processor engine that translates human text to Shell commands
  self,   
  lib, # 🦆 says ⮞ 📌 FEATURES:
  config,    # 🦆 says ⮞ ⭐ Dynamically generated regular expressions for pattern matching against declarative sentence definition + Fuzzy matching fallback
  pkgs,      # 🦆 says ⮞ ⭐ Automatic parameter resolution & entity substitutions
  sysHosts,  # 🦆 says ⮞ ⭐ Automated testing with extensive DuckTrace debug logging & JSON intent indexing
  cmdHelpers,# 🦆 says ⮞ ⭐ Shell command construction & dispatcher
  ...
} : let # 🦆 says ⮞ helpz pass Nix path 4 intent data 2 Bash 
  intentBasePath = "${config.this.user.me.dotfilesDir}#nixosConfigurations.${config.this.host.hostname}.config.yo.bitch.intents";
  # 🦆 says ⮞ grabbin’ all da scripts for ez listin'  
  scripts = config.yo.scripts; 
  scriptNames = builtins.attrNames scripts; # 🦆 says ⮞ just names - we never name one
  # 🦆 says ⮞ only scripts with known intentions
  scriptNamesWithIntents = builtins.filter (scriptName:
    let # 🦆 says ⮞ a intent iz kinda ..
      intent = config.yo.bitch.intents.${scriptName};
      # 🦆 says ⮞ .. pointless if it haz no sentence data ..
      hasSentences = builtins.any (data: data ? sentences && data.sentences != []) intent.data;
    in # 🦆 says ⮞ .. so datz how we build da scriptz!
      builtins.hasAttr scriptName config.yo.bitch.intents && hasSentences
  ) scriptNames; # 🦆 says ⮞ datz quackin' cool huh?!

  # 🦆 says ⮞ QUACK! da duck take a list of listz and duck make all da possible combinationz
  cartesianProductOfLists = lists:
    # 🦆 says ⮞ if da listz iz empty .. 
    if lists == [] then
      [ [] ] # 🦆 says ⮞ .. i gib u empty listz of listz yo got it?
    else # 🦆 says ⮞ ELSE WAT?!
      let # 🦆 says ⮞ sorry.. i gib u first list here u go yo
        head = builtins.head lists;
        # 🦆 says ⮞ remaining listz for u here u go bro!
        tail = builtins.tail lists;
        # 🦆 says ⮞ calculate combinations for my tail - yo calc wher u at?!
        tailProduct = cartesianProductOfLists tail;
      in # 🦆 says ⮞ for everyy x in da listz ..
        lib.concatMap (x:
          # 🦆 says ⮞ .. letz combinez wit every tail combinationz ..  
          map (y: [x] ++ y) tailProduct
        ) head; # 🦆 says ⮞ dang! datz a DUCK COMBO alright!  
         
  # 🦆 says ⮞ here i duckie help yo out! makin' yo life eazy sleazy' wen declarative sentence yo typin'    
  expandOptionalWords = sentence: # 🦆 says ⮞ qucik & simple sentences we quacky & hacky expandin'
    let # 🦆 says ⮞ CHOP CHOP! Rest in lil' Pieceez bigg sentence!!1     
      tokens = lib.splitString " " sentence;      
      # 🦆 says ⮞ definin' dem wordz in da (braces) taggin' dem' wordz az (ALTERNATIVES) lettin' u choose one of dem wen triggerin' 
      isRequiredGroup = t: lib.hasPrefix "(" t && lib.hasSuffix ")" t;
      # 🦆 says ⮞ puttin' sentence wordz in da [bracket] makin' em' [OPTIONAL] when bitchin' u don't have to be pickin' woooho 
      isOptionalGroup = t: lib.hasPrefix "[" t && lib.hasSuffix "]" t;   
      expandToken = token: # 🦆 says ⮞ dis gets all da real wordz out of one token (yo!)
        if isRequiredGroup token then
          let # 🦆 says ⮞ thnx 4 lettin' ducklin' be cleanin' - i'll be removin' dem "()" 
            clean = lib.removePrefix "(" (lib.removeSuffix ")" token);
            alternatives = lib.splitString "|" clean; # 🦆 says ⮞ use "|" to split (alternative|wordz) yo 
          in  # 🦆 says ⮞ dat's dat 4 dem alternativez
            alternatives
        else if isOptionalGroup token then
          let # 🦆 says ⮞ here we be goin' again - u dirty and i'll be cleanin' dem "[]"
            clean = lib.removePrefix "[" (lib.removeSuffix "]" token);
            alternatives = lib.splitString "|" clean; # 🦆 says ⮞ i'll be stealin' dat "|" from u 
          in # 🦆 says ⮞ u know wat? optional means we include blank too!
            alternatives ++ [ "" ]
        else # 🦆 says ⮞ else i be returnin' raw token for yo
          [ token ];      
      # 🦆 says ⮞ now i gib u generatin' all dem combinationz yo
      expanded = cartesianProductOfLists (map expandToken tokens);      
      # 🦆 says ⮞ clean up if too much space, smush back into stringz for ya
      trimmedVariants = map (tokenList:
        let # 🦆 says ⮞ join with spaces then trim them suckers
          raw = lib.concatStringsSep " " tokenList;
          # 🦆 says ⮞ remove ALL extra spaces
          cleaned = lib.replaceStrings ["  "] [" "] (lib.strings.trim raw);
        in # 🦆 says ⮞ wow now they be shinin'
          cleaned 
      ) expanded; # 🦆 says ⮞ and they be multiplyyin'!      
      # 🦆 says ⮞ throwin' out da empty and cursed ones yo
      nonEmpty = lib.filter (s: s != "") trimmedVariants;
      hasFixedText = v: builtins.match ".*[^\\{].*" v != null; # 🦆 says ⮞ no no no, no nullin'
      validVariants = lib.filter hasFixedText nonEmpty;
    in # 🦆 says ⮞ returnin' all unique variantz of da sentences – holy duck dat'z fresh 
      lib.unique validVariants;
  
  # 🦆 says ⮞ we be doin' sorta da same wit dem listz
  expandListInputVariants = value: 
    let # 🦆 says ⮞ first we choppy choppy - break up da list into word tokenz
      tokens = lib.splitString " " value;
      # 🦆 says ⮞ checkin' if a token be wrapped like [diz] = optional, ya feel?
      isOptional = t: lib.hasPrefix "[" t && lib.hasSuffix "]" t;
      # 🦆 says ⮞ now ducklin' expandz each token — either real or optional wit options
      expandToken = token:
        if isOptional token then
          let # 🦆 says ⮞ time 2 clean dat square junk up 4 yo bro
            clean = lib.removePrefix "[" (lib.removeSuffix "]" token);
             # 🦆 says ⮞ u know da drill - splittin' on da "|" to find alt optionalz
            alternatives = lib.splitString "|" clean;
          in
            alternatives
        else # 🦆 says ⮞ not optional? just be givin' back da token as iz
          [ token ];
      expanded = cartesianProductOfLists (map expandToken tokens);
      variants = map (tokenList:
        lib.replaceStrings [ "  " ] [ " " ] (lib.concatStringsSep " " tokenList)
      ) expanded;  # 🦆 says ⮞ only da fresh unique non-emptiez stayin’ in da pond
    in lib.unique (lib.filter (s: s != "") variants);

  # 🦆 says ⮞ optimized pattern expansion
  expandToRegex = sentence: data:
    let
      # 🦆 says ⮞ helper function to convert patterns to regex
      convertPattern = token:
        if lib.hasPrefix "(" token then
          let
            clean = lib.removePrefix "(" (lib.removeSuffix ")" token);
            alternatives = lib.splitString "|" clean;
            escaped = map lib.escapeRegex alternatives;
          in "(?:" + lib.concatStringsSep "|" escaped + ")"
        else if lib.hasPrefix "[" token then
          let
            clean = lib.removePrefix "[" (lib.removeSuffix "]" token);
            alternatives = lib.splitString "|" clean;
            escaped = map lib.escapeRegex alternatives;
          in "(?:" + lib.concatStringsSep "|" escaped + ")?"
        else
          lib.escapeRegex token;
      
      # 🦆 says ⮞ split into tokens while preserving special groups
      tokenize = s:
        let
          groups = builtins.match "([^{]*)(\{[^}]*\})?(.*)" s;
        in
          if groups == null then [s]
          else let
            prefix = builtins.elemAt groups 0;
            param = builtins.elemAt groups 1;
            rest = builtins.elemAt groups 2;
            tokens = if prefix != "" then [prefix] else [];
            tokensWithParam = if param != null then tokens ++ [param] else tokens;
          in tokensWithParam ++ tokenize rest;
      
      # 🦆 says ⮞ process tokens into regex parts
      tokens = tokenize sentence;
      regexParts = map (token:
        if lib.hasPrefix "{" token then
          let
            param = lib.removePrefix "{" (lib.removeSuffix "}" token);
            isWildcard = data.lists.${param}.wildcard or false;
          in if isWildcard then "(.*)" else "\\b([^ ]+)\\b"
        else
          convertPattern token
      ) tokens;
      
      # 🦆 says ⮞ combine parts into final regex
      regex = "^" + lib.concatStrings regexParts + "$";
    in
      regex;
  

  # 🦆 says ⮞ take each value like "yo|hey" and map it to its 'out' – buildin’ da translation matrix yo!
  makeEntityResolver = data: listName: # 🦆 says ⮞ i like ducks
    lib.concatMapStrings (entity:
      let 
        variants = expandListInputVariants entity."in"; # 🦆 says ⮞ "in" must always be quoted in Nix. never forget yo
      in # 🦆 says ⮞ otherwize itz an in like this one!
        lib.concatMapStrings (variant: ''
          "${variant}") echo "${entity.out}";;
        '') variants # 🦆 says ⮞ all of them yo!
    ) data.lists.${listName}.values; # 🦆 says ⮞ maps each "in" value to an echo of its "out"
  
  # 🦆 says ⮞ where da magic dynamic regex iz at 
  makePatternMatcher = scriptName: let
    dataList = config.yo.bitch.intents.${scriptName}.data;    
  in '' # 🦆 says ⮞ diz iz how i pick da script u want 
    match_${scriptName}() { # 🦆 says ⮞ shushin' da caps – lowercase life 4 cleaner dyn regex zen ✨
      local input="$(echo "$1" | tr '[:upper:]' '[:lower:]')" 
      # 🦆 says ⮞ always show input in debug mode
      # 🦆 says ⮞ watch the fancy stuff live in action  
      dt_debug "Trying to match for script: ${scriptName}" >&2
      dt_debug "Input: $input" >&2
      # 🦆 says ⮞ duck presentin' - da madnezz 
      ${lib.concatMapStrings (data:
        lib.concatMapStrings (sentence:
          lib.concatMapStrings (sentenceText: let
            # 🦆 says ⮞ now sentenceText is one of the expanded variants!
            parts = lib.splitString "{" sentenceText; # 🦆 says ⮞ diggin' out da goodies from curly nests! Gimme dem {param} nuggets! 
            firstPart = lib.escapeRegex (lib.elemAt parts 0); # 🦆 says ⮞ gotta escape them weird chars 
            restParts = lib.drop 1 parts;  # 🦆 says ⮞ now we in the variable zone quack?  
            # 🦆 says ⮞ process each part to build regex and params
            regexParts = lib.imap (i: part:
              let
                split = lib.splitString "}" part; # 🦆 says ⮞ yeah yeah curly close that syntax shell
                param = lib.elemAt split 0; # 🦆 says ⮞ name of the param in da curly – ex: {user}
                after = lib.concatStrings (lib.tail split); # 🦆 says ⮞ anything after the param in this chunk
                # 🦆 says ⮞ Wildcard mode! anything goes - duck catches ALL the worms! (.*)
                isWildcard = data.lists.${param}.wildcard or false;
                regexGroup = if isWildcard then "(.*)" else "\\b([^ ]+)\\b";       
                # 🦆 says ⮞ ^ da regex that gon match actual input text
              in {
                regex = regexGroup + lib.escapeRegex after;
                param = param;
              }
            ) restParts;

            fullRegex = let
              clean = lib.strings.trim (firstPart + lib.concatStrings (map (v: v.regex) regexParts));
            in "^${clean}$"; # 🦆 says ⮞ mash all regex bits 2gether
            paramList = map (v: v.param) regexParts; # 🦆 says ⮞ the squad of parameters 
          in ''
            local regex='^${fullRegex}$'
            dt_debug "REGEX: $regex"
            if [[ "$input" =~ $regex ]]; then  # 🦆 says ⮞ DANG DANG – regex match engaged 
              ${lib.concatImapStrings (i: paramName: ''
                # 🦆 says ⮞ extract match group #i+1 – param value, come here plz 
                param_value="''${BASH_REMATCH[${toString (i+1)}]}"
                # 🦆 says ⮞ if param got synonym, apply the duckfilter 
                if [[ -n "''${param_value:-}" && -v substitutions["$param_value"] ]]; then
                  subbed="''${substitutions["$param_value"]}"
                  if [[ -n "$subbed" ]]; then
                    param_value="$subbed"
                  fi
                fi           
                ${lib.optionalString (
                  data.lists ? ${paramName} && !(data.lists.${paramName}.wildcard or false)
                ) ''
                  # 🦆 says ⮞ apply substitutions before case matchin'
                  if [[ -v substitutions["$param_value"] ]]; then
                    param_value="''${substitutions["$param_value"]}"
                  fi
                  case "$param_value" in
                    ${makeEntityResolver data paramName}
                    *) ;;
                  esac
                ''} # 🦆 says ⮞ declare global param – duck want it everywhere! (for bash access)
                declare -g "_param_${paramName}"="$param_value"            
                declare -A params=()
                params["${paramName}"]="$param_value"
                matched_params+=("$paramName")
              '') paramList} # 🦆 says ⮞ set dat param as a GLOBAL VAR yo! every duck gotta know 
              # 🦆 says ⮞ build cmd args: --param valu
              cmd_args=()
              ${lib.concatImapStrings (i: paramName: ''
                value="''${BASH_REMATCH[${toString i}]}"
                cmd_args+=(--${paramName} "$value")
              '') paramList}
              dt_debug "REMATCH 1: ''${BASH_REMATCH[1]}"
              dt_debug "REMATCH 2: ''${BASH_REMATCH[2]}"
              dt_debug "REMATCH 3: ''${BASH_REMATCH[3]}"
              dt_debug "MATCHED SCRIPT: ${scriptName}"
              dt_debug "ARGS: ''${cmd_args[@]}"
              return 0
            fi
          '') (expandOptionalWords sentence)
        ) data.sentences
      ) dataList}
      return 1
    }
  ''; # 🦆 says ⮞ i aint' doin' dat againz ......

  # 🦆 says ⮞ matcher to json yao
  matchers = lib.mapAttrsToList (scriptName: data:
    let
      matcherCode = makePatternMatcher scriptName;
    in {
      name = scriptName;
      value = pkgs.writeText "${scriptName}-matcher" matcherCode;
    }
  ) config.yo.bitch.intents;

  # 🦆 says ⮞ one shell script dat sourcez dem allz
  matcherSourceScript = pkgs.writeText "matcher-loader.sh" (
    lib.concatMapStringsSep "\n" (m: "source ${m.value}") matchers
  );

  # 🦆 says ⮞ helpFooter for yo.bitch script
  helpFooterMd = let
    scriptBlocks = lib.concatMapStrings (scriptName:
      let # 🦆 says ⮞ we just da intentz in da help yo
        intent = config.yo.bitch.intents.${scriptName} or null;
        sentencesList = if intent != null then
          lib.flatten (map (d: d.sentences or []) intent.data)
        else
          []; # 🦆 says ⮞ no sentence - no help
        # 🦆 says ⮞ expand optional bracket syntax for da help view
        expandedSentences = lib.flatten (map expandOptionalWords sentencesList);
        sentencesMd = if expandedSentences == [] then
          "- (no sentences defined)\n"
        else # 🦆 says ⮞ letz put dem sentencez in markdown nao
          lib.concatMapStrings (sentence: "- ${lib.escapeShellArg sentence}\n") expandedSentences;
      in '' 
        ## 🦆 ⮞ **yo ${scriptName}**
        ${sentencesMd}
      '' # 🦆 says ⮞ datz all yo sentencez yo
    ) scriptNamesWithIntents;
  in '' # 🦆 says ⮞ nailin' a title for da help command 
    ## 🦆 ⮞ **Available Voice Commands**
    Trigger with: **yo bitch!**
    ${scriptBlocks}
  ''; # 🦆 says ⮞ we cat diz later yo

  # 🦆 says ⮞ oh duck... dis is where speed goes steroids yo iz diz cachin'? - no more nix evaluatin' lettin' jq takin' over
  intentDataFile = pkgs.writeText "intent-entity-map4.json" # 🦆 says ⮞ change name to force rebuild of file
    (builtins.toJSON ( # 🦆 says ⮞ packin' all our knowledges into a JSON duck-pond for bash to swim in!
      lib.mapAttrs (_scriptName: intentList:
        let
          allData = lib.flatten (map (d: d.lists or {}) intentList.data);
          # 🦆 says ⮞ collect all sentences for diz intent
          sentences = lib.concatMap (d: d.sentences or []) intentList.data;      
          # 🦆 says ⮞ expand all sentence variants
          expandedSentences = lib.unique (lib.concatMap expandOptionalWords sentences);
          # 🦆 says ⮞ "in" > "out" for dem' subz 
          substitutions = lib.flatten (map (lists: # 🦆 says ⮞ iterate through entity lists
            lib.flatten (lib.mapAttrsToList (_listName: listData: # 🦆 says ⮞ process each list definition
              if listData ? values then # 🦆 says ⮞ check for values existence
                lib.flatten (map (item: # 🦆 says ⮞ process each entity value
                  let # 🦆 says ⮞ clean and split input patterns
                    rawIn = item."in";
                    value = item.out;
                    # 🦆 says ⮞ handle cases like: "[foo|bar baz]" > ["foo", "bar baz"]
                    cleaned = lib.removePrefix "[" (lib.removeSuffix "]" rawIn);
                    variants = lib.splitString "|" cleaned;     
                in map (v: let # 🦆 says ⮞ juzt in case - trim dem' spaces and normalize whitespace         
                  cleanV = lib.replaceStrings ["  "] [" "] (lib.strings.trim v);
                in {   
                  pattern = if builtins.match ".* .*" cleanV != null
                            then cleanV         # 🦆 says ⮞ multi word == "foo bar"
                            else "(${cleanV})"; # 🦆 says ⮞ single word == \b(foo)\b
                  value = value;
                }) variants
              ) listData.values)
            else [] # 🦆 says ⮞ no listz defined - sorry dat gives empty list
          ) lists)
        ) allData);
      in { # 🦆 says ⮞ final per script structure
        inherit substitutions;
        sentences = expandedSentences;
      }
    ) config.yo.bitch.intents
  ));

  # 🦆 says ⮞ quack! now we preslicin' dem sentences wit their fuzzynutty signatures for bitchin' fast fuzz-lookup!
  fuzzyIndex = lib.mapAttrsToList (scriptName: intent:
    lib.concatMap (data: # 🦆 says ⮞ dive into each intent entryz like itz bread crumbs
      lib.concatMap (sentence: # 🦆 says ⮞ grab all dem raw sentence templates
        map (expanded: { # 🦆 says ⮞ ayy, time to expand theze feathers
          script = scriptName; # 🦆 says ⮞ label diz bird wit itz intent script yo
          sentence = expanded; # 🦆 says ⮞ this da expanded sentence duck gon' match against
          # 🦆 says ⮞ precompute signature for FAAASTEERRr matching - quicky quacky snappy matchin' yo! 
          signature = let
            words = lib.splitString " " (lib.toLower expanded); # 🦆 says ⮞ lowercase & split likez stale rye
            sorted = lib.sort (a: b: lib.hasPrefix a b) words; # 🦆 says ⮞ duck sort dem quackz alphabetically-ish quack quack
          in builtins.concatStringsSep "|" sorted;  # 🦆 says ⮞ make a fuzzy-flyin’ signature string, pipe separated - yo' know it 
        }) (expandOptionalWords sentence) # 🦆 says ⮞ diz iz where optional wordz becomez reality
      ) data.sentences # 🦆 says ⮞ waddlin' through all yo' sentencez
    ) intent.data # 🦆 says ⮞ scoopin' from every intentz
  ) config.yo.bitch.intents; # 🦆 says ⮞ diz da sacred duck scripture — all yo' intents livez here boom  
  fuzzyIndexFile = pkgs.writeText "fuzzy-index.json" (builtins.toJSON fuzzyIndex);
  matcherDir = pkgs.linkFarm "yo-matchers" (
    map (m: { name = "${m.name}.sh"; path = m.value; }) matchers
  ); # 🦆 says ⮞ export da nix store path to da intent data - could be useful yo
  environment.variables."YO_INTENT_DATA" = intentDataFile; 
  environment.variables."ỲO_FUZZY_INDEX" = fuzzyIndexFile;   
  environment.variables."MATCHER_DIR" = matcherDir;
  environment.variables."MATCHER_SOURCE" = matcherSourceScript;
    
  # 🦆 says ⮞ priority system 4 runtime optimization
  scriptRecordsWithIntents = 
    let # 🦆 says ⮞ calculate priority
      calculatePriority = scriptName:
        config.yo.bitch.intents.${scriptName}.priority or 3; # Default medium
      # 🦆 says ⮞ create script records metadata
      makeRecord = scriptName: rec {
        name = scriptName;
        priority = calculatePriority scriptName;
        hasComplexPatterns = 
          let 
            intent = config.yo.bitch.intents.${scriptName};
            patterns = lib.concatMap (d: d.sentences) intent.data;
          in builtins.any (p: lib.hasInfix "{" p || lib.hasInfix "[" p) patterns;
      };    
    in lib.sort (a: b:
        # 🦆 says ⮞ primary sort: lower number = higher priority
        a.priority < b.priority 
        # 🦆 says ⮞ secondary sort: simple patterns before complex ones
        || (a.priority == b.priority && !a.hasComplexPatterns && b.hasComplexPatterns)
        # 🦆 says ⮞ third sort: alphabetical for determinism
        || (a.priority == b.priority && a.hasComplexPatterns == b.hasComplexPatterns && a.name < b.name)
      ) (map makeRecord scriptNamesWithIntents);
  # 🦆 says ⮞ generate optimized processing order
  processingOrder = map (r: r.name) scriptRecordsWithIntents;
  
# 🦆 says ⮞ expose da magic! dis builds our NLP
in { # 🦆 says ⮞ YOOOOOOOOOOOOOOOOOO    
  yo.scripts = { # 🦆 says ⮞ quack quack quack quack quack.... qwack 
    bitch = { # 🦆 says ⮞ wat ='( 
      description = "Natural language to Shell script translator with dynamic regex matching and automatic parameter resolutiion";
      # 🦆 says ⮞ natural means.... human? 
      category = "⚙️ Configuration"; # 🦆 says ⮞ duckgorize iz zmart wen u hab many scriptz i'd say!
      logLevel = "DEBUG";
      autoStart = false;
      parameters = [{ name = "input"; description = "Text to parse into a yo command"; optional = false; }]; 
      # 🦆 says ⮞ run yo bitch --help to display all defined voice commands
      helpFooter = ''
        WIDTH=$(tput cols) # 🦆 duck say ⮞ Auto detect width
        cat <<EOF | ${pkgs.glow}/bin/glow --width $WIDTH -
${helpFooterMd}
EOF
      ''; # 🦆 says ⮞ ... there's moar..? YES! ALWAYS MOAR!
      code = ''
        set +u  
        ${cmdHelpers} # 🦆 says ⮞load required bash helper functions 
        intent_data_file="${intentDataFile}" # 🦆 says ⮞ cache dat JSON wisdom, duck hates slowridez
        YO_FUZZY_INDEX="${fuzzyIndexFile}" # For fuzzy nutty duckz
        text="$input" # 🦆 says ⮞ for once - i'm lettin' u doin' da talkin'
        match_result_flag=$(mktemp)
        trap 'rm -f "$match_result_flag"' EXIT
        debug_attempted_matches=()
        substitution_applied=false   
        declare -A script_substitutions_data
        declare -A script_has_lists  
        intent_data_json=$(<"$intent_data_file")
        while IFS=$'\t' read -r script pattern value; do
            if [[ -n "$script" ]]; then
                script_has_lists["$script"]=1
                key="''${script}:''${pattern}"
                script_substitutions_data["$key"]="$value"
            fi
        done < <(
            jq -r 'to_entries[] | .key as $script | .value.substitutions[]? | 
                    [$script, .pattern, .value] | @tsv' \
            <<<"$intent_data_json"
        )
        levenshtein() {
          local a="$1" b="$1"
          local -i len_a=''${#a} len_b=''${#b}
          local -a d; local -i i j cost
    
          for ((i=0; i<=len_a; i++)); do d[i]=$i; done
          for ((j=1; j<=len_b; j++)); do
            prev=$j
            for ((i=1; i<=len_a; i++)); do
              [[ "''${a:i-1:1}" == "''${b:j-1:1}" ]] && cost=0 || cost=1
              act=$(( d[i-1] + cost ))
              d[i]=$(( (d[i]+1) < (prev+1) ? 
                       ((d[i]+1) < act ? d[i]+1 : act) : 
                       ((prev+1) < act ? prev+1 : act) ))
              prev=$((d[i]))
            done
            d[0]=$j
          done
          echo ''${d[len_a]}
        }
        
        # 🦆 says ⮞ subz and entities lists handler yo
        resolve_entities() {
          local script="$1"
          local text="$2"
          local replacements
          local pattern out
          declare -A substitutions
          # 🦆 says ⮞ skip subs if script haz no listz
          has_lists=$(jq -e '."'"$script"'"?.substitutions | length > 0' "$intent_data_file" 2>/dev/null || echo false)
          if [[ "$has_lists" != "true" ]]; then
            echo -n "$text"
            echo "|declare -A substitutions=()"  # 🦆 says ⮞ empty substitutions
            return
          fi                    
          # 🦆 says ⮞ dis is our quacktionary yo 
          replacements=$(jq -r '.["'"$script"'"].substitutions[] | "\(.pattern)|\(.value)"' "$intent_data_file")
          while IFS="|" read -r pattern out; do
            if [[ -n "$pattern" && "$text" =~ $pattern ]]; then
              original="''${BASH_REMATCH[0]}"
              [[ -z "''$original" ]] && continue # 🦆 says ⮞ duck no like empty string
              substitutions["''$original"]="$out"
              substitution_applied=true # 🦆 says ⮞ rack if any substitution was applied
              text=$(echo "$text" | sed -E "s/\\b$pattern\\b/$out/g") # 🦆 says ⮞ swap the word, flip the script 
            fi
          done <<< "$replacements"      
          echo -n "$text"
          echo "|$(declare -p substitutions)" # 🦆 says ⮞ returning da remixed sentence + da whole 
        }
        trigram_similarity() {
          local str1="$1"
          local str2="$2"
          declare -a tri1 tri2 # 🦆 says ⮞ generate trigramz
          for ((i=0; i<''${#str1}-2; i++)); do
            tri1+=( "''${str1:i:3}" )
          done
          for ((i=0; i<''${#str2}-2; i++)); do
            tri2+=( "''${str2:i:3}" )
          done # 🦆 says ⮞ count dem' matches yo
          local matches=0
          for t in "''${tri1[@]}"; do
            [[ " ''${tri2[*]} " == *" $t "* ]] && ((matches++))
          done # 🦆 says ⮞ calc da % yo
          local total=$(( ''${#tri1[@]} + ''${#tri2[@]} ))
          (( total == 0 )) && echo 0 && return
          echo $(( 100 * 2 * matches / total ))  # 0-100 scale
        }       
        levenshtein_similarity() {
          local a="$1" b="$2"
          local len_a=''${#a} len_b=''${#b}
          local max_len=$(( len_a > len_b ? len_a : len_b ))   
          (( max_len == 0 )) && echo 100 && return     
          local dist=$(levenshtein "$a" "$b")
          local score=$(( 100 - (dist * 100 / max_len) ))         
          # 🦆 says ⮞ boostz da score for same startin' charizard yo
          [[ "''${a:0:1}" == "''${b:0:1}" ]] && score=$(( score + 10 ))
          echo $(( score > 100 ? 100 : score )) # 🦆 says ⮞ 100 iz da moon yo
        }
        
#        for f in "$MATCHER_DIR"/*.sh; do [[ -f "$f" ]] && source "$f"; done
        scripts_ordered_by_priority=(
          ${lib.concatMapStringsSep "\n" (name: "  \"${name}\"") processingOrder}
        )
  
        find_best_fuzzy_match() {
          local input="$1"
          local best_score=0
          local best_match=""
          local normalized=$(echo "$input" | tr '[:upper:]' '[:lower:]' | tr -d '[:punct:]')
          local candidates
          mapfile -t candidates < <(jq -r '.[] | .[] | "\(.script):\(.sentence)"' "$YO_FUZZY_INDEX")          
          dt_debug "Found ''${#candidates[@]} candidates for fuzzy matching" >&2
          if [[ -z "$normalized" || "$normalized" =~ ^[[:space:]]*$ ]]; then
            dt_error "Empty input after normalization"
            return 1
          fi
          
          for candidate in "''${candidates[@]}"; do
            IFS=':' read -r script sentence <<< "$candidate"
            local norm_sentence=$(echo "$sentence" | tr '[:upper:]' '[:lower:]' | tr -d '[:punct:]')
            if [[ -z "$norm_sentence" ]]; then
              dt_debug "Skipping empty pattern for: $script"
              continue
            fi
            local input_words=($normalized)
            local pattern_words=($norm_sentence)
            local match_count=0      
            for iword in "''${input_words[@]}"; do
              for pword in "''${pattern_words[@]}"; do
                # 🦆 says ⮞  skip da param placeholders
                if [[ "$pword" == \{* ]]; then
                  continue
                fi        
                # 🦆 says ⮞  basic substring match
                if [[ "$iword" == *"$pword"* || "$pword" == *"$iword"* ]]; then
                  ((match_count++))
                  break
                fi
              done
            done
            local score=$(( (match_count * 100) / ''${#pattern_words[@]} )) # 🦆 says ⮞  calculate score as percentage of matched words   
            # 🦆 says ⮞  ensures score is within bounds
            if (( score > 100 )); then
              score=100
            elif (( score < 0 )); then
              score=0
            fi   
            dt_debug "Candidate: $norm_sentence ⮞ $match_count/''${#pattern_words[@]} words ⮞ $score%"
            if (( score > best_score )); then
              best_score=$score
              best_match="$script:$sentence"
              dt_debug "New best match: $best_match ($score%)" >&2
            fi
          done
          if (( best_score > 15 )); then
              echo "$best_match|$best_score" | tr -d '\n'
          else
              echo ""
          fi
        }
        
        extract_params_from_fuzzy_match() {
          local input="$1"
          local pattern="$2"      
          dt_debug "Extracting params: '$input' using '$pattern'"
          cmd_args=()
          # 🦆 says ⮞ try to find numbers in input
          local numbers=($(grep -o -E '[0-9]+' <<< "$input" || true))
          
          # 🦆 says ⮞ extract parameter names from pattern
          local param_names=()
          while [[ "$pattern" =~ \{([^}]+)\} ]]; do
            param_names+=("''${BASH_REMATCH[1]}")
            pattern=''${pattern#*\}}
          done
          
          for ((i=0; i<''${#numbers[@]}; i++)); do
            if [[ -n "''${param_names[$i]}" ]]; then
              cmd_args+=(--"''${param_names[$i]}" "''${numbers[$i]}")
              dt_debug "Assigned number ''${numbers[$i]} to ''${param_names[$i]}"
            fi
          done
          # 🦆 says ⮞ if assigned at least one parameter it's successful!
          if (( ''${#cmd_args[@]} > 0 )); then
            return 0
          else
            dt_error "No parameters extracted"
            return 1
          fi
        }
    
        parse_time_components() {
          local input="$1"
          local found=0
          if [[ "$input" =~ ([0-9]+)[[:space:]]*(t|timmar|timme|h|hours|hour) ]]; then
            cmd_args+=(--hours "''${BASH_REMATCH[1]}")
            found=1
          fi
          if [[ "$input" =~ ([0-9]+)[[:space:]]*(m|minuter|minut|min|minutes|minute) ]]; then
            cmd_args+=(--minutes "''${BASH_REMATCH[1]}")
            found=1
          fi
          if [[ "$input" =~ ([0-9]+)[[:space:]]*(s|sekunder|sekund|sec|seconds|second) ]]; then
            cmd_args+=(--seconds "''${BASH_REMATCH[1]}")
            found=1
          fi
          if [[ "$input" =~ ([0-9]+[hH]) ]]; then
            cmd_args+=(--hours "''${BASH_REMATCH[1]//[^0-9]/}")
          fi
          if [[ "$input" =~ ([0-9]+[mM]) ]]; then
            cmd_args+=(--minutes "''${BASH_REMATCH[1]//[^0-9]/}")
          fi
          if [[ "$input" =~ ([0-9]+[sS]) ]]; then
            cmd_args+=(--seconds "''${BASH_REMATCH[1]//[^0-9]/}")
          fi   
          (( found )) && return 0
          return 1
        }
       
        # 🦆 says ⮞ insert matchers, build da regex empire. yo
#        ${lib.concatMapStrings (name: makePatternMatcher name) scriptNamesWithIntents}  
        # 🦆 says ⮞ for dem scripts u defined intents for ..
        exact_match_handler() {        
          fuzzy_match_handler &
          pid2=$!
          for script in "''${scripts_ordered_by_priority[@]}"; do
            # 🦆 says ⮞ .. we insert wat YOU sayz & resolve entities wit dat yo
            resolved_output=$(resolve_entities "$script" "$text")
            resolved_text=$(echo "$resolved_output" | cut -d'|' -f1)
            dt_debug "Tried: match_''${script} '$resolved_text'"
            # 🦆 says ⮞ we declare som substitutionz from listz we have - duckz knowz why 
            subs_decl=$(echo "$resolved_output" | cut -d'|' -f2-)
            declare -gA substitutions || true
            eval "$subs_decl" >/dev/null 2>&1 || true
            # 🦆 says ⮞ we hab a match quacky quacky diz sure iz hacky!
            if match_$script "$resolved_text"; then      
              if [[ "$(declare -p substitutions 2>/dev/null)" =~ "declare -A" ]]; then
                for original in "''${!substitutions[@]}"; do
                  dt_debug "Substitution: $original >''${substitutions[$original]}";
                  [[ -n "$original" ]] && dt_info "$original > ''${substitutions[$original]}" # 🦆 says ⮞ see wat duck did there?
                done # 🦆 says ⮞ i hop duck pick dem right - right?
              fi
              args=() # 🦆 says ⮞ duck gettin' ready 2 build argumentz 4 u script 
              for arg in "''${cmd_args[@]}"; do
                dt_debug "ADDING PARAMETER: $arg"
                args+=("$arg")  # 🦆 says ⮞ collecting them shell spell ingredients
              done
         
              # 🦆 says ⮞ final product - hope u like say duck!
              paramz="''${args[@]}"

              echo "exact" > "$match_result_flag" # 🦆 says ⮞ tellz fuzzy handler we done
              dt_info "Executing: yo $script $paramz" 
              # 🦆 says ⮞ EXECUTEEEEEEEAAA  – HERE WE QUAAAAACKAAAOAA
              exec "yo-$script" "''${args[@]}"   
              kill -9 $$  # 🦆 says ⮞ kill the entire script process
              exit
            fi         
          done 
        }        

        # 🦆 SCREAMS ⮞ FUZZY WOOOO TO THE MOON                
        fuzzy_match_handler() {        
          fuzzy_result=$(find_best_fuzzy_match "$text")
          ret=$?        
          if [[ $ret -ne 0 ]]; then
            dt_error "Fuzzy match failed"
            log_failed_input "$text"
            say_no_match
            exit 1
          fi
        
          if [[ -n "$fuzzy_result" ]]; then
            dt_debug "Raw fuzzy result: $fuzzy_result"
            IFS='|' read -r match_data actual_score best_score <<< "$fuzzy_result"
            if [[ -z "$best_score" ]]; then
                best_score="$actual_score"
            fi
            dt_debug "Split: match_data='$match_data' actual_score='$actual_score' best_score='$best_score'"   
            IFS=':' read -r matched_script matched_sentence <<< "$match_data"      
            if (( best_score >= 15 )); then
                dt_info "Match found ($best_score%): $match_data"
                resolved_output=$(resolve_entities "$matched_script" "$text")
                resolved_text=$(echo "$resolved_output" | cut -d'|' -f1)
                # 🦆 says ⮞ checkz if exact match already done
                while kill -0 "$pid1" 2>/dev/null; do
                  sleep 0.05
                done
                # 🦆 says ⮞ checkz if exact match succeeded yo
                if [[ -f "$match_result_flag" && "$(cat "$match_result_flag")" == "exact" ]]; then
                  dt_info "Exact match already handled execution. Fuzzy exiting."
                  exit 0
                fi

                if extract_params_from_fuzzy_match "$resolved_text" "$matched_sentence"; then
                    paramz="''${cmd_args[@]}"
                    dt_info "Executing: yo $matched_script $paramz"
                    exec "yo-$matched_script" "''${cmd_args[@]}"
                    sleep 0.1
                    force_exit 1
                else
                    dt_warning "Parameter extraction failed, using time parser"
                    if parse_time_components "$resolved_text"; then
                        paramz="''${cmd_args[@]}"
                        dt_info "Executing fallback: yo $matched_script $paramz"
#                        exec "yo-$matched_script" "''${cmd_args[@]}"
                        exit 0
                    else
                        dt_error "All parameter extraction failed!"
                        say_no_match
                        exit 1
                    fi
                fi
            else
                dt_error "Match score too low (''${best_score}%)"
                say_no_match
                exit 1
            fi
          else
            dt_error "No fuzzy match found"
            say_no_match
            exit 1
          fi
        }
        # 🦆 says ⮞ if exact match winz, no need for fuzz! but fuzz ready to quack when regex chokes
        exact_match_handler
        exit
      '';
    };
    
    # 🦆 says ⮞ automatic bitchin' sentencin' testin'
    tests = { # 🦆 says ⮞ just run yo tests to do an extensive automated test based on your defined sentence data 
      description = "Automated unit testing"; 
      category = "⚙️ Configuration";
      autoStart = false;
      logLevel = "INFO";
      # 🦆 says ⮞ TODO add moar parameter flagz for other testz
      parameters = [{ name = "debug"; description = "Using this flag when running the tests gives extensive debug logging."; optional = true; }];       
      code = ''    
        set +u  
        ${cmdHelpers} # 🦆 says ⮞load required bash helper functions 
        intent_data_file="${intentDataFile}" # 🦆 says ⮞ cache dat JSON wisdom, duck hates slowridez
        intent_base_path="${intentBasePath}" # 🦆 says ⮞ use da prebuilt path yo
        config_json=$(nix eval "$intent_base_path.$script" --json)
        passed=""
        failed=""
        total=""
        failures=()  # 🦆 says ⮞ quack! we'll store failures here!
        text="" # 🦆 says ⮞ for once - i'm lettin' u doin' da talkin'
        debug_attempted_matches=()
        substitution_applied=false                 
        # 🦆 says ⮞ insert matchers, build da regex empire. yo
        ${lib.concatMapStrings (name: makePatternMatcher name) scriptNamesWithIntents}  
        resolve_entities() {
          local script="$1"
          local text="$2"
          local replacements
          local pattern out
          declare -A substitutions
          # 🦆 says ⮞ skip subs if script haz no listz
          has_lists=$(jq -e '."'"$script"'"?.substitutions | length > 0' "$intent_data_file" 2>/dev/null || echo false)
          if [[ "$has_lists" != "true" ]]; then
            echo -n "$text"
            echo "|declare -A substitutions=()"  # 🦆 says ⮞ empty substitutions
            sleep 0.1           
          fi                    
          # 🦆 says ⮞ dis is our quacktionary yo 
          replacements=$(jq -r '.["'"$script"'"].substitutions[] | "\(.pattern)|\(.value)"' "$intent_data_file")
          while IFS="|" read -r pattern out; do
            if [[ -n "$pattern" && "$text" =~ $pattern ]]; then
              original="''${BASH_REMATCH[0]}"
              [[ -z "''$original" ]] && continue # 🦆 says ⮞ duck no like empty string
              substitutions["''$original"]="$out"
              substitution_applied=true # 🦆 says ⮞ rack if any substitution was applied
              text=$(echo "$text" | sed -E "s/\\b$pattern\\b/$out/g") # 🦆 says ⮞ swap the word, flip the script 
            fi
          done <<< "$replacements"      
          echo -n "$text"
          echo "|$(declare -p substitutions)" # 🦆 says ⮞ returning da remixed sentence + da whole 
        } # 🦆 says ⮞ process sentence to replace {parameters} with real wordz yo        
        resolve_sentence() {
          local script="$1"
          config_json=$(nix eval "$intent_base_path.$script" --json 2>/dev/null)
          [ -z "$config_json" ] && config_json="{}"          
          local sentence="$2"    
          local parameters # 🦆 says ⮞ first replace parameters to avoid conflictz wit regex processin' yo
          parameters=($(grep -oP '{\K[^}]+' <<< "$sentence"))          
          for param in "''${parameters[@]}"; do
            is_wildcard=$(jq -r --arg param "$param" '.data[0].lists[$param].wildcard // "false"' <<< "$config_json" 2>/dev/null)
            local replacement=""
            if [[ "$is_wildcard" == "true" ]]; then
              # 🦆 says ⮞ use da context valuez
              if [[ "$param" =~ hour|minute|second ]]; then
                replacement="1"  # 🦆 says ⮞ use numbers for time parameters
              elif [[ "$param" =~ room|device ]]; then
                replacement="livingroom" # 🦆 says ⮞ use realistic room names
              else
                replacement="test" # 🦆 says ⮞ generic test value
              fi
            else
              mapfile -t outs < <(jq -r --arg param "$param" '.data[0].lists[$param].values[].out' <<< "$config_json" 2>/dev/null)
              if [[ ''${#outs[@]} -gt 0 ]]; then
                replacement="''${outs[0]}"
              else
                replacement="unknown"
              fi
            fi
            sentence="''${sentence//\{$param\}/$replacement}"
          done # 🦆 says ⮞ process regex patterns after parameter replacement
          # 🦆 says ⮞ handle alternatives - (word1|word2) == pick first alternative
          sentence=$(echo "$sentence" | sed -E 's/\(([^|)]+)(\|[^)]+)?\)/\1/g')          
          # 🦆 says ⮞ handle optional wordz - [word] == include da word
          sentence=$(echo "$sentence" | sed -E 's/\[([^]]+)\]/ \1 /g')          
          # 🦆 says ⮞ handle vertical bars in alternatives - word1|word2 == word1
          sentence=$(echo "$sentence" | sed -E 's/(^|\s)\|(\s|$)/ /g')  # 🦆 says ⮞ remove standalone vertical bars
          sentence=$(echo "$sentence" | sed -E 's/([^ ]+)\|([^ ]+)/\1/g')  # 🦆 says ⮞ pick first alternative in groups          
          # 🦆 says ⮞ clean up spaces
          sentence=$(echo "$sentence" | tr -s ' ' | sed -e 's/^ //' -e 's/ $//')
          echo "$sentence"
        }
        # 🦆 says ⮞ test defined intent sentences
        test_all_sentences() {
          declare -a failures=()  # 🦆 says ⮞ array to store da failures
          for script in ${toString scriptNamesWithIntents}; do
            echo "[🦆📜] Testing script: $script"    
            # 🦆 says ⮞ eval dat thang yo
            config_json=$(nix eval "$intent_base_path.$script" --json)
            mapfile -t raw_sentences < <(jq -r '.data[].sentences[]' <<< "$config_json")
            for template in "''${raw_sentences[@]}"; do
              test_sentence=$(resolve_sentence "$script" "$template")
              echo " Sentence: $test_sentence"
              resolved_output=$(resolve_entities "$script" "$test_sentence")
              resolved_text=$(echo "$resolved_output" | cut -d'|' -f1)
              subs_decl=$(echo "$resolved_output" | cut -d'|' -f2-)
              declare -gA substitutions || true
              eval "$subs_decl" >/dev/null 2>&1 || true
              if match_$script "$resolved_text"; then
                say_duck "yay ✅ PASS: $resolved_text"
                ((passed++))
              else
                say_duck "fuck ❌ FAIL: $resolved_text"
                # 🦆 says ⮞ store failure details: script, original template, and resolved text
                failures+=("SCRIPT: $script | SENTENCE: $template | TEST: $resolved_text")
              fi
              ((total++))
            done
          done  
          # 🦆 says ⮞ show failures if any
          if [ ''${#failures[@]} -gt 0 ]; then
            echo "" && echo -e "''${RED} ## ────── FAILED TESTS ────── ## ''${RESET}"
            for failure in "''${failures[@]}"; do
              echo "❌ $failure"
            done
            echo -e "''${RED} ## ────────────────────────── ## ''${RESET}" && echo ""
          fi
        }  
        test_all_sentences
        # 🦆 says ⮞ display final report
        percent=$(( 100 * $passed / $total )) # 🦆 says ⮞ count da %
        # 🦆 says ⮞ colorize based on da %
        if [ "$percent" -ge 70 ]; then color="$GREEN"; else color="$RED"; fi        
        echo "" && echo "## ──────⋆⋅☆⋅⋆────── ##"
        bold "Testing  completed!" 
        say_duck "Tests passed: $passed / $total (''${color}''${percent}%''${GRAY})"
        echo "" && echo "## ──────⋆⋅☆⋅⋆────── ##"
        if [ "$passed" -ne "$total" ]; then exit 1; fi    
      ''; # 🦆 says ⮞ thnx for quackin' along til da end!
    }; # 🦆 says ⮞ the duck be stateless, the regex be law, and da shell... is my pond.
  };}# 🦆 say ⮞ nobody beat diz nlp nao says sir quack a lot NOBODY I SAY!
# 🦆 says ⮞ QuackHack-McBLindy out!
