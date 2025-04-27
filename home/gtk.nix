{ config, pkgs, ... }:

{
  # GTK packages installation
  environment.systemPackages = with pkgs; [
    gtk3
    gtk4
    bibata-cursors
    elementary-xfce-icon-theme
  ];

  # GTK configuration
  services.xserver = {
    enable = true;

    # Cursor and icon configuration
    desktopManager.runXdgAutostartIfNone = true;
    displayManager = {
      sessionCommands = ''
        export GTK_THEME="Adwaita-dark"
        export XCURSOR_THEME="Bibata-Modern-Classic"
        export XCURSOR_SIZE=24
      '';
    };
  };

  # Dconf settings for GTK
  services.dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      cursor-theme = "Bibata-Modern-Classic";
      icon-theme = "elementary-xfce-dark";
      gtk-theme = "Adwaita-dark";
    };
  };

  # GTK CSS configuration
  environment.etc = {
    "gtk-3.0/gtk.css" = {
      text = ''
        /* Your GTK3 CSS content here */
        window { background-color: #000000; color: #00FF00; }
        /* ... rest of your GTK3 CSS ... */
      '';
    };

    "gtk-4.0/gtk.css" = {
      text = ''
        /* Your GTK4 CSS content here */
        window { background-color: #000000; color: #00FF00; }
        /* ... rest of your GTK4 CSS ... */
      '';
    };
  };

  # Bookmarks and file manager integration
  xdg.configFile = {
    "gtk-3.0/bookmarks" = {
      text = ''
        file:///home/pungkula/dotfiles ❄️ - 𝒹𝑜𝓉𝒻𝒾𝓁ℯ𝓈
        file:///home/pungkula/.config 🛠️ - .𝒸ℴ𝓃𝒻𝒾𝑔
        file:///home/pungkula/projects 💡 - 𝑃𝓇𝑜𝒿𝑒𝒸𝓉𝓈
        file:///Pool 💾 - /ℙℴℴ𝓁
        file:///Files 🛡️ - ℙ𝒾ℕ𝒜𝒮
      '';
    };
  };

  # User directory symlinks
  systemd.services.home-pungkula-links = {
    serviceConfig = {
      Type = "oneshot";
      User = "punkgula";
      ExecStart = pkgs.writeScript "create-links" ''
        #!/bin/sh
        ln -sfn ${config.users.users.pungkula.home}/dotfiles ${config.users.users.pungkula.home}/.config/dotfiles
        # Add other links as needed
      '';
    };
    wantedBy = [ "multi-user.target" ];
  };

  # Dconf settings loading
  system.activationScripts.load-dconf = ''
    if [ -e /etc/dconf-settings.ini ]; then
      ${pkgs.dconf}/bin/dconf load / < /etc/dconf-settings.ini
    fi
  '';
}
