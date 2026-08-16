{ 
  self,
  config,
  lib,
  pkgs,
  ...
} : with lib;
let
  englishNumbers = [
    "zero" "one" "two" "three" "four" "five" "six" "seven" "eight" "nine" "ten"
    "eleven" "twelve" "thirteen" "fourteen" "fifteen" "sixteen" "seventeen" "eighteen" "nineteen" "twenty"
    "twenty-one" "twenty-two" "twenty-three" "twenty-four" "twenty-five" "twenty-six" "twenty-seven" "twenty-eight" "twenty-nine" "thirty"
    "thirty-one" "thirty-two" "thirty-three" "thirty-four" "thirty-five" "thirty-six" "thirty-seven" "thirty-eight" "thirty-nine" "forty"
    "forty-one" "forty-two" "forty-three" "forty-four" "forty-five" "forty-six" "forty-seven" "forty-eight" "forty-nine" "fifty"
    "fifty-one" "fifty-two" "fifty-three" "fifty-four" "fifty-five" "fifty-six" "fifty-seven" "fifty-eight" "fifty-nine" "sixty"
  ];

  englishNumber = n: builtins.elemAt englishNumbers (n - 1);

in {

  yo.scripts.tv = {
    description = "Android TV controller.";
    category = "Home Automation";
    logLevel = "INFO";    
    binary = /run/current-system/sw/bin/tv;
    parameters = [
      { name = "typ"; description = "Specify the type of command or the media type to search for. Supported commands: on, off, up, down, call, favorites, add. Media Types: tv, movie, livetv, podcast, news, music, song, musicvideo, jukebox (random music), othervideo, youtube, nav_up, nav_down, nav_left, nav_right, nav_select, nav_menu, nav_back"; default = "tv"; optional = true; values = [ "on" "off" "up" "down" "next" "prev" "call" "favorites" "add" "tv" "movie" "livetv" "podcast" "news" "music" "song" "musicvideo" "jukebox" "othervideo" "youtube" "nav_up" "nav_down" "nav_left" "nav_right" "nav_select" "nav_menu" "nav_back" "channel_up" "channel_down" ]; }
      { name = "search"; type = "string"; description = "Media to search"; optional = true; }
      { name = "device"; description = "Device IP to play on"; optional = true; }
      { name = "room"; description = "Room name of the device to control"; optional = true; }      
      { name = "season"; type = "string"; description = "Specific season to play"; optional = true; }
    ];

    voice = {
      priority = 1;
      fuzzy = {
        enable = true;
        threshold = 0.4;
      };       
      sentences = [    
        # season specific search
        "[I] (play|play|run|start|start) [up|on] {typ} {search} (season|season) {season} on {device}"
        "I want to watch {typ} {search} (season|season) {season} on {device}"
        "[I] (play|play|run|start|start) [up|on] {typ} {search} (season|season) {season}"
        "I want to watch {typ} {search} (season|season) {season}"
        # non-default device control
        "[I] (play|play|run|start|start) [up|on] {typ} {search} on {device}"
        "I want to watch {typ} {search} on {device}"
        "I want to listen to {typ} on {device}"
        "I want to hear {typ} {search} on {device}"
        "{typ} (volume|the volume|episode|the episode|song|the song|the shit) on {device}"
        "tv {typ} on {device}"
        # default player
        "[I] (play|play|run|start|start) [up|on] {typ} {search}"
        "I want to watch {typ} {search}"
        "I want to listen to [my] {typ}"
        "I want to hear [my] {typ}"
        "{typ} (volume|the volume|episode|the episode|song|the song|the shit)"
        "tv {typ}"
        # append to favorites playlist
        "save to {typ}"
        "add this [song] to {typ}"
        # find remote
        "call {typ}"
        "find {typ}"
      ];
      
      # lists are in word > out word
      lists = {
        typ.values = [
          # media
          { "in" = "[serie|series|show|tv series]"; out = "tv"; }
          { "in" = "[pod|podcast]"; out = "podcast"; }
          { "in" = "[random|randomize|music|mix|shuffle]"; out = "jukebox"; }
          { "in" = "[artist|band|group]"; out = "music"; }
          { "in" = "[song|track]"; out = "song"; }
          { "in" = "[movie|movies]"; out = "movie"; }
          { "in" = "[audiobook]"; out = "audiobook"; }
          { "in" = "[video|videos]"; out = "othervideo"; }
          { "in" = "[musicvideo|musicvideos|music-videos]"; out = "musicvideo"; }
          { "in" = "[channel]"; out = "livetv"; }
          { "in" = "[youtube|you-tube|you|yt|tube]"; out = "youtube"; }
          { "in" = "[news]"; out = "news"; }
      
          # heart currently playing
          { "in" = "[playlist|playlist]"; out = "favorites"; }
      
          # playback
          { "in" = "[pause|quiet|silence|mute|stop]"; out = "pause"; }
          { "in" = "[play|continue|okay]"; out = "play"; }
          { "in" = "[raise|increase|up]"; out = "up"; }
          { "in" = "[lower|down]"; out = "down"; }
          { "in" = "[next|forward]"; out = "next"; }
          { "in" = "[previous|back]"; out = "previous"; }
      
          # add to playlist
          { "in" = "[save|add]"; out = "add"; }
          { "in" = "[favorite|favorites|best]"; out = "add"; }
      
          # on/off
          { "in" = "[off|turn off]"; out = "off"; }
          { "in" = "on"; out = "on"; }
      
          # calls remote
          { "in" = "[the remote|remote control|the remote control]"; out = "call"; }
        ];
      
        # search can be anything
        search.wildcard = true;
      
        # hardcoded device names
        #device.values = [
        #  { "in" = "[bedroom|the bedroom]"; out = "192.168.1.153"; }
        #  { "in" = "[living room|the living room]"; out = "192.168.1.223"; }
        #];
      
        # or use device name from Nix config
        device.values = let
          devices = lib.attrValues config.house.tv;
        in map (device: {
          "in" = "[${device.room}|${lib.head (lib.splitString "." device.ip)}]";
          out = device.ip;
        }) devices;

        room.values = let
          rooms = lib.attrValues config.house.tv;
        in map (room: {
          "in" = "[${room.room}|${lib.head (lib.splitString "." room.ip)}]";
          out = room.room;
        }) rooms;
      
        season.values = builtins.concatLists (builtins.genList (
          i: let n = i + 1; in [
            { "in" = toString n; out = toString n; }
            { "in" = englishNumber n; out = toString n; }
          ]
        ) 60);
      };
    };
    
  };}
