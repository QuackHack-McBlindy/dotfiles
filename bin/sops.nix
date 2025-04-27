# bin/sops.nix
{ pkgs, cmdHelpers, ... }:
{
    yo.scripts = {  
      sops = {
        description = "Encrypts a file with sops-nix";
        aliases = [ "" ];
        parameters = [
          { name = "input"; description = "Input file to encrypt"; optional = false; } 
          { name = "agePub"; description = "The AGE public key used for encrypting the file"; optional = false; default = config.this.host.keys.publicKeys.age; } 
        ];
        code = ''
          ${cmdHelpers}
          if [[ $# -eq 0 ]]; then
            run_cmd echo -e "\033[1;31m❌ Usage: yo sops <input-file.yaml>\033[0m"
            exit 1
          fi
          INPUT_FILE="$input"
          OUTPUT_TMP="''${INPUT_FILE%.*}.enc.yaml"
          if [[ ! -f "$INPUT_FILE" ]]; then
            echo -e "\033[1;31m❌ Error: Input file '$INPUT_FILE' not found!\033[0m"
            exit 1
          fi
          if [[ -z "$agePub" ]]; then
             run_cmd echo -e "\033[1;31m❌ Error: Age public key not set in config.this.host.keys.publicKeys.age\033[0m"
             run_cmd echo -e "\033[1;31m❌ $EDITOR /${config.this.user.me.dotfilesDir}\033[0m"
            exit 1
          fi
          run_cmd echo -e "\033[1;34m🔐 Encrypting '$INPUT_FILE' with sops-nix using Age key...\033[0m"
          run_cmd sops --encrypt --age "$agePub" --output "$OUTPUT_FILE" "$INPUT_FILE"
          run_cmd echo -e "\033[1;32m✅ Encrypted: $INPUT_FILE → $OUTPUT_FILE\033[0m"
        '';
      };
    };}  
