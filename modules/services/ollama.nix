# EMPTY NIX OS MODULE
# import into flake.
{ config, pkgs, ... }:

{

  services.ollama = {
    enable = true;
    package = pkgs.ollama;
    home = "/home/ollama";
    models = "/home/ollama/models";
    sandbox = true;
    writablePaths = [ "/home/ollama" ];
    host = "0.0.0.0";
    port = 11434;
    acceleration = "cuda";
    environmentVariables = {
      OLLAMA_LLM_LIBRARY = "cuda";
    };
    loadModels = [ "model1" "model2" ];
    openFirewall = true;
  };
}
