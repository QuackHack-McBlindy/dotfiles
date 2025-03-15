{ 
    config, 
    lib, 
    pkgs, 
    ... 
} : let 
    TextToBeWritten = ''
      here goes text
    '';

    TextFile = pkgs.writeTextFile {
        name = "TextFile";
        text = TextToBeWritten;
    };
in { 
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ SERVICE ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°  
 
    system.activationScripts.sshConfig = {
        text = ''
           # mkdir -p /home/
            cp ${TextFile} /home/pungkula/TextFile.txt
        '';

    };}
