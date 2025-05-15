{ 
    config, 
    lib,
    self,
    inputs,
    pkgs, 
    ... 
}:

let
  serviceUser = "voice";
in {
    # Create a system user for the service
    users.groups.voice = { };
    users.users.voice = {
        group = "voice";
        home = "/var/lib/voice";
        createHome = true;
        isSystemUser = true;
    };

    systemd.services.voice-server = {
        description = "Voice Server API";
        after = [ "network.target" ];  # Start after networking is ready
        wantedBy = [ "multi-user.target" ]; # Ensures it starts on boot

        serviceConfig = {
            User = "pungkula";
            Group = "pungkula";
            ExecStart = "${inputs.voice-server.packages.${pkgs.system}.voice-server}/bin/voice-server";
            Restart = "always";
            WorkingDirectory = "/home/pungkula/dotfiles";
            StandardOutput = "journal";
            StandardError = "journal";
        };
    };
}

