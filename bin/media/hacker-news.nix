# dotfiles/bin/media/hacker-news.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ HN reader 
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ... 
} : let # 🦆 says ⮞     

in {   
   
  yo.scripts.hacker-news = {
    description = "Hacker news API controller";
    category = "🎧 Media Management";
    aliases = [ "hn" ];
    autoStart = false;
    logLevel = "INFO";
    parameters = [
      { name = "show"; type = "string"; description = "What stories to read "; optional = true; values = [ "top" "best" "new" "ask" "show" "jobos" ]; }
      { name = "item"; type = "int"; description = "Reads item details"; optional = true; }
      { name = "user"; type = "string"; description = "Reads user information"; optional = true; }
      { name = "clear"; type = "bool"; description = "Clears the ache if true"; default = false; optional = true; }
      { name = "number"; type = "int"; description = "Number of items to read"; default = 5; optional = false; }      
    ];
    helpFooter = ''
      echo "Hacker News CLI Reader"
    '';
    code = ''
      ${cmdHelpers}    
      BASE_URL="https://hacker-news.firebaseio.com/v0"
      CACHE_DIR="$HOME/.cache/hacker-news"
      MAX_ITEMS=$number      
      mkdir -p "$CACHE_DIR"
         
      fetch_json() {
          local url="$1"
          local cache_file="$CACHE_DIR/$(echo "$url" | md5sum | cut -d' ' -f1)"
          local cache_age=300  # 5 minutes cache
          
          if [[ -f "$cache_file" ]] && [[ $(($(date +%s) - $(stat -c %Y "$cache_file"))) -lt $cache_age ]]; then
              cat "$cache_file"
          else
              curl -s "$url" | tee "$cache_file"
          fi
      }
      
      get_item() {
          local item_id="$1"
          fetch_json "$BASE_URL/item/$item_id.json"
      }
      
      get_user() {
          local username="$1"
          fetch_json "$BASE_URL/user/$username.json"
      }
      
      display_story() {
          local item_json="$1"
          local index="$2"
          
          local title=$(echo "$item_json" | jq -r '.title // empty')
          local url=$(echo "$item_json" | jq -r '.url // empty')
          local score=$(echo "$item_json" | jq -r '.score // 0')
          local by=$(echo "$item_json" | jq -r '.by // "unknown"')
          local descendants=$(echo "$item_json" | jq -r '.descendants // 0')
          local id=$(echo "$item_json" | jq -r '.id')
          
          if [[ -n "$title" ]]; then
              printf "$CYAN%2d.$NC " "$index"
              printf "$YELLOW%s$NC" "$title"
              echo
              printf "     $GREEN↑%d$NC | $BLUE%s$NC | $CYAN%d comments$NC" "$score" "$by" "$descendants"
              if [[ -n "$url" ]]; then
                  printf " | $GREEN%s$NC" "$(echo "$url" | cut -d'/' -f1-3)"
              fi
              echo
              echo
          fi
      }
      
      display_stories() {
          local story_ids=("$@")
          local count=0      
          for id in "''${story_ids[@]}"; do
              if [[ $count -ge $MAX_ITEMS ]]; then
                  break
              fi
              
              local item_json=$(get_item "$id")
              if [[ -n "$item_json" ]] && [[ "$item_json" != "null" ]]; then
                  ((count++))
                  display_story "$item_json" "$count" &
              fi
          done
          wait
      }
      
      top_stories() {
          dt_debug "Fetching top stories..."
          local top_ids=$(fetch_json "$BASE_URL/topstories.json" | jq -r '.[]' | head -$MAX_ITEMS)
          local ids_array=($top_ids)
          display_stories "''${ids_array[@]}"
      }
      
      new_stories() {
          dt_debug "Fetching new stories..."
          local new_ids=$(fetch_json "$BASE_URL/newstories.json" | jq -r '.[]' | head -$MAX_ITEMS)
          local ids_array=($new_ids)
          display_stories "''${ids_array[@]}"
      }
      
      best_stories() {
          dt_debug "Fetching best stories..."
          local best_ids=$(fetch_json "$BASE_URL/beststories.json" | jq -r '.[]' | head -$MAX_ITEMS)
          local ids_array=($best_ids)
          display_stories "''${ids_array[@]}"
      }
      
      ask_stories() {
          dt_debug "Fetching Ask HN stories..."
          local ask_ids=$(fetch_json "$BASE_URL/askstories.json" | jq -r '.[]' | head -$MAX_ITEMS)
          local ids_array=($ask_ids)
          display_stories "''${ids_array[@]}"
      }
      
      show_stories() {
          dt_debug "Fetching Show HN stories..."
          local show_ids=$(fetch_json "$BASE_URL/showstories.json" | jq -r '.[]' | head -$MAX_ITEMS)
          local ids_array=($show_ids)
          display_stories "''${ids_array[@]}"
      }
      
      job_stories() {
          dt_debug "Fetching job stories..."
          local job_ids=$(fetch_json "$BASE_URL/jobstories.json" | jq -r '.[]' | head -$MAX_ITEMS)
          local ids_array=($job_ids)
          display_stories "''${ids_array[@]}"
      }
      
      user_info() {
          local username="$1"
          if [[ -z "$username" ]]; then
              dt_error "Please provide a username"
              exit 1
          fi
          
          dt_debug "Fetching user info for: $username"
          local user_json=$(get_user "$username")
          
          if [[ -z "$user_json" ]] || [[ "$user_json" == "null" ]]; then
              dt_error "User not found: $username"
              exit 1
          fi
          
          local id=$(echo "$user_json" | jq -r '.id')
          local created=$(echo "$user_json" | jq -r '.created')
          local karma=$(echo "$user_json" | jq -r '.karma')
          local about=$(echo "$user_json" | jq -r '.about // "N/A"' | sed 's/<[^>]*>//g')
          
          echo
          echo -e "$CYANUser: $YELLOW$id$NC"
          echo -e "$CYANKarma: $GREEN$karma$NC"
          echo -e "$CYANCreated: $BLUE$(date -d @$created)$NC"
          echo -e "$CYANAbout: $NC$about"
          echo
      }
      
      item_details() {
          local item_id="$1"
          if [[ -z "$item_id" ]]; then
              dt_error "Please provide an item ID"
              exit 1
          fi
          
          dt_debug "Fetching item: $item_id"
          local item_json=$(get_item "$item_id")
          
          if [[ -z "$item_json" ]] || [[ "$item_json" == "null" ]]; then
              dt_error "Item not found: $item_id"
              exit 1
          fi
          
          local type=$(echo "$item_json" | jq -r '.type')
          local title=$(echo "$item_json" | jq -r '.title // empty')
          local text=$(echo "$item_json" | jq -r '.text // empty' | sed 's/<[^>]*>//g')
          local by=$(echo "$item_json" | jq -r '.by // "unknown"')
          local time=$(echo "$item_json" | jq -r '.time')
          local score=$(echo "$item_json" | jq -r '.score // 0')
          local url=$(echo "$item_json" | jq -r '.url // empty')
          local descendants=$(echo "$item_json" | jq -r '.descendants // 0')
          
          echo
          if [[ -n "$title" ]]; then
              echo -e "$YELLOW$title$NC"
          fi
          
          if [[ -n "$text" ]]; then
              echo -e "$NC$text$NC"
              echo
          fi
          
          echo -e "$CYANType:$NC $type"
          echo -e "$CYANBy:$NC $by"
          echo -e "$CYANTime:$NC $(date -d @$time)"
          echo -e "$CYANScore:$NC $score"
          
          if [[ -n "$url" ]]; then
              echo -e "$CYANURL:$NC $url"
          fi
          
          if [[ "$type" == "story" ]]; then
              echo -e "$CYANComments:$NC $descendants"
          fi
          echo
      }
      
      clear_cache() {
          rm -rf "$CACHE_DIR"
          dt_debug "Cache cleared"
      }
      
      COMMAND="$show"

      if [ "$clear" = true ]; then
        cache-clear
        exit
      fi
      if [ -n "$item" ]; then
        item_details "$item"
        exit
      fi      
      if [ -n "$user" ]; then      
        user_info "$user"
        exit
      fi
    
      while [[ $# -gt 0 ]]; do
          case $1 in
              top|new|best|ask|show|jobs)
                  COMMAND="$1"
                  shift
                  ;;
              *)
                  dt_error "Unknown option: $1"
                  exit 1
                  ;;
          esac
      done
      

      case $COMMAND in
          top)
              top_stories
              ;;
          new)
              new_stories
              ;;
          best)
              best_stories
              ;;
          ask)
              ask_stories
              ;;
          show)
              show_stories
              ;;
          jobs)
              job_stories
              ;;
      esac
          
    '';
  };}  
