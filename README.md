# ❄️🦆 **QuackHack-McBLindy NixOS dotfiles** <br>

![NixOS](https://img.shields.io/badge/NixOS-25%2E05-blue) ![License](https://img.shields.io/badge/license-MIT-black) ![Linux Kernel](https://img.shields.io/badge/Linux-6.12.28-red) ![GNOME](https://img.shields.io/badge/GNOME-47%2E4-purple) ![Bash](https://img.shields.io/badge/bash-5.2.21-red) ![Nix](https://img.shields.io/badge/Nix-2.28.3-blue)

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

- 🛖 **[Simple Home Management](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/modules/home.nix)** *(auto symlinks ./home to /home)*  
- 🖥️  **[The one the only <strong>This</strong> module](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/modules/default.nix)** *(One module to define them all)*  
- 🛠️ **[Nix CLI Toolbox](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/modules/yo.nix)** *(for quick-quack deployments & magic nix+git syncronized rollbaks)*    
- 🦊 **[Firefox as Code](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/modules/programs/firefox.nix)** *(extensions, bookmarks and settings)* 
- 🎨 **[Global Theme Orchestration](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/modules/themes/default.nix)** *(GTK, icons, cursor, Discord, Firefox & Shell)* 
- 📝 **[Self-Documenting](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/bin/productivity/git.nix)** *(CLI usage, Git tags & README.md)*

<br><br>

## **🛟 Quick Start**

```bash
# Clone repository
$ git clone https://github.com/QuackHack-McBlindy/dotfiles.git
$ cd dotfiles
``` 

<br>

### **Some usage examples:**  

<br>

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
`yo rollback laptop`

### ✨ Available Commands
Set default values for your parameters to have them marked [optional]
| Command Syntax               | Aliases    | Description |
|------------------------------|------------|-------------|
| `yo block --url [--blocklist]` | ad | Block URLs using DNS |
| `yo clean ` | gc | Run a total garbage collection: Removes old NixOS generations, empty trash, flush tmp files, whipes cache and runs a docker prune |
| `yo deploy --host [--flake] [--user] [--repo] [--!]` | d | Build and deploy a NixOS configuration to a remote host. Bootstraps, builds locally, activates remotely, and auto-tags the generation. |
| `yo edit ` | config | yo CLI configuration mode |
| `yo fzf ` | f | Interactive fzf search for file content with quick edit & jump to line |
| `yo health [--host]` | hc | Check system health status across your machines |
| `yo proxy --mode` | prox | Turn proxy routing on/off for anonymous mode |
| `yo pull [--flake]` | pl | Pull the latest changes from your dotfiles repo. Safely resets local state and syncs with origin/main cleanly. |
| `yo push [--flake] [--repo] [--host] [--generation]` | ps | Commit, tag, and push dotfiles and system state to GitHub. Tags based on host + generation, auto-updates README, and preserves history. |
| `yo reboot [--host]` |  | Force reboot and wait for host |
| `yo rollback --host [--flake] [--user]` |  | Rollback a host to a previous NixOS generation. Fetches Git tags and reverts system+config to a synced, tagged state. |
| `yo scp ` |  | Move files between hosts interactively |
| `yo sops --input [--agePub]` | e | Encrypts a file with sops-nix |
| `yo speed ` | st | Test your internets Download speed |
| `yo stores --store_name [--location] [--radius]` | store, open | Finds nearby stores using OpenStreetMap data with fuzzy name matching. Returns results with opening hours. |
| `yo switch [--flake] [--!]` | rb | Rebuild and switch Nix OS system configuration |
| `yo weather [--location]` | weat | Tiny Weather Forecast. |
| `yo yubi --operation --input` | yk | Encrypts and decrypts files using a Yubikey and AGE |
### ❓ Detailed Help
For specific command help: 
`yo <command> --help`
`yo <command> -h`
<!-- YO_DOCS_END -->


<br><br>

## ❄️ **Flake**


*I like to keep my flakes cool & tiny.*  
*At first glance, this tiny flake may seem like an ordinary tiny flake*  
*But considering how the modules are constructed,*  
*I think calling this tiny flake a tiny upside-down flake would be more accurate.*  <br><br>


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
    │   └───tv omitted (use '--all-systems' to show)
    └───x86_64-linux
        ├───health: package 'health'
        ├───installer: package 'nixos-auto-installer-24.05.20240406.ff0dbd9-x86_64-linux.iso'
        ├───say: package 'say'
        └───tv: package 'tv'
```
  <!-- TREE_END -->

</details>


