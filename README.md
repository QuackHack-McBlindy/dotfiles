# ❄️🦆 **QuackHack-McBLindy NixOS dotfiles** <br>

<div align="right">
<sub>
> [!CAUTION]
> __Use with caution!__ <br>
</sub></div><br>

Sup duck? 🦆 <br>
This is a automagiduckically generated README.md  <br>

<!-- TREE_START -->
```nix
[1mgit+file:///home/pungkula/dotfiles[0m
[32;1m├───[0m[1mapps[0m
[32;1m│   ├───[0m[1maarch64-linux[0m
[32;1m│   │   ├───[0m[1mprogram[0m: app
[32;1m│   │   └───[0m[1mtype[0m: app
[32;1m│   └───[0m[1mx86_64-linux[0m
[32;1m│       ├───[0m[1mprogram[0m: app
[32;1m│       └───[0m[1mtype[0m: app
[32;1m├───[0m[1mdevShells[0m
[32;1m│   ├───[0m[1maarch64-linux[0m
[32;1m│   │   ├───[0m[1mandroid[0m [35;1momitted[0m (use '--all-systems' to show)
[32;1m│   │   ├───[0m[1mgo[0m [35;1momitted[0m (use '--all-systems' to show)
[32;1m│   │   ├───[0m[1mjava[0m [35;1momitted[0m (use '--all-systems' to show)
[32;1m│   │   ├───[0m[1mnode[0m [35;1momitted[0m (use '--all-systems' to show)
[32;1m│   │   ├───[0m[1mpython[0m [35;1momitted[0m (use '--all-systems' to show)
[32;1m│   │   └───[0m[1mrust[0m [35;1momitted[0m (use '--all-systems' to show)
[32;1m│   └───[0m[1mx86_64-linux[0m
[32;1m│       ├───[0m[1mandroid[0m: development environment 'nix-shell'
[32;1m│       ├───[0m[1mgo[0m: development environment 'nix-shell'
[32;1m│       ├───[0m[1mjava[0m: development environment 'nix-shell'
[32;1m│       ├───[0m[1mnode[0m: development environment 'nix-shell'
[32;1m│       ├───[0m[1mpython[0m: development environment 'nix-shell'
[32;1m│       └───[0m[1mrust[0m: development environment 'nix-shell'
[32;1m├───[0m[1mnixosConfigurations[0m
[32;1m│   ├───[0m[1mdesktop[0m: [35;1mNixOS configuration[0m
[32;1m│   ├───[0m[1mhomie[0m: [35;1mNixOS configuration[0m
[32;1m│   ├───[0m[1mlaptop[0m: [35;1mNixOS configuration[0m
[32;1m│   └───[0m[1mnasty[0m: [35;1mNixOS configuration[0m
[32;1m└───[0m[1mpackages[0m
[32;1m    ├───[0m[1maarch64-linux[0m
[32;1m    │   ├───[0m[1mexample[0m [35;1momitted[0m (use '--all-systems' to show)
[32;1m    │   ├───[0m[1mhealth[0m [35;1momitted[0m (use '--all-systems' to show)
[32;1m    │   ├───[0m[1msay[0m [35;1momitted[0m (use '--all-systems' to show)
[32;1m    │   └───[0m[1mtv[0m [35;1momitted[0m (use '--all-systems' to show)
[32;1m    └───[0m[1mx86_64-linux[0m
[32;1m        ├───[0m[1m"auto-installer.desktop"[0m: package 'nixos-minimal-25.05.20250405.42a1c96-x86_64-linux.iso'
[32;1m        ├───[0m[1m"auto-installer.homie"[0m: package 'nixos-minimal-25.05.20250405.42a1c96-x86_64-linux.iso'
[32;1m        ├───[0m[1m"auto-installer.laptop"[0m: package 'nixos-minimal-25.05.20250405.42a1c96-x86_64-linux.iso'
[32;1m        ├───[0m[1m"auto-installer.nasty"[0m: package 'nixos-minimal-25.05.20250405.42a1c96-x86_64-linux.iso'
[32;1m        ├───[0m[1mexample[0m: package 'hello-0.1.0'
[32;1m        ├───[0m[1mhealth[0m: package 'health'
[32;1m        ├───[0m[1msay[0m: package 'say'
[32;1m        └───[0m[1mtv[0m: package 'tv'
```
<!-- TREE_END -->

<br>

<!-- YO_DOCS_START -->
## Define scripts

```nix

```

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
