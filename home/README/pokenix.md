<div align="center">

<img
  src="https://raw.githubusercontent.com/QuackHack-McBlindy/pokenix/main/images/logo-compressed.png"
  alt="Logo"
  width="240"
>

<br>

![License](https://img.shields.io/badge/license-MIT-black?style=flat-square&logo=opensourceinitiative&logoColor=white)
[![Sponsors](https://img.shields.io/github/sponsors/QuackHack-McBlindy?logo=githubsponsors&label=Sponsor&style=flat&labelColor=ff1493&logoColor=fff&color=rgba(234,74,170,0.5) "")](https://github.com/sponsors/QuackHack-McBlindy)
[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-Sponsor?style=flat&logo=buymeacoffee&logoColor=fff&labelColor=ff1493&color=ff1493)](https://buymeacoffee.com/quackhackmcblindy)

![Updated for](https://img.shields.io/badge/Updated%20for-Pok%C3%A9mon%20Scarlet%2FViolet%20(The%20Hidden%20Treasure%20of%20Area%20Zero%20DLC)-blue)

![CI](https://github.com/quackhack-mcblindy/pokenix/actions/workflows/ci.yml/badge.svg)
[![Built with Nix](https://img.shields.io/badge/Built%20with-Nix-5277C3?style=flat&labelColor=5277C3&color=555&logo=nixos&logoColor=fff)](https://nixos.org)

</div>


# **PokéNix - Pokémon Collection Builder**

**You** simply write your Pokémons using the options.<br>
**PokéNix** generate, builds and deploy your Pokèmon collection website.<br>
**Version controlled, and always online.**<br>

<br>

- [x] **Web Editor** - Modify your collection straight from the website!
- [x] **Trainer** - Who's training these Pokémon?
- [x] **Breedable Apriballs Pokémon** - Optimized for breeding/trading. Click #Dex link to serebii. Click your chosen balls and CTRL + C them as a list. Click any Pokémon to view all their egg moves. Hover for move info.  
- [x] **Event Pokémon** - A collection worth Cherish*ishing*.
- [x] **True** *(♀️♂️)* **Shiny Living Dex** - Watch your shiny progress grow in %. Easy toggle between caught/missing.
- [x] **Specials** - Rare marks, ribbons or simply shared memories, any Pokémon belongs! Document anything! Enter IV/EV, nature and your Pokémon stats willl be auto-generated and displayed. 
- [x] **Search** - Quickly live search and find what you are looking for.
- **GitHub Pages** - If used with GitHub Pages: ❌ **terminal**, ❌ **Nix**, ❌ **local download required**. ✅ **Simple!**



<br>
<a href="https://quackhack-mcblindy.github.io/pokenix/">PokéNix Live Example</a>
<br>

## **Installation**

Pick one of the three ways below.<br>
Battle tested and ready to use templates for every section can be found in <a href="templates/">templates/</a>.<br>

<br>

<details><summary><strong>
Using GitHub Pages: No terminal, Nix or local install required.
</strong></summary>

You need a GitHub account *(free)*.

1. Log in to GitHub and click **Fork** on this repository.
2. On your forked repo, go to the browser address bar and add `/actions` at the end and press the Enter key. Click **I understand my workflows, go ahead and enable them**. Forks start with Actions turned off, so nothing gets built until you do this.
3. Go to **Settings > Pages** and set **Source** to **GitHub Actions**.
4. Open the file `my-pokemon.nix` and click the pencil icon.
5. Change `name = "PokèNix";` to your trainer name **(important!)**. If you keep the default name, your site shows the example collection instead of yours.
6. Add your Pokémon (helpful comments in the file), then click **Commit changes**.
7. Open the **Actions** tab and wait for **Build and deploy** to turn green. It takes about 3 minutes, a few minutes longer the first time. If it turns red, click the run to see which line of `my-pokemon.nix` it didn't like.
8. Visit `https://<YOUR-GITHUB-USERNAME>.github.io/pokenix/`. The link is also shown on the finished run.

<br>

When a PokéNix update (bug fixes or new Pokémon) is available, click **Sync fork** on your forked repository. Your `my-pokemon.nix` is kept.<br>
If GitHub reports a conflict, don't click **Discard commits**, that deletes your changes.<br>

<br>

</details>

<br>


<details><summary><strong>
❄️ Using flakes (NixOS)
</strong></summary>


#### **1: Add PokéNix as input in your flake.nix and add the module**

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    pokenix.url = "github:quackhack-mcblindy/pokenix";
  };

  outputs = { nixpkgs, pokenix, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        pokenix.nixosModules.pokenix
      ];
    };
  };
}
```

<br>

#### **2: Write your Pokémon and serve the site**

Your collection goes under `pokenix` in your configuration, the same options as in `my-pokemon.nix`.<br>
The module builds the site into `config.pokenix.html`, so any web server can serve it. Example with nginx:

```nix
{ config, ... }: {
  pokenix.trainer.name = "Ash";
  # Add your Pokémon here, see templates/

  services.nginx = {
    enable = true;
    virtualHosts."pokemon.local".root = config.pokenix.html;
  };
}
```

<br>

#### **3: Rebuild your system**

```bash
sudo nixos-rebuild switch --flake .#myhost
```

**Done!** Your collection is served on the host name you set in `virtualHosts`.

<br>

</details>

<br>

<details><summary><strong>
Linux / WSL, with Nix installed
</strong></summary>


```bash
git clone https://github.com/QuackHack-McBlindy/pokenix
cd pokenix
$EDITOR my-pokemon.nix
nix --extra-experimental-features 'nix-command flakes' build .#default
xdg-open result/index.html
```

macOS isn't supported yet, the flake only builds for `x86_64-linux` and `aarch64-linux`.

<br>

</details>

<br>


## **Notes**


♥️ **Special thanks to** <a href="https://github.com/msikma/pokesprite">msikma/pokesprite</a> for making this project possible.

<br>

For a more detailed and advanced option documentation, click <a href="https://htmlpreview.github.io/?https://github.com/quackhack-mcblindy/pokenix/blob/main/docs/index.html">here</a> .

<br>

## **Disclaimer**


Pokémon and all related names, characters, designs, and trademarks belong to their respective owners, including Nintendo, Creatures Inc., and GAME FREAK inc.<br>
PokéNix is an unofficial fan project and is not affiliated with or endorsed by them.<br>


<br>


## **License**

This project is licensed under the terms of the MIT license.<br>
See the `LICENSE` file in the repository for full details.<br>

Contributions are welcomed.
