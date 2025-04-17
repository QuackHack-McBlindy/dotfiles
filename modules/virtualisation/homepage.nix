{ 
  config,
  lib,
  ...
} : {
    config = lib.mkIf (lib.elem "homepage" config.this.host.modules.virtualisation) {
        #
    };}
