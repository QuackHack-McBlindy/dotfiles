# dotfiles/bin/system/pkgs.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
# » ★ QuackHack-McBLindy.com ★ «
{ # 🦆 duck say ⮞ adds system packages to the flake
  self,
  config,
  pkgs,
  cmdHelpers,
  ...
} : let
  sysHosts = builtins.attrNames self.nixosConfigurations ++ [ "all" ];
  vmHosts = builtins.filter (host:
    self.nixosConfigurations.${host}.self.config.system.build ? vm
  ) sysHosts;
in {
  yo.scripts = {
    pkgs = {
      description = "Add system package to specified hosts nixosConfiguration.";
      category = "🖥️ System Management";
      parameters = [
        {
          name = "host";
          type = "string";
          description = "Host that gets the package added.";
          optional = false;
          values = sysHosts;
          default = "all";
        }
        { name = "pkgs"; type = "string"; description = "Package to add."; optional = false; }
        { name = "file"; type = "path"; description = "Path to the file containing system packages."; optional = false; default = config.this.user.me.dotfilesDir + "/modules/system/pkgs.nix"; }
      ];
      code = ''
       ${cmdHelpers}
        HOST="$host"
        PKG="$pkgs"
        FILE="$file"

        [[ "$PKG" == pkgs.* ]] || PKG="pkgs.$PKG"

        if grep -Fq "$PKG" "$FILE"; then
            dt_warning "Note: \"$PKG\" already appears somewhere in $FILE (adding anyway)" >&2
        fi

        cp -- "$FILE" "$FILE.bak"

        if ! awk -v host="$HOST" -v pkg="$PKG" '
            function count_open(s,   t)  { t = s; return gsub(/\[/, "[", t) }
            function count_close(s,   t) { t = s; return gsub(/\]/, "]", t) }
            function get_indent(s,   n)  {
                n = match(s, /^[[:space:]]*/)
                return (n ? substr(s, 1, RLENGTH) : "")
            }

            BEGIN { state = 0; depth = 0; last_indent = ""; is_all = (host == "all") }

            {
                if (state == 0) {
                    if (is_all) {
                        if (index($0, "INSTALLED ON ALL HOSTS") > 0) {
                            state = 3          # waiting for the opening [
                            print
                            next
                        }
                    } else {
                        if (index($0, "config.networking.hostName == \"" host "\"") > 0) {
                            state = 1
                            o = count_open($0); c = count_close($0)

                            if (o > c) {
                                depth = o - c
                                print
                                next
                            } else {
                                idx = 0
                                for (i = length($0); i >= 1; i--)
                                    if (substr($0, i, 1) == "]") { idx = i; break }

                                if (idx == 0) {
                                    print "Error: malformed host line (no closing ])" > "/dev/stderr"
                                    exit 1
                                }
                                before = substr($0, 1, idx - 1)
                                after  = substr($0, idx)
                                sub(/[[:space:]]+$/, "", before)
                                print before " " pkg " " after
                                state = 2
                                next
                            }
                        }
                    }
                }

                if (state == 3) {
                    if ($0 ~ /[^[:space:]]/ && $0 ~ /\[/) {
                        o = count_open($0); c = count_close($0)
                        depth = o - c
                        state = 1
                        print
                        next
                    }
                    print
                    next
                }

                if (state == 1) {
                    o = count_open($0); c = count_close($0)
                    nd = depth + o - c

                    if (nd <= 0) {
                        indent = (last_indent != "" ? last_indent : get_indent($0) "    ")
                        print indent pkg
                        state = 2
                    } else if ($0 ~ /[^[:space:]]/) {
                        last_indent = get_indent($0)
                    }
                    depth = nd
                }
                print
            }

            END { if (state != 2) exit 1 }
        ' "$FILE" > "$FILE.tmp"; then
            mv -- "$FILE.bak" "$FILE"
            rm -f -- "$FILE.tmp"
            dt_error "failed to insert $PKG into host \"$HOST\"" >&2
            exit 1
        fi

        mv -- "$FILE.tmp" "$FILE"
        rm -f -- "$FILE.bak"
        dt_info "✓ Added $PKG to host \"$HOST\" in $FILE"
        dt_info "Rebuild system for changes to take effect!"
      '';
    };

  };}
