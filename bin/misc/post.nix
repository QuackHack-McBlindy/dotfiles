# dotfiles/bin/misc/post.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ Check next postal delivery
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ...
} : let
in {  
  yo.bitch = { 
    intents = {
      post = {
        priority = 3;
        data = [{
          sentences = [
            "när kommer posten"
            "när kommer [nästa] post (leverans|leveransen)"
            "vilken dag kommer posten"
          ];        
        }];
      };      
    };
  };

  yo.scripts.post = {
    description = "Search for the next postal delivery day is in Sweden";
    category = "🧩 Miscellaneous";
    parameters = [  
      { name = "postalCodeFile"; description = "Path to a file containing the postal code to search for"; default = config.sops.secrets.zipcode.path;  }   
      { name = "postalCode"; description = "Postal code to search for";  }       
    ];
    code = ''
      ${cmdHelpers}
      POSTAL_CODE_FILE="$postalCodeFile"
      POSTALCODE="$postalCode"
      if [[ -z "$POSTALCODE" ]]; then
        POSTAL_CODE=$(cat "$POSTAL_CODE_FILE")
      else
        POSTAL_CODE="$POSTALCODE"
      fi
      
      JSON=$(curl -s "https://portal.postnord.com/api/sendoutarrival/closest?postalCode=''${POSTAL_CODE}")
      DELIVERY=$(jq -r '.delivery' <<<"$JSON" | tr '[:upper:]' '[:lower:]' | tr -d ',')
      UPCOMING=$(jq -r '.upcoming' <<<"$JSON" | tr '[:upper:]' '[:lower:]' | tr -d ',')

      declare -A MONTHS_SV_EN=(
        [januari]="January" [februari]="February" [mars]="March" [april]="April"
        [maj]="May" [juni]="June" [juli]="July" [augusti]="August"
        [september]="September" [oktober]="October" [november]="November" [december]="December"
      )

      DELIVERY_EN="$DELIVERY"
      UPCOMING_EN="$UPCOMING"

      for SV in "''${!MONTHS_SV_EN[@]}"; do
        DELIVERY_EN="''${DELIVERY_EN//$SV/''${MONTHS_SV_EN[$SV]}}"
        UPCOMING_EN="''${UPCOMING_EN//$SV/''${MONTHS_SV_EN[$SV]}}"
      done

      DELIVERY_DATE=$(date -d "$DELIVERY_EN" +%F 2>/dev/null)
      UPCOMING_DATE=$(date -d "$UPCOMING_EN" +%F 2>/dev/null)

      TODAY=$(date +%F)
      TOMORROW=$(date -d "+1 day" +%F)

      if [[ "$DELIVERY_DATE" == "$TODAY" ]]; then
        MESSAGE1="Nästa post leverans är: Idag! den $DELIVERY"
      elif [[ "$DELIVERY_DATE" == "$TOMORROW" ]]; then
        MESSAGE1="Nästa post leverans är: Imorgon, den $DELIVERY"
      else
        MESSAGE1="Nästa post leverans är: $DELIVERY"
      fi

      MESSAGE2="Följande leverans är: $UPCOMING"

      dt_info "$MESSAGE1"
      dt_info "$MESSAGE2"
      if_voice_say "$MESSAGE1"
      sleep 1
      if_voice_say "$MESSAGE2"
    '';
  };
 
  sops.secrets = {
    zipcode = { # 🦆 says ⮞ quack, stupid!
      sopsFile = ./../../secrets/zipcode.yaml; 
      owner = config.this.user.me.name;
      group = config.this.user.me.name;
      mode = "0440"; # 🦆 says ⮞ Read-only for owner and group
    }; 
  };}
