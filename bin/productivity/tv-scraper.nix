# dotfiles/bin/productivity/tv-scraper.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ Scrapes tv schedule and build xml file
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ... 
} : let # 🦆 says ⮞ dependencies   
  pyEnv = pkgs.python3.withPackages (ps: [ ps.requests ]); 
  scraper = pkgs.writeScript "tv-scraper.py" ''
    #!${pyEnv}/bin/python
    import os
    import requests
    import re 
    import json
    from datetime import datetime, timedelta
    import xml.etree.ElementTree as ET
    import logging
    import html.parser
    import html.entities
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument('--xmlPath', type=str, default=os.path.expanduser("~/epg.xml"))
    parser.add_argument('--jsonPath', type=str, default=None)
    args = parser.parse_args()
    
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s - %(levelname)s - %(message)s",
        handlers=[
            logging.StreamHandler(),
            logging.FileHandler('tv-scraper.log')
        ]
    )
    logger = logging.getLogger()
    
    TIME_OFFSET = timedelta(hours=0)
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s - %(levelname)s - %(message)s",
        handlers=[
            logging.StreamHandler(),
            logging.FileHandler('tv-scraper.log')
        ]
    )
    logger = logging.getLogger()
    
    TIME_OFFSET = timedelta(hours=0)    
    class SimpleScheduleParser(html.parser.HTMLParser):
        def __init__(self):
            super().__init__()
            self.schedule = []
            self.current_entry = {}
            self.in_table = False
            self.in_row = False
            self.in_time = False
            self.in_program = False
            self.in_description = False
            self.data_buffer = ""
            self.cell_count = 0
        
        def handle_starttag(self, tag, attrs):
            attrs_dict = dict(attrs)  
            if tag == "table":
                self.in_table = True
                logger.debug("Found a table")
            elif self.in_table and tag == "tr":
                self.in_row = True
                self.cell_count = 0
                self.current_entry = {}
                logger.debug("Starting row")
            elif self.in_row and tag == "td":
                self.cell_count += 1
                if self.cell_count == 1:  # First cell is time
                    self.in_time = True
                    logger.debug("Found time cell")
                elif self.cell_count == 2:  # Second cell is program info
                    self.in_program = True
                    logger.debug("Found program cell")
            elif self.in_program and tag == "h2":
                logger.debug("Found program title")  
            elif self.in_program and tag == "a":
                logger.debug("Found program link")
            elif self.in_program and tag == "p":
                self.in_description = True
                logger.debug("Found description")
        
        def handle_endtag(self, tag):
            if tag == "table":
                self.in_table = False
                logger.debug("Exiting table") 
            elif tag == "tr" and self.in_row:
                self.in_row = False
                if self.current_entry.get('time') and self.current_entry.get('program'):
                    self.schedule.append(self.current_entry)
                    logger.debug(f"Added program: {self.current_entry['program']}")
                self.current_entry = {}
            
            elif tag == "td" and self.in_time:
                self.in_time = False
                if self.data_buffer.strip():
                    self.current_entry['time'] = self.data_buffer.strip()
                    logger.debug(f"Time: {self.data_buffer.strip()}")
                self.data_buffer = ""
            
            elif tag == "td" and self.in_program:
                self.in_program = False
                if self.data_buffer.strip() and not self.current_entry.get('program'):
                    self.current_entry['program'] = self.data_buffer.strip()
                    logger.debug(f"Program: {self.data_buffer.strip()}")
                self.data_buffer = ""
            
            elif tag == "p" and self.in_description:
                self.in_description = False
                if self.data_buffer.strip():
                    self.current_entry['description'] = self.data_buffer.strip()
                    logger.debug(f"Description: {self.data_buffer.strip()}")
                self.data_buffer = ""
        
        def handle_data(self, data):
            if self.in_time or self.in_program or self.in_description:
                self.data_buffer += data
                logger.debug(f"Data: {data}")
        
        def handle_entityref(self, name):
            char = html.entities.entitydefs.get(name, f'&{name};')
            if self.in_time or self.in_program or self.in_description:
                self.data_buffer += char
                logger.debug(f"Entity: {char}")
    
    def scrape_schedule(url, channel_id):
        try:
            headers = {
                "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36",
                "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
                "Accept-Language": "en-US,en;q=0.5",
            }
            
            logger.info(f"Fetching {url}")
            response = requests.get(url, headers=headers, timeout=10)
            response.raise_for_status()
            
            html_filename = f"channel_{channel_id}.html"
            with open(html_filename, "w", encoding="utf-8") as f:
                f.write(response.text)
            logger.info(f"Saved HTML to {html_filename}")
            
            logger.debug(f"HTML snippet: {response.text[:500]}")    
            parser = SimpleScheduleParser()
            parser.feed(response.text)  
            if not parser.schedule:
                logger.warning("Parser found no programs, trying regex fallback")
                programs = re.findall(r'<td[^>]*>(.*?)</td>\s*<td[^>]*>.*?<h2[^>]*>(.*?)</h2>.*?<p>(.*?)</p>', response.text, re.DOTALL)
                for time, program, desc in programs:
                    parser.schedule.append({
                        "time": time.strip(),
                        "program": program.strip(),
                        "description": desc.strip()
                    })
                logger.info(f"Regex found {len(parser.schedule)} programs")
            
            return parser.schedule
        except Exception as e:
            logger.error(f"Failed to scrape {url}: {str(e)}", exc_info=True)
            return None
    
    def build_epg(urls):
        xml_tv = ET.Element("tv", attrib={
            "generator-info-name": "custom-epg-generator",
            "generator-info-url": "https://tv-tabla.se"
        })
        
        json_data = {
            "generator": "custom-epg-generator",
            "generator_url": "https://tv-tabla.se",
            "channels": []
        }
        
        for url, channel_id in urls.items():
            schedule = scrape_schedule(url, channel_id)
            if not schedule:
                logger.warning(f"No schedule data found for {url}, skipping channel.")
                continue
            
            channel = ET.SubElement(xml_tv, "channel", id=channel_id)
            display_name = ET.SubElement(channel, "display-name")
            display_name.text = f"Channel {channel_id}"
            
            json_channel = {
                "id": channel_id,
                "name": f"Channel {channel_id}",
                "programs": []
            }
            
            current_date = datetime.now().date()
            
            for i, entry in enumerate(schedule):
                try:
                    time_str = re.sub(r"[^\d:\.]", "", entry["time"])   
                    time_formats = ["%H:%M", "%H.%M"]
                    start_time = None
                    for fmt in time_formats:
                        try:
                            start_time = datetime.strptime(time_str, fmt).time()
                            break
                        except ValueError:
                            continue
                    
                    if not start_time:
                        logger.warning(f"Could not parse time: {entry['time']}")
                        continue
                    
                    start_datetime = datetime.combine(current_date, start_time) + TIME_OFFSET
                    if i < len(schedule) - 1:
                        next_time_str = re.sub(r"[^\d:\.]", "", schedule[i + 1]["time"])
                        next_time = None
                        for fmt in time_formats:
                            try:
                                next_time = datetime.strptime(next_time_str, fmt).time()
                                break
                            except ValueError:
                                continue
                        
                        if next_time:
                            next_start_datetime = datetime.combine(current_date, next_time) + TIME_OFFSET
                            if next_start_datetime < start_datetime:
                                next_start_datetime += timedelta(days=1)
                            stop_datetime = next_start_datetime
                        else:
                            stop_datetime = start_datetime + timedelta(minutes=30)
                    else:
                        stop_datetime = start_datetime + timedelta(minutes=30)
                    
                    start = start_datetime.strftime("%Y%m%d%H%M%S +0000")
                    stop = stop_datetime.strftime("%Y%m%d%H%M%S +0000")
                    
                    programme = ET.SubElement(xml_tv, "programme", start=start, stop=stop, channel=channel_id)
                    title = ET.SubElement(programme, "title", lang="sv")
                    title.text = entry.get("program", "Unknown Program")
                    desc = ET.SubElement(programme, "desc", lang="sv")
                    desc.text = entry.get("description", "No description available")
                    
                    json_program = {
                        "start": start,
                        "stop": stop,
                        "title": entry.get("program", "Unknown Program"),
                        "description": entry.get("description", "No description available")
                    }
                    json_channel["programs"].append(json_program)
                    
                except Exception as e:
                    logger.error(f"Error processing program entry: {str(e)}", exc_info=True)
            
            json_data["channels"].append(json_channel)
            logger.info(f"Added programs for channel {channel_id}")
        
        xml_tree = ET.ElementTree(xml_tv)
        xml_tree.write(args.xmlPath, encoding="UTF-8", xml_declaration=True)
        logger.info(f"EPG XML data written to {args.xmlPath}")
        
        if args.jsonPath:
            with open(args.jsonPath, 'w', encoding='utf-8') as json_file:
                json.dump(json_data, json_file, ensure_ascii=False, indent=2)
            logger.info(f"EPG JSON data written to {args.jsonPath}")
        
        return json_data

    urls = {
        "https://tv-tabla.se/tabla/svt1/": "1",
        "https://tv-tabla.se/tabla/svt2/": "2",
        "https://tv-tabla.se/tabla/tv3/": "3",
        "https://tv-tabla.se/tabla/tv4/": "4",
        "https://tv-tabla.se/tabla/kanal_5/": "5",
        "https://tv-tabla.se/tabla/tv6/": "6",
        "https://tv-tabla.se/tabla/sjuan/": "7",
        "https://tv-tabla.se/tabla/tv8/": "8",
        "https://tv-tabla.se/tabla/kanal_9/": "9",
        "https://tv-tabla.se/tabla/tv10/": "10",
        "https://tv-tabla.se/tabla/tv_11/": "11",
        "https://tv-tabla.se/tabla/tv12/": "12",
        "https://tv-tabla.se/tabla/tv4_hockey/": "13",
        "https://tv-tabla.se/tabla/tv4_sport_live_1/": "14",
        "https://tv-tabla.se/tabla/tv4_sport_live_2/": "15",
        "https://tv-tabla.se/tabla/tv4_sport_live_3/": "16",
        "https://tv-tabla.se/tabla/tv4_sport_live_4/": "17",
    }    
    # logger.setLevel(logging.DEBUG) 
    build_epg(urls)
  '';
