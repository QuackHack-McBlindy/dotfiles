# dotfiles/overlays/beytufyksiyo.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ lib, ... }: self: super:
let
  inherit (super) python3;
in {
  python3 = python3.override {
    packageOverrides = pySelf: pySuper: {
      beautifulsoup4 = pySuper.buildPythonPackage rec {
        pname = "beautifulsoup4";
        version = "4.12.3";

        src = pySuper.fetchPypi {
          inherit pname version;
          sha256 = "6a25c41657edb24cf44a934c4e2a34012dc9bda59c9d4fce10805a05877aa7bc";
        };

        propagatedBuildInputs = with pySuper; [ ];

        meta = {
          description = "Screen-scraping library";
          homepage = "https://www.crummy.com/software/BeautifulSoup/";
          license = lib.licenses.mit;
        };

        doCheck = false;
      };
    };
  };
}
