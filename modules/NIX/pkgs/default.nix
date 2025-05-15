{ 
  config,
  ...
} : {
#  imports = [ ./gtk.nix ];
  this.home = {
  # RC
    torrc = { source = ./.torrc; };
    wgetrc = { source = ./.wgetrc; };
    hushlogin = { source = ./.hushlogin; };    
    pythonrc = { source = ./.pythonrc; }; 
    xmrigjson = { source = ./.xmrig.json; };
    face = { source = ./.face2; };
    direnvrc = { source = ./.direnvrc; user = "pungkula"; };
    starship = { source = ./.config/starship.toml; user = "pungkula"; };
    Templates = { source = ./Templates; };
    vesktop = { source = ./.config/vesktop; };
    thunar = { source = /.config/Thunar; };
    "piper-module" = { source = ./.config/speech-dispatcher/modules/piper-tts-generic.conf; };
    "custom-module" = { source = ./.config/speech-dispatcher/modules/custom-tts.conf; };
    "speech-dispatcher-desktop" = { source = ./.config/speech-dispatcher/desktop/speechd.desktop; };
    "orca-user-settings" = { source = ./.local/share/orca/user-settings.conf; };   
    ".config/Proton/VPN/app-config.json" = { source = ./.config/Proton/VPN/app-config.json; };
    "proton-app-config" = { source = ./.config/Proton/VPN/app-config.json; };
    ".proton-settings" = { source = ./.config/Proton/VPN/settings.json; };
    ".config/lsd" = { source = ./.config/lsd; recursive = true; };       
    "speechd" = { source = ./.config/speech-dispatcher/speechd.conf; };

  };
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



