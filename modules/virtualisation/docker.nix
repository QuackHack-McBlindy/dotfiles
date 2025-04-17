{ 
  config,
  lib,
  ...
} : {
    config = lib.mkIf (lib.elem "docker" config.this.host.modules.virtualisation) {
        virtualisation = {
            docker = {
                enable = true;
                enableOnBoot = true;
                autoPrune = {
                    enable = true;
                    dates = "weekly";
                };
                rootless = {
                    enable = false;
                    setSocketVariable = false;
                };
                daemon = {
                    settings = {
                        data-root = "/docker-root";
                        userland-proxy = false;
                    };
                };
            };
        };

    };}
