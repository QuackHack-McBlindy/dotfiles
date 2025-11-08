# dotfiles/bin/config/do.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ Quack Powered natural language processing engine written in Nix & Rust - translates text to Shell commands
  self,
  lib,
  config,
  pkgs,
  sysHosts,
  cmdHelpers,
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

  # 🦆 duck say ⮞ u like speed too? Rusty Speed inc
  do-rs = pkgs.writeText "do.rs" ''
    // 🦆 SCREAMS ⮞ 70x FASTER!!🚀
    use std::collections::HashMap;
    use std::env;
    use std::fs;
    use std::process::{Command, exit};
    use regex::Regex;
    use serde::{Deserialize, Serialize};
    use std::time::Instant;
    
    // 🦆 says ⮞ config structs wit da duck wisdom
    #[derive(Debug, Clone, Serialize, Deserialize)]
    struct ScriptConfig {
        description: String,
        aliases: Vec<String>,
        category: String,
        log_level: String,
        auto_start: bool,
        parameters: Vec<Parameter>,
        help_footer: String,
        code: String,
        voice: Option<VoiceConfig>,
    }
    
    #[derive(Debug, Clone, Serialize, Deserialize)]
    struct Parameter {
        name: String,
        description: String,
        optional: bool,
        param_type: Option<String>,
        default: Option<String>,
    }
    
    #[derive(Debug, Clone, Serialize, Deserialize)]
    struct VoiceConfig {
        enabled: bool,
        priority: i32,
        sentences: Vec<String>,
        lists: HashMap<String, ListConfig>,
    }
    
    #[derive(Debug, Clone, Serialize, Deserialize)]
    struct ListConfig {
        wildcard: bool,
        values: Vec<ListValue>,
    }

    // 🦆 says ⮞ entity resolution
    #[derive(Debug, Clone, Serialize, Deserialize)]
    struct EntityValue {
        r#in: String,  // 🦆 says ⮞ "in" is a keyword so we use raw identifier
        out: String,
    }

    #[derive(Debug, Clone, Serialize, Deserialize)] 
    struct EntityList {
        wildcard: Option<bool>,
        values: Vec<EntityValue>,
    }

    #[derive(Debug, Clone, Serialize, Deserialize)]
    struct VoiceData {
        sentences: Vec<String>,
        lists: HashMap<String, EntityList>,
    }
  
    #[derive(Debug, Clone, Serialize, Deserialize)]
    struct ScriptIntentData {
        substitutions: Vec<Substitution>,
        sentences: Vec<String>,
        // 🦆 says ⮞ voice data for entity resolution
        voice_data: Option<HashMap<String, VoiceData>>,
    }  
  
    #[derive(Debug, Clone, Serialize, Deserialize)]
    struct ListValue {
        r#in: String,
        out: String,
    }
    
    #[derive(Debug, Clone, Serialize, Deserialize)]
    struct IntentData {
        substitutions: Vec<Substitution>,
        sentences: Vec<String>,
    }
    
    #[derive(Debug, Clone, Serialize, Deserialize)]
    struct Substitution {
        pattern: String,
        value: String,
    }
 
    #[derive(Debug, Clone, Serialize, Deserialize)]
    struct FuzzyIndexEntry {
        script: String,
        sentence: String,
        signature: String,
    }
    
    // 🦆 says ⮞ script priority for da optimized processing yo
    #[derive(Debug, Clone)]
    struct ScriptPriority {
        name: String,
        priority: i32,
        has_complex_patterns: bool,
    }
    
    // 🦆 says ⮞ MATCH RESULT wit da duck power!
    #[derive(Debug)]
    struct MatchResult {
        script_name: String,
        args: Vec<String>,
        matched_sentence: String,
        processing_time: std::time::Duration,
    }
    
    struct YoDo {
        scripts: HashMap<String, ScriptConfig>,
        intent_data: HashMap<String, IntentData>,
        fuzzy_index: Vec<FuzzyIndexEntry>,
        processing_order: Vec<ScriptPriority>,
        fuzzy_threshold: i32,
        context: ContextData, // 🦆 NEW: Loaded context
        confirmed_patterns: HashMap<String, u32>, 
        debug: bool,        
    }
    
    impl YoDo {
        fn new() -> Self {
            Self {
                scripts: HashMap::new(),
                intent_data: HashMap::new(),
                fuzzy_index: Vec::new(),
                processing_order: Vec::new(),
                fuzzy_threshold: 15,
                debug: env::var("DEBUG").is_ok() || env::var("DT_DEBUG").is_ok(),
            }
        }

        // 🦆 says ⮞ never fail but log failz anywayz
        fn log_failed_command(&self, input: &str, fuzzy_candidates: &[(String, String, i32)]) -> Result<(), Box<dyn std::error::Error>> {
            let stats_dir = std::env::var("HOME").unwrap_or_else(|_| ".".to_string()) + "/.local/share/yo/stats";
            let _ = std::fs::create_dir_all(&stats_dir);
            
            let log_file = format!("{}/failed_commands.log", stats_dir);
            let stats_file = format!("{}/command_stats.json", stats_dir);
            
            // 🦆 says ⮞ log to text file
            let timestamp = chrono::Local::now().format("%Y-%m-%d %H:%M:%S");
            let log_entry = format!("[{}] FAILED: '{}'\n", timestamp, input);
            
            if let Ok(mut file) = std::fs::OpenOptions::new().create(true).append(true).open(&log_file) {
                use std::io::Write;
                let _ = file.write_all(log_entry.as_bytes());
            }
            
            // 🦆 says ⮞ update stats
            let mut stats: serde_json::Value = if let Ok(content) = std::fs::read_to_string(&stats_file) {
                serde_json::from_str(&content).unwrap_or_else(|_| {
                    serde_json::json!({
                        "failed_commands": {},
                        "successful_commands": {},
                        "fuzzy_matches": {}
                    })
                })
            } else {
                serde_json::json!({
                    "failed_commands": {},
                    "successful_commands": {}, 
                    "fuzzy_matches": {}
                })
            };
            
            // 🦆 says ⮞ increment failed command count
            if let Some(failed_commands) = stats.get_mut("failed_commands").and_then(|v| v.as_object_mut()) {
                let count = failed_commands.get(input).and_then(|v| v.as_u64()).unwrap_or(0);
                failed_commands.insert(input.to_string(), serde_json::Value::from(count + 1));
            }
            
            // 🦆 says ⮞ write back updated stats
            if let Ok(content) = serde_json::to_string_pretty(&stats) {
                let _ = std::fs::write(&stats_file, content);
            }
            
            // 🦆 says ⮞ log fuzzy matchin' candidates for analysis
            if !fuzzy_candidates.is_empty() {
                self.quack_debug(&format!("Fuzzy candidates for '{}':", input));
                for (script, sentence, score) in fuzzy_candidates {
                    self.quack_debug(&format!("  {}%: {} -> {}", score, sentence, script));
                }
            }        
            Ok(())
        }

        // 🦆 NEW: Load context from memory system
        fn load_context(&mut self) -> Result<(), Box<dyn std::error::Error>> {
            let memory_dir = std::env::var("HOME").unwrap_or_else(|_| ".".to_string()) + "/.local/share/yo/stats";
            let context_file = format!("{}/current_context.json", memory_dir);
            
            if let Ok(content) = std::fs::read_to_string(&context_file) {
                self.context = serde_json::from_str(&content)?;
                self.quack_debug(&format!("Loaded context: {:?}", self.context));
            }
            
            // 🦆 Load confirmed patterns for confidence scoring
            let history_file = format!("{}/command_history.json", memory_dir);
            if let Ok(content) = std::fs::read_to_string(&history_file) {
                let history: serde_json::Value = serde_json::from_str(&content)?;
                if let Some(confirmed) = history.get("confirmed_matches").and_then(|c| c.as_object()) {
                    for (key, count) in confirmed {
                        self.confirmed_patterns.insert(key.clone(), count.as_u64().unwrap_or(0) as u32);
                    }
                }
            }
            
            Ok(())
        }
        
        // 🦆 NEW: Context-aware matching - boost patterns that match current context
        fn apply_context_boost(&self, script_name: &str, sentence: &str) -> bool {
            // 🦆 If last action was "update", boost patterns containing "rebuild" or "deploy"
            if self.context.last_action == "update" {
                if sentence.contains("rebuild") || sentence.contains("deploy") {
                    self.quack_debug(&format!("Context boost: {} (follows update)", sentence));
                    return true;
                }
            }
            
            // 🦆 If servers are active, boost patterns mentioning them
            for server in &self.context.active_servers {
                if sentence.contains(&server.to_lowercase()) {
                    self.quack_debug(&format!("Context boost: {} (mentions active server {})", sentence, server));
                    return true;
                }
            }
            
            // 🦆 Boost patterns that have been manually confirmed
            let pattern_key = format!("{}:{}", script_name, sentence);
            if let Some(confidence) = self.confirmed_patterns.get(&pattern_key) {
                if *confidence > 0 {
                    self.quack_debug(&format!("Confidence boost: {} ({} confirmations)", sentence, confidence));
                    return true;
                }
            }
            
            false
        }
        
        // 🦆 NEW: Update context after successful execution
        fn update_context(&self, script_name: &str, args: &[String], matched_sentence: &str) -> Result<(), Box<dyn std::error::Error>> {
            let memory_dir = std::env::var("HOME").unwrap_or_else(|_| ".".to_string()) + "/.local/share/yo/stats";
            let context_file = format!("{}/current_context.json", memory_dir);
            
            let mut context = self.context.clone();
            context.last_action = script_name.to_string();
            
            // 🦆 Detect server mentions in arguments
            for arg in args {
                if arg.contains("dads") {
                    context.active_servers = vec!["dads_media_server".to_string()];
                }
                if arg.contains("moms") { 
                    context.active_servers = vec!["moms_media_server".to_string()];
                }
            }
            
            // 🦆 Update environment based on action type
            if script_name == "deploy" {
                context.environment = "deployment".to_string();
            } else if script_name == "update" || script_name == "rebuild" {
                context.environment = "maintenance".to_string();
            }
            
            // 🦆 Save updated context
            let context_json = serde_json::to_string_pretty(&context)?;
            std::fs::write(&context_file, context_json)?;
            
            // 🦆 Record in command history
            let history_file = format!("{}/command_history.json", memory_dir);
            let mut history: serde_json::Value = if let Ok(content) = std::fs::read_to_string(&history_file) {
                serde_json::from_str(&content).unwrap_or_else(|_| {
                    serde_json::json!({
                        "recent_commands": [],
                        "confirmed_matches": {}
                    })
                })
            } else {
                serde_json::json!({
                    "recent_commands": [],
                    "confirmed_matches": {}
                })
            };
            
            let new_command = serde_json::json!({
                "script": script_name,
                "args": args,
                "matched_sentence": matched_sentence,
                "timestamp": chrono::Local::now().to_rfc3339(),
                "confirmed": false
            });
            
            // 🦆 Keep last 10 commands
            if let Some(recent_commands) = history.get_mut("recent_commands").and_then(|c| c.as_array_mut()) {
                recent_commands.insert(0, new_command);
                if recent_commands.len() > 10 {
                    recent_commands.truncate(10);
                }
            }
            
            std::fs::write(&history_file, serde_json::to_string_pretty(&history)?)?;
            
            Ok(())
        }
        
            
        // 🦆 says ⮞ log successful command execution
        fn log_successful_command(&self, script_name: &str, args: &[String], processing_time: std::time::Duration) -> Result<(), Box<dyn std::error::Error>> {
            let stats_dir = std::env::var("HOME").unwrap_or_else(|_| ".".to_string()) + "/.local/share/yo/stats";
            let stats_file = format!("{}/command_stats.json", stats_dir);  
            let mut stats: serde_json::Value = if let Ok(content) = std::fs::read_to_string(&stats_file) {
                serde_json::from_str(&content).unwrap_or_else(|_| {
                    serde_json::json!({
                        "failed_commands": {},
                        "successful_commands": {},
                        "fuzzy_matches": {}
                    })
                })
            } else {
                serde_json::json!({
                    "failed_commands": {},
                    "successful_commands": {},
                    "fuzzy_matches": {}
                })
            }; 
            if let Some(successful_commands) = stats.get_mut("successful_commands").and_then(|v| v.as_object_mut()) {
                let count = successful_commands.get(script_name).and_then(|v| v.as_u64()).unwrap_or(0);
                successful_commands.insert(script_name.to_string(), serde_json::Value::from(count + 1));
            }
            
            if let Ok(content) = serde_json::to_string_pretty(&stats) {
                let _ = std::fs::write(&stats_file, content);
            }     
            Ok(())
        }
   
        // 🦆 says ⮞ QUACK LOADER - load all the duck data!
        fn load_intent_data(&mut self, intent_data_path: &str) -> Result<(), Box<dyn std::error::Error>> {
            let data = fs::read_to_string(intent_data_path)?;
            self.intent_data = serde_json::from_str(&data)?;
            self.quack_debug(&format!("🦆 Loaded intent data for {} scripts", self.intent_data.len()));
            Ok(())
        }
    
        fn load_fuzzy_index(&mut self, fuzzy_index_path: &str) -> Result<(), Box<dyn std::error::Error>> {
            let data = fs::read_to_string(fuzzy_index_path)?;
            self.fuzzy_index = serde_json::from_str(&data)?;
            self.quack_debug(&format!("🦆 Loaded {} fuzzy index entries", self.fuzzy_index.len()));
            Ok(())
        }
    
        // 🦆 says ⮞ DUCK DEBUGGER - quack while you work!
        fn quack_debug(&self, msg: &str) {
            if self.debug {
                eprintln!("[🦆📜] ⁉️DEBUG⁉️ ⮞ {}", msg);
            }
        }
    
        fn quack_info(&self, msg: &str) {
            eprintln!("[🦆📜] ✅INFO✅ ⮞ {}", msg);
        }
    
        // 🦆 says ⮞ OPTIONAL WORD EXPANDER - make all the combinations!
        fn expand_optional_words(&self, sentence: &str) -> Vec<String> {
            let tokens: Vec<&str> = sentence.split_whitespace().collect();
            let mut variants = Vec::new();
            
            // 🦆 says ⮞ recursive combination generator
            fn generate_combinations(tokens: &[&str], current: Vec<String>, index: usize, result: &mut Vec<String>) {
                if index >= tokens.len() {
                    let sentence = current.join(" ").trim().to_string();
                    if !sentence.is_empty() {
                        result.push(sentence);
                    }
                    return;
                }
    
                let token = tokens[index];
                let mut alternatives = Vec::new();
    
                // 🦆 says ⮞ handle (required|alternatives)
                if token.starts_with('(') && token.ends_with(')') {
                    let clean = &token[1..token.len()-1];
                    alternatives.extend(clean.split('|').map(|s| s.to_string()));
                } 
                // 🦆 says ⮞ handle [optional|words]
                else if token.starts_with('[') && token.ends_with(']') {
                    let clean = &token[1..token.len()-1];
                    alternatives.extend(clean.split('|').map(|s| s.to_string()));
                    alternatives.push("".to_string()); // 🦆 says ⮞ empty for optional
                } 
                // 🦆 says ⮞ regular token
                else {
                    alternatives.push(token.to_string());
                }
    
                for alt in alternatives {
                    let mut new_current = current.clone();
                    if !alt.is_empty() {
                        new_current.push(alt);
                    }
                    generate_combinations(tokens, new_current, index + 1, result);
                }
            }
    
            generate_combinations(&tokens, Vec::new(), 0, &mut variants);
            
            // 🦆 says ⮞ YO! clean up da mezz and filter
            variants.iter()
                .map(|v| v.replace("  ", " ").trim().to_string())
                .filter(|v| !v.is_empty())
                .collect()
        }
    
        // 🦆 says ⮞ ENTITY RESOLVER - duck translation matrix!
        fn resolve_entity(&self, script_name: &str, param_name: &str, param_value: &str) -> String {
            if let Some(intent) = self.intent_data.get(script_name) {
                let normalized_input = param_value.to_lowercase();
                
                for sub in &intent.substitutions {
                    let pattern = sub.pattern.to_lowercase();
                    
                    // 🦆 says ⮞ exact match
                    if pattern == normalized_input {
                        self.quack_debug(&format!("      Exact entity match: {} → {}", param_value, sub.value));
                        return sub.value.clone();
                    }
                    
                    // 🦆 says ⮞ parenthesized content match
                    if pattern.starts_with('(') && pattern.ends_with(')') {
                        let content = &pattern[1..pattern.len()-1]; // 🦆 says ⮞ remove parentheses
                        if content == normalized_input {
                            self.quack_debug(&format!("      Parenthesized entity match: {} → {}", param_value, sub.value));
                            return sub.value.clone();
                        }
                    }
                    
                    // 🦆 says ⮞ handle alternatives in parentheses
                    if pattern.starts_with('(') && pattern.ends_with(')') && pattern.contains('|') {
                        let content = &pattern[1..pattern.len()-1];
                        let alternatives: Vec<&str> = content.split('|').collect();
                        for alternative in alternatives {
                            if alternative.trim() == normalized_input {
                                self.quack_debug(&format!("      Parenthesized alternative match: {} → {}", param_value, sub.value));
                                return sub.value.clone();
                            }
                        }
                    }
                }
                
                // 🦆 says ⮞ Debug: show what we tried to match against
                self.quack_debug(&format!("      No entity match found for '{}' in {} substitutions", 
                    param_value, intent.substitutions.len()));
            }
            
            param_value.to_string()
        }
      
        // 🦆 says ⮞ DYNAMIC REGEX BUILDER - quacky pattern magic!
        fn build_pattern_matcher(&self, _script_name: &str, sentence: &str) -> Option<(Regex, Vec<String>)> {
            let start_time = Instant::now();
            self.quack_debug(&format!("    Building pattern matcher for: '{}'", sentence));
    
            let mut regex_parts = Vec::new();
            let mut param_names = Vec::new();
            let mut current = sentence.to_string();
    
            // 🦆 says ⮞ extract parameters and build regex
            while let Some(start) = current.find('{') {
                if let Some(end) = current.find('}') {
                    let before_param = &current[..start];
                    let param = &current[start+1..end];
                    let after_param = &current[end+1..];
    
                    // 🦆 says ⮞ handle text before parameter
                    if !before_param.is_empty() {
                        let escaped = regex::escape(before_param);
                        regex_parts.push(escaped);
                    }
    
                    param_names.push(param.to_string());
                    
                    // 🦆 says ⮞ handle WILDCARD vs SPECIFIC paramz
                    let regex_group = if param == "search" || param == "param" {
                        // 🦆 says ⮞ wildcard - match anything!
                        self.quack_debug(&format!("      Wildcard parameter: {}", param));
                        "(.*)".to_string()
                    } else {
                        // 🦆 says ⮞ specific parameter - match word boundaries
                        self.quack_debug(&format!("      Specific parameter: {}", param));
                        r"(\b[^ ]+\b)".to_string()
                    };
                    regex_parts.push(regex_group);
                    current = after_param.to_string();
                } else {
                    break;
                }
            }
    
            // 🦆 says ⮞ handle remaining text
            if !current.is_empty() {
                regex_parts.push(regex::escape(&current));
            }
    
            let regex_pattern = format!("^{}$", regex_parts.join(""));
            
            let build_time = start_time.elapsed();
            self.quack_debug(&format!("      Final regex: {}", regex_pattern));
            self.quack_debug(&format!("      Parameter names: {:?}", param_names));
            self.quack_debug(&format!("      Regex build time: {:?}", build_time));  
            match Regex::new(&regex_pattern) {
                Ok(re) => {
                    self.quack_debug("      Regex compiled successfully");
                    Some((re, param_names))
                },
                Err(e) => {
                    self.quack_debug(&format!("🦆 says ⮞ fuck ❌ Regex compilation failed: {}", e));
                    None
                },
            }
        }
    
        // 🦆 says ⮞ PRIORITY PROCESSIN' SYSTEM
        fn calculate_processing_order(&mut self) {
            let mut script_priorities = Vec::new();
            for (script_name, intent) in &self.intent_data {
                // 🦆 says ⮞ calculate priority (default medium)
                let priority = 3; // 🦆 says ⮞ TODO: from voice config 
                // 🦆 says ⮞ detect complex patterns
                let has_complex_patterns = intent.sentences.iter().any(|s| {
                    s.contains('{') || s.contains('[') || s.contains('(')
                });
    
                script_priorities.push(ScriptPriority {
                    name: script_name.clone(),
                    priority,
                    has_complex_patterns,
                });
            }
    
            // 🦆 says ⮞ Nix stylez priority:
            // 🦆 says ⮞ 1: lower priority number first (higher priority)
            // 🦆 says ⮞ 2: simple patterns before complex ones  
            // 🦆 says ⮞ 3: alphabetical for determinism
            script_priorities.sort_by(|a, b| {
                a.priority.cmp(&b.priority)
                    .then(a.has_complex_patterns.cmp(&b.has_complex_patterns))
                    .then(a.name.cmp(&b.name))
            });
    
            self.processing_order = script_priorities;
            self.quack_debug(&format!("Processing order: {:?}", 
                self.processing_order.iter().map(|s| &s.name).collect::<Vec<_>>()));
        }
    
        // 🦆 says ⮞ SUBSTITUTION ENGINE
        fn apply_real_time_substitutions(&self, script_name: &str, text: &str) -> (String, HashMap<String, String>) {
            let mut resolved_text = text.to_lowercase();
            let mut substitutions = HashMap::new();
    
            if let Some(intent) = self.intent_data.get(script_name) {
                for sub in &intent.substitutions {
                    // 🦆 says ⮞ word boundary substitution
                    let pattern = format!(r"\b{}\b", regex::escape(&sub.pattern));
                    if let Ok(re) = Regex::new(&pattern) {
                        if let Some(original_match) = re.find(&resolved_text) {
                            let original = original_match.as_str().to_string();
                            resolved_text = re.replace_all(&resolved_text, &sub.value).to_string();
                            substitutions.insert(original.clone(), sub.value.clone());
                            self.quack_debug(&format!("      Real-time sub: {} → {}", original, sub.value));
                        }
                    }
                }
            }
            (resolved_text, substitutions)
        }
    
        // 🦆 says ⮞ EXACT MATCHIN'        
        fn exact_match(&self, text: &str) -> Option<MatchResult> {
            let global_start = Instant::now();
            let text = text.to_lowercase();     
            self.quack_debug(&format!("Starting EXACT match for: '{}'", text));
        
            for (script_index, script_priority) in self.processing_order.iter().enumerate() {
                let script_name = &script_priority.name; 
                self.quack_debug(&format!("Trying script [{}/{}]: {}", 
                    script_index + 1, self.processing_order.len(), script_name));
                // 🦆 says ⮞ go real-time substitutions i choose u!
                let (resolved_text, substitutions) = self.apply_real_time_substitutions(script_name, &text);
                self.quack_debug(&format!("After substitutions: '{}'", resolved_text));
                if let Some(intent) = self.intent_data.get(script_name) {
                    for sentence in &intent.sentences {
                        let expanded_variants = self.expand_optional_words(sentence);
                        
                        for variant in expanded_variants {
                            if let Some((regex, param_names)) = self.build_pattern_matcher(script_name, &variant) {
                                if let Some(captures) = regex.captures(&resolved_text) {
                                    let mut args = Vec::new();      
                                    // 🦆 says ⮞ process da param
                                    for i in 1..captures.len() {
                                        if let Some(matched) = captures.get(i) {
                                            let param_index = i - 1;
                                            let param_name = if param_index < param_names.len() {
                                                &param_names[param_index]
                                            } else {
                                                "param"
                                            };
                        
                                            let mut param_value = matched.as_str().to_string();     
                                            // 🦆 says ⮞ go entity resolution i choose u!
                                            self.quack_debug(&format!("Before entity resolution: --{} {}", param_name, param_value));
                                            
                                            let entity_resolved = self.resolve_entity(script_name, param_name, &param_value);
                                            if entity_resolved != param_value {
                                                self.quack_debug(&format!("      Entity resolution: --{} {} → {}", 
                                                    param_name, param_value, entity_resolved));
                                                param_value = entity_resolved;
                                            }
                                            
                                            if let Some(sub) = substitutions.get(&param_value) {
                                                self.quack_debug(&format!("      Substitution: {} → {}", param_value, sub));
                                                param_value = sub.clone();
                                            }
                                            
                                            self.quack_debug(&format!("      Final argument: --{} {}", param_name, param_value));
                                            args.push(format!("--{}", param_name));
                                            args.push(param_value);
                                        }
                                    }
                                    
                                    return Some(MatchResult {
                                        script_name: script_name.clone(),
                                        args,
                                        matched_sentence: variant,
                                        processing_time: global_start.elapsed(),
                                    });
                                }
                            }
                        }
                    }
                }
            }          
            None
        }
                 
        // 🦆 says ⮞ fallback yo! FUZZY MATCHIN' 2 teh moon!
        fn levenshtein_distance(&self, a: &str, b: &str) -> usize {
            let a_chars: Vec<char> = a.chars().collect();
            let b_chars: Vec<char> = b.chars().collect();
            let a_len = a_chars.len();
            let b_len = b_chars.len();
    
            if a_len == 0 { return b_len; }
            if b_len == 0 { return a_len; }
    
            let mut matrix = vec![vec![0; b_len + 1]; a_len + 1];
    
            for i in 0..=a_len { matrix[i][0] = i; }
            for j in 0..=b_len { matrix[0][j] = j; }
    
            for i in 1..=a_len {
                for j in 1..=b_len {
                    let cost = if a_chars[i-1] == b_chars[j-1] { 0 } else { 1 };
                    matrix[i][j] = (matrix[i-1][j] + 1)
                        .min(matrix[i][j-1] + 1)
                        .min(matrix[i-1][j-1] + cost);
                }
            }
            matrix[a_len][b_len]
        }
    
        fn find_best_fuzzy_match(&self, text: &str) -> Option<(String, String, i32)> {
            let normalized_input = text.to_lowercase();
            let mut best_score = 0;
            let mut best_match = None;
            self.quack_debug(&format!("Fuzzy matching against {} entries", self.fuzzy_index.len()));
    
            for entry in &self.fuzzy_index {
                let normalized_sentence = entry.sentence.to_lowercase();            
                let distance = self.levenshtein_distance(&normalized_input, &normalized_sentence);
                let max_len = normalized_input.len().max(normalized_sentence.len());
        
                if max_len == 0 { continue; }      
                let score = 100 - (distance * 100 / max_len) as i32;
        
                self.quack_debug(&format!("  '{}' vs '{}' -> {}%", normalized_input, normalized_sentence, score));
        
                if score >= self.fuzzy_threshold {
                    if score > best_score {
                        best_score = score;
                        best_match = Some((entry.script.clone(), entry.sentence.clone(), score));
                        self.quack_debug(&format!("  🦆 NEW BEST: {}%", score));
                    }
                }
            }
            best_match
        }
    
        fn fuzzy_match(&self, text: &str) -> Option<MatchResult> {
            self.quack_debug(&format!("Starting FUZZY match for: '{}'", text));
            
            if let Some((script_name, sentence, score)) = self.find_best_fuzzy_match(text) {
                self.quack_info(&format!("Fuzzy match: {} (score: {}%)", script_name, score)); 
                // 🦆 says ⮞ TODO parameter extraction for fuzzy matches
                let input_words: Vec<&str> = text.split_whitespace().collect();
                let sentence_words: Vec<&str> = sentence.split_whitespace().collect();     
                let mut args = Vec::new();
                let mut param_index = 0;  
                // 🦆 says ⮞ extract parameter names from sentence
                let mut param_names = Vec::new();
                let mut current = sentence.clone();
                while let Some(start) = current.find('{') {
                    if let Some(end) = current.find('}') {
                        let param = &current[start+1..end];
                        param_names.push(param.to_string());
                        current = current[end+1..].to_string();
                    } else { break; }
                }
                
                for (i, word) in sentence_words.iter().enumerate() {
                    if word.starts_with('{') && word.ends_with('}') {
                        if i < input_words.len() && param_index < param_names.len() {
                            let param_name = &param_names[param_index];
                            let param_value = input_words[i];
                            
                            // 🦆 says ⮞ go entity resolution i choose u!
                            let resolved_value = self.resolve_entity(&script_name, param_name, param_value);
                            
                            args.push(format!("--{}", param_name));
                            args.push(resolved_value);
                            param_index += 1;
                            
                            self.quack_debug(&format!("      Fuzzy argument: --{} {}", param_name, param_value));
                        }
                    }
                }
                
                Some(MatchResult {
                    script_name,
                    args,
                    matched_sentence: sentence,
                    processing_time: std::time::Duration::default(),
                })
            } else {
                self.quack_debug("No fuzzy match found");
                None
            }
        }
    
        // 🦆 says ⮞ YO waz qwackin' yo?!
        // 🦆 says ⮞ here comez da executta 
        fn execute_script(&self, result: &MatchResult) -> Result<(), Box<dyn std::error::Error>> {
            self.quack_debug(&format!("Executing: yo {} {}", result.script_name, result.args.join(" ")));  
            // 🦆 says ⮞ execution tree
            println!("   ┌─(yo-{})", result.script_name);
            println!("   │🦆 qwack!? {}", result.matched_sentence);       
            if result.args.is_empty() {
                println!("   └─🦆 says ⮞ no parameters yo");
            } else {
                for chunk in result.args.chunks(2) {
                    if chunk.len() == 2 {
                        println!("   └─⮞ {} {}", chunk[0], chunk[1]);
                    }
                }
            }      
            println!("   └─⏰ do took {:?}", result.processing_time);
 
            // 🦆 says ⮞ EXECUTION
            let status = Command::new(format!("yo-{}", result.script_name))
                .args(&result.args)
                .status()?;          
            if !status.success() {
                eprintln!("🦆 says ⮞ fuck ❌ Script execution failed with status: {}", status);
            }     
            Ok(())
        }
        // 🦆 says ⮞ TTS
        fn say(&self, text: &str) {
            let _ = std::process::Command::new("yo-say")
                .arg(text)
                .status();
        }

        // 🦆 duck say ⮞ very mature sentences incomin' yo!
        fn say_no_match(&self) {
            let responses = vec![
                "Kompis du pratar japanska jag fattar ingenting",
                "Det låter som att du har en köttee bulle i käften. Ät klart middagen och försök sedan igen.",
                "eeyyy bruscchan öppna käften innan du pratar ja fattar nada ju", 
                "men håll käften cp!",
                "noll koll . Golf boll.",
                "Ursäkta?",
            ];

            // 🦆 duck say ⮞ pick a random and text to speech dat shit yo
            use rand::seq::SliceRandom;
            use rand::thread_rng;
            let mut rng = thread_rng();
            if let Some(response) = responses.choose(&mut rng) {
                self.say(response);
           }
        }
        
        // 🦆 says ⮞ go MAIN RUNNER i choose u! - quack 2 da attack!
        pub fn run(&mut self, input: &str, fuzzy_threshold: i32) -> Result<(), Box<dyn std::error::Error>> {
            let total_start = Instant::now(); 
            self.fuzzy_threshold = fuzzy_threshold;
            self.calculate_processing_order();
            
            // 🦆 says ⮞ SPLIT LOGIC: Check if input contains "samt"
            let parts: Vec<&str> = if input.to_lowercase().contains("samt") {
                // 🦆 says ⮞ Split on "samt" and trim each part
                input.split("samt")
                    .map(|part| part.trim())
                    .filter(|part| !part.is_empty())
                    .collect()
            } else {
                // 🦆 says ⮞ No "samt" found, process as single input
                vec![input]
            };
            
            // 🦆 says ⮞ If we have multiple parts, process each one
            if parts.len() > 1 {
                self.quack_debug(&format!("Found {} parts to process: {:?}", parts.len(), parts));
                let mut all_successful = true;
                let mut processed_count = 0;
                
                for (index, part) in parts.iter().enumerate() {
                    self.quack_info(&format!("Processing part {}/{}: '{}'", index + 1, parts.len(), part));
                    
                    // 🦆 says ⮞ Process each part individually
                    match self.process_single_input(part, total_start) {
                        Ok(_) => {
                            processed_count += 1;
                            self.quack_debug(&format!("Successfully processed part {}/{}", index + 1, parts.len()));
                        }
                        Err(e) => {
                            all_successful = false;
                            self.quack_debug(&format!("❌ Failed to process part {}: {}", index + 1, e));
                            // 🦆 says ⮞ Continue with other parts even if one fails
                        }
                    }
                    // 🦆 says ⮞ yo do small delay
                    if index < parts.len() - 1 {
                        std::thread::sleep(std::time::Duration::from_millis(100));
                    }
                }
                if processed_count > 0 {
                    self.quack_debug(&format!("Successfully processed {}/{} parts", processed_count, parts.len()));
                    return Ok(());
                } else {
                    self.quack_info("🦆 says ⮞ fuck ❌ All parts failed to process");
                    std::process::exit(1);
                }
            } else {
                // 🦆 says ⮞ input processing
                self.process_single_input(parts[0], total_start)
            }
        }
        
        // 🦆 says ⮞ process command
        fn process_single_input(&self, input: &str, total_start: Instant) -> Result<(), Box<dyn std::error::Error>> {
            let part_start = Instant::now();
            
            // 🦆 says ⮞ collect fuzzy candidates for logging
            let fuzzy_candidates: Vec<(String, String, i32)> = self.fuzzy_index.iter()
                .filter_map(|entry| {
                    let normalized_input = input.to_lowercase();
                    let normalized_sentence = entry.sentence.to_lowercase();
                    let distance = self.levenshtein_distance(&normalized_input, &normalized_sentence);
                    let max_len = normalized_input.len().max(normalized_sentence.len());
                    if max_len == 0 { return None; }
                    let score = 100 - (distance * 100 / max_len) as i32;
                    if score >= 10 {
                        Some((entry.script.clone(), entry.sentence.clone(), score))
                    } else {
                        None
                    }
                })
                .collect();
                   
            // 🦆 says ⮞ exact matchin'
            if let Some(match_result) = self.exact_match(input) {
                let part_elapsed = part_start.elapsed();
                self.quack_debug(&format!("Exact match found: {}", match_result.script_name));
                let _ = self.log_successful_command(&match_result.script_name, &match_result.args, part_elapsed);    
                let final_result = MatchResult {
                    script_name: match_result.script_name,
                    args: match_result.args,
                    matched_sentence: match_result.matched_sentence,
                    processing_time: part_elapsed,
                };    
                self.execute_script(&final_result)?;
                return Ok(());
            }
        
            // 🦆 says ⮞ fallback yo go fuzzy matchin' i choose u!
            if let Some(match_result) = self.fuzzy_match(input) {
                let part_elapsed = part_start.elapsed();
                self.quack_info(&format!("Fuzzy match found: {}", match_result.script_name));
                let final_result = MatchResult {
                    script_name: match_result.script_name,
                    args: match_result.args,
                    matched_sentence: match_result.matched_sentence,
                    processing_time: part_elapsed,
                };    
                let _ = self.log_successful_command(&final_result.script_name, &final_result.args, final_result.processing_time); 
                self.execute_script(&final_result)?;
                return Ok(());
            }
            
            // 🦆 says ⮞ NO MATCH
            let part_elapsed = part_start.elapsed();
            println!("   ┌─(yo-do)");
            println!("   │🦆 qwack! {}", input);
            println!("   │🦆 says ⮞ fuck ❌ no match!");
        
            if !fuzzy_candidates.is_empty() {
                let top_candidates: Vec<_> = fuzzy_candidates.iter()
                    .filter(|(_, _, score)| *score >= 50)
                    .take(3)
                    .collect();
        
                for (script, sentence, score) in top_candidates {
                    println!("   │   {}%: '{}' -> yo {}", score, sentence, script);
                }
            }
            println!("   └─⏰ do took {:?}", part_elapsed);
            
            // 🦆 says ⮞ speak no match
            self.say_no_match();
            
            // 🦆 says ⮞ log failed command with analysis data
            self.quack_debug("No match found for part, logging statistics...");
            let _ = self.log_failed_command(input, &fuzzy_candidates);
            Err("No match found for this part".into())
        }
        
    }
    fn main() -> Result<(), Box<dyn std::error::Error>> {
        let args: Vec<String> = env::args().collect(); 
        if args.len() < 2 {
            exit(1);
        }       
        let input = &args[1];
        let fuzzy_threshold = if args.len() > 2 {
            args[2].parse().unwrap_or(15)
        } else {
            15
        };
        let mut yo_do = YoDo::new();
        
        // 🦆 says ⮞ load da environment data
        if let Ok(intent_data_path) = env::var("YO_INTENT_DATA") {
            yo_do.load_intent_data(&intent_data_path)?;
        } else {
            eprintln!("🦆 says ⮞ fuck ❌ YO_INTENT_DATA environment variable not set");
            eprintln!("Available YO_* vars:");
            for (key, _) in env::vars().filter(|(k, _)| k.starts_with("YO_")) {
                eprintln!("   {}", key);
            }
            return Ok(());
        }    
        if let Ok(fuzzy_index_path) = env::var("YO_FUZZY_INDEX") {
            // println!("Loading fuzzy index from: {}", fuzzy_index_path);
            yo_do.load_fuzzy_index(&fuzzy_index_path)?;
        }
        yo_do.run(input, fuzzy_threshold)
    }
  '';

  cargoToml = pkgs.writeText "Cargo.toml" ''    
    [package]
    name = "yo_do"
    version = "0.1.1"
    edition = "2021"

    [dependencies]
    regex = "1.0"
    serde = { version = "1.0", features = ["derive"] }
    serde_json = "1.0"
    chrono = { version = "0.4", features = ["serde", "clock"] }
    rand = "0.8"
  '';
 
