# dotfiles/bin/config/do-bash.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ Quack Powered natural language processing engine written in Nix & Bash - translates text to Shell commands
  self,
  lib,
  config,
  pkgs,
  sysHosts,
  cmdHelpers,
  ...
} : let
  cfg = config.yo;
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
#      builtins.hasAttr scriptName generatedIntents && hasSentences
#  ) scriptNames; # 🦆 says ⮞ datz quackin' cool huh?!
      builtins.hasAttr scriptName generatedIntents && hasSentences
  ) (builtins.attrNames scriptsWithVoice);

#  scriptsWithVoice = lib.filterAttrs (_: script: script.voice != null) config.yo.scripts;
  # 🦆 says ⮞ only scripts with voice enabled and non-null voice config
  scriptsWithVoice = lib.filterAttrs (_: script: 
    script.voice != null && (script.voice.enabled or true)
  ) config.yo.scripts;  
  
  # 🦆 says ⮞ generate intents
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
                regexGroup = if isWildcard then "(.*)" else "\\b([^ ]+)\\b"; # 82%
                # regexGroup = if isWildcard then "(.*)" else "([^ ]+)";
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

  # 🦆 says ⮞ 4 rust version of da nlp 
  fuzzyFlatIndex = lib.flatten (lib.mapAttrsToList (scriptName: intent:
    lib.concatMap (data:
      lib.concatMap (sentence:
        map (expanded: {
          script = scriptName;
          sentence = expanded;
          signature = let
            words = lib.splitString " " (lib.toLower expanded);
            sorted = lib.sort (a: b: a < b) words;
          in builtins.concatStringsSep "|" sorted;
        }) (expandOptionalWords sentence)
      ) data.sentences
    ) intent.data
  ) generatedIntents);

  fuzzyIndexFile = pkgs.writeText "fuzzy-index.json" (builtins.toJSON fuzzyIndex);
  fuzzyIndexFlatFile = pkgs.writeText "fuzzy-rust-index.json" (builtins.toJSON fuzzyFlatIndex);  
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
  # 🦆 says ⮞ generate optimized processing order
  processingOrder = map (r: r.name) scriptRecordsWithIntents;

  # 🦆 duck say ⮞ quacky hacky helper 2 escape md special charizardz yo
  escapeMD = str: let
    replacements = [
      [ "\\" "\\\\" ]
      [ "*" "\\*" ]
      [ "`" "\\`" ]
      [ "_" "\\_" ]
      [ "[" "\\[" ]
      [ "]" "\\]" ]
    ];
  in
    lib.foldl (acc: r: lib.replaceStrings [ (builtins.elemAt r 0) ] [ (builtins.elemAt r 1) ] acc) str replacements;
 
  # 🦆 says ⮞ conflict detection - no bad voice intentz quack!  
  assertionCheckForConflictingSentences = let
    # 🦆 says ⮞ collect all expanded sentences with their script originz
    allExpandedSentences = lib.flatten (lib.mapAttrsToList (scriptName: intent:
      lib.concatMap (data:
        lib.concatMap (sentence:
          map (expanded: {
            inherit scriptName;
            sentence = expanded;
            original = sentence;
            # 🦆 says ⮞ extract parameter positionz & count da fixed words
            hasWildcardAtEnd = lib.hasSuffix " {search}" (lib.toLower expanded) || 
                              lib.hasSuffix " {param}" (lib.toLower expanded) ||
                              (lib.hasInfix " {" expanded && 
                               !(lib.hasInfix "} " expanded)); # 🦆 says ⮞ wildcard at end if no } followed by space
            fixedWordCount = let
              words = lib.splitString " " expanded;
              nonParamWords = lib.filter (word: 
                !(lib.hasPrefix "{" word) && !(lib.hasSuffix "}" word)
              ) words;
            in lib.length nonParamWords;
          }) (expandOptionalWords sentence)
        ) data.sentences
      ) intent.data
    ) generatedIntents);
    # 🦆 says ⮞ check for prefix conflictz
    checkPrefixConflicts = sentences:
      let
        sortedSentences = lib.sort (a: b: 
          lib.stringLength a.sentence < lib.stringLength b.sentence
        ) sentences;
        conflicts = lib.foldl (acc: shorterItem:
          let
            shorter = shorterItem.sentence;
            shorterScript = shorterItem.scriptName;
            shorterHasWildcard = shorterItem.hasWildcardAtEnd;
          in
            acc ++ (lib.foldl (innerAcc: longerItem:
              let
                longer = longerItem.sentence;
                longerScript = longerItem.scriptName;
              in
                if shorterScript != longerScript then
                  if lib.hasPrefix (shorter + " ") longer && shorterHasWildcard then
                    innerAcc ++ [{
                      type = "PREFIX_CONFLICT";
                      shorter = shorter;
                      longer = longer;
                      scripts = [shorterScript longerScript];
                      reason = "Shorter pattern '${shorter}' (ends with wildcard) is a prefix of '${longer}'";
                    }]
                  else
                    innerAcc
                else
                  innerAcc
            ) [] sortedSentences)
        ) [] sortedSentences;
      in
        conflicts;
    # 🦆 says ⮞ find prefix conflictz!
    sentencesByText = lib.groupBy (item: item.sentence) allExpandedSentences;
    exactConflicts = lib.filterAttrs (sentence: items:
      let 
        uniqueScripts = lib.unique (map (item: item.scriptName) items);
      in 
        lib.length uniqueScripts > 1
    ) sentencesByText; 
    # 🦆 says ⮞ find duplicatez!
    exactConflictList = lib.mapAttrsToList (sentence: items:
      let
        scripts = lib.unique (map (item: item.scriptName) items);
      in { # 🦆  says ⮞ format exact conflictz dawg
        type = "EXACT_CONFLICT";
        sentence = sentence;
        scripts = scripts;
        reason = "Exact pattern match in scripts: ${lib.concatStringsSep ", " scripts}";
      }
    ) exactConflicts;   
    # 🦆  says ⮞ find prefix conflictz
    prefixConflicts = checkPrefixConflicts allExpandedSentences;    
    # 🦆  says ⮞ letz put dem conflictz together okay?
    allConflicts = exactConflictList ++ prefixConflicts;
    hasConflicts = allConflicts != [];    
    # 🦆  says ⮞ find da prefix conflictz  
  in {
    assertion = !hasConflicts;
    message = 
      if hasConflicts then
        let
          conflictMsgs = map (conflict:
            if conflict.type == "EXACT_CONFLICT" then
              ''
              🦆 says ⮞ CONFLICT! 
                Pattern "${conflict.sentence}"
                In scripts: ${lib.concatStringsSep ", " conflict.scripts}
              ''
            else if conflict.type == "PREFIX_CONFLICT" then
              ''
              🦆 says ⮞ CONFLICT!
                Shorter: "${conflict.shorter}" (ends with wildcard)
                Longer:  "${conflict.longer}"
                Scripts: ${lib.concatStringsSep ", " conflict.scripts}
                Reason:  ${conflict.reason}
              ''
            else
              ""
          ) allConflicts;
        in
          "Sentence conflicts detected in voice definition:\n\n" +
          lib.concatStringsSep "\n" conflictMsgs +
          "\n\n🦆 says ⮞ fix da conflicts before rebuildin' yo!"
      else
        "No sentence conflicts found.";
  };

  # 🦆 says ⮞ category based helper with actual names instead of {param}
  voiceSentencesHelpFile = pkgs.writeText "voice-sentences-help.md" (
    let
      scriptsWithVoice = lib.filterAttrs (_: script: 
        script.voice != null && script.voice.sentences != [] && (script.voice.enabled or true)
      ) config.yo.scripts;
      
      # 🦆 says ⮞ replace {param} with actual values from voice lists
      replaceParamsWithValues = sentence: voiceData:
        let
          # 🦆 says ⮞ find all {param} placeholders in the sentence
          paramMatches = builtins.match ".*(\\{([^}]+)\\}).*" sentence;
          processToken = token:
            if lib.hasPrefix "{" token && lib.hasSuffix "}" token then
              let
                paramName = lib.removePrefix "{" (lib.removeSuffix "}" token);
                listData = voiceData.lists.${paramName} or null;
              in
                if listData != null then
                  if listData.wildcard or false then
                    "ANYTHING"
                  else
                    let
                      # 🦆 says ⮞ get all possible input values
                      values = map (v: v."in") listData.values;
                      # 🦆 says ⮞ expand any optional patterns like [foo|bar]
                      expandedValues = lib.concatMap expandListInputVariants values;
                      # 🦆 says ⮞ take first few examples for display
                      examples = lib.take 3 (lib.unique expandedValues);
                    in
                      if examples == [] then "ANYTHING"
                      else "(" + lib.concatStringsSep "|" examples + 
                           (if lib.length examples < lib.length expandedValues then "|...)" else ")")
                else
                  "ANYTHING" # 🦆 says ⮞ fallback if param not found
            else
              token;
          
          # 🦆 says ⮞ split sentence and process each token
          tokens = lib.splitString " " sentence;
          processedTokens = map processToken tokens;
        in
          lib.concatStringsSep " " processedTokens;
      
      # 🦆 says ⮞ group by category
      groupedScripts = lib.groupBy (script: script.category or "🧩 Miscellaneous") 
        (lib.attrValues scriptsWithVoice);
      
      # 🦆 says ⮞ generate category sections with param replacement
      categorySections = lib.mapAttrsToList (category: scripts:
        let
          scriptLines = map (script:
            let
              # 🦆 says ⮞ replace params in each sentence
              sentenceLines = lib.concatMapStrings (sentence: 
                let processedSentence = replaceParamsWithValues sentence script.voice;
                in "    - \"${escapeMD processedSentence}\"\n"
              ) script.voice.sentences;
            in
              "  **${escapeMD script.name}**:\n${sentenceLines}"
          ) (lib.sort (a: b: a.name < b.name) scripts);
        in
          "# ${category}\n\n${lib.concatStringsSep "\n" scriptLines}"
      ) groupedScripts;
      
      # 🦆 says ⮞ statistics
      totalScripts = lib.length (lib.attrNames config.yo.scripts);
      voiceScripts = lib.length (lib.attrNames scriptsWithVoice);
      totalPatterns = config.yo.generatedPatterns;
      totalPhrases = config.yo.understandsPhrases;    
      stats = ''  
  # ----────----──⋆⋅☆☆☆⋅⋆─────----─ #
  # Total:  
  - **Scripts with voice enabled**: ${toString voiceScripts} / ${toString totalScripts}
  - **Generated patterns**: ${toString totalPatterns}
  - **Understandable phrases**: ${toString totalPhrases}
      '';
    in
      "# 🦆 Voice Commands\nÅ\n\n${lib.concatStringsSep "\n\n" categorySections}\n\n${stats}"
  );

  # 🦆 duck say ⮞ constructs GitHub "blob" URL based on `config.this.user.me.repo` 
  githubBaseUrl = let # 🦆 duck say ⮞ pattern match to extract username and repo name
    matches = builtins.match ".*github.com[:/]([^/]+)/([^/\\.]+).*" config.this.user.me.repo;
  in if matches != null then # 🦆 duck say ⮞ if match - construct
    "https://github.com/${builtins.elemAt matches 0}/${builtins.elemAt matches 1}/blob/main"
  else ""; # 🦆 duck say ⮞ no match? empty string

