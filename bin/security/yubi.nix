# dotfiles/bin/security/yknix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 say ⮞ YubiKey encrypted secrets
  self,
  config,
  pkgs,
  cmdHelpers,
  ...
} : let
in { 
    yo.scripts = {
      yubi = {
        description = "Encrypts and decrypts files using a Yubikey and AGE";
        category = "🔐 Security & Encryption";
        aliases = [ "yk" ];
        parameters = [
          { 
            name = "operation";
            description = "Operation to perform";
            optional = false;
            type = "string";
            values = [ "encrypt" "decrypt" ];
          }
          { 
            name = "input";
            description = "Input file to process";
            optional = false;
            type = "path";
          }
        ];
        code = ''
          ${cmdHelpers}

          temp_file="$(mktemp)"

          case "$operation" in
            encrypt)

              echo -e "\033[1;34m🔒 Encrypting $input in-place\033[0m"
              mv "$input" "$temp_file"
        
              if rage -r "age1yubikey1q0ek47e26sg9eej2xlvxj308fgw8h8ajgx6ucagjzlm9tzgxtckdw35eg0m" \
                   -o "$input" "$temp_file"; then
                echo -e "\033[1;32m✅ Successfully encrypted file\033[0m"
                rm -f "$temp_file"
              else
                echo -e "\033[1;31m❌ Encryption failed - restoring original file\033[0m"
                mv "$temp_file" "$input"
                exit 1
              fi
              ;;

            decrypt)
              identity_tmp="/tmp/yubikey-identity.txt"
              decrypted_tmp="$(mktemp)"
            
              # 🦆 say ⮞ get identity from Yubikey
              age-plugin-yubikey --identity --slot 1 > "$identity_tmp" 2>/dev/null
            
              if rage -d -i "$identity_tmp" -o "$decrypted_tmp" "$input"; then
                # 🦆 say ⮞ output the decrypted content
                cat "$decrypted_tmp"
            
                # 🦆 say ⮞ re-encrypt it back in place
                if rage -r "age1yubikey1q0ek47e26sg9eej2xlvxj308fgw8h8ajgx6ucagjzlm9tzgxtckdw35eg0m" \
                     -o "$input" "$decrypted_tmp"; then
                  :
                else
                  echo -e "\033[1;31m❌ Re-encryption failed - preserving original encrypted file\033[0m"
                  exit 1
                fi
              else
                echo -e "\033[1;31m❌ Decryption failed - original file preserved\033[0m"
                rm -f "$decrypted_tmp"
                exit 1
              fi
            
              # 🦆 say ⮞ clean up
              rm -f "$identity_tmp" "$decrypted_tmp"
              ;;
          esac
        '';
      };
      
    };}
