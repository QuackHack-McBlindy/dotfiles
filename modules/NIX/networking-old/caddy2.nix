{ 
  config,
  lib,
  ...
} : let
  cfg = config.my.host.modules;
  mkModuleEnable = list: lib.elem (baseNameOf (toString ./.)) list;
in {
    config = lib.mkIf (mkModuleEnable cfg.networking) {

    };}
