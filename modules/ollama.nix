{ config, pkgs, lib, ... }:

let
  # Function to create a dynamic Nix shell environment
  generateShellEnv = name: deps: ''
    { pkgs ? import <nixpkgs> {} }:

    pkgs.mkShell {
      name = "${name}";
      buildInputs = [ ${lib.concatMapStringsSep " " (dep: "pkgs.${dep}") deps} ];
    }
  '';

  # Function to create a new tool dynamically
  generateTool = name: deps: script: ''
    mkdir -p /var/ollama-tools/${name}
    echo '${generateShellEnv name deps}' > /var/ollama-tools/${name}/default.nix
    echo '#!/usr/bin/env bash' > /var/ollama-tools/${name}/${name}.sh
    echo '${script}' >> /var/ollama-tools/${name}/${name}.sh
    chmod +x /var/ollama-tools/${name}/${name}.sh
  '';

  # Ollama tool generation script (to be called from prompts)
  ollamaScript = pkgs.writeShellScriptBin "ollama-tool-runner" ''
    # Read user prompt from input
    read -p "What do you need me to do? " user_prompt

    # Call Ollama to generate a response
    response=$(ollama run system "Given the following user request: '$user_prompt', determine if a new tool is required.
    If so, output a JSON object like: {\"name\": \"tool-name\", \"dependencies\": [\"python3\", \"curl\"], \"script\": \"echo Hello\"}
    If a tool already exists, output {\"use_existing\": \"tool-name\"}")

    echo "Ollama response: $response"

    # Parse JSON response
    tool_name=$(echo $response | jq -r '.name // empty')
    use_existing=$(echo $response | jq -r '.use_existing // empty')

    if [[ -n "$use_existing" ]]; then
      echo "Using existing tool: $use_existing"
      /var/ollama-tools/$use_existing/$use_existing.sh
      exit 0
    fi

    if [[ -n "$tool_name" ]]; then
      dependencies=$(echo $response | jq -c '.dependencies')
      script_content=$(echo $response | jq -r '.script')

      echo "Generating new tool: $tool_name with dependencies: $dependencies"
      ${generateTool "tool_name" "dependencies" "script_content"}

      # Execute the new tool
      /var/ollama-tools/$tool_name/$tool_name.sh
    else
      echo "Ollama did not generate a valid tool."
    fi
  '';

in
{
  options.ollama.enable = lib.mkEnableOption "Ollama with autonomous tool creation";

  config = lib.mkIf config.ollama.enable {
    # Install required packages
    environment.systemPackages = with pkgs; [
      ollama
      jq   # For parsing JSON responses
      git
      nixFlakes
      "${ollamaScript}"
    ];

    # Enable Nix Flakes for tool management
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    # Directory for generated tools
    systemd.tmpfiles.rules = [
      "d /var/ollama-tools 0755 root root -"
    ];
  };
}

