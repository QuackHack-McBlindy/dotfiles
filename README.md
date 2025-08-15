# ❄️🦆 **QuackHack-McBLindy NixOS dotfiles** <br>

<!-- VERSIONS_START -->
![NixOS](https://img.shields.io/badge/NixOS-25.11-blue?style=flat-square&logo=NixOS&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-black?style=flat-square&logo=opensourceinitiative&logoColor=white)
![Linux Kernel](https://img.shields.io/badge/Linux-6.12.30-red?style=flat-square&logo=linux&logoColor=white)
![GNOME](https://img.shields.io/badge/GNOME-48.1-purple?style=flat-square&logo=gnome&logoColor=white)
![Bash](https://img.shields.io/badge/bash-5.2.37-red?style=flat-square&logo=gnubash&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.12.10-%23FFD43B?style=flat-square&logo=python&logoColor=white)
![Nix](https://img.shields.io/badge/Nix-2.28.3-blue?style=flat-square&logo=nixos&logoColor=white)
<!-- VERSIONS_END -->

[![Sponsors](https://img.shields.io/github/sponsors/QuackHack-McBlindy?logo=githubsponsors&label=?&style=flat&labelColor=ff1493&logoColor=fff&color=rgba(234,74,170,0.5) "")](https://github.com/sponsors/QuackHack-McBlindy)<div align="right"><sub>

_This is a <abbr title="Magically automated with duck-powered quackery">automagiduckically</abbr> updated README.md_

</sub></div> 


> [!CAUTION]
> __Do not blindly run this flake.__ <br>
> **That's my job.** 🧑‍🦯
<br>

__Oh hellow? please quack on in,__ <br>
__while duckie quite stuckie in dis endless rabbit hole__ <br>

__Here lives home machines configurations,__  
__crafted as a tiny Nix flake__  
__Glued together by a Nix-flavoured command line utility,__  
__easiy expanded and used to deploy, doc, and duck around__ 🦆✨  
 

## **What makes this configuration unique?** 

Nix Declarative configuration style, custom modules evaluated dynamically for each host. <br>
Home Manager - No duckng way. I just auto symlink ./home to /home <br>
Zigbee and smart home deeply integrated with Nix. For not just a declarative house but also deployable apartments. <br>

While building the OS, it will dynamically generating code for esp32 devices which configures: <br>
Webserver with frontend for everything device related. <br>
Zigbee device control UI, RGB and brightness control etc . <br>
Microphone for voice input. <br>

Plug in your device and run `yo esp`. <br>

Self-documented and fully voice controlled. <br>
Input text is proccesed with a Quack Powered Natural language Processor written in Nix & Bash, to dynamically generate millions of regex patterns used for exact matching and async fuzzy matching. <br>
With no parameter limit for resolution for the Shell translator - I can make the fair assumption this is probably a quite niche repository... <br>

<br> 
  
## ❄️ **Flake**

<details><summary><strong>
Define yourself at `config.this.user.me`.
</strong></summary>

<!-- USER_START -->
```nix
{
  discord = "https://discordapp.com/users/675530282849533952";
  dotfilesDir = "/home/pungkula/dotfiles";
  email = "isthisrandomenough@protonmail.com";
  extraGroups = [ "networkmanager" "wheel" "dialout" "docker" "dockeruser" "users" "pungkula" "adbusers" "audio" "2000" ];
  hashedPassword = "$y$j9T$m8hPD36i1VMaO5rurbZ4j0$KpzQyat.F6NoWFKpisEj77TvpN2wBGB8ezd26QoKDj6";
  matrix = "";
  mobileDevices =   {
    iphone =     {
      pubkey = "UFB0T1Y/uLZi3UBtEaVhCi+QYldYGcOZiF9KKurC5Hw=";
      wgip = "10.0.0.7"
    };
    tablet =     {
      pubkey = "ETRh93SQaY+Tz/F2rLAZcW7RFd83eofNcBtfyHCBWE4=";
      wgip = "10.0.0.8"
    };
  };
  name = "pungkula";
  repo = "git@github.com:QuackHack-McBlindy/dotfiles.git"
};
```
<!-- USER_END -->

</details>


<details><summary><strong>
Define each hosts data at `config.this.host`.
</strong></summary>

<!-- HOST_START -->
```nix
{
  hostname = "desktop";
  interface = [ "enp119s0" ];
  ip = "192.168.1.111";
  keys =   {
    privateKeys =     {
    };
    publicKeys =     {
      adb = "QAAAACEJNfsfRV4PQ9Ah87MbTVbMkbXC6CAMDOR+0K6mIpv/4TSzYMkc2qit3Kryc55IVOjwR3fJRjj/uL549gZ7nEemWtcd3AsYQBp0iIEor8nu1L/V6jfsTY6Xe/pl06xoroy6OwZRWuDbZ4wD2xQRRQjfPd+JtYnMAWneM6r1V15uR67w4ITvjk3ckyfgNeLZMUwahMRjC3wSjaU9sAdKNmg8yPd8uHZ+mK6mstxJFAGEpnnm1lE7Z2r0DF6h6MKY1++dwhU+WM5BRDNiBg+D4i6fDW4+Z1I9ENuFnjT17zAxZXch04SNlG3O94BANYP7jmKp60OvtDL6msfphntuIUzMCkndF9De0Kv4lJdQxe1d+wf+AFpmtd/xtrk45YdMV+eWCJf2OkidaHmSj4ffkAobpun0VrkZN2Z1JymmdsvUbyMjAsby3Zun0xr3EocUS8Jy5TcsK/dcpD6CB5dqzlHhsHSAWt2TDwPzZYXgV1xc+q+PqM09OVN1xActJu75UMkg5b84U15hwQvYdwB8UaopMWWk6p064c7gxYSfH7fSxwkW2Jy1CElgJa55Pp4SZG9b/3B+VcNL1WSf6v/lvJqPbrRvBqvS0+e9wcFMNZtQKTX3n5X0wW1/czZPCQX+hmM8Uu1qrtaz4rKViIEGf4YR0/9eUGYQVfuAxAh8ZmsroJlnAAEAAQA= pungkula@desktop";
      age = "age16utg7mmk73cn3glrwthtm0p7mf6g3vrd48h3ucpn6wnf28pgxvcsh4rjjp";
      borg = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMVYczAOBSeS7WfSvzYDOS4Q9Ss+yxCf2G5MVfAALOx/";
      builder = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINQ7c/AeIpmJS6cWQkHOe4ZEq3DXVRnjtTWuWfx6L46n";
      cache = "cache:/pbj1Agw2OoSSDZcClS69RHa1aNcwwTOX3GIEGKYwPc=";
      host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILdwPkRQxlbrbRGwEO5zMJ4m+7QqUQPZg1iqbd5HRP34";
      iPhone = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMcmr+z7k/yCbrFg+JDgo8JCuWqNVYn10ajRbNTp8fq";
      ssh = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPwZL27kGTQDIlSe03abT9F24nSAizORyjo5cI3BD92s";
      wireguard = "Oq0ZaYAnOo5sLpV//OEFwLgjVCxPyeQqf8cZBASluWk="
    };
  };
  modules =   {
    hardware = [ "cpu/intel" "gpu/amd" "audio" ];
    networking = [ "default" "pool" ];
    programs = [ "default" "thunar" "firefox" "vesktop" ];
    services = [ "ssh" "adb" "backup" "cache" "keyd" "jelly" "duck-tv" ];
    system = [ "nix" "pkgs" "gnome" "crossEnv" "gtk" ];
    virtualisation = [ "docker" "vm" ]
  };
  system = "x86_64-linux";
  wgip = "10.0.0.2"
};
```
<!-- HOST_END -->

</details>


<details><summary><strong>
Define any optional theme configuration at `config.this.theme`.
</strong></summary>

<!-- THEME_START -->
```nix
{
  cursorTheme =   {
    name = "Bibata-Modern-Classic";
    package = "/nix/store/1np4cfqil5jh04zmscj3i6h2zvh9yqvv-bibata-cursors-2.0.7";
    size = 32
  };
  enable = false;
  fonts =   {
    monospace = "Fira Code";
    packages = [ "/nix/store/k4s2ckig2pyi2lzzaxmh8wcwbq7n7pz3-fira-code-6.2" ];
    system = "Fira Sans"
  };
  gtkSettings =   {
    gtk-application-prefer-dark-theme = "1";
    gtk-cursor-theme-name = "Bibata-Modern-Classic";
    gtk-icon-theme-name = "elementary-xfce-icon-theme"
  };
  iconTheme =   {
    name = "Papirus-Dark";
    package = "/nix/store/5ncf05fvvy7zmb2azprzq1qhymwh733h-papirus-icon-theme-20250201"
  };
  name = "gtk3.css";
  styles = "/nix/store/nbdydk71q12sazcajdnvrajiib1pcimg-source/modules/themes/css/gtk3.css"
};
```
<!-- THEME_END -->

</details>


<details><summary><strong>
I like my flakes tiny & ny modules dynamically loaded,  
</strong></summary>

<!-- FLAKE_START -->
```nix
# dotfiles/flake.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{
    description = "❄️🦆 ⮞ QuackHack-McBLindy's big dot of flakyfiles with extra quackz.";
    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";        
        sops-nix.url = "github:Mic92/sops-nix";
        sops-nix.inputs.nixpkgs.follows = "nixpkgs";  
        caddy-duckdns.url = "github:QuackHack-McBlindy/nix-caddy-duckdns";
        installer.url = "github:QuackHack-McBlindy/auto-installer-nixos";
    };
    outputs = inputs @ { self, systems, nixpkgs, ... }:
        let
            lib = import ./lib { 
                inherit self inputs;
                lib = nixpkgs.lib;      
            };                   
        in lib.makeFlake {
            systems = [ "x86_64-linux" "aarch64-linux" ]; 
            overlays = lib.mapOverlays ./overlays { inherit lib; };
            hosts = lib.mapHosts ./hosts;
            specialArgs = { pkgs = system: nixpkgs.legacyPackages.${system}; };
            packages = lib.mapModules ./packages import;
            devShells = lib.mapModules ./devShells (path: import path);     
        };} # 🦆 duck say ⮞ flakes all set, with no debating — next nix file awaiting, ducks be there waitin'
```
<!-- FLAKE_END -->
</details>

<br>

<details><summary><strong>
View Flake Outputs
</strong></summary>

  <!-- TREE_START -->
```nix
git+file:///home/pungkula/dotfiles
├───devShells
│   ├───aarch64-linux
│   │   ├───android omitted (use '--all-systems' to show)
│   │   ├───esphome omitted (use '--all-systems' to show)
│   │   ├───go omitted (use '--all-systems' to show)
│   │   ├───java omitted (use '--all-systems' to show)
│   │   ├───node omitted (use '--all-systems' to show)
│   │   ├───python312 omitted (use '--all-systems' to show)
│   │   ├───python38 omitted (use '--all-systems' to show)
│   │   └───rust omitted (use '--all-systems' to show)
│   └───x86_64-linux
│       ├───android: development environment 'nix-shell'
│       ├───esphome: development environment 'nix-shell'
│       ├───go: development environment 'nix-shell'
│       ├───java: development environment 'nix-shell'
│       ├───node: development environment 'nix-shell'
│       ├───python312: development environment 'nix-shell'
│       ├───python38: development environment 'nix-shell'
│       └───rust: development environment 'nix-shell'
├───nixosConfigurations
│   ├───desktop: NixOS configuration
│   ├───homie: NixOS configuration
│   ├───laptop: NixOS configuration
│   └───nasty: NixOS configuration
├───overlays
│   └───noisereduce: Nixpkgs overlay
└───packages
    ├───aarch64-linux
    │   ├───health omitted (use '--all-systems' to show)
    │   ├───installer omitted (use '--all-systems' to show)
    │   ├───jellyfin omitted (use '--all-systems' to show)
    │   ├───say omitted (use '--all-systems' to show)
    │   ├───tv omitted (use '--all-systems' to show)
    │   └───yo-bitch omitted (use '--all-systems' to show)
    └───x86_64-linux
        ├───health: package 'health'
        ├───installer: package 'nixos-auto-installer-24.05.20240406.ff0dbd9-x86_64-linux.iso'
        ├───jellyfin: package 'jellyfin'
        ├───say: package 'say'
        ├───tv: package 'tv'
        └───yo-bitch: package 'yo-bitch'
```
  <!-- TREE_END -->

</details>  
  

## **🛟 Quick Start**

**Build automated, offline USB NixOS installer** 

```bash
$ sudo bash usb-installer \
  --user "pungkula" \
  --host "laptop" \
  --ssid "IfYouDontHaveEthernet" \
  --wifipass "CanBeOmitted" \
  --publickey "ssh-ed25519 AAAAC3FoRSsHCoNnEcTiOn..."
``` 

<br>

```bash
# dd result to flash drive (replace sdX)
$ sudo dd if="$(readlink -f ./result/iso/*.iso)" of=/dev/sdX bs=4M status=progress oflag=sync
``` 

Plug in flash drive into laptop and boot. Let it work and wait until it powers down.  
Remove flash drive, boot it up again and deploy configuration from your main machine:

```bash
# 🦆🔓 First deploy? Get your Yubikey: PIN+Touch unlocks host specific AGE key for sops-nix 
$ yo deploy laptop
```

**Any builds after first deployment will use local cached binaries for enhanced build time.**  

<br>

<!-- YO_DOCS_START -->
## 🚀 **yo CLI 🦆**
**Usage:** `yo <command> [arguments]`  

### **Usage Examples:**  
The yo CLI supports flexible parameter parsing through two primary mechanisms:  

```bash
# Named Parameters  
$ yo deploy --host laptop --flake /home/pungkula/dotfiles

# Positional Parameters
$ yo deploy laptop /home/pungkula/dotfiles

# Scripts can also be executed with natural language text by typing:
$ yo do "is laptop overheatiing"
# Natural language voice commands are also supported, say:
"yo bitch reboot the laptop"

# If the server is not running, it can be manually started with:
$ yo transcription
$ yo wake

# Get list of all defined sentences for voice commands:
$ yo do --help
```

### ✨ Available Commands
Set default values for your parameters to have them marked [optional]
| Command Syntax               | Aliases    | Description | VoiceReady |
|------------------------------|------------|-------------|--|
| **🖥️ System Management** | | | |
| [yo deploy](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/system/deploy.nix) --host [--flake] [--user] [--repo] [--port] [--!] |  | Build and deploy a NixOS configuration to a remote host. Bootstraps, builds locally, activates remotely, and auto-tags the generation. | 📛 |
| [yo dev](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/system/dev.nix) [--devShell] |  | Start development enviorment | 📛 |
| [yo duckTrace](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/system/duckTrace.nix) [--file] | log | View duckTrace logs quick and quack. | 📛 |
| [yo esp](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/system/esp.nix) [--device] [--serialPort] [--ota] [--otaPort] [--OTAPwFile] [--wifiSSID] [--wifiPwFile] [--mqttHost] [--mqttUser] [--mqttPwFile] [--transcriptionHostIP] |  | Declarative firmware deployment tool for ESP32 boards  | 📛 |
| [yo reboot](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/system/reboot.nix) [--host] | restart | Force reboot and wait for host | 📛 |
| [yo rollback](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/system/rollback.nix) --host [--flake] [--user] |  | Rollback a host to a previous NixOS generation. Fetches Git tags and reverts system+config to a synced, tagged state. | 📛 |
| [yo switch](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/system/switch.nix) [--flake] [--!] | rb | Rebuild and switch Nix OS system configuration | 📛 |
| **⚙️ Configuration** | | | |
| [yo do](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/config/do.nix) --input [--fuzzyThreshold] | d | Natural language to Shell script translator with dynamic regex matching and automatic parameter resolutiion | 📛 |
| [yo espaudio](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/config/espaudio.nix)  |  |  | 📛 |
| [yo mic](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/config/mic.nix) [--port] [--host] [--seconds] |  | Trigger microphone recording sent to transcription. | 📛 |
| [yo say](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/config/say.nix) --text [--model] [--modelDir] [--silence] [--host] [--blocking] [--file] |  | Text to speech with built in language detection and automatic model downloading | 📛 |
| [yo tests](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/config/tests.nix) [--input] |  | Extensive automated sentence testing for the NLP | 📛 |
| [yo train](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/config/train.nix) --phrase |  | Trains the NLP module. Correct misclassified commands and update NLP patterns | 📛 |
| [yo transcribe](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/config/transcribe.nix) [--port] [--model] [--language] [--beamSize] [--gpu] [--cert] [--key] |  | Transcription server-side service. Sit and waits for audio that get transcribed and returned. | 📛 |
| [yo wake](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/config/wake.nix) [--threshold] [--cooldown] [--sound] [--remoteSound] [--redisHost] [--redis_pwFIle] |  | Run Wake word detection for audio recording and transcription | 📛 |
| **⚡ Productivity** | | | |
| [yo calculator](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/productivity/calculator.nix) --expression | calc | Calculate math expressions | ✅ |
| [yo calendar](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/productivity/calendar.nix) --operation | kal | Calendar assistant | 📛 |
| [yo fzf](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/productivity/fzf.nix)  | f | Interactive fzf search for file content with quick edit & jump to line | 📛 |
| [yo google](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/productivity/google.nix) --search [--apiKeyFile] [--searchIDFile] | g | Perform web search on google | 📛 |
| [yo pull](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/productivity/pull.nix) [--flake] | pl | Pull the latest changes from your dotfiles repo. Safely resets local state and syncs with origin/main cleanly. | 📛 |
| [yo push](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/productivity/push.nix) [--flake] [--repo] [--host] [--generation] | ps | Commit, tag, and push dotfiles and system state to GitHub. Tags based on host + generation, auto-updates README, and preserves history. | 📛 |
| [yo scp](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/productivity/scp.nix) --host [--path] [--username] [--downloadPath] |  | Move files between hosts interactively | 📛 |
| **🌍 Localization** | | | |
| [yo stores](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/stores.nix) --store_name [--location] [--radius] | store, shop | Finds nearby stores using OpenStreetMap data with fuzzy name matching. Returns results with opening hours. | ✅ |
| [yo travel](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/travel.nix) [--arrival] [--departure] [--type] [--apikeyPath] |  | Public transportation helper. Fetches current bus and train schedules. (Sweden) | ✅ |
| [yo weather](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/weather.nix) [--location] [--day] [--condition] [--locationPath] | weat | Weather Assistant. Ask anything weather related (3 day forecast) | ✅ |
| **🌐 Networking** | | | |
| [yo block](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/network/block.nix) --url [--blocklist] | ad | Block URLs using DNS | 📛 |
| [yo ip-updater](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/network/ip-updater.nix) [--token1] [--token2] [--token3] |  | domain updater | 📛 |
| [yo notify](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/network/notify.nix) --message [--topic] [--base_urlFile] |  | Send Notifications eazy as-quick quack done | 📛 |
| [yo notify-me](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/network/notify-me.nix) [--topic] [--base_urlFile] [--sound] |  | Listener for notifications and run actions | 📛 |
| [yo speed](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/network/speed.nix)  | st | Test your internets Download speed | 📛 |
| **🎧 Media Management** | | | |
| [yo news](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/media/news.nix) [--apis] [--clean] [--playedFile] |  | API caller and playlist manager for latest Swedish news | ✅ |
| [yo transcode](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/media/transcode.nix) [--directory] | trans | Transcode media files | 📛 |
| [yo tv](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/media/tv.nix) [--typ] [--search] [--device] [--shuffle] [--tvshowsDir] [--moviesDir] [--musicDir] [--musicvideoDir] [--videosDir] [--podcastDir] [--audiobookDir] [--youtubeAPIkeyFile] [--webserver] [--defaultPlaylist] [--favoritesPlaylist] [--max_items] | remote | Android TV Controller | ✅ |
| [yo tv-guide](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/media/tv-guide.nix) [--search] [--channel] [--jsonFilePath] | tvg | TV-guide assistant.. | ✅ |
| [yo tv-scraper](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/media/tv-scraper.nix) [--epgFilePath] [--jsonFilePath] | tvc | Scrapes web for tv-listing data. | 📛 |
| **🔐 Security & Encryption** | | | |
| [yo sops](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/security/sops.nix) --input [--operation] [--value] [--output] [--agePub] | e | Encrypts a file with sops-nix | 📛 |
| [yo yubi](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/security/yubi.nix) --operation --input | yk | Encrypts and decrypts files using a Yubikey and AGE | 📛 |
| **🛖 Home Automation** | | | |
| [yo alarm](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/alarm.nix) [--hours] [--minutes] [--sound] | wakeup | Set an alarm for a specified time | ✅ |
| [yo blinds](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/blinds.nix) [--state] |  | Turn blinds up/down | ✅ |
| [yo blink](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/blink.nix) [--duration] [--user] [--passwordfile] |  | Blink all lights for a specified duration | 📛 |
| [yo house](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/house.nix) [--device] [--state] [--brightness] [--color] [--temperature] [--scene] [--user] [--passwordfile] [--flake] |  | Control lights and other home automatioon devices | ✅ |
| [yo indoorTemp](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/indoorTemp.nix)  |  | Get all temperature values from sensors and return a average value. | ✅ |
| [yo kitchenFan](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/kitchenFan.nix) [--state] |  | Turns kitchen fan on/off | ✅ |
| [yo tibber](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/tibber.nix) [--homeIDFile] [--APIKeyFile] [--filePath] | el | Fetches home electricity price data | ✅ |
| [yo timer](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/timer.nix) [--minutes] [--seconds] [--hours] [--sound] |  | Set a timer | ✅ |
| [yo zigduck](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/zigduck.nix) [--user] [--pwfile] | zigb, hem | Home Automations at its best! Bash & Nix cool as dat. Runs on single process | 📛 |
| **🧩 Miscellaneous** | | | |
| [yo joke](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/joke.nix) [--jokeFile] |  | Tells a quacktastic joke | ✅ |
| [yo post](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/post.nix) [--postalCodeFile] [--postalCode] |  | Check for the next postal delivery day. (Sweden) | ✅ |
| [yo qr](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/qr.nix) --input [--icon] [--output] |  | Create fun randomized QR codes from input. | 📛 |
| [yo reminder](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/reminder.nix) [--about] [--list] | remind | Reminder Assistant | 📛 |
| [yo shop-list](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/shop-list.nix) [--operation] [--item] |  | Shopping list management | ✅ |
| [yo suno](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/suno.nix) --about [--date] | mg | AI generated lyrics and music files powered by Suno | 📛 |
| [yo time](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/time.nix)  |  | Tells time, day and date | ✅ |
| **🧹 Maintenance** | | | |
| [yo clean](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/maintenance/clean.nix)  | gc | Run a total garbage collection: Removes old NixOS generations, empty trash, flush tmp files, whipes cache and runs a docker prune | 📛 |
| [yo health](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/maintenance/health.nix) [--host] | hc | Check system health status across your machines | ✅ |
### ❓ Detailed Help
For specific command help: 
`yo <command> --help`
`yo <command> -h`
<!-- YO_DOCS_END -->


## 💬 **Comments?**

**Nix Talk? Or just say tiny flake sucks?**   
**That's cool!**  
**I am all ears. 👀**  

<!-- CONTACT_START -->
[![Discord](https://img.shields.io/badge/Discord-Chat-5865F2?style=flat-square&logo=discord&logoColor=white)](https://discordapp.com/users/675530282849533952)
[![Email](https://img.shields.io/badge/Email-Contact-6D4AFF?style=flat-square&logo=protonmail&logoColor=white)](mailto:isthisrandomenough@protonmail.com)
[![GitHub Discussions](https://img.shields.io/badge/Discussions-Join-181717?style=flat-square&logo=github&logoColor=white)](https://github.com/QuackHack-McBlindy/dotfiles/discussions)

<!-- CONTACT_END -->
