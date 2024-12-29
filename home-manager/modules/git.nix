{ config, pkgs, ... }: 
{
  home.packages = with pkgs; [ pkgs.git ];
  
  programs.git = {
    enable = true;
    userName = "QuackHack-McBlindy";
    userEmail = "isthisrandomenough@protonmail.com";
    ignores = [
      # Compiled source files
      "*.class"
      "*.dll"
      "*.exe"
      "*.o"
      "*.so"
      "*.pyc"
      
      # Editing tools and IDEs
      ".sw[a-p]"
      "[._]*.sw[a-p]"
      "[._]*.s[a-v][a-z]"
      "*~"
      "~*"
      "\\#*\\#"
      ".#*"
      ".ipynb_checkpoints/"
      
      # Logs and databases
      "*.log"
      "*.sqlite"
      
      # OS generated files
      ".DS_Store"
      ".DS_Store?"
      "._*"
      ".Spotlight-V100"
      ".Trashes"
      "Icon?"
      "ehthumbs.db"
      "Thumbs.db"
      
      # Other common file types
      "*.bak"
      "*.tmp"
      "*.swp"
      ".idea/"
      ".vscode/"
      "node_modules/"
      "dist/"
      "build/"
      

      # SSH and Age keys
      "*.pem"
      "*.age"
      "*.key"
      "*.ssh/"
    ];

 #   extraConfig = [

 #   ];
  };
}
