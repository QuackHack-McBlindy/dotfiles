{ 
  config,
  lib,
  pkgs,
  stdenv,
  python3,
  ...
} : let
  pythonEnv = python3.withPackages (ps: [
    ps.sounddevice
    ps.requests
    ps.python-dotenv
  ]);
  
  adbkey = ''
    "@ADBKEY@"
  '';

  adbkeyFile = 
    pkgs.runCommand "adbkeyFile"
      { preferLocalBuild = true; }
      ''
        cat > $out <<EOF
${adbkey}
EOF
      '';  
  
in

stdenv.mkDerivation {
  name = "tv";
  src = ./tv;

  buildInputs = [ pythonEnv pkgs.android-tools ];
  propagatedBuildInputs = [ pythonEnv ];

  installPhase = ''
    mkdir -p $out/bin
    echo "#!${pythonEnv}/bin/python3" > $out/bin/tv
    cat $src/tv.py >> $out/bin/tv
    chmod +x $out/bin/tv
  '';

  meta = {
    description = "ADB Controller";
    license = lib.licenses.mit;
    maintainers = [ "QuackHack-McBlindy" ];
  };
  
  systemd.services.android_config = {
    wantedBy = [ "multi-user.target" ];
    preStart = ''
      mkdir -p /home/${config.this.user.me.name}/.android
      sed -e "/@ADBKEY@/{
        r ${config.sops.secrets.adbkey.path}
        d
      }" ${adbkeyFile} > /home/${config.this.user.me.name}/.android/adbkey
      ${config.this.host.keys.publicKeys.adb} > /home/${config.this.user.me.name}/.android/adbkey.pub
    '';
    serviceConfig = {
      ExecStart = "${pkgs.bash}/bin/bash -c 'echo succes; sleep 200'";
      Restart = "on-failure";
      RestartSec = "2s";
      RuntimeDirectory = [ config.this.user.me.name ];
      User = config.this.user.me.name;
    };
  };
  
  sops.secrets = {
    adbkey = {
      sopsFile = ./../secrets/adbkey.yaml;
      owner = config.this.user.me.name;
      group = config.this.user.me.name;
      mode = "0440";
    };
  };
}
