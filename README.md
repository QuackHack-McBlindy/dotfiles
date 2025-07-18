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

🦆 _duck say ⮞_ __Oh hellow? please quack on in,__ <br>
🦆 _duck say ⮞_ __while duckie quite stuckie in dis endless rabbit hole__ <br>

## **📌 Highlights** 

- 🛖 **[Simple Home Management](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/modules/home.nix)** *(auto symlinks ./home to /home)*  
- 🛠️ **[yo CLI](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/modules/yo.nix)** *(CLI framework - dynamically generates scripts executables & much more Nix+Bash+🦆 )*    
- 🎙️ **[Nix/Bash NLP](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/config/nlp.nix)** *(Translates natural language to yo scripts - Dynamic regex+Automatic parameter resolution+++ Speak directly to your Shell)* 
- 📡 **[Smart Home](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/network/zigbee.nix)** *(Nix Smart Home - Living right down the Rabbit Hole)* 
- 🛡️ **[Dynamic WireGuard Server](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/modules/networking/wg-server.nix)** *(with automatic QR codes for mobile devices)* 
- 🗣️ **[Language-Aware TTS](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/packages/say.nix)** *(LangID & Piper, TTS notifications, Orca plugin)* 
- 🦊 **[Firefox as Code](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/modules/programs/firefox.nix)** *(Extensions, Bookmarks & Settings)* 
- 📥 **[Declarative Self-Hosted Services](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/modules/virtualisation/arr.nix)** *(Servarr, Navidrome, ...)* 
- 🎨 **[Global Theme Orchestration](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/modules/themes/default.nix)** *(GTK, icons, cursor, Discord, Firefox & Shell)* 
- 📝 **[Self-Documenting](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/productivity/git.nix)** *(CLI usage, Git tags & README.md)*

<br>

