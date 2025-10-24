## 🦆✨ COMMANDS! yo  

🦆🏠  HOME via  via 🐍 v3.12.10 
11:37:13 ❯ yo -h
Optional parameters marked [optional]
# 🦆✨ COMMANDS! yo
Optional parameters are marked [optional]
| Command Syntax | Description |
|----------------|-------------|
| **🖥️ System Management** | |
| [yo duckTrace](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/system/duckTrace.nix) [--script] [--host] | View duckTrace logs quick and quack, unified logging system |
| [yo reboot](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/system/reboot.nix) [--host] | Force reboot and wait for host |
| [yo services](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/system/services.nix) --operation --service --host [--user] [--port] [--!] | Systemd service handler. |
| [yo switch](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/system/switch.nix) [--flake] [--!] | Rebuild and switch Nix OS system configuration |
| **⚙️ Configuration** | |
| [yo say](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/config/say.nix) --text [--model] [--modelDir] [--silence] [--host] [--blocking] [--file] [--caf] | Text to speech with built in language detection and automatic model downloading |
| [yo tests](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/config/tests.nix) [--input] [--stats] | Extensive automated sentence testing for the NLP |
| **⚡ Productivity** | |
| [yo calculator](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/productivity/calculator.nix) --expression | Calculate math expressions |
| [yo calendar](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/productivity/calendar.nix) [--operation] [--calenders] | Calendar assistant. Provides easy calendar access. Interactive terminal calendar, or manage the calendar through yo commands or with voice. |
| [yo clip2phone](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/productivity/clip2phone.nix) --copy | Send clipboard to an iPhone, for quick copy paste |
| [yo google](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/productivity/google.nix) --search [--apiKeyFile] [--searchIDFile] | Perform web search on google |
| [yo hitta](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/productivity/hitta.nix) --search | Locate a persons address with help of Hitta.se |
| [yo pull](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/productivity/pull.nix) [--flake] [--host] | Pull the latest changes from your dotfiles repo. Resets tracked files to origin/main but keeps local extras. |
| **🌍 Localization** | |
| [yo stores](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/stores.nix) --store_name [--location] [--radius] | Finds nearby stores using OpenStreetMap data with fuzzy name matching. Returns results with opening hours. |
| [yo travel](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/travel.nix) [--arrival] [--departure] [--type] [--apikeyPath] | Public transportation helper. Fetches current bus and train schedules. (Sweden) |
| [yo weather](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/weather.nix) [--location] [--day] [--condition] [--locationPath] | Weather Assistant. Ask anything weather related (3 day forecast) |
| **🌐 Networking** | |
| [yo ip-updater](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/network/ip-updater.nix) [--token1] [--token2] [--token3] | DDNS updater |
| [yo shareWiFi](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/network/shareWiFi.nix) [--ssidFile] [--passwordFile] | creates a QR code of guest WiFi and push image to iPhone |
| [yo speed](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/network/speed.nix)  | Test internet download speed |
| **🎧 Media Management** | |
| [yo call-remote](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/media/call-remote.nix)  | Used to call the tv remote, for easy localization. |
| [yo news](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/media/news.nix) [--apis] [--clear] [--playedFile] | API caller and playlist manager for latest Swedish news from SR. |
| [yo tv](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/media/tv.nix) [--typ] [--search] [--device] [--shuffle] [--tvshowsDir] [--moviesDir] [--musicDir] [--musicvideoDir] [--videosDir] [--podcastDir] [--audiobookDir] [--youtubeAPIkeyFile] [--webserver] [--defaultPlaylist] [--favoritesPlaylist] [--max_items] [--mqttUser] [--mqttPWFile] | Android TV Controller. Fuzzy search all media types and creates playlist and serves over webserver for casting. Fully conttrollable. |
| [yo tv-guide](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/media/tv-guide.nix) [--search] [--channel] [--jsonFilePath] | TV-guide assistant.. |
| **🛖 Home Automation** | |
| [yo alarm](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/alarm.nix) --hours --minutes [--list] [--sound] | Set an alarm for a specified time |
| [yo battery](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/battery.nix) [--device] | Fetch battery level for specified device. |
| [yo bed](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/bed.nix) [--part] [--state] | Bed controller |
| [yo blinds](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/blinds.nix) [--state] | Turn blinds up/down |
| [yo chair](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/chair.nix) [--part] [--state] | Chair controller |
| [yo findPhone](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/findPhone.nix)  | Helper for locating Phone |
| [yo house](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/house.nix) [--device] [--state] [--brightness] [--color] [--temperature] [--scene] [--user] [--passwordfile] [--flake] | Control lights and other home automatioon devices |
| [yo kitchenFan](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/kitchenFan.nix) [--state] | Turns kitchen fan on/off |
| [yo state](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/state.nix) [--device] | Fetches the state of the specified device. |
| [yo temperatures](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/temperatures.nix)  | Get all temperature values from sensors and return a average value. |
| [yo tibber](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/tibber.nix) [--mode] [--homeIDFile] [--APIKeyFile] [--filePath] [--user] [--pwfile] | Fetches home electricity price data |
| [yo timer](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/timer.nix) [--minutes] [--seconds] [--hours] [--list] [--sound] | Set a timer |
| [yo toilet](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/toilet.nix)  | Flush the toilet |
| **🧩 Miscellaneous** | |
| [yo chat](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/chat.nix) --text | No fwendz? Let's chat yo! |
| [yo duckPUCK](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/duckPUCK.nix) [--mode] [--team] [--stat] [--dataDir] | duckPUCK is your personal hockey assistant - Expert commentary and analyzer specialized on Hockey Allsvenskan (SWE). Analyzing games, scraping scoreboard and keeping track of all dates annd numbers. |
| [yo hockeyGames](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/hockeyGames.nix) [--type] [--days] [--team] [--dataDir] [--debug] | Hockey Assistant. Provides Hockey Allsvenskan data and deliver analyzed natural language responses (TTS). |
| [yo invokeai](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/invokeai.nix) --prompt [--host] [--port] [--outputDir] [--width] [--height] [--steps] [--cfgScale] [--seed] [--model] | AI generated images powered by InvokeAI |
| [yo joke](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/joke.nix) [--jokeFile] | Duck says s funny joke. |
| [yo post](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/post.nix) [--postalCodeFile] [--postalCode] | Check for the next postal delivery day. (Sweden) |
| [yo reminder](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/reminder.nix) [--about] [--list] [--clear] [--user] [--pwfile] | Reminder Assistant |
| [yo shop-list](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/shop-list.nix) [--operation] [--item] [--list] [--mqttUser] [--mqttPWFile] | Shopping list management |
| [yo suno](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/suno.nix) --prompt [--genre] | AI generated lyrics and music files powered by Suno |
| [yo time](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/time.nix)  | Tells time, day and date |
| **🧹 Maintenance** | |
| [yo health](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/maintenance/health.nix) [--host] | Check system health status across your machines. Returns JSON structured responses. |
 
 
## 🦆🚀 SENTENCES! qwack    
🦆🏠  HOME via  via 🐍 v3.12.10 
11:38:13 ❯ yo do -h
# 🦆 Voice Commands
One-of required words are marked (say|one)
Optional words are marked [no|have|to]

