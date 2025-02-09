#{
#  systemd.user.services.tts-notifications = {
#    description = "Text to SPeech Nofifications Service";
#    enable = true;
#    after = [ "graphical-session.target" ];
#    wantedBy = [ "default.target" ];  # Ensures it starts after login

#    script = ''
#      bash notification-listener
#    '';

#    restartIfChanged = false;  # Avoids restarting on config changes
#    restartTriggers = [ ];  # Define dependencies if needed
#  };
#}


#{
#  systemd.services."tts-notifications" = {
#    enable = true;
#    description = "Text-to-speech notifications";
#    after = [ "graphical-session.target" ];
#    wantedBy = [ "default.target" ];
 #   serviceConfig = {
#      ExecStart = "/etc/profiles/per-user/pungkula/bin/bash /home/pungkula/dotfiles/home/bin/notification-listener";
#      User = "pungkula";
#      Restart = "always";
#      Type = "simple";
#      Environment = "DISPLAY=:0";
      
#    };
#  };
#}

{

  services.cron.enable = true;
  services.cron.systemCronJobs = [
    "@reboot root /etc/profiles/per-user/pungkula/bin/bash /home/pungkula/dotfiles/home/bin/notification-listener > /var/log/tts-notify.log 2>&1"
  ];

}
