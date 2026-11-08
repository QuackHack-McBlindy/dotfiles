# dotfiles/bin/home/loop.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
# » ★ QuackHack-McBLindy.com ★ «
{ # 🦆 duck say ⮞ loop a repeating MQTT action until a device leaves its defined state
  config,
  lib,
  swe,
  pkgs,
  ...
} : let
  base = config.house.zigbee.mosquitto.baseTopic;

  loopPresets = {
    "living-cealing" = {
      description = "Cycle Living Cealing until Takkrona 1 leaves the LC fingerprint";
      device      = "Takkrona 1";
      topic       = "${base}/effects/living/cealing";
      payload     = "{}";
      interval    = 30;
      max_minutes = 60;
      fingerprint = [
        { brightness = { min = 235; max = 245; };
          hue        = { min = 340; max = 15;  };
          sat        = { min = 85;  max = 100; }; }
        { brightness = { min = 178; max = 186; };
          hue        = { min = 195; max = 245; }; }
        { brightness = { min = 195; max = 205; };
          hue        = { min = 345; max = 15;  };
          sat        = { min = 85;  max = 100; }; }
      ];
    };
  };

  presetsJson = pkgs.writeText "yo-loop-presets.json" (builtins.toJSON loopPresets);

  body = pkgs.writeShellScript "yo-loop-body" ''
    set -u
    name="$1"

    L=$(jq -r --arg n "$name" '.[$n] // empty' ${presetsJson})
    [ -z "$L" ] && { echo "unknown loop: $name" >&2; exit 1; }

    topic=$(printf '%s' "$L" | jq -r '.topic')
    payload=$(printf '%s' "$L" | jq -r '.payload // "{}"')
    device=$(printf '%s' "$L" | jq -r '.device')
    interval=$(printf '%s' "$L" | jq -r '.interval // 30')
    max_min=$(printf '%s' "$L" | jq -r '.max_minutes // 60')
    fp=$(printf '%s' "$L" | jq -c '.fingerprint // []')

    SD="/tmp/yo"
    [ -n "''${XDG_RUNTIME_DIR:-}" ] && SD="$XDG_RUNTIME_DIR/yo"
    mkdir -p "$SD"

    SIG="$SD/loop-$name.jsonl"
    PIDF="$SD/loop-$name.pid"
    : > "$SIG"
    echo $$ > "$PIDF"

    zigduck-cli --subscribe --device "$device" >> "$SIG" 2>/dev/null &
    SUB=$!
    trap "kill $SUB 2>/dev/null; rm -f $SIG $PIDF" EXIT

    sleep 2

    is_fp() {
      local line="$1"
      [ -z "$line" ] && return 0
      local st br hu sa
      st=$(printf '%s' "$line" | jq -r '.state // "OFF"')
      [ "$st" = "ON" ] || return 1
      br=$(printf '%s' "$line" | jq -r '.brightness // 0')
      hu=$(printf '%s' "$line" | jq -r '.color.hue // 0')
      sa=$(printf '%s' "$line" | jq -r '.color.saturation // 0')
      printf '%s' "$fp" | jq -e \
        --argjson b "$br" --argjson h "$hu" --argjson s "$sa" '
        any(.[];
          (if .brightness then ($b >= .brightness.min and $b <= .brightness.max) else true end)
          and
          (if .hue then
             if .hue.min <= .hue.max then ($h >= .hue.min and $h <= .hue.max)
             else ($h >= .hue.min or $h <= .hue.max) end
           else true end)
          and
          (if .sat then ($s >= .sat.min and $s <= .sat.max) else true end)
        )' >/dev/null 2>&1
    }

    echo "[loop] started name=$name device=$device interval=''${interval}s max=''${max_min}m"
    echo "[loop] topic=$topic"
    echo "[loop] fingerprint=$fp"

    START=$(date +%s)
    while true; do
      ELAPSED=$(( ($(date +%s) - START) / 60 ))
      if [ "$ELAPSED" -ge "$max_min" ]; then
        echo "[loop] exit: max_minutes reached ($ELAPSED >= $max_min)"
        exit 0
      fi

      BEFORE=$(wc -l < "$SIG")
      echo "[loop] iter $ELAPSED min: publishing"
      zigduck-cli --publish --topic "$topic" --payload "$payload" 2>/dev/null
      sleep "$interval"
      sleep 2
      AFTER=$(wc -l < "$SIG")

      if [ "$AFTER" -gt "$BEFORE" ]; then
        LAST=$(tail -1 "$SIG")
        echo "[loop] iter $ELAPSED min: last=$LAST"
        if [ -n "$LAST" ] && ! is_fp "$LAST"; then
          echo "[loop] exit: state left fingerprint"
          exit 0
        fi
      else
        echo "[loop] iter $ELAPSED min: no new state"
      fi
    done
  '';