# ⚙️ Configuration

  **yo say**:
🦆 say ⮞    - "imitera mig ANYTHING"

  **yo tests**:
🦆 say ⮞    - "testa mina meningar"
    - "kör röst test\[et|erna\]"
    - "testa röst\[ styrningen\]"



# ⚡ Productivity

  **yo calculator**:
🦆 say ⮞    - "(beräkna|beräknar|räkna|räknar) \[ut\] ANYTHING"
    - "(beräkna|beräknar|räkna|räknar) ut ANYTHING"
    - "lös ekvationen ANYTHING"

  **yo calendar**:
🦆 say ⮞    - "vad har jag planerat \[idag|imorgon\]"
    - "visa min kalender för ANYTHING"
    - "har jag något inbokat \[idag|imorgon\]"
    - "vad händer \[på\] \[dag\] \[idag\]"
    - "vad har jag \[i\] kalendern \[idag\]"
    - "visa \[min\] kalender \[för\] \[idag\]"
    - "kalender \[händelser\] \[idag\]"

  **yo clip2phone**:
🦆 say ⮞    - "kopiera till telefonen"
    - "skicka clipboard till telefonen"

  **yo google**:
🦆 say ⮞    - "sök \[efter|på|om\] ANYTHING på google"
    - "(google|googl) \[efter|på|om\] ANYTHING"

  **yo hitta**:
