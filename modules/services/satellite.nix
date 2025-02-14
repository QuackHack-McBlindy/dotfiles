# /etc/nixos/configuration.nix

{
  # Enable Wyoming Satellite service
  services.wyoming-satellite = {
    enable = true;

    # You can override specific settings if necessary:
    package = pkgs.wyoming-satellite;  # If you have a custom package
    user = "your-username";            # Set the user for running the service
    group = "your-group";              # Set the group for running the service
    uri = "tcp://your-server-uri";     # Custom URI for service binding
    area = "LivingRoom";               # Define the area for the satellite
    microphone = {
      command = "arecord -r 16000 -c 1 -f S16_LE -t raw";  # Example microphone command
      autoGain = 5;  # Set auto gain value
      noiseSuppression = 2;  # Set noise suppression level
    };
    sound = {
      command = "aplay -r 22050 -c 1 -f S16_LE -t raw";  # Example sound output command
    };
    vad.enable = true;  # Enable or disable voice activity detection
    extraArgs = [ "--custom-arg" ];  # Extra arguments to pass to wyoming-satellite
  };
}
