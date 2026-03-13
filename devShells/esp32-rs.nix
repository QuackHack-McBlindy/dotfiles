# dotfiles/devShells/esp32-rs.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ esp32 development with rust
  pkgs,
  system,
  inputs,
  self
} : let # 🦆says⮞ list dependencies
  myBuildInputs = with pkgs; [
    git
    nixpkgs-fmt
    rustc
    cargo
    clippy
    rustfmt    
    rust-bin.stable.latest.default
    cmake
    ninja
    pkg-config  
    # 🦆 says ⮞ ESP tools
    espflash
    cargo-generate            
    ldproxy
    espup
    # 🦆 says ⮞ serial tools
    minicom    
  ];

  formatRed = name: "echo - \$'\\e[0;31m'${name}\$'\\e[0m'";
  formatHeader = text: "echo \$'\\e[1m'${text}\$'\\e[0m'";
in {
  buildInputs = myBuildInputs;

  # 🦆 says ⮞ hook it
  shellHook = ''
    export ESPUP_HOME=$PWD/.esp
    export PATH=$ESPUP_HOME/bin:$PATH

    if [ ! -d "$ESPUP_HOME" ]; then
      echo "Installing esp-rs toolchain via espup..."
      espup install
    fi
            
    export LIBCLANG_PATH="~/.rustup/toolchains/esp/xtensa-esp32-elf-clang/esp-20.1.1_20250829/esp-clang/lib"
    export PATH="~/.rustup/toolchains/esp/xtensa-esp-elf/esp-15.2.0_20250920/xtensa-esp-elf/bin:$PATH"
    export CROSS_COMPILE=xtensa-esp32s3-elf
    export CFLAGS=-mlongcalls     
      
    # 🦆 says ⮞ New project?
    choice=$(gum choose "New project" "No")
    if [ "$choice" = "New project" ]; then
      cargo generate --git https://github.com/esp-rs/esp-idf-template cargo
    fi
            
    rustup target add xtensa-esp32s3-espidf   

    # 🦆 says ⮞ display dependencies when entering shell
    echo "Running on ${system}"
    echo "Entering Rust ESP32 dev shell"    
    echo ""
    ${formatHeader "Build inputs:"}
    ${pkgs.lib.concatMapStringsSep "\n" (pkg: "echo - \$'\\e[0;31m'${pkg.name}\$'\\e[0m'") myBuildInputs}
  '';
  
  NIX_CONFIG = "system = ${system}";
}
