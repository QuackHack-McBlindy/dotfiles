{ config, pkgs, ... }: 
{
  home.sessionVariables = {
      BROWSER = "firefox";
      EDITOR = "nano";
      TERMINAL = "ghostty";
      #NIXOS_OZONE_WL = "1";
      QT_QPA_PLATFORMTHEME = "gtk3";
      QT_SCALE_FACTOR = "1";
      #MOZ_ENABLE_WAYLAND = "1";
      #SDL_VIDEODRIVER = "wayland";
      #_JAVA_AWT_WM_NONREPARENTING = "1";
      #QT_QPA_PLATFORM = "wayland-egl";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      #WLR_DRM_DEVICES = "/dev/dri/card1:/dev/dri/card0";
      #WLR_NO_HARDWARE_CURSORS = "1"; # if no cursor,uncomment this line  
      #GBM_BACKEND = "nvidia-drm";
      #CLUTTER_BACKEND = "wayland";
      # __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      # LIBVA_DRIVER_NAME = "nvidia";
      #WLR_RENDERER = "vulkan";
      #__NV_PRIME_RENDER_OFFLOAD="1"; 
      #XDG_CURRENT_DESKTOP = "gnome";
      #XDG_SESSION_DESKTOP = "gnome";
      #XDG_SESSION_TYPE = "wayland";
      #GTK_USE_PORTAL = "1";
      #NIXOS_XDG_OPEN_UsSE_PORTAL = "1";
      
      XDG_CACHE_HOME = "\${HOME}/.cache";
      XDG_CONFIG_HOME = "\${HOME}/.config";
      XDG_BIN_HOME = "\${HOME}/dotfiles/home/bin";
      XDG_DATA_HOME = "\${HOME}/.local/share";
  };   
  home.sessionPath = [
      "\${HOME}/dotfiles/home/bin"
  ];
}
