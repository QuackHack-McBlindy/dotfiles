{ config, ... }: {
  programs.atuin = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      auto_sync = true;
      sync_frequency = "5m";
      sync_address = "https://api.atuin.sh";
      search_mode = "prefix";
  #    dialect = "uk";
  #    key_path = config.sops.secrets.atuin_key.path;
    };
  };

 # sops.secrets.atuin_key = {
 #   sopsFile = ../secrets.yaml;
 # };
}