# 🦆 says ⮞ expose da magic! dis builds da NLP
in { # 🦆 says ⮞ YOOOOOOOOOOOOOOOOOO    
  yo.scripts = { # 🦆 says ⮞ quack quack quack quack quack.... qwack 
    do-bash = { # 🦆 says ⮞ wat? BASH?! quack - just bcause duck can! crazy huh?! 
      description = "Natural language to Shell script translator with dynamic regex matching and automatic parameter resolutiion. (Bash version)";
      category = "🗣️ Voice"; # 🦆 says ⮞ duckgorize iz zmart wen u hab many scriptz i'd say!
      logLevel = "INFO";
      autoStart = false;
      parameters = [
        { name = "input"; description = "Text to parse into a yo command"; optional = false; }
        { name = "fuzzyThreshold"; type = "int"; description = "Minimum procentage for considering fuzzy matching sucessful. (1-100)"; default = 15; }
      ]; 
      helpFooter = ''
        cat ${voiceSentencesHelpFile} 
      '';
      code = ''
        set +u  
        ${cmdHelpers} # 🦆 says ⮞load required bash helper functions 
        FUZZY_THRESHOLD=$fuzzyThreshold
        intent_data_file="${intentDataFile}" # 🦆 says ⮞ cache dat JSON wisdom, duck hates slowridez
        YO_FUZZY_INDEX="${fuzzyIndexFile}" # for fuzzy nutty duckz
        text="$input" # 🦆 says ⮞ for once - i'm lettin' u doin' da talkin'
        match_result_flag=$(mktemp)
        trap 'rm -f "$match_result_flag"' EXIT
        echo "waiting" > "$match_result_flag"
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
          echo $(( 100 * 2 * matches / total ))  # 🦆 says ⮞ 0-100 scale
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
        
        for f in "$MATCHER_DIR"/*.sh; do [[ -f "$f" ]] && source "$f"; done
        scripts_ordered_by_priority=( ${lib.concatMapStringsSep "\n" (name: "  \"${name}\"") processingOrder} )
        dt_info "$scripts_ordered_by_priority"
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
           
        # 🦆 says ⮞ insert matchers, build da regex empire. yo
#        ${lib.concatMapStrings (name: makePatternMatcher name) scriptNamesWithIntents}  
        # 🦆 says ⮞ for dem scripts u defined intents for ..
        exact_match_handler() {        
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
              paramz="''${args[@]}" && echo
              echo "exact" > "$match_result_flag" # 🦆 says ⮞ tellz fuzzy handler we done
              
              echo "   ┌─(yo-$script)"
              echo "   │🦆"
              if [ ''${#args[@]} -eq 0 ]; then
                echo "   └─🦆 says ⮞ no parameters yo"
              else
                for ((i=0; i<''${#args[@]}; i+=2)); do
                  if [ $i -eq 0 ]; then
                    echo -n "   └─⮞ "
                  else
                    echo -n "   └─⮞ "
                  fi
                  echo -n "''${args[$i]}"
                  if [ $((i+1)) -lt ''${#args[@]} ]; then
                    echo " ''${args[$((i+1))]}"
                  else
                    echo
                  fi
                done
              fi
              dt_debug "Executing: yo $script $paramz" 
              # 🦆 says ⮞ EXECUTEEEEEEEAAA  – HERE WE QUAAAAACKAAAOAA
              exec "yo-$script" "''${args[@]}"   
              # kill -9 $$  # 🦆 says ⮞ kill the entire script process
              return 0
            fi         
          done
          # 🦆 says ⮞ tell fuzzy no exact match found
          dt_info "Exact: No exact match found"
          echo "exact_finished" > "$match_result_flag"
        }        

        ${lib.concatMapStrings (name: makeFuzzyPatternMatcher name) scriptNamesWithIntents}  
        # 🦆 SCREAMS ⮞ FUZZY WOOOO TO THE MOON                
        fuzzy_match_handler() {
          resolved_output=$(resolve_entities "dummy" "$text") # 🦆 says ⮞ We'll resolve 4real after matchin'
          resolved_text=$(echo "$resolved_output" | cut -d'|' -f1)
          fuzzy_result=$(find_best_fuzzy_match "$resolved_text")
          [[ -z "$fuzzy_result" ]] && return 1

          IFS='|' read -r combined match_score <<< "$fuzzy_result"
          IFS=':' read -r matched_script matched_sentence <<< "$combined"
          if (( match_score < FUZZY_THRESHOLD )); then
            dt_debug "Fuzzy match score $match_score below threshold $FUZZY_THRESHOLD, skipping."
            return 1
          fi
          dt_debug "Best fuzzy script: $matched_script (score: $match_score%)"

          # 🦆 says ⮞ resolve entities agein, diz time for matched script yo
          resolved_output=$(resolve_entities "$matched_script" "$text")
          resolved_text=$(echo "$resolved_output" | cut -d'|' -f1)
          subs_decl=$(echo "$resolved_output" | cut -d'|' -f2-)
          declare -gA substitutions || true
          eval "$subs_decl" >/dev/null 2>&1 || true

          #if (( best_score >= $FUZZY_THRESHOLD )); then
          # 🦆 says ⮞ we hab a match quacky quacky diz sure iz hacky!
          if match_fuzzy_$matched_script "$resolved_text" "$matched_sentence"; then
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
            # 🦆 says ⮞ wait for exact match to finish
            # while kill -0 "$pid1" 2>/dev/null; do
            dt_debug "Fuzzy handler: Waiting for exact match to finish..."
            while [[ $(cat "$match_result_flag") == "waiting" ]]; do
              dt_debug "Fuzzy: Still waiting for exact match flag... (loop)"
              sleep 0.05
            done
            dt_debug "Fuzzy: Exact match flag found"
            # 🦆 says ⮞ check if exact match already won
            if [[ $(cat "$match_result_flag") == "exact" ]]; then 
              dt_debug "Exact match already handled execution. Fuzzy exiting."             
              exit 0
            fi    
            dt_debug "Fuzzy: Proceeding with fuzzy execution..."
            # 🦆 says ⮞ final product - hope u like say duck!
            paramz="''${args[@]}" && echo
            echo "   ┌─(yo-$matched_script)"
            echo "   │🦆 Fuzzy"
            if [ ''${#args[@]} -eq 0 ]; then
              echo "   └─🦆 says ⮞ no parameters yo"
            else
              for ((i=0; i<''${#args[@]}; i+=2)); do
                if [ $i -eq 0 ]; then
                  echo -n "   └─⮞ "
                else
                  echo -n "   └─⮞ "
                fi
                echo -n "''${args[$i]}"
                if [ $((i+1)) -lt ''${#args[@]} ]; then
                  echo " ''${args[$((i+1))]}"
                else
                  echo
                fi
              done
            fi
            dt_info "Executing: yo $matched_script $paramz" 
            # 🦆 says ⮞ EXECUTEEEEEEEAAA  – HERE WE QUAAAAACKAAAOAA
            exec "yo-$matched_script" "''${args[@]}"
            return 0
          fi
        }        

        # 🦆 says ⮞ if exact match winz, no need for fuzz! but fuzz ready to quack when regex chokes
        exact_match_handler &
        pid1=$!
        fuzzy_match_handler
#        pid1=$!
        # 🦆 says ⮞ if this is reached - we have NO MATCH
        if [[ $(cat "$match_result_flag") == "exact_finished" ]]; then
          say_no_match
        fi
        exit
      ''; # 🦆 says ⮞ thnx for quackin' along til da end!
    };  
  };
  # 🦆 says ⮞ SAFETY FIRST! 
  assertions = [
    {
      assertion = assertionCheckForConflictingSentences.assertion;
      message = assertionCheckForConflictingSentences.message;
    } # 🦆 says ⮞ the duck be stateless, the regex be law, and da shell... is my pond.    
  ];}# 🦆 say ⮞ nobody beat diz nlp nao says sir quack a lot NOBODY I SAY!
# 🦆 says ⮞ QuackHack-McBLindy out!  
