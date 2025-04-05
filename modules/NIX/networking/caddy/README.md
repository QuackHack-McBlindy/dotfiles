1: Add plugins by Editing caddy-src/main.go
2: Run go mod tidy
3: nix build (edit flake.nix vendor hash if neccesary)
4: Test: ./result/bin/caddy list-modules 