🦆 say ⮞    - "vad har ANYTHING för adress"
    - "ta reda på ANYTHING adress"
    - "(säg|berätta|hämta) ANYTHING adress"
    - "sök efter ANYTHING på hitta"

  **yo pull**:
🦆 say ⮞    - "(pull|pulla) \[på\] (desktop|nasty|laptop|...)"
    - "(pull|pulla)"



# 🌍 Localization

  **yo stores**:
🦆 say ⮞    - "vilken tid (öppnar|stänger) ANYTHING"
    - "vad har ANYTHING för öppettider"
    - "var är närmaste ANYTHING"
    - "finns det någon ANYTHING i närheten"
    - "när stänger ANYTHING"
    - "när öppnar ANYTHING"

  **yo travel**:
🦆 say ⮞    - "mår går tåget till ANYTHING"
    - "vilken tid går tåget till ANYTHING"
    - "mår går bussen till ANYTHING"
    - "vilken tid går bussen till ANYTHING"
    - "mår går tåget från ANYTHING"
    - "vilken tid går tåget från ANYTHING"
    - "mår går bussen från ANYTHING"
    - "vilken tid går bussen från ANYTHING"
    - "när går (bus|buss|bussen|...) från ANYTHING till ANYTHING"
    - "vilken tid går (bus|buss|bussen|...) från ANYTHING till ANYTHING"
    - "när går (bus|buss|bussen|...) till ANYTHING från ANYTHING"
    - "vilken tid går (bus|buss|bussen|...) till ANYTHING från ANYTHING"

  **yo weather**:
🦆 say ⮞    - "hur är vädret"
    - "vädret"
    - "hur (blir|är) vädret \[på\] (ida|idag|imorgon|...)"
    - "hur (varmt|kallt) (blir|är) det \[på\] (ida|idag|imorgon|...)"
    - "vad blir det för väder \[på\] (ida|idag|imorgon|...)"
    - "hur (sol|soligt|klart|...) (är|blir) det på (ida|idag|imorgon|...)"
    - "blir det (sol|soligt|klart|...) \[på\] (ida|idag|imorgon|...)"
    - "hur (sol|soligt|klart|...) är det"
    - "kommer det att (sol|soligt|klart|...) \[på\] (ida|idag|imorgon|...)"



# 🌐 Networking

  **yo ip-updater**:
🦆 say ⮞    - "uppdatera duckdns"
    - "uppdatera \[mitt\] \[duck\]dns ip"

  **yo shareWiFi**:
🦆 say ⮞    - "dela \[gäst\] (wifi|internet)"
    - "(internet|wifi) delning"
    - "dela \[mitt\] (internet|wifi) för gäster"
    - "dela \[mitt\] (internet|wifi)"

  **yo speed**:
🦆 say ⮞    - "nätverks test"
    - "hur fort går internet"
    - "testa internet hastigheten"



# 🎧 Media Management

  **yo call-remote**:
🦆 say ⮞    - "ring (fjärren|fjärrkontroll|fjärrkontrollen|fjärris)"
    - "hitta (fjärren|fjärrkontroll|fjärrkontrollen|fjärris)"

  **yo news**:
🦆 say ⮞    - "(senast|senaste) (myt|nyt|nytt)"

  **yo tv**:
