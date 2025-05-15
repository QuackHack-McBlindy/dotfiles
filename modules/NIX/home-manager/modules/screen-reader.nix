 { config, pkgs, ... }: 

{
  home.packages = with pkgs; [
    pkgs.orca
    pkgs.speechd
    pkgs.piper-tts
  ];

  # Speech Dispatcher Configuration
  home.file."speechd" = {
    source = ./../../home/.config/speech-dispatcher/speechd.conf;
    target = "/.config/speech-dispatcher/speechd.conf";
    enable = true;
  };


  # Piper sv_SE TTS Module
  home.file."piper-module" = {
    source = ./../../home/.config/speech-dispatcher/modules/piper-tts-generic.conf;
    target = "/.config/speech-dispatcher/modules/piper-tts-generic.conf";
    enable = true;
  };


  home.file."custom-module" = {
    source = ./../../home/.config/speech-dispatcher/modules/custom-tts.conf;
    target = "/.config/speech-dispatcher/modules/custom-tts.conf";
    enable = true;
  };
    
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

  # Speech Dispatcher Desktop Client
  home.file."speech-dispatcher-desktop" = {
    source = ./../../home/.config/speech-dispatcher/desktop/speechd.desktop;
    target = "/.config/speech-dispatcher/desktop/speechd.desktop";
    enable = true;
  };

  # Orca Settings
  home.file."orca-user-settings" = {
    source = ./../../home/.local/share/orca/user-settings.conf;
    target = "/.local/share/orca/user-settings.conf";
    enable = true;
  };

}  
