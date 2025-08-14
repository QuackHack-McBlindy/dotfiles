# dotfiles/bin/productivity/calc.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ self, config, pkgs, cmdHelpers, ... }:
{
  yo = {
    scripts = {
      calculator = {
        description = "Calculate math expressions";
        category = "⚡ Productivity";
        aliases = [ "calc" ];
        helpFooter = ''
          ${cmdHelpers}
          echo "## ──────⋆⋅☆⋅⋆────── ##"
          echo "## 🧠 Usage Examples:"        
          echo '`yo calc "15 + 39 * 7"`'
          echo '`yo calc "5 x 2 / 3"`'    
          echo '`yo calc "19÷2*3"`'
          echo '`yo calc "sqrt(49)"`'
          echo "## ──────⋆⋅☆⋅⋆────── ##"        
        '';
        parameters = [{ name = "expression"; description = "A complete math expression as free text (e.g. '5 plus 3')"; optional = false; }];
        code = ''
          ${cmdHelpers}
          math="$expression"
          RED='\033[31m'
          RESET='\033[0m'
        
          # 🦆 duck say ⮞ swedish math words > math symbols
           math=$(echo "$math" \
            | sed -e 's/plus/+/g' \
              -e 's/minus/-/g' \
              -e 's/gånger/*/g' \
              -e 's/delat med/\//g' \
              -e 's/roten ur/sqrt/g' \
              -e 's/÷/\//g' \
              -e 's/[xX]/\*/g' \
              -e 's/komma/./g' \
          )

          # 🦆 duck say ⮞ replace any divide symbol with slash
          math=$(echo "$math" | sed 's/÷/\//g')
  
          # 🦆 duck say ⮞ x is a star if it's betweeb duguts or spaces yo
          math=$(echo "$math" | sed -E -e 's/([0-9]) *[xX] *([0-9])/\1*\2/g' -e 's/^ *[xX] *([0-9])/*\1/g' -e 's/([0-9]) *[xX] *$/\1*/g')
    
          # 🦆 duck say ⮞ convert swedish number words to digits
          swedish_to_digits() {
            local input="$1"
            # 🦆 duck say ⮞ remove any "-" & spaces & go small letters - no yelling in here yo
            input=$(echo "$input" | tr '-' ' ' | sed 's/ //g' | tr '[:upper:]' '[:lower:]')
            
            # 🦆 duck say ⮞ define number word mappings (0-19, tens, hundreds, thousands)
            declare -A word_map=(
              ["noll"]=0 ["en"]=1 ["ett"]=1 ["två"]=2 ["tre"]=3 ["fyra"]=4 ["fem"]=5 
              ["sex"]=6 ["sju"]=7 ["åtta"]=8 ["nio"]=9 ["tio"]=10 ["elva"]=11 ["tolv"]=12 
              ["tretton"]=13 ["fjorton"]=14 ["femton"]=15 ["sexton"]=16 ["sjutton"]=17 
              ["arton"]=18 ["nitton"]=19 ["tjugo"]=20 ["trettio"]=30 ["fyrtio"]=40 
              ["femtio"]=50 ["sextio"]=60 ["sjuttio"]=70 ["åttio"]=80 ["nittio"]=90
              ["hundra"]=100 ["hundraen"]=101 ["hundraett"]=101 ["tvåhundra"]=200
              ["trehundra"]=300 ["fyrahundra"]=400 ["femhundra"]=500 ["sexhundra"]=600
              ["sjuhundra"]=700 ["åttahundra"]=800 ["niohundra"]=900 ["tusen"]=1000
              ["tusenen"]=1001 ["tusenett"]=1001 ["tvåtusen"]=2000 ["tretusen"]=3000
              ["fyratusen"]=4000 ["femtusen"]=5000 ["sextusen"]=6000 ["sjutusen"]=7000
              ["åttatusen"]=8000 ["niotusen"]=9000
            ) # 🦆 duck say ⮞ wow .. bleh
            
            # 🦆 duck say ⮞ extract keys sorted by longest first for greedy matchin' yo
            keys=$(for key in "''${!word_map[@]}"; do echo "$key"; done | awk '{ print length, $0 }' | sort -rn | cut -d" " -f2-)           
            local result=0
            local temp_str="$input"
            local matched           
            # 🦆 duck say ⮞ duckie likes a full string - translates thong yo
            if [ -z "$temp_str" ]; then
              echo 0
              return 0
            fi
            
            # 🦆 duck say ⮞ process da thong by matching long thong token 1st yo
            while [ -n "$temp_str" ]; do
                matched=0
                for key in $keys; do
                    if [[ "$temp_str" == "$key"* ]]; then
                        (( result += ''${word_map[$key]} ))
                        temp_str="''${temp_str:''${#key}}" # 🦆 duck say ⮞ temporary thong? lolz
                        matched=1
                        break
                    fi
                done
                if [ $matched -eq 0 ]; then
                    # 🦆 duck say ⮞ handle compound numbers yo
                    if [[ "$temp_str" =~ ^([a-zåäö]+)([0-9]+)$ ]]; then
                        # 🦆 duck say ⮞ digits? why we even doin' dis?
                        break
                    else
                        say_duck "fuck ❌ Unrecognized number word: $temp_str" # 🦆 duck say ⮞ i said no to dat shit alreddy yo
                        exit 1
                    fi
                fi
            done
         
            echo "$result" # 🦆 duck say ⮞ phew.. oh noe.. barely started yo
          }
          
          # 🦆 duck say ⮞ protect yo func yo
          math=$(echo "$math" | sed 's/sqrt/__SQRT__/g')       
          # 🦆 duck say ⮞ digits! yeaah
          new_math=""
          temp_math="$math" # 🦆 duck say ⮞ dis is how duckie likes da mmath 
          while [[ -n "$temp_math" ]]; do
              # 🦆 duck say ⮞ match math - matcha matte as we ducks say  
              if [[ "$temp_math" =~ ^[a-zåäö]+ ]]; then
                  token="''${BASH_REMATCH[0]}"
                  number=$(swedish_to_digits "$token") || {
                      say_duck "fuck ❌ Failed to convert number word: $token"
                      exit 1 # 🦆 duck say ⮞ foolproof - dont worr? 
                  }
                  new_math+="$number"
                  temp_math="''${temp_math:''${#token}}"
              else
                  # digi char, is dat a pokemon???
                  char="''${temp_math:0:1}"
                  new_math+="$char"
                  temp_math="''${temp_math:1}"
              fi
          done
          
          math="$new_math" # 🦆 duck say ⮞ all dis for voice..... and cuz ducks cant count on fingerz
          
          # 🦆 duck say ⮞ throw off da condom func yo
          math=$(echo "$math" | sed 's/__SQRT__/sqrt/g')    
          
          # 🦆 duck say ⮞ only allow dis charz4grep
          allowed='^[-0-9+*/().^ %a-z]+$'    
  
          # 🦆 duck say ⮞ allow char no regex and no poké =(
          allowed_chars='-0-9+*/().^ %sqrtd'

          # 🦆 duck say ⮞ input sanitization
          if ! echo "$math" | grep -Eq "$allowed"; then
            # 🦆 duck say ⮞ find invalid characters by removing allowed ones
            invalid_chars=$(echo "$math" | sed "s/[$allowed_chars]//g" | fold -w1 | sort | uniq | tr -d '\n')
            say_duck "fuck ⛔ Invalid characters in math expression: ''${RESET}[''${RED}$invalid_chars''${RESET}]"
            exit 1
          fi
        
          # 🦆 duck say ⮞ calculate math using bc
          result=$(echo "$math" | ${pkgs.bc}/bin/bc -l)
        
          # 🦆 duck say ⮞ check if bc returned a result
          if [ $? -ne 0 ]; then
            # 🦆 duck say ⮞  if not - then
            say_duck "fuck ❌ Invalid math expression."
            exit 1
          fi

          # 🦆 duck say ⮞ format result to more duck readable output
          formatted_result=$(echo "$result" | sed -E 's/(\.[0-9]{3})[0-9]+$/\1/; s/(\.[0-9]*[1-9])0+$/\1/; s/\.0+$//')

          # 🦆 duck say ⮞ all good? ok, provide da quackidy quack answer yo!
          say_duck "$(bold "Answer:") $formatted_result"
          if_voice_say "Svaret är $formatted_result"
        '';
        voice = {
          sentences = [
            "(beräkna|beräknar|räkna|räknar) [ut] {expression}"
            "(beräkna|beräknar|räkna|räknar) ut {expression}"
            "lös ekvationen {expression}"
          ];
          lists = {
            expression.wildcard = true;
          };
        };  
      };
    };   
   
  };}
