# dotfiles/bin/system/zoom.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
# » ★ QuackHack-McBLindy.com ★ «
{ # 🦆 duck say ⮞ nice to be able to see a little sometimes..... yay
  self,
  config,
  pkgs,
  cmdHelpers,
  ...
} : let
  sysHosts = builtins.attrNames self.nixosConfigurations;
  vmHosts = builtins.filter (host:
    self.nixosConfigurations.${host}.self.config.system.build ? vm
  ) sysHosts;
in {
  yo.scripts = {
   zoom = {
     description = "Magnify the display enough even a blind duck can see a little..";
     category = "🖥️ System Management";
     parameters = [
       { name = "action"; type = "string"; description = "Zoom in/out or toggle (on/off)"; optional = false;
         default = "in"; values = [ "in" "out" "toggle" ]; }
     ];
     code = ''
       ${cmdHelpers}
       DBUS_DEST=org.gnome.Shell.Extensions.Magnixify
       DBUS_PATH=/org/gnome/Shell/Extensions/Magnixify
       DBUS_IFACE=org.gnome.Shell.Extensions.Magnixify

       ACTION="$action"

       if [ "$ACTION" = "in" ]; then
         gdbus call --session --dest "$DBUS_DEST" --object-path "$DBUS_PATH" \
           --method "$DBUS_IFACE.ZoomIn"
       fi

       if [ "$ACTION" = "toggle" ]; then
         gdbus call --session --dest "$DBUS_DEST" --object-path "$DBUS_PATH" \
           --method "$DBUS_IFACE.Toggle"
       fi

       if [ "$ACTION" = "out" ]; then
         gdbus call --session --dest "$DBUS_DEST" --object-path "$DBUS_PATH" \
           --method "$DBUS_IFACE.ZoomOut"
       fi
     '';
     voice = {
       enabled = true;
       priority = 5;
       fuzzy.enable = false;
       sentences = [
         "(zoom|zooma) {action}"
         "förstoring {action}"
         "{action} (förstoring|förstoringen|zoom|zoomen)"
       ];
       lists = {
         action.values = [
           { "in" = "in|mer|mera"; out = "in"; }
           { "in" = "ut|mindre"; out = "out"; }
           { "in" = "på|av|on|off|start|starta|stäng|toggle"; out = "toggle"; }
         ];
       };
     };
    };

  };}
