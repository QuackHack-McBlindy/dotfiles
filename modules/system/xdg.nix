# dotfiles/modules/system/xdg.nix
{ 
  config,
  pkgs,
  lib,
  ...
} : {
    config = lib.mkIf (lib.elem "gnome" config.this.host.modules.system) {
        xdg.terminal-exec.enable = true;
        xdg.portal = {
            enable = true;
            xdgOpenUsePortal = true;
            config = {
                common = {
                    default = [ "gtk" ];
                };
            };
        };
        
        xdg.mime.enable = true;
  
        # Added Associations 
        xdg.mime.addedAssociations = {
            "text/plain" = "org.gnome.TextEditor.desktop";
            "x-scheme-handler/http" = "firefox-esr.desktop";
            "x-scheme-handler/https" = "firefox-esr.desktop";
            "x-scheme-handler/chrome" = "firefox-esr.desktop";
            "text/html" = "firefox-esr.desktop";
            "application/x-extension-htm" = "firefox-esr.desktop";
            "application/x-extension-html" = "firefox-esr.desktop";
            "application/x-extension-shtml" = "firefox-esr.desktop";
            "application/xhtml+xml" = "firefox-esr.desktop";
            "application/x-extension-xhtml" = "firefox-esr.desktop";
            "application/x-extension-xht" = "firefox-esr.desktop";
            "application/x-shellscript" = "org.gnome.TextEditor.desktop";
            "x-scheme-handler/sms" = "org.gnome.Shell.Extensions.GSConnect.desktop";
            "x-scheme-handler/tel" = "org.gnome.Shell.Extensions.GSConnect.desktop";
            "application/x-trash" = "org.gnome.TextEditor.desktop";
            "application/vnd.ms-publisher" = "org.gnome.TextEditor.desktop";
            "application/octet-stream" = "org.gnome.TextEditor.desktop";
            "image/png" = [
                "org.gnome.Loupe.desktop"
                "com.github.maoschanz.drawing.desktop"
            ];
        };
  
        xdg.mime.removedAssociations = { };
  
        # Default Applications
        xdg.mime.defaultApplications = {
            "x-scheme-handler/terminal" = "ghostty.desktop"; 
            "application/illustrator" = "org.gnome.Evince.desktop";
            "application/mxf" = "mpv.desktop";
            "application/ogg" = "mpv.desktop";
            "application/oxps" = "org.gnome.Evince.desktop";
            "application/pdf" = "org.gnome.Evince.desktop";
            "application/postscript" = "org.gnome.Evince.desktop";
            "application/sdp" = "mpv.desktop";
            "application/smil" = "mpv.desktop";
            "application/streamingmedia" = "mpv.desktop";
            "application/vnd.apple.mpegurl" = "mpv.desktop";
            "application/vnd.comicbook+zip" = "org.gnome.Evince.desktop";
            "application/vnd.comicbook-rar" = "org.gnome.Evince.desktop";
            "application/vnd.ms-asf" = "mpv.desktop";
            "application/vnd.ms-xpsdocument" = "org.gnome.Evince.desktop";
            "application/vnd.rn-realmedia" = "mpv.desktop";
            "application/vnd.rn-realmedia-vbr" = "mpv.desktop";
            "application/x-bzdvi" = "org.gnome.Evince.desktop";
            "application/x-bzpdf" = "org.gnome.Evince.desktop";
            "application/x-bzpostscript" = "org.gnome.Evince.desktop";
            "application/x-cb7" = "org.gnome.Evince.desktop";
            "application/x-cbr" = "org.gnome.Evince.desktop";
            "application/x-cbt" = "org.gnome.Evince.desktop";
            "application/x-cbz" = "org.gnome.Evince.desktop";
            "application/x-cue" = "mpv.desktop";
            "application/x-dvi" = "org.gnome.Evince.desktop";
            "application/x-ext-cb7" = "org.gnome.Evince.desktop";
            "application/x-ext-cbr" = "org.gnome.Evince.desktop";
            "application/x-ext-cbt" = "org.gnome.Evince.desktop";
            "application/x-ext-cbz" = "org.gnome.Evince.desktop";
            "application/x-ext-djv" = "org.gnome.Evince.desktop";
            "application/x-ext-djvu" = "org.gnome.Evince.desktop";
            "application/x-ext-dvi" = "org.gnome.Evince.desktop";
            "application/x-ext-eps" = "org.gnome.Evince.desktop";
            "application/x-ext-pdf" = "org.gnome.Evince.desktop";
            "application/x-ext-ps" = "org.gnome.Evince.desktop";
            "application/x-extension-m4a" = "mpv.desktop";
            "application/x-extension-mp4" = "mpv.desktop";
            "application/x-gzdvi" = "org.gnome.Evince.desktop";
            "application/x-gzpdf" = "org.gnome.Evince.desktop";
            "application/x-gzpostscript" = "org.gnome.Evince.desktop";
            "application/x-matroska" = "mpv.desktop";
            "application/x-mpegurl" = "mpv.desktop";
            "application/x-ogg" = "mpv.desktop";
            "application/x-ogm" = "mpv.desktop";
            "application/x-ogm-audio" = "mpv.desktop";
            "application/x-ogm-video" = "mpv.desktop";
            "application/x-shellscript" = "org.gnome.TextEditor.desktop";
            "application/x-shorten" = "mpv.desktop";
            "application/x-smil" = "mpv.desktop";
            "application/x-streamingmedia" = "mpv.desktop";
            "application/x-xzpdf" = "org.gnome.Evince.desktop";
            "audio/3gpp" = "mpv.desktop";
            "audio/3gpp2" = "mpv.desktop";
            "audio/AMR" = "mpv.desktop";
            "audio/aac" = "mpv.desktop";
            "audio/ac3" = "mpv.desktop";
            "audio/aiff" = "mpv.desktop";
            "audio/amr-wb" = "mpv.desktop";
            "audio/dv" = "mpv.desktop";
            "audio/eac3" = "mpv.desktop";
            "audio/flac" = "mpv.desktop";
            "audio/m3u" = "mpv.desktop";
            "audio/m4a" = "mpv.desktop";
            "audio/mp1" = "mpv.desktop";
            "audio/mp2" = "mpv.desktop";
            "audio/mp3" = "mpv.desktop";
            "audio/mp4" = "mpv.desktop";
            "audio/mpeg" = "mpv.desktop";
            "audio/mpeg2" = "mpv.desktop";
            "audio/mpeg3" = "mpv.desktop";
            "audio/mpegurl" = "mpv.desktop";
            "audio/mpg" = "mpv.desktop";
            "audio/musepack" = "mpv.desktop";
            "audio/ogg" = "mpv.desktop";
            "audio/opus" = "mpv.desktop";
            "audio/rn-mpeg" = "mpv.desktop";
            "audio/scpls" = "mpv.desktop";
            "audio/vnd.dolby.heaac.1" = "mpv.desktop";
            "audio/vnd.dolby.heaac.2" = "mpv.desktop";
            "audio/vnd.dts" = "mpv.desktop";
            "audio/vnd.dts.hd" = "mpv.desktop";
            "audio/vnd.rn-realaudio" = "mpv.desktop";
            "audio/vorbis" = "mpv.desktop";
            "audio/wav" = "mpv.desktop";
            "audio/webm" = "mpv.desktop";
            "audio/x-aac" = "mpv.desktop";
            "audio/x-adpcm" = "mpv.desktop";
            "audio/x-aiff" = "mpv.desktop";
            "audio/x-ape" = "mpv.desktop";
            "audio/x-m4a" = "mpv.desktop";
            "audio/x-matroska" = "mpv.desktop";
            "audio/x-mp1" = "mpv.desktop";
            "audio/x-mp2" = "mpv.desktop";
            "audio/x-mp3" = "mpv.desktop";
            "audio/x-mpegurl" = "mpv.desktop";
            "audio/x-mpg" = "mpv.desktop";
            "audio/x-ms-asf" = "mpv.desktop";
            "audio/x-ms-wma" = "mpv.desktop";
            "audio/x-musepack" = "mpv.desktop";
            "audio/x-pls" = "mpv.desktop";
            "audio/x-pn-au" = "mpv.desktop";
            "audio/x-pn-realaudio" = "mpv.desktop";
            "audio/x-pn-wav" = "mpv.desktop";
            "audio/x-pn-windows-pcm" = "mpv.desktop";
            "audio/x-realaudio" = "mpv.desktop";
            "audio/x-scpls" = "mpv.desktop";
            "audio/x-shorten" = "mpv.desktop";
            "audio/x-tta" = "mpv.desktop";
            "audio/x-vorbis" = "mpv.desktop";
            "audio/x-vorbis+ogg" = "mpv.desktop";
            "audio/x-wav" = "mpv.desktop";
            "audio/x-wavpack" = "mpv.desktop";
            "image/bmp" = "org.gnome.eog.desktop";
            "image/gif" = "org.gnome.eog.desktop";
            "image/jpeg" = "org.gnome.eog.desktop";
            "image/jpg" = "org.gnome.eog.desktop";
            "image/pjpeg" = "org.gnome.eog.desktop";
            "image/png" = "org.gnome.eog.desktop";
            "image/svg+xml" = "org.gnome.eog.desktop";
            "image/svg+xml-compressed" = "org.gnome.eog.desktop";
            "image/tiff" = "org.gnome.Evince.desktop";
            "image/vnd.djvu+multipage" = "org.gnome.Evince.desktop";
            "image/vnd.wap.wbmp" = "org.gnome.eog.desktop";
            "image/x-icns" = "org.gnome.eog.desktop";
            "image/x-bmp" = "org.gnome.eog.desktop";
            "image/x-bzeps" = "org.gnome.Evince.desktop";
            "image/x-eps" = "org.gnome.Evince.desktop";
            "image/x-gray" = "org.gnome.eog.desktop";
            "image/x-gzeps" = "org.gnome.Evince.desktop";
            "image/x-icb" = "org.gnome.eog.desktop";
            "image/x-ico" = "org.gnome.eog.desktop";
            "image/x-pcx" = "org.gnome.eog.desktop";
            "image/x-png" = "org.gnome.eog.desktop";
            "image/x-portable-anymap" = "org.gnome.eog.desktop";
            "image/x-portable-bitmap" = "org.gnome.eog.desktop";
            "image/x-portable-graymap" = "org.gnome.eog.desktop";
            "image/x-portable-pixmap" = "org.gnome.eog.desktop";
            "image/x-xbitmap" = "org.gnome.eog.desktop";
            "image/x-xpixmap" = "org.gnome.eog.desktop";
            "text/english" = "nvim.desktop";
            "text/html" = "firefox-esr.desktop";
            "text/plain" = "org.gnome.TextEditor.desktop";
            "text/x-c" = "nvim.desktop";
            "text/x-c++" = "nvim.desktop";
            "text/x-c++hdr" = "nvim.desktop";
            "text/x-c++src" = "nvim.desktop";
            "text/x-chdr" = "nvim.desktop";
            "text/x-csrc" = "nvim.desktop";
            "text/x-java" = "nvim.desktop";
            "text/x-makefile" = "nvim.desktop";
            "text/x-moc" = "nvim.desktop";
            "text/x-pascal" = "nvim.desktop";
            "text/x-tcl" = "nvim.desktop";
            "text/x-tex" = "nvim.desktop";
            "video/3gp" = "mpv.desktop";
            "video/3gpp" = "mpv.desktop";
            "video/3gpp2" = "mpv.desktop";
            "video/avi" = "mpv.desktop";
            "video/divx" = "mpv.desktop";
            "video/dv" = "mpv.desktop";
            "video/fli" = "mpv.desktop";
            "video/flv" = "mpv.desktop";
            "video/mkv" = "mpv.desktop";
            "video/mp2t" = "mpv.desktop";
            "video/mp4" = "mpv.desktop";
            "video/mp4v-es" = "mpv.desktop";
            "video/mpeg" = "mpv.desktop";
            "video/msvideo" = "mpv.desktop";
            "video/ogg" = "mpv.desktop";
            "video/quicktime" = "mpv.desktop";
            "video/vnd.divx" = "mpv.desktop";
            "video/vnd.mpegurl" = "mpv.desktop";
            "video/vnd.rn-realvideo" = "mpv.desktop";
            "video/webm" = "mpv.desktop";
            "video/x-avi" = "mpv.desktop";
            "video/x-flc" = "mpv.desktop";
            "video/x-flic" = "mpv.desktop";
            "video/x-flv" = "mpv.desktop";
            "video/x-m4v" = "mpv.desktop";
            "video/x-matroska" = "mpv.desktop";
            "video/x-mpeg2" = "mpv.desktop";
            "video/x-mpeg3" = "mpv.desktop";
            "video/x-ms-afs" = "mpv.desktop";
            "video/x-ms-asf" = "mpv.desktop";
            "video/x-ms-wmv" = "mpv.desktop";
            "video/x-ms-wmx" = "mpv.desktop";
            "video/x-ms-wvxvideo" = "mpv.desktop";
            "video/x-msvideo" = "mpv.desktop";
            "video/x-ogm" = "mpv.desktop";
            "video/x-ogm+ogg" = "mpv.desktop";
            "video/x-theora" = "mpv.desktop";
            "video/x-theora+ogg" = "mpv.desktop";
            "x-scheme-handler/about" = "firefox.desktop";
            "x-scheme-handler/http" = "firefox-esr.desktop";
            "x-scheme-handler/https" = "firefox-esr.desktop";
            "x-scheme-handler/sgnl" = "signal-desktop.desktop";
            "x-scheme-handler/signalcaptcha" = "signal-desktop.desktop";
            "x-scheme-handler/unknown" = "firefox.desktop";
            "x-scheme-handler/chrome" = "firefox-esr.desktop";
            "application/x-extension-htm" = "firefox-esr.desktop";
            "application/x-extension-html" = "firefox-esr.desktop";
            "application/x-extension-shtml" = "firefox-esr.desktop";
            "application/xhtml+xml" = "firefox-esr.desktop";
            "application/x-extension-xhtml" = "firefox-esr.desktop";
            "application/x-extension-xht" = "firefox-esr.desktop";
            "application/x-trash" = "org.gnome.TextEditor.desktop";
            "application/vnd.ms-publisher" = "org.gnome.TextEditor.desktop";
            "application/octet-stream" = "org.gnome.TextEditor.desktop";
        };  
        
    };}
