# dotfiles/devShells/rust.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ 4 da rust development
  pkgs,
  system,
  inputs,
  self
} : let # 🦆says⮞ list dependencies
  myBuildInputs = with pkgs; [
    git
    nixpkgs-fmt
    rustc
    clang
    cargo
    cargo-msrv
    clippy
    pkg-config        # or: pkgconf
    dbus              # provides dbus-1.pc
    pipewire          # provides libpipewire-0.3.pc and libspa-0.2.pc
    libclang          # for bindgen (libspa-sys / pipewire-sys)
    alsa-lib          # keep, since you were already using it
  ];

  formatRed = name: "echo - \$'\\e[0;31m'${name}\$'\\e[0m'";
  formatHeader = text: "echo \$'\\e[1m'${text}\$'\\e[0m'";
in {
  buildInputs = myBuildInputs;

  # 🦆 says ⮞ display dependencies when entering shell
  shellHook = ''
    export PKG_CONFIG_PATH="${pkgs.alsa-lib.dev}/lib/pkgconfig"
    export OPENSSL_INCLUDE_DIR=$(nix eval --raw nixpkgs#openssl.dev)/include
    export OPENSSL_LIB_DIR=$(nix eval --raw nixpkgs#openssl.out)/lib
    #export LIBCLANG_PATH="/nix/store/60y46s779qpjaqqal33yccwadcigscni-rocm-toolchain/lib/libclang.so.22.0"
    export LIBCLANG_PATH="${pkgs.libclang.lib}/lib"
    echo "Running on ${system}"
    echo ""
    ${formatHeader "Build inputs:"}
    ${pkgs.lib.concatMapStringsSep "\n" (pkg: "echo - \$'\\e[0;31m'${pkg.name}\$'\\e[0m'") myBuildInputs}
  '';


  CMAKE_POLICY_VERSION_MINIMUM = "3.5";
  NIX_CONFIG = "system = ${system}";
}
