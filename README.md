# ❄️🦆 **QuackHack-McBLindy NixOS dotfiles** <br>

<!-- VERSIONS_START -->
![NixOS](https://img.shields.io/badge/NixOS-25.05-blue?style=flat-square&logo=NixOS&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-black?style=flat-square&logo=opensourceinitiative&logoColor=white)
![Linux Kernel](https://img.shields.io/badge/Linux-6.12.28-red?style=flat-square&logo=linux&logoColor=white)
![GNOME](https://img.shields.io/badge/GNOME-47.4-purple?style=flat-square&logo=gnome&logoColor=white)
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

__Sup ducks? 🦆 qwack on__ <br>

## **📌 Highlights**

- 🛖 **[Simple Home Management](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/modules/home.nix)** *(auto symlinks ./home to /home)*  
- 🛠️ **[Nix CLI Toolbox](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/modules/yo.nix)** *(for quick-quack deployments, magically syncronized rollbacks & voice execution)*    
- 🦊 **[Firefox as Code](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/modules/programs/firefox.nix)** *(extensions, bookmarks and settings)* 
- 🎨 **[Global Theme Orchestration](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/modules/themes/default.nix)** *(GTK, icons, cursor, Discord, Firefox & Shell)* 
- 📝 **[Self-Documenting](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/productivity/git.nix)** *(CLI usage, Git tags & README.md)*

<br>

__Here lives home machines configurations,__  
__crafted as a tiny Nix flake__  
__Glued together by a Nix-flavoured command line utility,__  
__easiy expanded and used to deploy, doc, and duck around__ 🦆✨  
  
  
## ❄️ **Flake**

<details><summary><strong>

__I define myself at `config.this.user.me`.__  

</strong></summary>
<!-- USER_START -->
```nix
{
  "discord": "https://discordapp.com/users/675530282849533952",
  "dotfilesDir": "/home/pungkula/dotfiles",
  "email": "isthisrandomenough@protonmail.com",
  "extraGroups": [
    "networkmanager",
    "wheel",
    "dialout",
    "docker",
    "dockeruser",
    "users",
    "pungkula",
    "adbusers",
    "audio"
  ],
  "hashedPassword": "$y$j9T$m8hPD36i1VMaO5rurbZ4j0$KpzQyat.F6NoWFKpisEj77TvpN2wBGB8ezd26QoKDj6",
  "matrix": "",
  "mobileDevices": {
    "iphone": {
      "pubkey": "UFB0T1Y/uLZi3UBtEaVhCi+QYldYGcOZiF9KKurC5Hw=",
      "wgip": "10.0.0.7"
    },
    "tablet": {
      "pubkey": "ETRh93SQaY+Tz/F2rLAZcW7RFd83eofNcBtfyHCBWE4=",
      "wgip": "10.0.0.8"
    }
  },
  "name": "pungkula",
  "repo": "git@github.com:QuackHack-McBlindy/dotfiles.git"
}
```
```nix
{
  "builder": {
    "enable": true,
    "sshKeys": [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINQ7c/AeIpmJS6cWQkHOe4ZEq3DXVRnjtTWuWfx6L46n"
    ]
  },
  "enable": true,
  "i18n": "sv_SE.UTF-8",
  "me": {
    "discord": "https://discordapp.com/users/675530282849533952",
    "dotfilesDir": "/home/pungkula/dotfiles",
    "email": "isthisrandomenough@protonmail.com",
    "extraGroups": [
      "networkmanager",
      "wheel",
      "dialout",
      "docker",
      "dockeruser",
      "users",
      "pungkula",
      "adbusers",
      "audio"
    ],
    "hashedPassword": "$y$j9T$m8hPD36i1VMaO5rurbZ4j0$KpzQyat.F6NoWFKpisEj77TvpN2wBGB8ezd26QoKDj6",
    "matrix": "",
    "mobileDevices": {
      "iphone": {
        "pubkey": "UFB0T1Y/uLZi3UBtEaVhCi+QYldYGcOZiF9KKurC5Hw=",
        "wgip": "10.0.0.7"
      },
      "tablet": {
        "pubkey": "ETRh93SQaY+Tz/F2rLAZcW7RFd83eofNcBtfyHCBWE4=",
        "wgip": "10.0.0.8"
      }
    },
    "name": "pungkula",
    "repo": "git@github.com:QuackHack-McBlindy/dotfiles.git"
  },
  "yubikey": {
    "enable": true
  }
}
```
```nix
{"builder":{"enable":true,"sshKeys":["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINQ7c/AeIpmJS6cWQkHOe4ZEq3DXVRnjtTWuWfx6L46n"]},"enable":true,"i18n":"sv_SE.UTF-8","me":{"discord":"https://discordapp.com/users/675530282849533952","dotfilesDir":"/home/pungkula/dotfiles","email":"isthisrandomenough@protonmail.com","extraGroups":["networkmanager","wheel","dialout","docker","dockeruser","users","pungkula","adbusers","audio"],"hashedPassword":"$y$j9T$m8hPD36i1VMaO5rurbZ4j0$KpzQyat.F6NoWFKpisEj77TvpN2wBGB8ezd26QoKDj6","matrix":"","mobileDevices":{"iphone":{"pubkey":"UFB0T1Y/uLZi3UBtEaVhCi+QYldYGcOZiF9KKurC5Hw=","wgip":"10.0.0.7"},"tablet":{"pubkey":"ETRh93SQaY+Tz/F2rLAZcW7RFd83eofNcBtfyHCBWE4=","wgip":"10.0.0.8"}},"name":"pungkula","repo":"git@github.com:QuackHack-McBlindy/dotfiles.git"},"yubikey":{"enable":true}}
```




<!-- USER_END -->
</details>
<br>

<details><summary><strong>
__I define each hosts data at `config.this.host`.__  
</strong></summary>
<!-- HOST_START -->
```nix
{
  "hostname": "desktop",
  "interface": [
    "enp119s0"
  ],
  "ip": "192.168.1.111",
  "keys": {
    "privateKeys": {},
    "publicKeys": {
      "adb": "QAAAACEJNfsfRV4PQ9Ah87MbTVbMkbXC6CAMDOR+0K6mIpv/4TSzYMkc2qit3Kryc55IVOjwR3fJRjj/uL549gZ7nEemWtcd3AsYQBp0iIEor8nu1L/V6jfsTY6Xe/pl06xoroy6OwZRWuDbZ4wD2xQRRQjfPd+JtYnMAWneM6r1V15uR67w4ITvjk3ckyfgNeLZMUwahMRjC3wSjaU9sAdKNmg8yPd8uHZ+mK6mstxJFAGEpnnm1lE7Z2r0DF6h6MKY1++dwhU+WM5BRDNiBg+D4i6fDW4+Z1I9ENuFnjT17zAxZXch04SNlG3O94BANYP7jmKp60OvtDL6msfphntuIUzMCkndF9De0Kv4lJdQxe1d+wf+AFpmtd/xtrk45YdMV+eWCJf2OkidaHmSj4ffkAobpun0VrkZN2Z1JymmdsvUbyMjAsby3Zun0xr3EocUS8Jy5TcsK/dcpD6CB5dqzlHhsHSAWt2TDwPzZYXgV1xc+q+PqM09OVN1xActJu75UMkg5b84U15hwQvYdwB8UaopMWWk6p064c7gxYSfH7fSxwkW2Jy1CElgJa55Pp4SZG9b/3B+VcNL1WSf6v/lvJqPbrRvBqvS0+e9wcFMNZtQKTX3n5X0wW1/czZPCQX+hmM8Uu1qrtaz4rKViIEGf4YR0/9eUGYQVfuAxAh8ZmsroJlnAAEAAQA= pungkula@desktop",
      "age": "age16utg7mmk73cn3glrwthtm0p7mf6g3vrd48h3ucpn6wnf28pgxvcsh4rjjp",
      "borg": "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMVYczAOBSeS7WfSvzYDOS4Q9Ss+yxCf2G5MVfAALOx/",
      "builder": "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINQ7c/AeIpmJS6cWQkHOe4ZEq3DXVRnjtTWuWfx6L46n",
      "cache": "cache:/pbj1Agw2OoSSDZcClS69RHa1aNcwwTOX3GIEGKYwPc=",
      "host": "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILdwPkRQxlbrbRGwEO5zMJ4m+7QqUQPZg1iqbd5HRP34",
      "iPhone": "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMcmr+z7k/yCbrFg+JDgo8JCuWqNVYn10ajRbNTp8fq",
      "ssh": "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPwZL27kGTQDIlSe03abT9F24nSAizORyjo5cI3BD92s",
      "wireguard": "Oq0ZaYAnOo5sLpV//OEFwLgjVCxPyeQqf8cZBASluWk="
    }
  },
  "modules": {
    "hardware": [
      "cpu/intel",
      "gpu/amd",
      "audio"
    ],
    "networking": [
      "default",
      "pool"
    ],
    "programs": [
      "default",
      "thunar",
      "firefox",
      "vesktop"
    ],
    "services": [
      "ssh",
      "adb",
      "backup",
      "cache",
      "keyd",
      "bitch"
    ],
    "system": [
      "nix",
      "pkgs",
      "gnome",
      "crossEnv",
      "gtk"
    ],
    "virtualisation": [
      "docker",
      "vm"
    ]
  },
  "system": "x86_64-linux",
  "wgip": "10.0.0.2"
}
```
```nix
{
  "hostname": "desktop",
  "interface": [
    "enp119s0"
  ],
  "ip": "192.168.1.111",
  "keys": {
    "privateKeys": {},
    "publicKeys": {
      "adb": "QAAAACEJNfsfRV4PQ9Ah87MbTVbMkbXC6CAMDOR+0K6mIpv/4TSzYMkc2qit3Kryc55IVOjwR3fJRjj/uL549gZ7nEemWtcd3AsYQBp0iIEor8nu1L/V6jfsTY6Xe/pl06xoroy6OwZRWuDbZ4wD2xQRRQjfPd+JtYnMAWneM6r1V15uR67w4ITvjk3ckyfgNeLZMUwahMRjC3wSjaU9sAdKNmg8yPd8uHZ+mK6mstxJFAGEpnnm1lE7Z2r0DF6h6MKY1++dwhU+WM5BRDNiBg+D4i6fDW4+Z1I9ENuFnjT17zAxZXch04SNlG3O94BANYP7jmKp60OvtDL6msfphntuIUzMCkndF9De0Kv4lJdQxe1d+wf+AFpmtd/xtrk45YdMV+eWCJf2OkidaHmSj4ffkAobpun0VrkZN2Z1JymmdsvUbyMjAsby3Zun0xr3EocUS8Jy5TcsK/dcpD6CB5dqzlHhsHSAWt2TDwPzZYXgV1xc+q+PqM09OVN1xActJu75UMkg5b84U15hwQvYdwB8UaopMWWk6p064c7gxYSfH7fSxwkW2Jy1CElgJa55Pp4SZG9b/3B+VcNL1WSf6v/lvJqPbrRvBqvS0+e9wcFMNZtQKTX3n5X0wW1/czZPCQX+hmM8Uu1qrtaz4rKViIEGf4YR0/9eUGYQVfuAxAh8ZmsroJlnAAEAAQA= pungkula@desktop",
      "age": "age16utg7mmk73cn3glrwthtm0p7mf6g3vrd48h3ucpn6wnf28pgxvcsh4rjjp",
      "borg": "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMVYczAOBSeS7WfSvzYDOS4Q9Ss+yxCf2G5MVfAALOx/",
      "builder": "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINQ7c/AeIpmJS6cWQkHOe4ZEq3DXVRnjtTWuWfx6L46n",
      "cache": "cache:/pbj1Agw2OoSSDZcClS69RHa1aNcwwTOX3GIEGKYwPc=",
      "host": "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILdwPkRQxlbrbRGwEO5zMJ4m+7QqUQPZg1iqbd5HRP34",
      "iPhone": "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMcmr+z7k/yCbrFg+JDgo8JCuWqNVYn10ajRbNTp8fq",
      "ssh": "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPwZL27kGTQDIlSe03abT9F24nSAizORyjo5cI3BD92s",
      "wireguard": "Oq0ZaYAnOo5sLpV//OEFwLgjVCxPyeQqf8cZBASluWk="
    }
  },
  "modules": {
    "hardware": [
      "cpu/intel",
      "gpu/amd",
      "audio"
    ],
    "networking": [
      "default",
      "pool"
    ],
    "programs": [
      "default",
      "thunar",
      "firefox",
      "vesktop"
    ],
    "services": [
      "ssh",
      "adb",
      "backup",
      "cache",
      "keyd",
      "bitch"
    ],
    "system": [
      "nix",
      "pkgs",
      "gnome",
      "crossEnv",
      "gtk"
    ],
    "virtualisation": [
      "docker",
      "vm"
    ]
  },
  "system": "x86_64-linux",
  "wgip": "10.0.0.2"
}
```
```nix
{"hostname":"desktop","interface":["enp119s0"],"ip":"192.168.1.111","keys":{"privateKeys":{},"publicKeys":{"adb":"QAAAACEJNfsfRV4PQ9Ah87MbTVbMkbXC6CAMDOR+0K6mIpv/4TSzYMkc2qit3Kryc55IVOjwR3fJRjj/uL549gZ7nEemWtcd3AsYQBp0iIEor8nu1L/V6jfsTY6Xe/pl06xoroy6OwZRWuDbZ4wD2xQRRQjfPd+JtYnMAWneM6r1V15uR67w4ITvjk3ckyfgNeLZMUwahMRjC3wSjaU9sAdKNmg8yPd8uHZ+mK6mstxJFAGEpnnm1lE7Z2r0DF6h6MKY1++dwhU+WM5BRDNiBg+D4i6fDW4+Z1I9ENuFnjT17zAxZXch04SNlG3O94BANYP7jmKp60OvtDL6msfphntuIUzMCkndF9De0Kv4lJdQxe1d+wf+AFpmtd/xtrk45YdMV+eWCJf2OkidaHmSj4ffkAobpun0VrkZN2Z1JymmdsvUbyMjAsby3Zun0xr3EocUS8Jy5TcsK/dcpD6CB5dqzlHhsHSAWt2TDwPzZYXgV1xc+q+PqM09OVN1xActJu75UMkg5b84U15hwQvYdwB8UaopMWWk6p064c7gxYSfH7fSxwkW2Jy1CElgJa55Pp4SZG9b/3B+VcNL1WSf6v/lvJqPbrRvBqvS0+e9wcFMNZtQKTX3n5X0wW1/czZPCQX+hmM8Uu1qrtaz4rKViIEGf4YR0/9eUGYQVfuAxAh8ZmsroJlnAAEAAQA= pungkula@desktop","age":"age16utg7mmk73cn3glrwthtm0p7mf6g3vrd48h3ucpn6wnf28pgxvcsh4rjjp","borg":"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMVYczAOBSeS7WfSvzYDOS4Q9Ss+yxCf2G5MVfAALOx/","builder":"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINQ7c/AeIpmJS6cWQkHOe4ZEq3DXVRnjtTWuWfx6L46n","cache":"cache:/pbj1Agw2OoSSDZcClS69RHa1aNcwwTOX3GIEGKYwPc=","host":"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILdwPkRQxlbrbRGwEO5zMJ4m+7QqUQPZg1iqbd5HRP34","iPhone":"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMcmr+z7k/yCbrFg+JDgo8JCuWqNVYn10ajRbNTp8fq","ssh":"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPwZL27kGTQDIlSe03abT9F24nSAizORyjo5cI3BD92s","wireguard":"Oq0ZaYAnOo5sLpV//OEFwLgjVCxPyeQqf8cZBASluWk="}},"modules":{"hardware":["cpu/intel","gpu/amd","audio"],"networking":["default","pool"],"programs":["default","thunar","firefox","vesktop"],"services":["ssh","adb","backup","cache","keyd","bitch"],"system":["nix","pkgs","gnome","crossEnv","gtk"],"virtualisation":["docker","vm"]},"system":"x86_64-linux","wgip":"10.0.0.2"}
```




<!-- HOST_END -->
</details>
<br>

__I like my flakes tiny & ny modules dynamic,__  


<details><summary><strong>
Display Flake  
</strong></summary>

<!-- FLAKE_START -->
```nix
# dotfiles/flake.nix
{ 
    description = "❄️🦆 QuackHack-McBlindy's NixOS Flakes.";
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
            overlays = [ ];
            hosts = lib.mapHosts ./hosts;
            specialArgs = { pkgs = system: nixpkgs.legacyPackages.${system}; };
            packages = lib.mapModules ./packages import;
            devShells = lib.mapModules ./devShells (path: import path);     
        };}
```
<!-- FLAKE_END -->
</details>

<br>

<details><summary><strong>
Display Flake Outputs
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
│   │   └───rust omitted (use '--all-systems' to show)
│   └───x86_64-linux
│       ├───android: development environment 'nix-shell'
│       ├───go: development environment 'nix-shell'
│       ├───java: development environment 'nix-shell'
│       ├───node: development environment 'nix-shell'
│       ├───python: development environment 'nix-shell'
│       └───rust: development environment 'nix-shell'
├───nixosConfigurations
│   ├───desktop: NixOS configuration
│   ├───homie: NixOS configuration
│   ├───laptop: NixOS configuration
│   └───nasty: NixOS configuration
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

**Any builds after first deployment will use local cached binaries with enhanced build time.**  

<br>

<!-- YO_DOCS_START -->
## 🚀 **yo CLI TOol 🦆🦆🦆🦆🦆🦆**
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
The yo CLI tool supports flexible parameter parsing through two primary mechanisms:  

```bash
# Named Parameters  
$ yo deploy --host laptop --flake /home/pungkula/dotfiles

# Positional Parameters
$ yo deploy laptop /home/pungkula/dotfiles

# Scripts can also be executed by voice, say
$ yo bitch deploy laptop
```

### ✨ Available Commands
Set default values for your parameters to have them marked [optional]
| Command Syntax               | Aliases    | Description |
|------------------------------|------------|-------------|
| **🖥️ System Management** | | |
| `yo deploy --host [--flake] [--user] [--repo] [--!]` | d | Build and deploy a NixOS configuration to a remote host. Bootstraps, builds locally, activates remotely, and auto-tags the generation. |
| `yo reboot [--host]` | restart | Force reboot and wait for host |
| `yo rollback --host [--flake] [--user]` |  | Rollback a host to a previous NixOS generation. Fetches Git tags and reverts system+config to a synced, tagged state. |
| `yo switch [--flake] [--!]` | rb | Rebuild and switch Nix OS system configuration |
| **⚙️ Configuration** | | |
| `yo bitch --input` |  | Parses plain text natural language and builds yo script execution commands. |
| `yo edit ` | config | yo CLI configuration mode |
| `yo mic ` |  | Description of the script. |
| **⚡ Productivity** | | |
| `yo fzf ` | f | Interactive fzf search for file content with quick edit & jump to line |
| `yo pull [--flake]` | pl | Pull the latest changes from your dotfiles repo. Safely resets local state and syncs with origin/main cleanly. |
| `yo push [--flake] [--repo] [--host] [--generation]` | ps | Commit, tag, and push dotfiles and system state to GitHub. Tags based on host + generation, auto-updates README, and preserves history. |
| `yo scp ` |  | Move files between hosts interactively |
| **🌍 Localization** | | |
| `yo stores --store_name [--location] [--radius]` | store, open | Finds nearby stores using OpenStreetMap data with fuzzy name matching. Returns results with opening hours. |
| `yo transport --arrival [--departure] [--apikey]` | buss, trafiklab | Public transportation helper. Fetches current airplane, bus, boats and train departure and arrival times. (Sweden) |
| `yo weather [--location]` | weat | Tiny Weather Report. |
| **🌐 Networking** | | |
| `yo arris [--typ] --search` | bedroom, a | Android TV Controller |
| `yo block --url [--blocklist]` | ad | Block URLs using DNS |
| `yo proxy --mode` | prox | Turn proxy routing on/off for anonymous mode |
| `yo shield --search [--typ]` | s, tv | Android TV Controller |
| `yo speed ` | st | Test your internets Download speed |
| **🔐 Security & Encryption** | | |
| `yo sops --input [--agePub]` | e | Encrypts a file with sops-nix |
| `yo yubi --operation --input` | yk | Encrypts and decrypts files using a Yubikey and AGE |
| **🧩 Miscellaneous** | | |
| `yo qr --input [--icon] [--output]` |  | Create fun randomized QR codes from input. |
| **🧹 Maintenance** | | |
| `yo clean ` | gc | Run a total garbage collection: Removes old NixOS generations, empty trash, flush tmp files, whipes cache and runs a docker prune |
| `yo health [--host]` | hc | Check system health status across your machines |
### ❓ Detailed Help
For specific command help: 
`yo <command> --help`
`yo <command> -h`
<!-- YO_DOCS_END -->


## 💬 **Comments?**

**Nix Talk? Or just tell me tiny flake sucks?**   
**That's cool!**  
**I am all ears. 👀**  

<!-- CONTACT_START -->
[![Discord](https://img.shields.io/badge/Discord-Chat-5865F2?style=flat-square&logo=discord&logoColor=white)](https://discordapp.com/users/675530282849533952)
[![Email](https://img.shields.io/badge/Email-Contact-6D4AFF?style=flat-square&logo=protonmail&logoColor=white)](mailto:isthisrandomenough@protonmail.com)
[![GitHub Discussions](https://img.shields.io/badge/Discussions-Join-181717?style=flat-square&logo=github&logoColor=white)](https://github.com/QuackHack-McBlindy/dotfiles/discussions)

<!-- CONTACT_END -->
