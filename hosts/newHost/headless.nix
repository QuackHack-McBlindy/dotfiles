{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/firmware.nix
    ./modules/nix-unstable.nix
    ./modules/flakes.nix

  ];

  nixpkgs.config.allowUnfree = true;

  networking.hostName = "installer";

  boot.initrd.systemd.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.firewall.logRefusedConnections = false;
  networking.networkmanager.enable = true;

  services.avahi = {
    enable = true;
    ipv4 = true;
    ipv6 = true;
    nssmdns4 = true;
    publish = { enable = true; domain = true; addresses = true; };
  };

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    tmux
    unzip
  ];




  security.sudo.wheelNeedsPassword = false;
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;  # Disable password auth
      PermitRootLogin = "yes";  # Disallow root login
      AllowUsers = null;  # Restrict SSH logins to these users

      DisableForwarding = false;  # Allow port forwarding
      PermitEmptyPasswords = true;  # Disallow empty passwords
      ClientAliveInterval = 60;  # Server sends keep-alive messages every 60 seconds
      ClientAliveCountMax = 3;  # Disconnect clients after 3 missed keep-alives
    };
  };

  networking.firewall.allowedTCPPorts = [ 22 ];

  users.mutableUsers = false;
  users.extraUsers.root.password = "";

  users.users.pungkula = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "kvm"
    ];
    initialPassword = "";
    openssh.authorizedKeys.keys = [
      "ssh-rsa x7qq8zRAH5jdxUduQ/ThAmvjYm91H42QVm70OCFjjb8dg9LIb/va2j1eakNlBiwCmUK7frmRkWjFj+2t5zCTd2iLpygLv7PvFVIidxAoXLdTxilAAg2ZlX/xSGvRPkaqX/ZQfR5j3OCVYy6aV4VonbIUids7kUynRz9SRN2AHmLpK/oniwlwhAS5aa0PvC8Ln7x3wzhH501sLKk+krNpOEr4E1AA/VwOMqSqU4KTMoYzkUix9YnnAf70AQV6rZ4NxNrqWcZve/UGqMxtUbxMP7rL8hxKihc0Zdus5zxDEZ36oXIDYq9kQ3KgJZx4aVPePEX68A8fxhx6zIOfsg0Hz6M3ko53MhG/qZhYmDvTG1548tgn24gQjEawRjUc2a6gEH+va+TP99260ELeWZD3AHzIzL+ln4BBGcYgNglkIxpI5gH7LqeQ+XHlW8iQbnlfRUYKo72MGA8KLDPP3IHhWa5cSN4DKBlgEJ8ijUbcYqES4dK34cqyM1JWVTnEdw== pungkula@desktop.com"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE6UXhj/qh1qSnHdAuPyOUr0OQyJ1QIy5QlZu3y7CaGV pungkula@desktop"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE6UXhj/qh1qSnHdAuPyOUr0OQyJ1QIy5QlZu3y7CaGV"       
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPwZL27kGTQDIlSe03abT9F24nSAizORyjo5cI3BD92s your_email@example.com"
    ];       
  };
}


