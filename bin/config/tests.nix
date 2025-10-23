# dotfiles/bin/config/tests.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ Aitp,ated testomg fra,ewprl for NLP module
  self,
  lib,
  config,
  pkgs,
  sysHosts,
  cmdHelpers,
  ...
} : let
  # 🦆 says ⮞ grabbin’ all da scripts for ez listin'  
  scripts = config.yo.scripts; 
  scriptNames = builtins.attrNames scripts; # 🦆 says ⮞ just names - we never name one
  # 🦆 says ⮞ only scripts with known intentions
  scriptNamesWithIntents = builtins.filter (scriptName:
    let # 🦆 says ⮞ a intent iz kinda ..
      intent = generatedIntents.${scriptName};
      # 🦆 says ⮞ .. pointless if it haz no sentence data ..
      hasSentences = builtins.any (data: data ? sentences && data.sentences != []) intent.data;
    in # 🦆 says ⮞ .. so datz how we build da scriptz!
      builtins.hasAttr scriptName generatedIntents && hasSentences
  ) scriptNames; # 🦆 says ⮞ datz quackin' cool huh?!

  scriptsWithVoice = lib.filterAttrs (_: script: script.voice != null) config.yo.scripts;
  
  generatedIntents = lib.mapAttrs (name: script: {
    priority = script.voice.priority or 3;
    data = [{
      inherit (script.voice) sentences lists;
    }];
  }) scriptsWithVoice;

  # 🦆 says ⮞ helpz pass Nix path 4 intent data 2 Bash 
  intentBasePath = "${config.this.user.me.dotfilesDir}#nixosConfigurations.${config.this.host.hostname}.config.yo.scripts";
  
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
    dataList = generatedIntents.${scriptName}.data;    
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
  ''; # 🦆 says ⮞ dat was fun! let'z do it again some time

  # 🦆 says ⮞ quack and scan, match bagan
  makeFuzzyPatternMatcher = scriptName: let
    dataList = generatedIntents.${scriptName}.data;
  in '' # 🦆 says ⮞ fuzz in code, waddle mode
    match_fuzzy_${scriptName}() {
      local input="$(echo "$1" | tr '[:upper:]' '[:lower:]')"
      local matched_sentence="$2"
      # 🦆 says ⮞ skip regex! dat shit iz crazy - use aligned wordz yo
      declare -A params=()
      local input_words=($input)
      local sentence_words=($matched_sentence)     
      # 🦆 says ⮞ extract params by aligning words cool huh
      for i in ''${!sentence_words[@]}; do
        local word="''${sentence_words[$i]}"
        if [[ "$word" == \{*\} ]]; then
          local param_name="''${word:1:-1}"
          params["$param_name"]="''${input_words[$i]}"
        fi
      done
      # 🦆 says ⮞ apply subs to params yo
      for param in "''${!params[@]}"; do
        local value="''${params[$param]}"
        if [[ -v substitutions["$value"] ]]; then
          params["$param"]="''${substitutions["$value"]}"
        fi
      done
      # 🦆 says ⮞ build da paramz
      cmd_args=()
      for param in "''${!params[@]}"; do
        cmd_args+=(--"$param" "''${params[$param]}")
      done
      return 0
    }
  '';
  
  # 🦆 says ⮞ matcher to json yao
  matchers = lib.mapAttrsToList (scriptName: data:
    let
      matcherCode = makePatternMatcher scriptName;
    in {
      name = scriptName;
      value = pkgs.writeText "${scriptName}-matcher" matcherCode;
    }
  ) generatedIntents;

  # 🦆 says ⮞ one shell script dat sourcez dem allz
  matcherSourceScript = pkgs.writeText "matcher-loader.sh" (
    lib.concatMapStringsSep "\n" (m: "source ${m.value}") matchers
  );

  # 🦆 says ⮞ helpFooter for yo.bitch script
  helpFooterMd = let
    scriptBlocks = lib.concatMapStrings (scriptName:
      let # 🦆 says ⮞ we just da intentz in da help yo
        intent = generatedIntents.${scriptName} or null;
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
  intentDataFile = pkgs.writeText "intent-entity-map6.json" # 🦆 says ⮞ change name to force rebuild of file
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
    ) generatedIntents
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
  ) generatedIntents; # 🦆 says ⮞ diz da sacred duck scripture — all yo' intents livez here boom  
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
        generatedIntents.${scriptName}.priority or 3; # Default medium
      # 🦆 says ⮞ create script records metadata
      makeRecord = scriptName: rec {
        name = scriptName;
        priority = calculatePriority scriptName;
        hasComplexPatterns = 
          let 
            intent = generatedIntents.${scriptName};
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
  # 🦆 says ⮞ generate optimized processing order - check pattern, phrases, ratio and priority
  processingOrder = map (r: r.name) scriptRecordsWithIntents;
  
# 🦆 says ⮞ expose da magic! dis builds our NLP
in { # 🦆 says ⮞ YOOOOOOOOOOOOOOOOOO    
  yo.scripts = { # 🦆 says ⮞ quack quack quack quack quack.... qwack      
    # 🦆 says ⮞ automatic doin' sentencin' testin'
    tests = { # 🦆 says ⮞ just run yo tests to do an extensive automated test based on your defined sentence data 
      description = "Extensive automated sentence testing for the NLP"; 
      category = "⚙️ Configuration";
      autoStart = false;
      logLevel = "INFO";
      parameters = [
        { name = "input"; description = "Text to test as a single  sentence test"; optional = true; }
        { name = "stats"; type = "bool"; description = "Flag to display voice commands information like generated regex patterns, generated phrases and ratio"; optional = true; }    
      ];
      helpFooter = ''
        nix eval --raw /home/pungkula/dotfiles#nixosConfigurations.desktop.config.yo.scripts --apply '
          s:
          let
            scripts = builtins.attrValues (builtins.mapAttrs (n: v: v // { name = n; }) s);
            categorize = builtins.map (x:
              let
                patterns = x.voicePatterns or 0;
                phrases = x.voicePhrases or 0;
                ratio = if patterns == 0 then 0 else builtins.floor (phrases / patterns);
                status =
                  if patterns == 0 then "EMPTY"
                  else if phrases == 0 || (patterns > 0 && phrases / patterns < 0.5) then "NEEDS PHRASES"
                  else if ratio > 50 then "HIGH RATIO"
                  else "OK";
                priorityStr = toString (x.voice.priority or "-");
              in
                { name = x.name; status = status; phrases = phrases; patterns = patterns; ratio = ratio; priority = priorityStr; }
            ) scripts;
     
            attention = builtins.filter (x: x.name == "house" && x.status == "HIGH RATIO") categorize;
            needsPhrases = builtins.filter (x: x.status == "NEEDS PHRASES") categorize;
            sortedNeeds = builtins.sort (a: b: a.phrases <= b.phrases) needsPhrases;
        
            formatAttention = builtins.map (x:
              "# Attention!\n⚠️\nThe \"" + x.name + "\" script has a very high phrase-to-pattern ratio (" + toString x.ratio + ") with " + toString x.patterns + " patterns, priority " + x.priority + ". Double-check the voice configuration!"
            ) attention;
        
            formatNeeds = builtins.map (x:
              "- " + x.name + ": only " + toString x.phrases + " phrases across " + toString x.patterns + " patterns."
            ) sortedNeeds;
          in
            builtins.concatStringsSep "\n\n" (formatAttention ++ ["Scripts needing more phrases:"] ++ formatNeeds)
        '
        echo && echo
        echo "The key to remember when configuring a scripts voice definition is that a high pattern value decreases pattern matching performance in terms of speed, while increasing accuracy."
        echo "Recommended approach if you need a high pattern value is to counter decreased speed with a low priority value (5)."
        echo "This will make the scripts pattern matching go last, meaning an increased amount of patterns less important as long as an exact match is found."         
      '';
      code = ''    
        set +u  
        ${cmdHelpers}
        intent_data_file="${intentDataFile}" # 🦆 says ⮞ cache dat JSON wisdom, duck hates slowridez
        intent_base_path="${intentBasePath}" # 🦆 says ⮞ use da prebuilt path yo
        config_json=$(nix eval "$intent_base_path.$script" --json)
        passed_positive=0
        total_positive=0
        passed_negative=0
        total_negative=0
        passed_boundary=0
        failures=()     
        
        display_stats() {
          nix eval --raw ${config.this.user.me.dotfilesDir}#nixosConfigurations.${config.this.host.hostname}.config.yo.scripts --apply '
            s:
            let
              scripts =
                builtins.attrValues (builtins.mapAttrs (n: v: v // { name = n; }) s);
              withRatios =
                builtins.map
                  (x:
                    let
                      patterns = x.voicePatterns or 0;
                      phrases = x.voicePhrases or 0;
                      ratio = if patterns == 0 then 0.0 else (phrases / patterns);
                    in
                      x // { inherit patterns phrases ratio; }
                  )
                  scripts;
              sorted =
                builtins.sort (a: b: b.ratio < a.ratio) withRatios;
              formatNumber = n: toString (builtins.fromJSON (builtins.toJSON n));
            in
              builtins.concatStringsSep "\n"
                (map (x:
                  let
                    p = toString x.patterns;
                    ph = toString x.phrases;
                    r = if x.patterns == 0 then "∞" else formatNumber x.ratio;
                  in "''${x.name}: patterns=''${p}, phrases=''${ph}, ratio=''${r}"
                ) sorted)
          '
        }
        
        resolve_sentence() {
          local script="$1"
          config_json=$(nix eval "$intent_base_path.$script" --json 2>/dev/null)
          [ -z "$config_json" ] && config_json="{}"          
          local sentence="$2"    
          dt_debug "Raw config for $script: $(echo "$config_json" | jq -c . 2>/dev/null || echo "invalid JSON")"
          local parameters # 🦆 says ⮞ first replace parameters to avoid conflictz wit regex processin' yo
          parameters=($(grep -oP '{\K[^}]+' <<< "$sentence"))          
          for param in "''${parameters[@]}"; do
            dt_debug "Processing parameter: $param"
            list_exists=$(echo "$config_json" | jq -r --arg param "$param" '.voice.lists | has($param)')
            dt_debug "List $param exists: $list_exists"
            is_wildcard=$(jq -r --arg param "$param" '.voice.lists[$param].wildcard // "false"' <<< "$config_json" 2>/dev/null)
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
              mapfile -t outs < <(jq -r --arg param "$param" '.voice.lists[$param].values[].out' <<< "$config_json" 2>/dev/null)
              dt_debug "Found ''${#outs[@]} values for $param: ''${outs[*]}"
      
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
        if [[ "$stats" == "true" ]]; then
          display_stats
          exit 1
        fi
        if [[ -n "$input" ]]; then
            echo "[🦆📜] Testing single input: '$input'"
            FUZZY_THRESHOLD=15
            YO_FUZZY_INDEX="${fuzzyIndexFile}"
            priorityList="${toString (lib.concatStringsSep " " processingOrder)}"
            scripts_ordered_by_priority=($priorityList)
            ${lib.concatMapStrings (name: makePatternMatcher name) scriptNamesWithIntents}
            ${lib.concatMapStrings (name: makeFuzzyPatternMatcher name) scriptNamesWithIntents}
            for f in "$MATCHER_DIR"/*.sh; do [[ -f "$f" ]] && source "$f"; done
            find_best_fuzzy_match() {
              local input="$1"
              local best_score=0
              local best_match=""
              local normalized=$(echo "$input" | tr '[:upper:]' '[:lower:]' | tr -d '[:punct:]')
              local candidates
              mapfile -t candidates < <(jq -r '.[] | .[] | "\(.script):\(.sentence)"' "$YO_FUZZY_INDEX")
              dt_debug "Found ''${#candidates[@]} candidates for fuzzy matching"
              for candidate in "''${candidates[@]}"; do
                IFS=':' read -r script sentence <<< "$candidate"
                local norm_sentence=$(echo "$sentence" | tr '[:upper:]' '[:lower:]' | tr -d '[:punct:]')
                local tri_score=$(trigram_similarity "$normalized" "$norm_sentence")
                (( tri_score < 30 )) && continue
                local score=$(levenshtein_similarity "$normalized" "$norm_sentence")  
                if (( score > best_score )); then
                  best_score=$score
                  best_match="$script:$sentence"
                  dt_info "New best match: $best_match ($score%)"
                fi
              done
              if [[ -n "$best_match" ]]; then
                echo "$best_match|$best_score"
              else
                echo ""
              fi
            }
            test_single_input() {
                local input="$1"
                dt_info "Testing input: '$input'"
                for script in "''${scripts_ordered_by_priority[@]}"; do
                    resolved_output=$(resolve_entities "$script" "$input")
                    resolved_text=$(echo "$resolved_output" | cut -d'|' -f1)
                    dt_debug "Trying exact match: $script '$resolved_text'" 
                    if match_$script "$resolved_text"; then
                        dt_info "✅ EXACT MATCH: $script"
                        dt_info "Parameters:"
                        for arg in "''${cmd_args[@]}"; do
                            dt_info "  - $arg"
                        done
                        return 0
                    fi
                done
                dt_info "No exact match found. Attempting fuzzy match..."
                fuzzy_result=$(find_best_fuzzy_match "$input")
                if [[ -z "$fuzzy_result" ]]; then
                    dt_info "❌ No fuzzy candidates found"
                    return 1
                fi  
                IFS='|' read -r combined match_score <<< "$fuzzy_result"
                IFS=':' read -r matched_script matched_sentence <<< "$combined"
                dt_info "Best fuzzy candidate: $matched_script (score: $match_score%)"
                dt_info "Matched sentence: '$matched_sentence'"
                resolved_output=$(resolve_entities "$matched_script" "$input")
                resolved_text=$(echo "$resolved_output" | cut -d'|' -f1)
                if match_fuzzy_$matched_script "$resolved_text" "$matched_sentence"; then
                    dt_info "✅ FUZZY MATCH ACCEPTED: $matched_script"
                    dt_info "Parameters:"
                    for arg in "''${cmd_args[@]}"; do
                        dt_info "  - $arg"
                    done
                    return 0
                else
                    dt_info "❌ Fuzzy match rejected (parameter resolution failed)"
                    return 1
                fi
            }
            test_single_input "$input"
            exit $?
        fi
    
        # 🦆 says ⮞ insert matchers
        ${lib.concatMapStrings (name: makePatternMatcher name) scriptNamesWithIntents}  
        test_positive_cases() {
          for script in ${toString scriptNamesWithIntents}; do
            echo "[🦆📜] Testing script: $script"
            dt_debug "intent_base_path=$intent_base_path" && dt_debug "nix eval path=$intent_base_path.$script"
            config_json=$(nix eval "$intent_base_path.$script" --json 2>/dev/null || echo "{}")
            dt_debug "config_json=$(echo "$config_json" | jq length 2>/dev/null)" && dt_debug "config_json keys=$(echo "$config_json" | jq 'keys' 2>/dev/null)"

            mapfile -t raw_sentences < <(jq -r ".\"$script\".sentences[]?" "$intent_data_file" 2>/dev/null)

            dt_debug "found ''${#raw_sentences[@]} sentences for $script"
            for template in "''${raw_sentences[@]}"; do
              test_sentence=$(resolve_sentence "$script" "$template")
              echo " Testing: $test_sentence"
              resolved_output=$(resolve_entities "$script" "$test_sentence")
              resolved_text=$(echo "$resolved_output" | cut -d'|' -f1)
              subs_decl=$(echo "$resolved_output" | cut -d'|' -f2-)
              declare -gA substitutions || true
              eval "$subs_decl" >/dev/null 2>&1 || true
              if match_$script "$resolved_text"; then
                say_duck "yay ✅ PASS: $resolved_text"
                ((passed_positive++))
              else
                say_duck "fuck ❌ FAIL: $resolved_text"
                failures+=("POSITIVE: $script | $resolved_text")
              fi
              ((total_positive++))
            done
          done
        }
        test_negative_cases() {
          echo "[🦆🚫] Testing Negative Cases"
          negative_cases=(
            "make me a sandwich"
            "launch the nuclear torpedos!"
            "gör mig en macka"
            "avfyra kärnvapnen!"
            "ducks sure are the best dont you agree"
          )        
          for neg_case in "''${negative_cases[@]}"; do
            echo " Testing: $neg_case"
            matched=false
            for script in ${toString scriptNamesWithIntents}; do
              resolved_output=$(resolve_entities "$script" "$neg_case")
              resolved_neg=$(echo "$resolved_output" | cut -d'|' -f1)     
              if match_$script "$resolved_neg"; then
                say_duck "fuck ❌ FALSE POSITIVE: $resolved_neg (matched by $script)"
                failures+=("NEGATIVE: $script | $resolved_neg")
                matched=true
                break
              fi
            done       
            if ! $matched; then
              say_duck "yay ✅ [NEG] PASS: $resolved_neg"
              ((passed_negative++))
            fi
            ((total_negative++))
          done
        }
        test_boundary_cases() {
          echo "[🦆🔲] Testing Boundary Cases"
          boundary_cases=("" "   " "." "!@#$%^&*()")  
          for bcase in "''${boundary_cases[@]}"; do
            printf " Testing: '%s'\n" "$bcase"
            matched=false   
            for script in ${toString scriptNamesWithIntents}; do
              if match_$script "$bcase"; then
                say_duck "fuck ❌ BOUNDARY FAIL: '$bcase' (matched by $script)"
                failures+=("BOUNDARY: $script | '$bcase'")
                matched=true
                break
              fi
            done       
            if ! $matched; then
              say_duck "yay ✅ [BND] PASS: '$bcase'"
              ((passed_boundary++))
            fi
          done
          total_boundary=''${#boundary_cases[@]}
        }  
        test_positive_cases
        test_negative_cases
        test_boundary_cases
        
        # 🦆 says ⮞ calculate
        total_tests=$((total_positive + total_negative + total_boundary))
        passed_tests=$((passed_positive + passed_negative + passed_boundary))
        percent=$(( 100 * passed_tests / total_tests ))
        
        # 🦆 says ⮞ colorize based on percentage
        if [ "$percent" -ge 80 ]; then 
            color="$GREEN" && duck_report="⭐"
        elif [ "$percent" -ge 60 ]; then 
            color="$YELLOW" && duck_report="🟢"
        else 
            color="$RED" && duck_report="😭"
        fi
        
        # 🦆 says ⮞ display failed tests report
        if [ "$passed_tests" -ne "$total_tests" ]; then 
            if [ ''${#failures[@]} -gt 0 ]; then
                echo "" && echo -e "''${RED}## ────── FAILURES ──────##''${RESET}"
                for failure in "''${failures[@]}"; do
                    echo -e "''${RED}## ❌ $failure"
                done
                echo -e "''${RED}## ────── FAILURES ──────##''${RESET}"
            fi
        fi
        
        # 🦆 says ⮞ display final report
        echo "" && echo -e "''${color}"## ──────⋆⋅☆⋅⋆────── ##''${RESET}"
        bold "Testing completed!" 
        say_duck "Positive: $passed_positive/$total_positive"
        say_duck "Negative: $passed_negative/$total_negative"
        say_duck "Boundary: $passed_boundary/$total_boundary"
        say_duck "TOTAL: $passed_tests/$total_tests (''${color}''${percent}%''${GRAY})"
        echo "''${RESET}" && echo -e "''${color}## ──────⋆⋅☆⋅⋆────── ##''${RESET}"
        say_duck "$duck_report"
        dt_info "Test completed with results: $passed_tests/$total_tests ''${percent}%"
        exit 1
      ''; # 🦆 says ⮞ thnx for quackin' along til da end!
      voice = {
        enabled = true;
        priority = 5;
        sentences = [
          "testa mina meningar"
          "kör röst test[et|erna]"
          "testa röst[ styrningen]"
        ];     
      }; # 🦆 says ⮞ the duck be stateless, the regex be law, and da shell... is my pond.
    };  # 🦆 say ⮞ nobody beat diz nlp nao says sir quack a lot NOBODY I SAY!
  };} # 🦆 says ⮞ QuackHack-McBLindy out!  
