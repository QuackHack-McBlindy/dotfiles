# dotfiles/modules/yo.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 duck say ⮞ CLI framework - centralized script handling
  self, 
  config,
  lib,
  pkgs,   
  ...
} : with lib;
let # 🦆 says ⮞ for README version badge yo
  nixosVersion = let
    raw = builtins.readFile /etc/os-release;
    versionMatch = builtins.match ".*VERSION_ID=([0-9\\.]+).*" raw;
  in builtins.replaceStrings [ "." ] [ "%2E" ] (builtins.elemAt versionMatch 0);

  sysHosts = builtins.attrNames self.nixosConfigurations;
  vmHosts = builtins.filter (host:
    self.nixosConfigurations.${host}.self.config.system.build ? vm
  ) sysHosts;  
  # 🦆 duck say ⮞ comma sep list of your hosts
  sysHostsComma = builtins.concatStringsSep "," sysHosts;

  # 🦆 duck say ⮞ validate time format - HH:MM (24h)
  isValidTime = timeStr:
    let
      matches = builtins.match "([0-9]{1,2}):([0-9]{2})" timeStr;
    in
      if matches != null then
        let
          hourStr = builtins.elemAt matches 0;
          minuteStr = builtins.elemAt matches 1;
          # 🦆 duck say ⮞ remove leading zeros for JSON parsin'
          cleanNumber = str:
            if builtins.substring 0 1 str == "0" && builtins.stringLength str > 1
            then builtins.substring 1 (builtins.stringLength str) str
            else str;
          hour = builtins.fromJSON (cleanNumber hourStr);
          minute = builtins.fromJSON (cleanNumber minuteStr);
        in
          hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59
      else false;
  
  # 🦆 duck say ⮞ validate list of timez
  validateTimes = times:
    if times == null then null
    else
      let
        invalidTimes = lib.filter (time: !isValidTime time) times;
      in
        if invalidTimes != [] then
          throw "🦆 duck say ⮞ fuck ❌ Invalid time format in runAt: ${lib.concatStringsSep ", " invalidTimes}. Use HH:MM (24-hour format)"
        else times;

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
    lib.foldl (acc: r: replaceStrings [ (builtins.elemAt r 0) ] [ (builtins.elemAt r 1) ] acc) str replacements;

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

  # 🦆 duck say ⮞ expoort param into shell script
  yoEnvGenVar = script: let
    withDefaults = builtins.filter (p: p.default != null) script.parameters;
    exports = map (p: 
      let # 🦆 duck say ⮞ convert dem Nix types 2 shell strings
        defaultValue = 
          if p.type == "string" then lib.escapeShellArg (toString p.default)
          else if p.type == "int" then toString p.default
          else if p.type == "bool" then (if p.default then "true" else "false")
          else if p.type == "path" then lib.escapeShellArg (toString p.default)
          else lib.escapeShellArg (toString p.default);
      in
        "export ${p.name}=${defaultValue}"
    ) withDefaults;
  in lib.concatStringsSep "\n" exports;

  scriptType = types.submodule ({ name, configFinal, ... }: {   
# 🦆 ⮞ OPTIONS 🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆#    
    options = { # 🦆 duck say ⮞ a name cool'd be cool right?
      name = mkOption {
        type = types.str;
        internal = true;
        readOnly = true;
        default = name;
        description = "Script name derived from attribute key";
      }; # 🦆 duck say ⮞ describe yo script yo!
      description = mkOption {
        type = types.str;
        default = "";
        description = "Description of the script";
      }; # 🦆 duck say > categoryiez da script (for sorting in `yo --help` & README.md    
      category = mkOption {
        type = types.str;
        default = "";
        description = "Category of the script";
      };
      filePath = mkOption {
        type = types.str;
        readOnly = true;
      };
      # 🦆 duck say ⮞ yo go ahead describe da script yo     
      visibleInReadme = mkOption {
        type = types.bool;
        default = ./category != "";
        defaultText = "category != \"\"";
        description = "Whether to include this script in README.md";
      }; # 🦆 duck say ⮞ duck trace log level
      logLevel = mkOption {
        type = types.enum ["DEBUG" "INFO" "WARNING" "ERROR" "CRITICAL"];
        default = "INFO";
        description = "Sets the log level for Duck Trace";
      }; # 🦆 duck say ⮞ extra code to be ran & displayed whelp calling da scripts --help cmd  
      helpFooter = mkOption {
        type = types.lines;
        default = "";
        description = "Additional shell code to run when generating help text";
      }; # 🦆 duck say ⮞ generatez systemd service for da script if true 
      autoStart = mkOption {
        type = types.bool;
        default = false;
        description = "Run the script in the background at startup";
      };
      runEvery = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Run this script periodically every X minutes";
      }; # 🦆 duck say ⮞ run at specific time
      runAt = mkOption {
        type = types.nullOr (types.listOf (types.strMatching "[0-9]{1,2}:[0-9]{2}"));
        default = null;
        description = "Run this script at specific times daily (format: [HH:MM, ...], 24-hour)";
        apply = validateTimes;
      }; # 🦆 duck say ⮞ code to be executed when calling tda script yo      
      code = mkOption {
        type = types.lines;
        description = "The script code";
      }; # 🦆 duck say ⮞ alias for da script for extra execution triggerz 
      aliases = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Alternative command names for this script";
      }; # 🦆 duck say ⮞ read-only option dat showz da number of generated regex patternz
      voicePatterns = mkOption {
        type = types.int;
        internal = true;
        readOnly = true;
        description = "Number of regex patterns generated for this script's voice commands";      
      }; # 🦆 duck say ⮞ phrase coverage for this script
      voicePhrases = mkOption {
        type = types.int;
        internal = true;
        readOnly = true;
        description = "Theoretical number of unique spoken phrases this script can understand";   
      }; # 🦆 duck say ⮞ parameter options for the yo script we writin' 
      parameters = mkOption {
        type = types.listOf (types.submodule {
          options = { # 🦆 duck say ⮞ parameters = [{ name = ""; description = ""; default = "": optional = "": type = ""; }]; 
            name = mkOption { type = types.str; };
            description = mkOption { type = types.str; };
            default = mkOption {
              type = types.nullOr (types.oneOf [
                types.str
                types.int
                types.bool
                types.path
              ]);
              default = null;
              description = "Default value if parameter is not provided";
            }; # 🦆 duck say ⮞ i likez diz option - highly useful
            optional = mkOption { 
              type = types.bool; 
              default = ./default != null;
              description = "Whether this parameter can be omitted";
            }; # 🦆 duck say ⮞ diz makez da param sleazy eazy to validate yo 
            type = mkOption {
              type = types.enum ["string" "int" "path" "bool"];
              default = "string";
              description = "Type of parameter. Use path for filepath int for numbers, bool for true/false flags, and string (default) for all others";
            }; # 🦆 duck say ⮞ value option for allowed values (string type only)
            values = mkOption {
              type = types.nullOr (types.listOf types.str);
              default = null;
              description = "Allowed values for this parameter (only applicable for string type)";
            };
          };
        });
        default = [];
        description = "Parameters accepted by this script";
      };
      voice = mkOption {
        type = types.nullOr (types.submodule {
          options = {
            enabled = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Whether to generate voice intents for this script";
            };
            priority = mkOption {
              type = types.ints.between 1 5;
              default = 3;
              description = "Processing priority (1=highest, 5=lowest)";
            };
            fuzzy = mkOption {
              type = types.submodule {
                options = {
                  enable = mkOption {
                    type = types.bool;
                    default = true;
                    description = "Enable fuzzy voice matching for this script";
                  };
                  threshold = mkOption {
                    type = types.float;
                    default = 0.8;
                    description = "Script specific similarity threshold for fuzzy matching (0.0–1.0)";
                  };
                };
              };
              default = {};
              description = "Configuration for fuzzy voice matching";
            };
            sentences = mkOption {
              type = types.listOf types.str;
              default = [];
              description = "Voice command patterns for this script";
            };
            lists = mkOption {
              type = types.attrsOf (types.submodule {
                options = {
                  wildcard = mkOption {
                    type = types.bool;
                    default = false;
                    description = "Accept free-form text input";
                  };
                  values = mkOption {
                    type = types.listOf (types.submodule {
                      options."in" = mkOption { type = types.str; };
                      options.out = mkOption { type = types.str; };
                    });
                    default = [];
                  };
                };
              });
              default = {};
              description = "Entity lists for voice parameters";
            };
          };
        });
        default = null;
        description = "Voice command configuration for this script";
      }; # 🦆 duck say ⮞ read-only option dat showz if da script haz voice
      voiceReady = mkOption {
        type = types.bool;
        internal = true;
        readOnly = true;
        description = "Whether this script has voice commands configured";
      };
    };
    config = let # 🦆 duck say ⮞ map categories to bin directories
      categoryDirMap = {
        "🎧 Media Management" = "bin/media";
        "🗣️ Voice" = "bin/voice";
        "🛖 Home Automation" = "bin/home";
        "🧹 Maintenance" = "bin/maintenance";
        "🧩 Miscellaneous" = "bin/misc";
        "🌐 Networking" = "bin/network";
        "🌍 Localization" = "bin/misc";
        "⚡ Productivity" = "bin/productivity";
        "🖥️ System Management" = "bin/system";
        "📁 File Operations" = "bin/files";        
        "🔐 Security & Encryption" = "bin/security";
      };  
      script = config.yo.scripts.${name};      
      vr = config.yo.scripts.${name}.voiceReady;      
      category = config.yo.scripts.${name}.category;
      resolvedDir = categoryDirMap.${category} or "bin/misc"; # 🦆 duck say ⮞ falback to bin/misc
    in { # 🦆 duck say ⮞ set scripts filepath
      filePath = mkDefault "${resolvedDir}/${name}.nix";
      voiceReady = mkDefault (
        script.voice != null && 
        script.voice.sentences != [] &&
        script.voice.sentences != null
      );
      # 🦆 duck say ⮞ set script counterz
      voicePatterns = mkDefault (countGeneratedPatterns script);
      voicePhrases = mkDefault (countUnderstoodPhrases script);
    };
  });
  cfg = config.yo;

  # 🦆 duck say ⮞ letz create da yo scripts pkgs - we symlinkz all yo scripts togetha .. quack quack 
  yoScriptsPackage = pkgs.symlinkJoin {
    name = "yo-scripts"; # 🦆 duck say ⮞ map over yo scripts and gen dem shell scriptz wrapperz!!
    paths = mapAttrsToList (name: script:
      let # 🦆 duck say ⮞ compile help sentences at build time      
        # 🦆 duck say ⮞ compile help sentences at build time
        voiceSentencesHelp = if script.voice != null && script.voice.sentences != [] then
          let
            patterns = countGeneratedPatterns script;
            phrases = countUnderstoodPhrases script;
            # 🦆 duck say ⮞ copy the parameter replacement logic from voiceSentencesHelpFile
            replaceParamsWithValues = sentence: voiceData:
              let
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
                            # 🦆 duck say ⮞ get all possible input values
                            values = map (v: v."in") listData.values;
                            # 🦆 duck say ⮞ expand any optional patterns like [foo|bar]
                            expandedValues = lib.concatMap expandListInputVariants values;
                            # 🦆 duck say ⮞ take first few examples for display
                            examples = lib.take 3 (lib.unique expandedValues);
                          in
                            if examples == [] then "ANYTHING"
                            else "(" + lib.concatStringsSep "|" examples + 
                                 (if lib.length examples < lib.length expandedValues then "|...)" else ")")
                      else
                        "ANYTHING" # 🦆 duck say ⮞ fallback if param not found
                  else
                    token;
                
                # 🦆 duck say ⮞ split sentence and process each token
                tokens = lib.splitString " " sentence;
                processedTokens = map processToken tokens;
              in
                lib.concatStringsSep " " processedTokens;
            
            # 🦆 duck say ⮞ replace params in each sentence for the help display
            processedSentences = map (sentence: 
              replaceParamsWithValues sentence script.voice
            ) script.voice.sentences;
            
            sentencesMarkdown = lib.concatMapStrings (sentence: 
              "- \"${escapeMD sentence}\"\n"
            ) processedSentences;
          in
            "## Voice Commands\n\nPatterns: ${toString patterns}  \nPhrases: ${toString phrases}  \n\n${sentencesMarkdown}"
        else "";
       
      
        # 🦆 duck say ⮞ generate a string for da CLI usage optional parameters [--like] diz yo
        param_usage = lib.concatMapStringsSep " " (param:
          if param.optional
          then "[--${param.name}]" # 🦆 duck say ⮞ iptional params baked inoto brackets
          else "--${param.name}" # 🦆 duck say ⮞ otherz paramz shown az iz yo
        # 🦆 duck say ⮞ filter out da special flagz from standard usage 
        ) (lib.filter (p: !builtins.elem p.name ["!" "?"]) script.parameters);
        
        # 🦆 duck say ⮞ diz iz where da magic'z at yo! trust da duck yo 
        scriptContent = ''
          #!${pkgs.runtimeShell}
#          set -euo pipefail # 🦆 duck say ⮞ strict error handlin' yo - will exit on errorz
          set -o noglob  # 🦆 duck say ⮞ disable wildcard expansion for ? and ! flags
          ${yoEnvGenVar script} # 🦆 duck say ⮞ inject da env quack quack.... quack
          export LC_NUMERIC=C
          start=$(date +%s.%N)
#          trap 'end=$(date +%s.%N); elapsed=$(echo "$end - $start" | bc); printf "[🦆⏱] Total time: %.3f seconds\n" "$elapsed"' EXIT
          # 🦆 duck say ⮞ duckTrace log setup
          export DT_LOG_PATH="$HOME/.config/duckTrace/"
          mkdir -p "$DT_LOG_PATH"   
          export DT_LOG_FILE="${name}.log" # 🦆 duck say ⮞ duck tracin' be namin' da log file for da ran script
          touch "$DT_LOG_PATH/$DT_LOG_FILE"
          export DT_LOG_LEVEL="${script.logLevel}" # 🦆 duck say ⮞ da tracin' duck back to fetch da log level yo
          DT_MONITOR_HOSTS="${sysHostsComma}";
          DT_MONITOR_PORT="9999";
      
          # 🦆 duck say ⮞ PHASE 1: preprocess special flagz woop woop
          VERBOSE=0
          DRY_RUN=false
          FILTERED_ARGS=()
          # 🦆 duck say ⮞ LOOP through da ARGz til' duckie duck all  dizzy duck
          while [[ $# -gt 0 ]]; do
            case "$1" in
              \?) ((VERBOSE++)); shift ;;        # 🦆 duck say ⮞ if da arg iz '?' == increment verbose counter
              '!') DRY_RUN=true; shift ;;        # 🦆 duck say ⮞ if da arg iz '!' == enablez da dry run mode yo
              *) FILTERED_ARGS+=("$1"); shift ;; # 🦆 duck say ⮞ else we collect dem arguments for script processin'
            esac
          done  
          VERBOSE=$VERBOSE
          export VERBOSE DRY_RUN
          
          # 🦆 duck say ⮞ reset arguments without special flags
          set -- "''${FILTERED_ARGS[@]}"

          # 🦆 duck say ⮞ PHASE 2: regular parameter parsin' flappin' flappin' quack quack yo
          declare -A PARAMS=()
          POSITIONAL=()
          VERBOSE=$VERBOSE
          DRY_RUN=$DRY_RUN
          # 🦆 duck say ⮞ if ? flag used - sets scripts logLevel to DEBUG
          if [ "$VERBOSE" -ge 1 ]; then
            DT_LOG_LEVEL="DEBUG"
          fi
          
          # 🦆 duck say ⮞ parse all parameters
          while [[ $# -gt 0 ]]; do
            case "$1" in
              --help|-h) # 🦆 duck say ⮞ if  u needz help call `--help` or `-h`
                width=$(tput cols 2>/dev/null || echo 100) # 🦆 duck say ⮞ get terminal width for formatin' - fallin' back to 100
                help_footer=$(${script.helpFooter}) # 🦆 duck say ⮞ dynamically generatez da helpFooter if ya defined it yo   
                # 🦆 duck say ⮞ script haz paramz?
                usage_suffix=""
                if [[ -n "${toString (script.parameters != [])}" ]]; then
                  usage_suffix=" [OPTIONS]"
                fi
                
                cat <<EOF | ${pkgs.glow}/bin/glow --width "$width" - # 🦆 duck say ⮞ renderin' da cool & duckified CLI docz usin' Markdown & Glow yo 
# 🚀🦆 yo ${escapeMD script.name}
${script.description}
**Usage:** \`yo ${escapeMD script.name}''${usage_suffix}\`
${lib.optionalString (script.parameters != []) ''
## Parameters
${lib.concatStringsSep "\n\n" (map (param: ''
**\`--${param.name}\`**  
${param.description}  
${lib.optionalString param.optional "*(optional)*"} ${lib.optionalString (param.default != null) (let
  defaultText = 
    if param.type == "bool" then 
      (if param.default then "true" else "false")
    else 
      (toString param.default);
in "*(default: ${defaultText})*")}
${lib.optionalString (param.values != null && param.type == "string") 
  "*(allowed: ${lib.concatStringsSep ", " param.values})*"}
'') script.parameters)}
''}
${voiceSentencesHelp}

$help_footer
EOF
                exit 0
                ;;
              --*) # 🦆 duck say ⮞ parse named paramz like: "--duck"
                param_name=''${1##--}
                # 🦆 duck say ⮞ let'z check if diz param existz in da scriptz defined parameterz
                if [[ " ${concatMapStringsSep " " (p: 
                      if p.type == "bool" then p.name else ""
                    ) script.parameters} " =~ " $param_name " ]]; then
                  # 🦆 duck say ⮞ boolean flag - presence means true, but also allow explicit true/false
                  if [[ $# -gt 1 && ( "$2" == "true" || "$2" == "false" ) ]]; then
                    PARAMS["$param_name"]="$2"
                    shift 2
                  else
                    PARAMS["$param_name"]="true"
                    shift 1
                  fi
                else
                  # 🦆 duck say ⮞ regular param expects value
                  if [[ " ${concatMapStringsSep " " (p: p.name) script.parameters} " =~ " $param_name " ]]; then
                    PARAMS["$param_name"]="$2" # 🦆 duck say ⮞ assignz da value
                    shift 2
                  else # 🦆 duck say ⮞ unknown param? duck say fuck
                    echo -e "\033[1;31m 🦆 duck say ⮞ fuck ❌ $1\033[0m Unknown parameter: $1"
                    exit 1
                  fi
                fi
                ;;
              *) # 🦆 duck say ⮞ none of the above matchez? i guezz itz a positional param yo
                POSITIONAL+=("$1")
                shift
                ;;
            esac
          done

            # 🦆 duck say ⮞ PHASE 3: assign dem' parameterz!
            ${concatStringsSep "\n" (lib.imap0 (idx: param: '' # 🦆 duck say ⮞ match positional paramz to script paramz by index
              if (( ${toString idx} < ''${#POSITIONAL[@]} )); then
                ${param.name}="''${POSITIONAL[${toString idx}]}" # 🦆 duck say ⮞ assign positional paramz to variable
              fi
            '') script.parameters)}
          # 🦆 duck say ⮞ assign named paramz! PARAMS ⮞ their variable
          ${concatStringsSep "\n" (map (param: ''
            if [[ -n "''${PARAMS[${param.name}]:-}" ]]; then
              ${param.name}="''${PARAMS[${param.name}]}"
            fi
          '') script.parameters)}

          # 🦆 duck say ⮞ count da paramz you cant bring too many to da party yo
          ${optionalString (script.parameters != []) ''
            if [ ''${#POSITIONAL[@]} -gt ${toString (length script.parameters)} ]; then
              echo -e "\033[1;31m 🦆 duck say ⮞ fuck ❌ Too many arguments (max ${toString (length script.parameters)})\033[0m" >&2
              exit 1
            fi
          ''}

          # 🦆 duck say ⮞ param type validation quuackidly quack yo
          ${concatStringsSep "\n" (map (param: 
            optionalString (param.type != "string") ''
              if [ -n "''${${param.name}:-}" ]; then
                case "${param.type}" in
                  int)
                    if ! [[ "''${${param.name}}" =~ ^[0-9]+$ ]]; then
                      echo -e "\033[1;31m 🦆 duck say ⮞ fuck ❌ ${name} --${param.name} must be integer\033[0m" >&2
                      exit 1
                    fi
                    ;;
                  path)
                    if ! [ -e "''${${param.name}}" ]; then
                      echo -e "\033[1;31m 🦆 duck say ⮞ fuck ❌ ${name} Path not found: ''${${param.name}}\033[0m" >&2
                      exit 1
                    fi
                    ;;
                  bool)
                    if ! [[ "''${${param.name}}" =~ ^(true|false)$ ]]; then
                      echo -e "\033[1;31m 🦆 duck say ⮞ fuck ❌ ${name} Parameter ${param.name} must be true or false\033[0m" >&2
                      exit 1
                    fi
                    ;;
                esac
              fi
            ''
          ) script.parameters)}


          # 🦆 duck say ⮞ values validation - explicit allowed list yo
          ${concatStringsSep "\n" (map (param: 
            optionalString (param.values != null && param.type == "string") ''
              if [ -n "''${${param.name}:-}" ]; then
                # 🦆 duck say ⮞ check if value is in allowed list
                allowed_values=(${lib.concatMapStringsSep " " (v: "'${lib.escapeShellArg v}'") param.values})
                value_found=false
                for allowed in "''${allowed_values[@]}"; do
                  if [[ "''${${param.name}}" == "$allowed" ]]; then
                    value_found=true
                    break
                  fi
                done
                if [[ "$value_found" == "false" ]]; then
                  echo -e "\033[1;31m 🦆 duck say ⮞ fuck ❌ ${name} --${param.name} must be one of: ${lib.concatStringsSep ", " param.values}\033[0m" >&2
                  exit 1
                fi
              fi
            ''
          ) script.parameters)}


          # 🦆 duck say ⮞ boolean defaults - false if not provided
          ${concatStringsSep "\n" (map (param: 
            optionalString (param.type == "bool" && param.default != null) ''
              if [[ -z "''${${param.name}:-}" ]]; then
                ${param.name}=${if param.default then "true" else "false"}
              fi
            '') script.parameters)}


          ${concatStringsSep "\n" (map (param: 
            optionalString (param.default != null) ''
              if [[ -z "''${${param.name}:-}" ]]; then
                ${param.name}=${
                  if param.type == "string" then 
                    "'${lib.escapeShellArg (toString param.default)}'" 
                  else if param.type == "int" then
                    "${toString param.default}"
                  else if param.type == "bool" then
                    (if param.default then "true" else "false")
                  else if param.type == "path" then
                    "'${lib.escapeShellArg (toString param.default)}'"
                  else
                    "'${lib.escapeShellArg (toString param.default)}'"
                }
              fi
            '') script.parameters)}
            
          # 🦆 duck say ⮞ checkz required param yo - missing? errorz out 
          ${concatStringsSep "\n" (map (param: ''
            ${optionalString (!param.optional && param.default == null) ''
              if [[ -z "''${${param.name}:-}" ]]; then
                echo -e "\033[1;31m 🦆 duck say ⮞ fuck ❌ ${name} Missing required parameter: ${param.name}\033[0m" >&2
                exit 1
              fi
            ''}
          '') script.parameters)}

          # 🦆 duck say ⮞ EXECUTEEEEEAAAOO 🦆quack🦆quack🦆quack🦆quack🦆quack🦆quack🦆quack🦆quack🦆quack🦆quack🦆quack🦆yo
          ${script.code}
        '';
        # 🦆 duck say ⮞ generate da entrypoint
        mainScript = pkgs.writeShellScriptBin "yo-${script.name}" scriptContent;
      in # 🦆 duck say ⮞ letz wrap diz up already  
        pkgs.runCommand "yo-script-${script.name}" {} ''
          mkdir -p $out/bin  # 🦆 duck say ⮞ symlinkz da main script
          ln -s ${mainScript}/bin/yo-${script.name} $out/bin/yo-${script.name} 
          ${concatMapStrings (alias: '' # 🦆 duck say ⮞ dont forget to symlinkz da aliases too yo!
            ln -s ${mainScript}/bin/yo-${script.name} $out/bin/yo-${alias}
          '') script.aliases}
        ''
    ) cfg.scripts; # 🦆 duck say ⮞ apply da logic to da yo scriptz
  };

  # 🦆 duck say ⮞ constructs GitHub "blob" URL based on `config.this.user.me.repo` 
  githubBaseUrl = let # 🦆 duck say ⮞ pattern match to extract username and repo name
    matches = builtins.match ".*github.com[:/]([^/]+)/([^/\\.]+).*" config.this.user.me.repo;
  in if matches != null then # 🦆 duck say ⮞ if match - construct
    "https://github.com/${builtins.elemAt matches 0}/${builtins.elemAt matches 1}/blob/main"
  else ""; # 🦆 duck say ⮞ no match? empty string

  # 🦆 duck say ⮞ build scripts for da --help command
  terminalScriptsTableFile = pkgs.writeText "yo-helptext.md" terminalScriptsTable;
  # 🦆 duck say ⮞ markdown help text
  terminalScriptsTable = let # 🦆 duck say ⮞ categorize scripts
    groupedScripts = lib.groupBy (script: script.category) (lib.attrValues cfg.scripts);
    # 🦆 duck say ⮞ sort da scriptz by category
    visibleScripts2 = lib.filterAttrs (_: script: script.visibleInReadme) cfg.scripts;
    groupedScripts2 = lib.groupBy (script: script.category) (lib.attrValues visibleScripts2);
    sortedCategories2 = lib.sort (a: b: 
      # 🦆 duck say ⮞ system management goes first yo
      if a == "🖥️ System Management" then true
      else if b == "🖥️ System Management" then false
      else a < b # 🦆 duck say ⮞ after dat everything else quack quack
    ) (lib.attrNames groupedScripts2);
  
    # 🦆 duck say ⮞ create table rows with category separatorz 
    rows = lib.concatMap (category:
      let  # 🦆 duck say ⮞ sort from A to Ö  
        scripts = lib.sort (a: b: a.name < b.name) groupedScripts.${category};
      in
        [ # 🦆 duck say ⮞ add **BOLD** header table row for category
          "| **${escapeMD category}** | | |"
        ] 
        ++ # 🦆 duck say ⮞ each yo script goes into a table row
        (map (script:
          let # 🦆 duck say ⮞ format list of aliases
            aliasList = if script.aliases != [] then
              concatStringsSep ", " (map escapeMD script.aliases)
            else "";
            # 🦆 duck say ⮞ generate CLI parameter hints, with [] for optional/defaulted
            paramHint = concatStringsSep " " (map (param:
              if param.optional || param.default != null
              then "[--${param.name}]"
              else "--${param.name}"
            ) script.parameters);
            # 🦆 duck say ⮞ render yo script syntax with param
            syntax = "\\`yo ${escapeMD script.name} ${paramHint}\\`";
          in # 🦆 duck say ⮞ write full md table row - command | aliases | description
            "| ${syntax} | ${aliasList} | ${escapeMD script.description} |"
        ) scripts)
    ) sortedCategories2;
  in concatStringsSep "\n" rows;


  # 🦆 duck say ⮞ count GENERATED regex patterns (the ~800 count)
  countGeneratedPatterns = script:
    if script.voice == null then
      0
    else
      let # 🦆 duck say ⮞ expand sentence variants with optional wordz
        expandedSentences = lib.concatMap expandOptionalWords script.voice.sentences;
      in
        lib.length expandedSentences;
  
  # 🦆 duck say ⮞ count phrase coverage  
  countUnderstoodPhrases = script:
    if script.voice == null then
      0
    else
      let # 🦆 duck say ⮞ expand sentence variants with optional wordz
        expandedSentences = lib.concatMap expandOptionalWords script.voice.sentences;   
        # 🦆 duck say ⮞ extract parameter names from sentences
        extractParamNames = sentence:
          let # 🦆 duck say ⮞ split by { to find parameters
            parts = lib.splitString "{" sentence;
            paramNames = lib.concatMap (part:
              let
                paramPart = lib.splitString "}" part;
              in
                if lib.length paramPart > 1 then
                  [ (lib.elemAt paramPart 0) ]
                else
                  []
            ) (lib.tail parts); # 🦆 says ⮞ skip the first part (before first {)
          in
            paramNames; 
        # 🦆 says ⮞ count parameter combinations for each expanded sentence
        countPhrasesForSentence = sentence:
          let
            paramNames = extractParamNames sentence;
          in
            if paramNames == [] then
              1
            else
              let # 🦆 duck say ⮞ count possible values for each parameter
                paramValueCounts = map (paramName:
                  let
                    list = script.voice.lists.${paramName} or null;
                  in
                    if list == null then 1
                    else lib.length list.values
                ) paramNames;           
                # 🦆 duck say ⮞ multiply counts for all parameters
                totalCombinations = lib.foldl (a: b: a * b) 1 paramValueCounts;
              in
                totalCombinations; 
        # 🦆 duck say ⮞ sum phrases across all expanded sentences
        totalPhrases = lib.foldl (total: sentence:
          total + countPhrasesForSentence sentence
        ) 0 expandedSentences;
      in
        totalPhrases;
  
  # 🦆 duck say ⮞ count generated patterns
  countTotalGeneratedPatterns = scripts:
    lib.foldl (total: script: 
      total + countGeneratedPatterns script
    ) 0 (lib.attrValues scripts);
  
  # 🦆 duck say ⮞ count phrases across all scriptz  
  countTotalUnderstoodPhrases = scripts:
    lib.foldl (total: script: 
      total + countUnderstoodPhrases script
    ) 0 (lib.attrValues scripts);
  
  # 🦆 duck say ⮞ quack! da duck take a list of listz and duck make all da possible combinationz
  cartesianProductOfLists = lists:
    # 🦆 duck say ⮞ if da listz iz empty .. 
    if lists == [] then
      [ [] ] # 🦆 duck say ⮞ .. i gib u empty listz of listz yo got it?
    else # 🦆 duck say ⮞ ELSE WAT?!
      let # 🦆 duck say ⮞ sorry.. i gib u first list here u go yo
        head = builtins.head lists;
        # 🦆 duck say ⮞ remaining listz for u here u go bro!
        tail = builtins.tail lists;
        # 🦆 duck say ⮞ calculate combinations for my tail - yo calc wher u at?!
        tailProduct = cartesianProductOfLists tail;
      in # 🦆 duck say ⮞ for everyy x in da listz ..
        lib.concatMap (x:
          # 🦆 duck say ⮞ .. letz combinez wit every tail combinationz ..  
          map (y: [x] ++ y) tailProduct
        ) head; # 🦆 duck say ⮞ dang! datz a DUCK COMBO alright!
  
  # 🦆 duck say ⮞ here i duckie help yo out! makin' yo life eazy sleazy' wen declarative sentence yo typin'    
  expandOptionalWords = sentence: # 🦆 duck say ⮞ qucik & simple sentences we quacky & hacky expandin'
    let # 🦆 duck say ⮞ CHOP CHOP! Rest in lil' Pieceez bigg sentence!!1     
      tokens = lib.splitString " " sentence;      
      # 🦆 duck say ⮞ definin' dem wordz in da (braces) taggin' dem' wordz az (ALTERNATIVES) lettin' u choose one of dem wen triggerin' 
      isRequiredGroup = t: lib.hasPrefix "(" t && lib.hasSuffix ")" t;
      # 🦆 duck say ⮞ puttin' sentence wordz in da [bracket] makin' em' [OPTIONAL] when bitchin' u don't have to be pickin' woooho 
      isOptionalGroup = t: lib.hasPrefix "[" t && lib.hasSuffix "]" t;   
      expandToken = token: # 🦆 duck say ⮞ dis gets all da real wordz out of one token (yo!)
        if isRequiredGroup token then
          let # 🦆 duck say ⮞ thnx 4 lettin' ducklin' be cleanin' - i'll be removin' dem "()" 
            clean = lib.removePrefix "(" (lib.removeSuffix ")" token);
            alternatives = lib.splitString "|" clean; # 🦆 duck say ⮞ use "|" to split (alternative|wordz) yo 
          in  # 🦆 duck say ⮞ dat's dat 4 dem alternativez
            alternatives
        else if isOptionalGroup token then
          let # 🦆 duck say ⮞ here we be goin' again - u dirty and i'll be cleanin' dem "[]"
            clean = lib.removePrefix "[" (lib.removeSuffix "]" token);
            alternatives = lib.splitString "|" clean; # 🦆 duck say ⮞ i'll be stealin' dat "|" from u 
          in # 🦆 duck say ⮞ u know wat? optional means we include blank too!
            alternatives ++ [ "" ]
        else # 🦆 duck say ⮞ else i be returnin' raw token for yo
          [ token ];      
      # 🦆 duck say ⮞ now i gib u generatin' all dem combinationz yo
      expanded = cartesianProductOfLists (map expandToken tokens);      
      # 🦆 duck say ⮞ clean up if too much space, smush back into stringz for ya
      trimmedVariants = map (tokenList:
        let # 🦆 duck say ⮞ join with spaces then trim them suckers
          raw = lib.concatStringsSep " " tokenList;
          # 🦆 duck say ⮞ remove ALL extra spaces
          cleaned = lib.replaceStrings ["  "] [" "] (lib.strings.trim raw);
        in # 🦆 duck say ⮞ wow now they be shinin'
          cleaned 
      ) expanded; # 🦆 duck say ⮞ and they be multiplyyin'!      
      # 🦆 duck say ⮞ throwin' out da empty and cursed ones yo
      nonEmpty = lib.filter (s: s != "") trimmedVariants;
      hasFixedText = v: builtins.match ".*[^\\{].*" v != null; # 🦆 duck say ⮞ no no no, no nullin'
      validVariants = lib.filter hasFixedText nonEmpty;
    in # 🦆 duck say ⮞ returnin' all unique variantz of da sentences – holy duck dat'z fresh 
      lib.unique validVariants;

  # 🦆 duck say ⮞ generatez safe systemd timer namez
  makeTimerName = scriptName: timeStr:
    let
      safeTime = replaceStrings [":"] ["-"] timeStr;
    in
      "yo-${scriptName}-at-${safeTime}";

  
in { # 🦆 duck say ⮞ import server/client module
  imports = [ ./yo-rs.nix ];

  # 🦆 duck say ⮞ options options duck duck
  options = { # 🦆 duck say ⮞ quack 
    yo = {
      pkgs = mkOption {
        type = types.package;
        readOnly = true;
        description = "The final yo scripts package";
      }; # 🦆 duck say ⮞ yo scriptz optionz yo
      scripts = mkOption {
        type = types.attrsOf scriptType;
        default = {};
        description = "Attribute set of scripts to be made available";
      };
      sorryPhrases = mkOption {
        type = types.listOf types.str;
        default = [ 
          "Kompis du pratar japanska jag fattar ingenting"
          "Det låter som att du har en köttee bulle i käften. Ät klart middagen och försök sedan igen."
          "eeyyy bruscchan öppna käften innan du pratar ja fattar nada ju"
          "men håll käften cp!"
          "noll koll . Golf boll."
          "Ursäkta?"
        ];
        description = "List of phrases to be randomly picked for text-to-speect when no match is found during pattern matching.";
      };
      SplitWords = mkOption {
        type = types.listOf types.str;
        default = [ "samt" ];
        example = [ "and" "also" ];
        description = "List of words that is used for command chaining.";
      };            
      wakeWord = mkOption {
        type = types.nullOr types.path;
        default = null;
        apply = p:
          if p == null || lib.hasSuffix ".tflite" (toString p)
          then p
          else throw "yo.voice.wakeWord must be null or a .tflite file";
        example = "/etc/yo/wake_word_model.tflite";
        description = "Optional path to the .tflite wake word model file.";
      }; # 🦆 duck say ⮞ generated regex patterns count
      generatedPatterns = mkOption {
        type = types.int;
        readOnly = true;
        description = "Number of regex patterns generated at build time";
      }; # 🦆 duck say ⮞ count nlp phrases understood  
      understandsPhrases = mkOption {
        type = types.int;
        readOnly = true;
        description = "Theoretical number of unique spoken phrases the system can understand";
      };
    };
  };  
  
  # 🦆 ⮞ CONFIG  🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆🦆
  config = {  # 🦆 duck say ⮞ expose diz module and all yo.scripts as a package  
    yo.pkgs = yoScriptsPackage; # 🦆 duck say ⮞ reference as: ${config.pkgs.yo}/bin/yo-<name>
    # 🦆 duck say ⮞ set global counterz
    yo.generatedPatterns = countTotalGeneratedPatterns cfg.scripts;
    yo.understandsPhrases = countTotalUnderstoodPhrases cfg.scripts;

    # 🦆 ⮞  SAFETY ASSERTIONS  ⮜ 🦆
    assertions = let # 🦆 ⮞ safety first
      scripts = cfg.scripts;
      scriptNames = attrNames scripts;    
      
      # 🦆 duck say ⮞ runAt scripts need default values on required paramz
      runAtErrors = lib.mapAttrsToList (name: script:
        if script.runAt != null then
          let
            missingParams = lib.filter (p: !p.optional && p.default == null) script.parameters;
          in
            if missingParams != [] then
              "🦆 duck say ⮞ fuck ❌ Cannot schedule '${name}' at ${script.runAt} - missing defaults for: " +
              lib.concatMapStringsSep ", " (p: p.name) missingParams
            else null
        else null
      ) scripts;
      actualRunAtErrors = lib.filter (e: e != null) runAtErrors;
            
      # 🦆 duck say ⮞ quackin' flappin' mappin' aliasez ⮞ script dat belong to it 
      aliasMap = lib.foldl' (acc: script:
        lib.foldl' (acc': alias:
          acc' // { 
            ${alias} = (acc'.${alias} or []) ++ [script.name]; # 🦆 duck say ⮞ mmerge or start a list yo
          }
        ) acc script.aliases
      ) {} (attrValues scripts);
      # 🦆 duck say ⮞ find conflicts between script names & script aliases
      scriptNameConflicts = lib.filterAttrs (alias: _: lib.elem alias scriptNames) aliasMap;  
      # 🦆 duck say ⮞ find dem' double aliasez 
      duplicateAliases = lib.filterAttrs (_: scripts: lib.length scripts > 1) aliasMap;
      # 🦆 duck say ⮞ build da alias conflict error msg
      formatConflict = alias: scripts: 
        "Alias '${alias}' conflicts with script name (used by: ${lib.concatStringsSep ", " scripts})";       
      # 🦆 duck say ⮞ build da double rainbowz error msg yo
      formatDuplicate = alias: scripts: 
        "Alias '${alias}' used by multiple scripts: ${lib.concatStringsSep ", " scripts}";
      # 🦆 duck say ⮞ find auto-start scriptz - if i find i make sure it haz default values for all required paramz
      autoStartErrors = lib.mapAttrsToList (name: script:
        if script.autoStart then
          let # 🦆 duck say ⮞ filter dem not optional no defaultz
            missingParams = lib.filter (p: !p.optional && p.default == null) script.parameters;
          in
            if missingParams != [] then
              "🦆 duck say ⮞ fuck ❌ Cannot auto-start '${name}' - missing defaults for: " +
              lib.concatMapStringsSep ", " (p: p.name) missingParams
            else null
        else null
      ) scripts;    
      
      nonInteractiveErrors = lib.mapAttrsToList (name: script:
        if script.autoStart || script.runEvery != null then
          let
            missingParams = lib.filter (p: !p.optional && p.default == null) script.parameters;
          in
            if missingParams != [] then
              "🦆 duck say ⮞ fuck ❌ Cannot schedule '${name}' - missing defaults for: " +
              lib.concatMapStringsSep ", " (p: p.name) missingParams
            else null
        else null
      ) scripts;      
      # 🦆 duck say ⮞ clean out dem' nullz! no nullz in ma ASSertionthz! ... quack
      actualAutoStartErrors = lib.filter (e: e != null) autoStartErrors;   
      # 🦆 duck say ⮞ Validate da shit out of 'value' option quack! only allowed wit string type yo!
      valueTypeErrors = lib.concatMap (script:
        lib.concatMap (param:
          if param.values != null && param.type != "string" then
            [ "🦆 duck say ⮞ fuck ❌ Parameter '${param.name}' in script '${script.name}' has 'value' defined but type is '${param.type}' (only 'string' type allowed)" ]
          else []
        ) script.parameters
      ) (lib.attrValues scripts);
    in [
      { # 🦆 duck say ⮞ assert no alias name cpmflict with script name 
        assertion = scriptNameConflicts == {};
        message = "🦆 duck say ⮞ fuck ❌ Alias/script name conflicts:\n" +
          lib.concatStringsSep "\n" (lib.mapAttrsToList formatConflict scriptNameConflicts);
      }
      { # 🦆 duck say ⮞ make sure dat aliases unique are yo
        assertion = duplicateAliases == {};
        message = "🦆 duck say ⮞ fuck ❌ Duplicate aliases:\n" +
          lib.concatStringsSep "\n" (lib.mapAttrsToList formatDuplicate duplicateAliases);
      }
      { # 🦆 duck say ⮞ autoStart scriptz must be fully configured of course!
        assertion = actualAutoStartErrors == [];
        message = "Auto-start errors:\n" + lib.concatStringsSep "\n" actualAutoStartErrors;
      }  
      { # 🦆 duck say ⮞ runAt script fully configured?
        assertion = actualRunAtErrors == [];
        message = "runAt scheduling errors:\n" + lib.concatStringsSep "\n" actualRunAtErrors;
      }      
      { # 🦆 duck say ⮞ runEvery OR runAt NOT BOTH
        assertion = lib.all (script: 
          !(script.runEvery != null && script.runAt != null)
        ) (lib.attrValues scripts);
        message = "🦆 duck say ⮞ fuck ❌ Script cannot have both runEvery and runAt set";
      }
      { # 🦆 duck say ⮞ value option only 4 strings i said!
        assertion = valueTypeErrors == [];
        message = "Value type errors:\n" + lib.concatStringsSep "\n" valueTypeErrors;
      }
    ];
    # 🦆 duck say ⮞ TODO replace with: system.activationScripts.update-readme.text = "${updateReadme}/bin/update-readme";

    environment.systemPackages = [
      config.yo.pkgs
      pkgs.glow # 🦆 duck say ⮞ For markdown renderin' in da terminal
      (pkgs.writeShellScriptBin "yo" ''
        #y!${pkgs.runtimeShell}
        set -o noglob # 🦆 duck say ⮞ help command data (
        script_dir="${yoScriptsPackage}/bin" 
        # 🦆 duck say ⮞ help command data (yo --help
        show_help() {
          #width=$(tput cols) # 🦆 duck say ⮞ Auto detect width
          width=130 # 🦆 duck say ⮞ fixed width
          cat <<EOF | ${pkgs.glow}/bin/glow --width $width -
        ## ──────⋆⋅☆☆☆⋅⋆────── ##
        ## 🦆🚀 **yo CLI** 🦆🦆 
        ## 🦆 duck say ⮞ quack! i help with scripts yo
        **Usage:** \`yo <command> [arguments]\`
        ## ──────⋆⋅☆☆☆⋅⋆────── ##
        ## 🦆✨ Available Commands
        Parameters inside brackets are [optional]
        | Command Syntax               | Aliases    | Description |
        |------------------------------|------------|-------------|
        ${terminalScriptsTable}
        ## ──────⋆⋅☆☆☆⋅⋆────── ##
        ## 🦆❓ Detailed Help
        For specific command help: \`yo <command> --help\`
        \`yo do --help\` will list all defined voice intents.
        \`yo zigduck --help\` will display a battery status report for your deevices.
        🦆🦆
        EOF
          exit 0
        } # 🦆 duck say ⮞ handle zero args           
        if [[ $# -eq 0 ]]; then
          show_help
          exit 1
        fi
        # 🦆 duck say ⮞ parse da command
        case "$1" in # 🦆 duck say ⮞ handle zero args "-h" & "--help" to show da help
          -h|--help) show_help; exit 0 ;;
          *) command="$1"; shift ;;
        esac

        script_path="$script_dir/yo-$command"
        if [[ -x "$script_path" ]]; then
          exec "$script_path" "$@"
        else
          # 🦆 duck say ⮞ TODO FuzzYo commands! but until then..
          echo -e "\033[1;31m 🦆 duck say ⮞ fuck ❌ $1\033[0m Error: Unknown command '$command'" >&2
          show_help
          exit 1
        fi
      '')
      yoScriptsPackage
    ];

    # 🦆 duck say ⮞ buildz systemd services    
    systemd.services = lib.mkMerge [
      # 🦆 duck say ⮞ if `autoStart` is set
      (lib.mapAttrs' (name: script:
        lib.nameValuePair "yo-${name}" (mkIf script.autoStart {
          enable = true;
          wantedBy = ["multi-user.target"];
          after = ["sound.target" "network.target" "pulseaudio.socket" "sops-nix.service"];
    
          serviceConfig = {
            ExecStart = let
              args = lib.concatMapStringsSep " " (param:
                "--${param.name} ${lib.escapeShellArg param.default}"
              ) (lib.filter (p: p.default != null) script.parameters);
            in "${yoScriptsPackage}/bin/yo-${name} ${args}";
            User = config.this.user.me.name;
            Group = "audio";
            RestartSec = 45;
            Restart = "on-failure";
            Environment = [
              "XDG_RUNTIME_DIR=${
                if config.this.host.hostname == "desktop" then "/run/user/1000"
                else if config.this.host.hostname == "homie" then "/run/user/1002"
                else if config.this.host.hostname == "nasty" then "/run/user/1000"
                else "/run/user/1000"
              }"
              "PULSE_SERVER=unix:%t/pulse/native"
              "HOME=/home/${config.this.user.me.name}"
              "PATH=/run/current-system/sw/bin:/bin:/usr/bin:${pkgs.binutils-unwrapped}/bin:${pkgs.coreutils}/bin"
            ];
          };
        })
      ) cfg.scripts)
    
      # 🦆 duck say ⮞ if `runEvery` is set 
      (lib.mapAttrs' (name: script:
        lib.nameValuePair "yo-${name}-periodic" (mkIf (script.runEvery != null) {
          enable = true;
          description = "Periodic execution of yo.${name}";
          serviceConfig = {
            Type = "oneshot";
            User = config.this.user.me.name;
            Group = config.this.user.me.name;
            Environment = [                        
              "HOME=/home/${config.this.user.me.name}"
              "PATH=/run/current-system/sw/bin:/bin:/usr/bin:${pkgs.binutils-unwrapped}/bin:${pkgs.coreutils}/bin"
            ];  
            ExecStart = let
              args = lib.concatMapStringsSep " " (param:
                "--${param.name} ${lib.escapeShellArg param.default}"
              ) (lib.filter (p: p.default != null) script.parameters);
            in "${yoScriptsPackage}/bin/yo-${name} ${args}";
          };
        })
      ) cfg.scripts)
      
      # 🦆 duck say ⮞ if `runAt` is set: one service that can be triggered by multiple timerz
      (lib.mapAttrs' (name: script:
        lib.nameValuePair "yo-${name}-scheduled" (mkIf (script.runAt != null) {
          enable = true;
          description = let
            # 🦆 duck say ⮞ create human-readable time list
            timesFormatted = if script.runAt != null then
              lib.concatStringsSep ", " script.runAt
            else "";
            # 🦆 duck say ⮞ include script description if available
            baseDesc = if script.description != "" then
              "${script.description} (scheduled at ${timesFormatted})"
            else
              "Scheduled execution of yo.${name} at ${timesFormatted}";
          in baseDesc;
          serviceConfig = {
            Type = "oneshot";
            User = config.this.user.me.name;
            Group = config.this.user.me.name;
            Environment = [                        
              "HOME=/home/${config.this.user.me.name}"
              "PATH=/run/current-system/sw/bin:/bin:/usr/bin:${pkgs.binutils-unwrapped}/bin:${pkgs.coreutils}/bin"
            ];  
            ExecStart = let
              args = lib.concatMapStringsSep " " (param:
                "--${param.name} ${lib.escapeShellArg param.default}"
              ) (lib.filter (p: p.default != null) script.parameters);
            in "${yoScriptsPackage}/bin/yo-${name} ${args}";
          };
        })
      ) cfg.scripts)
    ];

    # 🦆 duck say ⮞ systemd timer configuration
    systemd.timers = lib.mkMerge [  
      # 🦆 duck say ⮞ if `runEvery` is configured 
      (lib.mapAttrs' (name: script:
        lib.nameValuePair "yo-${name}-periodic" (mkIf (script.runEvery != null) {
          enable = true;
          wantedBy = ["timers.target"];
          timerConfig = {
            OnCalendar = "*-*-* *:0/${script.runEvery}";
            Unit = "yo-${name}-periodic.service";
            Persistent = true;
          };
        })
      ) cfg.scripts)
      
      # 🦆 duck say ⮞ if `runAt` is configured: one timer per scheduled time
      (lib.foldl' lib.recursiveUpdate {} (lib.mapAttrsToList (name: script:
        if script.runAt != null then
          lib.listToAttrs (lib.map (timeStr:
            lib.nameValuePair (makeTimerName name timeStr) {
              enable = true;
              wantedBy = ["timers.target"];
              timerConfig = {
                OnCalendar = "*-*-* ${timeStr}:00";
                Unit = "yo-${name}-scheduled.service";
                Persistent = true;
              };
            }
            ) script.runAt)
        else {}
      ) cfg.scripts))
    ];
  };} # 🦆 duck say ⮞ 2 long module 4 jokez.. bai bai yo
# 🦆 says ⮞ QuackHack-McBLindy out!
# ... 🛌🦆💤
