{ stdenv }:

stdenv.mkDerivation {
  pname = "hello";
  version = "0.1.0";
  src = null;
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/bin
    echo 'echo Hello, world!' > $out/bin/hello
    chmod +x $out/bin/hello
  '';
}

