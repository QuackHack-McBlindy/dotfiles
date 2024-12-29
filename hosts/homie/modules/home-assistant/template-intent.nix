{

  system.activationScripts.writeCommonFile = ''
    echo "    
    example_key1: value1
    example_key2: value2
    example_key3:
      - list_item1
      - list_item2
      - list_item3
    " > /var/lib/hass/config/custom_sentences/sv/Media.yaml
  '';
  services.home-assistant.config = {

    intent_script = {
      speech.text = "{{ action_response['stdout'] }}";
      action = {
        service = "shell_command.media_controller";
        data = { 
          player = {
            {% if states('sensor.presence_media_player') == 'shield' %}
              192.168.1.223
            {% elif states('sensor.presence_media_player') == 'android_tv' %}
              192.168.1.152
            {% else %}
              192.168.1.223
            {% endif %}
          };  
          search = {
            {% if typ == 'playlist' %}
              https://example.duckdns.org/Playlists/MyPlaylist2.m3u
            {% else %}
              {{ search.replace(',', '').replace('!', '').replace('.', '').replace('?', '').strip() | default(0) }}
            {% endif %}     
          };
          typ = {
            {{ typ.replace(',', '').replace('!', '').replace('.', '').replace('?', '').strip() | default('tv') }}
          };
        };
        response_variable = "action_response";
        stop = "";
        response_variable = "action_response";   
      };
    };
  };
}
