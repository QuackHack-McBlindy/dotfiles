{
  services.keyd = {
    enable = true;
    keyboards.default.settings = {
 #     main.shift = "oneshot(hold(shift))";
    #  main.meta = "oneshot(hold(meta))";
   #   main.control = "oneshot(control)";
  #    main.leftalt = "oneshot(alt)";
  #    main.rightalt = "oneshot(altgr)";
      main.capslock = "enter";
      main.insert = "S-insert";
   
    };
  };
  systemd.services.keyd.restartIfChanged = false;
}

