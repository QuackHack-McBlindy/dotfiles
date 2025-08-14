# dotfiles/bin/misc/qr.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ 
  config,
  lib,
  pkgs,
  cmdHelpers,
  ...
} : let

in {
  yo.scripts.qr = {
    description = "Create fun randomized QR codes from input.";
    category = "🧩 Miscellaneous";
    parameters = [
      { name = "input"; description = "Data to encode into the QR code"; optional = false; }
      { name = "icon"; description = "Fun icon for the QR code"; default = "https://raw.githubusercontent.com/QuackHack-McBlindy/dotfiles/refs/heads/main/modules/themes/icons/duck2.png"; }        
      { name = "output"; description = "Filename for the output PNG file"; default = "./qr.png"; }
    ];
    code = ''
      ${cmdHelpers}

      if [[ -f "$input" ]]; then
        ENCODED_DATA=$(<"$input")
      else
        ENCODED_DATA="$input"
      fi
          
      ICON="$icon"
      FINAL="$output"
      FG_COLOR=$(printf "#%06X\n" $((RANDOM * 256 * 256 * 256 / 32768)))
      BG_COLOR=$(printf "#%06X\n" $((RANDOM * 256 * 256 * 256 / 32768)))
          
      tmpdir=$(mktemp -d -t qrgen.XXXXXX)
      trap 'rm -rf "$tmpdir"' EXIT
          
      ${pkgs.qrencode}/bin/qrencode -l H -s 10 -o "$tmpdir/qrcode.png" "$ENCODED_DATA"
                   
      ${pkgs.imagemagick}/bin/magick "$tmpdir/qrcode.png" -fill "$FG_COLOR" -opaque black -fill "$BG_COLOR" -opaque white "$tmpdir/qrcode_colored.png"
      ${pkgs.imagemagick}/bin/magick "$tmpdir/qrcode_colored.png" \( +clone -background black -shadow 50x10+0+0 \) +swap -background none -layers merge +repage "$tmpdir/qrcode_shadow.png"
      ${pkgs.imagemagick}/bin/magick $ICON -resize 25% -background none "$tmpdir/resized_duck.png"
      ${pkgs.imagemagick}/bin/magick "$tmpdir/qrcode_shadow.png" "$tmpdir/resized_duck.png" -gravity center -composite $FINAL
          
      echo "QR? Quack. 🦆"
      echo "Done! Quack. 🦆 Open:"
      echo "xdg-open $FINAL"
    '';      
      
  };}
  
