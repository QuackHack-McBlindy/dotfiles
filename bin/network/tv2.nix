{ self, config, pkgs, cmdHelpers, ... }:
{  
  yo.bitch = { 
    intents = {
      arris = {
        data = [{
          sentences = [
            "(spel|spela|kör|start|starta) [upp|igång] {typ} {search} i (sovrum|sovrummet)"
            "jag vill se {typ} {search} i (sovrum|sovrummet)"    
            "jag vill lyssna på {typ} i (sovrum|sovrummet)"
            "jag vill höra {typ} {search} i (sovrum|sovrummet)"
            "{typ} (volym|volymen|avsnitt|avsnittet|låt|låten|skiten) i (sovrum|sovrummet)"            
          ];
          
          lists = {
            typ.values = [
              { "in" = "[serie|serien|tvserien|tv-serien]"; out = "tv"; }
              { "in" = "[pod|podd|podcost|poddan|podden|podcast]"; out = "podcast"; }
              { "in" = "[slump|slumpa|random|musik|mix|shuffle]"; out = "jukebox"; }
              { "in" = "[artist|artisten|band|bandet|grupp|gruppen]"; out = "music"; }
              { "in" = "[låt|låten|sång|sången|biten]"; out = "song"; }
              { "in" = "[film|filmen]"; out = "movie"; }
              { "in" = "[ljudbok|ljudboken]"; out = "audiobook"; }
              { "in" = "video"; out = "othervideo"; }
              { "in" = "[musicvideo|musikvideo]"; out = "musicvideo"; }
              { "in" = "[spellista|spellistan|spel lista|spel listan]"; out = "playlist"; }
              { "in" = "[nyhet|nyheter|nyheten|nyheterna|senaste nytt]"; out = "news"; }
              { "in" = "[kanal|kanalen|kannal]"; out = "livetv"; }
              { "in" = "[youtube|you-tube|you|yt|yotub|yotube|yotub|tuben|juden]"; out = "youtube"; }
              { "in" = "[paus|pause|pausa|tyst|tysta|mute|stop]"; out = "pause"; }
              { "in" = "[play|fortsätt|okej]"; out = "play"; }
              { "in" = "[öj|höj|höjj|öka|hej]"; out = "up"; }
              { "in" = "[sänk|sänkt|ner|ned]"; out = "down"; }
              { "in" = "[näst|nästa|nästan|next|fram|framåt]"; out = "next"; }
              { "in" = "[förr|förra|föregående|backa|bakåt]"; out = "previous"; }
              { "in" = "[spara|add|adda|addera|lägg till]"; out = "add"; }
            ];
            search.wildcard = true;
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
      { name = "typ"; description = "Media type"; default = "tv"; optional = false; }
      { name = "search"; description = "Media to search"; optional = false; }

    ];
    code = ''
      ${cmdHelpers}
      media_type="$typ"
      media_search="$search"
      tv arris "$media_search" "$media_type"
    '';
  };
}
