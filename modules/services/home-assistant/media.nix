{

  system.activationScripts.writeMediaSentencesFile = ''
    echo "
    language: \"sv\"
    intents:
      MediaController:
        data:
          - sentences:
              - \"kör igång {typ} {search}\"
              - \"(spel|spell|spela|spera) upp {typ} {search}\"
              - \"(spel|spell|spela|spera) [upp] {typ} {search}\"
              - \"(start|starta|startar) {typ} {search}\"
              - \"jag vill se {typ} {search}\"
              - \"(spel|spell|spela|spera) [upp] {typ} \"
              - \"jag vill höra {typ} {search}\"
              - \"{typ}\"
    lists:
      search:
        wildcard: true
      typ:
        values:
          - in: \"(serie|serien|tvserien|tv-serien|v-serien|tv serien)\"
            out: \"tv\"
          - in: \"(podd|pod|podcast|podcost|poddan|podden)\"
            out: \"podcast\"
          - in: \"(slump|slumpa|random|musik)\"
            out: \"jukebox\"
          - in: \"(artist|artisten|band|bandet|grupp|gruppen)\"
            out: \"music\"
          - in: \"(låt|låten|sång|sången|biten)\"
            out: \"song\"
          - in: \"(film|filmen)\"
            out: \"movie\"
          - in: \"(ljudbok|ljudboken)\"
            out: \"audiobook\"
          - in: \"video\"
            out: \"othervideo\"
          - in: \"(musik video|music video)\"
            out: \"musicvideo\"
          - in: \"(spellista|spellistan|spel lista|spel listan|playlist)\"
            out: \"playlist\"
          - in: \"(nyhet|nyheter|nyheten|nyheterna|senaste nytt)\"
            out: \"news\"
          - in: \"(kanal|kanalen|kannal)\"
            out: \"livetv\"
          - in: \"(youtube|yotub|yotube|yootub|tuben|juden)\"
            out: \"youtube\"
          - in: \"(paus|pause|pausa|tyst|mute|stop|stoppa)\"
            out: \"pause\"
          - in: \"(play|fortsätt|okej)\"
            out: \"play\"
          - in: \"(höj|höjj|öj|öka|hej|upp)\"
            out: \"up\"
          - in: \"(sänk|sänkt|ner|ned)\"
            out: \"down\"
          - in: \"(näst|nästa|nästan|next|fram|framåt)\"
            out: \"next\"
          - in: \"(förr|förra|föregående|backa|bakåt)\"
            out: \"previous\"
          - in: \"(spara|add|adda|addera|lägg till)\"
            out: \"add\"
    " > /var/lib/hass/config/custom_sentences/sv/media.yaml
  '';

  system.activationScripts.writeIntentFile = ''
    echo "    
    MediaController:
      action:   
        - service: shell_command.media_controller
          data: 
            player: >
              {% if states('sensor.presence_media_player') == 'shield' %}
                192.168.1.223
              {% elif states('sensor.presence_media_player') == 'android_tv' %}
                192.168.1.152
              {% else %}
                192.168.1.223
              {% endif %}
            search: >
              {% if typ == 'playlist' %}
                https://example.duckdns.org/Playlists/MyPlaylist2.m3u
              {% else %}
                {{ search.replace(',', '').replace('!', '').replace('.', '').replace('?', '').strip() | default(0) }}
              {% endif %}
          
            typ: >
              {{ typ.replace(',', '').replace('!', '').replace('.', '').replace('?', '').strip() | default('tv') }}
            #player: remote.{{ states('sensor.presence_media_player') }}

          response_variable: action_response
        - stop: ''
          response_variable: action_response   
      speech:
        text: {{ action_response['stdout'] }}
    " > /var/lib/hass/config/intent_script.yaml
  '';
}
  
  
  
  
  #services.home-assistant.config = {
    #intent_script = {
    #  mediaController = {
    #    speech.text = "Send notification";
    #    action = {
    #      service = "shell_command.media_controller";
    #      data = { 
    #        player = [
    #          {% if states('sensor.presence_media_player') == 'shield' %}
    #            192.168.1.223
    #          {% elif states('sensor.presence_media_player') == 'android_tv' %}
    #            192.168.1.152
    #          {% else %}
    #            192.168.1.223
    #          {% endif %}
    #        ];  
    #        search = {
    #          {% if typ == 'playlist' %}
    #            https://example.duckdns.org/Playlists/MyPlaylist2.m3u
    #          {% else %}
    #            {{ search.replace(',', '').replace('!', '').replace('.', '').replace('?', '').strip() | default(0) }}
    #          {% endif %}     
    #        };
    #        typ = {
    #          {{ typ.replace(',', '').replace('!', '').replace('.', '').replace('?', '').strip() | default('tv') }}
    #        };
    #      };
    #      response_variable = "action_response";
    #      stop = "";
    #      response_variable = "action_response";   
    #    };
    #  };
   # };
 # };
}
