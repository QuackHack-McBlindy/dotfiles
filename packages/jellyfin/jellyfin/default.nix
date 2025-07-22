{
  lib,
  buildDotnetModule,
  dotnetCorePackages,
  fetchFromGitHub,
  fontconfig,
  freetype,
  jellyfin-ffmpeg,
  sqlite,
  ...
}: let
  pname = "jellyfin";
  version = "10.10.7";
in
  buildDotnetModule rec {
    inherit pname version;

    src = fetchFromGitHub {
      owner = "jellyfin";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-GWpzX8DvCafHb5V9it0ZPTXKm+NbLS7Oepe/CcMiFuI=";
    };

    propagatedBuildInputs = [
      sqlite
    ];

    projectFile = "Jellyfin.Server/Jellyfin.Server.csproj";
    executables = ["jellyfin"];
    nugetDeps = ./nuget-deps.json;
    runtimeDeps = [
      fontconfig
      freetype
      jellyfin-ffmpeg
    ];
    dotnet-sdk = dotnetCorePackages.sdk_8_0;
    dotnet-runtime = dotnetCorePackages.aspnetcore_8_0;
    dotnetBuildFlags = ["--no-self-contained"];

    passthru.updateScript = ./update.sh;

    meta = {
      description = "The Free Software Media System";
      homepage = "https://jellyfin.org/";
      # https://github.com/jellyfin/jellyfin/issues/610#issuecomment-537625510
      license = lib.licenses.gpl2Plus;
      mainProgram = "jellyfin";
      platforms = dotnet-runtime.meta.platforms;
    };
  }
