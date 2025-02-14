let
  caddyFlake = import ./caddy/flake.nix;
  myCaddy = caddyFlake.packages.x86_64-linux.caddy;  # Adjust for your system
in

  environment.systemPackages = with pkgs; [
    myCaddy
  ];


  services.caddy = {
    enable = true;
    package = myCaddy;  # Use the built Caddy package or the Nixpkgs package
    configFile = "/etc/caddy/Caddyfile";  # Path to your Caddyfile
    user = "caddy";
    group = "caddy";
    extraConfig = ''
      # Additional custom configuration can go here
    '';
  };
