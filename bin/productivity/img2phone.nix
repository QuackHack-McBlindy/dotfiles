# dotfiles/bin/productivity/img2phone.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ send images to iPhone
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ...
} : let
in {  
  # 🦆 says ⮞ port for stop url
  networking.firewall.allowedTCPPorts = [ 9876 ];
  
  yo.scripts.img2phone = {
    description = "Send images to an iPhone";
    category = "⚡ Productivity";
    autoStart = false;
    logLevel = "INFO";
    parameters = [
      { name = "image"; description = "URL to the image to send"; optional = false; }
    ];  
    code = ''
      ${cmdHelpers}     
      IMAGE_URL="$image"
      start_time=$(date +%s)
      duration=60
      stopfile="/tmp/img2phoneRunning"
      localip=$(ip route get 1.1.1.1 | awk '{print $7}')
      port=9876
      stopurl="http://$localip:$port"
      echo "1" > "$stopfile"

      trap 'rm -f "$stopfile"; kill $server_pid 2>/dev/null' EXIT

      (
        ncat -l $port --sh-exec "echo -ne 'HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n<b>🖼️ Image viewed</b>'; rm -f '$stopfile'"
      ) &

      server_pid=$!

      while true; do
        current_time=$(date +%s)
        elapsed=$((current_time - start_time))
        if [ "$elapsed" -ge "$duration" ]; then
          dt_debug "Stopped after 1 minute"
          break
        fi
        
        if [ ! -f "$stopfile" ]; then
          sleep 30
          dt_info "Image viewed, stopping..."
          break
        fi

        yo notify --text "📷 Image" --url "$IMAGE_URL"

        sleep 10
      done

      kill $server_pid
    '';
  };}
