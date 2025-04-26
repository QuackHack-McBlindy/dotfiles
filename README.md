# ❄️🦆 **QuackHack-McBLindy NixOS dotfiles** <br>

<div align="right">
<sub>
> [!CAUTION]
> __Don't blindy run this flake!__ <br>
> **that's my job.**
</sub></div><br>

![Nix](https://img.shields.io/badge/Nix-2.18.1-blue) <br>

Sup ducks? 🦆 <br>
This is a automagiduckically generated README.md  <br>


## **❄️🪾 FlakeTree **

<!-- TREE_START -->
```nix
git+file:///home/pungkula/dotfiles
├───apps
│   ├───aarch64-linux
│   │   ├───program: app
│   │   └───type: app
│   └───x86_64-linux
│       ├───program: app
│       └───type: app
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
    │   ├───example omitted (use '--all-systems' to show)
    │   ├───health omitted (use '--all-systems' to show)
    │   ├───say omitted (use '--all-systems' to show)
    │   └───tv omitted (use '--all-systems' to show)
    └───x86_64-linux
        ├───"auto-installer.desktop": package 'nixos-minimal-25.05.20250405.42a1c96-x86_64-linux.iso'
        ├───"auto-installer.homie": package 'nixos-minimal-25.05.20250405.42a1c96-x86_64-linux.iso'
        ├───"auto-installer.laptop": package 'nixos-minimal-25.05.20250405.42a1c96-x86_64-linux.iso'
        ├───"auto-installer.nasty": package 'nixos-minimal-25.05.20250405.42a1c96-x86_64-linux.iso'
        ├───example: package 'hello-0.1.0'
        ├───health: package 'health'
        ├───say: package 'say'
        └───tv: package 'tv'
```
<!-- TREE_END -->

<br>

## 🚀 **Declare scripts with parameters**

```nix
yo.scripts = {
  example = {
    description = "Cool script yo";
    alias = [ "e" ];
    parameters = [
      { 
        name = "input";
        description = "Input file for examplez";
        optional = false; # always required parameters first
      }
      {
        name = "agePub";
        description = "AGE Public key";
        optional = true;
        default = config.this.host.keys.publicKeys.age; # Set a default value to make it optional
      }  
    ];
  };
};  
```


<!-- YO_DOCS_START -->
## 🚀 **yo CLI TOol 🦆🦆🦆🦆🦆🦆**
**Usage:** `yo <command> [arguments]`  

**yo CLI config mode:** `yo config`, `yo edit` 

``` 
❄️ yo CLI Tool
🦆 ➤ Edit hosts
     Edit yo CLI scripts
     Edit flake
     Add new host
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
| `yo clean ` | gc | Run a total garbage collection: Removes old NixOS generations, empty trash, flush tmp files, whipes cache and runs a docker prune |
| `yo deploy --host [--flake] [--user] [--repo] [--!]` | d | Deploy NixOS system configurations to your remote servers |
| `yo edit ` | config | yo CLI configuration mode |
| `yo health [--host]` | hc | Check system health status across your machines |
| `yo pull [--flake]` | pl | Pull dotfiles repo from GitHub |
| `yo push [--flake] [--repo]` | ps | Push dotfiles to GitHub |
| `yo reboot [--host]` |  | Force reboot and wait for host |
| `yo rollback ` |  | Synchronized system+config rollback |
| `yo sops --input [--agePub]` |  | Encrypts a file with sops-nix |
| `yo switch [--flake] [--autoPull]` | rb | Rebuild and switch Nix OS system configuration |
| `yo yubi --operation --input` | yk | Encrypts and decrypts files using a Yubikey and AGE |
## ℹ️ Detailed Help
For specific command help: 
`yo <command> --help`
`yo <command> -h`
<!-- YO_DOCS_END -->
