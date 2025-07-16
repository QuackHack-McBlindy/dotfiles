# dotfiles/bin/security/sops.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 duck say ⮞
  self,
  config,
  pkgs,
  cmdHelpers,
  ...
} : let
in { 
    yo.scripts = {  
      sops = {
        description = "Encrypts a file with sops-nix";
        category = "🔐 Security & Encryption";
        aliases = [ "e" ];
        parameters = [
          { name = "input"; description = "Input file to encrypt"; optional = false; } 
          { name = "operation"; description = "Operational mode, encrypt or edit"; default = "encrypt"; }           
          { name = "value"; description = "Value to append at the end of file (append mode only)"; optional = true; }
          { name = "agePub"; description = "The AGE public key used for encrypting the file"; optional = true; default = config.this.host.keys.publicKeys.age; } 
        ];
        code = ''
          ${cmdHelpers}
          INPUT_FILE="$input"
          OUTPUT_FILE="''${INPUT_FILE%.*}.enc.yaml"
          if [[ ! -f "$INPUT_FILE" ]]; then
            say_duck "fuck ❌ Error: Input file '$INPUT_FILE' not found!"
            exit 1
          fi
          if [[ -z "$agePub" ]]; then
            say_duck "fuck ❌ Error: Age public key not configured!"
            dt_info "Hint: Set config.this.host.keys.publicKeys.age"
            exit 1
          fi
          OPERATION="$operation"
          
          # 🦆 duck say ⮞ ENCRYPT
          if [[ "$OPERATION" == "encrypt" ]]; then     
            dt_debug "Encrypting '$INPUT_FILE'..."
            ${pkgs.sops}/bin/sops --encrypt --age "$agePub" --output "$OUTPUT_FILE" "$INPUT_FILE"
            mv "$OUTPUT_FILE" "$INPUT_FILE"
            dt_info "Encrypted: $INPUT_FILE"
          
          # 🦆 duck say ⮞ EDIT
          elif [[ "$OPERATION" == "edit" ]]; then
            if grep -q '^sops:' "$INPUT_FILE"; then
              dt_debug "Editing '$INPUT_FILE' with sops..."
              ${pkgs.sops}/bin/sops "$INPUT_FILE"
            else
              dt_debug "Decrypting -> Editing -> Re-encrypting '$INPUT_FILE'..."
              TEMP_FILE=$(mktemp)
              cleanup() { rm -f "$TEMP_FILE"; }
              trap cleanup EXIT
              ${pkgs.sops}/bin/sops --decrypt "$INPUT_FILE" > "$TEMP_FILE"
              ''${EDITOR:-vi} "$TEMP_FILE"
              ${pkgs.sops}/bin/sops --encrypt --age "$agePub" "$TEMP_FILE" > "$INPUT_FILE"
              dt_info "File updated and re-encrypted"
            fi  
          
          # 🦆 duck say ⮞ APPEND
          elif [[ "$OPERATION" == "append" ]]; then
            if [[ -z "$value" ]]; then
              say_duck "fuck ❌ Error: Value to append not provided!"
              exit 1
            fi
            dt_debug "Decrypting '$INPUT_FILE' for append..."
            TEMP_FILE=$(mktemp)
            cleanup() { rm -f "$TEMP_FILE"; }
            trap cleanup EXIT
            ${pkgs.sops}/bin/sops -d "$INPUT_FILE" > "$TEMP_FILE"
            ${pkgs.yq}/bin/yq -i -Y '
              (select(tag == "!!str") |= . + "\n'"$value"'" |
              (.. | select(tag == "!!str" and style == "literal") |= . + "\n'"$value"'" |
              (select(tag == "!!seq") |= . + ["'"$value"'"])
            ' "$TEMP_FILE"
  
            ${pkgs.sops}/bin/sops --encrypt --age "$agePub" --input-type yaml --output-type yaml "$TEMP_FILE" > "$INPUT_FILE"
            dt_info "Line appended, File re-encrypted!"
            exit 
          fi  
        '';
      };
    };}  