🦆 say ⮞    - "\[jag\] (spel|spela|kör|start|starta) \[upp|igång\] (serie|serien|tvserien|...) ANYTHING i (sovrum|sovrummet|bedroom|...)"
    - "jag vill se (serie|serien|tvserien|...) ANYTHING i (sovrum|sovrummet|bedroom|...)"
    - "jag vill lyssna på (serie|serien|tvserien|...) i (sovrum|sovrummet|bedroom|...)"
    - "jag vill höra (serie|serien|tvserien|...) ANYTHING i (sovrum|sovrummet|bedroom|...)"
    - "(serie|serien|tvserien|...) (volym|volymen|avsnitt|avsnittet|låt|låten|skiten) i (sovrum|sovrummet|bedroom|...)"
    - "tv (serie|serien|tvserien|...) i (sovrum|sovrummet|bedroom|...)"
    - "\[jag\] (spel|spela|kör|start|starta) \[upp|igång\] (serie|serien|tvserien|...) ANYTHING"
    - "jag vill se (serie|serien|tvserien|...) ANYTHING"
    - "jag vill lyssna på \[mina\] (serie|serien|tvserien|...)"
    - "jag vill höra \[mina\] (serie|serien|tvserien|...)"
    - "(serie|serien|tvserien|...) (volym|volymen|avsnitt|avsnittet|låt|låten|skiten)"
    - "tv (serie|serien|tvserien|...)"
    - "spara i (serie|serien|tvserien|...)"
    - "lägg till den här \[låten\] i (serie|serien|tvserien|...)"
    - "ring (serie|serien|tvserien|...)"
    - "hitta (serie|serien|tvserien|...)"

  **yo tv-guide**:
🦆 say ⮞    - "vilken kanal (spela|spelas|sänds|går|är) ANYTHING på"
    - "vad (sänds|visas|spelas|går) på \[kanal\] (SVT1|1|\[Kanal 10|10\]|...) \[just nu\]"



# 🖥️ System Management

  **yo duckTrace**:
🦆 say ⮞    - "sök \[i\] {service}\[s\] \[log|loggar|loggen\] efter fel på (desktop|datorn|nas|...)"
    - "sök \[i\] {service}\[s\] \[log|loggar|loggen\] efter fel"
    - "sök \[efter\] error på (desktop|datorn|nas|...)"
    - "sök \[efter\] error"
    - "ducktrace ANYTHING"
    - "kolla \[i\] \[log|loggen|loggar|loggarna)\]"

  **yo reboot**:
🦆 say ⮞    - "starta om (desktop|vatten|homie|...) \[dator|datorn\]"
    - "starta om (desktop|vatten|homie|...) \[server|servern\]"

  **yo switch**:
🦆 say ⮞    - "bygg om systemet"



# 🛖 Home Automation

  **yo alarm**:
🦆 say ⮞    - "(ställ|sätt|starta) \[en\] (väckarklocka|väckarklockan|larm|alarm) \[på\] \[klocka|klockan\] (1|2|3|...) \[och\] (0|1|2|...)"
    - "väck mig \[klocka|klockan\] (1|2|3|...) \[och\] (0|1|2|...)"
    - "när ska jag (stiga|vakna|ringer) \[upp\]"
    - "när (stiga|vakna|ringer) min väckarklocka"

  **yo battery**:
🦆 say ⮞    - "hur mycket batteri har (vägg|väggen|\[ikea 5 dimmer|ikea5dimmer|ikea 5 dimmeren\]|...) \[kvar\]"
    - "batteri nivå \[på\] (vägg|väggen|\[ikea 5 dimmer|ikea5dimmer|ikea 5 dimmeren\]|...)"
    - "vad är (batteri|batteronivån) \[nivån\] \[på\] (vägg|väggen|\[ikea 5 dimmer|ikea5dimmer|ikea 5 dimmeren\]|...)"
    - "(berätta|säg) hur mycket batteri (vägg|väggen|\[ikea 5 dimmer|ikea5dimmer|ikea 5 dimmeren\]|...) \[har\] \[kvar\]"

  **yo bed**:
🦆 say ⮞    - "(huvud|huvudet|skallen|sänghuvud) (upp|uppe|up|...)"
    - "(fot|fötter|sängfot) (upp|uppe|up|...)"
    - "säng\[en\] (huvud|huvudet|skallen|...) (upp|uppe|up|...)"

  **yo blinds**:
