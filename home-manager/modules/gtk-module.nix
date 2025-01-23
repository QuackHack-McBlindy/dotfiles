{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.gtk;
  cfg2 = config.gtk.gtk2;
  cfg3 = config.gtk.gtk3;
  cfg4 = config.gtk.gtk4;

  toGtk3Ini = generators.toINI {
    mkKeyValue = key: value:
      let value' = if isBool value then boolToString value else toString value;
      in "${escape [ "=" ] key}=${value'}";
  };

  bookmarksText = concatMapStrings (bm: 
    let
      name = bm.name;
      path = bm.path;
      icon = bm.icon or "default";  # Fallback to "default" icon if none is provided.
    in
      "${escape [ "=" ] name}=${path},icon=${icon}"
  ) cfg.bookmarks;

  # Debug output for bookmarks
  debugBookmarks = builtins.toString cfg3.bookmarks;
  debugBookmarksText = builtins.toString bookmarksText;

in {
  meta.maintainers = [ maintainers.rycee ];

  options = {
    gtk3 = {
      bookmarks = mkOption {
        type = types.listOf (types.attrsOf types.str);
        default = [
          { name = "dotfiles"; path = "file:///home/pungkula/dotfiles"; icon = "document"; }
          { name = "config"; path = "file:///home/pungkula/.config"; icon = "picture"; }
        ];
        example = [
          { name = "Documents"; path = "file:///home/jane/Documents"; icon = "document"; }
          { name = "Pictures"; path = "file:///home/jane/Pictures"; icon = "picture"; }
        ];
        description = "List of bookmarks with metadata like name, path, and icon.";
      };
    };
  };

  config = mkIf cfg.enable (let
    gtkIni = optionalAttrs (cfg.font != null) {
      gtk-font-name = let
        fontSize =
          optionalString (cfg.font.size != null) " ${toString cfg.font.size}";
      in "${cfg.font.name}" + fontSize;
    };

    dconfIni = optionalAttrs (cfg.font != null) {
      font-name = let
        fontSize =
          optionalString (cfg.font.size != null) " ${toString cfg.font.size}";
      in "${cfg.font.name}" + fontSize;
    };

  in {
    # Debug output for bookmarks
    home.sessionVariables.debugBookmarks = debugBookmarks;
    home.sessionVariables.debugBookmarksText = debugBookmarksText;

    # Only generate the bookmarks file if there are bookmarks
    xdg.configFile."gtk-3.0/bookmarks" = mkIf (cfg3.bookmarks != null && cfg3.bookmarks != []) {
      text = bookmarksText;
    };
  });
}

