{ config, pkgs, ... }:

{
  # Keybindings for GNOME
  services.xserver.windowManager.gnome.extraConfig = ''
    [org/gnome/settings-daemon/plugins/media-keys custom-keybindings/custom0]
    name='Open Terminal'
    binding='<Primary>§'
    command='gnome-terminal'

    [org/gnome/settings-daemon/plugins/media-keys custom-keybindings/custom1]
    name='Switch to Workspace 1'
    binding='<Primary>1'
    command='wmctrl -s 0'

    [org/gnome/settings-daemon/plugins/media-keys custom-keybindings/custom2]
    name='Switch to Workspace 2'
    binding='<Primary>2'
    command='wmctrl -s 1'

    [org/gnome/settings-daemon/plugins/media-keys custom-keybindings/custom3]
    name='Switch to Workspace 3'
    binding='<Primary>3'
    command='wmctrl -s 2'
  '';
}
