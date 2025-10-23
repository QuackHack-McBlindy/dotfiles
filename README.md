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


__Here lives home machines configurations,__  
__crafted as a tiny Nix flake__  
__Glued together by a Nix-flavoured command line utility,__  
__easiy expanded and used to deploy, doc, and duck around__ 🦆✨  
 

## **What makes this configuration unique?** 

Nix Declarative configuration style, custom modules evaluated dynamically for each host. <br>
Home Manager - No duckng way. I just auto symlink ./home to /home <br>
Zigbee and smart home tightly integrated with Nix. For not just a declarative house but also deployable apartments. <br><br>

<!-- SCRIPT_STATS_START -->
- __74 qwacktastic scripts in /bin - 41 scripts have voice commands.__ <br>
- __1170 dynamically generated regex patterns - makes 91214840 phrases available as commands.__ <br>
<!-- SCRIPT_STATS_END -->
- __Smart Home Nix style__ <br>
- __Natural Language support with complete voice pipeline__ <br>
- __Infra as everyday accessibility__ <br>
- __Yubikey encrypted deployment system__ <br>
- __Self Documenting__<br>

_List would get long, very quackly._ <br>
_perhaps a more suitable question would be:_ <br>
_"What makes this configuration common?_" <br>


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
    services = [ "ssh" "default" "adb" "backup" "cache" "keyd" "jelly" "duck-tv" ];
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
  styles = "/nix/store/90klh0aba91qjr3xxdjlkiik1x8wkcnl-source/modules/themes/css/gtk3.css"
};
```
<!-- THEME_END -->

</details>


<details><summary><strong>
For smart home integration, define your devices at `config.house`.
</strong></summary>

<!-- SMARTHOME_START -->
<details><summary><strong>
Zigbee devices at `config.house.zigbee.devices`.
</strong></summary>
<!-- ZIGBEE_DEVICES_START -->
```nix
{
  0x000b57fffe0e2a04 = {
    batteryType = null;
    endpoint = 1;
    friendly_name = "Vägg";
    icon = "mdi:lightbulb";
    room = "hallway";
    supports_color = false;
    type = "light";
  };
  0x000b57fffe0f0807 = {
    batteryType = null;
    endpoint = 1;
    friendly_name = "IKEA 5 Dimmer";
    icon = "mdi:remote";
    room = "other";
    supports_color = false;
    type = "remote";
  };
  0x00158d00053ec9b1 = {
    batteryType = null;
    endpoint = 1;
    friendly_name = "Door Sensor Hall";
    icon = "mdi:door";
    room = "hallway";
    supports_color = false;
    type = "sensor";
  };
  0x00178801001ecdaa = {
    batteryType = null;
    endpoint = 11;
    friendly_name = "Bloom";
    icon = "mdi:lightbulb";
    room = "bedroom";
    supports_color = true;
    type = "light";
  };
  0x00178801021311c4 = {
    batteryType = "AAA";
    endpoint = 1;
    friendly_name = "Motion Sensor Hall";
    icon = "mdi:motion-sensor";
    room = "hallway";
    supports_color = false;
    type = "motion";
  };
  0x0017880102de8570 = {
    batteryType = null;
    endpoint = 11;
    friendly_name = "Rustning";
    icon = "mdi:spotlight";
    room = "livingroom";
    supports_color = true;
    type = "light";
  };
  0x0017880102f0848a = {
    batteryType = null;
    endpoint = 11;
    friendly_name = "Spotlight kök 1";
    icon = "mdi:spotlight";
    room = "kitchen";
    supports_color = false;
    type = "light";
  };
  0x0017880102f08526 = {
    batteryType = null;
    endpoint = 11;
    friendly_name = "Spotlight Kök 2";
    icon = "mdi:spotlight";
    room = "kitchen";
    supports_color = false;
    type = "light";
  };
  0x0017880103406f41 = {
    batteryType = null;
    endpoint = 11;
    friendly_name = "WC 2";
    icon = "mdi:ceiling-light";
    room = "wc";
    supports_color = false;
    type = "light";
  };
  0x001788010361b842 = {
    batteryType = null;
    endpoint = 11;
    friendly_name = "WC 1";
    icon = "mdi:ceiling-light";
    room = "wc";
    supports_color = false;
    type = "light";
  };
  0x00178801037e754e = {
    batteryType = null;
    endpoint = 1;
    friendly_name = "Takkrona 1";
    icon = "mdi:ceiling-light";
    room = "livingroom";
    supports_color = true;
    type = "light";
  };
  0x0017880103a0d280 = {
    batteryType = null;
    endpoint = 11;
    friendly_name = "Uppe";
    icon = "mdi:light-strip";
    room = "kitchen";
    supports_color = true;
    type = "light";
  };
  0x0017880103c73f85 = {
    batteryType = null;
    endpoint = 1;
    friendly_name = "Takkrona 2";
    icon = "mdi:ceiling-light";
    room = "livingroom";
    supports_color = true;
    type = "light";
  };
  0x0017880103c7467d = {
    batteryType = null;
    endpoint = 11;
    friendly_name = "Taket Sovrum 2";
    icon = "mdi:ceiling-light";
    room = "bedroom";
    supports_color = true;
    type = "light";
  };
  0x0017880103c753b8 = {
    batteryType = null;
    endpoint = 1;
    friendly_name = "Takkrona 4";
    icon = "mdi:ceiling-light";
    room = "livingroom";
    supports_color = true;
    type = "light";
  };
  0x0017880103ca6e95 = {
    batteryType = "CR2450";
    endpoint = 1;
    friendly_name = "Dimmer Switch Kök";
    icon = "mdi:toggle-switch";
    room = "kitchen";
    supports_color = false;
    type = "dimmer";
  };
  0x0017880103e0add1 = {
    batteryType = null;
    endpoint = 11;
    friendly_name = "Golvet";
    icon = "mdi:light-strip";
    room = "kitchen";
    supports_color = true;
    type = "light";
  };
  0x0017880103eafdd6 = {
    batteryType = null;
    endpoint = 11;
    friendly_name = "Tak Hall";
    icon = "mdi:ceiling-light";
    room = "hallway";
    supports_color = false;
    type = "light";
  };
  0x0017880103f44b5f = {
    batteryType = null;
    endpoint = 11;
    friendly_name = "Dörr";
    icon = "mdi:light-strip";
    room = "bedroom";
    supports_color = true;
    type = "light";
  };
  0x0017880103f94041 = {
    batteryType = null;
    endpoint = 1;
    friendly_name = "Takkrona 3";
    icon = "mdi:ceiling-light";
    room = "livingroom";
    supports_color = true;
    type = "light";
  };
  0x0017880104051a86 = {
    batteryType = null;
    endpoint = 11;
    friendly_name = "Sänggavel";
    icon = "mdi:light-strip";
    room = "bedroom";
    supports_color = true;
    type = "light";
  };
  0x0017880104540411 = {
    batteryType = null;
    endpoint = 11;
    friendly_name = "PC";
    icon = "mdi:spotlight";
    room = "livingroom";
    supports_color = true;
    type = "light";
  };
  0x0017880104f77d61 = {
    batteryType = "CR2450";
    endpoint = 1;
    friendly_name = "Dimmer Switch Sovrum";
    icon = "mdi:toggle-switch";
    room = "bedroom";
    supports_color = false;
    type = "dimmer";
  };
  0x0017880104f78065 = {
    batteryType = "CR2450";
    endpoint = 1;
    friendly_name = "Dimmer Switch Vardagsrum";
    icon = "mdi:toggle-switch";
    room = "livingroom";
    supports_color = false;
    type = "dimmer";
  };
  0x0017880106156cb0 = {
    batteryType = null;
    endpoint = 11;
    friendly_name = "Taket Sovrum 1";
    icon = "mdi:ceiling-light";
    room = "bedroom";
    supports_color = true;
    type = "light";
  };
  0x0017880109ac14f3 = {
    batteryType = null;
    endpoint = 11;
    friendly_name = "Sänglampa";
    icon = "mdi:lightbulb";
    room = "bedroom";
    supports_color = true;
    type = "light";
  };
  0x0c4314fffe179b05 = {
    batteryType = null;
    endpoint = 1;
    friendly_name = "Fläkt";
    icon = "mdi:power-socket-eu";
    room = "kitchen";
    supports_color = false;
    type = "outlet";
  };
  0x540f57fffe85c9c3 = {
    batteryType = null;
    endpoint = 1;
    friendly_name = "Water Sensor";
    icon = "mdi:water";
    room = "livingroom";
    supports_color = false;
    type = "sensor";
  };
  0x54ef4410003e58e2 = {
    batteryType = null;
    endpoint = 1;
    friendly_name = "Roller Shade";
    icon = "mdi:blinds";
    room = "livingroom";
    supports_color = false;
    type = "blind";
  };
  0x70ac08fffe6497be = {
    batteryType = "CR2032";
    endpoint = 1;
    friendly_name = "On/Off Switch 1";
    icon = "mdi:remote";
    room = "other";
    supports_color = false;
    type = "remote";
  };
  0x70ac08fffe65211e = {
    batteryType = "CR2032";
    endpoint = 1;
    friendly_name = "On/Off Switch 2";
    icon = "mdi:remote";
    room = "other";
    supports_color = false;
    type = "remote";
  };
  0x70ac08fffe9fa3d1 = {
    batteryType = "CR2032";
    endpoint = 1;
    friendly_name = "Motion Sensor Kök";
    icon = "mdi:motion-sensor";
    room = "kitchen";
    supports_color = false;
    type = "motion";
  };
  0xa4c1380afa9f7f3e = {
    batteryType = null;
    endpoint = 1;
    friendly_name = "Smoke Alarm Kitchen";
    icon = "mdi:smoke-detector";
    room = "kitchen";
    supports_color = false;
    type = "sensor";
  };
  0xa4c1382553627626 = {
    batteryType = null;
    endpoint = 1;
    friendly_name = "Power Plug";
    icon = "mdi:power-socket-eu";
    room = "other";
    supports_color = false;
    type = "outlet";
  };
  0xa4c13873044cb7ea = {
    batteryType = null;
    endpoint = 11;
    friendly_name = "Kök Bänk Slinga";
    icon = "mdi:light-strip";
    room = "kitchen";
    supports_color = false;
    type = "light";
  };
  0xa4c138b9aab1cf3f = {
    batteryType = null;
    endpoint = 1;
    friendly_name = "Power Plug 2";
    icon = "mdi:power-socket-eu";
    room = "other";
    supports_color = false;
    type = "outlet";
  };
  0xf4b3b1fffeaccb27 = {
    batteryType = "CR2032";
    endpoint = 1;
    friendly_name = "Motion Sensor Sovrum";
    icon = "mdi:motion-sensor";
    room = "bedroom";
    supports_color = false;
    type = "motion";
  };
}
```
<!-- ZIGBEE_DEVICES_END -->
</details>
<br>
<details><summary><strong>
Zigbee scenes at `config.house.zigbee.scenes`.
</strong></summary>
<!-- ZIGBEE_SCENES_START -->
```nix
{
  Chill Scene = {
    Bloom = {
      brightness = 200;
      color = {
        hex = "#FFB6C1";
      };
      state = "ON";
    };
    Golvet = {
      brightness = 200;
      color = {
        hex = "#40E0D0";
      };
      state = "ON";
    };
    PC = {
      brightness = 200;
      color = {
        hex = "#8A2BE2";
      };
      state = "ON";
    };
    Spotlight Kök 1 = {
      brightness = 200;
      color = {
        hex = "#FFD700";
      };
      state = "OFF";
    };
    Spotlight Kök 2 = {
      brightness = 200;
      color = {
        hex = "#FF8C00";
      };
      state = "OFF";
    };
    Sänggavel = {
      brightness = 200;
      color = {
        hex = "#7FFFD4";
      };
      state = "ON";
    };
    Taket Sovrum 1 = {
      brightness = 200;
      color = {
        hex = "#00CED1";
      };
      state = "ON";
    };
    Taket Sovrum 2 = {
      brightness = 200;
      color = {
        hex = "#9932CC";
      };
      state = "ON";
    };
    Takkrona 1 = {
      brightness = 200;
      color = {
        hex = "#7FFFD4";
      };
      state = "ON";
    };
    Takkrona 2 = {
      brightness = 200;
      color = {
        hex = "#7FFFD4";
      };
      state = "ON";
    };
    Takkrona 3 = {
      brightness = 200;
      color = {
        hex = "#7FFFD4";
      };
      state = "ON";
    };
    Takkrona 4 = {
      brightness = 200;
      color = {
        hex = "#7FFFD4";
      };
      state = "ON";
    };
    Uppe = {
      brightness = 200;
      color = {
        hex = "#FF69B4";
      };
      state = "ON";
    };
  };
  Duck Scene = {
    PC = {
      brightness = 200;
      color = {
        hex = "#00FF00";
      };
      state = "ON";
    };
  };
  Green D = {
    Bloom = {
      brightness = 200;
      color = {
        hex = "#00FF00";
      };
      state = "ON";
    };
    Golvet = {
      brightness = 200;
      color = {
        hex = "#00FF00";
      };
      state = "ON";
    };
    PC = {
      brightness = 200;
      color = {
        hex = "#00FF00";
      };
      state = "ON";
    };
    Spotlight Kök 1 = {
      brightness = 200;
      color = {
        hex = "#00FF00";
      };
      state = "OFF";
    };
    Spotlight Kök 2 = {
      brightness = 200;
      color = {
        hex = "#00FF00";
      };
      state = "OFF";
    };
    Sänggavel = {
      brightness = 200;
      color = {
        hex = "#00FF00";
      };
      state = "ON";
    };
    Taket Sovrum 1 = {
      brightness = 200;
      color = {
        hex = "#00FF00";
      };
      state = "ON";
    };
    Taket Sovrum 2 = {
      brightness = 200;
      color = {
        hex = "#00FF00";
      };
      state = "ON";
    };
    Takkrona 1 = {
      brightness = 200;
      color = {
        hex = "#7FFFD4";
      };
      state = "ON";
    };
    Takkrona 2 = {
      brightness = 200;
      color = {
        hex = "#7FFFD4";
      };
      state = "ON";
    };
    Takkrona 3 = {
      brightness = 200;
      color = {
        hex = "#7FFFD4";
      };
      state = "ON";
    };
    Takkrona 4 = {
      brightness = 200;
      color = {
        hex = "#7FFFD4";
      };
      state = "ON";
    };
    Uppe = {
      brightness = 200;
      color = {
        hex = "#00FF00";
      };
      state = "ON";
    };
  };
  dark = {
    Bloom = {
      state = "OFF";
      transition = 10;
    };
    Dörr = {
      state = "OFF";
      transition = 10;
    };
    Golvet = {
      state = "OFF";
      transition = 10;
    };
    Kök Bänk Slinga = {
      state = "OFF";
      transition = 10;
    };
    PC = {
      state = "OFF";
      transition = 10;
    };
    Rustning = {
      state = "OFF";
      transition = 10;
    };
    Spotlight Kök 2 = {
      state = "OFF";
      transition = 10;
    };
    Spotlight kök 1 = {
      state = "OFF";
      transition = 10;
    };
    Sänggavel = {
      state = "OFF";
      transition = 10;
    };
    Sänglampa = {
      state = "OFF";
      transition = 10;
    };
    Tak Hall = {
      state = "OFF";
      transition = 10;
    };
    Taket Sovrum 1 = {
      state = "OFF";
      transition = 10;
    };
    Taket Sovrum 2 = {
      state = "OFF";
      transition = 10;
    };
    Takkrona 1 = {
      state = "OFF";
      transition = 10;
    };
    Takkrona 2 = {
      state = "OFF";
      transition = 10;
    };
    Takkrona 3 = {
      state = "OFF";
      transition = 10;
    };
    Takkrona 4 = {
      state = "OFF";
      transition = 10;
    };
    Uppe = {
      state = "OFF";
      transition = 10;
    };
    Vägg = {
      state = "OFF";
      transition = 10;
    };
    WC 1 = {
      state = "OFF";
      transition = 10;
    };
    WC 2 = {
      state = "OFF";
      transition = 10;
    };
  };
  dark-fast = {
    Bloom = {
      state = "OFF";
    };
    Dörr = {
      state = "OFF";
    };
    Golvet = {
      state = "OFF";
    };
    Kök Bänk Slinga = {
      state = "OFF";
    };
    PC = {
      state = "OFF";
    };
    Rustning = {
      state = "OFF";
    };
    Spotlight Kök 2 = {
      state = "OFF";
    };
    Spotlight kök 1 = {
      state = "OFF";
    };
    Sänggavel = {
      state = "OFF";
    };
    Sänglampa = {
      state = "OFF";
    };
    Tak Hall = {
      state = "OFF";
    };
    Taket Sovrum 1 = {
      state = "OFF";
    };
    Taket Sovrum 2 = {
      state = "OFF";
    };
    Takkrona 1 = {
      state = "OFF";
    };
    Takkrona 2 = {
      state = "OFF";
    };
    Takkrona 3 = {
      state = "OFF";
    };
    Takkrona 4 = {
      state = "OFF";
    };
    Uppe = {
      state = "OFF";
    };
    Vägg = {
      state = "OFF";
    };
    WC 1 = {
      state = "OFF";
    };
    WC 2 = {
      state = "OFF";
    };
  };
  max = {
    Bloom = {
      brightness = 255;
      color = {
        hex = "#FFFFFF";
      };
      state = "ON";
    };
    Dörr = {
      brightness = 255;
      color = {
        hex = "#FFFFFF";
      };
      state = "ON";
    };
    Golvet = {
      brightness = 255;
      color = {
        hex = "#FFFFFF";
      };
      state = "ON";
    };
    Kök Bänk Slinga = {
      brightness = 255;
      color = {
        hex = "#FFFFFF";
      };
      state = "ON";
    };
    PC = {
      brightness = 255;
      color = {
        hex = "#FFFFFF";
      };
      state = "ON";
    };
    Rustning = {
      brightness = 255;
      color = {
        hex = "#FFFFFF";
      };
      state = "ON";
    };
    Spotlight Kök 2 = {
      brightness = 255;
      color = {
        hex = "#FFFFFF";
      };
      state = "ON";
    };
    Spotlight kök 1 = {
      brightness = 255;
      color = {
        hex = "#FFFFFF";
      };
      state = "ON";
    };
    Sänggavel = {
      brightness = 255;
      color = {
        hex = "#FFFFFF";
      };
      state = "ON";
    };
    Sänglampa = {
      brightness = 255;
      color = {
        hex = "#FFFFFF";
      };
      state = "ON";
    };
    Tak Hall = {
      brightness = 255;
      color = {
        hex = "#FFFFFF";
      };
      state = "ON";
    };
    Taket Sovrum 1 = {
      brightness = 255;
      color = {
        hex = "#FFFFFF";
      };
      state = "ON";
    };
    Taket Sovrum 2 = {
      brightness = 255;
      color = {
        hex = "#FFFFFF";
      };
      state = "ON";
    };
    Takkrona 1 = {
      brightness = 255;
      color = {
        hex = "#FFFFFF";
      };
      state = "ON";
    };
    Takkrona 2 = {
      brightness = 255;
      color = {
        hex = "#FFFFFF";
      };
      state = "ON";
    };
    Takkrona 3 = {
      brightness = 255;
      color = {
        hex = "#FFFFFF";
      };
      state = "ON";
    };
    Takkrona 4 = {
      brightness = 255;
      color = {
        hex = "#FFFFFF";
      };
      state = "ON";
    };
    Uppe = {
      brightness = 255;
      color = {
        hex = "#FFFFFF";
      };
      state = "ON";
    };
    Vägg = {
      brightness = 255;
      color = {
        hex = "#FFFFFF";
      };
      state = "ON";
    };
    WC 1 = {
      brightness = 255;
      color = {
        hex = "#FFFFFF";
      };
      state = "ON";
    };
    WC 2 = {
      brightness = 255;
      color = {
        hex = "#FFFFFF";
      };
      state = "ON";
    };
  };
}
```
<!-- ZIGBEE_SCENES_END -->
</details>
<br>
<details><summary><strong>
Android TV devices at `config.house.tv`.
</strong></summary>
<!-- TVS_START -->
```nix
{
  arris = {
    apps = {
      telenor = "se.telenor.stream/.MainActivity   ";
      tv4 = "se.tv4.tv4playtab/se.tv4.tv4play.ui.mobile.main.BottomNavigationActivity";
    };
    channels = {
      1 = {
        cmd = "";
        icon = "/nix/store/90klh0aba91qjr3xxdjlkiik1x8wkcnl-source/modules/themes/icons/tv/1.png";
        id = 1;
        name = "SVT1";
        scrape_url = "https://tv-tabla.se/tabla/svt1/";
        stream_url = "";
      };
      10 = {
        cmd = "";
        icon = "/nix/store/90klh0aba91qjr3xxdjlkiik1x8wkcnl-source/modules/themes/icons/tv/10.png";
        id = 10;
        name = "Kanal 10";
        scrape_url = "https://tv-tabla.se/tabla/tv10/";
        stream_url = "";
      };
      11 = {
        cmd = "";
        icon = "/nix/store/90klh0aba91qjr3xxdjlkiik1x8wkcnl-source/modules/themes/icons/tv/11.png";
        id = 11;
        name = "Kanal 11";
        scrape_url = "https://tv-tabla.se/tabla/tv11/";
        stream_url = "";
      };
      12 = {
        cmd = "";
        icon = "/nix/store/90klh0aba91qjr3xxdjlkiik1x8wkcnl-source/modules/themes/icons/tv/12.png";
        id = 12;
        name = "Kanal 12";
        scrape_url = "https://tv-tabla.se/tabla/tv12/";
        stream_url = "";
      };
      13 = {
        cmd = "nav_down && nav_down && nav_right && nav_right && nav_center";
        icon = "/nix/store/90klh0aba91qjr3xxdjlkiik1x8wkcnl-source/modules/themes/icons/tv/13.png";
        id = 13;
        name = "TV4 Hockey";
        scrape_url = "https://tv-tabla.se/tabla/tv4_hockey/";
        stream_url = "";
      };
      14 = {
        cmd = "nav_down && nav_down && nav_right && nav_right && nav_center";
        icon = "/nix/store/90klh0aba91qjr3xxdjlkiik1x8wkcnl-source/modules/themes/icons/tv/14.png";
        id = 14;
        name = "TV4 Sport Live 1";
        scrape_url = "https://tv-tabla.se/tabla/tv4_sport_live_1/";
        stream_url = "";
      };
      15 = {
        cmd = "nav_down && nav_down && nav_right && nav_right && nav_center";
        icon = "/nix/store/90klh0aba91qjr3xxdjlkiik1x8wkcnl-source/modules/themes/icons/tv/15.png";
        id = 15;
        name = "TV4 Sport Live 2";
        scrape_url = "https://tv-tabla.se/tabla/tv4_sport_live_2/";
        stream_url = "";
      };
      16 = {
        cmd = "nav_down && nav_down && nav_right && nav_right && nav_center";
        icon = "/nix/store/90klh0aba91qjr3xxdjlkiik1x8wkcnl-source/modules/themes/icons/tv/16.png";
        id = 16;
        name = "TV4 Sport Live 3";
        scrape_url = "https://tv-tabla.se/tabla/tv4_sport_live_3/";
        stream_url = "";
      };
      17 = {
        cmd = "nav_down && nav_down && nav_right && nav_right && nav_center";
        icon = "/nix/store/90klh0aba91qjr3xxdjlkiik1x8wkcnl-source/modules/themes/icons/tv/17.png";
        id = 17;
        name = "TV 4 Sport Live 4";
        scrape_url = "https://tv-tabla.se/tabla/tv4_sport_live_4/";
        stream_url = "";
      };
      2 = {
        cmd = "";
        icon = "/nix/store/90klh0aba91qjr3xxdjlkiik1x8wkcnl-source/modules/themes/icons/tv/2.png";
        id = 2;
        name = "SVT2";
        scrape_url = "https://tv-tabla.se/tabla/svt2/";
        stream_url = "";
      };
      3 = {
        cmd = "";
        icon = "/nix/store/90klh0aba91qjr3xxdjlkiik1x8wkcnl-source/modules/themes/icons/tv/3.png";
        id = 3;
        name = "Kanal 3";
        scrape_url = "https://tv-tabla.se/tabla/tv3/";
        stream_url = "";
      };
      4 = {
        cmd = "";
        icon = "/nix/store/90klh0aba91qjr3xxdjlkiik1x8wkcnl-source/modules/themes/icons/tv/4.png";
        id = 4;
        name = "TV4";
        scrape_url = "https://tv-tabla.se/tabla/tv4/";
        stream_url = "";
      };
      5 = {
        cmd = "";
        icon = "/nix/store/90klh0aba91qjr3xxdjlkiik1x8wkcnl-source/modules/themes/icons/tv/5.png";
        id = 5;
        name = "TV5";
        scrape_url = "https://tv-tabla.se/tabla/kanal_5/";
        stream_url = "";
      };
      6 = {
        cmd = "";
        icon = "/nix/store/90klh0aba91qjr3xxdjlkiik1x8wkcnl-source/modules/themes/icons/tv/6.png";
        id = 6;
        name = "Kanal 6";
        scrape_url = "https://tv-tabla.se/tabla/tv6/";
        stream_url = "";
      };
      7 = {
        cmd = "";
        icon = "/nix/store/90klh0aba91qjr3xxdjlkiik1x8wkcnl-source/modules/themes/icons/tv/7.png";
        id = 7;
        name = "Sjuan";
        scrape_url = "https://tv-tabla.se/tabla/sjuan/";
        stream_url = "";
      };
      8 = {
        cmd = "";
        icon = "/nix/store/90klh0aba91qjr3xxdjlkiik1x8wkcnl-source/modules/themes/icons/tv/8.png";
        id = 8;
        name = "TV8";
        scrape_url = "https://tv-tabla.se/tabla/tv8/";
        stream_url = "";
      };
      9 = {
        cmd = "";
        icon = "/nix/store/90klh0aba91qjr3xxdjlkiik1x8wkcnl-source/modules/themes/icons/tv/9.png";
        id = 9;
        name = "Kanal 9";
        scrape_url = "https://tv-tabla.se/tabla/kanal_9/";
        stream_url = "";
      };
    };
    enable = true;
    ip = "192.168.1.152";
    room = "bedroom";
  };
  shield = {
    apps = {
      telenor = "se.telenor.stream/.MainActivity";
      tv4 = "se.tv4.tv4playtab/se.tv4.tv4play.ui.mobile.main.BottomNavigationActivity";
    };
    channels = {
      1 = {
        cmd = "open_telenor && wait 5 && start_channel_1";
        icon = "/nix/store/90klh0aba91qjr3xxdjlkiik1x8wkcnl-source/modules/themes/icons/tv/1.png";
        id = 1;
        name = "SVT1";
        scrape_url = "https://tv-tabla.se/tabla/svt1/";
        stream_url = "";
      };
      10 = {
        cmd = "";
        icon = "/nix/store/90klh0aba91qjr3xxdjlkiik1x8wkcnl-source/modules/themes/icons/tv/10.png";
        id = 10;
        name = "Kanal 10";
        scrape_url = "https://tv-tabla.se/tabla/tv10/";
        stream_url = "";
      };
      11 = {
        cmd = "";
        icon = "/nix/store/90klh0aba91qjr3xxdjlkiik1x8wkcnl-source/modules/themes/icons/tv/11.png";
        id = 11;
        name = "Kanal 11";
        scrape_url = "https://tv-tabla.se/tabla/tv11/";
        stream_url = "";
      };
      12 = {
        cmd = "";
        icon = "/nix/store/90klh0aba91qjr3xxdjlkiik1x8wkcnl-source/modules/themes/icons/tv/12.png";
        id = 12;
        name = "Kanal 12";
        scrape_url = "https://tv-tabla.se/tabla/tv12/";
        stream_url = "";
      };
      13 = {
        cmd = "open_tv4 && nav_select && nav_left && nav_down && nav_doown && nav_down && nav_select && wait 3 && nav_down && nav_down && nav_down && nav_down && nav_down && nav_select";
        icon = "/nix/store/90klh0aba91qjr3xxdjlkiik1x8wkcnl-source/modules/themes/icons/tv/13.png";
        id = 13;
        name = "TV4 Hockey";
        scrape_url = "https://tv-tabla.se/tabla/tv4_hockey/";
        stream_url = "";
      };
      14 = {
        cmd = "open_tv4 && nav_left && nav_down && nav_down && nav_down && nav_select && wait 3 && nav_down && nav_down && nav_down && nav_down && nav_down && nav_right && nav_right && nav_select";
        icon = "/nix/store/90klh0aba91qjr3xxdjlkiik1x8wkcnl-source/modules/themes/icons/tv/14.png";
        id = 14;
        name = "TV4 Sport Live 1";
        scrape_url = "https://tv-tabla.se/tabla/tv4_sport_live_1/";
        stream_url = "";
      };
      15 = {
        cmd = "open_tv4 && nav_select && nav_left && nav_down && nav_down && nav_down && nav_select && wait 3 && nav_down && nav_down && nav_down && nav_down && nav_down && nav_down && nav_select";
        icon = "/nix/store/90klh0aba91qjr3xxdjlkiik1x8wkcnl-source/modules/themes/icons/tv/15.png";
        id = 15;
        name = "TV4 Sport Live 2";
        scrape_url = "https://tv-tabla.se/tabla/tv4_sport_live_2/";
        stream_url = "";
      };
      16 = {
        cmd = "open_tv4 && nav_down && nav_right && nav_right && nav_center";
        icon = "/nix/store/90klh0aba91qjr3xxdjlkiik1x8wkcnl-source/modules/themes/icons/tv/16.png";
        id = 16;
        name = "TV4 Sport Live 3";
        scrape_url = "https://tv-tabla.se/tabla/tv4_sport_live_3/";
        stream_url = "";
      };
      17 = {
        cmd = "open_tv4 && nav_left && nav_down && nav_down && nav_down && nav_select && wait 3 && nav_down && nav_down && nav_down && nav_down && nav_down && nav_down && nav_right && nav_right && nav_select";
        icon = "/nix/store/90klh0aba91qjr3xxdjlkiik1x8wkcnl-source/modules/themes/icons/tv/17.png";
        id = 17;
        name = "TV4 Sport Live 4";
        scrape_url = "https://tv-tabla.se/tabla/tv4_sport_live_4/";
        stream_url = "";
      };
      2 = {
        cmd = "open_telenor && wait 5 && start_channel_2";
        icon = "/nix/store/90klh0aba91qjr3xxdjlkiik1x8wkcnl-source/modules/themes/icons/tv/2.png";
        id = 2;
        name = "SVT2";
        scrape_url = "https://tv-tabla.se/tabla/svt2/";
        stream_url = "";
      };
      3 = {
        cmd = "open_telenor && wait 5 && start_channel_3";
        icon = "/nix/store/90klh0aba91qjr3xxdjlkiik1x8wkcnl-source/modules/themes/icons/tv/3.png";
        id = 3;
        name = "Kanal 3";
        scrape_url = "https://tv-tabla.se/tabla/tv3/";
        stream_url = "";
      };
      4 = {
        cmd = "open_telenor && wait 5 && start_channel_4";
        icon = "/nix/store/90klh0aba91qjr3xxdjlkiik1x8wkcnl-source/modules/themes/icons/tv/4.png";
        id = 4;
        name = "TV4";
        scrape_url = "https://tv-tabla.se/tabla/tv4/";
        stream_url = "";
      };
      5 = {
        cmd = "open_telenor && wait 5 && start_channel_5";
        icon = "/nix/store/90klh0aba91qjr3xxdjlkiik1x8wkcnl-source/modules/themes/icons/tv/5.png";
        id = 5;
        name = "Kanal 5";
        scrape_url = "https://tv-tabla.se/tabla/kanal_5/";
        stream_url = "";
      };
      6 = {
        cmd = "open_telenor && wait 5 && start_channel_6";
        icon = "/nix/store/90klh0aba91qjr3xxdjlkiik1x8wkcnl-source/modules/themes/icons/tv/6.png";
        id = 6;
        name = "Kanal 6";
        scrape_url = "https://tv-tabla.se/tabla/tv6/";
        stream_url = "";
      };
      7 = {
        cmd = "open_telenor && wait 5 && start_channel_7";
        icon = "/nix/store/90klh0aba91qjr3xxdjlkiik1x8wkcnl-source/modules/themes/icons/tv/7.png";
        id = 7;
        name = "Sjuan";
        scrape_url = "https://tv-tabla.se/tabla/sjuan/";
        stream_url = "";
      };
      8 = {
        cmd = "";
        icon = "/nix/store/90klh0aba91qjr3xxdjlkiik1x8wkcnl-source/modules/themes/icons/tv/8.png";
        id = 8;
        name = "TV8";
        scrape_url = "https://tv-tabla.se/tabla/tv8/";
        stream_url = "";
      };
      9 = {
        cmd = "";
        icon = "/nix/store/90klh0aba91qjr3xxdjlkiik1x8wkcnl-source/modules/themes/icons/tv/9.png";
        id = 9;
        name = "Kanal 9";
        scrape_url = "https://tv-tabla.se/tabla/kanal_9/";
        stream_url = "";
      };
    };
    enable = true;
    ip = "192.168.1.223";
    room = "livingroom";
  };
}
```
<!-- TVS_END -->
</details>
<!-- SMARTHOME_END -->

</details>


<details><summary><strong>
And you'll get a dashboard for your devices generated and found at http://localhost:13337  
</strong></summary>
<img src="https://github.com/QuackHack-McBlindy/dotfiles/blob/main/home/duckdash1.png?raw=true" width="25%">
<img src="https://github.com/QuackHack-McBlindy/dotfiles/blob/main/home/duckdash2.png?raw=true" width="25%">
<img src="https://github.com/QuackHack-McBlindy/dotfiles/blob/main/home/duckdash3.png?raw=true" width="25%">
<img src="https://github.com/QuackHack-McBlindy/dotfiles/blob/main/home/duckdash4.png?raw=true" width="25%">

<br>
The dashboard currently gives you: <br><br>

- __Advanced zigbee device control__ <br>
- __Remote for your Android TV devices__ <br>
- __Set scenes__ <br>
- __Access to `yo do` through both an text input field aswell as microphone__ <br>
- __and more...__ <br>


</details>



<details><summary><strong>
I like my flakes tiny & ny modules dynamically loaded,  
</strong></summary>

<!-- FLAKE_START -->
```nix
# dotfiles/flake.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{
    description = "❄️🦆 ⮞ QuackHack-McBLindy's NixOS flake";
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
The `yo` CLI is a framework designed to execute scripts defined in the `./bin` directory.  
It provides a unified interface for script execution, centralizes all help commands, and automatically validates parametrs and updates the documentation.  

