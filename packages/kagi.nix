# ddotfiles/packages/kagi.nix ⮞ https://github.com/QuackHack-McBlindy/dotfiles
{ 
  self,
  lib,
  stdenv,
  python3,
} : let 
  ducktrace-python = self.inputs.ducktrace-python.packages.${stdenv.system}.default;

  # 🦆 says ⮞ python dependencies
  pythonEnv = python3.withPackages (ps: [
    ps.beautifulsoup4
    ducktrace-python
  ]);
in # 🦆 says ⮞ code source
stdenv.mkDerivation {
  name = "kagi";
  src = ./kagi;

  # 🦆 says ⮞ build dependencies
  buildInputs = [
    pythonEnv
  ];
  
  # 🦆 says ⮞ crucial for runtime dependenciies
  propagatedBuildInputs = [ pythonEnv ];

  # 🦆 says ⮞ installer
  installPhase = ''
    mkdir -p $out/bin
    echo "#!${pythonEnv}/bin/python3" > $out/bin/kagi  # 🦆 says ⮞ Use wrapped python
    cat $src/kagi.py >> $out/bin/kagi
    chmod +x $out/bin/kagi
  '';

  # 🦆 says ⮞ metadata
  meta = {
    description = "Kagi Search using scraping from the web with session token";
    
  };}
