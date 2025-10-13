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
      { name = "image"; type = "path"; description = "File path to the image to send"; optional = false; }
    ];  
    code = ''
      ${cmdHelpers}     
      IMAGE_PATH="$image"
      
      start_time=$(date +%s)
      duration=60
      stopfile="/tmp/img2phoneRunning"
      localip=$(ip route get 1.1.1.1 | awk '{print $7}')
      port=9876
      image_url="http://$localip:$port/image"
      stopurl="http://$localip:$port/stop"
      
      echo "1" > "$stopfile"

      trap 'rm -f "$stopfile"; kill $server_pid 2>/dev/null' EXIT
      (
        while true; do
          ncat -l $port --sh-exec "
            read -r line
            if echo \"\$line\" | grep -q 'GET /image'; then
              echo -ne 'HTTP/1.1 200 OK\r\n'
              echo -ne 'Content-Type: image/jpeg\r\n'
              echo -ne 'Connection: close\r\n'
              echo -ne '\r\n'
              cat '$IMAGE_PATH'
            elif echo \"\$line\" | grep -q 'GET /stop'; then
              echo -ne 'HTTP/1.1 200 OK\r\n'
              echo -ne 'Content-Type: text/html\r\n'
              echo -ne 'Connection: close\r\n'
              echo -ne '\r\n'
              echo '<b>🖼️ Image viewed - stopping notifications</b>'
              rm -f '$stopfile'
            else
              echo -ne 'HTTP/1.1 404 Not Found\r\n'
              echo -ne 'Content-Type: text/html\r\n'
              echo -ne 'Connection: close\r\n'
              echo -ne '\r\n'
              echo '<b>Not found</b>'
            fi
          "
        done
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
          dt_info "Notification clicked, keeping image server running for 30 seconds..."
          sleep 15
          dt_info "Stopping image server..."
          break
        fi

        yo notify --title "📸 Image" --text "Tap to view image" --url "$image_url" --level "info"   
        sleep 10
      done
      kill $server_pid 2>/dev/null
    '';
  };}
