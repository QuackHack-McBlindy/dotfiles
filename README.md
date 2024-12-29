<h2 align="center">:snowflake: flakes with Custom Acessibility enabled :snowflake:</h2>

<p align="center">
    <img src="https://img.shields.io/badge/NixOS-25.05-informational.svg?style=for-the-badge&logo=nixos&color=161616&logoColor=42be65&labelColor=dde1e6"></a>
    <img src="https://img.shields.io/github/last-commit/71zenith/kiseki?style=for-the-badge&labelColor=dde1e6&color=161616"/>
    <img src="https://img.shields.io/github/repo-size/71zenith/kiseki?style=for-the-badge&labelColor=dde1e6&color=161616"/>
    <img src="https://img.shields.io/github/languages/code-size/71zenith/kiseki?color=161616&style=for-the-badge&labelColor=dde1e6"/>
</p>


## Table Of Contents

- ℹ [Highlights](#-highlights)
- 🔧 [Components](#-components)
- ⌨ [Keybindings](#-keybindings)
- [NixOS specific zsh aliases](#-nixos-specific-zsh-aliases)
- 📖 [License](#-license)

<details><summary><b>## ℹ About</b></summary>

This repository holds my personal NixOS configuration using ❄️ flakes, running Gnome and declares my dotfiles using Home-Manager.

As I can barly see, my entire operating system's main focus will be to make it as reproducable as possible while perfecting the accessibility, to get it customized to make everyday use as easy as possible.
If by any chance any other visually impaired person would happen to find its way here, I hope this repository will prove that Nix OS is without doubt the optimal choice, even for someone as blind as I am.

Feel free to learn, use or steal.
</details>


- **flake** (Experimental feature of the Nix package manager)
- **nixpkgs**: unstable

## 🚀 Highlights

| Component        | About                 |
| ---------------- | ------------------------------ |
| Strong Accessibility | Strong  custom accessibility focus on low vision. |
| Multi Plattform  | Flake covers all my devices.    |
| Security         | Hardware key for PAM, WebAuthn, LUKS, and more. |
| Secrets          | Secured secrets with Sops-Nix. |
| Browser          | Highly customized Firefox ESR. |
| Simple Usage     | Custom scripts for easy maintence.|                       |
| Webfrontend      | Dashboard secured with Yubikey. |



## 🔧 Components

| Component        | Version/Name                   |
| ---------------- | ------------------------------ |
| Distro           | NixOS                          |
| Shell            | Zsh                            |
| Display Server   | Wayland                        |
| WM (Compositor)  | Hyprland                       |
| Bar              | Waybar                         |
| Notification     | Mako                           |
| Launcher         | Wofi                           |
| Editor           | Neovim                         |
| Terminal         | Kitty                          |
| Fetch Utility    | Neofetch                       |
| Theme            | Catppuccin Macchiato           |
| Font             | JetBrains Mono & Font Awesome  |
| File Browser     | Thunar & viewnior for images   |
| Internet Browser | Firefox                        |
| Screenshot       | Hyprshot                       |
| Clipboard        | wl-clipboard                   |
| Idle             | Swayidle                       |
| Lock             | Swaylock                       |
| Logout menu      | Wlogout                        |
| Wallpaper        | Hyprpaper                      |
| Display Manager  | SDDM                           |
| Containerization | Podman                         |
| Virtualisation   | qemu + virt-manager + libvirtd |

## ⌨ Keybindings

| Key Combination           | Action                                                                |
| ------------------------- | --------------------------------------------------------------------- |
| SUPER + H, J, K, L        | Change window focus                                                   |
| SUPER + CTRL + H, J, K, L | Resize window                                                         |
| SUPER + SHIFT + H,J,K,L   | Move windows                                                          |
| SUPER + 1..0              | Change workspace                                                      |
| SUPER + SHIFT + 1..0      | Move window to workspace                                              |
| SUPER + S                 | Toggle split                                                          |
| SUPER + Q                 | Kill active window                                                    |
| SUPER + SHIFT + Q         | Launch `swaylock`                                                     |
| SUPER + M                 | Exit from `hyprland`                                                  |
| SUPER + Return            | Launch `kitty`                                                        |
| SUPER + D                 | Launch `wofi`                                                         |
| SUPER + E                 | Launch `thunar`                                                       |
| SUPER + M                 | Launch `wlogout`                                                      |
| SUPER + B                 | Launch `firefox`                                                      |
| SUPER + C                 | Launch `telegram-desktop`                                             |
| Print                     | Take screenshot (currently configured to area capture into clipboard) |

All other keybindings can be found at [bind.conf](./home/config/hypr/bind.conf)

## NixOS specific zsh aliases

- **fullClean** - Fully clean old generations data
- **rebuild** - alias to `nixos-rebuild switch`
- **fullRebuild** - same as previous but also includes `home-manager switch`
- **homeRebuild** - only rebuild home-manager

> Make sure to make appropriate changes to [shell.nix](./home/user/shell.nix) flake paths.

## 📖 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
