# dotfiles/overlays/noisereduce.nix
{ lib, ... }: self: super:
let
  inherit (super) python3;
in {
  python3 = python3.override {
    packageOverrides = pySelf: pySuper: {
      noisereduce = pySuper.buildPythonPackage rec {
        pname = "noisereduce";
        version = "3.0.3";

        src = pySuper.fetchPypi {
          inherit pname version;
          sha256 = "ff64a28fb92e3c81f153cf29550e5c2db56b2523afa8f56f5e03c177cc5e918f";
        };

        propagatedBuildInputs = with pySuper; [ numpy scipy librosa tqdm ];

        meta = {
          description = "Noise reduction in python using spectral gating";
          homepage = "https://github.com/timsainb/noisereduce";
        };

        doCheck = false;
      };
    };
  };
}

