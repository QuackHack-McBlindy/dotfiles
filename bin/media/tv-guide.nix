# dotfiles/bin/media/tv-guide.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ Fancy markdown & Text-To-Speech EPG in da terminal! 
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ... 
} : let # 🦆 says ⮞ yo    
in {
  yo.bitch.intents.tv-guide = {
    data = [{
      sentences = [
        "vilken kanal (spelas|sänds) {search} på"  
        "vad (sänds|visas) på [kanal] {channel} [just nu]"       
      ];    
      lists = {
        channel.values = [
          { "in" = "ettan"; out = "1"; }         
          { "in" = "tvåan"; out = "2"; }      
          { "in" = "trean"; out = "3"; }      
          { "in" = "fyran"; out = "4"; }      
          { "in" = "femman"; out = "5"; }         
          { "in" = "sexan"; out = "6"; }      
          { "in" = "sjuan"; out = "7"; }      
          { "in" = "åttan"; out = "8"; }      
          { "in" = "nian"; out = "9"; }         
          { "in" = "tian"; out = "10"; }      
          { "in" = "elvan"; out = "11"; }      
          { "in" = "tolvan"; out = "12"; }   
          { "in" = "sport 1"; out = "14"; }   
          { "in" = "sport 2"; out = "15"; }   
          { "in" = "sport 3"; out = "16"; }   
          { "in" = "sport 4"; out = "17"; }                                           
        ];
        search.wildcard = true;
      };
    }];
  };
  yo.scripts.tv-guide = {
    description = "TV-guide assistant..";
    aliases = [ "tvg" ];
    category = "🎧 Media Management";
    autoStart = false;
    logLevel = "DEBUG";
#    helpFooter = '' # 🦆 says ⮞ TODO Show what is on da TVB usin' glow
#    '';
    parameters = [
      { name = "search"; description = "TV show to search for"; optional = true; }  
      { name = "channel"; description = "TV show to search for"; optional = true; }      
      { name = "jsonFilePath"; description = "Optional option to write as JSON file in addation to the EPG"; optional = true; default = "/home/" + config.this.user.me.name + "/epg.json"; }      
    ];
    code = ''
      ${cmdHelpers}
      channel="$channel"
      search="$search"
      current_time=$(date -u +"%Y%m%d%H%M%S +0000")      
      jsonFilePath="''${jsonFilePath:-/home/${config.this.user.me.name}/epg.json}"
      
      if [ ! -f "$jsonFilePath" ]; then
        yo tv-scraper
        sleep 5
      fi
      
      clean_title() {
        echo "$1" | sed -n 's/.*>\(.*\)<\/a>.*/\1/p'
      }
      
      format_time() {
        local time_str="$1"
        local datetime_part="''${time_str:0:14}"
        local hour="''${datetime_part:8:2}"
        local minute="''${datetime_part:10:2}"
        echo "''${hour}:''${minute}"
      }
      
      get_channel_name() {
        ${pkgs.jq}/bin/jq -r --arg id "$1" '
          (.channels // [])[] | select(.id == $id) | .name
        ' "$jsonFilePath"
      }
      
      get_progress_bar() {
        local start_time="$1"
        local end_time="$2"
        local width=50     
        local start_epoch=$(date -u -d "$(echo "$start_time" | sed -E 's/^([0-9]{4})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2}).*/\1-\2-\3 \4:\5:\6/')" +%s)
        local end_epoch=$(date -u -d "$(echo "$end_time" | sed -E 's/^([0-9]{4})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2}).*/\1-\2-\3 \4:\5:\6/')" +%s)
        local now_epoch=$(date -u +%s)      
        local total_duration=$((end_epoch - start_epoch))
        local elapsed=$((now_epoch - start_epoch))
        local progress=$((elapsed * 100 / total_duration))
     
        if (( progress < 0 )); then progress=0; fi
        if (( progress > 100 )); then progress=100; fi
        
        local filled=$((progress * width / 100))
        local empty=$((width - filled)) 
        local bar=""
        for ((i=0; i<filled; i++)); do bar+="█"; done
        for ((i=0; i<empty; i++)); do bar+="─"; done
        
        if (( progress < 50 )); then
          bar="\033[32m$bar\033[0m"  # Green
        elif (( progress < 75 )); then
          bar="\033[33m$bar\033[0m"  # Yellow
        else
          bar="\033[31m$bar\033[0m"  # Red
        fi
        
        echo "$bar"
      }
      
      display_channel_info() {
        local chan_id="$1"
        local title="$2"
        local start_time="$3"
        local end_time="$4"
        local progress_bar="$5"
        
        title=$(clean_title "$title")
        
        local start_fmt=$(format_time "$start_time")
        local end_fmt=$(format_time "$end_time")
        local channel_name=$(get_channel_name "$chan_id")
        local title_length=''${#title}
        local padding=$(( (50 - title_length) / 2 ))
        printf "\n%*s" $padding ""
        echo -e "\033[1m$title\033[0m"
        
        echo -e "\033[1m$chan_id\033[0m $channel_name"
        echo "─────────────────────────────────────────────────────────────────────────────"
        
        echo -e "$start_fmt $progress_bar $end_fmt"
      }
      
      # 🦆 says ⮞ channel search, yo!
      if [ -n "$channel" ]; then
        dt_debug "Kollar vad som går på kanal $channel just nu..."
        
        program=$(${pkgs.jq}/bin/jq -r --arg chan "$channel" --arg now "$current_time" '
          (.channels[].programs // [])[] | 
          select(.channel_id == $chan and .start <= $now and .stop >= $now) |
          "\(.title)|\(.start)|\(.stop)"
        ' "$jsonFilePath")
        
        if [ -z "$program" ]; then
          channel_name=$(get_channel_name "$channel")
          dt_error "Inget program hittades på $channel_name."
        else
          IFS='|' read -r title start_time end_time <<< "$program"
          progress_bar=$(get_progress_bar "$start_time" "$end_time")
          display_channel_info "$channel" "$title" "$start_time" "$end_time" "$progress_bar"
        fi
      
      # 🦆 says ⮞ program search, yolo!
      elif [ -n "$search" ]; then
        dt_debug "Söker efter program som matchar: $search"
        
        results=$(${pkgs.jq}/bin/jq -r --arg query "$search" --arg now "$current_time" '
          (.channels[].programs // [])[] | 
          select(
            (.title | ascii_downcase | contains($query | ascii_downcase)) and 
            (.start <= $now) and 
            (.stop >= $now)
          ) | 
          "\(.channel_id)|\(.title)|\(.start)|\(.stop)"
        ' "$jsonFilePath")
        
        if [ -z "$results" ]; then
          dt_debug "Inga aktuella program matchade din sökning."
        else
          echo -e "\n\033[1mProgram som matchar '$search':\033[0m"
          while IFS='|' read -r chan_id title start_time end_time; do
            progress_bar=$(get_progress_bar "$start_time" "$end_time")
            display_channel_info "$chan_id" "$title" "$start_time" "$end_time" "$progress_bar"
          done <<< "$results"
        fi
      
      # 🦆 says ⮞ show all currently airing in a channel list
      else
        dt_debug "Aktuella program just nu:"
       
        results=$(${pkgs.jq}/bin/jq -r --arg now "$current_time" '
          (.channels[].programs // [])[] | 
          select(.start <= $now and .stop >= $now) | 
          "\(.channel_id)|\(.title)|\(.start)|\(.stop)"
        ' "$jsonFilePath")
        
        if [ -z "$results" ]; then
          dt_info "Inga aktuella program hittades."
        else
          echo -e "\n\033[1mAktuella program:\033[0m"
          while IFS='|' read -r chan_id title start_time end_time; do
            progress_bar=$(get_progress_bar "$start_time" "$end_time")
            display_channel_info "$chan_id" "$title" "$start_time" "$end_time" "$progress_bar"
          done <<< "$results"
        fi
      fi
    '';   
  };}
