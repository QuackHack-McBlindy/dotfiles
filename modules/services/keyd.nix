{
  services.keyd = {
    enable = true;
    keyboards.default.settings = {
      main.shift = "oneshot(hold(shift))";
    #  main.meta = "oneshot(hold(meta))";
      main.control = "oneshot(control)";
      main.leftalt = "oneshot(alt)";
      main.rightalt = "oneshot(altgr)";
      main.capslock = "overload(control, enter)";
      main.insert = "S-insert";
     
    };
  };
  # seems to break my keyboard after an upgrade
  systemd.services.keyd.restartIfChanged = false;
}

