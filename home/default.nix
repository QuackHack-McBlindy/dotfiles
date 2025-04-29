{ 
  config,
  ...
} : {
#  imports = [ ./gtk.nix ];
#  this.home = {
  # RC
#    torrc = { source = ./.torrc; };
#    wgetrc = { source = ./.wgetrc; };
#    hushlogin = { source = ./.hushlogin; };    
#    pythonrc = { source = ./.pythonrc; }; 
#    xmrigjson = { source = ./.xmrig.json; };
#    face = { source = ./.face2; };
#    direnvrc = { source = ./.direnvrc; user = "pungkula"; };
#    starship = { source = ./.config/starship.toml; user = "pungkula"; };
#    Templates = { source = ./Templates; };
#    vesktop = { source = ./.config/vesktop; };
#    thunar = { source = /.config/Thunar; };

  # Proton VPN App Config
#    "proton-app-config" = {
#      source = ./.config/Proton/VPN/app-config.json;
#      target = ".config/Proton/VPN/app-config.json";
#    };
     # Proton VPN Settings
#    ".proton-settings" = {
#      source = ./.config/Proton/VPN/settings.json;
#      target = ".config/Proton/VPN/settings.json";
#    };
        
    # Directory example
#    ".config/lsd" = {
#      source = ./.config/lsd;
#      recursive = true; # For directories
#    };

    # Custom target example
#    ".config/Proton/VPN/app-config.json".source = ./.config/Proton/VPN/app-config.json;
 

    # Speech Dispatcher Configuration
#    "speechd" = {
#      source = ./.config/speech-dispatcher/speechd.conf;
#      target = ".config/speech-dispatcher/speechd.conf";
#      enable = true;
#    };


    # Piper sv_SE TTS Module
#    "piper-module" = {
#      source = ./.config/speech-dispatcher/modules/piper-tts-generic.conf;
#      target = ".config/speech-dispatcher/modules/piper-tts-generic.conf";
#      enable = true;
#    };


#    "custom-module" = {
#      source = ./.config/speech-dispatcher/modules/custom-tts.conf;
#      target = ".config/speech-dispatcher/modules/custom-tts.conf";
#      enable = true;
#    };
   
    # Speech Dispatcher Desktop Client
#    "speech-dispatcher-desktop" = {
#      source = ./.config/speech-dispatcher/desktop/speechd.desktop;
#      target = ".config/speech-dispatcher/desktop/speechd.desktop";
#      enable = true;
#    };

    # Orca Settings
#    "orca-user-settings" = {
#      source = ./.local/share/orca/user-settings.conf;
#      target = ".local/share/orca/user-settings.conf";
#      enable = true;
#    };   


#  };
}    
  
  
  # en_US Female Amy
#  home.file.piper = {
#    enable = true;
#    force = true;
#    target = "/.config/speech-dispatcher/modules/piper-tts-generic.conf";
#    text = ''
#      GenericExecuteSynth "export XDATA=\'$DATA\'; echo \"$XDATA\" | sed -z 's/\\n/ /g' | piper -q -m \"./../../home/.config/.piper/en_US-amy-medium.onnx\" -c \"./../../home/.config/.piper/en_US-amy-medium-onnx.json\" -s 21 -f - | aplay"
#
#      AddVoice "en-US" "Amy"   "en_US-amy-medium"
#    '';
#  }; 



