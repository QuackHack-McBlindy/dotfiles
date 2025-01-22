{ config, pkgs, lib, ... }:

{
  system.activationScripts.createDirs = {
    text = ''
      directories=(${builtins.readFile ./folders.nix})
      
      for dir in $directories; do
        if [ ! -d "$dir" ]; then
          mkdir -p "$dir"
          echo "Created directory: $dir"
        else
          echo "Directory already exists: $dir"
        fi
      done
    '';
  };
}

