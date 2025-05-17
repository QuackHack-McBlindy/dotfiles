{ self, config, pkgs, cmdHelpers, ... }:
{  
  yo.scripts.arris = {
    description = "Android TV Controller";
    category = "🌐 Networking";
    aliases = [ "bedroom" "a" ];
#    helpFooter = ''
#    '';
    parameters = [
      { name = "search"; description = "Media to search and play"; optional = false; }
      { name = "mediaType"; description = "Media Type to search and play"; default = "tv"; }     
    ];
    code = ''
      ${cmdHelpers}
      media_type="$mediaType"
      media_search="$search"
      run_cmd "tv arris $media_search $media_type"
    '';
  };
}
