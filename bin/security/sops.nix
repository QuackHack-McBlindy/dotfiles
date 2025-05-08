# dotfiles/bin/security/sops.nix
{ self, config, pkgs, cmdHelpers, ... }:
{
    yo.scripts = {  
      sops = {
        description = "Encrypts a file with sops-nix";
        aliases = [ "e" ];
        parameters = [
          { name = "input"; description = "Input file to encrypt"; optional = false; } 
          { name = "agePub"; description = "The AGE public key used for encrypting the file"; optional = false; default = config.this.host.keys.publicKeys.age; } 
        ];
        code = ''
          ${cmdHelpers}
          INPUT_FILE="$input"
          OUTPUT_FILE="''${INPUT_FILE%.*}.enc.yaml"

          if [[ ! -f "$INPUT_FILE" ]]; then
            run_cmd echo -e "\033[1;31m❌ Error: Input file '$INPUT_FILE' not found!\033[0m"
            exit 1
          fi

          if [[ -z "$agePub" ]]; then
            run_cmd echo -e "\033[1;31m❌ Error: Age public key not configured!\033[0m"
            run_cmd echo -e "\033[1;33mℹ Hint: Set config.this.host.keys.publicKeys.age\033[0m"
            exit 1
          fi

          run_cmd echo -e "\033[1;34m🔐 Encrypting '$INPUT_FILE'...\033[0m"
          run_cmd ${pkgs.sops}/bin/sops --encrypt --age "$agePub" --output "$OUTPUT_FILE" "$INPUT_FILE"
          run_cmd mv "$OUTPUT_FILE" "$INPUT_FILE"
          run_cmd echo -e "\033[1;32m✅ Encrypted: $INPUT_FILE\033[0m"
        '';
      };
    };}  
