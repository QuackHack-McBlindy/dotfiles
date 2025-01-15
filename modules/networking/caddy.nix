{ 
  services.caddy = {
    enable = true;
    package = (pkgs.callPackage /etc/caddy/custom-package.nix {
      plugins = [
        "github.com/caddy-dns/duckdns"
        "github.com/caddyserver/forwardproxy"
      ];
      vendorSha256 = "0000000000000000000000000000000000000000000000000000";
    });
  };
}
