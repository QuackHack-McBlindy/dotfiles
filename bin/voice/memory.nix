# dotfiles/bin/config/memory.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ stats for fail ratio and memory for context awareness
  self,
  lib,
  config,
  pkgs,
  sysHosts,
  cmdHelpers,
  ...
} : let
  # 🦆 says ⮞ Statistical logging for failed commands
  statsDir = "/home/${config.this.user.me.name}/.local/share/yo/stats";
  failedCommandsLog = "${statsDir}/failed_commands.log";
  commandStatsDB = "${statsDir}/command_stats.json";
  
in {
  yo.scripts = {
    memory = {
      description = "Memory is stats and metrics that acts as contexual awareness for the Brain (NLP)";
      category = "🗣️ Voice"; # 🦆 says ⮞ duckgorize iz zmart wen u hab many scriptz i'd say!     
      aliases = [ "stats" ];
      autoStart = false;
      logLevel = "INFO";
      helpFooter = ''
        echo "[🦆📶] yo memory"

        echo "[🦆📶]"    
        echo "Commands:"
        echo "  failed      - Show most frequently failed commands"
        echo "  successful  - Show most used successful commands"
        echo "  fuzzy       - Show fuzzy match statistics"
        echo "  summary     - Show overall statistics"
        echo "  reset       - Reset all statistics"
        echo "  tail        - Live tail of failed commands"
      '';
      parameters = [ # 🦆 says ⮞ set your mosquitto user & password
        { 
          name = "show";
          type = "string";
          description = "What stat to analyze";
          default = "summary";
          values = [ "failed" "successful" "summary" "fuzzy" ];
        }      
        { name = "tail"; type = "bool"; description = "Live tail of failed commands"; default = false; }
        { name = "reset"; type = "bool"; description = "Warning! Will reset all stats!"; default = false; }
      ];

      code = ''
        set +u  
        ${cmdHelpers} # 🦆 says ⮞load required bash helper functions 

        load_stats() {
          if [ -f "${commandStatsDB}" ]; then
            cat "${commandStatsDB}"
          else
            echo '{"failed_commands": {}, "successful_commands": {}, "fuzzy_matches": {}}'
          fi
        }
    
        save_stats() {
          local stats="$1"
          echo "$stats" > "${commandStatsDB}"
        }
    
        increment_stat() {
          local category="$1"
          local key="$2"
          local stats=$(load_stats)      
          local current_count=$(echo "$stats" | jq -r ".''${category}.\"$key\" // 0")
          local new_count=$((current_count + 1))
      
          stats=$(echo "$stats" | jq ".''${category}.\"$key\" = $new_count")
          save_stats "$stats"
        }
    
        show_failed() {
          local stats=$(load_stats)
          echo "🦆 Most Frequently Failed Commands:"
          echo "$stats" | jq -r '.failed_commands | to_entries | sort_by(-.value) | .[] | "\(.key): \(.value) failures"' | head -20
        }
    
        show_successful() {
          local stats=$(load_stats)
          echo "🦆 Most Used Successful Commands:"
          echo "$stats" | jq -r '.successful_commands | to_entries | sort_by(-.value) | .[] | "\(.key): \(.value) successes"' | head -20
        }
    
        show_fuzzy() {
          local stats=$(load_stats)
          echo "🦆 Fuzzy Match Statistics:"
          echo "$stats" | jq -r '.fuzzy_matches | to_entries | sort_by(-.value) | .[] | "\(.key): \(.value) fuzzy matches"' | head -20
        }
    
        show_summary() {
          local stats=$(load_stats)
          local total_failed=$(echo "$stats" | jq '.failed_commands | length')
          local total_success=$(echo "$stats" | jq '.successful_commands | length')
          local total_fuzzy=$(echo "$stats" | jq '.fuzzy_matches | length')      
          local failed_count=$(echo "$stats" | jq '[.failed_commands[]] | add // 0')
          local success_count=$(echo "$stats" | jq '[.successful_commands[]] | add // 0')
          local fuzzy_count=$(echo "$stats" | jq '[.fuzzy_matches[]] | add // 0')
      
          cat << EOF
[🦆📶] Command Statistics Summary:
    
[🦆📶] Total Unique Failed Commands: $total_failed
[🦆📶] Total Failed Attempts: $failed_count
    
[🦆📶] Total Unique Successful Commands: $total_success  
[🦆📶] Total Successful Executions: $success_count
    
[🦆📶] Total Unique Fuzzy Matches: $total_fuzzy
[🦆📶] Total Fuzzy Match Uses: $fuzzy_count
    
Success Rate: $(if [ $((success_count + failed_count)) -gt 0 ]; then echo "scale=2; $success_count * 100 / ($success_count + $failed_count)" | bc; else echo "0"; fi)%
EOF
        }
    
        reset_stats() {
          echo '{"failed_commands": {}, "successful_commands": {}, "fuzzy_matches": {}}' > "${commandStatsDB}"
          echo "[🦆📶]  Statistics reset!"
        }
    
        tail_failed() {
          tail -f "${failedCommandsLog}"
        }
        if [[ "$good" == "true" ]]; then
          confirm_last_command
        fi
        if [[ "$reset" == "true" ]]; then
          reset_stats
        fi
        if [[ "$tail" == "true" ]]; then
          tail_failed
        fi
        if [[ "$show" == "failed" ]]; then
          show_failed
        fi
        if [[ "$show" == "successful" ]]; then
          show_successful
        fi
        if [[ "$show" == "summary" ]]; then
          show_summary
        fi
    
        case "''${1:-}" in
          failed) show_failed ;;
          successful) show_successful ;;
          fuzzy) show_fuzzy ;;
          summary) show_summary ;;
          reset) reset_stats ;;
          tail) tail_failed ;;
          *) show_help ;;
        esac
      '';
    };
    
  };}    
