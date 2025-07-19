# dotfiles/overlays/noisereduce.nix  ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ lib, ... }: self: super:
let
  inherit (super) python3;
in {
  python3 = python3.override {
    packageOverrides = pySelf: pySuper: {
      
      # NOISEREDUCE
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
      
      # PYTICKERSYMBOLS
      pytickersymbols = pySuper.buildPythonPackage rec {
        pname = "pytickersymbols";
        version = "1.15.0";
        src = pySuper.fetchPypi {
          inherit pname version;
          sha256 = "jDTJDr+ykeSk90afTnDj+/T1FfD3b9IOpBkLQ+uteMs=";
        };
        format = "pyproject";
        nativeBuildInputs = with pySuper; [ setuptools wheel poetry-core ];
        propagatedBuildInputs = with pySuper; [ ];        
        meta = {
          description = "Fundamental stock data and yahoo/google ticker symbols for several indices. ";
          homepage = "https://github.com/portfolioplus/pytickersymbols";
        };
        doCheck = false;
      };

      # ONNXRUNTIME
#      onnxruntime = pySuper.buildPythonPackage rec {
#        pname = "onnxruntime";
#        version = "1.22.1";  # or latest available on PyPI
#        src = pySuper.fetchPypi {
#          inherit pname version;
#          sha256 = "";
#        };
#        format = "pyproject";
#        nativeBuildInputs = with pySuper; [ poetry-core setuptools wheel ];
#        propagatedBuildInputs = with pySuper; [ ];
#        doCheck = false;
#      };
    
      # TFLITE_RUNTIME
##      tflite-runtime = pySuper.buildPythonPackage rec {
#        pname = "tflite-runtime";
#        version = "2.11.0";  # or latest available on PyPI
#        src = pySuper.fetchPypi {
#          inherit pname version;
#          sha256 = "0c7khn27kcv4qdrw0sz0nvx1frd9kfsn7p41rsq3sww3k8zmrhfm";
#        };
##        format = "pyproject";
#        nativeBuildInputs = with pySuper; [ poetry-core setuptools wheel ];
#        propagatedBuildInputs = with pySuper; [ ];
#        doCheck = false;
#      };
      
      # OPEN WAKE WORD     
#      openwakeword = pySuper.buildPythonPackage rec {
#        pname = "openwakeword";
#        version = "0.6.0";
#        src = pySuper.fetchPypi {
#          inherit pname version;
#          sha256 = "NoWNkPEYPjB0hVl6kSpOPDOEsU6pkj+D/q/658FWVWU=";
#        };
#        format = "pyproject";
#        nativeBuildInputs = with pySuper; [ poetry-core setuptools wheel ];
#        propagatedBuildInputs = with pySelf; [
#          tqdm
#          scipy
#          scikit-learn
#          requests
#        ];

#        doCheck = false;
#      };
    };
  };
}

