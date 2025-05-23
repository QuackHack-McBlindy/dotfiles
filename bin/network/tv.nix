# dotfiles/bin/network/shield.nix
{ self, config, pkgs, cmdHelpers, ... }:
{  
  yo.bitch = {
    language = "sv";
    
    intents = {
      shield = {
        data = [{
          sentences = [
            "kör igång {typ} {search}"
#            "(spel|spell|spela|spera) upp {typ} {search}"
#            "(spel|spell|spela|spera) [upp] {typ} {search}"
#            "(start|starta|startar) {typ} {search}"
#            "jag vill se {typ} {search}"
#            "kör igång {typ} {search}"
#            "spel upp {typ} {search}"
#            "spell upp {typ} {search}"
#            "spela upp {typ} {search}"
#            "spera upp {typ} {search}"
#            "spela {typ} {search}"
#            "start {typ} {search}"
#            "starta {typ} {search}"
#            "startar {typ} {search}"
#            "jag vill se {typ} {search}"
#            "starta {search}"

          ];
          lists = {
            search.wildcard = true;
#            typ.values = [
#              { "in" = "serien|vserien|tv-serien)"; out = "tv"; }
#              { "in" = "(podd|pod|podcast)"; out = "podcast"; }
#              { "in" = "(slump|slumpa|random|musik)"; out = "jukebox"; }
#              { "in" = "(artist|artisten|band|bandet|grupp|gruppen)"; out = "music"; }
#              { "in" = "(låt|låten|sång|sången|biten)"; out = "song"; }
#            ];
          };
        }];
      };
    };
  };


  yo.scripts.shield = {
    description = "Android TV Controller";
    intent = "shield";
    category = "🌐 Networking";
    aliases = [ "s" "tv" ];
#    helpFooter = ''
#    '';
    parameters = [
      { name = "search"; description = "Media to search and play"; optional = false; }
      { name = "typ"; description = "Media type"; default = "tv"; } 
    ];
    code = ''
      ${cmdHelpers}
      media_type="$typ"
      media_search="$search"
      run_cmd "tv shield $media_search $media_type"
    '';
  };
}
