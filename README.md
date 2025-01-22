
# ❄️🦆 **Flake** <br><br>
<details>
<summary>

## 🗒 Introduction
    
</summary><br>

This repo contains NixOS configuration flake for my hosts on my home network/homelab. <br>

<img src="./home/screenshot1.png" width="48%" style="display: inline-block; margin-right: 2%;">
<img src="./home/screenshot2.png" width="48%" style="display: inline-block;">

<br><br>

**❄️ This flake main focus will be on:** 

- **Custom Accessibility**
- **Good Reproducibility**
- **& Easy Usage**

<br>

## 🔧 Components

| Component        | Version/Name                   |
| ---------------- | ------------------------------ |
| Distro           | NixOS                          |
| Shell            | Bash                           |
| Display Server   | Wayland                        |
| WM (Compositor)  |                       |
| Bar              | OpenBar                        |
| Notification     | notifyd                          |
| Launcher         |                         |
| Editor           | nano                        |
| Terminal         | Gnome-Terminal                         |
| Fetch Utility    | Neofetch                       |
| Theme            |            |
| Font             |   |
| File Browser     | Thunar    |
| Internet Browser | Customized Firefox                        |
| Screenshot       |                        |
| Clipboard        | wl-clipboard                   |
| Idle             |                        |
| Lock             |                        |
| Logout menu      |                         |
| Display Manager  | Gnome                        |
| Containerization | Docker                         |
| Virtualisation   | qemu + virt-manager + libvirtd |

<br>

------------

</details>



<details>
<summary>
    
## 🖥️ Hosts
    
</summary><br>


<details>
<summary>Desktop</summary> <br>

**Desktop** <br>

Main machine.  <br> 
Brag build for SteelSeries World Championchip Builds. <br><br>

**System:** x86_64-linux <br>

<details>
<summary>⌨ Keybindings</summary>


| Key Combination           | Action                                                                |
| ------------------------- | --------------------------------------------------------------------- |
| MUM +                      | Magnifier Zoom In                                                     |
| MUM -                      | Magnifier Zoom Out                                                    |
| MUM /
| Screen Reader Toggle                                                  |
| §                          | Open Terminal                                                          |
| CTRL + Q                   | Close open window                                                      |
| CTRL + W                   | Open Firefox                                                          |
| CTRL + E                   | Open Editor                                                           |
| ALT/SUPER + TAB            | Switch Windows                                                          |

<br>
All keybindings for this device are listed [here](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/home-manager/keybindings-desktop.nix) <br>


</details>

------------
</details>

<details>
<summary>Laptop</summary><br>

**Laptop** <br>

Old crappy laptop.<br>

**System:** x86_64-linux <br>


<details>
<summary>⌨ Keybindings</summary>


| Key Combination           | Action                                                                |
| ------------------------- | --------------------------------------------------------------------- |
| MUM +                      | Magnifier Zoom In                                                     |
| MUM -                      | Magnifier Zoom Out                                                    |
| MUM /
| Screen Reader Toggle                                                  |
| §                          | Open Terminal                                                          |
| CTRL + Q                   | Close open window                                                      |
| CTRL + W                   | Open Firefox                                                          |
| CTRL + E                   | Open Editor                                                           |
| ALT/SUPER + TAB            | Switch Windows                                                          |

<br>
All keybindings for this device are listed [here](https://github.com/QuackHack-McBlindy/dotfiles/blob/main/home-manager/keybindings-laptop.nix) <br>


</details>


------------
</details>

<details>
<summary>Nasty</summary><br>

**Nasty** <br>

Huge Mass Storage NAS - Creates Pool with mergerfs.<br>
15x 3.5" drives. Runs media servers and rreverse proxy.<br>
**System:** x86_64-linux <br>

------------
</details>

<details>
<summary>Tiny</summary><br>

**Tiny** <br>

Raspberry Pi 4 server with raid 1 - for personal data storage. <br>
**System:** aarch64-linux <br>

------------
</details>

<details>
<summary>Homie</summary><br>

**Homie** <br>

Smaall fanless server to run my smart home devices and everything related. <br>
**System:** x86_64-linux <br>

------------
</details>

<details>

<summary>Phone</summary><br>

PinePhone <br>
**System:** aarch64-linux <br>


------------
</details>

<details>
<summary>Smart Watch</summary> <br>

**Smart Watch** <br>

ESP32 Smart Watch.  <br> 

**System:** ESP32 device <br>

------------
</details>

<details>
<summary>Voice Assistant</summary> <br>

**Voice Assistant** <br>

A ESP32-S3-Box3 used as a voice assistant.  <br> 

**System:** ESP32 device <br>

------------
</details>




</details>




<details>
<summary>
    
## 🚀 Features
    
</summary><br>


<details>
<summary>Accessibility</summary><br>

Custom orca configuration, with Piper TTS and langid for auto detecting language of text and provide correct model. <br>


------------
</details>

<details>
<summary>Secret Management</summary>
sops-nix <br>
age-plugin-yubikey <br>

------------
</details>



------------
</details>

</details>

<details>
<summary>
    
## 🌐 Networking
    
</summary><br>

**Reverse Proxy:** Caddy <br>
**WireGuard**


</details>


<details>
<summary>
    
## 🧑‍🦯 Scripts
    
</summary><br>

**Scripts** <br>

</details>


</details>