in {
  yo.scripts.tv-scraper = {
    description = "Scrapes web for tv-listing data.";
    category = "⚡ Productivity";
    autoStart = false;
    logLevel = "INFO";
#    helpFooter = '' # 🦆 says ⮞ TODO Show what is on da TVB usin' glow
#    '';
    parameters = [
      { name = "epgFilePath"; description = "Path to storage of the xml EPG file"; optional = false; default = "/home/" + config.this.user.me.name + "/tvepg.xml"; }
      { name = "jsonFilePath"; description = "Optional option to write as JSON file in addation to the EPG"; optional = true; default = "/home/" + config.this.user.me.name + "/epg.json"; }      
    ];
    code = ''
      ${cmdHelpers}
      ${scraper} --xmlPath "$epgFilePath" --jsonPath "$jsonFilePath"
    '';
  };
 
  yo.bitch.intents.tv-guide = {
    data = [{
      sentences = [
        "vilken kanal går {search} på"  
        "vad sänds på {channel} just nu"
        
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
          { "in" = "sport live 1"; out = "14"; }   
          { "in" = "sport live 2"; out = "15"; }   
          { "in" = "sport live 3"; out = "16"; }   
          { "in" = "sport live 4"; out = "17"; }                                           
        ];
        search.wildcard = true;
      };
    }];
  };
  yo.scripts.tv-guide = {
    description = "TV-guide assistant..";
    category = "🎧 Media Management";
    autoStart = false;
    logLevel = "DEBUG";
#    helpFooter = '' # 🦆 says ⮞ TODO Show what is on da TVB usin' glow
#    '';
    parameters = [
      { name = "epgFilePath"; description = "Path to storage of the xml EPG file"; optional = false; default = "/home/" + config.this.user.me.name + "/tvepg.xml"; }
      { name = "jsonFilePath"; description = "Optional option to write as JSON file in addation to the EPG"; optional = true; default = "/home/" + config.this.user.me.name + "/epg.json"; }      
    ];
    code = ''
      ${cmdHelpers}
      current_time=$(date -u +"%Y%m%d%H%M%S +0000")
      
      format_time() {
        local time_str="$1"
        local date_part=$(echo "$time_str" | cut -c1-8)
        local time_part=$(echo "$time_str" | cut -c9-14)
        local timezone=$(echo "$time_str" | awk '{print $2}')   
        date -d "$date_part $time_part $timezone" +"%H:%M" 2>/dev/null || echo "$time_str"
      }
      
      get_channel_name() {
        ${pkgs.jq}/bin/jq -r --arg id "$1" '
          .channels[] | select(.id == $id) | .name
        ' "$jsonFilePath"
      }
      
      if [ -n "${channel:-}" ]; then
        echo "Kollar vad som går på kanal $channel just nu..."
        program=$(${pkgs.jq}/bin/jq -r --arg chan "$channel" --arg now "$current_time" '
          .programs[] | 
          select(.channel_id == $chan and .start <= $now and .stop >= $now) |
          "\(.title) [\(.start)]"
        ' "$jsonFilePath")
        
        if [ -z "$program" ]; then
          channel_name=$(get_channel_name "$channel")
          echo "Inget program hittades på $channel_name just nu."
        else
          title=$(echo "$program" | cut -d'[' -f1)
          start_time=$(echo "$program" | awk -F'[][]' '{print $2}')
          end_time=$(${pkgs.jq}/bin/jq -r --arg chan "$channel" --arg start "$start_time" '
            .programs[] | 
            select(.channel_id == $chan and .start == $start) |
            .stop
          ' "$jsonFilePath")
          
          channel_name=$(get_channel_name "$channel")
          echo ""
          echo "┌──────────────────────────────────────┐"
          echo "│ Kanal: $channel_name"
          echo "├──────────────────────────────────────┤"
          echo "│ Program: $title"
          echo "│ Tid:    $(format_time "$start_time") - $(format_time "$end_time")"
          echo "└──────────────────────────────────────┘"
        fi
      
      elif [ -n "${search:-}" ]; then
        echo "Söker efter program som matchar: $search"
        
        results=$(${pkgs.jq}/bin/jq -r --arg query "$search" --arg now "$current_time" '
          .programs[] | 
          select(
            (.title | test($query; "i")) and 
            (.start <= $now) and 
            (.stop >= $now)
          ) | 
          "\(.channel_id)|\(.title)|\(.start)"
        ' "$jsonFilePath")
        
        if [ -z "$results" ]; then
          echo "Inga aktuella program matchade din sökning."
        else
          echo ""
          echo "Program som matchar '$search' och går just nu:"
          echo "┌───────┬───────────────────────────┬──────────────┐"
          echo "│ Kanal │ Program                   │ Tid          │"
          echo "├───────┼───────────────────────────┼──────────────┤"
          
          while IFS='|' read -r chan_id title start_time; do
            channel_name=$(get_channel_name "$chan_id")
            # Shorten long titles
            short_title=$(echo "$title" | cut -c1-25)
            # Format time range
            end_time=$(${pkgs.jq}/bin/jq -r --arg chan "$chan_id" --arg start "$start_time" '
              .programs[] | 
              select(.channel_id == $chan and .start == $start) |
              .stop
            ' "$jsonFilePath") 
            time_range="$(format_time "$start_time")-$(format_time "$end_time")" 
            printf "│ %-5s │ %-25s │ %-12s │\n" \
              "$chan_id" "$short_title" "$time_range"
          done <<< "$results"  
          echo "└───────┴───────────────────────────┴──────────────┘"
        fi  
      else
        echo "Aktuella program just nu:" 
        results=$(${pkgs.jq}/bin/jq -r --arg now "$current_time" '
          .programs[] | 
          select(.start <= $now and .stop >= $now) | 
          "\(.channel_id)|\(.title)|\(.start)"
        ' "$jsonFilePath")
     
        if [ -z "$results" ]; then
          echo "Inga aktuella program hittades."
        else
          echo "┌───────┬──────────────────────────────────────┬──────────────┐"
          echo "│ Kanal │ Program                              │ Tid          │"
          echo "├───────┼──────────────────────────────────────┼──────────────┤"
          
          while IFS='|' read -r chan_id title start_time; do
            channel_name=$(get_channel_name "$chan_id")

            short_title=$(echo "$title" | cut -c1-30)

            end_time=$(${pkgs.jq}/bin/jq -r --arg chan "$chan_id" --arg start "$start_time" '
              .programs[] | 
              select(.channel_id == $chan and .start == $start) |
              .stop
            ' "$jsonFilePath")
            
            time_range="$(format_time "$start_time")-$(format_time "$end_time")"
            printf "│ %-5s │ %-30s │ %-12s │\n" \
              "$chan_id" "$short_title" "$time_range"
          done <<< "$results"   
          echo "└───────┴──────────────────────────────────────┴──────────────┘"
        fi
      fi
    '';   
  };}  
