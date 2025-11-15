# dotfiles/bin/config/tests-rs.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ sentence validation framework
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

  main-rs = pkgs.writeText "main.rs" ''    
    use std::collections::HashMap;
    use std::env;
    use std::fs;
    use std::process::{Command, exit};
    use std::time::Instant;
    use regex::Regex;
    use serde::{Deserialize, Serialize};
    use colored::*;
    
    #[derive(Debug, Clone, Serialize, Deserialize)]
    struct ScriptConfig {
        description: String,
        category: String,
        voice: Option<VoiceConfig>,
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
    
    struct TestRunner {
        intent_data: HashMap<String, IntentData>,
        fuzzy_index: Vec<FuzzyIndexEntry>,
        debug: bool,
        stats_mode: bool,
        single_input: Option<String>,
    }
    
    #[derive(Debug)]
    struct TestResult {
        passed_positive: usize,
        total_positive: usize,
        passed_negative: usize,
        total_negative: usize,
        passed_boundary: usize,
        total_boundary: usize,
        failures: Vec<String>,
        processing_time: std::time::Duration,
    }
    
    impl TestRunner {
        fn new() -> Self {
            Self {
                intent_data: HashMap::new(),
                fuzzy_index: Vec::new(),
                debug: env::var("DEBUG").is_ok() || env::var("DT_DEBUG").is_ok(),
                stats_mode: false,
                single_input: None,
            }
        }
    
        // 🦆 says ⮞ load data from env var
        fn load_data(&mut self) -> Result<(), Box<dyn std::error::Error>> {
            if let Ok(intent_data_path) = env::var("YO_INTENT_DATA") {
                let data = fs::read_to_string(intent_data_path)?;
                self.intent_data = serde_json::from_str(&data)?;
                self.quack_debug(&format!("🦆 Loaded intent data for {} scripts", self.intent_data.len()));
            }
    
            if let Ok(fuzzy_index_path) = env::var("YO_FUZZY_INDEX") {
                let data = fs::read_to_string(fuzzy_index_path)?;
                self.fuzzy_index = serde_json::from_str(&data)?;
                self.quack_debug(&format!("🦆 Loaded {} fuzzy index entries", self.fuzzy_index.len()));
            }
            Ok(())
        }
    
        fn quack_debug(&self, msg: &str) {
            if self.debug {
                eprintln!("[🦆📜] ⁉️DEBUG⁉️ ⮞ {}", msg);
            }
        }
    
        fn quack_info(&self, msg: &str) {
            eprintln!("[🦆📜] ✅INFO✅ ⮞ {}", msg);
        }
    
        // 🦆 says ⮞ word expansion same algorithm as da Nix version
        fn expand_optional_words(&self, sentence: &str) -> Vec<String> {
            let tokens: Vec<&str> = sentence.split_whitespace().collect();
            let mut variants = Vec::new();
            
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
                    alternatives.push("".to_string());
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
            
            // 🦆 says ⮞ clean and filter
            variants.iter()
                .map(|v| v.replace("  ", " ").trim().to_string())
                .filter(|v| !v.is_empty())
                .collect()
        }
    
        // 🦆 says ⮞ resolve sentence / mimic resolve_sentences
        fn resolve_sentence(&self, script_name: &str, sentence: &str) -> String {
            let mut resolved = sentence.to_string();
            
            // 🦆 says ⮞ extract param like {param}
            let param_pattern = Regex::new(r"\{([^}]+)\}").unwrap();
            let mut params: Vec<String> = Vec::new();
            
            for cap in param_pattern.captures_iter(sentence) {
                if let Some(param) = cap.get(1) {
                    params.push(param.as_str().to_string());
                }
            }
    
            // 🦆 says ⮞ replace da param with da example values
            for param in params {
                let replacement = if param.to_lowercase().contains("hour") 
                    || param.to_lowercase().contains("minute") 
                    || param.to_lowercase().contains("second") {
                    "1".to_string()
                } else if param.to_lowercase().contains("room") 
                    || param.to_lowercase().contains("device") {
                    "livingroom".to_string()
                } else {
                    "test".to_string()
                };
                
                resolved = resolved.replace(&format!("{{{}}}", param), &replacement);
            }
    
            // 🦆 says ⮞ handle alternatives (word1|word2) pick da first yo
            let required_pattern = Regex::new(r"\(([^|)]+)(\|[^)]+)?\)").unwrap();
            resolved = required_pattern.replace_all(&resolved, "$1").to_string();
            
            // 🦆 says ⮞ handle optional words [word] steal da word
            let optional_pattern = Regex::new(r"\[([^]]+)\]").unwrap();
            resolved = optional_pattern.replace_all(&resolved, " $1 ").to_string();
            
            // 🦆 says ⮞ handle vertical bars in da alts
            resolved = resolved.replace(" | ", " ").to_string();
            
            // 🦆 says ⮞ clean da spaces
            resolved = resolved.replace("  ", " ").trim().to_string();
    
            resolved
        }
    
        // 🦆 says ⮞ exact matchin' testin'
        fn test_exact_match(&self, script_name: &str, input: &str) -> bool {
            if let Some(intent) = self.intent_data.get(script_name) {
                let normalized_input = input.to_lowercase();
                
                for sentence in &intent.sentences {
                    let expanded_variants = self.expand_optional_words(sentence);
                    
                    for variant in expanded_variants {
                        // 🦆 says ⮞ build dynamic regex
                        let pattern = self.build_test_regex(&variant);
                        if let Ok(re) = Regex::new(&pattern) {
                            if re.is_match(&normalized_input) {
                                self.quack_debug(&format!("✅ EXACT MATCH: {} -> '{}'", script_name, input));
                                return true;
                            }
                        }
                    }
                }
            }
            false
        }
    
        // 🦆 says ⮞ build test regex
        fn build_test_regex(&self, sentence: &str) -> String {
            let mut regex_parts = Vec::new();
            let mut current = sentence.to_string();
    
            // 🦆 says ⮞ exxtract da param & build regex
            while let Some(start) = current.find('{') {
                if let Some(end) = current.find('}') {
                    let before_param = &current[..start];
                    let param = &current[start+1..end];
                    let after_param = &current[end+1..];
    
                    if !before_param.is_empty() {
                        let escaped = regex::escape(before_param);
                        regex_parts.push(escaped);
                    }
    
                    // 🦆 says ⮞ wildcard vs specific parameters
                    let regex_group = if param == "search" || param == "param" {
                        "(.*)".to_string()
                    } else {
                        r"(\b[^ ]+\b)".to_string()
                    };
                    
                    regex_parts.push(regex_group);
                    current = after_param.to_string();
                } else {
                    break;
                }
            }
    
            if !current.is_empty() {
                regex_parts.push(regex::escape(&current));
            }
    
            format!("^{}$", regex_parts.join(""))
        }
    
        // 🦆 says ⮞ test single input
        fn test_single_input(&self, input: &str) {
            println!("{}", "[🦆📜] Testing single input:".bright_blue());
            println!("{} '{}'", "   └─".bright_blue(), input);
            let mut matched = false;
            // 🦆 says ⮞ exact matchin' first
            for script_name in self.intent_data.keys() {
                if self.test_exact_match(script_name, input) {
                    println!("{} {} {}", "   └─".green(), "✅ MATCH:".green(), script_name);
                    matched = true;
                    break;
                }
            }
    
            if !matched {
                // 🦆 says ⮞ fuzzy matchin'
                if let Some(fuzzy_match) = self.find_best_fuzzy_match(input) {
                    println!("{} {} {} (score: {}%)", "   └─".yellow(), "FUZZY:".yellow(), fuzzy_match.0, fuzzy_match.1);
                } else {
                    println!("{} {}", "   └─".red(), "❌ NO MATCH".red());
                }
            }
        }
    
        // 🦆 says ⮞ fuzzy matchin'
        fn find_best_fuzzy_match(&self, text: &str) -> Option<(String, i32)> {
            let normalized_input = text.to_lowercase();
            let mut best_score = 0;
            let mut best_match = None;
    
            for entry in &self.fuzzy_index {
                let normalized_sentence = entry.sentence.to_lowercase();
                let distance = self.levenshtein_distance(&normalized_input, &normalized_sentence);
                let max_len = normalized_input.len().max(normalized_sentence.len()); 
                if max_len == 0 { continue; }
                let score = 100 - (distance * 100 / max_len) as i32;
        
                if score >= 15 && score > best_score {
                    best_score = score;
                    best_match = Some((entry.script.clone(), score));
                }
            }
            best_match
        }
    
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
    
        // 🦆 says ⮞ testin' suite
        fn run_test_suite(&self) -> TestResult {
            let start_time = Instant::now();
            let mut result = TestResult {
                passed_positive: 0,
                total_positive: 0,
                passed_negative: 0,
                total_negative: 0,
                passed_boundary: 0,
                total_boundary: 0,
                failures: Vec::new(),
                processing_time: std::time::Duration::default(),
            };
    
            self.test_positive_cases(&mut result);
            self.test_negative_cases(&mut result);
            self.test_boundary_cases(&mut result);
    
            result.processing_time = start_time.elapsed();
            result
        }
    
        fn test_positive_cases(&self, result: &mut TestResult) {
            println!("{}", "[🦆📜] Testing Positive Cases".bright_blue());
    
            for (script_name, intent) in &self.intent_data {
                println!("{} {}", "   └─ Testing script:".bright_blue(), script_name);
    
                for sentence in &intent.sentences {
                    let expanded_variants = self.expand_optional_words(sentence);
                    
                    for variant in expanded_variants {
                        let test_sentence = self.resolve_sentence(script_name, &variant);
                        result.total_positive += 1;
    
                        print!("{} {}", "     Testing:".bright_blue(), test_sentence);
    
                        if self.test_exact_match(script_name, &test_sentence) {
                            println!(" {}", "✅".green());
                            result.passed_positive += 1;
                        } else {
                            println!(" {}", "❌".red());
                            result.failures.push(format!("POSITIVE: {} | {}", script_name, test_sentence));
                        }
                    }
                }
            }
        }
    
        fn test_negative_cases(&self, result: &mut TestResult) {
            println!("{}", "[🦆🚫] Testing Negative Cases".bright_blue());
    
            let negative_cases = vec![
                "make me a sandwich",
                "launch the nuclear torpedos!",
                "gör mig en macka", 
                "avfyra kärnvapnen!",
                "ducks sure are the best dont you agree",
            ];
    
            for case in negative_cases {
                result.total_negative += 1;
                print!("{} {}", "   Testing:".bright_blue(), case);
    
                let mut matched = false;
                for script_name in self.intent_data.keys() {
                    if self.test_exact_match(script_name, case) {
                        println!(" {}", "❌ FALSE POSITIVE".red());
                        result.failures.push(format!("NEGATIVE: {} | {}", script_name, case));
                        matched = true;
                        break;
                    }
                }
    
                if !matched {
                    println!(" {}", "✅".green());
                    result.passed_negative += 1;
                }
            }
        }
    
        fn test_boundary_cases(&self, result: &mut TestResult) {
            println!("{}", "[🦆🔲] Testing Boundary Cases".bright_blue());
            let boundary_cases = vec!["", "   ", ".", "!@#$%^&*()"];
    
            for case in boundary_cases {
                result.total_boundary += 1;
                print!("{} '{}'", "   Testing:".bright_blue(), case);
    
                let mut matched = false;
                for script_name in self.intent_data.keys() {
                    if self.test_exact_match(script_name, case) {
                        println!(" {}", "❌".red());
                        result.failures.push(format!("BOUNDARY: {} | '{}'", script_name, case));
                        matched = true;
                        break;
                    }
                }
    
                if !matched {
                    println!(" {}", "✅".green());
                    result.passed_boundary += 1;
                }
            }
        }
    
        // 🦆 says ⮞ display statz yo
        fn display_stats(&self) {
            println!("{}", "[🦆📊] Voice Command Statistics".bright_blue());
            println!();
    
            let mut scripts_with_voice = Vec::new();
    
            for (script_name, intent) in &self.intent_data {
                let patterns = intent.sentences.len();
                let phrases: usize = intent.sentences.iter()
                    .map(|s| self.expand_optional_words(s).len())
                    .sum();
                
                let ratio = if patterns > 0 {
                    phrases as f64 / patterns as f64
                } else {
                    0.0
                };
    
                scripts_with_voice.push((script_name.clone(), patterns, phrases, ratio));
            }
    
            scripts_with_voice.sort_by(|a, b| b.3.partial_cmp(&a.3).unwrap());
    
            for (name, patterns, phrases, ratio) in scripts_with_voice {
                let ratio_str = if patterns == 0 {
                    "∞".to_string()
                } else {
                    format!("{:.1}", ratio)
                };
    
                let status = if patterns == 0 {
                    "EMPTY".red()
                } else if phrases == 0 || (patterns > 0 && ratio < 0.5) {
                    "NEEDS PHRASES".yellow()
                } else if ratio > 50.0 {
                    "HIGH RATIO".bright_yellow()
                } else {
                    "OK".green()
                };
                println!("{}: patterns={}, phrases={}, ratio={} - {}", 
                    name, patterns, phrases, ratio_str, status);
            }
    
            println!();
            println!("{}", "Key insights:".bright_blue());
            println!("  • High pattern count decreases matching speed but increases accuracy");
            println!("  • High ratio (>50) may indicate over-complex patterns");
            println!("  • Use priority=5 for scripts with many patterns to optimize performance");
        }
    
        // 🦆 says ⮞ Final report
        fn display_final_report(&self, result: &TestResult) {
            let total_tests = result.total_positive + result.total_negative + result.total_boundary;
            let passed_tests = result.passed_positive + result.passed_negative + result.passed_boundary;
            let percent = if total_tests > 0 {
                (passed_tests * 100) / total_tests
            } else {
                0
            };
    
            let (color, duck_report) = if percent >= 80 {
                (Color::Green, "⭐")
            } else if percent >= 60 {
                (Color::Yellow, "🟢") 
            } else {
                (Color::Red, "😭")
            };
    
            // 🦆 says ⮞ display fails
            if passed_tests != total_tests && !result.failures.is_empty() {
                println!();
                println!("{}", "# ────── FAILURES ──────#".red());
                for failure in &result.failures {
                    println!("{} {}", "## ❌".red(), failure);
                }
                println!("{}", "# ────── FAILURES ──────#".red());
            }
    
            println!();
            println!("{}", "# ──────⋆⋅☆⋅⋆────── #".color(color));
            println!("{}", "Testing completed!".bold());
            println!("{} {}", "Positive:".bold(), 
                format!("{}/{}", result.passed_positive, result.total_positive).color(color));
            println!("{} {}", "Negative:".bold(),
                format!("{}/{}", result.passed_negative, result.total_negative).color(color));
            println!("{} {}", "Boundary:".bold(),
                format!("{}/{}", result.passed_boundary, result.total_boundary).color(color));
            println!("{} {}", "TOTAL:".bold(),
                format!("{}/{} ({}%)", passed_tests, total_tests, percent).color(color));
            println!("{}", "# ──────⋆⋅☆⋅⋆────── #".color(color));
            println!("{}", duck_report);   
            self.quack_info(&format!("Test completed with results: {}/{} {}%", 
                passed_tests, total_tests, percent));
        }
    }
    
    fn main() -> Result<(), Box<dyn std::error::Error>> {
        let args: Vec<String> = env::args().collect();
        let mut test_runner = TestRunner::new();
        let mut stats_mode = false;
        let mut single_input = None;
        let mut i = 1;
        while i < args.len() {
            match args[i].as_str() {
                "--stats" => stats_mode = true,
                "--input" if i + 1 < args.len() => {
                    single_input = Some(args[i + 1].clone());
                    i += 1;
                }
                _ => {}
            }
            i += 1;
        }
    
        test_runner.stats_mode = stats_mode;
        test_runner.single_input = single_input;
    
        // 🦆 says ⮞ load test data
        test_runner.load_data()?;
    
        if test_runner.stats_mode {
            test_runner.display_stats();
        } else if let Some(input) = &test_runner.single_input {
            test_runner.test_single_input(input);
        } else {
            let result = test_runner.run_test_suite();
            test_runner.display_final_report(&result);
            
            if result.passed_positive + result.passed_negative + result.passed_boundary 
                != result.total_positive + result.total_negative + result.total_boundary {
                exit(1);
            }
        } 
        Ok(())
    }
    
  '';

  cargoToml = pkgs.writeText "Cargo.toml" ''    
    [package]
    name = "yo_tests"
    version = "0.1.0"
    edition = "2021"

    [[bin]]
    name = "yo-tests"
    path = "src/bin/yo-tests.rs"

    [dependencies]
    colored = "2.0"
    regex = "1.0"
    serde = { version = "1.0", features = ["derive"] }
    serde_json = "1.0"
  '';
  fuzzyIndexFlatFile = pkgs.writeText "fuzzy-rust-index.json" (builtins.toJSON fuzzyFlatIndex);  
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

  scriptsWithFuzzy = lib.filterAttrs (_: script: 
    script.voice != null && 
    (script.voice.enabled or true) &&
    (script.voice.fuzzy.enable or true)  # 🦆 Must explicitly allow fuzzy
  ) config.yo.scripts;
 

# 🦆 says ⮞ expose da magic! dis builds our NLP
in { # 🦆 says ⮞ YOOOOOOOOOOOOOOOOOO    
  yo.scripts = { # 🦆 says ⮞ quack quack quack quack quack.... qwack      
    # 🦆 says ⮞ automatic doin' sentencin' testin'
    tests-rs = { # 🦆 says ⮞ just run yo tests to do an extensive automated test based on your defined sentence data 
      description = "Extensive automated sentence testing for the NLP ()"; 
      category = "🗣️ Voice";
      autoStart = false;
      logLevel = "INFO";
      parameters = [
        { name = "input"; description = "Text to test as a single  sentence test"; optional = true; }
        { name = "stats"; type = "bool"; description = "Flag to display voice commands information like generated regex patterns, generated phrases and ratio"; optional = true; }    
        { name = "fuzzy"; type = "int"; description = "Minimum procentage for considering fuzzy matching sucessful. (1-100)"; default = 30; }
        { name = "dir"; description = "Directory path to compile in"; default = "/home/pungkula/tests-rs"; optional = false; } 
        { name = "build"; type = "bool"; description = "Flag for building the Rust binary"; optional = true; default = false; }            
        { name = "realtime"; type = "bool"; description = "Run in real-time mode for voice assistant"; optional = true; default = false; } 
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
        ${cmdHelpers} # 🦆 says ⮞load required bash helper functions 
        FUZZY_THRESHOLD=$fuzzy
        YO_FUZZY_INDEX="${fuzzyIndexFlatFile}"
        text="$input"
        INTENT_FILE="${intentDataFile}"
        
   
        # 🦆 says ⮞ create the Rust projectz directory and move into it
        mkdir -p "$dir"
        cd "$dir"
        mkdir -p src
        
        # 🦆 says ⮞ create the source filez yo 
        cat ${main-rs} > src/main.rs
        cat ${cargoToml} > Cargo.toml     
        
        # 🦆 says ⮞ check build bool
        if [ "$build" = true ]; then
          dt_debug "Deleting any possible old versions of the binary"
          rm -f target/release/yo_do
          ${pkgs.cargo}/bin/cargo generate-lockfile     
          ${pkgs.cargo}/bin/cargo build --release  
          dt_debug "Build complete!"
        fi
        
        # 🦆 says ⮞ if no binary exist - compile it yo
        if [ ! -f "target/release/yo_do" ]; then
          ${pkgs.cargo}/bin/cargo generate-lockfile     
          ${pkgs.cargo}/bin/cargo build --release
          dt_debug "Build complete!"
        fi

        # 🦆 says ⮞ websocket streaming chunks (testing)
        if [ "$realtime" = "true" ]; then
          dt_info "[🦆🧠] Starting real-time NLP mode..."
          YO_INTENT_DATA="$INTENT_FILE" YO_FUZZY_INDEX="$YO_FUZZY_INDEX" ./target/release/yo_tests --realtime
          exit 0
        fi

        dt_info "[🦆🧠] '$input'"
        
        # 🦆 says ⮞ capture Rust output
        TEMP_OUTPUT=$(mktemp)
        
        # 🦆 says ⮞ check yo.scripts.do if DEBUG mode yo
        if [ "$VERBOSE" -ge 1 ]; then
          DEBUG=1 YO_INTENT_DATA="$INTENT_FILE" YO_FUZZY_INDEX="$YO_FUZZY_INDEX" ./target/release/yo_tests "$input" $FUZZY_THRESHOLD 2>&1 | tee "$TEMP_OUTPUT"
        else
          YO_INTENT_DATA="$INTENT_FILE" YO_FUZZY_INDEX="$YO_FUZZY_INDEX" ./target/release/yo_tests "$input" $FUZZY_THRESHOLD 2>&1 | tee "$TEMP_OUTPUT"
        fi

        # 🦆 says ⮞ parse da memory data no subshell plx
        SCRIPT_NAME=""
        ARGS=""
        SENTENCE=""
        MATCH_TYPE=""

        # 🦆 says ⮞ Read from temp file no avoid subshell
        while IFS= read -r line; do
          if echo "$line" | grep -q "🦆MEMORY:SCRIPT:"; then
            SCRIPT_NAME=$(echo "$line" | sed 's/.*🦆MEMORY:SCRIPT://')
          elif echo "$line" | grep -q "🦆MEMORY:ARGS:"; then
            ARGS=$(echo "$line" | sed 's/.*🦆MEMORY:ARGS://')
          elif echo "$line" | grep -q "🦆MEMORY:SENTENCE:"; then
            SENTENCE=$(echo "$line" | sed 's/.*🦆MEMORY:SENTENCE://')
          elif echo "$line" | grep -q "🦆MEMORY:TYPE:"; then
            MATCH_TYPE=$(echo "$line" | sed 's/.*🦆MEMORY:TYPE://')
          fi
        done < "$TEMP_OUTPUT"

        rm -f "$TEMP_OUTPUT"
        # 🦆 says⮞record 2 memory if successful matchin'
        if [ -n "$SCRIPT_NAME" ] && [ -n "$SENTENCE" ]; then
          dt_debug "Recording to memory: $SCRIPT_NAME|$ARGS|$SENTENCE|$MATCH_TYPE"
          yo memory --record "$SCRIPT_NAME|$ARGS|$SENTENCE|$MATCH_TYPE"
        else
          dt_debug "No successful match to record to memory"
        fi
      ''; # 🦆 says ⮞ thnx for quackin' along til da end!
    };  # 🦆 say ⮞ nobody beat diz nlp nao says sir quack a lot NOBODY I SAY!
  };} # 🦆 says ⮞ QuackHack-McBLindy out!  
