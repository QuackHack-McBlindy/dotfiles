# dotfiles/modules/sops-yubikey.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ ensures sops required keys are decrypted before builds happen
  self,
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.services.sops-yubikey;
  
  # 🦆 says ⮞ get the encrypted key path based on hostname
  encryptedKeyPath = 
    if builtins.isPath cfg.encryptedKeyDir
    then cfg.encryptedKeyDir + "/${config.networking.hostName}/age.key"
    else builtins.toPath "${cfg.encryptedKeyDir}/${config.networking.hostName}/age.key";
    
in {
  options.services.sops-yubikey = {
    enable = lib.mkEnableOption "YubiKey SOPS decryption";
    
    encryptedKeyDir = lib.mkOption {
      type = lib.types.path;
      default = ./../secrets/hosts;
      description = "Directory containing encrypted age keys per host";
    };
    
    ensureDecrypted = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Ensure age key is decrypted before SOPS tries to use it";
    };
  };

  config = lib.mkIf (cfg.enable) {
    # 🦆 says ⮞ dependencies
    environment.systemPackages = with pkgs; [
      age-plugin-yubikey
      yubioath-flutter
      yubikey-agent
      yubikey-personalization    
      yubikey-manager
      pam_u2f
      libu2f-host
      libykclient
      yubico-pam
      yubico-piv-tool
      piv-agent
      pcsclite
      pcscliteWithPolkit
      pcsc-tools
      acsccid
    ];

    services.pcscd.enable = true;

    # 🦆 says ⮞ activation script that runs before sops tries to decrypt secrets
    system.activationScripts.yubikeyDecrypt = {
      text = ''
        echo "Checking for YubiKey-decrypted SOPS age key..."
        
        SOPS_KEYFILE="${config.sops.age.keyFile}"
        ENCRYPTED_KEY="${encryptedKeyPath}"
        
        # 🦆 says ⮞ check if the decrypted key already exists and is valid
        if [ -f "$SOPS_KEYFILE" ]; then
          echo "SOPS age key already exists at $SOPS_KEYFILE"
          # 🦆 says ⮞ quick test to ensure it's a valid age key
          if grep -q "AGE-SECRET-KEY-1" "$SOPS_KEYFILE"; then
            echo "Key appears valid, skipping decryption"
            exit 0
          else
            echo "⚠️  Key exists but doesn't look valid, will re-decrypt"
          fi
        fi
        
        echo ""
        echo "❌ SOPS age key not found or invalid at: $SOPS_KEYFILE"
        echo "🔑 Encrypted key location: $ENCRYPTED_KEY"
        echo ""
        echo "Please:"
        echo "1. Insert your YubiKey"
        echo "2. Enter PIN when prompted"
        echo "3. Touch the YubiKey when it flashes"
        echo ""
        echo "Decrypting now..."
        echo ""
        
        # 🦆 says ⮞ create directory for key if it doesn't exist
        mkdir -p "$(dirname "$SOPS_KEYFILE")"
        
        # 🦆 says ⮞ temporary identity file
        IDENTITY_TMP="$(mktemp)"
        trap 'rm -f "$IDENTITY_TMP"' EXIT
        
        # 🦆 says ⮞ get identity from YubiKey
        if ! age-plugin-yubikey --identity --slot 1 > "$IDENTITY_TMP" 2>/dev/null; then
          echo ""
          echo "❌ ERROR: Could not get YubiKey identity."
          echo "   Make sure:"
          echo "   - YubiKey is inserted"
          echo "   - YubiKey has PIV slot 1 configured for age"
          echo "   - You have permissions to access the YubiKey"
          echo ""
          exit 1
        fi
        
        # 🦆 says ⮞ decrypt the age key
        if ! rage -d -i "$IDENTITY_TMP" -o "$SOPS_KEYFILE" "$ENCRYPTED_KEY"; then
          echo ""
          echo "❌ ERROR: Decryption failed!"
          echo "   Possible reasons:"
          echo "   - Wrong PIN entered"
          echo "   - Didn't touch YubiKey in time"
          echo "   - Encrypted file doesn't match this YubiKey"
          exit 1
        fi
        
        # 🦆 says ⮞ set secure permissions
        chmod 0400 "$SOPS_KEYFILE"
        chown root:root "$SOPS_KEYFILE"
        
        echo ""
        echo "Successfully decrypted SOPS age key!"
        echo "   Key saved to: $SOPS_KEYFILE"
      '';
      
      # 🦆 says ⮞ run this BEFORE sops activation scripts
      deps = [ "users" "groups" "etc" ];
    };
    
    # 🦆 says ⮞ make sure sops activation runs AFTER our decryption
    system.activationScripts.sops.deps = [ "yubikeyDecrypt" ];
    system.activationScripts.sops.text = " ";

  };}
