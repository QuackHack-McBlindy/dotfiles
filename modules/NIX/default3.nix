# dotfiles/lib/modules.nix
{ 
    config,
    lib,
    pkgs,
    ...
} : let
  inherit (lib) types mkOption;
  importModulesRecursive = dir:
    let
      entries = builtins.readDir dir;
      processEntry = name: type:
        if type == "directory" then
          importModulesRecursive (dir + "/${name}")
        else if type == "regular" && lib.hasSuffix ".nix" name then
          [ (dir + "/${name}") ]
        else
          [];
    in
      lib.lists.flatten (lib.attrsets.mapAttrsToList processEntry entries);
in {
    imports = [./../security.nix] ++
        (importModulesRecursive ./../modules/hardware) ++
        (importModulesRecursive ./../modules/system) ++
        (importModulesRecursive ./../modules/networking) ++
        (importModulesRecursive ./../modules/services) ++
        (importModulesRecursive ./../modules/programs) ++
        (importModulesRecursive ./../modules/virtualisation);


    options.this = {
        user = mkOption {
            type = types.str;
            example = "pungkula";
            default = "pungkula";
            description = "Primary user account";
        };   
        host = {
            system = mkOption {
                type = types.str;
                example = "x86_64-linux";
                default = builtins.currentSystem;
                description = "System architecture for the host. Available options are: x86_64-linux or aarch64-linux";
            };
            hostname = mkOption {
                type = types.str;
                example = "desktop";
                default = 
                    if config.networking.hostName != ""
                    then config.networking.hostName
                    else "nixos-${lib.strings.substring 0 8 (builtins.hashString "sha256" builtins.currentSystem)}";
                description = "System hostname";
            };
            interface = mkOption {
                type = types.listOf types.str;
                example = [ "enp119s0" ];
                default = [];
                description = "Network interfaces to configure";
            };
            ip = mkOption {
                type = types.str;
                example = "182,168.1.100";
                default = null;
                description = "IP address to bind host to";
            };
            wgip = mkOption {
                type = types.str;
                example = "10.10.10.10";
                default = null;
                description = "WireGuard peer IP address";
            };
            modules = {
                hardware = mkOption {
                    type = types.listOf types.str;
                    example = [ "cpu/intel" "gpu/amd" ];
                    default = [];
                    description = "Hardware configuration modules to enable";
                };
                networking = mkOption {
                    type = types.listOf types.str;
                    example = [ "default" "caddy" ];
                    default = [ "default" ];
                    description = "Networking modules to enable";
                };
                services = mkOption {
                    type = types.listOf types.str;
                    example = [ "ssh" "pairdrop" ];
                    default = [];
                    description = "Service modules to enable";
                };
                programs = mkOption {
                    type = types.listOf types.str;
                    example = [ "thunar" ];
                    default = [];
                    description = "Program modules to enable";
                };
                virtualisation = mkOption {
                    type = types.listOf types.str;
                    example = [ "docker" "vm" ];
                    default = [];
                    description = "Virtualisation modules to enable";
                };      
            };   
            keys = {
                privateKeys = mkOption {
                    type = types.attrsOf types.str;
                    description = "Private keys configuration";
                    default = {};
                };
                publicKeys = mkOption {
                    type = types.attrsOf types.str;
                    description = "Public keys configuration";
                    default = {};
                };
            };         
        };      
    };
    config._module.args.this = {
        mkModule = moduleType: name: config:
            lib.mkIf (lib.elem name config.this.host.modules.${moduleType}) config;
    };}

