
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

------------

</details>


<details>
<summary>
    
## 🛠️ Usage
    
</summary><br>

**Usage:** <br>


With Nix installed:<br><br>

build auto-installer which can be flashed onto a USB drive,<br> 

```
nix build .#nixosConfigurations.auto-installer
```

<br><br>

build phone-image which can be flashed onto a SD card,<br> 

```
nix build .#nixosConfigurations.phone-image
```

<br>
Qucik test<br>

```
nixos-rebuild switch --flake github:QuackHack-McBlindy/dotfiles#desktop
```



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

------------
</details>

<details>
<summary>Laptop</summary><br>

**Laptop** <br>

Old crappy laptop.<br>

**System:** x86_64-linux <br>

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

<details>
<summary>Keybindings</summary>

```"MUM_+"``` = Magnifier Zoom In <br>

```"MUM_-"``` = Magnifier Zoom Out <br>

```"MUM_*"``` = Screen Reader Toggle <br>

```"§"``` = Open Terminal <br>

```"<Ctrl>" + "Q"``` = Quit open window. <br>

```"<Ctrl>" + "W"``` = Open Firefox <br>

```"<Ctrl>" + "E"``` = Open Editor <br>



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

