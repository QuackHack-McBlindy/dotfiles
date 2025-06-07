# dotfiles/bin/network/suno.nix
{ 
  self,
  config,
  pkgs,
  cmdHelpers,
  ...
} : {  
  yo.bitch = { 
    intents = {
      suno = {
        data = [{
          sentences = [
            "skapa en {prompt} låt om {genre}"
            "generera en {prompt} låt om {genre}"
            "gör en {prompt} låt om {genre}"
            "fixa en {prompt} låt om {genre}"
          ];        
          lists = {
            genre.values = [
              { "in" = "hiphop"; out = "hip-hop"; }
              { "in" = "hip-hop"; out = "hip-hop"; }
              { "in" = "hipphopp"; out = "hip-hop"; }          
              { "in" = "rap"; out = "rap"; }     
              { "in" = "rapp"; out = "rap"; }  
              { "in" = "pop"; out = "pop"; }
              { "in" = "popp"; out = "pop"; }    
              { "in" = "rock"; out = "rock"; }   
              { "in" = "deathmetal"; out = "death metal"; }
              { "in" = "dödsmetal"; out = "death metal"; }
              { "in" = "dödsmetall"; out = "death metal"; }  
              { "in" = "heavy metal"; out = "heavy metal"; }   
              { "in" = "heavymetal"; out = "heavy metal"; }   
              { "in" = "heavymetall"; out = "heavy metal"; }   
              { "in" = "tungmetall"; out = "heavy metal"; }   
              { "in" = "tung metall"; out = "heavy metal"; }          
              { "in" = "metal"; out = "metal"; }       
              { "in" = "metall"; out = "metal"; }
              { "in" = "dubstep"; out = "dubstep"; }
              { "in" = "techo"; out = "techno"; }     
              { "in" = "tekno"; out = "techno"; }                  
              { "in" = "blues"; out = "blues"; }
              { "in" = "blue"; out = "blues"; }
              { "in" = "blå"; out = "blues"; }
              { "in" = "tjill"; out = "chill"; }                  
              { "in" = "chill"; out = "chill"; }                 
            ];
            prompt.wildcard = true;
          };
        }];
      };
    };
  };

  yo.scripts.suno = {
    description = "AI generated lyrics and music files powered by Suno";
    category = "🧩 Miscellaneous";
    aliases = [ "mg" ];
#    helpFooter = ''
#    '';
    parameters = [
      { name = "prompt"; description = "Prompt to be used for the generated lyrics"; optional = true; }    
      { name = "genre"; description = "Music genre type for the generated song"; }

    ];
    code = ''
      ${cmdHelpers}

      echo "Genre input: "
      echo "$genre"
      echo " ---- "
      echo "Prompt input: "
      echo "$prompt"
      
      # Step 1 Create title

      # Step 2 Create lyrics from input
      # max 2000 characters from duckai
      # Response back it to duckai for final polish
    
      # Step 2 Send to suno
      echo "Sending API request to Suno: "
      echo "🎶🏷️ Title: "
      echo "$final_title"
      echo "🎸🎷 Genre: "
#      echo "$final_genre"
      echo " ---- "
      echo "💬📜 Lyrics: "
#      echo "$final_prompt"
      
      # TODO Suno logic
      
    '';
  };}
