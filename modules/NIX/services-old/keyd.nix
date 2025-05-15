{
  services.keyd = {
    enable = true;
    keyboards.default.settings = {
      main.capslock = "enter";
      main.insert = "S-insert";
   
    };
  };
  systemd.services.keyd.restartIfChanged = false;
}

