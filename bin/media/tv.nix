# dotfiles/bin/media/tv.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ Android TVOS Controller 
  self,
  lib,
  config,
  pkgs,
  ... 
} : let # 🦆 says ⮞ used for season entity lists
  nums = [
    [ "1"  "ett" ]
    [ "2"  "två" ]
    [ "3"  "tre" ]
    [ "4"  "fyra" ]
    [ "5"  "fem" ]
    [ "6"  "sex" ]
    [ "7"  "sju" ]
    [ "8"  "åtta" ]
    [ "9"  "nio" ]
    [ "10" "tio" ]
    [ "11" "elva" ]
    [ "12" "tolv" ]
    [ "13" "tretton" ]
    [ "14" "fjorton" ]
    [ "15" "femton" ]
    [ "16" "sexton" ]
    [ "17" "sjutton" ]
    [ "18" "arton" ]
    [ "19" "nitton" ]
    [ "20" "tjugo" ]
    [ "21" "tjugoett" ]
    [ "22" "tjugotvå" ]
    [ "23" "tjugotre" ]
    [ "24" "tjugofyra" ]
    [ "25" "tjugofem" ]
    [ "26" "tjugosex" ]
    [ "27" "tjugosju" ]
    [ "28" "tjugoåtta" ]
    [ "29" "tjugonio" ]
    [ "30" "trettio" ]
  ];

