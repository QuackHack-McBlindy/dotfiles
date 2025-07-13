# dotfiles/overlays/ddgs.nix
{ lib, ... }: self: super:
let
  inherit (super) python3;
in {
  python3 = python3.override {
    packageOverrides = pySelf: pySuper: {
      ddgs = pySuper.buildPythonPackage rec {
        pname = "ddgs";
        version = "9.1.0";

        src = pySuper.fetchPypi {
          inherit pname version;
          # SHA256 for ddgs‑9.1.0.tar.gz from PyPI
          sha256 = "dfca16a9818e68ce834d19795a5c1c09fbafb23f2cf1f6beb3ef5a4563e6f1ef";
        };

        propagatedBuildInputs = with pySuper; [
          requests
        ];

        meta = {
          description = "D.D.G.S. – DuckDuckGo metasearch library/CLI";
          homepage = "https://github.com/deedy5/ddgs";
          license = lib.licenses.mit;
        };

        doCheck = false;
      };
    };
  };
}