# 🦆 says ⮞ expose da magic! dis builds da NLP
in { # 🦆 says ⮞ YOOOOOOOOOOOOOOOOOO    
  yo.scripts = { # 🦆 says ⮞ quack quack quack quack quack.... qwack 
    # 🦆 says ⮞ GO RUST DO I CHOOSE u!!1
    do = {
      description = "Brain (do) is a Natural Language to Shell script translator that generates dynamic regex patterns at build time for defined yo.script sentences. At runtime it runs exact and fuzzy pattern matching with automatic parameter resolution and seamless execution";
      category = "🗣️ Voice"; # 🦆 says ⮞ duckgorize iz zmart wen u hab many scriptz i'd say!     
      aliases = [ "brain" ];
      autoStart = false;
      logLevel = "INFO";
      helpFooter = ''
        echo "[🦆🧠]"
        cat ${voiceSentencesHelpFile} 
      '';
      parameters = [ # 🦆 says ⮞ set your mosquitto user & password
        { name = "input"; description = "Text to translate"; optional = false; } 
        { name = "fuzzy"; type = "int"; description = "Minimum procentage for considering fuzzy matching sucessful. (1-100)"; default = 30; }
        { name = "dir"; description = "Directory path to compile in"; default = "/home/pungkula/do-rs"; optional = false; } 
        { name = "build"; type = "bool"; description = "Flag for building the Rust binary"; optional = true; default = false; }            
      ];
      code = ''
        set +u  
        ${cmdHelpers} # 🦆 says ⮞load required bash helper functions 
        FUZZY_THRESHOLD=$fuzzy
        YO_FUZZY_INDEX="${fuzzyIndexFlatFile}"
        text="$input" # 🦆 says ⮞ for once - i'm lettin' u doin' da talkin'
        INTENT_FILE="${intentDataFile}" # 🦆 says ⮞ cache dat JSON wisdom, duck hates slowridez    
        # 🦆 says ⮞ create da stats dirz etc
        mkdir -p "${statsDir}"
        touch "${failedCommandsLog}"
        if [ ! -f "${commandStatsDB}" ]; then
          echo '{"failed_commands": {}, "successful_commands": {}, "fuzzy_matches": {}}' > "${commandStatsDB}"
        fi
        # 🦆 says ⮞ create the Rust projectz directory and move into it
        mkdir -p "$dir"
        cd "$dir"
        mkdir -p src
        # 🦆 says ⮞ create the source filez yo 
        cat ${do-rs} > src/main.rs
        cat ${cargoToml} > Cargo.toml     
        # 🦆 says ⮞ check build bool
        if [ "$build" = true ]; then
          dt_debug "Deleting any possible old versions of the binary"
          rm -f target/release/yo_do
          ${pkgs.cargo}/bin/cargo generate-lockfile     
          ${pkgs.cargo}/bin/cargo build --release  
          dt_debug "Build complete!"
        fi # 🦆 says ⮞ if no binary exist - compile it yo
        if [ ! -f "target/release/yo_do" ]; then
          ${pkgs.cargo}/bin/cargo generate-lockfile     
          ${pkgs.cargo}/bin/cargo build --release
          dt_debug "Build complete!"
        fi
        
        # 🦆 says ⮞ input to duckput
        dt_info "[🦆🧠] Processing: '$input'  hmmm ..."
        
        
        # 🦆 says ⮞ check yo.scripts.do if DEBUG mode yo
        if [ "$VERBOSE" -ge 1 ]; then
          DEBUG=1 YO_INTENT_DATA="$INTENT_FILE" YO_FUZZY_INDEX="$YO_FUZZY_INDEX" ./target/release/yo_do "$input" $FUZZY_THRESHOLD
        fi  
        # 🦆 says ⮞ else run debugless yo
        YO_INTENT_DATA="$INTENT_FILE" YO_FUZZY_INDEX="$YO_FUZZY_INDEX" ./target/release/yo_do "$input" $FUZZY_THRESHOLD
      '';
    };
    
    # 🦆 says ⮞ STATS LOG FAILED COMNMANDS
    memory = {
      description = "Memory is stats and metrics that acts as contexual awareness for the Brain (NLP)";
      category = "🗣️ Voice"; # 🦆 says ⮞ duckgorize iz zmart wen u hab many scriptz i'd say!     
      aliases = [ "stats" ];
      autoStart = false;
      logLevel = "INFO";
      helpFooter = ''
        echo "[🦆📶] yo memory"

        echo "[🦆📶]"    
        echo "Commands:"
        echo "  failed      - Show most frequently failed commands"
        echo "  successful  - Show most used successful commands"
        echo "  fuzzy       - Show fuzzy match statistics"
        echo "  summary     - Show overall statistics"
        echo "  reset       - Reset all statistics"
        echo "  tail        - Live tail of failed commands"
      '';
      parameters = [ # 🦆 says ⮞ set your mosquitto user & password
        { 
          name = "show";
          type = "string";
          description = "What stat to analyze";
          default = "summary";
          values = [ "failed" "successful" "summary" "fuzzy" ];
        }      
        { name = "tail"; type = "bool"; description = "Live tail of failed commands"; default = false; }
        { name = "reset"; type = "bool"; description = "Warning! Will reset all stats!"; default = false; }
      ];

      code = ''
        set +u  
        ${cmdHelpers} # 🦆 says ⮞load required bash helper functions 

        load_stats() {
          if [ -f "${commandStatsDB}" ]; then
            cat "${commandStatsDB}"
          else
            echo '{"failed_commands": {}, "successful_commands": {}, "fuzzy_matches": {}}'
          fi
        }
    
        save_stats() {
          local stats="$1"
          echo "$stats" > "${commandStatsDB}"
        }
    
        increment_stat() {
          local category="$1"
          local key="$2"
          local stats=$(load_stats)      
          local current_count=$(echo "$stats" | jq -r ".''${category}.\"$key\" // 0")
          local new_count=$((current_count + 1))
      
          stats=$(echo "$stats" | jq ".''${category}.\"$key\" = $new_count")
          save_stats "$stats"
        }
    
        show_failed() {
          local stats=$(load_stats)
          echo "🦆 Most Frequently Failed Commands:"
          echo "$stats" | jq -r '.failed_commands | to_entries | sort_by(-.value) | .[] | "\(.key): \(.value) failures"' | head -20
        }
    
        show_successful() {
          local stats=$(load_stats)
          echo "🦆 Most Used Successful Commands:"
          echo "$stats" | jq -r '.successful_commands | to_entries | sort_by(-.value) | .[] | "\(.key): \(.value) successes"' | head -20
        }
    
        show_fuzzy() {
          local stats=$(load_stats)
          echo "🦆 Fuzzy Match Statistics:"
          echo "$stats" | jq -r '.fuzzy_matches | to_entries | sort_by(-.value) | .[] | "\(.key): \(.value) fuzzy matches"' | head -20
        }
    
        show_summary() {
          local stats=$(load_stats)
          local total_failed=$(echo "$stats" | jq '.failed_commands | length')
          local total_success=$(echo "$stats" | jq '.successful_commands | length')
          local total_fuzzy=$(echo "$stats" | jq '.fuzzy_matches | length')      
          local failed_count=$(echo "$stats" | jq '[.failed_commands[]] | add // 0')
          local success_count=$(echo "$stats" | jq '[.successful_commands[]] | add // 0')
          local fuzzy_count=$(echo "$stats" | jq '[.fuzzy_matches[]] | add // 0')
      
          cat << EOF
[🦆📶] Command Statistics Summary:
    
[🦆📶] Total Unique Failed Commands: $total_failed
[🦆📶] Total Failed Attempts: $failed_count
    
[🦆📶] Total Unique Successful Commands: $total_success  
[🦆📶] Total Successful Executions: $success_count
    
[🦆📶] Total Unique Fuzzy Matches: $total_fuzzy
[🦆📶] Total Fuzzy Match Uses: $fuzzy_count
    
Success Rate: $(if [ $((success_count + failed_count)) -gt 0 ]; then echo "scale=2; $success_count * 100 / ($success_count + $failed_count)" | bc; else echo "0"; fi)%
EOF
        }
    
        reset_stats() {
          echo '{"failed_commands": {}, "successful_commands": {}, "fuzzy_matches": {}}' > "${commandStatsDB}"
          echo "[🦆📶]  Statistics reset!"
        }
    
        tail_failed() {
          tail -f "${failedCommandsLog}"
        }
        if [[ "$good" == "true" ]]; then
          confirm_last_command
        fi
        if [[ "$reset" == "true" ]]; then
          reset_stats
        fi
        if [[ "$tail" == "true" ]]; then
          tail_failed
        fi
        if [[ "$show" == "failed" ]]; then
          show_failed
        fi
        if [[ "$show" == "successful" ]]; then
          show_successful
        fi
        if [[ "$show" == "summary" ]]; then
          show_summary
        fi
    
        case "''${1:-}" in
          failed) show_failed ;;
          successful) show_successful ;;
          fuzzy) show_fuzzy ;;
          summary) show_summary ;;
          reset) reset_stats ;;
          tail) tail_failed ;;
          *) show_help ;;
        esac
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