in {   
   
  yo.scripts.tv = {
    description = "Android TV Controller. Fuzzy search all media types and creates playlist and serves over webserver for casting.";
    category = "🎧 Media Management";
    logLevel = "INFO";
    parameters = [
      { 
        name = "typ";
        description = ''
          Specify the type of command or the media type to search for.
          Supported commands are: 
            on, off, up, down, call, favorites, star. 
          Media Types:
            tv, movie, livetv, podcast, music, song, musicvideo, jukebox (random music), othervideo, youtube.
          Device Naviagation:
            nav_up, nav_down, nav_left, nav_right, nav_select, nav_menu, nav_back
        '';
        default = "tv";
        optional = true;
        values = [ # 🦆 says ⮞ listz of allowed values
          "on" "off" "up" "down" "next" "prev" "call" "favourites" "star" "tv" "movie"
          "livetv" "podcast" "music" "song" "musicvideo" "jukebox" "othervideo" "youtube"
          "nav_up" "nav_down" "nav_left" "nav_right" "nav_select" "nav_menu" "nav_back" "channel_up" "channel_down" 
        ];
      }
      { name = "search"; type = "string"; description = "Media to search"; optional = true; }
      { name = "room"; description = "Room name of device to play on"; optional = true; }
      { name = "season"; type = "string"; description = "Specific season to play"; optional = true; }
      { name = "shuffle"; type = "bool"; description = "Shuffle Toggle, true or false"; default = true; }
    ];
    binary = self.inputs.zigduck2mqttnix.packages.x86_64-linux.tv + "/bin/tv";
    voice = { # 🦆 says ⮞ low priority = higher priority! faser execution? wtf upside down?!
        priority = 1; # 🦆 says ⮞ 1 to 5
        sentences = [
          # 🦆 says ⮞ season specific search
          "[jag] (spel|spela|kör|start|starta) [upp|igång] {typ} {search} (säsong|season) {season} i {room}"
          "jag vill se {typ} {search} (säsong|season) {season} i {room}" 
          "[jag] (spel|spela|kör|start|starta) [upp|igång] {typ} {search} (säsong|season) {season}"
          "jag vill se {typ} {search} (säsong|season) {season}"       
          # 🦆 says ⮞ room specific device control
          "[jag] (spel|spela|kör|start|starta) [upp|igång] {typ} {search} i {room}"
          "jag vill se {typ} {search} i {room}"    
          "jag vill lyssna på {typ} i {room}"
          "jag vill höra {typ} {search} i {room}"
          "{typ} (volym|volymen|avsnitt|avsnittet|låt|låten|skiten) i {room}"          
          "tv {typ} i {room}"
          # 🦆 says ⮞ default player
          "[jag] (spel|spela|kör|start|starta) [upp|igång] {typ} {search}"
          "jag vill se {typ} {search}"    
          # 🦆 says ⮞ listen to starred tracks
          "jag vill lyssna på [mina] {typ}"
          "jag vill höra [mina] {typ}"
          "spela upp mina {typ} [låtar]"
          # 🦆 says ⮞ up volume 
          "{typ} (volym|volymen|avsnitt|avsnittet|låt|låten|skiten)"       
          "tv {typ}"
          # 🦆 says ⮞ append to favorites playlist
          "{typ} i [favoriter|spellistan]"
          "{typ} den här [låten] i [favoriter|spellistan]"
          "{typ} till [den] [här] [låten] i [favoriter|spellistan]"
          # 🦆 says ⮞ find remote
          "ring {typ}"
          "hitta {typ}"
        ]; # 🦆 says ⮞ lists are in word > out word
        lists = { # swap 🦆 says ⮞ long list incomin' yo 
          typ.values = [          
          # 🦆 says ⮞ media 
            { "in" = "serie|serien|tvserien|tv-serien"; out = "tv"; }
            { "in" = "pod|podd|podcost|poddan|podden|podcast"; out = "podcast"; }
            { "in" = "slump|slumpa|random|musik|mix|shuffle"; out = "jukebox"; }
            { "in" = "artist|artisten|band|bandet|grupp|gruppen"; out = "music"; }
            { "in" = "låt|låten|sång|sången|biten"; out = "song"; }
            { "in" = "film|filmen"; out = "movie"; }
            { "in" = "ljudbok|ljudboken"; out = "audiobook"; }
            { "in" = "video|videon"; out = "othervideo"; }
            { "in" = "musicvideo|musikvideo"; out = "musicvideo"; }
            { "in" = "kanal|kanalen|kannal"; out = "livetv"; }
            { "in" = "youtube|you-tube|you|yt|yotub|yotube|yotub|tuben|juden"; out = "youtube"; }     
            { "in" = "news|nyhet|nyheter|nyheterna|senaste nytt"; out = "news"; }               
          # 🦆 says ⮞ play starred tracks            
            { "in" = "spellista|spellistan|spel lista|spel listan"; out = "favourites"; }
            { "in" = "favorit|favoriter"; out = "favourites"; }
          # 🦆 says ⮞ playback            
            { "in" = "paus|pause|pausa|tyst|tysta|mute|stop"; out = "pause"; }
            { "in" = "play|fortsätt|okej"; out = "play"; }
            { "in" = "öj|höj|höjj|öka|hej"; out = "up"; }
            { "in" = "sänk|sänkt|ner|ned"; out = "down"; }
            { "in" = "näst|nästa|nästan|next|fram|framåt"; out = "next"; }
            { "in" = "förr|förra|föregående|backa|bakåt"; out = "previous"; }
          # 🦆 says ⮞ star currently playing                           
            { "in" = "spara|add|adda|addera|lägg"; out = "star"; }
            #{ "in" = "[favorit|favoriter|bästa]"; out = "star"; }
          # 🦆 says ⮞ on/off           
            { "in" = "av|stäng av"; out = "off"; }            
            { "in" = "på"; out = "on"; }      
          # 🦆 says ⮞ calls remote                        
            { "in" = "fjärren|fjärrkontroll|fjärrkontrollen"; out = "call"; }               
          ]; # 🦆 says ⮞ search can be anything            
          search.wildcard = true;
          # 🦆 says ⮞ hardcoded device names
          room.values = [
            { "in" = "sovrum|sovrummet|bedroom"; out = "bedroom"; }
            { "in" = "vardagsrum|vardagsrummet|livingroom"; out = "livingroom"; }              
          ]; # 🦆 says ⮞ or use device name from Nix config          
          # device.values = let
          #   devices = lib.attrValues config.house.tv;
          # in map (device: {
          #   "in" = "[${device.room}|${lib.head (lib.splitString "." device.ip)}]"; 
          #   out = device.ip; 
          # }) devices;
          season.values = map (pair: {
            "in" = builtins.concatStringsSep "|" pair;
            out  = builtins.head pair;
          }) nums;
        };
    };

  };}
