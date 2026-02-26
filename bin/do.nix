# dotfiles/bin/voice/do.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ Quack Powered natural language processing engine written in Nix & Rust - translates text to Shell commands
  self,
  lib,
  config,
  pkgs,
  sysHosts,
  cmdHelpers,
  RustDuckTrace,
  ...
} : let
  cfg = config.yo;
  # 🦆 says ⮞ Statistical logging for failed commands
  statsDir = "/home/${config.this.user.me.name}/.local/share/yo/stats";
  failedCommandsLog = "${statsDir}/failed_commands.log";
  commandStatsDB = "${statsDir}/command_stats.json";
  
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
  ) (builtins.attrNames scriptsWithVoice); # 🦆 says ⮞ datz quackin' cool huh?!

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
  ) (lib.mapAttrs (name: script: {
    priority = script.voice.priority or 3;
    data = [{
      inherit (script.voice) sentences lists;
    }];
  }) scriptsWithFuzzy));

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
# 🦆 EXAMPLE ⮞ cartesianProductOfLists [ ["a" "b"] ["1" "2"] ["x" "y"] ]
# 🦆 BOOOOOM ⮟ 
#  [ ["a" "1" "x"]
#    ["a" "1" "y"] 
#    ["a" "2" "x"]
#    ["a" "2" "y"]
#    ["b" "1" "x"]
#    ["b" "1" "y"]
#    ["b" "2" "x"]
#    ["b" "2" "y"] ]
         
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

  # 🦆 says ⮞ oh duck... dis is where speed goes steroids yo iz diz cachin'?
  intentDataFile = pkgs.writeText "intent-entity-map4.json"
    (builtins.toJSON (
      lib.mapAttrs (_scriptName: intentList:
        let
          allData = lib.flatten (map (d: d.lists or {}) intentList.data);
          # 🦆 says ⮞ collect all sentences for diz intent
          sentences = lib.concatMap (d: d.sentences or []) intentList.data;      
          # 🦆 says ⮞ expand all sentence variants
          expandedSentences = lib.unique (lib.concatMap expandOptionalWords sentences);
          # 🦆 says ⮞ "in" > "out" for dem' subz 
          substitutions = lib.flatten (map (lists: 
            lib.flatten (lib.mapAttrsToList (_listName: listData: 
              if listData ? values then
                lib.flatten (map (item: 
                  let
                    rawIn = item."in";
                    value = item.out;
                    cleaned = lib.removePrefix "[" (lib.removeSuffix "]" rawIn);
                    variants = lib.splitString "|" cleaned;     
                  in map (v: let
                    cleanV = lib.replaceStrings ["  "] [" "] (lib.strings.trim v);
                  in {   
                    pattern = if builtins.match ".* .*" cleanV != null
                              then cleanV
                              else "(${cleanV})";
                    value = value;
                  }) variants
                ) listData.values)
              else []
            ) lists)
          ) allData);
          # 🦆 says ⮞ CRITICAL: Include the lists data for wildcard detection
          lists = lib.foldl (acc: d: acc // (d.lists or {})) {} intentList.data;
        in {
          inherit substitutions;
          inherit sentences;
          inherit lists;
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

  # 🦆 says ⮞ fuzzy index only for allowed yo scriptz dat allow dem fuzzy matchin' yo
  scriptsWithFuzzy = lib.filterAttrs (_: script: 
    script.voice != null && 
    (script.voice.enabled or true) &&
    (script.voice.fuzzy.enable or true)  # 🦆 Must explicitly allow fuzzy
  ) config.yo.scripts;

  splitWordsFile = pkgs.writeText "split-words.json" (builtins.toJSON config.yo.SplitWords);
  sorryPhrasesFile = pkgs.writeText "sorry-phrases.json" (builtins.toJSON config.yo.sorryPhrases);
  fuzzyIndexFile = pkgs.writeText "fuzzy-index.json" (builtins.toJSON fuzzyIndex);
  fuzzyIndexFlatFile = pkgs.writeText "fuzzy-rust-index.json" (builtins.toJSON fuzzyFlatIndex);  
  matcherDir = pkgs.linkFarm "yo-matchers" (
    map (m: { name = "${m.name}.sh"; path = m.value; }) matchers
  ); 


  # 🦆 says ⮞ export da nix store path to da intent data - could be useful yo
  environment.variables = {
    "YO_SPLIT_WORDS" = splitWordsFile;
    "YO_SORRY_PHRASES" = sorryPhrasesFile;
    "YO_INTENT_DATA" = intentDataFile;
    "ỲO_FUZZY_INDEX" = fuzzyIndexFile;  
    "MATCHER_DIR" = matcherDir;
    "MATCHER_SOURCE" = matcherSourceScript;
  };
  

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
    # 🦆 says ⮞ GO RUST DO I CHOOSE u!!1
    do = {
      description = "Brain (do) is a Natural Language to Shell script translator that generates dynamic regex patterns at build time for defined yo.script sentences. It runs exact and fuzzy pattern matching at runtime with automatic parameter resolution and seamless shell script execution";
      category = "🗣️ Voice"; # 🦆 says ⮞ duckgorize iz zmart wen u hab many scriptz i'd say!     
      aliases = [ "brain" ];
      autoStart = false;
      logLevel = "INFO";
      helpFooter = ''
        echo "[🦆🧠]"
        cat ${voiceSentencesHelpFile} 
      '';
      parameters = [ # 🦆 says ⮞ set your mosquitto user & password
        { name = "input"; description = "Text to translate"; optional = true; } 
        { name = "fuzzy"; type = "int"; description = "Minimum procentage for considering fuzzy matching sucessful. (1-100)"; default = 60; }
      ];
      code = ''
        set +u  
        ${cmdHelpers} # 🦆 says ⮞load required bash helper functions 
        FUZZY_THRESHOLD=$fuzzy
        YO_SPLIT_WORDS="${splitWordsFile}"
        YO_SORRY_PHRASES="${sorryPhrasesFile}"
        YO_FUZZY_INDEX="${fuzzyIndexFlatFile}"
        text="$input"
        INTENT_FILE="${intentDataFile}"
        
        # 🦆 says ⮞ create da stats dirz etc
        mkdir -p "${statsDir}"
        touch "${failedCommandsLog}"
        if [ ! -f "${commandStatsDB}" ]; then
          echo '{"failed_commands": {}, "successful_commands": {}, "fuzzy_matches": {}}' > "${commandStatsDB}"
        fi
        
          
 
        # 🦆 says ⮞ check yo.scripts.do if DEBUG mode yo
        if [ "$VERBOSE" -ge 1 ]; then
          DEBUG=1 YO_SPLIT_WORDS="${splitWordsFile}" YO_SORRY_PHRASES="${sorryPhrasesFile}" YO_INTENT_DATA="$INTENT_FILE" YO_FUZZY_INDEX="$YO_FUZZY_INDEX" yo-do "$input" $FUZZY_THRESHOLD
        else
          YO_SPLIT_WORDS="${splitWordsFile}" YO_SORRY_PHRASES="${sorryPhrasesFile}" YO_INTENT_DATA="$INTENT_FILE" YO_FUZZY_INDEX="$YO_FUZZY_INDEX" yo-do "$input" $FUZZY_THRESHOLD
        fi



      '';
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
