# dotfiles/bin/network/shield.nix
{ self, config, pkgs, cmdHelpers, ... }:
{  
  yo.bitch = { 
    intents = {
      shield = {
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



  yo.scripts.shield = {
    description = "Android TV Controller";
#    intent = "shield";
    category = "🌐 Networking";
    aliases = [ "s" "tv" ];
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
      tv shield ''$media_search ''${typ}
    '';
  };
}
