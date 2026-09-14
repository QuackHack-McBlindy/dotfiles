# dotfiles/bin/home/findPhone.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ lacate phone
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

  yo.scripts.findPhone = {
    description = "Helper for locating Phone";
    category = "🛖 Home Automation";
    autoStart = false;
    logLevel = "INFO";
    code = ''
      ${cmdHelpers}
      start_time=$(date +%s)
      duration=70
      stopfile="/tmp/findPhoneRunning"
      localip=$(ip route get 1.1.1.1 | awk '{print $7}')
      port=9876
      stopurl="http://$localip:$port"
      echo "1" > "$stopfile"

      trap 'rm -f "$stopfile"; kill $server_pid 2>/dev/null' EXIT

      # 🦆 says ⮞ start http server to check if notification has been clicked
      (
        ncat -l $port --sh-exec "echo -ne 'HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n<b>📱 Phone found!</b>'; rm -f '$stopfile'"
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
          dt_info "Phone found, stopping..."
          break
        fi

        yo notify --title "HITTA MIG!" --text "HÄR ÄR JAG!" --level "critical" --url "$stopurl" --sound "minuet"

        sleep 7
      done
      kill $server_pid
    '';
    voice = {
      sentences = [
        "hitta [min] telefon"
        "var är min telefon"
        "ring min telefon"
      ];
    };
  };}
