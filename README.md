# ❄️🦆 **QuackHack-McBLindy NixOS dotfiles** <br>

![NixOS](https://img.shields.io/badge/NixOS-25.05-blue) ![License](https://img.shields.io/badge/license-MIT-black) ![Linux Kernel](https://img.shields.io/badge/Linux-6.12.25-red) ![GNOME](https://img.shields.io/badge/GNOME-47%2E4-purple) ![Bash](https://img.shields.io/badge/bash-5.2.21-red) ![Nix](https://img.shields.io/badge/Nix-2.28.3-blue)

[![About](https://img.shields.io/github/sponsors/QuackHack-McBlindy?logo=githubsponsors&label=?&style=flat&labelColor=ff1493&logoColor=fff&color=rgba(234,74,170,0.5) "")](https://github.com/sponsors/QuackHack-McBlindy)<div align="right"><sub>

_This is a <abbr title="Magically automated with duck-powered quackery">automagiduckically</abbr> updated README.md_

</sub></div> 


> [!CAUTION]
> __Do not blindly run this flake.__ <br>
> **That's my job.** 🧑‍🦯
<br>

__Sup ducks? 🦆 qwack on__ <br>

__Home to machine configurations,__  
__crafted as a minimalist Nix flake__  
__Glued together by a Nix-flavoured command line utility,__  
__that deploys, docs, and ducks around__ 🦆✨  

<br>

## **📌 Highlights**

- 🛖 **Simple Home Management** *(auto symlinks ./home to /home)*   
- 🛠️ **Nix CLI Toolbox** *(for quick-quack deployments)*    
- 🦊 **Firefox as Code** *(extensions, bookmarks and settings)*   
- 🎨 **Global Theme Orchestration** *(GTK, icons, cursor, Discord, Firefox & Shell)*  
- 📝 **Self-Documenting** *(CLI usage & README.md)*  

<br><br>

## **🛟 Quick Start**

**Some usage examples:**

```bash
# Clone repository
$ git clone https://github.com/QuackHack-McBlindy/dotfiles.git
$ cd dotfiles
``` 

**Build automated, offline USB NixOS installer** 

```bash
$ sudo bash usb-installer \
  --user "pungkula" \
  --host "laptop" \
  --ssid "IfYouDontHaveEthernet" \
  --wifipass "CanBeOmitted" \
  --publickey "ssh-ed25519 AAAAC3FoRSsHCoNnEcTiOn..."
``` 

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

Any builds after first deployment will use locally cached binaries.

<br><br>

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
`yo deploy laptop`
`yo deploy user@hostname`
`yo health`
`yo health --host desktop` 

### ✨ Available Commands
Set default values for your parameters to have them marked [optional]
| Command Syntax               | Aliases    | Description |
|------------------------------|------------|-------------|
| `yo block --url [--blocklist]` | ad | Block URLs using DNS |
| `yo clean ` | gc | Run a total garbage collection: Removes old NixOS generations, empty trash, flush tmp files, whipes cache and runs a docker prune |
| `yo deploy --host [--flake] [--user] [--repo] [--!]` | d | Deploy NixOS system configurations to your remote servers |
| `yo edit ` | config | yo CLI configuration mode |
| `yo fzf ` | f | Interactive fzf search for file content with quick edit & jump to line |
| `yo health [--host]` | hc | Check system health status across your machines |
| `yo proxy --mode` | prox | Turn proxy routing on/off for anonymous mode |
| `yo pull [--flake]` | pl | Pull dotfiles repo from GitHub |
| `yo push [--flake] [--repo] [--host] [--generation]` | ps | Update README.md and pushes dotfiles to GitHub with tags |
| `yo reboot [--host]` |  | Force reboot and wait for host |
| `yo rollback --host [--flake] [--user]` |  | Synchronized system+config rollback |
| `yo scp ` |  | Move files between hosts interactively |
| `yo sops --input [--agePub]` | e | Encrypts a file with sops-nix |
| `yo speed ` | st | Test your internets Download speed |
| `yo switch [--flake] [--!]` | rb | Rebuild and switch Nix OS system configuration |
| `yo yubi --operation --input` | yk | Encrypts and decrypts files using a Yubikey and AGE |
### ❓ Detailed Help
For specific command help: 
`yo <command> --help`
`yo <command> -h`
<!-- YO_DOCS_END -->


<br><br>

## ❄️ **Flake**

*I like to keep my flakes cool & tiny.*

<details><summary>
Flake
</summary>

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

<details><summary>
Flake Outputs
</summary>

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
    │   └───tv omitted (use '--all-systems' to show)
    └───x86_64-linux
        ├───health: package 'health'
        ├───installer: package 'nixos-auto-installer-24.05.20240406.ff0dbd9-x86_64-linux.iso'
        ├───say: package 'say'
        └───tv: package 'tv'
```
  <!-- TREE_END -->

</details>


