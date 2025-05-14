{ config, lib, pkgs, ... }:

let
  cfg = config.services.googleSheets;
  script = pkgs.writeScriptBin "update-sheet" (builtins.readFile ./update_sheet.py);
in {

  options.services.googleSheets = {
    enable = lib.mkEnableOption "Google Sheets declarative updates";
    spreadsheetId = lib.mkOption { type = lib.types.str; description = "Google Spreadsheet ID"; };
    range = lib.mkOption { type = lib.types.str; description = "Sheet range (e.g., 'Sheet1!A1:B2')"; };
    data = lib.mkOption { type = lib.types.attrs; description = "Data to write (as an attribute set)"; };
    serviceAccountFile = lib.mkOption { type = lib.types.path; description = "Path to service account JSON file"; };
  };

  config = lib.mkIf (lib.elem "sheets" config.this.host.modules.services) {
    environment.systemPackages = with pkgs; [
      (python3.withPackages (ps: [ ps.google-api-python-client ps.oauth2client ]))
    ];

    # Securely expose the service account file and data
    environment.etc = {
      "google-sheet-credentials.json" = {
        source = cfg.serviceAccountFile;
        mode = "0400";  # Restrict permissions
      };
      "google-sheet-data.json" = {
        text = builtins.toJSON cfg.data;
      };
    };

    # Run the script on every rebuild
    system.activationScripts.updateGoogleSheet = {
      text = ''
        export SERVICE_ACCOUNT_FILE=/etc/google-sheet-credentials.json
        export SPREADSHEET_ID=${cfg.spreadsheetId}
        export RANGE=${cfg.range}
        ${script}/bin/update-sheet
      '';
      deps = [ "setupSecrets" ];  # Ensure credentials are available      
    };
    
   
    services.googleSheets = {
      enable = true;
      spreadsheetId = "your-spreadsheet-id";
      range = "Sheet1!A1:B2";
      data = {
        values = [
          ["Header1" "Header2"]
          ["Data1" "Data2"]
        ];
      };
      serviceAccountFile = config.age.secrets.google-sheet-credentials.path;
    };

#    age.secrets.google-sheet-credentials.file = ./secrets/google-sheet-credentials.json.age;
  };
  
}
