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
      "*.db"
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
      "id_ed25519"
    ];

    extraConfig = {
      # Core settings
      core.editor = "nano";  # Set your preferred editor
      core.autocrlf = "input";  # For cross-platform (Windows/Linux) compatibility
      core.ignorecase = true;  # Ignore case in file names
      # Whitespace management
      core.whitespace = "trailing-space,space-before-tab";  # Manage trailing spaces

      # Diff and merge tools
     # diff.tool = "vimdiff";  # Set your diff tool (example: vimdiff, meld)
     # merge.tool = "vimdiff";  # Set your merge tool
     # mergetool.vimdiff.cmd = "vim -d $LOCAL $REMOTE";  # Configure vimdiff for merging

      init.defaultBranch = "main";  # Set default branch to "main"
      
      # Help prevent large repositories with submodules
      submodule.recurse = true;  # Recursively update submodules

      # Performance optimizations for large repositories
      gc.auto = 256;  # Run git gc automatically after this many objects
      pack.threads = 1;  # Use single thread for git pack operations (adjust as needed)
      
      # Handling remotes
      url."git@github.com:".insteadOf = "https://github.com/";  # Use SSH instead of HTTPS for GitHub

      # Rebase instead of merge for pull requests
      pull.rebase = true;  # Use rebase instead of merge when pulling
    };
  };
}
