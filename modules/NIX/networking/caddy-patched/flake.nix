{
  description = "Patched version of Caddy with DuckDNS plugin.";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let

      lastModifiedDate = self.lastModifiedDate or self.lastModified or "19700101";

      version = builtins.substring 0 8 lastModifiedDate;

      supportedSystems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });

    in
    {

      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {

          caddy = pkgs.buildGoModule {
            pname = "caddy";
            inherit version;
            src = ./caddy-src;
            runVend = true;
            vendorHash = "sha256-lhycz8kaZajH0cXPu7nJn8xpjD8Rohv8qtbFaz+Yn1w=";


            meta = {
              homepage = "https://caddyserver.com";
              description = "Fast and extensible multi-platform HTTP/1-2-3 web server with automatic HTTPS";
              license = pkgs.lib.licenses.asl20;
              mainProgram = "caddy";
              maintainers = with pkgs.lib.maintainers; [
                Br1ght0ne
                emilylange
                techknowlogick
              ];
            };
          };
          default = self.packages.${system}.caddy;
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [ go ];
          };
        }
      );

    };
}
