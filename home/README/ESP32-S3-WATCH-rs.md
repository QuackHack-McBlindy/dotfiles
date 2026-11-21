# **ESP32-S3-WATCH-rs**

[![Sponsors](https://img.shields.io/github/sponsors/QuackHack-McBlindy?logo=githubsponsors&label=Sponsor&style=flat&labelColor=ff1493&logoColor=fff&color=rgba(234,74,170,0.5) "")](https://github.com/sponsors/QuackHack-McBlindy) [![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-Sponsor?style=flat&logo=buymeacoffee&logoColor=fff&labelColor=ff1493&color=ff1493)](https://buymeacoffee.com/quackhackmcblindy)


## **ESP32-S3-WATCH**

> [!NOTE]
> **🧑‍🦯 Personal project!**  
> **As I am blind this OS is mostly focused on accessibility through the voice assistant functionality of the watch.**  
> **It has a full graphical user interface -- but it's designed for a blind man, so it's BIG.**  
<br>


**Bare Metal** *(no-std)* voice-driven wearable OS for **ESP32-S3** smartwatch with a high focus on accessibility and smart home and media control. Written in Rust, using `esp-hal` as it's hardware abstraction layer.  
There is no usage of the `ESP-IDF` API in this firmware.   
  
Designed to be used as a personal voice assistant watch with **EXTENSIVE** custom voice commands & **much much more!** *(I flush the toilet with this thing..)*  

*“Source code is the best documentation.“*   

<br>
Be sure to check out the demo usage videos/pictures down below.  
<br>

Its up to [yo](https://github.com/QuackHack-McBlindy/yo) to write your own voice commands.  
My watch can execute **57** different [scripts](https://github.com/QuackHack-McBlindy/dotfiles), and understands **272684913**  different phrases as voice commands **-- with a average processing time of 2,72 ms per command**.  
  
The top-tier performance come from a **deterministic** voice architecture and smart caching inside the voice intents.  
  
  
## **Summary**

- [x] Async & WiFi
- [x] Handle multiple SSID/WiFi alternatives  
- [x] Buttons & Deep Sleep (power-save mode)
- [x] Interactive Shell terminal (Bash syntax over HTTP)
- [x] Remote file upload to the SD card (streamed chunks, POST)
- [x] Remote file download from the SD card (streamed chunks)
- [x] i2s: RX Microphone  
- [x] i2s: TX Speaker  
- [x] i2s: Simultaneous RX & TX  (Full-Duplex)
- [x] Voice Command Execution (Wake word, speech to shell command)
- [x] Push-to-talk feature (more battery effecient)
- [x] Media Player - Stream any audio to speaker (wav, mp3, flac, mp4, ...)
- [x] Fuzzy search & play local media from the SD card. (with downsampling) 
- [x] Browse server stored media in the GUI and cast to TV
- [x] Live bidirectional intercom with backend
- [x] 50+ API endpoints
- [x] On-Device WebServer & Web Media Player (with casting to Android TV)
- [x] Control & start/pause any task from the GUI 
- [x] SSHd (+ client)
- [x] Live feed keyboard input over SSH
- [x] Interactive Shell over SSH
- [x] Broadcasting all text-to-speech to every ESP32 device.   
- [x] tinyWeather app - tap weather page to cycle displayed day (3-day forecast)
- [x] Overclock/underclock CPU at runtime/from GUI
- [x] Automatic filesystem testing (cargo run --release --features sd-test)
- [x] Image Gallery
- [ ] Pinch-to-zoom anywhere
- [ ] Phone calls/text message (HFP)
- [x] WireGuard™ client
- [ ] Entire voice pipeline `no-std` 
- [x] Backend: `yo`

<br>

## **Table Of Contents**

- [Demo](#demo)
- [Overview](#overview)
- [Installation](#installation)
- [Usage](#usage)
  - [Frontend](#frontend)
  - [API](#api)
  - [Media Player](#media-player)
  - [SSH](#ssh)
- [Voice Assistant](#voice-assistant)
  - [Architecture](#architecture)
  - [My Voice Commands](#my-voice-commands)
- [Networking](#networking)  
- [Hardware](#hardware)
- [Graphical User Interface](#graphical-user-interface)
- [Applications](#applications)
- [Power Management/Optimization](#power-management--optimizations)
- [♥️ Sponsor](#sponsor)
- [License](#license)

<br>  


## **Demo**

#### **Voice Assistant Video**  


Turn up volume & hit play.  

[Play voice assistant wake word demo video](https://github.com/user-attachments/assets/357bf377-0874-4f42-8d15-3532c31bc813)

  
**Yes, it's fast!** *(TTS generation is the bottleneck)*  


<br>


[Play demo video of duck-TV](https://github.com/user-attachments/assets/0620ad92-fc35-46b9-bc6d-33b7ace8a9b4)



<br>

[Play demo video of Qwackify](https://github.com/user-attachments/assets/19572217-8631-4e67-9cca-f6afe24042c8)



<br>

#### **Pictures**

**Homescreens (swipe left/right)**   

<a href="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/homescreen1.jpeg">
  <img src="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/homescreen1.jpeg" alt="Homescreen" width="148">
</a>

<a href="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/control_center.jpeg">
  <img src="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/control_center.jpeg" alt="Control Center" width="148">
</a>

<a href="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/battery.jpeg">
  <img src="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/battery.jpeg" alt="Battery" width="148">
</a>

<a href="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/charging.jpeg">
  <img src="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/charging.jpeg" alt="Charging" width="148">
</a>

<a href="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/tinyweather.jpeg">
  <img src="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/tinyweather.jpeg" alt="Tiny Weather" width="148">
</a> <br>

**Launcher - accessed far left at homescreen (in launcher swipe up/down)**  


<a href="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/launcher1.jpeg">
  <img src="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/launcher1.jpeg" alt="Launcher 1" width="148">
</a>

<a href="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/launcher2.jpeg">
  <img src="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/launcher2.jpeg" alt="Launcher 2" width="148">
</a>

<a href="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/launcher3.jpeg">
  <img src="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/launcher3.jpeg" alt="Launcher 3" width="148">
</a> 

<a href="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/launcher4.jpeg">
  <img src="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/launcher4.jpeg" alt="Launcher 4" width="148">
</a> <br>

**Apps/Misc**  

<a href="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/media_player.jpeg">
  <img src="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/media_player.jpeg" alt="Media Player" width="148">
</a> 


<a href="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/calling.jpeg">
  <img src="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/calling.jpeg" alt="Dad is calling" width="148">
</a> <br>

**Settings (swipe left/right between settings, up/down to control)**  

<a href="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/settings0.jpeg">
  <img src="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/settings0.jpeg" alt="Settings 0" width="148">
</a> 

<a href="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/settings1.jpeg">
  <img src="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/settings1.jpeg" alt="Settings 1" width="148">
</a>

<a href="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/settings2.jpeg">
  <img src="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/settings2.jpeg" alt="Settings 2" width="148">
</a> <br>

<a href="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/settings3.jpeg">
  <img src="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/settings3.jpeg" alt="Settings 3" width="148">
</a>

<a href="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/setteings4.jpeg">
  <img src="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/setteings4.jpeg" alt="Settings 4" width="148">
</a>

<a href="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/settings5.jpeg">
  <img src="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/settings5.jpeg" alt="Settings 5" width="148">
</a> <br>

<a href="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/settings6.jpeg">
  <img src="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/settings6.jpeg" alt="Settings 6" width="148">
</a>

<a href="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/settomgs7.jpeg">
  <img src="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/settomgs7.jpeg" alt="Settings 7" width="148">
</a>

<a href="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/settings8.jpeg">
  <img src="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/settings8.jpeg" alt="Settings 8" width="148">
</a> <br>

<a href="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/IMG_2916.jpeg">
  <img src="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/IMG_2916.jpeg" alt="IMG 2916" width="148">
</a>

<a href="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/IMG_2918.jpeg">
  <img src="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/IMG_2918.jpeg" alt="IMG 2918" width="148">
</a>

<a href="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/settings10.jpeg">
  <img src="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/settings10.jpeg" alt="Settings 10" width="148">
</a> <br>

<a href="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/settings11.jpeg">
  <img src="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/settings11.jpeg" alt="Settings 11" width="148">
</a>

<a href="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/settings12.jpeg">
  <img src="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/settings12.jpeg" alt="Settings 12" width="148">
</a>

<a href="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/settings13.jpeg">
  <img src="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/settings13.jpeg" alt="Settings 13" width="148">
</a> <br>

**Settings (info pages (swipe up/down)**

<a href="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/settings_info_0.jpeg">
  <img src="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/settings_info_0.jpeg" alt="Settings Info 0" width="148">
</a>

<a href="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/settings_info_1.jpeg">
  <img src="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/settings_info_1.jpeg" alt="Settings Info 1" width="148">
</a>


<a href="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/settings_info_2.jpeg">
  <img src="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/settings_info_2.jpeg" alt="Settings Info 2" width="148">
</a>

<a href="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/settings_info_3.jpeg">
  <img src="https://raw.githubusercontent.com/quackhack-mcblindy/ESP32-S3-WATCH-rs/main/resource/demo/settings_info_3.jpeg" alt="Settings Info 3" width="148">
</a> <br>


  
**Sorry, I have been told I am the master of blurry pictures.**  
*(how would I know...)*  

There is a video demo from the web-based Qwackify too down below.  

<br>


## **Overview**


*“A powerful voice assistant can make a huge difference for blind people.”*  
*“Imagine yourself stumbling blindly across the room looking for the remote — meanwhile, I cam call it using only my voice.”*  


`ESP32-S3-WATCH-rs` is a `no_std` Rust firmware for the ESP32-S3 based smartwatch. The primary goal is to create a fully voice‑controlled assistant that is highly accessible for blind and visually impaired users. All interactions can be performed via voice, and the graphical interface is designed with large, high‑contrast elements.  

The watch streams audio to a companion backend service called [`yo`](https://github.com/QuackHack-McBlindy/yo), which handles wake word detection, speech‑to‑text, intent recognition and execution, and text‑to‑speech synthesis. The watch itself streams microphone audio, serves TCP server for audio streaming to the speaker, manages notifications, plays media, and serves a web frontend for web based media playback in the browser called **Qwackify**, which is like Jellyfin on steroids - but much more good looking and served directly from a watch.  <br>

The watch also has an internal API serving GET endpoints for controlling options and media playback -- playing local music straight from the micro SD card is as easy as:  <br>
**From your desktop:** `curl http://<ESP_IP>/api/media/search/songs/mysong`.  <br>
**From the watch:** tap the display and swipe left open the app launcher, swipe down to the app `Qwackify` and double tap it to open then press play.  <br>
**Using your voice, say:** `yo bitch! play the duck song`.  

<br>

## **Project Structure & Design**  

I knew that if I did not do this properly like I want it - right away, that it would get really messy, and never get done.  
I amm basically writing a complete voice-driven API on top of every available run-time option of `esp-hal`.   
Modular API and using use statements only when needed, otherwise fully qualified paths everywhere, should help keep things as tiny as possible.      
I also prefer to have some of the extensive code as library crates, it can be useful for other people or simplify usage for myself on my other devices.  

```
📂 ESP32-S3-WATCH-rs
├── 📂 applications
├── 📂 base
│   ├── 📂 routes
│   │   └── 📂 ... 
│   │       └── 📂 ... 
├── 📂 components
├── 📂 crates
│   ├── 📂 barely-fuzzy
│   ├── 📂 embedded-png
│   ├── 📂 embedded-keyboard
│   ├── 📂 es7210
│   ├── 📂 es8311
│   ├── 📂 tinyapi
│   └── 📂 yo-esp
├── 📂 gui
├── 📄 main.rs
└── 📄 state.rs
```


<br>


## **Installation**

<details><summary><strong>
❄️ Using flakes (TODO)
</strong></summary>

*sorry, not yet...*

</details>


<details><summary><strong>
📦 Building from source
</strong></summary>


Configure WiFi and other required seetings in the example `.env` file.  

```bash
$ mv .env.example .env
$ nano .env
```


## **Build and flash!**

```bash
cargo run --release
```


</details>


<details><summary><strong>
🐋 Docker (recommended)
</strong></summary>

```bash
$ git clone https://github.com/QuackHack-McBlindy/ESP32-S3-WATCH-rs
$ cd ESP32-S3-WATCH-rs
```

Configure WiFi and other required seetings in the example `.env` file.  

```bash
$ mv .env.example .env
$ nano .env
```

`docker-compose.yaml` may require you to change the defined serial port.  
To locate the serial port for use with the `docker-compose.yaml` file you can run the following command:  

```bash
$ ls -l /dev/serial/by-id/
```

**Build and Flash!**

```bash
$ docker compose build
$ docker compose up
```


</details>


<br>

## **Usage**


### **Frontend**  

If you prefer to handle your media manually in the web browser - good news!  
Your `ESP32-S3` is now serving a fully featured media player that can cast to your TV's and has built-in transcoding (transcoding on backend).  
You can go ahead and visit your device at:  

`http://<ESP_IP>/`  


https://github.com/user-attachments/assets/bdbd0250-b683-4ffa-b8cb-817d0589df1a 

https://github.com/user-attachments/assets/91760f4f-0f31-439e-bc6b-8d2960c62cd8


<br>


### **API**    

The API is designed to be easily expandable.       
*Fetch all your available endpoints at:* `curl http://<ESP_IP>/api`      
  
  
Using the internal API you can for example set the `ESP32-S3` display brightness to 75 percentage using:    

```bash
curl http://<ESP_IP>/api/settings/display/brightness/75 
```
  

| Endpoint | Description |
|----------|-------------|
| `/` | Serves the web frontend (HTML dashboard) |
| `/favicon.ico` | Serves the favicon |
| `/www/{file}` | Serves static files from the `www` directory |
| `/api` | Returns a plain‑text list of all available API endpoints |
| `/api/process/{value}` | Process a plain text natural language sentence and executes corresponding script with extracted parameters. |
| `/api/shell/{value}` | Send a Shell command (see supported commands below) |
| `/api/sensor/{value}` | Read a single sensor/system value (see supported keys below) |
| `/api/sensors` | Returns all sensor/system values as JSON |
| `/api/weather/update` | Update tinyWeather data |
| `/api/download/file/music/{filename}` | Download a song from the SD card’s `/Music` directory |
| `/api/download/file/share/{filename}` | Download any file from the `/share` directory of the SD card |
| `/api/upload/file/music/{filename}` | Upload a song to the SD card’s `/Music` directory **Note: POST** |
| `/api/media/gallery` | Draws `path` on the display. If no path is provided, the gallery is drawn. |
| `/api/media/prev` | Sends `previous` command to the media player – plays previous track |
| `/api/media/next` | Sends `next` command to the media player – plays next track |
| `/api/media/play_pause` | Toggles play/pause |
| `/api/media/heart` | Saves currently playing track to your favourite playlist |
| `/api/media/search/song/{value}` | Fuzzy search for the best single match and play it |
| `/api/media/search/songs/{value}` | Fuzzy search up to 10 matches and add them to the playlist |
| `/api/media/playlist/add/{value}` | Add a song (exact filename/path) to the playlist |
| `/api/media/playlist/remove/{value}` | Remove a song (exact filename/path) from the playlist |
| `/api/media/playlist/clear` | Clear the entire temporary playlist |
| `/api/media/playlist/fav` | Plays favourite playlist. Add/remove with heart. |
| `/api/settings/api/off` | Stops the internal API (including webserver). **Note: use GUI to turn back on** |
| `/api/settings/ssh/{value}` | Enable/disable/toggle the SSH server (`on`, `off`, `toggle`) |
| `/api/settings/sleep` | Enter deep sleep immediately |
| `/api/settings/sleep/reset` | Reset the deep‑sleep timer |
| `/api/settings/power/low/{value}` | Toggle low‑power mode (`on`, `off`, `toggle`) |
| `/api/settings/cpu/{value}` | Set CPU frequency (`80`, `160`, `240`) |
| `/api/settings/mic/volume/{value}` | Set microphone gain (0–100%). `{value}` as integer percent |
| `/api/settings/mic/mute/{value}` | Mute/unmute mic: `1`/`on`/`mute`, `0`/`off`/`unmute`, or `toggle` |
| `/api/settings/speaker/{value}` | Toggle speaker task on/off |
| `/api/settings/speaker/stream/{value}` | Toggle speaker streaming task on/off |
| `/api/settings/speaker/volume/{value}` | Set speaker volume (0–100%). Automatically handles mute/unmute & amplifier state |
| `/api/settings/speaker/mute/{value}` | Mute/unmute speaker: same options as mic mute |
| `/api/settings/speaker/amp/{value}` | Amplifier power: `on`, `off`, or `toggle` |
| `/api/settings/speaker/play/ding` | Play a test “ding” sound on the speaker |
| `/api/settings/voice/{value}` | Enable/disable/toggle the entire voice pipeline (`on`, `off`, `toggle`) |
| `/api/settings/voice/wakeword/{value}` | Enable/disable wake‑word streaming (`on`, `off`, `enable`, `disable`) |
| `/api/settings/voice/intercom/{value}` | Start/stop bidirectional live intercom mode with the backend.  |
| `/api/settings/vpn/{value}` | Enable/disable/toggle the VPN client (`on`, `off`, `toggle`) |
| `/api/settings/display/brightness/{value}` | Set backlight brightness (0–100%). `{value}` as integer percent |
| `/api/settings/display/state/{value}` | Set display state (`on`, `off`, `toggle`) |
| `/api/settings/display/page/{value}` | Change display page. `{value}` integer: 0=clock, 1=battery, 2=apps, 10=media player, etc. |
| `/api/settings/display/text/{value}` | Displays the provided value as a large text on the display |
| `/api/settings/display/call/{value}` | Show the incoming call screen with the caller’s name. The watch can accept/decline the call |
| `/api/settings/display/redraw` | Force a full redraw of the display |
| `/api/settings/display/redraw/loop/{value}` | Enable/disable the redraw loop (`on`, `off`) |
| `/api/settings/wifi/off` | Turns off the WiFi **Note: use GUI to turn back on** |
| `/api/settings/wifi/scan` | Trigger a WiFi scan (results printed to serial/log) |




### Supported sensor keys for `/api/sensor/{value}`

| Key(s)                                                       | Description                         |
|--------------------------------------------------------------|-------------------------------------|
| `battery`, `battery_level`, `battery_percentage`             | Battery charge in percent           |
| `battery_voltage`, `voltage`                                 | Battery voltage in millivolts       |
| `battery_charging`                                           | Charging status                     |
| `battery_need_charging`                                      | Low battery warning                 |
| `battery_full`                                               | Battery full flag                   |
| `battery_usb_connected`                                      | USB connection status               |
| `brightness`, `display`                                      | Display brightness (0–100)          |
| `display_state`                                              | Display power state                 |
| `display_timeout`, `screen_timeout`                          | Display auto‑off timeout (seconds)  |
| `rssi`, `wifi_signal`, `wifi`                                | Wi‑Fi signal strength in dBm        |
| `ip`                                                         | Device IPv4 address                 |
| `cpu`, `cpu_freq`, `cpu_speed`                               | Current CPU frequency in MHz        |
| `speaker`                                                    | Speaker volume (0–100)              |
| `mic`                                                        | Microphone gain (0–100)             |
| `uptime`                                                     | System uptime (e.g., "02h 15m 30s") |
| `time`                                                       | Current time in HH:MM:SS            |
| `firmware`, `version`                                        | Firmware version string             |
| `mic_muted`                                                  | Microphone mute state               |
| `speaker_muted`                                              | Speaker mute state                  |
| `speaker_task_state`                                         | Speaker task running                |
| `speaker_allow_streaming`                                    | Streaming allowed flag              |
| `amplifier_state`                                            | Audio amplifier power state         |         
| `low_power`, `low_power_mode`, `power_save`                  | Low‑power mode state                |
| `sd_ready`                                                   | SD card ready status                |
| `media_is_playing`                                           | Media playback active               |
| `ssh`, `ssh_state`                                           | SSH server state                    |
| `vpn`, `vpn_state`                                           | VPN client state   
| `powerdown_timeout`, `sleep_timeout`                         | Deep‑sleep timeout (seconds)        |



### **Shell**

A Bash‑like interactive shell over HTTP.  
Commands are issued via `GET /api/shell/{command}`.  
Spaces must be encoded as `%20`, and slashes inside paths as `%2F`.  

**Examples:**  

```bash
# `ls /Music`
curl "http://<ESP_IP>/api/shell/ls%20%2FMusic"
```

Or check what is on the SD card from browser, visit: `http://<ESP_IP>/api/shell/tree`  
You should see something like:  

```
📂 .
├── 📂 Music
│   ├── 🎵 ducksong-1.mp3  
│   └── 🎵 ducksong-gangstarap.mp3
└── 📂 share
    └──  image.jpeg
```


| Command | Description |
|---------|-------------|
| `--help` or `help` | Print shell documentation and examples |
| `ls [path]` | List directory contents (relative or absolute) |
| `cd [path]` | Change working directory (`.` = stay, `..` = up one, `...` = up two, no arg = root) |
| `pwd` | Print current working directory |
| `nano <file>` | Creates a text file (TODO) |
| `cat <file>` | Display text file content |
| `hexdump <file>` | Show binary file in hexadecimal (truncated to ~500 chars) |
| `rm <file>` | Delete a file (no confirmation) |
| `mv <file> <path>` | Moves a file **Note: moving of very large is not possible** |
| `jq <file>` | Parse JSON file (TODO) |
| `tree [path]` | Recursive directory listing |



> **Persistence:** The shell keeps state – `cd` into a directory, then `ls` and `cat` will use that directory for relative paths.  
> Use `pwd` to see where you are.  


<br>



### **Media Player** 


> [!NOTE]
> __🎵 Media Player__ <br>
> **Media player supports any file format, and can play any file or playlist.**  
> **You can use the provided `scripts/play-esp.sh` helper script to stream audioo to the device speaker.**
<br>

<br>


### **SSH**  

The SSH server uses `ed25519` key authentication.  
If you want a fixed host key on the watch you can generate a secret key by running the command `./scripts/generate_host_key` from the project root. This will create a hex encoded key which can be placed in the `.env` file.  
Omitting this step is perfectly fine - but you should be aware that a new host key will be used for every connection.  
*(See the `.env.example` file for example usage.)*  
  

The SSHd is running on port  2222 and can be started/stopped at any time from the settings page in the GUI.  
The Shell gives the user full control of the device over a secure conection and supports both named and positional parameters.  
Once a connection has been established you can type `keyboard` to start a live keyboard input feed to the device.  
Type `help` to see all available commands.  


<br>
 
## **Voice Assistant**

Wake word detection is disabled by default to save battery.  
Hold the `BOOT` button to send voice commands, release it when done talking.   

### **Architecture**

Check out the official [yo repository](https://github.com/QuackHack-Mcblindy/yo).  

<br>

The **yo** voice assistant employs a dual-language architecture that separates grammar compilation from runtime interpretation.  
This design allows for a **rapid** fast, deterministic, and privacy-first offline-capable system.  
  
The architecture is fundamentally split into two parts:  

- **Compile-Time (Nix):** Acts as a grammar compiler. It takes declarative sentence templates from configuration files, expands them into all possible variants, and pre-compiles them into optimized regular expressions.  

- **Runtime (Rust):** Functions as a deterministic interpreter. It takes audio input, matches it against the pre-compiled patterns, extracts any defined parameters, and executes the corresponding script with those arguments.  

<br>

So - no more bad, expensive strategies like:  

> * speech ➤ LLM ➤ guess intent  

Instead the flow looks like:   

> * speech ➤ deterministic intent match ➤ script  

<br>

**Result:** Designed for speeed and safety. All heavy lifting is done at build-time.   

<br>


### **My Voice Commands**

<!-- MY_VOICE_COMMANDS_START -->

My voice assistant can currently execute **57** voice scripts.   
That is **2503** regex patterns and makes a total of **272684913** understandable phrases available as voice commands.  

| Command Syntax | Description |
|---|---|
| [yo deploy](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/system/deploy.nix) --host [--flake] [--user] [--repo] [--port] [--test] | Build and deploy a NixOS configuration to a remote host. Bootstraps, builds locally, activates remotely, and auto-tags the generation. |
| [yo reboot](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/system/reboot.nix) [--host] | Force reboot and wait for host |
| [yo services](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/system/services.nix) --operation --service --host [--user] [--port] [--!] | Systemd service handler. |
| [yo switch](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/system/switch.nix) [--flake] [--!] | Rebuild and switch Nix OS system configuration. ('!' to test) |
| [yo call](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/call.nix) --contactName --contactFile | Calls phone number from contact list |
| [yo text](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/text.nix) --contactName --contactFile | Text message a phone number from contact list |
| [yo calculator](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/productivity/calculator.nix) --expression | Calculate math expressions |
| [yo calendar](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/productivity/calendar.nix) [--operation] [--calenders] | Calendar assistant. Provides easy calendar access. Interactive terminal calendar, or manage the calendar through yo commands or with voice. |
| [yo clip2phone](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/productivity/clip2phone.nix) --copy | Send clipboard to an iPhone, for quick copy paste |
| [yo hitta](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/productivity/hitta.nix) --search | Locate a persons address with help of Hitta.se |
| [yo pull](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/productivity/pull.nix) [--flake] [--host] | Pull the latest changes from your dotfiles repo. Resets tracked files to origin/main but keeps local extras. |
| [yo search](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/productivity/search.nix) --search [--token-file] [--num-results] | Perform web search using Kagi with Quick Answer |
| [yo stores](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/stores.nix) --store_name [--location] [--radius] | Finds nearby stores using OpenStreetMap data with fuzzy name matching. Returns results with opening hours. |
| [yo travel](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/travel.nix) [--to] [--from] [--type] [--apikeyPath] | Public transportation helper. Fetches current bus, boat, train and air travel schedules. (Sweden) |
| [yo weather](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/weather.nix) [--location] [--day] [--condition] [--locationPath] | Weather Assistant. Ask anything weather related (3 day forecast) |
| [yo ip-updater](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/network/ip-updater.nix) [--token1] [--token2] [--token3] | DDNS updater |
| [yo shareWiFi](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/network/shareWiFi.nix) [--ssidFile] [--passwordFile] | creates a QR code of guest WiFi and push image to iPhone |
| [yo speed](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/network/speed.nix) | Test internet download speed |
| [yo call-remote](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/media/call-remote.nix) | Used to call the tv remote, for easy localization. |
| [yo news](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/media/news.nix) [--apis] [--clear] | API caller and playlist manager for latest Swedish news from SR. |
| [yo tv](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/media/tv.nix) [--typ] [--search] [--device] [--season] [--shuffle] [--tvshowsDir] [--moviesDir] [--musicDir] [--musicvideoDir] [--videosDir] [--podcastDir] [--audiobookDir] [--youtubeAPIkeyFile] [--webserver] [--defaultPlaylist] [--favoritesPlaylist] [--max_items] [--mqttUser] [--mqttPWFile] | Android TV Controller. Fuzzy search all media types and creates playlist and serves over webserver for casting. Fully controllable. |
| [yo tv-guide](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/media/tv-guide.nix) [--search] [--channel] [--jsonFilePath] | TV-guide assistant.. |
| [yo copy](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/files/copy.nix) --from --to | Copy a file or directory to a new location |
| [yo list](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/files/list.nix) [--path] | List directory contents with details |
| [yo makedir](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/files/makedir.nix) --path | Create a new directory with parents if needed |
| [yo move](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/files/move.nix) --from --to | Move a file or directory to a new location |
| [yo nano](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/files/nano.nix) --file --content | Write content to filepath |
| [yo remove](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/files/remove.nix) --target | Remove files or directories safely |
| [yo alarm](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/alarm.nix) --hours --minutes [--list] [--sound] | Set an alarm for a specified time |
| [yo battery](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/battery.nix) [--device] | Fetch battery level for specified device. |
| [yo bed](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/bed.nix) [--part] [--state] | Bed controller |
| [yo blinds](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/blinds.nix) [--state] | Turn blinds up/down |
| [yo chair](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/chair.nix) [--part] [--state] | Chair controller |
| [yo display](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/display.nix) --path | Creates a HTML image that can be displayed on the chat frontend. |
| [yo findPhone](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/findPhone.nix) | Helper for locating Phone |
| [yo house](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/house.nix) [--device] [--state] [--brightness] [--color] [--temperature] [--scene] [--all-lights] [--room] [--json] [--hue-key-file] | High-performance unified CLI for controlling all smart home devices. |
| [yo kitchenFan](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/kitchenFan.nix) [--state] | Turns kitchen fan on/off |
| [yo lights](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/lights.nix) [--state] | Lights toggle |
| [yo state](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/state.nix) [--device] | Fetches the state of the specified device. |
| [yo temperatures](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/temperatures.nix) | Get all temperature values from sensors and return a average value. |
| [yo tibber](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/tibber.nix) [--mode] [--homeIDFile] [--APIKeyFile] [--filePath] [--user] [--pwfile] | Fetches home electricity price data |
| [yo timer](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/timer.nix) [--minutes] [--seconds] [--hours] [--list] [--sound] | Set a timer |
| [yo toilet](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/toilet.nix) | Flush the toilet |
| [yo btc](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/btc.nix) [--filePath] [--user] [--pwfile] | Crypto currency BTC price tracker |
| [yo chat](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/chat.nix) --text | No fwendz? Let's chat yo! |
| [yo duckPUCK](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/duckPUCK.nix) [--mode] [--team] [--stat] [--count] [--dataDir] | [🏒🦆] - Your Personal Hockey Assistant! - Expert commentary and analyzer specialized on Hockey Allsvenskan (SWE). Analyzing games, scraping scoreboards and keeping track of all dates and numbers. |
| [yo hockeyGames](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/hockeyGames.nix) [--type] [--days] [--team] [--dataDir] [--debug] | Hockey Assistant. Provides Hockey Allsvenskan data and deliver analyzed natural language responses (TTS). |
| [yo invokeai](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/invokeai.nix) --prompt [--host] [--port] [--outputDir] [--width] [--height] [--steps] [--cfgScale] [--seed] [--model] | AI generated images powered by InvokeAI |
| [yo joke](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/joke.nix) [--jokeFile] | Duck says a funny joke. |
| [yo post](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/post.nix) [--postalCodeFile] [--postalCode] | Check for the next postal delivery day. (Sweden) |
| [yo reminder](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/reminder.nix) [--about] [--list] [--clear] [--user] [--pwfile] | Reminder Assistant |
| [yo shop-list](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/shop-list.nix) [--operation] [--item] [--list] [--mqttUser] [--mqttPWFile] | Shopping list management |
| [yo suno](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/suno.nix) --prompt [--genre] | AI generated lyrics and music files powered by Suno |
| [yo timee](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/timee.nix) | Tells time, day, date & week |
| [yo xmr](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/xmr.nix) [--filePath] [--user] [--pwfile] | Crypto currency XMR price tracker |
| [yo duckTrace](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/maintenance/duckTrace.nix) [--script] [--host] [--errors] [--monitor] | View duckTrace logs quick and quack, unified logging system |
| [yo health](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/maintenance/health.nix) | Check system health status across your machines. Returns JSON structured responses. |
<!-- MY_VOICE_COMMANDS_END -->

<br>  


## **Networking**


**WiFi**  

User may provide multiple SSID connections using environment variables through the `.env` file *(see .env.example)*.  
If the connection to the first provided SSID fails it will automatically try the next one in the file.  
If none of the pre-defined networks has a successful connection, a wireless network scan is performed and it will try to connect to any open network.  
This should be safe since all network traffic are routed through the VPN task *(see below)*.  
You will hear a "ding" sound, when a network connection has been established.  

WiFi connection can be toggled on/off via the GUI from the settings page, and also lets the user scan for other availaable networks.  

<br>

**WireGuard™ VPN**  

The watch runs a WireGuard™ client to ensure a secure connection to the users home network and that the `yo` backend is always available.  
Just drop your WireGuard™ peer configuration file (most often generated by the server) in the project root as `.wg-client.conf`.   


User can toggle the VPN on/off at any time from the settings page using the GUI.  

<br>

## **Hardware**

<details><summary><strong>
Specs and GPIO
</strong></summary>

**Display: CO5300**  

Screen width: 33.09 mm  
Screen height: 40.51 mm  

QSPI_SIO0 > GPIO4  
QSPI_SI1 > GPIO5  
QSPI_SI2 > GPIO6  
QSPI_SI3 > GPIO7  
QSPI_SCL > GPIO11  

LCD_CS > GPIO12  
LCD_RESET > GPIO8  
LCD_TE > GPIO13  
  
**Touch: FT3168**  
  
RESET > GPIO9  
Interrupt > GPIO38  
I2C_SDA > GPIO15  
I2C_SCL > GPIO14  
  
**PMU: AXP2101**  

I2C_SDA > GPIO15  
I2C_SCL > GPIO14  

(Controlled by DSI_PWR_EN)  

**6-Axis IMU: QMI8658**  

Interrupt > GPIO21  
I2C_SDA > GPIO15  
I2C_SCL > GPIO14  
  
**RTC: PCF85063**  

Interrupt > GPIO39  
I2C_SDA > GPIO15  
I2C_SCL > GPIO14  
  
**Audio**  

I2C for configuration:  
I2C_SDA > GPIO15  
I2C_SCL > GPIO14  
  
**Speaker: ES8311**  
  
I2S_ASDOUT > GPIO42  
I2S_MCLK > GPIO16  
I2S_SCLK > GPIO41  

**Microphone: ES7210**  
     
I2S_LRCK > GPIO45  
I2S_DSDIN > GPIO40  
  
**Storage**  
  
32MB Flash + 8MB PSRAM  
  
**Micro SD Card**  
  
MOSI > GPIO1  
SCK > GPIO2  
MISO > GPIO3  
SDCS > GPIO   
  
**Buttons / Control**  
  
BOOT > GPIO0  
PWR > GPIO10  
PA_CTRL > GPIO46  
  
</details>

<details><summary><strong>
DEVICE DIMENSIONS (unit: mm)
</strong></summary>

**Front View**  
  
Overall width: 42.00 mm  
Overall height: 50.80 mm  
Screen width (inner): 33.09 mm  
Screen height (inner): 40.51 mm  
Corner radius: R9.2  

**Side View**  

Thickness (main body): 12.90 mm  
Maximum thickness: 13.60 mm  

**Back View**  
  
Top section width: 22.00 mm  
Bottom section width: 22.00 mm  
Label: ESP32-S3-Touch-AMOLED-2.06  

**Strap**  
  
Total length: 250.00 mm  
Strap width: 22.00 mm  
  
</details>


<br>

## **Graphical User Interface**

You boot up at the clock page.  
Swiping down from the very top of the screen slides down the control center which has 4 quick access button slots.  
Swipe left to get to the app launcher, which has 1x1 big icons that smoothly scrolls like a list.  
Tapping an app does nothing (to prevent accidental openings).  
Double tap will open the application.  
A upwards swipe gesture from the very bottom will close the open application and send user back to homescreen (clock page).  
  

Going right from the clock page will show the battery page which has a clean looking ARC gauge with an bolt when charging.   

To the right of the battery page we have **tinyWeather** which shows temperature and a big weather icon.     

Inside the **Qwackify** (media player) application clicking the Qwackify icon will split the view into two pieces that slide apart and show the playlist.  
The trashcan will clear the temporary playlist without confirmation.  
CLicking the heart icon will save current song to your favourite playlist.  

<br>


## **Applications**  

**Settings** - From the settings application user can control all settings at runtime using toggle switch buttons in the GUI and/or swipe gestures, like speaker volume swipe up/down for example.  
All the embassy-executor tasks can also be started/paused from this application.  


**Qwackify** - a media player that plays local MP3 files with play/pause & previous/next track buttons, title & progress bar.  
It also allows saving favourite songs by tapping a heart icon - marking them as favourite.  
The media player slides apart into two pieces and displays the playlist when the Qwackify icon is tapped, which allows the user to select any song to play from the playlist. Tap the trashcan icon to clear the playlist.  
While in the application the two hardware buttons on the watch control the playback volume.  

**duck-TV** - a TV controller application that lets the user browse media stored on external server.  
Tapping on chosen media instantly casts it for playback on a Android TV device. Application also has prev/next track control buttons as well as play/puase.  
While in the application the two hardware buttons on the side of the watch control the TV volume.  


**tinyWeather** - More of a widget than an app really. Displays the current temperature and an icon representing the weather state on the display. Tapping anywhere on the weather page will cycle between current weather and a three day forecast.  
  
**Caller** - simple application that starts bidirectional audio streaming between the watch and the backend server. This effectively creates a intercom session which lets user talk with a desktop computer while away.  
  
**Gallery** - swipe between images stored in `/share` directory on the SD card.  

  
Will extend with more applications as I think of any useful ones.  

<br>


## **Power Management & Optimizations**  

User control all tasks/peripherals and even the clock speed from the GUI, and therefore handle their own battery optimizations and have full control of battery lifetime.  

<br>


## **Sponsor**

[![Sponsors](https://img.shields.io/github/sponsors/QuackHack-McBlindy?logo=githubsponsors&label=Sponsor&style=flat&labelColor=ff1493&logoColor=fff&color=rgba(234,74,170,0.5) "")](https://github.com/sponsors/QuackHack-McBlindy) [![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-Sponsor?style=flat&logo=buymeacoffee&logoColor=fff&labelColor=ff1493&color=ff1493)](https://buymeacoffee.com/quackhackmcblindy)

### **☕**

> 🦆🧑‍🦯 says ⮞ Hi! I'm QuackHack-McBlindy!  
> Like my work?  
> Buy me a coffee, or become a sponsor.  
> Thanks for supporting open source/hungry developers ♥️🦆!   

♥️₿ *Wallet:* `pungkula.x`  
<a href="https://www.buymeacoffee.com/quackhackmcblindy" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>



<br>

## **License**

This project is licensed under the terms of the MIT license.  
See the `LICENSE` file in the repository for full details.
