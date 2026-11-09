# dotfiles/bin/system/switch.nix
# » ★ QuackHack-McBlindY.com ★ «
{
  self,
  config,
  pkgs,
  cmdHelpers,
  ...
} : let

in {
  yo = {
    scripts = {
      switch = {
        description = "Rebuild and switch with dry runs as default ('!' to save new system generation)";
        category = "🖥️ System Management";
        aliases = [ "rb" ];
        parameters = [
          {
            name = "flake";
            description = "Path to the directory containing your flake.nix";
            optional = false;
            default = config.this.user.me.dotfilesDir;
          }
          {
            name = "!";
            description = "Save a new system generation";
            optional = true;
          }
        ];

        code = ''
          ${cmdHelpers}

          if $DRY_RUN; then
            echo "❗ Test run: reboot will revert activation"
          fi

          fetch_nix_error_log() {
            local drv_path

            drv_path=$(grep -oE "Cannot build '/nix/store/[^']+\.drv'" \
              <<< "$BUILD_OUTPUT" \
              | head -n1 \
              | sed "s/^Cannot build '//; s/'$//")

            if [[ -n "$drv_path" ]]; then
              echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
              say_duck "BUILD ERROR LOG ❌🦆❌🦆❌🦆❌"
              echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

              echo "🦆 Failed derivation: $drv_path"
              echo

              nix log "$drv_path" 2>&1 | tail -n 100
            else
              echo "🦆 Could not locate failed derivation."
            fi
          }

          FAIL_COUNT_FILE="/tmp/nixos_rebuild_fail_count"

          if [[ -f "$FAIL_COUNT_FILE" ]]; then
            FAIL_COUNT=$(cat "$FAIL_COUNT_FILE")
          else
            FAIL_COUNT=0
          fi


          if $DRY_RUN; then
            rebuild_command="switch"
          else
            rebuild_command="test"
          fi

          cmd=(
            sudo ${pkgs.nixos-rebuild}/bin/nixos-rebuild
            "$rebuild_command"
            --flake "$flake"
            --show-trace
            --log-format internal-json
            -v
          )

          BUILD_LOG=$(mktemp /tmp/nixos-rebuild.XXXXXX.log)

          echo
          echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
          say_duck "🦆 STARTING REBUILD......"
          echo "⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️"
          say_duck "🔑🔑  TOUCH YUBIKEY  🔑🔑"
          echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
          echo


          set -o pipefail

          if "''${cmd[@]}" 2>&1 \
            | tee "$BUILD_LOG" \
            | ${pkgs.nix-output-monitor}/bin/nom --json
          then
            BUILD_STATUS=0
          else
            BUILD_STATUS=$?
          fi


          BUILD_OUTPUT=$(cat "$BUILD_LOG")
          rm -f "$BUILD_LOG"

          if [[ $BUILD_STATUS -eq 0 ]]; then

            if [[ $FAIL_COUNT -ge 11 ]]; then
              echo "🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆"
              echo "⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐"
              echo "🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆"
              echo "⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐"

              dt_info "🦆🎉 ! Rebuild successful! $FAIL_COUNT noob fails!"
              play_relax

            elif [[ $FAIL_COUNT -ge 6 ]]; then
              echo "🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆"
              echo "⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐"
              echo "🦆⭐🦆⭐🦆⭐🦆🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆"
              echo "⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐"

              play_relax

            elif [[ $FAIL_COUNT -ge 4 ]]; then
              echo "🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆"
              echo "⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐"
              echo "🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆"
              echo "⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐"

              dt_info "😅 phew! $FAIL_COUNT noob fails!"
              play_win

            else
              if $DRY_RUN; then
                echo "🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆"
                echo "⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐"
                echo "🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆"
                echo "⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐"

              else
                echo "🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆"
                echo "⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐"
                echo "🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆"
                echo "⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐🦆⭐"

                echo "⚠️⚠️⚠️⚠️⚠️⚠️ NO SYSTEM GENERATION SAVED ⚠️⚠️⚠️⚠️⚠️⚠️"
              fi

              play_win
            fi

            echo 0 > "$FAIL_COUNT_FILE"

          else
            FAIL_COUNT=$((FAIL_COUNT + 1))
            echo "$FAIL_COUNT" > "$FAIL_COUNT_FILE"

            fetch_nix_error_log

            if [[ $FAIL_COUNT -ge 5 ]]; then
              echo "❌🦆❌🦆❌🦆❌🦆❌🦆❌🦆❌🦆❌🦆❌"
              echo "🦆❌🦆❌🦆❌🦆❌🦆❌🦆❌🦆❌🦆❌🦆"

              say_duck " FUCK!  ❌🦆❌🦆❌🦆❌🦆"

              echo "❌🦆❌🦆❌🦆❌🦆❌🦆❌🦆❌🦆❌🦆❌"
              echo "🦆❌🦆❌🦆❌🦆❌🦆❌🦆❌🦆❌🦆❌🦆"

              play_fail2

            else
              echo "❌🦆❌🦆❌🦆❌🦆❌🦆❌🦆❌🦆❌🦆❌🦆❌🦆❌"
              echo "🦆❌🦆❌🦆❌🦆❌🦆❌🦆❌🦆❌🦆❌🦆❌🦆❌🦆"

              say_duck " FUCK!  ❌🦆❌🦆❌🦆❌🦆❌🦆"

              echo "❌🦆❌🦆❌🦆❌🦆❌🦆❌🦆❌🦆❌🦆❌🦆❌🦆❌"
              echo "🦆❌🦆❌🦆❌🦆❌🦆❌🦆❌🦆❌🦆❌🦆❌🦆❌🦆"

              play_fail
            fi

            exit 1
          fi
        '';

        voice = {
          enabled = true;
          priority = 5;
          fuzzy.enable = false;
          sentences = [
            "bygg om systemet"
          ];
        };
      };
    };

  };}
