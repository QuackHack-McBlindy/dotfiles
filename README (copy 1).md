# ❄️🦆 **Flake: Just4Quackz** <br>

<div align="right">
<sub>

 
</sub></div><br>


> [!CAUTION]
> __Not a plug and play flake!__ <br>
> Use with caution! <br>

<details>
<summary>

## ⁉️ Introduction
    
</summary><br>

This repo contains NixOS configuration flake for my personal machines on home network. <br>
This flake holds everything neeeded to build, run, maintain - <br>
and restore and recover my devices. <br> 
🧑‍🦯 🧑‍🦯 🧑‍🦯  <br>

<p align="center"> <img src="./home/hosts/desktop/screenshot-lock.png" width="40%" style="display: inline-block; margin-right: 2%;"></p> <br>
<img src="./home/hosts/desktop/screenshot1.png" width="48%" style="display: inline-block; margin-right: 2%;">
<img src="./home/hosts/desktop/screenshot2.png" width="48%" style="display: inline-block;">

<br><br>

### **❄️ This flake main focus will be on:** 

- **Custom Accessibility** 
- **Good Reproducibility**
- **Easy Usage**

<br>

<details><summary>

### 🔧 **Components**

<br>
</summary>

| Component        | Version/Name                   |
| ---------------- | ------------------------------ |
| Distro           | NixOS                          |
| Shell            | Bash                           |
| Display Server   | Wayland                        |
| Bar              | OpenBar                        |
| Notification     | libnotify                      |
| Editor           | vim / Getty                    |
| Terminal         | Ghostty                        |
| Prompt           | Starship
| Fetch Utility    | Neofetch                       |
| Theme            | Custom                         |
| File Browser     | Thunar                         |
| Internet Browser | Custom Firefox                 |
| Intent Recognition | Hassil                       |
| Speech To Text   | Faster Whisper                 |
| Wakeword         | Open Wake Word                 |
| Clipboard        | nix-shell -p (optional)        |
| Display Manager  | Gnome                          |
| Containerization | Docker                         |
| Virtualisation   | qemu + virt-manager + libvirtd |
| VPN              | WireGuard
<br>

</details>
<br>

------------

<br>
</details>



<details>
<summary>
### 🔧 **CLI Toool execution**

<!-- YO_DOCS_START -->

  ## 🚀 yo CLI TOol 🦆🦆🦆🦆🦆🦆                                                                                                                                                                
                                                                                                                                                                                                
  Usage:  yo <command> [arguments]                                                                                                                                                              
                                                                                                                                                                                                
  Edit configurations  yo edit                                                                                                                                                                  
                                                                                                                                                                                                
  ## Usage Examples:                                                                                                                                                                            
                                                                                                                                                                                                
   yo deploy laptop                                                                                                                                                                             
   yo deploy user@hostname                                                                                                                                                                      
   yo health                                                                                                                                                                                    
   yo health --host desktop                                                                                                                                                                     
                                                                                                                                                                                                
  ## ✨ Available Commands                                                                                                                                                                      
                                                                                                                                                                                                
  Set default values for your parameters to have them marked [optiional]                                                                                                                        
                                                                                                                                                                                                
  Command Syntax                                      │Aliases│Description                                                                                                                      
  ────────────────────────────────────────────────────┼───────┼─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   yo clean                                           │gc     │Run a total garbage collection: Removes old NixOS generations, empty trash, flush tmp files, whipes cache and runs a docker prune
   yo deploy --host [--flake] [--user] [--repo] [--!] │d      │Deploy NixOS system configurations to your remote servers                                                                        
   yo edit                                            │config │yo CLI configuration mode                                                                                                        
   yo health [--host]                                 │hc     │Check system health status across your machines                                                                                  
   yo pull [--flake]                                  │pl     │Pull dotfiles repo from GitHub                                                                                                   
   yo push [--flake] [--repo]                         │ps     │Push dotfiles to GitHub                                                                                                          
   yo reboot [--host]                                 │       │Force reboot and wait for host                                                                                                   
   yo rollback                                        │       │Synchronized system+config rollback                                                                                              
   yo sops --input [--agePub]                         │       │Encrypts a file with sops-nix                                                                                                    
   yo switch [--flake] [--autoPull]                   │rb     │Rebuild and switch Nix OS system configuration                                                                                   
   yo yubi --operation --input                        │yk     │Encrypts and decrypts files using a Yubikey and AGE                                                                              
                                                                                                                                                                                                
  ## ℹ️ Detailed Help                                                                                                                                                                           
                                                                                                                                                                                                
  For specific command help:                                                                                                                                                                    
   yo <command> --help                                                                                                                                                                          
   yo <command> -h                                                                                                                                                                              


<!-- YO_DOCS_END -->
<br>
</summary>


</details>
