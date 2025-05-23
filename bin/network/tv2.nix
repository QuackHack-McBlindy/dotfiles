{ self, config, pkgs, cmdHelpers, ... }:
{  
  yo.bitch = {
    language = "sv";    
    intents = {
      arris = {
        data = [{
          sentences = [
            "spela upp {search} {typ}"
            "spela {search} {typ}"
            "starta {search}"
          ];  
          lists = {
            search.wildcard = true;
            typ.values = [
              { "in" = "serien"; out = "tv"; }
              { "in" = "serie"; out = "tv"; }
              { "in" = "podd"; out = "podcast"; }
              { "in" = "pod"; out = "podcast"; }
              { "in" = "podcast"; out = "podcast"; }
              { "in" = "slump"; out = "jukebox"; }
              { "in" = "random"; out = "jukebox"; }
              { "in" = "slumpa"; out = "jukebox"; }
              { "in" = "artist"; out = "music"; }
              { "in" = "band"; out = "music"; }
              { "in" = "gruppen"; out = "music"; }
              { "in" = "låt"; out = "song"; }
            ];
            
          };
        }];
      };
    };
  };


  yo.scripts.arris = {
    description = "Android TV Controller";
    category = "🌐 Networking";
    aliases = [ "bedroom" "a" ];
#    helpFooter = ''
#    '';
    parameters = [
      { name = "typ"; description = "Media type"; default = "tv"; optional = true; }
      { name = "search"; description = "Media to search"; optional = false; }

    ];
    code = ''
      ${cmdHelpers}
      media_type="$typ"
      media_search="$search"
      echo "debug: {pkgs.tv}/bin/tv arris ''$media_search ''${typ}"
      tv arris ''$media_search ''${typ}
    '';
  };
}
