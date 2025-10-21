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
      default = "/var/www/file-server";
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

    # 🦆 duck say ⮞ create the public directory
    systemd.tmpfiles.rules = [
      "d ${cfg.root} 0755 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.publicPath} 0755 ${cfg.user} ${cfg.group} - -"
      "L+ ${cfg.root}/share 0755 ${cfg.user} ${cfg.group} - ${cfg.publicPath}"
    ];

    # 🦆 duck say ⮞ open firewall port?
    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };

    # 🦆 duck say ⮞ create index.html
    system.activationScripts.file-server = ''
      if [ ! -f "${cfg.publicPath}/index.html" ]; then
        mkdir -p "${cfg.publicPath}"
        cat "${index}" > "${cfg.root}/index.html"
        chown -R ${cfg.user}:${cfg.group} "${cfg.publicPath}"
        chmod -R 755 "${cfg.publicPath}"
      fi
    '';
    
    # 🦆 duck say ⮞ python http.server
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
