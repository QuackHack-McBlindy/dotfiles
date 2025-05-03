# ❄️🦆 **QuackHack-McBLindy NixOS dotfiles** <br>

![NixOS](https://img.shields.io/badge/NixOS-25%05-blue)  ![License](https://img.shields.io/badge/license-MIT-black) ![Linux Kernel](https://img.shields.io/badge/Linux-6.12.21-red) ![GNOME](https://img.shields.io/badge/GNOME-47%2E4-purple) ![Bash](https://img.shields.io/badge/bash-5.2.21-red) ![Nix](https://img.shields.io/badge/Nix-2.28.3-blue) <br>

[![About](https://img.shields.io/github/sponsors/QuackHack-McBlindy?logo=githubsponsors&label=?&style=flat&labelColor=ff1493&logoColor=fff&color=rgba(234,74,170,0.5) "")](https://github.com/sponsors/QuackHack-McBlindy)  
<div align="right"><sub> _This is a automagiduckically generated README.md_ </sub></div> 
 
> [!CAUTION]
> __Do not blindly run this flake.__ <br>
> **That's my job.** 🧑‍🦯

<br>

## **📌Highlights**

- 🛖 Automated Home Management *(no messy Home-Manager)*
- 🛠️ Integrated CLI Tool
- 🦊 True Declarative Firefox
- 🎨 Set Global Theme
- 📝 Automatic Documentation

<br><br>

__Sup ducks? 🦆 qwack on__ <br> <br>

__Here lives my machines configuration files,__ <br>
__and my personal dotfiles, with a minimalistic flake setup.__  <br>
__With a unified script execution style and automated documentation,__ <br>
__it's deployed and maintained with a Nix flavoured command line utlity.__ <br> <br>

<br><br>



```bash
nix build '.#packages.x86_64-linux."auto-installer.hostname"'
``` 

<br>

<!-- FLAKE_START -->
```nix
# flake.nix
{ 
    description = "❄️🦆 QuackHack-McBlindy's dotfiles! With extra Flakes.";
    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";        
        disko.url = "github:nix-community/disko";
        disko.inputs.nixpkgs.follows = "nixpkgs";
        sops-nix.url = "github:Mic92/sops-nix";
        sops-nix.inputs.nixpkgs.follows = "nixpkgs";  
        caddy-duckdns.url = "github:QuackHack-McBlindy/nix-caddy-duckdns";
    };
    outputs = inputs @ { self, systems, nixpkgs, ... }:
        let
            lib = import ./lib {
                inherit self inputs;
                lib = nixpkgs.lib;      
            };
                    
        in lib.mkFlake {
            systems = [ "x86_64-linux" "aarch64-linux" ]; 
            overlays = [ ];
            hosts = lib.mapHosts ./hosts;
            specialArgs = { pkgs = system: nixpkgs.legacyPackages.${system}; };
            packages = lib.mapModules ./packages import;
            apps = lib.mkApp ./apps.nix;
            devShells = lib.mapModules ./devShells (path: import path);     
        };             
  }
```
<!-- FLAKE_END -->


<details><summary>❄️🌲 FlakeTree</summary>

  <!-- TREE_START -->
```nix
git+file:///home/pungkula/dotfiles
├───apps
│   ├───aarch64-linux
│   │   ├───program: app: no description
│   │   └───type: app: no description
│   └───x86_64-linux
│       ├───program: app: no description
│       └───type: app: no description
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
├───diskoConfigurations: unknown
├───nixosConfigurations
│   ├───desktop: NixOS configuration
│   ├───homie: NixOS configuration
│   ├───laptop: NixOS configuration
│   └───nasty: NixOS configuration
└───packages
    ├───aarch64-linux
    │   ├───health omitted (use '--all-systems' to show)
    │   ├───say omitted (use '--all-systems' to show)
    │   └───tv omitted (use '--all-systems' to show)
    └───x86_64-linux
        ├───"auto-installer.desktop": package 'nixos-minimal-25.05.20250501.f02fddb-x86_64-linux.iso'
        ├───"auto-installer.homie": package 'nixos-minimal-25.05.20250501.f02fddb-x86_64-linux.iso'
        ├───"auto-installer.laptop": package 'nixos-minimal-25.05.20250501.f02fddb-x86_64-linux.iso'
        ├───"auto-installer.nasty": package 'nixos-minimal-25.05.20250501.f02fddb-x86_64-linux.iso'
        ├───health: package 'health'
        ├───say: package 'say'
        └───tv: package 'tv'
```
  <!-- TREE_END -->

</details>

<!-- YO_DOCS_START -->
## 🚀 **yo CLI TOol 🦆🦆🦆🦆🦆🦆**
**Usage:** `yo <command> [arguments]`  

**yo CLI config mode:** `yo config`, `yo edit` 

``` 
❄️ yo CLI Tool
🦆 ➤ Edit hosts
     Edit flake
     Edit yo CLI scripts
     Add new host
     ❌ Remove host 
     🚫 Exit
``` 

## **Usage Examples:**
`yo deploy laptop`
`yo deploy user@hostname`
`yo health`
`yo health --host desktop` 

## ✨ Available Commands
Set default values for your parameters to have them marked [optiional]
| Command Syntax               | Aliases    | Description |
|------------------------------|------------|-------------|
| `yo block --url [--blocklist]` | ad | Block URLs using DNS |
| `yo clean ` | gc | Run a total garbage collection: Removes old NixOS generations, empty trash, flush tmp files, whipes cache and runs a docker prune |
| `yo deploy --host [--flake] [--user] [--repo] [--!]` | d | Deploy NixOS system configurations to your remote servers |
| `yo edit ` | config | yo CLI configuration mode |
| `yo fzf ` | f | Interactive fzf search for file content with quick edit & jump to line |
| `yo health [--host]` | hc | Check system health status across your machines |
| `yo pull [--flake]` | pl | Pull dotfiles repo from GitHub |
| `yo push [--flake] [--repo]` | ps | Update README.md and pushes dotfiles to GitHub with tags |
| `yo reboot [--host]` |  | Force reboot and wait for host |
| `yo rollback [--flake]` |  | Synchronized system+config rollback |
| `yo scp ` | pl | Move files between hosts interactively |
| `yo sops --input [--agePub]` |  | Encrypts a file with sops-nix |
| `yo speed ` | st | Test your internets Download speed |
| `yo switch [--flake] [--autoPull]` | rb | Rebuild and switch Nix OS system configuration |
| `yo yubi --operation --input` | yk | Encrypts and decrypts files using a Yubikey and AGE |
## ❓ Detailed Help
For specific command help: 
`yo <command> --help`
`yo <command> -h`
<!-- YO_DOCS_END -->