in {
  yo.scripts.loop = {
    description = "Handle a configured device loop — repeatedly fires an MQTT topic until the watched device leaves its fingerprint.";
    category    = "🛖 Home Automation";
    autoStart   = false;
    logLevel    = "WARNING";

    parameters = [
      { name = "action"; description = "start | stop | status"; optional = true; default = "status";
          values = [ "start" "stop" "status" ]; }
      { name = "name"; description = "loop preset name"; optional = true;
          default = builtins.head (builtins.attrNames loopPresets);
          values  = builtins.attrNames loopPresets; }
    ];

    code = ''
      SD="/tmp/yo"
      [ -n "''${XDG_RUNTIME_DIR:-}" ] && SD="$XDG_RUNTIME_DIR/yo"
      mkdir -p "$SD"
      PIDF="$SD/loop-''${name}.pid"
      LOG="$SD/loop-''${name}.log"

      running() {
        [ -f "$PIDF" ] || return 1
        local p; p=$(cat "$PIDF" 2>/dev/null)
        [ -n "$p" ] && kill -0 "$p" 2>/dev/null
      }

      case "''${action:-status}" in
        start)
          running && { echo "Redan igång (pid $(cat "$PIDF"))"; exit 0; }
          setsid ${body} "''${name}" </dev/null >>"$LOG" 2>&1 &
          sleep 0.5
          if [ -f "$PIDF" ]; then
            echo "Startad: ''${name} (pid $(cat "$PIDF"))"
            echo "Logg: $LOG"
          else
            echo "Start misslyckades — senaste logg:"
            tail -20 "$LOG" 2>/dev/null
            exit 1
          fi
          ;;
        stop)
          running || { echo "Inte igång"; rm -f "$PIDF"; exit 0; }
          PID=$(cat "$PIDF")
          kill -TERM "$PID" 2>/dev/null
          for _ in $(seq 1 10); do
            kill -0 "$PID" 2>/dev/null || break
            sleep 1
          done
          kill -0 "$PID" 2>/dev/null && kill -9 "$PID" 2>/dev/null
          rm -f "$PIDF"
          echo "Stoppad: ''${name}"
          ;;
        status)
          running && { echo "running (pid $(cat "$PIDF"))"; exit 0; }
          echo "stopped"; exit 1
          ;;
      esac
    '';

    voice = {
      priority        = 4;
      fuzzy.enable    = true;
      fuzzy.threshold = 0.5;
      sentences = [
        "[kör|dra] {action} levande {name} tills (nån|den) (ändra|ändrar|ändrat|ändras) (tillstånd|lampan|tak|taket|sig)"
        "[kör|dra] {action} levande {name} tillsvidare"
        "[kör|dra] {action} levande {name} tills vidare"
        "[kör|dra] {action} levande {name}"
        "är levande {name} igång"
        "[vad] [har] levande {name} [för] status"
      ];
      lists = {
        action.values = [
          { "in" = "starta|start|börja|kör|igång|loopa|loop"; out = "start";  }
          { "in" = "stoppa|stop|sluta|avbryt|döda";          out = "stop";   }
          { "in" = "status|kolla";                            out = "status"; }
        ];
        name.values = [
          { "in" = "taket|tak|cealing";
            out = "living-cealing"; }
        ];
      };
    };
  };
}
