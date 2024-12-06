{ config, pkgs, lib, inputs, user, ... }:
{

    users.defaultUserShell = pkgs.bash; 
    users.users.${user} = {
      hashedPassword = "$6$ywtdfbhjDtQE9b5s$fPIAqx0fCkd2G07Sz8SeJzr.Ds.yFb69SEJL3Oj.o6crBAXH3ExWdZnlwGIsbeSPAkB4QR.fazgVfHZW0gwvf0";
      isNormalUser = true;
      description = "${user}";
      extraGroups = [ "networkmanager" "wheel" "qemu-libvirtd" "libvirtd" "kvm" "docker" "amdgpu" ];
      packages = with pkgs; [
        xdg-utils
        xwaylandvideobridge
      ];
      openssh.authorizedKeys.keys = [
        "ssh-rsa x7qq8zRAH5jdxUduQ/ThAmvjYm91H42QVm70OCFjjb8dg9LIb/va2j1eakNlBiwCmUK7frmRkWjFj+2t5zCTd2iLpygLv7PvFVIidxAoXLdTxilAAg2ZlX/xSGvRPkaqX/ZQfR5j3OCVYy6aV4VonbIUids7kUynRz9SRN2AHmLpK/oniwlwhAS5aa0PvC8Ln7x3wzhH501sLKk+krNpOEr4E1AA/VwOMqSqU4KTMoYzkUix9YnnAf70AQV6rZ4NxNrqWcZve/UGqMxtUbxMP7rL8hxKihc0Zdus5zxDEZ36oXIDYq9kQ3KgJZx4aVPePEX68A8fxhx6zIOfsg0Hz6M3ko53MhG/qZhYmDvTG1548tgn24gQjEawRjUc2a6gEH+va+TP99260ELeWZD3AHzIzL+ln4BBGcYgNglkIxpI5gH7LqeQ+XHlW8iQbnlfRUYKo72MGA8KLDPP3IHhWa5cSN4DKBlgEJ8ijUbcYqES4dK34cqyM1JWVTnEdw== pungkula@desktop.com"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE6UXhj/qh1qSnHdAuPyOUr0OQyJ1QIy5QlZu3y7CaGV pungkula@desktop"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE6UXhj/qh1qSnHdAuPyOUr0OQyJ1QIy5QlZu3y7CaGV"       
      ];
    };

  security.sudo = {
    enable = true;
    extraConfig = ''
      %wheel ALL=(ALL) NOPASSWD: ALL
    '';
  };
  # swaylock pass verify
    security.pam.services.swaylock = {
      text = ''
      auth include login
      '';
    };
  
    services.gnome.gnome-keyring.enable = true;
    programs.nautilus-open-any-terminal = {
        enable = true;
        terminal = "kitty";
      };
    services.gvfs.enable = true; 
    programs.dconf.enable = lib.mkDefault true;
    
    environment.etc."xdg/user-dirs.defaults".text= ''
    DESKTOP=$HOME/dotfiles
    DOWNLOAD=$HOME/Downloads
    TEMPLATES=$HOME/Templates
    PUBLICSHARE=$HOME/Public
    DOCUMENTS=$HOME/duckOS/dev
    MUSIC=$HOME/Music
    PICTURES=$HOME/Photos
    VIDEOS=$HOME/Video 
    '';  
}

