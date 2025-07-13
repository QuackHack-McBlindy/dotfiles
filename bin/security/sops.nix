# dotfiles/bin/security/sops.nix
{ self, config, pkgs, cmdHelpers, ... }:
{
    yo.scripts = {  
      sops = {
        description = "Encrypts a file with sops-nix";
        category = "🔐 Security & Encryption";
        aliases = [ "e" ];
        parameters = [
          { name = "input"; description = "Input file to encrypt"; optional = false; } 
          { name = "agePub"; description = "The AGE public key used for encrypting the file"; optional = true; default = config.this.host.keys.publicKeys.age; } 
          { name = "operation"; description = "Operational mode, encrypt or edit"; default = "encrypt"; } 
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
          OPERATION="$operation"
          if [[ "$OPERATION" == "encrypt" ]]; then     
            echo -e "\033[1;34m🔐 Encrypting '$INPUT_FILE'...\033[0m"
            ${pkgs.sops}/bin/sops --encrypt --age "$agePub" --output "$OUTPUT_FILE" "$INPUT_FILE"
            mv "$OUTPUT_FILE" "$INPUT_FILE"
            echo -e "\033[1;32m✅ Encrypted: $INPUT_FILE\033[0m"
          elif [[ "$OPERATION" == "edit" ]]; then
            if grep -q '^sops:' "$INPUT_FILE"; then
              echo -e "\033[1;34m✏️  Editing '$INPUT_FILE' with sops...\033[0m"
              ${pkgs.sops}/bin/sops "$INPUT_FILE"
            else
              echo -e "\033[1;34m🔓 Decrypting -> Editing -> Re-encrypting '$INPUT_FILE'...\033[0m"
              TEMP_FILE=$(mktemp)
              cleanup() { rm -f "$TEMP_FILE"; }
              trap cleanup EXIT
              ${pkgs.sops}/bin/sops --decrypt "$INPUT_FILE" > "$TEMP_FILE"
              ''${EDITOR:-vi} "$TEMP_FILE"
              ${pkgs.sops}/bin/sops --encrypt --age "$agePub" "$TEMP_FILE" > "$INPUT_FILE"
              echo -e "\033[1;32m✅ File updated and re-encrypted\033[0m"
            fi
          fi
        '';
      };
    };}  