__Here lives home machines configurations,__  
__crafted as a tiny Nix flake__  
__Glued together by a Nix-flavoured command line utility,__  
__easiy expanded and used to deploy, doc, and duck around__ 🦆✨  
  
  
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
  extraGroups = [ "networkmanager" "wheel" "dialout" "docker" "dockeruser" "users" "pungkula" "adbusers" "audio" ];
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
    services = [ "ssh" "adb" "backup" "cache" "keyd" ];
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
  styles = "/nix/store/jjpxcqg77c5y1bywlg3zgfwn9bcwcigk-source/modules/themes/css/gtk3.css"
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
{  # 🦆 duck say ⮞ welcome to
    description = "❄️🦆 ⮞ QuackHack-McBLindy's big dot of flakyfiles with extra quackz.";
    inputs = { # 🦆 duck say ⮞ inputz stuff
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";        
        sops-nix.url = "github:Mic92/sops-nix";
        sops-nix.inputs.nixpkgs.follows = "nixpkgs";  
        caddy-duckdns.url = "github:QuackHack-McBlindy/nix-caddy-duckdns";
        installer.url = "github:QuackHack-McBlindy/auto-installer-nixos";
    }; # 🦆 duck say ⮞ outputz other ducky stuffz
    outputs = inputs @ { self, systems, nixpkgs, ... }:
        let
            lib = import ./lib { 
                inherit self inputs;
                lib = nixpkgs.lib;      
            };                   
        in lib.makeFlake { # 🦆 duck say ⮞ make my flake
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
│   │   ├───go omitted (use '--all-systems' to show)
│   │   ├───java omitted (use '--all-systems' to show)
│   │   ├───node omitted (use '--all-systems' to show)
│   │   ├───python omitted (use '--all-systems' to show)
│   │   ├───python312 omitted (use '--all-systems' to show)
│   │   └───rust omitted (use '--all-systems' to show)
│   └───x86_64-linux
│       ├───android: development environment 'nix-shell'
│       ├───go: development environment 'nix-shell'
│       ├───java: development environment 'nix-shell'
│       ├───node: development environment 'nix-shell'
│       ├───python: development environment 'nix-shell'
│       ├───python312: development environment 'nix-shell'
│       └───rust: development environment 'nix-shell'
├───nixosConfigurations
│   ├───desktop: NixOS configuration
│   ├───homie: NixOS configuration
│   ├───laptop: NixOS configuration
│   └───nasty: NixOS configuration
├───overlays
│   ├───beutifulsoup: Nixpkgs overlay
│   ├───ddgs: Nixpkgs overlay
│   └───noisereduce: Nixpkgs overlay
└───packages
    ├───aarch64-linux
    │   ├───health omitted (use '--all-systems' to show)
    │   ├───installer omitted (use '--all-systems' to show)
    │   ├───say omitted (use '--all-systems' to show)
    │   ├───tv omitted (use '--all-systems' to show)
    │   └───yo-bitch omitted (use '--all-systems' to show)
    └───x86_64-linux
        ├───health: package 'health'
        ├───installer: package 'nixos-auto-installer-24.05.20240406.ff0dbd9-x86_64-linux.iso'
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
## 🚀 **yo CLI 🦆🦆🦆🦆🦆🦆**
**Usage:** `yo <command> [arguments]`  

**yo CLI config mode:** `yo config`, `yo edit` 

``` 
❄️ yo CLI Tool
🦆 ➤ Edit hosts
     Edit flake
     Edit yo CLI scripts
     🚫 Exit
``` 

### **Usage Examples:**  
The yo CLI supports flexible parameter parsing through two primary mechanisms:  

```bash
# Named Parameters  
$ yo deploy --host laptop --flake /home/pungkula/dotfiles

# Positional Parameters
$ yo deploy laptop /home/pungkula/dotfiles

# Scripts can also be executed with voice, by saying:
"yo bitch deploy laptop"

# If the server is not running, it can be manually started with:
$ yo transcription
$ yo wake

# Get list of all defined sentences for voice commands:
$ yo bitch --help
```

### ✨ Available Commands
Set default values for your parameters to have them marked [optional]
| Command Syntax               | Aliases    | Description |
|------------------------------|------------|-------------|
| **🖥️ System Management** | | |
| `yo deploy --host [--flake] [--user] [--repo] [--port] [--!]` | d | Build and deploy a NixOS configuration to a remote host. Bootstraps, builds locally, activates remotely, and auto-tags the generation. |
| `yo dev [--devShell]` |  | Start development enviorment |
| `yo duckTrace [--file]` | log | View duckTrace logs quick and quack. |
| `yo reboot [--host]` | restart | Force reboot and wait for host |
| `yo rollback --host [--flake] [--user]` |  | Rollback a host to a previous NixOS generation. Fetches Git tags and reverts system+config to a synced, tagged state. |
| `yo switch [--flake] [--!]` | rb | Rebuild and switch Nix OS system configuration |
| **** | | |
| `yo blindsDown ` |  |  |
| `yo blindsUp ` |  |  |
| `yo fanOff ` |  |  |
| `yo fanOn ` |  |  |
| `yo goodmorning ` |  |  |
| `yo goodnight ` |  |  |
| `yo indoorTemp ` |  |  |
| **⚙️ Configuration** | | |
| `yo bitch --input` |  | Natural language to Shell script translator with dynamic regex matching and automatic parameter resolutiion |
| `yo edit ` | config | yo CLI configuration mode |
| `yo mic [--port] [--host] [--seconds]` |  | Trigger microphone recording sent to transcription. |
| `yo say --text [--model] [--modelDir] [--silence] [--host]` |  | Text to speech with built in language detection and automatic model downloading |
| `yo tests [--debug]` |  | Automated unit testing |
| `yo train --phrase` |  | Trains the NLP module. Correct misclassified commands and update NLP patterns |
| `yo transcribe [--port] [--model] [--language] [--beamSize] [--gpu] [--cert] [--key]` |  | Transcription server-side service. Sit and waits for audio that get transcribed and returned. |
| `yo wake [--threshold] [--cooldown] [--sound] [--remoteSound] [--redisHost] [--redis_pwFIle]` |  | Run Wake word detection for audio recording and transcription |
| **⚡ Productivity** | | |
| `yo askDuck --question [--area] [--minScoreThreshold] [--phrasesFilePath] [--searchDepth] [--fallback] [--loop]` | duck | Ask da duck any question - Quacktastic assistant |
| `yo calculator --expression` | calc | Calculate math expressions |
| `yo calendar --operation` | kal | Calendar assistant |
| `yo fzf ` | f | Interactive fzf search for file content with quick edit & jump to line |
| `yo pull [--flake]` | pl | Pull the latest changes from your dotfiles repo. Safely resets local state and syncs with origin/main cleanly. |
| `yo push [--flake] [--repo] [--host] [--generation]` | ps | Commit, tag, and push dotfiles and system state to GitHub. Tags based on host + generation, auto-updates README, and preserves history. |
| `yo scp ` |  | Move files between hosts interactively |
| **🌍 Localization** | | |
| `yo travel --arrival [--departure] [--type] [--apikeyPath]` |  | Public transportation helper. Fetches current bus and train schedules. (Sweden) |
| `yo weather [--location] [--day] [--condition]` | weat | Tiny Weather Report. |
| **🌐 Networking** | | |
| `yo block --url [--blocklist]` | ad | Block URLs using DNS |
| `yo notify --message [--topic] [--device] [--base_urlFile]` |  | Send Notifications eazy as-quick quack done |
| `yo notify-me [--topic] [--device] [--base_urlFile] [--sound]` |  | Listener for notifications and run actions |
| `yo speed ` | st | Test your internets Download speed |
| **🎧 Media Management** | | |
| `yo news [--apis] [--playedFile]` |  | API caller and playlist manager for latest Swedish news |
| `yo tv [--typ] [--search] [--device] [--shuffle] [--tvshowsDir] [--moviesDir] [--musicDir] [--musicvideoDir] [--videosDir] [--podcastDir] [--audiobookDir] [--youtubeAPIkeyFile] [--webserver] [--defaultPlaylist] [--favoritesPlaylist] [--max_items]` | remote | Android TV Controller |
| `yo tv-guide [--search] [--channel] [--jsonFilePath]` | tvg | TV-guide assistant.. |
| `yo tv-scraper [--epgFilePath] [--jsonFilePath]` | tvc | Scrapes web for tv-listing data. |
| **🔐 Security & Encryption** | | |
| `yo sops --input [--operation] [--value] [--agePub]` | e | Encrypts a file with sops-nix |
| `yo yubi --operation --input` | yk | Encrypts and decrypts files using a Yubikey and AGE |
| **🛒 Shopping** | | |
| `yo shopping_list [--operation] [--item]` |  | Shopping list management |
| **🛖 Home Automation** | | |
| `yo house [--device] [--state] [--brightness] [--color] [--temperature] [--user] [--passwordfile] [--flake]` |  | Control lights and other home automatioon devices |
| `yo zigduck [--user] [--pwfile]` | zigb, hem | Home Automations at its best! Bash & Nix cool as dat. Runs on single process |
| **🧩 Miscellaneous** | | |
| `yo alarm [--hours] [--minutes] [--sound]` | wakeup | Set an alarm for a specified time |
| `yo joke [--jokeFile]` |  | Tells a quacktastic joke |
| `yo post [--postalCodeFile] [--postalCode]` |  | Search for the next postal delivery day is in Sweden |
| `yo qr --input [--icon] [--output]` |  | Create fun randomized QR codes from input. |
| `yo reminder --about [--date]` | remind | Reminder Assistant |
| `yo suno --about [--date]` | mg | AI generated lyrics and music files powered by Suno |
| `yo tibber [--homeIDFile] [--APIKeyFile]` | el | Fetches home electricity price data |
| `yo time ` |  | Tells time, day and date |
| `yo timer [--minutes] [--seconds] [--hours] [--sound]` |  | Set a timer |
| **🧹 Maintenance** | | |
| `yo clean ` | gc | Run a total garbage collection: Removes old NixOS generations, empty trash, flush tmp files, whipes cache and runs a docker prune |
| `yo health [--host]` | hc | Check system health status across your machines |
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
