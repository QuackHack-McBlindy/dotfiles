{ 
  self,
  lib,
  stdenv,
  alsa-utils,  # For arecord
  curl,        # For HTTP requests
  keyd         # For keyboard monitoring
}:

stdenv.mkDerivation {
  name = "hold";
  src = ./hold;  # This directory should contain your hold.sh script

  buildInputs = [
    alsa-utils
    curl
    keyd
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp $src/hold.sh $out/bin/hold
    chmod +x $out/bin/hold

    # Optional: Create a wrapper that ensures PATH is set correctly
    cat > $out/bin/hold-wrapper <<EOF
    #!${stdenv.shell}
    export PATH="${lib.makeBinPath [ alsa-utils curl keyd ]}:\$PATH"
    exec $out/bin/hold "\$@"
    EOF
    chmod +x $out/bin/hold-wrapper
  '';

  meta = {
    description = "Hold-to-record audio with keyd integration";
    license = lib.licenses.mit;
  };
}
