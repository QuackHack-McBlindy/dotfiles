# dotfiles/bin/media/tv-guide.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ Fancy markdown & Text-To-Speech EPG in da terminal! 
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ... 
} : let # 🦆 says ⮞ yo    
in {
  yo.scripts.transcode = {
    description = "Transcode media files";
    aliases = [ "trans" ];
    category = "🎧 Media Management";
    autoStart = false;
    logLevel = "DEBUG";
#    helpFooter = '' # 🦆 says ⮞ TODO Show what is on da TVB usin' glow
#    '';
    parameters = [
      { name = "directory"; description = "Directory path to look for media that shall be transcoded"; default = "/Pool/TV/House"; }  

    ];
    code = ''
      ${cmdHelpers}
      SEARCH_DIR="$directory" 
      counter=1
      dt_info "Transcoding Process Started"
      find "$SEARCH_DIR" -type f -iname "*.mkv" | while read -r file; do
        codec=$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "$file")
        if [[ "$codec" == "hevc" || "$codec" == "h265" ]]; then
          output_file="''${file%.mkv}.mp4"
          if [[ ! -f "$output_file" ]]; then
            dt_info "Transcoding #$counter: $file to $output_file"
            ((counter++))
            ffmpeg -nostdin -i "$file" -c:v libx264 -preset slower -crf 22 \
                   -threads 1 \
                   -profile:v high -level 4.1 \
                   -c:a copy "$output_file"
          else
            dt_info "Skipping existing: $output_file"
          fi
        fi
      done
      dt_info "Transcoding Process Completed"
    '';   
  };}
