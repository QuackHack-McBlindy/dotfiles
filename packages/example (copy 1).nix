{ stdenv, makeWrapper, git, openssh }:

stdenv.mkDerivation {
  pname = "git-wrapped";
  version = "0.1.0";

  src = null;

  phases = [ "installPhase" ]; # skip fetch/unpack/build/check

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    makeWrapper ${git}/bin/git $out/bin/git \
      --set GIT_TRACE 1 \
      --prefix PATH : ${openssh}/bin
  '';
}
