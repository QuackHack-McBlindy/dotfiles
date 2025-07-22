{
  lib,
  fetchFromGitHub,
  stdenv,
  Cocoa ? null,
  CoreAudio ? null,
  CoreFoundation ? null,
  MediaPlayer ? null,
  SDL2,
  cmake,
  libGL,
  libX11,
  libXrandr,
  libvdpau,
  mpv,
  nix-update-script,
  ninja,
  pkg-config,
  python3,
  qt5,
  jellyfin-web,
  # Options as overrides
  withDbus ? stdenv.hostPlatform.isLinux,
  ...
}: let
  inherit (lib) concatStringsSep optionals optionalString;

  pname = "jellyfin-media-player";
  version = "1.12.0";
in
  stdenv.mkDerivation {
    inherit pname version;

    src = fetchFromGitHub {
      owner = "jellyfin";
      repo = "jellyfin-media-player";
      rev = "v${version}";
      hash = "sha256-IXinyenadnW+a+anQ9e61h+N8vG2r77JPboHm5dN4Iw=";
    };

    patches = [
      # fix the location of the jellyfin-web path
      ./fix-web-path.patch
      # disable update notifications since the end user can't simply download the release artifacts to update
      ./disable-update-notifications.patch
    ];

    buildInputs =
      [
        SDL2
        libGL
        libX11
        libXrandr
        libvdpau
        mpv
        qt5.qtbase
        qt5.qtwebchannel
        qt5.qtwebengine
        qt5.qtx11extras
      ]
      ++ optionals stdenv.hostPlatform.isLinux [
        qt5.qtwayland
      ]
      ++ optionals stdenv.hostPlatform.isDarwin [
        Cocoa
        CoreAudio
        CoreFoundation
        MediaPlayer
      ];

    nativeBuildInputs = [
      cmake
      ninja
      pkg-config
      python3
      qt5.wrapQtAppsHook
    ];

    cmakeFlags =
      [
        "-DQTROOT=${qt5.qtbase}"
        "-GNinja"
      ]
      ++ optionals (!withDbus) [
        "-DLINUX_X11POWER=ON"
      ];

    preConfigure = ''
      # link the jellyfin-web files to be copied by cmake (see fix-web-path.patch)
      ln -s ${jellyfin-web}/share/jellyfin-web .
    '';

    postInstall = optionalString stdenv.hostPlatform.isDarwin ''
      mkdir -p $out/bin $out/Applications
      mv "$out/Jellyfin Media Player.app" $out/Applications

      # move web-client resources
      mv $out/Resources/* "$out/Applications/Jellyfin Media Player.app/Contents/Resources/"
      rmdir $out/Resources

      ln -s "$out/Applications/Jellyfin Media Player.app/Contents/MacOS/Jellyfin Media Player" $out/bin/jellyfinmediaplayer
    '';

    passthru.updateScript = concatStringsSep " " (nix-update-script {
      extraArgs = ["--flake" pname];
    });

    meta = with lib; {
      homepage = "https://github.com/jellyfin/jellyfin-media-player";
      description = "Jellyfin Desktop Client based on Plex Media Player";
      license = with licenses; [gpl2Only mit];
      platforms = ["aarch64-linux" "x86_64-linux" "x86_64-darwin"];
      mainProgram = "jellyfinmediaplayer";
    };
  }
