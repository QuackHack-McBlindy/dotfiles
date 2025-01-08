{ config, pkgs, ... }:

{
  services.monero = {
    enable = true;
    dataDir = "/var/lib/monero";
    mining.enable = true;
    mining.address = "YOUR_MONERO_ADDRESS";  # Replace with your Monero address
    mining.threads = 4;                      # Use 4 threads for mining, adjust as needed
    rpc.user = "rpcuser";                    # RPC username
    rpc.password = config.sops.secrets.MONERO_PASSWORD.path;          # RPC password
    rpc.address = "0.0.0.0";                 # Listen on all interfaces
    rpc.port = 18081;                        # Default RPC port
    rpc.restricted = true;                   # Restrict RPC to view-only commands
    limits.upload = 1000;                    # Upload rate limit (kB/s)
    limits.download = 1000;                  # Download rate limit (kB/s)
    limits.threads = 8;                      # Maximum number of threads
    limits.syncSize = 100;                   # Number of blocks to sync at once
    extraNodes = [ "peer1.example.com" ];   # Additional peer nodes
    priorityNodes = [ "peer2.example.com" ];# Priority peer nodes
    exclusiveNodes = [ "peer3.example.com" ];# Exclusive peer nodes
    extraConfig = ''
      # Extra configuration lines
    '';
  };
}
