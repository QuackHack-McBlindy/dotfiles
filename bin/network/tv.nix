# dotfiles/bin/network/shield.nix
{ self, config, pkgs, cmdHelpers, ... }:
{  
  yo.bitch = { 
    intents = {
      shield = {
        data = [{
          sentences = [
            "kör igång {search} {typ}"
            "spel upp {search} {typ}"
            "spell upp {search} {typ}"
            "spela upp {search} {typ}"
            "spera upp {search} {typ}"
            "spel {search} {typ}"
            "spell {search} {typ}"
            "spela {search} {typ}"
            "spera {search} {typ}"
            "start {search} {typ}"
            "starta {search} {typ}"
            "startar {search} {typ}"
            "jag vill se {search} {typ}"
            "spel upp {search}"
            "spell upp {search}"
            "spela upp {search}"
            "spera upp {search}"
            "jag vill höra {search} {typ}"
            "{typ}"
          ];
          
          lists = {
            typ.values = [
              { "in" = "serie"; out = "tv"; }
              { "in" = "serien"; out = "tv"; }
              { "in" = "tvserien"; out = "tv"; }
              { "in" = "tv-serien"; out = "tv"; }
              { "in" = "v-serien"; out = "tv"; }
              { "in" = "podd"; out = "podcast"; }
              { "in" = "pod"; out = "podcast"; }
              { "in" = "podcast"; out = "podcast"; }
              { "in" = "podcost"; out = "podcast"; }
              { "in" = "poddan"; out = "podcast"; }
              { "in" = "podden"; out = "podcast"; }
              { "in" = "slump"; out = "jukebox"; }
              { "in" = "slumpa"; out = "jukebox"; }
              { "in" = "random"; out = "jukebox"; }
              { "in" = "musik"; out = "jukebox"; }
              { "in" = "artist"; out = "music"; }
              { "in" = "artisten"; out = "music"; }
              { "in" = "band"; out = "music"; }
              { "in" = "bandet"; out = "music"; }
              { "in" = "grupp"; out = "music"; }
              { "in" = "gruppen"; out = "music"; }
              { "in" = "låt"; out = "song"; }
              { "in" = "låten"; out = "song"; }
              { "in" = "sång"; out = "song"; }
              { "in" = "sången"; out = "song"; }
              { "in" = "biten"; out = "song"; }
              { "in" = "film"; out = "movie"; }
              { "in" = "filmen"; out = "movie"; }
              { "in" = "ljudbok"; out = "audiobook"; }
              { "in" = "ljudboken"; out = "audiobook"; }
              { "in" = "video"; out = "othervideo"; }
              { "in" = "musik video"; out = "musicvideo"; }
              { "in" = "music video"; out = "musicvideo"; }
              { "in" = "spellista"; out = "playlist"; }
              { "in" = "spellistan"; out = "playlist"; }
              { "in" = "spel lista"; out = "playlist"; }
              { "in" = "spel listan"; out = "playlist"; }
              { "in" = "playlist"; out = "playlist"; }
              { "in" = "nyhet"; out = "news"; }
              { "in" = "nyheter"; out = "news"; }
              { "in" = "nyheten"; out = "news"; }
              { "in" = "nyheterna"; out = "news"; }
              { "in" = "senaste nytt"; out = "news"; }
              { "in" = "kanal"; out = "livetv"; }
              { "in" = "kanalen"; out = "livetv"; }
              { "in" = "kannal"; out = "livetv"; }
              { "in" = "youtube"; out = "youtube"; }
              { "in" = "yotub"; out = "youtube"; }
              { "in" = "yotube"; out = "youtube"; }
              { "in" = "yootub"; out = "youtube"; }
              { "in" = "tuben"; out = "youtube"; }
              { "in" = "juden"; out = "youtube"; }
              { "in" = "paus"; out = "pause"; }
              { "in" = "pause"; out = "pause"; }
              { "in" = "pausa"; out = "pause"; }
              { "in" = "tyst"; out = "pause"; }
              { "in" = "mute"; out = "pause"; }
              { "in" = "stop"; out = "pause"; }
              { "in" = "stoppa"; out = "pause"; }
              { "in" = "play"; out = "play"; }
              { "in" = "fortsätt"; out = "play"; }
              { "in" = "okej"; out = "play"; }
              { "in" = "höj"; out = "up"; }
              { "in" = "höjj"; out = "up"; }
              { "in" = "öj"; out = "up"; }
              { "in" = "öka"; out = "up"; }
              { "in" = "hej"; out = "up"; }
              { "in" = "sänk"; out = "down"; }
              { "in" = "sänkt"; out = "down"; }
              { "in" = "ner"; out = "down"; }
              { "in" = "ned"; out = "down"; }
              { "in" = "näst"; out = "next"; }
              { "in" = "nästa"; out = "next"; }
              { "in" = "nästan"; out = "next"; }
              { "in" = "next"; out = "next"; }
              { "in" = "fram"; out = "next"; }
              { "in" = "framåt"; out = "next"; }
              { "in" = "förr"; out = "previous"; }
              { "in" = "förra"; out = "previous"; }
              { "in" = "föregående"; out = "previous"; }
              { "in" = "backa"; out = "previous"; }
              { "in" = "bakåt"; out = "previous"; }
              { "in" = "spara"; out = "add"; }
              { "in" = "add"; out = "add"; }
              { "in" = "adda"; out = "add"; }
              { "in" = "addera"; out = "add"; }
              { "in" = "lägg till"; out = "add"; }
            ];
            search.wildcard = true;
          };
        }];
      };
    };
  };


  yo.scripts.shield = {
    description = "Android TV Controller";
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
      tv shield "$media_search" "$media_type"
    '';
  };
}