🦆 say ⮞    - "(persienner|persiennerna) (upp|uppe|ned|...)"
    - "(blind|blinds) (upp|uppe|ned|...)"

  **yo chair**:
🦆 say ⮞    - "stol\[en \](rygg) (upp|uppe|up|...)"
    - "stol\[en\] (ben|fötter) (upp|uppe|up|...)"
    - "stol\[en\] (rygg|back|ben|...) (upp|uppe|up|...)"
    - "stol\[en\] (upp|uppe|up|...)"

  **yo findPhone**:
🦆 say ⮞    - "hitta \[min\] telefon"
    - "var är min telefon"
    - "ring min telefon"

  **yo house**:
🦆 say ⮞    - "(vardagsrum|vardagsrummet|kök|...) (tänd|tända|tänk|...) och färg (röd|rött|röda|...)"
    - "(vardagsrum|vardagsrummet|kök|...) (tänd|tända|tänk|...) och ljusstyrka (1|2|3|...) procent"
    - "(gör|ändra) (vardagsrum|vardagsrummet|kök|...) \[till\] (röd|rött|röda|...) \[färg\] \[och\] (1|2|3|...) procent \[ljusstyrka\]"
    - "(tänd|tänk|släck|starta|stäng) (vardagsrum|vardagsrummet|kök|...)"
    - "ANYTHING alla lampor i (vardagsrum|vardagsrummet|kök|...)"
    - "(tänd|tända|tänk|...) (vardagsrum|vardagsrummet|kök|...) lampor"
    - "(tänd|tända|tänk|...) lamporna i (vardagsrum|vardagsrummet|kök|...)"
    - "(tänd|tända|tänk|...) alla lampor"
    - "stäng (tänd|tända|tänk|...) (vardagsrum|vardagsrummet|kök|...)"
    - "starta (tänd|tända|tänk|...) (vardagsrum|vardagsrummet|kök|...)"
    - "(ändra|gör) färgen \[på|i\] (vardagsrum|vardagsrummet|kök|...) till (röd|rött|röda|...)"
    - "(ändra|gör) (vardagsrum|vardagsrummet|kök|...) (röd|rött|röda|...)"
    - "justera (vardagsrum|vardagsrummet|kök|...) till (1|2|3|...) procent"

  **yo kitchenFan**:
🦆 say ⮞    - "(fläkt|fläck|fkäckt|fläckten|fläkten) (på|av)"

  **yo state**:
🦆 say ⮞    - "är (vägg|väggen|\[ikea 5 dimmer|ikea5dimmer|ikea 5 dimmeren\]|...) på\[slagen\] \[slagen\]"
    - "är (vägg|väggen|\[ikea 5 dimmer|ikea5dimmer|ikea 5 dimmeren\]|...) på eller av"
    - "är (vägg|väggen|\[ikea 5 dimmer|ikea5dimmer|ikea 5 dimmeren\]|...) öppen"
    - "är (vägg|väggen|\[ikea 5 dimmer|ikea5dimmer|ikea 5 dimmeren\]|...) stängd"
    - "är (vägg|väggen|\[ikea 5 dimmer|ikea5dimmer|ikea 5 dimmeren\]|...) \[öppen|stängd\]"
    - "vad är status på (vägg|väggen|\[ikea 5 dimmer|ikea5dimmer|ikea 5 dimmeren\]|...)"
    - "status (vägg|väggen|\[ikea 5 dimmer|ikea5dimmer|ikea 5 dimmeren\]|...)"

  **yo temperatures**:
🦆 say ⮞    - "hur varmt är det (inne|inomhus)"
    - "vad är det för (temp|temperatur) (inne|inomhus)"
    - "hur varmmt är det inne"

  **yo tibber**:
🦆 say ⮞    - "vad kostar strömmen"
    - "hur mycket kostar strömmen"
    - "vad är elpriset just nu"

  **yo timer**:
