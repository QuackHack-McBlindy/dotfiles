# ddotfiles/packages/tv.nix ⮞ https://github.com/QuackHack-McBlindy/dotfiles
{ 
  self,
  stdenv,
  lib,
  python3,
} : let # 🦆 says ⮞ python dependencies

in  # 🦆 says ⮞ code source
stdenv.mkDerivation {
    name = "jellyfin";
    src = ./jellyfin;
}    
