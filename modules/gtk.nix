{ config, pkgs, ... }:

{
  # Install required packages system-wide
  environment.systemPackages = with pkgs; [
    gtk3
    gtk4
    elementary-xfce-icon-theme
    bibata-cursors
  ];

  # Set environment variables for cursor theme
  environment.variables = {
    XCURSOR_THEME = "Bibata-Modern-Classic";
  };

  # User-specific configuration
  users.users.pungkula = {
    # Create GTK config files directly in user's home
    home.file = {
      # GTK 3 Configuration
      ".config/gtk-3.0/settings.ini".text = ''
        [Settings]
        gtk-application-prefer-dark-theme=1
        gtk-cursor-theme-name=Bibata-Modern-Classic
        gtk-icon-theme-name=elementary-xfce-icon-theme
      '';
      
      ".config/gtk-3.0/gtk.css".text = ''
        window {
          background-color: #000000;
          color: #00FF00;
          font-family: "Monospace", sans-serif;
          font-size: 14px;
          font-weight: normal;
          transition: all 0.2s ease;
        }
      '';

      ".config/gtk-3.0/bookmarks".text = ''
        file:///home/pungkula/dotfiles ❄️ - 𝒹𝑜𝓉𝒻𝒾𝓁ℯ𝓈
        file:///home/pungkula/.config 🛠️ - .𝒸ℴ𝓃𝒻𝒾𝑔
        file:///home/pungkula/dotfiles    ❄️  ·  𝘿𝙤𝙩𝙛𝙞𝙡𝙚𝙨
        file:///home/pungkula/.config     🛠️  ·  𝘾𝙤𝙣𝙛𝙞𝙜
        file:///home/pungkula/projects    💡  ·  𝙋𝙧𝙤𝙟𝙚𝙘𝙩𝙨
        file:///Pool                      💾  ·  𝙋𝙤𝙤𝙡
        file:///Files                     🛡️  ·  𝙁𝙞𝙡𝙚 𝙑𝙖𝙪𝙡𝙩
      '';

      # GTK 4 Configuration
      ".config/gtk-4.0/settings.ini".text = ''
        [Settings]
        gtk-application-prefer-dark-theme=1
        gtk-cursor-theme-name=Bibata-Modern-Classic
        gtk-icon-theme-name=elementary-xfce-icon-theme
      '';

      ".config/gtk-4.0/gtk.css".text = ''
        window {
          background-color: #000000;
          color: #00FF00;
          font-family: "Monospace", sans-serif;
          font-size: 14px;
          font-weight: normal;
          transition: all 0.2s ease;
        }
      '';
    };
  };
}
