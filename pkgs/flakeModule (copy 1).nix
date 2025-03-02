{
  perSystem =
    { pkgs, ... }:
    {
      packages = {
        voice-server = pkgs.callPackage ./pkgs/voice-server { };
        voice-client = pkgs.callPackage ./pkgs/voice-client { };
      };
    };
}

