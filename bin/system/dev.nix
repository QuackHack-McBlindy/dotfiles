# dotfiles/bin/maintenance/health.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ self, config, pkgs, cmdHelpers, ... }:
{  
  yo.scripts.dev = {
    description = "Start development enviorment";
    category = "🖥️ System Management";
#    aliases = [ "" ];
    parameters = [
      { name = "devShell"; description = "Development enviorment to open"; optional = false; default = "python"; }
      { name = "list"; description = "List all dev shells"; optional = true; type = "bool"; }      
    ];
    code = ''
      ${cmdHelpers}

      if [ "$list" = "true" ]; then
        ls "${config.this.user.me.dotfilesDir}"/devShells
        exit 0
      fi

      if [ "$devShell" = "esp32-rs" ]; then
        mkdir -p ~/projects
        cd ~/projects

        mkdir -p esp32-rs
        cd esp32-rs

        cat > flake.nix << 'EOF'
{
  description = "ESP32 Rust development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, rust-overlay, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ rust-overlay.overlays.default ];
        };
        rust = pkgs.rust-bin.stable.latest.default;
      in {
        devShells.default = pkgs.mkShellNoCC {
          packages = with pkgs; [
            rustup
            rust-analyzer
            cmake
            ninja
            pkg-config
            openssl
            git
            espup
            espflash
            cargo-generate
            ldproxy
            openocd
            gdb
            picocom
            sccache
          ];


          shellHook = '''
            export RUSTC_WRAPPER=sccache
            if ! rustup toolchain list | grep -q esp; then
              echo "Installing esp toolchain..."
              espup install
            fi
            source $HOME/export-esp.sh
            echo ""
            echo "ESP32 Rust environment ready"
          ''';
        };
      });
}
EOF

        nix develop
      else
        target_env="$devShell"
        nix develop ${config.this.user.me.dotfilesDir}#"$devShell"
      fi
    '';


  };}
     
