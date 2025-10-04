# dotfiles/lib/dirMap.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 duck say ⮞ service host finder
  lib,
  pkgs
} : {
  # 🦆 duck say ⮞ find a single host running a specific service
  findServiceHost = { nixosConfigurations, serviceAttrPath }:
    let
      sysHosts = attrNames nixosConfigurations;
      serviceHost = findSingle (host:
        let cfg = nixosConfigurations.${host}.config;
        in attrByPath serviceAttrPath false cfg
      ) null null sysHosts;
    in
    serviceHost;

  # 🦆 duck say ⮞ get the IP address of a host, with DNS fallback
  getHostIP = { nixosConfigurations, host }:
    if host != null then
      nixosConfigurations.${host}.config.this.host.ip or (
        let
          resolved = builtins.readFile (pkgs.runCommand "resolve-host" { } ''
            ${pkgs.dnsutils}/bin/host -t A ${host} | grep "has address" | head -1 > $out
          '');
          parts = splitString " " (stringAsChars (x: x != "\n") resolved);
        in
        if length parts >= 4 then
          elemAt parts 3
        else
          throw "Cannot resolve IP for host ${host}"
      )
    else
      throw "Host is null";

  # 🦆 duck say ⮞ find service host and get IP
  findServiceHostWithIP = { nixosConfigurations, serviceAttrPath }:
    let
      host = findServiceHost {
        inherit nixosConfigurations serviceAttrPath;
      };
      ip = getHostIP {
        inherit nixosConfigurations host;
      };
    in
    { inherit host ip; };

  # 🦆 duck say ⮞ find service host with IP and construct URL
  findServiceEndpoint = { nixosConfigurations, serviceAttrPath, port }:
    let
      hostInfo = findServiceHostWithIP {
        inherit nixosConfigurations serviceAttrPath;
      };
    in
    hostInfo // {
      url = "http://${hostInfo.ip}:${toString port}";
    };

  # 🦆 duck say ⮞ find all hosts running a service
  findAllServiceHosts = { nixosConfigurations, serviceAttrPath }:
    let
      sysHosts = attrNames nixosConfigurations;
      serviceHosts = filter (host:
        let cfg = nixosConfigurations.${host}.config;
        in attrByPath serviceAttrPath false cfg
      ) sysHosts;
    in
    serviceHosts;

  # 🦆 duck say ⮞ get service info for all hosts that have it enabled
  findAllServiceEndpoints = { nixosConfigurations, serviceAttrPath, port }:
    let
      hosts = findAllServiceHosts {
        inherit nixosConfigurations serviceAttrPath;
      };
      hostInfo = map (host: {
        inherit host;
        ip = getHostIP { inherit nixosConfigurations host; };
      }) hosts;
    in
    map (info: info // {
      url = "http://${info.ip}:${toString port}";
    }) hostInfo;
}
