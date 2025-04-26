{
  my.userFiles = {
    vesktop = {
      source = "./.config/vesktop";
      target = ".config/vesktop";
      recursive = true;
    };

    torrc = {
      source = "./.torrc";
      target = ".torrc";
    };

    wgetrc = {
      source = "./.wgetrc";
      target = ".wgetrc";
    };

    hushlogin = {
      source = "./.hushlogin";
      target = ".hushlogin";
    };

    pythonrc = {
      source = "./.pythonrc";
      target = ".pythonrc";
    };

    xmrigjson = {
      source = "./.xmrig.json";
      target = ".xmrig.json";
    };

    face = {
      source = "./.face2";
      target = ".face";
    };

    direnvrc = {
      source = "./.direnvrc";
      target = ".direnvrc";
    };

    Templates = {
      source = "./Templates";
      target = "Templates";
      recursive = true;
    };

    thunar = {
      source = "/.config/Thunar";
      target = ".config/Thunar";
      recursive = true;
    };
    
    hej = {
      source = "133713371337";
      target = "133713371337";

    };    
    

  };



  # Example of additional entries (if uncommented, place them *inside* my.userFiles)
  # projects-envrc = {
  #   source = ./../../home/projects/fetch/.envrc;
  #   target = "projects/fetch/.envrc";
  #   enable = true;
  # };

  # projects-flake = {
  #   source = ./../../home/projects/fetch/flake.nix;
  #   target = "projects/fetch/flake.nix";
  #   enable = true;
  # };
}

