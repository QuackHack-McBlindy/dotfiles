{pkgs, ...};
  hardware.ledger.enable = true;

  home.packages = with pkgs; [ledger-live-desktop];
}