🦆 say ⮞    - "(skapa|ställ|sätt|starta) \[en\] (time|timer|timern) \[på\] (1|ett|2|...) (timme|timmar) (1|ett|2|...) (minut|minuter) (1|ett|2|...) (sekund|sekunder)"
    - "(skapa|ställ|sätt|starta) \[en\] (time|timer|timern) \[på\] (1|ett|2|...) (minut|minuter) \[och\] (1|ett|2|...) (sekund|sekunder)"
    - "(skapa|ställ|sätt|starta) \[en\] (time|timer|timern) \[på\] (1|ett|2|...) (minut|minuter)"
    - "(skapa|ställ|sätt|starta) \[en\] (time|timer|timern) \[på\] (1|ett|2|...) sekunder"
    - "hur (länge|kvar) är det kvar på (time|timer|timern)"
    - "tid (länge|kvar) på (time|timer|timern)"
    - "när (länge|kvar) (time|timer|timern)"

  **yo toilet**:
🦆 say ⮞    - "färdig\[!\] torka\[!\]"
    - "spola \[toa|toan|toaletten\]"
    - "spola"



# 🧩 Miscellaneous

  **yo chat**:
🦆 say ⮞    - "hej ANYTHING"
    - "hejsan ANYTHING"

  **yo duckPUCK**:
🦆 say ⮞    - "hockey tabellen"
    - "visa hockeytabellen"
    - "hur ser tabellen ut"
    - "visa allsvenska tabellen"
    - "hur ligger lagen till"
    - "vad är ställningen i tabellen"
    - "vad ligger (björklöven|björklövens|löven|...) i tabellen"
    - "visa (björklöven|björklövens|löven|...) statistik"
    - "var ligger (björklöven|björklövens|löven|...) i tabellen"
    - "vilken plats har (björklöven|björklövens|löven|...)"
    - "hur går det för (björklöven|björklövens|löven|...)"
    - "hur ligger (björklöven|björklövens|löven|...) till"
    - "är (björklöven|björklövens|löven|...) på slutspelsplats"
    - "är (björklöven|björklövens|löven|...) på kvalplats"
    - "hur många poäng har (björklöven|björklövens|löven|...)"
    - "visa {team}s statistik"
    - "visa statistik för (björklöven|björklövens|löven|...)"
    - "hur ser {team}s statistik ut"
    - "vad har (björklöven|björklövens|löven|...) för statistik"
    - "ge mig {team}s siffror"
    - "hur går det för (björklöven|björklövens|löven|...) den (förra|senaste|igår|...) tiden"
    - "analysera (björklöven|björklövens|löven|...)"
    - "ge en analys av (björklöven|björklövens|löven|...)"
    - "analysera \[laget\] (björklöven|björklövens|löven|...)"
    - "analysera {team}s (förra|senaste|igår|...) matcher"
    - "hur presterade (björklöven|björklövens|löven|...) i (förra|senaste|igår|...) matchen"
    - "vilka trender har (björklöven|björklövens|löven|...)"
    - "vad har (björklöven|björklövens|löven|...) (för|i) (\[power|powerplay|pp|överläge|numerärt överläge\]|\[box|boxplay|bp|box play|undertal|numerärt underläge\]) (statistik|stats)"
    - "analysera (björklöven|björklövens|löven|...) (\[power|powerplay|pp|överläge|numerärt överläge\]|\[box|boxplay|bp|box play|undertal|numerärt underläge\])"
    - "hur (bra|dåliga|effektiva) är (björklöven|björklövens|löven|...) \[i\] (\[power|powerplay|pp|överläge|numerärt överläge\]|\[box|boxplay|bp|box play|undertal|numerärt underläge\])"
    - "hur presterar (björklöven|björklövens|löven|...) \[i\] (\[power|powerplay|pp|överläge|numerärt överläge\]|\[box|boxplay|bp|box play|undertal|numerärt underläge\])"
    - "hur ser {team}s (\[power|powerplay|pp|överläge|numerärt överläge\]|\[box|boxplay|bp|box play|undertal|numerärt underläge\]) ut"
    - "visa {team}s (\[power|powerplay|pp|överläge|numerärt överläge\]|\[box|boxplay|bp|box play|undertal|numerärt underläge\])"
    - "analysera {team}s (\[power|powerplay|pp|överläge|numerärt överläge\]|\[box|boxplay|bp|box play|undertal|numerärt underläge\])"
    - "ge en analys av {team}s (\[power|powerplay|pp|överläge|numerärt överläge\]|\[box|boxplay|bp|box play|undertal|numerärt underläge\])"
    - "visa (förra|senaste|igår|...) matcher"
    - "vilka matcher spelas (förra|senaste|igår|...)"
    - "visa matcher \[för\] (förra|senaste|igår|...)"
    - "när spelar (björklöven|björklövens|löven|...) (förra|senaste|igår|...) gång"
    - "vilka möter (björklöven|björklövens|löven|...) (förra|senaste|igår|...)"
    - "vilka matcher har (björklöven|björklövens|löven|...) (förra|senaste|igår|...)"
    - "när är {team}s (förra|senaste|igår|...) match"

  **yo hockeyGames**:
