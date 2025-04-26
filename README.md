<!-- YO_DOCS_START -->
| \`yo clean \` | gc | Run a total garbage collection: Removes old NixOS generations, empty trash, flush tmp files, whipes cache and runs a docker prune |
| \`yo deploy --host [--flake] [--user] [--repo] [--!]\` | d | Deploy NixOS system configurations to your remote servers |
| \`yo edit \` | config | yo CLI configuration mode |
| \`yo health [--host]\` | hc | Check system health status across your machines |
| \`yo pull [--flake]\` | pl | Pull dotfiles repo from GitHub |
| \`yo push [--flake]\` | ps | Push dotfiles to GitHub |
| \`yo reboot [--host]\` |  | Force reboot and wait for host |
| \`yo sops --input [--agePub]\` |  | Encrypts a file with sops-nix |
| \`yo switch [--flake] [--autoPull]\` | rb | Rebuild and switch Nix OS system configuration |
| \`yo yubi --operation --input\` | yk | Encrypts and decrypts files using a Yubikey and AGE |<!-- YO_DOCS_END -->
