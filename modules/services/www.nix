# dotfiles/modules/services/www.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 duck say ⮞ file-server
  config,
  lib,       
  pkgs,   
  ...
} : with lib;
let 
  cfg = config.services.file-server;
  # 🦆 says ⮞ default index.html file for the file server
  index = config.this.user.me.dotfilesDir + "/modules/services/file-server/browse.html";
  # 🦆 says ⮞ directory to share - default's to `~/Public`
  publicPath = "/home/" + config.this.user.me.name + "/Public";
  
  # 🦆 says ⮞ detect caddy
  caddyHost = lib.elem "caddy" config.this.host.modules.networking;
  caddyUser = if caddyHost then config.systemd.services.caddy.serviceConfig.User or "caddy" else "nobody";
  caddyHome = if caddyHost && config.users.users ? ${caddyUser}
               then config.users.users.${caddyUser}.home
               else "/var/lib/caddy";
  caddyGroup = if caddyHost then caddyUser else "nogroup";
  caddyTemplateDir = caddyHome + "/templates";

  caddyServer = if caddyHost then "true" else "false";

in {
  options.services.file-server = {
    user = mkOption {
      type = types.str;
      default = "www-data";
      description = "User that runs the file-server";
    };

    group = mkOption {
      type = types.str;
      default = "www-data";
      description = "Group that runs the file-server";
    };

    root = mkOption {
      type = types.path;
      default = "/var/lib/www/file-server";
      description = "File server root directory.";
    };

    publicPath = mkOption {
      type = types.path;
      default = publicPath;
      description = "Path to the directory to share. Will be symlinked into file-server root.";
    };

    port = mkOption {
      type = types.port;
      default = 11111;
      description = "Port to serve the server on";
    };

    host = mkOption {
      type = types.str;
      default = "0.0.0.0";
      description = "Host to bind the file-server to.";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to open the port in the firewall";
    };
  };

  config = lib.mkIf (lib.elem "www" config.this.host.modules.services) {
    # 🦆 duck say ⮞ create user & group
    users.users = {
      www-data = {
        group = cfg.group;
        isSystemUser = true;
      };
    };

    users.groups = {
      ${cfg.group} = {};
    };

    # 🦆 duck say ⮞ create directories
    systemd.tmpfiles.rules = [
      "d ${cfg.root} 0755 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.publicPath} 0755 ${cfg.user} ${cfg.group} - -"
      "L+ ${cfg.root}/public 0755 ${cfg.user} ${cfg.group} - ${cfg.publicPath}"
    ] ++ lib.optionals caddyHost [
      # 🦆 duck say ⮞ create caddy template dir
      "d ${caddyTemplateDir} 0755 ${caddyUser} ${caddyUser} - -"
    ];

    # 🦆 duck say ⮞ open firewall port?
    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };

    # 🦆 duck say ⮞ create index.html
    system.activationScripts.file-server = ''
      # 🦆 duck say ⮞ if caddy iz enabled - setup file-server 4 caddy yo
      if [[ "${caddyServer}" == "true" ]]; then
        # 🦆 duck say ⮞ caddy mode - serve the html as template
        echo "Setting up file-server for Caddy..."
        mkdir -p "${cfg.root}"
        mkdir -p "${caddyTemplateDir}"
        
        # 🦆 duck say ⮞ copy template 2 template dir
        cp "${index}" "${caddyTemplateDir}/browse.html"
        chown ${caddyUser}:${caddyUser} "${caddyTemplateDir}/browse.html"
        chmod 644 "${caddyTemplateDir}/browse.html"
        
        # 🦆 duck say ⮞ permissionz
        chown -R ${caddyUser}:${caddyUser} "${cfg.root}" || true
        chmod -R 755 "${cfg.root}"
        
        # 🦆 duck say ⮞ remove existing index.html
        rm -f "${cfg.root}/index.html"

        # 🦆 duck say ⮞ mkSure publiivPath symlinkz yo
        echo "Copying Public files to file-server directory..."
        mkdir -p "${cfg.root}/public"
    
        # Copy files only if they don't already exist in destination
        if [ -d "${cfg.publicPath}" ]; then
          # Use rsync to copy only new files (preserves directory structure)
          ${pkgs.rsync}/bin/rsync -av --ignore-existing "${cfg.publicPath}/" "${cfg.root}/public/" || echo "rsync failed, trying cp..."
      
          # Fallback to cp if rsync fails
          if [ ! "$(ls -A "${cfg.root}/public")" ]; then
            cp -r "${cfg.publicPath}"/* "${cfg.root}/public/" 2>/dev/null || true
          fi
      
          echo "Public files copied to: ${cfg.root}/public"
        else
          echo "Warning: Public path ${cfg.publicPath} does not exist"
        fi
    
        # Ensure proper ownership of copied files
        chown -R ${caddyUser}:${caddyUser} "${cfg.root}/public" || true
        chmod -R 644 "${cfg.root}/public" || true
        find "${cfg.root}/public" -type d -exec chmod 755 {} \; || true

        # 🦆 duck say ⮞ copy README.md for instant display
        if [ -f "${cfg.root}/public/README.md" ]; then
          cp "${cfg.root}/public/README.md" "${cfg.root}/README.md" 2>/dev/null || true
          chown ${caddyUser}:${caddyUser} "${cfg.root}/README.md" 2>/dev/null || true
          chmod 644 "${cfg.root}/README.md" 2>/dev/null || true
        fi

      else
        # 🦆 duck say ⮞ python mode - create index.html
        echo "Setting up standalone file-server..."
        mkdir -p "${cfg.root}"
        cat "${index}" > "${cfg.root}/index.html"
        chown ${cfg.user}:${cfg.group} "${cfg.root}/index.html"
        chmod 644 "${cfg.root}/index.html"
        
        # 🦆 duck say ⮞ mkSure publiivPath iz copied yo
        echo "Copying Public files to file-server directory..."
        mkdir -p "${cfg.root}/public"
    
        if [ -d "${cfg.publicPath}" ]; then
          ${pkgs.rsync}/bin/rsync -av --ignore-existing "${cfg.publicPath}/" "${cfg.root}/public/" || echo "rsync failed, trying cp..."
          if [ ! "$(ls -A "${cfg.root}/public")" ]; then
            cp -r "${cfg.publicPath}"/* "${cfg.root}/public/" 2>/dev/null || true
          fi
          echo "Public files copied to: ${cfg.root}/public"
        fi
    
        chown -R ${cfg.user}:${cfg.group} "${cfg.root}/public" || true
        chmod -R 644 "${cfg.root}/public" || true
        find "${cfg.root}/public" -type d -exec chmod 755 {} \; || true

        # 🦆 duck say ⮞ copy README.md for instant display
        if [ -f "${cfg.root}/public/README.md" ]; then
          cp "${cfg.root}/public/README.md" "${cfg.root}/README.md" 2>/dev/null || true
          chown ${caddyUser}:${caddyUser} "${cfg.root}/README.md" 2>/dev/null || true
          chmod 644 "${cfg.root}/README.md" 2>/dev/null || true
        fi
      fi  
  
      # 🦆 duck say ⮞ verify public directory
      if [ -d "${cfg.root}/public" ] && [ "$(ls -A "${cfg.root}/public")" ]; then
        echo "Public directory verified with $(find "${cfg.root}/public" -type f | wc -l) files"
      else
        echo -e "\e[3m\e[38;2;0;150;150m🦆 duck say \e[1m\e[38;2;255;255;0m⮞\e[0m\e[3m\e[38;2;0;150;150m fuck ❌ Public directory empty/missing: ${cfg.root}/public\e[0m"
      fi
    '';
    
    # 🦆 duck say ⮞ python http.server (if not usin' caddy)
    systemd.services.file-server = {
      description = "Python file-server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = cfg.root;
        ExecStart = "${pkgs.python3}/bin/python -m http.server ${toString cfg.port}";
        Restart = "on-failure";
      };
    };
    
  };}