🦆 say ⮞    - "(vad|hur) (hände|gick) (det|matchen) (för|med) (björklöven|björklövens|löven|...) (senast|igår)"
    - "(berätta|visa) (om|) (björklöven|björklövens|löven|...) (senaste|sista) match"
    - "(vilka|vad) (hände|resultat) (i|) hockyn (igår|senast)"
    - "senaste hockymatcherna"
    - "allsvenskan matcher"
    - "när (är|spelar) (björklöven|björklövens|löven|...) \[sin\] (kommande|nästa|senaste|...) match"
    - "hur har (björklöven|björklövens|löven|...) spelat \[den\] (kommande|nästa|senaste|...) \[tiden\]"
    - "hur (var|spelade) (björklöven|björklövens|löven|...) (kommande|nästa|senaste|...) matchen"

  **yo joke**:
🦆 say ⮞    - "få höra \[ett\] \[roligt\] skämt"
    - "berätta \[ett\] \[roligt\] skämt"
    - "säg \[ett\] \[roligt\] skämt"
    - "få mig \[att\] skratta"
    - "gör mig glad"

  **yo post**:
🦆 say ⮞    - "när kommer \[nästa\] (post|posten) \[leverans|leveransen\]"
    - "vilken dag kommer posten"

  **yo reminder**:
🦆 say ⮞    - "påminn \[mig\] om \[att\] ANYTHING"
    - "(visa) påminnelser"
    - "(rensa) påminnelser"

  **yo shop-list**:
🦆 say ⮞    - "(lägg|ta|bort|...) till ANYTHING i (inköpslistan|shoppinglistan)"
    - "(lägg|ta|bort|...) ANYTHING till (inköpslistan|shoppinglistan)"
    - "(lägg|ta|bort|...) till ANYTHING på listan"
    - "(lägg|ta|bort|...) till ANYTHING"
    - "(lägg|ta|bort|...) ANYTHING på (inköpslistan|shoppinglistan)"
    - "(lägg|ta|bort|...) \[bort\] ANYTHING (från|i) (inköpslistan|shoppinglistan)"
    - "(lägg|ta|bort|...) \[bort\] ANYTHING (från|i) listan"
    - "(lägg|ta|bort|...) bort ANYTHING"
    - "(lägg|ta|bort|...) ANYTHING från listan"
    - "visa inköpslistan"
    - "vad finns på inköpslistan"
    - "visa listan"
    - "vad är på listan"

  **yo time**:
🦆 say ⮞    - "(va|vad|vart) är klockan"
    - "hur mycket är klockan"
    - "(va|vad|vart) är det för dag"
    - "vilket datum är det"
    - "vad är det för datum"



# 🧹 Maintenance

  **yo health**:
🦆 say ⮞    - "kolla hälsan på (desktop|datorn|nas|...)"
    - "hur mår (desktop|datorn|nas|...)"
    - "mår (desktop|datorn|nas|...) okej"
    - "visa status för (desktop|datorn|nas|...)"



# ----────----──⋆⋅☆☆☆⋅⋆─────----─ #
# Total:  
- **Scripts with voice enabled**: 43 / 75
- **Generated patterns**: 1840
- **Understandable phrases**: 271860062

