# dotfiles/bin/security/proxy.nix
{ self, config, pkgs, ... }:
{
  yo.scripts.proxy = {
    description = "Turn proxy routing on/off for anonymous mode";
    category = "🌐 Networking";
    aliases = [ "prox" ];
    parameters = [
      { name = "mode"; description = "on or off"; optional = false; }
    ];
    code = ''
      set -euo pipefail

      enable_proxy() {
        echo "🔐 Enabling proxy..."
        sudo iptables -t nat -N PROXY 2>/dev/null || true
        sudo iptables -t nat -F PROXY
        sudo iptables -t nat -A PROXY -d 127.0.0.0/8 -j RETURN
        sudo iptables -t nat -A PROXY -p tcp -j REDIRECT --to-ports 9050
        sudo iptables -t nat -A OUTPUT -p tcp -j PROXY
        sudo iptables -A OUTPUT -p udp -j DROP
        echo "✅ Proxy enabled. All TCP routed via 127.0.0.1:9050"
      }

      disable_proxy() {
        echo "🧹 Disabling proxy..."
        sudo iptables -t nat -D OUTPUT -p tcp -j PROXY 2>/dev/null || true
        sudo iptables -t nat -F PROXY 2>/dev/null || true
        sudo iptables -t nat -X PROXY 2>/dev/null || true
        sudo iptables -D OUTPUT -p udp -j DROP 2>/dev/null || true
        echo "✅ Proxy disabled. Direct traffic restored."
      }

      case "$mode" in
        on)
          enable_proxy
          ;;
        off)
          disable_proxy
          ;;
        *)
          echo "Usage: yo proxy on|off"
          exit 1
          ;;
      esac
    '';
  };
  
  
  yo.bitch = { 
    intents = {
      proxy = {
        data = [{
          sentences = [
            # Basic commands
            "proxy {mode}"
            "turn proxy {mode}"
            "set proxy {mode}"
            "enable {mode} proxy"
          
            # Natural language variations
            "i want to turn {mode} the proxy"
            "can you switch {mode} proxy mode"
            "please set proxy to {mode}"
            "change proxy status to {mode}"
          
            # Shortcuts
            "go anonymous"  # Will map to "on"
            "stop hiding"    # Will map to "off"
          ];
          lists = {
            mode.values = [
              # Direct matches
              { "in" = "on"; out = "on"; }
              { "in" = "off"; out = "off"; }
            
              # Synonyms for "on"
              { "in" = "enable"; out = "on"; }
              { "in" = "start"; out = "on"; }
              { "in" = "activate"; out = "on"; }
              { "in" = "anonymous"; out = "on"; }
              { "in" = "hide"; out = "on"; }
            
              # Synonyms for "off"
              { "in" = "disable"; out = "off"; }
              { "in" = "stop"; out = "off"; }
              { "in" = "deactivate"; out = "off"; }
              { "in" = "visible"; out = "off"; }
              { "in" = "normal"; out = "off"; }
            ];
          };
        }];
      };
    };
  };}
