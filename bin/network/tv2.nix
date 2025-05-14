{ self, config, pkgs, cmdHelpers, ... }:
{  
  yo.scripts.tv2 = {
    description = "Android TV Controller";
    category = "🌐 Networking";
    aliases = [ "arris" "a" ];
#    helpFooter = ''
#    '';
    parameters = [
    
      { name = "search"; description = "Media to search and play"; optional = false; }
      { name = "device"; description = "Device IP to cast to"; optional = false; default = "192.168.1.152"; }
      { name = "mediaType"; description = "Media Type to search and play"; optional = true; default = "tv"; }
      
    ];
    code = ''
      ${cmdHelpers}
      target_device="$device"
      media_type="'$mediaType"
      media_search="$search"
      run_cmd "tv $target_device $media_search $media_type"
    '';
  };
}
