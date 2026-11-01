#!/bin/bash
DBUS_DEST=org.gnome.Shell.Extensions.Magnixify
DBUS_PATH=/org/gnome/Shell/Extensions/Magnixify
DBUS_IFACE=org.gnome.Shell.Extensions.Magnixify


gdbus call --session --dest "$DBUS_DEST" --object-path "$DBUS_PATH" \
  --method "$DBUS_IFACE.Toggle"
