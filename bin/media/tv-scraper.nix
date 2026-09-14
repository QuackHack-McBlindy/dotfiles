# dotfiles/bin/media/tv-scraper.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ scrapes tv schedule and buuid epg and html (seen in dash
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ...
} : let # 🦆 says ⮞ dependencies
  # 🦆 says ⮞ gen json from `config.house.tv`
  channelsJson = pkgs.writeText "channels.json" (builtins.toJSON (
    lib.mapAttrs (deviceName: deviceConfig: deviceConfig.channels) config.house.tv
  ));

  # 🦆 says ⮞ mapping of scrape_url 2 channel ID
  urlMappingJson = pkgs.writeText "url-mapping.json" (builtins.toJSON (
    lib.foldl (acc: device:
      acc // lib.mapAttrs' (channelId: channel: {
        name = channel.scrape_url;
        value = channelId;
      }) device.channels
    ) {} (lib.attrValues config.house.tv)
  ));

  # 🦆 says ⮞ channel names map
  channelNamesJson = pkgs.writeText "channel-names.json" (builtins.toJSON (
    lib.foldl (acc: device:
      acc // lib.mapAttrs (channelId: channel: channel.name) device.channels
    ) {} (lib.attrValues config.house.tv)
  ));

  # 🦆 says ⮞ gen json from `config.house.tv`
  tvDevicesJson = pkgs.writeText "tv-devices.json" (builtins.toJSON config.house.tv);

  # 🦆 says ⮞ bleh... got 2 advanced 4 bash - lazy py scrapin' .... quack quack
  pyEnv = pkgs.python3.withPackages (ps: [ ps.requests ps.lxml ]);
  scraper = pkgs.writeScript "tv-scraper.py" ''
    #!${pyEnv}/bin/python
    import os
    import requests
    import re
    import json
    from datetime import datetime, timedelta
    import xml.etree.ElementTree as ET
    import logging
    import argparse
    import tempfile
    import shutil
    from lxml import html

    parser = argparse.ArgumentParser()
    parser.add_argument('--xmlPath', type=str, default=os.path.expanduser("~/epg.xml"))
    parser.add_argument('--jsonPath', type=str, default=None)
    parser.add_argument('--htmlPath', type=str, default=None)
    parser.add_argument('--urlMapping', type=str, required=True, help='Path to URL mapping JSON file')
    parser.add_argument('--channelNames', type=str, required=True, help='Path to channel names JSON file')
    parser.add_argument('--debug-dir', type=str, default=None, help='If set, raw HTML files are saved to this directory')
    args = parser.parse_args()
    temp_dir = tempfile.mkdtemp(prefix="tv_scraper_")
    logging.basicConfig(
        level=logging.INFO,
        format="[🦆📜] %(levelname)s - %(message)s",
        handlers=[
            logging.StreamHandler(),
            logging.FileHandler(os.path.join(temp_dir, 'tv-scraper.log'))
        ]
    )
    logger = logging.getLogger()

    TIME_OFFSET = timedelta(hours=0)

    def scrape_schedule(url, channel_id):
        try:
            headers = {
                "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36",
                "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
                "Accept-Language": "en-US,en;q=0.5",
            }
            logger.info(f"Fetching {url} for channel {channel_id}")
            response = requests.get(url, headers=headers, timeout=10)
            response.raise_for_status()

            if args.debug_dir:
                os.makedirs(args.debug_dir, exist_ok=True)
                debug_path = os.path.join(args.debug_dir, f"{channel_id}.html")
                with open(debug_path, "w", encoding="utf-8") as f:
                    f.write(response.text)
                logger.info(f"Saved debug HTML to {debug_path}")

            tree = html.fromstring(response.content)   # bytes avoids encoding issues

            schedule = []
            rows = tree.xpath('//table[@id="channel-schedule"]//tr')
            for row in rows:
                time_el = row.xpath('.//time')
                title_el = row.xpath('.//a[contains(@class, "program-title")]')
                desc_el = row.xpath('.//p')

                if not time_el or not title_el:
                    continue

                datetime_attr = time_el[0].get('datetime')
                if datetime_attr:
                    time_text = datetime_attr
                else:
                    time_text = time_el[0].text_content().strip()

                title = title_el[0].text_content().strip()
                description = desc_el[0].text_content().strip() if desc_el else "No description"

                schedule.append({
                    "time": time_text,
                    "program": title,
                    "description": description
                })

            logger.info(f"Found {len(schedule)} programs for {channel_id}")
            return schedule

        except Exception as e:
            logger.error(f"Failed to scrape {url}: {str(e)}", exc_info=True)
            return None

    def build_epg(urls, channel_names):
        try:
            xml_tv = ET.Element("tv", attrib={
                "generator-info-name": "DuckEPG-Generator",
                "generator-info-url": "https://tv-tabla.se"
            })
            json_data = {
                "generator": "DuckEPG-Generator",
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
                channel_name = channel_names.get(channel_id, f"Channel {channel_id}")
                display_name.text = channel_name
                json_channel = {
                    "id": channel_id,
                    "name": channel_name,
                    "programs": []
                }
                current_date = datetime.now().date()
                for i, entry in enumerate(schedule):
                    try:
                        # Try to parse full ISO datetime first (from datetime attribute)
                        raw_time = entry["time"]
                        start_dt = None
                        try:
                            start_dt = datetime.fromisoformat(raw_time) + TIME_OFFSET
                        except ValueError:
                            # Fallback to old HH:MM parsing
                            time_str = re.sub(r"[^\d:\.]", "", raw_time)
                            time_formats = ["%H:%M", "%H.%M"]
                            start_time = None
                            for fmt in time_formats:
                                try:
                                    start_time = datetime.strptime(time_str, fmt).time()
                                    break
                                except ValueError:
                                    continue
                            if start_time:
                                start_dt = datetime.combine(current_date, start_time) + TIME_OFFSET
                        if not start_dt:
                            logger.warning(f"Could not parse time: {raw_time}")
                            continue

                        # Determine stop time: next program's start, else +30 min
                        if i < len(schedule) - 1:
                            next_raw = schedule[i + 1]["time"]
                            next_dt = None
                            try:
                                next_dt = datetime.fromisoformat(next_raw) + TIME_OFFSET
                            except ValueError:
                                # Fallback: parse as time and combine with current_date (or next day if before start)
                                next_time_str = re.sub(r"[^\d:\.]", "", next_raw)
                                next_time = None
                                for fmt in time_formats:
                                    try:
                                        next_time = datetime.strptime(next_time_str, fmt).time()
                                        break
                                    except ValueError:
                                        continue
                                if next_time:
                                    next_dt = datetime.combine(current_date, next_time) + TIME_OFFSET
                                    if next_dt < start_dt:
                                        next_dt += timedelta(days=1)
                            if next_dt:
                                stop_dt = next_dt
                            else:
                                stop_dt = start_dt + timedelta(minutes=30)
                        else:
                            stop_dt = start_dt + timedelta(minutes=30)

                        start = start_dt.strftime("%Y%m%d%H%M%S +0000")
                        stop = stop_dt.strftime("%Y%m%d%H%M%S +0000")
                        programme = ET.SubElement(xml_tv, "programme", start=start, stop=stop, channel=channel_id)
                        title = ET.SubElement(programme, "title", lang="sv")
                        title.text = entry.get("program", "Unknown Program")
                        desc = ET.SubElement(programme, "desc", lang="sv")
                        desc.text = entry.get("description", "No description")
                        json_program = {
                            "channel_id": channel_id,
                            "start": start,
                            "stop": stop,
                            "title": entry.get("program", "Unknown Program"),
                            "description": entry.get("description", "No description")
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
        finally:
            try:
                shutil.rmtree(temp_dir)
                logger.info(f"Cleaned up temporary directory: {temp_dir}")
            except Exception as e:
                logger.warning(f"Failed to clean up temp directory {temp_dir}: {e}")

    # 🦆 says ⮞ load URL
    with open(args.urlMapping, 'r') as f:
        urls = json.load(f)

    # 🦆 says ⮞ channel names
    with open(args.channelNames, 'r') as f:
        channel_names = json.load(f)

    # logger.setLevel(logging.DEBUG)
    build_epg(urls, channel_names)
  '';
in {
  environment = {
    systemPackages = [ pkgs.xmlstarlet ];
    # 🦆 says ⮞ share the json epg for duckDash
    etc."epg.json".source =
      "/home/pungkula/epg.json";
    etc."tv.html".source =
      "/home/pungkula/.config/tv.html";
  };

  yo.scripts.tv-scraper = {
    description = "Scrapes web for tv-listing data. Builds EPG and generates HTML.";
    aliases = [ "tvs" ];
    category = "🎧 Media Management";
    autoStart = false;
    runAt = [ "05:00" ]; # 🦆 says ⮞ most tv guides change day around 5ish
    logLevel = "INFO";
    parameters = [
      { name = "epgFilePath"; description = "Path to storage of the xml EPG file"; optional = false; default = "/home/" + config.this.user.me.name + "/tvepg.xml"; }
      { name = "jsonFilePath"; description = "Optional option to write as JSON file in addation to the EPG"; optional = true; default = "/home/" + config.this.user.me.name + "/epg.json"; }
      { name = "htmlOutPath"; description = "Where to save your new TV-guide html file."; optional = true; default = "/home/" + config.this.user.me.name + "/tv.html"; }
      { name = "flake"; description = "Path to the directory containing your flake.nix"; default = config.this.user.me.dotfilesDir; }
    ];
    code = ''
      ${cmdHelpers}
      HTML_OUT="$htmlOutPath"
      FLAKE_DIR="$flake"

      mkdir -p "$(dirname "$HTML_OUT")"

      ${scraper} --xmlPath "$epgFilePath" --jsonPath "$jsonFilePath" --urlMapping "${urlMappingJson}" --channelNames "${channelNamesJson}"

      if [ ! -f "$epgFilePath" ]; then
          dt_error "EPG file not found: $epgFilePath"
          exit 1
      fi

      current_epoch=$(date +%s)

      {
          echo "<!DOCTYPE html>"
          echo "<html>"
          echo "<head>"
          echo "<meta charset=\"UTF-8\">"
          echo "<style>"
          echo "body { font-family: sans-serif; margin: 20px; }"
          echo ".channel { margin: 10px 0; padding: 10px; border-bottom: 1px solid #ccc; }"
          echo ".channel-header { display: flex; align-items: center; margin-bottom: 10px; }"
          echo ".channel-icon { width: 32px; height: 32px; margin-right: 10px; }"
          echo ".channel-name { font-weight: bold; font-size: 1.2em; }"
          echo ".program { margin: 5px 0; padding: 8px; cursor: pointer; border-radius: 4px; transition: background-color 0.2s; }"
          echo ".program:hover { background-color: #f5f5f5; }"
          echo ".program.ended { background-color: #f8f8f8; color: #999; }"
          echo ".program.current { background-color: #fff3cd; border-left: 4px solid #ffc107; }"
          echo ".program-time { color: #666; font-size: 0.9em; margin-right: 10px; font-family: monospace; }"
          echo ".program-title { font-weight: bold; }"
          echo ".program-description { display: none; margin-top: 8px; padding: 8px; background: #f0f0f0; border-radius: 4px; font-size: 0.9em; color: #555; }"
          echo ".program-description.show { display: block; }"
          echo "</style>"
          echo "</head>"
          echo "<body>"

          echo "<!-- 🦆 says ⮞ channels by id -->"
          xmlstarlet sel -t -m "//channel" -v "@id" -o "|" -v "display-name" -n "$epgFilePath" | sort -n -t'|' -k1 | while IFS='|' read -r channel_id channel_name; do
              echo "<div class=\"channel\">"
              echo "<div class=\"channel-header\">"

              icon_found=""
              icon_path="$FLAKE_DIR/modules/themes/icons/tv/$channel_id.png"
              if [ -f "$icon_path" ]; then
                  icon_found="$icon_path"
              fi

              if [ -n "$icon_found" ]; then
                  echo "<img class=\"channel-icon\" src=\"file://$icon_found\" alt=\"$channel_name\">"
              else
                  echo "<div class=\"channel-icon\" style=\"background:#ddd;text-align:center;line-height:32px;\">''${channel_id}</div>"
              fi

              echo "<span class=\"channel-name\">$channel_name</span>"
              echo "</div>"

              echo "<!-- 🦆 says ⮞ channel $channel_id programs -->"
              xmlstarlet sel -t -m "//programme[@channel='$channel_id']" \
                  -v "@start" -o "|" \
                  -v "@stop" -o "|" \
                  -v "title" -o "|" \
                  -v "desc" -n "$epgFilePath" 2>/dev/null | while IFS='|' read -r start stop title desc; do
                  if [ -n "$start" ] && [ -n "$stop" ] && [ -n "$title" ]; then
                      clean_title=$(echo "$title" | sed 's/<[^>]*>//g' | sed 's/&amp;/\&/g; s/&lt;/</g; s/&gt;/>/g; s/&quot;/"/g; s/&apos;/'"'"'/g')
                      clean_desc=$(echo "$desc" | sed 's/<[^>]*>//g' | sed 's/&amp;/\&/g; s/&lt;/</g; s/&gt;/>/g; s/&quot;/"/g; s/&apos;/'"'"'/g')
                      start_date="''${start:0:8}"
                      start_time="''${start:8:4}"
                      stop_time="''${stop:8:4}"

                      start_formatted="''${start_time:0:2}:''${start_time:2:2}"
                      stop_formatted="''${stop_time:0:2}:''${stop_time:2:2}"
                      start_epoch=$(date -d "''${start_date:0:4}-''${start_date:4:2}-''${start_date:6:2} ''${start_formatted}" +%s 2>/dev/null || echo "0")
                      stop_epoch=$(date -d "''${start_date:0:4}-''${start_date:4:2}-''${start_date:6:2} ''${stop_formatted}" +%s 2>/dev/null || echo "0")

                      # 🦆 says ⮞ dynamic updating
                      echo "<div class=\"program\" data-start=\"$start_epoch\" data-end=\"$stop_epoch\" onclick=\"toggleDescription(this)\">"
                      echo "<span class=\"program-time\">''${start_formatted} - ''${stop_formatted}</span>"
                      echo "<span class=\"program-title\">$clean_title</span>"
                      echo "<div class=\"program-description\">$clean_desc</div>"
                      echo "</div>"
                  fi
              done
              echo "</div>"
          done

          echo "<script>"
          echo "function toggleDescription(element) {"
          echo "  const description = element.querySelector('.program-description');"
          echo "  description.classList.toggle('show');"
          echo "}"
          echo ""
          echo "// 🦆 says ⮞ dynamically update current/ended programs"
          echo "function updateCurrentPrograms() {"
          echo "    const now = Math.floor(Date.now() / 1000);"
          echo "    document.querySelectorAll('.program').forEach(program => {"
          echo "        const start = parseInt(program.dataset.start);"
          echo "        const end = parseInt(program.dataset.end);"
          echo "        program.classList.remove('current', 'ended');"
          echo "        if (now >= start && now < end) {"
          echo "            program.classList.add('current');"
          echo "        } else if (now >= end) {"
          echo "            program.classList.add('ended');"
          echo "        }"
          echo "    });"
          echo "}"
          echo ""
          echo "// 🦆 says ⮞ update every minute"
          echo "updateCurrentPrograms();"
          echo "setInterval(updateCurrentPrograms, 60000);"
          echo "</script>"
          echo "</body>"
          echo "</html>"
      } > "$HTML_OUT"

      dt_info "HTML TV-Guide generated: $HTML_OUT"
      echo "HTML TV-Guide generated: $HTML_OUT"
    '';

  };}
