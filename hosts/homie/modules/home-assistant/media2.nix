
let
  # Define the presence media player conditionally
  player = if states.sensor.presence_media_player == "shield" then
            "192.168.1.223"
           else if states.sensor.presence_media_player == "android_tv" then
            "192.168.1.152"
           else
            "192.168.1.223";
  
  # Handle the search URL conditionally
  searchUrl = if typ == "playlist" then
                "https://example.duckdns.org/Playlists/MyPlaylist2.m3u"
             else
                lib.trim (lib.replaceStrings [","] [""] (lib.replaceStrings ["!"] [""] (lib.replaceStrings ["."] [""] (lib.replaceStrings ["?"] [""] search))));

  # Handle the type (typ) conditionally
  mediaType = lib.trim (lib.replaceStrings [","] [""] (lib.replaceStrings ["!"] [""] (lib.replaceStrings ["."] [""] (lib.replaceStrings ["?"] [""] typ)))) or "tv";

in
{
  
  services.home-assistant.config.intent_script = {
    mediaController = {
      speech.text = "Send notification";
      action = {
        service = "shell_command.media_controller";
        data = {
          player = [ player ];  # Using the computed player
          search = searchUrl;   # Using the computed search URL
          typ = mediaType;      # Using the computed media type
        };
        response_variable = "action_response";
        stop = "";
  #      response_variable = "action_response";
      };
    };
  };
}
