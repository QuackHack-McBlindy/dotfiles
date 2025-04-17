#########
{ config, pkgs, ... }: 
{
  home.packages = with pkgs; [ pkgs.gtk3 ];
  
  gtk = {
    enable = true;
    font.name = "TeX Gyre Adventor 10";
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
    };
    
    gtk3 = {
      bookmarks = [
        "file:///home/pungkula/dotfiles dotfiles"
        "file:///home/pungkula/.config .config"
        "file:///etc/nixos nixos"
        "smb://192.168.1.181/config/ HA"
        "smb://192.168.1.28/pool/ Media"
        "smb://192.168.1.159/files/ PiNAS"
      ];
      extraConfig = {
        Settings = ''
          gtk-application-prefer-dark-theme=1
          gtk-cursor-theme-name=Bibata-Modern-Classic
        '';
      };
      extraCss = ''
 
        /* Custom CSS for GTK3 Dark and Teal Theme */
        
        /* General Window Styling */
        window {
          background-color: #121212;
          color: #FFFFFF;
          font-family: "Arial", sans-serif;
          font-size: 16px;
          font-weight: bold;
          transition: all 0.3s ease;
        }
        
        /* Content Area */
        .view {
          background-color: #121212;
          color: #FFFFFF;
        }
        
        /* Button Styles */
        button {
          background-color: #006F72;
          color: #FFFFFF;
          border-radius: 5px;
          padding: 10px 15px;
          border: 1px solid #004D4A;
          font-weight: bold;
          font-size: 16px;
          transition: background-color 0.3s ease, color 0.3s ease;
        }
        
        /* Button Hover Effects */
        button:hover {
          background-color: #004D4A;
          color: #000000;
        }
        
        button:active {
          background-color: #003D3A;
        }
        
        button:focus {
          outline: none;
          box-shadow: 0 0 5px 2px rgba(0, 111, 114, 0.8);
        }
        
        /* Entry Fields (Text Boxes) */
        entry, textview, textarea {
          background-color: #2E2E2E;
          color: #FFFFFF;
          border: 1px solid #006F72;
          font-size: 16px;
          font-weight: bold;
          transition: border-color 0.3s ease, box-shadow 0.3s ease;
        }
        
        /* Entry Focus Effect */
        entry:focus, textview:focus, textarea:focus {
          border-color: #004D4A;
          box-shadow: 0 0 5px 2px rgba(0, 111, 114, 0.8);
        }
        
        /* Label and Other Text Elements */
        label {
          font-size: 16px;
          font-family: "Arial", sans-serif;
          color: #FFFFFF;
          font-weight: bold;
        }
        
        /* Scrollbar Styling */
        scrollbar {
          background-color: #2e2e2e;
          border-radius: 5px;
        }
        
        scrollbar slider {
          background-color: #006F72;
          border-radius: 5px;
        }
        
        scrollbar slider:hover {
          background-color: #004D4A;
        }
        
        /* TreeView and ListView (Hover and Selected Item Effects) */
        treeview, listview {
          background-color: #121212;
          color: #FFFFFF;
        }
        
        treeview:hover, listview:hover {
          background-color: #004D4A;
          cursor: pointer;
        }
        
        treeview:selected, listview:selected {
          background-color: #006F72;
          color: #000000;
        }
        
        /* Tooltips */
        tooltip {
          background-color: #006F72;
          color: #FFFFFF;
          border-radius: 5px;
          box-shadow: 0 2px 5px rgba(0, 0, 0, 0.3);
        }
        
        /* Statusbar Styling */
        statusbar {
          background-color: #1a1a1a;
          color: #FFFFFF;
          padding: 5px;
          font-size: 14px;
        }
        
        /* Dialog Boxes */
        dialog {
          background-color: #121212;
          color: #FFFFFF;
          border-radius: 10px;
          box-shadow: 0 4px 15px rgba(0, 0, 0, 0.6);
        }
        
        dialog label, dialog p {
          color: #FFFFFF;
        }
        
        /* Menu Bar and Items */
        menubar {
          background-color: #121212;
          color: #FFFFFF;
        }
        
        menubar menuitem {
          color: #FFFFFF;
          font-size: 16px;
          font-weight: bold;
          transition: background-color 0.3s ease;
        }
        
        /* Menu Item Hover and Active States */
        menubar menuitem:hover {
          background-color: #004D4A;
        }
        
        menubar menuitem:active {
          background-color: #006F72;
        }
        
        menu {
          background-color: #121212;
          color: #FFFFFF;
        }
        
        menuitem {
          background-color: #121212;
          color: #FFFFFF;
        }
        
        menuitem:hover {
          background-color: #004D4A;
        }
        
        menuitem:active, menuitem:focus {
          background-color: #006F72;
          color: #000000;
        }
        
        /* Header Bars */
        headerbar {
          background-color: #121212;
          color: #FFFFFF;
          padding: 5px;
          font-size: 18px;
          font-weight: bold;
          border-bottom: 2px solid #004D4A;
        }
        
        headerbar button {
          background-color: transparent;
          color: #FFFFFF;
          border: none;
          font-size: 18px;
        }
        
        headerbar button:hover {
          background-color: #006F72;
          color: #FFFFFF;
        }
        
        /* Smooth Transition Effects for Interactive Elements */
        button, entry, textview, menuitem {
          transition: background-color 0.3s ease, color 0.3s ease;
        }

        /* Window Title Bar */
        titlebar {
          background-color: #121212;  /* Keep the dark background */
          color: #FFFFFF;  /* White text for good contrast */
          font-size: 18px;
          font-weight: bold;
          padding: 10px;
          border-bottom: 3px solid #008080; /* Teal accent at the bottom */
        }

        
        /* Focused Window Border */
        window:focus {
          border: 2px solid #006F72;
          box-shadow: 0 0 10px 4px rgba(0, 111, 114, 0.8);
        }
        
        /* Notebook Tabs */
        notebook tab {
       /*   background-color: #121212; */
        /*  color: #FFFFFF; */
          background-color: #006F72;
          color: #000000;
          padding: 8px;
          border-radius: 5px;
        }
        
        
        notebook tab:focus {
          background-color: #006F72;
          color: #000000;
        }
        
        /* Custom Frames */
        frame {
          background-color: #121212;
          color: #FFFFFF;
          border-radius: 10px;
          border: 1px solid #006F72;
          padding: 10px;
        }
        
        frame header {
          background-color: #006F72;
          color: #FFFFFF;
          font-weight: bold;
        }
        
        /* Context Menu and Right-click Styling */
        .context-menu {
          background-color: #121212;
          color: #FFFFFF;
          border-radius: 5px;
          box-shadow: 0 2px 5px rgba(0, 0, 0, 0.3);
        }
        
        .context-menu menuitem {
          color: #FFFFFF;
          background-color: #121212;
          font-size: 16px;
          font-weight: bold;
          padding: 8px;
          border-radius: 5px;
        }
        
        .context-menu menuitem:hover {
          background-color: #004D4A;
        }
        
        .context-menu menuitem:active, .context-menu menuitem:focus {
          background-color: #121212;
          color: #000000;
        }
        
        /* Ensure properties dialog has dark background and visible text */
        dialog .vbox, dialog .hbox {
          background-color: #121212;
        }
        
        dialog .label, dialog .textview {
          color: #FFFFFF;
        }
        
        dialog .button {
          background-color: #006F72;
          color: #FFFFFF;
          border-radius: 5px;
        }
        
        dialog .button:hover {
          background-color: #004D4A;
        }
        
    
      '';
    };
    
    
    # GTK 4
    gtk4 = {
      extraConfig = {
        Settings = ''
          gtk-application-prefer-dark-theme=1
          gtk-cursor-theme-name=Bibata-Modern-Classic
        '';
      };  
    };
  };
}
