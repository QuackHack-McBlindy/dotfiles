
{
  pkgs,
  system,
  self,
  inputs
} : let
  cfg = inputs.nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = { inherit self inputs pkgs; };
    modules = [
      inputs.zigduck.nixosModules.zigduck
      inputs.yo.nixosModules.yo
      ({ lib, ... }: {
        system.stateVersion = "24.11";
        house.languages = [ "sv" ];

        house.zigbee.networkKeyFile = "/dev/null";
        house.zigbee.coordinator = {
          vendorId = "test";
          productId = "test";
        };
        house.zigbee.mosquitto.host = "localhost";

        house.rooms.test = { icon = "mdi:test"; };
        house.rooms.kitchen = { icon = "mdi:test"; };
        house.rooms.hallway = { icon = "mdi:test"; };

        house.zigbee.devices."test" = {
          friendly_name = "Test Device";
          room = "test";
          type = "light";
          endpoint = 1;
        };

        house.zigbee.devices."test1" = {
          friendly_name = "Test Device2";
          aliases = [ "dörr" "ytterdörren" ];
          room = "hallway";
          type = "sensor";
          endpoint = 1;
        };

        house.zigbee.devices."fläkt" = {
          friendly_name = "Fläkt";
          aliases = [ "fläkten" ];
          room = "kitchen";
          type = "outlet";
          endpoint = 1;
        };

        house.zigbee.devices."test3" = {
          friendly_name = "Test Device3";
          aliases = [ "3" ];
          room = "hallway";
          type = "light";
          endpoint = 1;
          supports_color = true;
        };

        house.zigbee.devices."test4" = {
          friendly_name = "Test Device4";
          aliases = [ "4" ];
          room = "kitchen";
          type = "light";
          endpoint = 1;
          supports_color = true;
        };

        house.zigbee.scenes = {
          dark = {
            _aliases = [ "mörkt" ];
            "Test Device4" = { state = "OFF"; };
          };
        };

        yo.fuzzy = {
          threshold = 0.6;
          conflict.detection = true;
          conflict.threshold = 70;
        };

        fileSystems = lib.mkForce {
          "/" = { device = "/dev/null"; fsType = "ext4"; };
        };
        boot.loader.grub.enable = lib.mkForce false;
      })
    ];
  };

  failures = builtins.filter
    (a: !a.assertion)
    cfg.config.assertions;

  renderMessage = f:
    let r = builtins.tryEval (builtins.stringLength f.message);
    in if r.success then f.message else "<message unavailable>";

  yoTests = pkgs.writeShellScript "yo-do-tests" ''
    set -euo pipefail

    check() {
      local input="$1"
      local expected="$2"
      local actual

      actual=$(YO_PREVIEW=true yo-do --input "$input")

      if [[ "$actual" != "$expected" ]]; then
        echo "FAIL: $input"
        echo "Expected: $expected"
        echo "Actual:   $actual"
        exit 1
      fi

      echo "PASS: $input"
    }

    check \
      "spelar björklöven just nu" \
      "yo duckPUCK-games --team IF Björklöven --type live"

    check \
      "om ytterdörren inte är öppen så säg ett skämt" \
      "yo if --condition ytterdörren inte är öppen --then säg ett skämt"
  '';
in
if failures == []
then pkgs.runCommand "grammar-check" {
  nativeBuildInputs = [
    pkgs.coreutils
    self.inputs.yo.packages.x86_64-linux.yo-rs
  ];
} ''
  echo "🦆 Grammar check passed"
  echo "Running yo do tests..."

  ${yoTests}

  echo "✅ All tests passed"
  touch $out
''
else throw (
  "🦆 Grammar check failed: ${toString (builtins.length failures)} assertion(s):\n"
  + builtins.concatStringsSep "\n"
    (map (f: "  • " + renderMessage f) failures)
)