**Usage:** `yo <command> [arguments]`  

### **Usage Examples:**  
The yo CLI supports flexible parameter parsing through two primary mechanisms:  

```bash
# Named Parameters  
$ yo deploy --host laptop --flake /home/pungkula/dotfiles

# Positional Parameters
$ yo deploy laptop /home/pungkula/dotfiles

# Scripts can also be executed with natural language text by typing:
$ yo do "is laptop overheating"
# Natural language voice commands are also supported, say:
"yo bitch reboot the laptop"

# If the server is not running, it can be manually started with:
$ yo transcribe
$ yo wake
```

### ✨ Available Commands
Set default values for your parameters to have them marked [optional]
| Command Syntax               | Aliases    | Description | VoiceReady |
|------------------------------|------------|-------------|--|
| **🖥️ System Management** | | | |
| [yo deploy](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/system/deploy.nix) --host [--flake] [--user] [--repo] [--port] |  | Build and deploy a NixOS configuration to a remote host. Bootstraps, builds locally, activates remotely, and auto-tags the generation. | 📛 |
| [yo dev](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/system/dev.nix) [--devShell] |  | Start development enviorment | 📛 |
| [yo duckTrace](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/system/duckTrace.nix) [--file] | log | View duckTrace logs quick and quack, unified logging system | 📛 |
| [yo esp](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/system/esp.nix) [--device] [--serialPort] [--ota] [--otaPort] [--OTAPwFile] [--wifiSSID] [--wifiPwFile] [--mqttHost] [--mqttUser] [--mqttPwFile] [--transcriptionHostIP] |  | Declarative firmware deployment tool for ESP32 boards with built-in version control. | 📛 |
| [yo espOTA](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/system/espOTA.nix)  |  | Updates ESP32 devices over the air. | 📛 |
| [yo reboot](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/system/reboot.nix) [--host] | restart | Force reboot and wait for host | ✅ |
| [yo rollback](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/system/rollback.nix) --host [--flake] [--user] |  | Rollback a host to a previous NixOS generation. Fetches Git tags and reverts system+config to a synced, tagged state. | 📛 |
| [yo services](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/system/services.nix) --operation --service --host [--user] [--port] [--!] |  | Systemd service handler. | ✅ |
| [yo switch](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/system/switch.nix) [--flake] [--!] | rb | Rebuild and switch Nix OS system configuration | ✅ |
| **⚙️ Configuration** | | | |
| [yo do](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/config/do.nix) --input [--fuzzyThreshold] | d | Natural language to Shell script translator with dynamic regex matching and automatic parameter resolutiion | 📛 |
| [yo espaudio](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/config/espaudio.nix)  |  |  | 📛 |
| [yo mic](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/config/mic.nix) [--port] [--host] [--seconds] |  | Trigger microphone recording sent to transcription. | 📛 |
| [yo say](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/config/say.nix) --text [--model] [--modelDir] [--silence] [--host] [--blocking] [--file] [--caf] |  | Text to speech with built in language detection and automatic model downloading | 📛 |
| [yo tests](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/config/tests.nix) [--input] [--stats] |  | Extensive automated sentence testing for the NLP | 📛 |
| [yo train](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/config/train.nix) --phrase |  | Trains the NLP module. Correct misclassified commands and update NLP patterns | 📛 |
| [yo transcribe](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/config/transcribe.nix) [--port] [--model] [--language] [--beamSize] [--gpu] [--cert] [--key] |  | Transcription server-side service. Sit and waits for audio that get transcribed and returned. | 📛 |
| [yo wake](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/config/wake.nix) [--threshold] [--cooldown] [--sound] [--remoteSound] [--redisHost] [--redis_pwFIle] |  | Run Wake word detection for audio recording and transcription | 📛 |
| **⚡ Productivity** | | | |
| [yo calculator](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/productivity/calculator.nix) --expression | calc | Calculate math expressions | ✅ |
| [yo calendar](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/productivity/calendar.nix) [--operation] [--calenders] | kal | Calendar assistant. Provides easy calendar access. Interactive terminal calendar, or manage the calendar through yo commands or with voice. | ✅ |
| [yo clip2phone](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/productivity/clip2phone.nix) --copy |  | Send clipboard to an iPhone, for quick copy paste | ✅ |
| [yo fzf](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/productivity/fzf.nix)  | f | Interactive fzf search for file content with quick edit & jump to line | 📛 |
| [yo google](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/productivity/google.nix) --search [--apiKeyFile] [--searchIDFile] | g | Perform web search on google | ✅ |
| [yo hitta](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/productivity/hitta.nix) --search |  | Locate a persons address with help of Hitta.se | ✅ |
| [yo img2phone](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/productivity/img2phone.nix) --image |  | Send images to an iPhone | 📛 |
| [yo pull](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/productivity/pull.nix) [--flake] |  | Pull the latest changes from your dotfiles repo. Resets tracked files to origin/main but keeps local extras. | 📛 |
| [yo push](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/productivity/push.nix) [--flake] [--repo] [--host] [--generation] | ps | Commit, tag, and push dotfiles and system state to GitHub. Tags based on host + generation, auto-updates README, and preserves history. | 📛 |
| [yo scp](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/productivity/scp.nix) --host [--path] [--username] [--downloadPath] |  | Move files between hosts interactively | 📛 |
| **🌍 Localization** | | | |
| [yo stores](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/stores.nix) --store_name [--location] [--radius] | store, shop | Finds nearby stores using OpenStreetMap data with fuzzy name matching. Returns results with opening hours. | ✅ |
| [yo travel](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/travel.nix) [--arrival] [--departure] [--type] [--apikeyPath] |  | Public transportation helper. Fetches current bus and train schedules. (Sweden) | ✅ |
| [yo weather](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/weather.nix) [--location] [--day] [--condition] [--locationPath] | weat | Weather Assistant. Ask anything weather related (3 day forecast) | ✅ |
| **🌐 Networking** | | | |
| [yo api](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/network/api.nix) [--host] [--port] |  | Simple API for collecting system data | 📛 |
| [yo block](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/network/block.nix) --url [--blocklist] | ad | Block URLs using DNS | 📛 |
| [yo ip-updater](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/network/ip-updater.nix) [--token1] [--token2] [--token3] |  | DDNS updater | ✅ |
| [yo notify](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/network/notify.nix) [--text] [--title] [--icon] [--url] [--group] [--sound] [--volume] [--copy] [--autoCopy] [--level] [--encrypt] [--base_urlFile] [--deviceKeyFile] |  | Send custom push to iOS devices | 📛 |
| [yo notify-me](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/network/notify-me.nix) [--address] [--port] [--dataDir] |  | Notification server for iOS devices | 📛 |
| [yo shareWiFi](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/network/shareWiFi.nix) [--ssidFile] [--passwordFile] |  | creates a QR code of guest WiFi and push image to iPhone | ✅ |
| [yo speed](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/network/speed.nix)  | st | Test internet download speed | ✅ |
| **🎧 Media Management** | | | |
| [yo news](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/media/news.nix) [--apis] [--clear] [--playedFile] |  | API caller and playlist manager for latest Swedish news from SR. | ✅ |
| [yo transcode](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/media/transcode.nix) [--directory] | trans | Transcode media files | 📛 |
| [yo tv](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/media/tv.nix) [--typ] [--search] [--device] [--shuffle] [--tvshowsDir] [--moviesDir] [--musicDir] [--musicvideoDir] [--videosDir] [--podcastDir] [--audiobookDir] [--youtubeAPIkeyFile] [--webserver] [--defaultPlaylist] [--favoritesPlaylist] [--max_items] [--mqttUser] [--mqttPWFile] | remote | Android TV Controller. Fuzzy search all media types and creates playlist and serves over webserver for casting. Fully conttrollable. | ✅ |
| [yo tv-guide](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/media/tv-guide.nix) [--search] [--channel] [--jsonFilePath] | tvg | TV-guide assistant.. | ✅ |
| [yo tv-scraper](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/media/tv-scraper.nix) [--epgFilePath] [--jsonFilePath] [--flake] | tvs | Scrapes web for tv-listing data. Builds EPG and generates HTML. | 📛 |
| **🔐 Security & Encryption** | | | |
| [yo sops](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/security/sops.nix) --input [--operation] [--value] [--output] [--agePub] | e | Encrypts a file with sops-nix | 📛 |
| [yo yubi](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/security/yubi.nix) --operation --input | yk | Encrypts and decrypts files using a Yubikey and AGE | 📛 |
| **🛖 Home Automation** | | | |
| [yo alarm](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/alarm.nix) --hours --minutes [--list] [--sound] | wakeup | Set an alarm for a specified time | ✅ |
| [yo battery](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/battery.nix) [--device] |  | Fetch battery level for specified device. | ✅ |
| [yo bed](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/bed.nix) [--part] [--state] |  | Bed controller | ✅ |
| [yo blinds](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/blinds.nix) [--state] |  | Turn blinds up/down | ✅ |
| [yo chair](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/chair.nix) [--part] [--state] |  | Chair controller | ✅ |
| [yo duckDash](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/duckDash.nix) [--host] [--port] [--cert] [--key] | dash | Mobile-first dashboard, unified frontend for zigbee devices, tv remotes and other smart home gadgets. | 📛 |
| [yo findPhone](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/findPhone.nix)  |  | Helper for locating Phone | ✅ |
| [yo house](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/house.nix) [--device] [--state] [--brightness] [--color] [--temperature] [--scene] [--user] [--passwordfile] [--flake] |  | Control lights and other home automatioon devices | ✅ |
| [yo kitchenFan](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/kitchenFan.nix) [--state] |  | Turns kitchen fan on/off | ✅ |
| [yo leaving](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/leaving.nix)  |  | Run when leaving house to set away state | 📛 |
| [yo returned](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/returned.nix)  |  | Run when returned home to set home state | 📛 |
| [yo state](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/state.nix) [--device] |  | Fetches the state of the specified device. | ✅ |
| [yo temperatures](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/temperatures.nix)  |  | Get all temperature values from sensors and return a average value. | ✅ |
| [yo tibber](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/tibber.nix) [--mode] [--homeIDFile] [--APIKeyFile] [--filePath] [--user] [--pwfile] | el | Fetches home electricity price data | ✅ |
| [yo timer](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/timer.nix) [--minutes] [--seconds] [--hours] [--list] [--sound] |  | Set a timer | ✅ |
| [yo toilet](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/toilet.nix)  |  | Flush the toilet | ✅ |
| [yo zigduck](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/home/zigduck.nix) [--user] [--pwfile] | hem | Home Automations at its best! Bash & Nix cool as dat. Runs on single process | 📛 |
| **🧩 Miscellaneous** | | | |
| [yo chat](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/chat.nix) --text |  | No fwendz? Let's chat yo! | ✅ |
| [yo duckPUCK](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/duckPUCK.nix) [--mode] [--team] [--stat] [--dataDir] | puck | duckPUCK is your personal hockey assistant - Expert commentary and analyzer specialized on Hockey Allsvenskan (SWE). Analyzing games, scraping scoreboard and keeping track of all dates annd numbers. | ✅ |
| [yo hockeyGames](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/hockeyGames.nix) [--type] [--days] [--team] [--dataDir] [--debug] | hag | Hockey Assistant. Provides Hockey Allsvenskan data and deliver analyzed natural language responses (TTS). | ✅ |
| [yo invokeai](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/invokeai.nix) --prompt [--host] [--port] [--outputDir] [--width] [--height] [--steps] [--cfgScale] [--seed] [--model] | genimg | AI generated images powered by InvokeAI | ✅ |
| [yo joke](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/joke.nix) [--jokeFile] |  | Duck says s funny joke. | ✅ |
| [yo post](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/post.nix) [--postalCodeFile] [--postalCode] |  | Check for the next postal delivery day. (Sweden) | ✅ |
| [yo qr](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/qr.nix) --input [--icon] [--output] |  | Create fun randomized QR codes from input. | 📛 |
| [yo reminder](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/reminder.nix) [--about] [--list] [--clear] [--user] [--pwfile] | remind | Reminder Assistant | ✅ |
| [yo shop-list](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/shop-list.nix) [--operation] [--item] [--list] [--mqttUser] [--mqttPWFile] |  | Shopping list management | ✅ |
| [yo suno](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/suno.nix) --prompt [--genre] | mg | AI generated lyrics and music files powered by Suno | ✅ |
| [yo time](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/misc/time.nix)  |  | Tells time, day and date | ✅ |
| **🧹 Maintenance** | | | |
| [yo clean](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/maintenance/clean.nix)  | gc | Run a total garbage collection: Removes old NixOS generations, empty trash, flush tmp files, whipes cache and runs a docker prune | 📛 |
| [yo health](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/maintenance/health.nix) [--host] | hc | Check system health status across your machines. Returns JSON structured responses. | ✅ |
### ❓ Detailed Help
For specific command help: 
`yo <command> --help`
`yo <command> -h`
<!-- YO_DOCS_END -->


<br>



## 💬 **Comments?**

**Nix Talk? Or just say tiny flake sucks?**   
**That's cool!**  
**I am all ears. 👀**  

<!-- CONTACT_START -->
[![Discord](https://img.shields.io/badge/Discord-Chat-5865F2?style=flat-square&logo=discord&logoColor=white)](https://discordapp.com/users/675530282849533952)
[![Email](https://img.shields.io/badge/Email-Contact-6D4AFF?style=flat-square&logo=protonmail&logoColor=white)](mailto:isthisrandomenough@protonmail.com)
[![GitHub Discussions](https://img.shields.io/badge/Discussions-Join-181717?style=flat-square&logo=github&logoColor=white)](https://github.com/QuackHack-McBlindy/dotfiles/discussions)

<!-- CONTACT_END -->

<br>

> [!NOTE]
> __Im not blind.__ <br>
> **I just can't see.** 🧑‍🦯
<br>
