{ pkgs }:

pkgs.runCommand "git-wrapped" { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
  mkdir -p $out/bin
  makeWrapper ${pkgs.git}/bin/git $out/bin/git \
    --set GIT_TRACE 1 \
    --prefix PATH : ${pkgs.openssh}/bin
''

